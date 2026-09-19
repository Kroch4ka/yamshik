# Yamshik — дизайн-документ (черновик v0.1)

Гем-ядро для унифицированной работы со службами доставки РФ («active_shipping для России»).
Архитектура: ядро `yamshik` + плагины по одному на службу (`yamshik-cdek` первым).

Этот файл — рабочий черновик для обсуждения. Правь прямо в тексте.

---

## 1. Принятые архитектурные решения

- **Ядро + плагины**: ядро не знает про конкретные службы; плагин при `require "yamshik/cdek"` регистрирует себя через `Yamshik.register_adapter(:cdek, Yamshik::Cdek::Adapter)`.
- **Совместимость версий**: контракт `Yamshik::Carrier` + доменные классы = публичный API ядра (semver). Плагин в gemspec: `add_dependency "yamshik", "~> X.Y"`.
- **Версии API курьерки** инкапсулированы в плагине: `Yamshik::Cdek::V2::Adapter`. Наружу — последняя версия, переопределение через конфиг (`api_version: :v2`). Ядро про версии API не знает.
- **HTTP**: Faraday. Ядро отдаёт плагинам сконфигурированный `Yamshik::HTTP::Client`: ретраи с backoff, circuit breaker (своя реализация, closed/open/half-open), таймауты, логгер, маппинг сетевых сбоев в иерархию исключений.
- **Без ActiveSupport** в ядре (работа вне Rails). Rails-интеграция — потенциально отдельный `yamshik-rails` позже.
- **Без вебхуков и поллинга в ядре**: клиент сам выбирает механику; ядро даёт методы refresh (см. «Асинхронность»).
- **Тесты**: VCR-кассеты в репозитории каждого плагина; ядро поставляет контрактный RSpec-сьют (`it_behaves_like "a yamshik carrier"`), который запускает каждый плагин. В ядре есть референс-адаптер `Yamshik::Adapters::Fake` (пример, основа сьюта, мок для пользователей).
- **Лицензия MIT**, README на английском, статья на Хабр на русском.

## 2. Результаты и ошибки

- Бизнес-результаты — **Result-объекты** (`result.success?`, `result.value`, `result.error`).
- Исключения — только инфраструктурные:
  - `Yamshik::Error` — базовый
  - `Yamshik::TimeoutError`
  - `Yamshik::ConnectionError`
  - `Yamshik::RateLimitedError` — с полем `retry_after`
  - `Yamshik::AuthenticationError`
  - `Yamshik::InvalidResponseError` — служба вернула непарсящийся мусор
- `Result.err` содержит `Yamshik::CarrierError` как **данные** (не exception):
  - поля: `code` (из таксономии ниже), `carrier`, `message`, `details`, `raw`, `carrier_code`
- 429 после исчерпания ретраев → исключение `RateLimitedError` (инфра), с метаинформацией.

### Таксономия кодов CarrierError (черновик)

```
:validation_failed      # служба отвергла параметры (details: что именно)
:duplicate              # заказ с таким reference уже существует
:not_found              # нет такого заказа/сущности
:route_not_supported    # не возим из А в Б / нет такого ПВЗ
:rejected               # бизнес-отказ без расшифровки
:other                  # неизвестный код службы (сырой код — в carrier_code)
```

## 3. Идемпотентность

- `Parcel#reference` — **обязательный** атрибут, генерируется клиентом гема (напр. id заказа в его системе). Якорь идемпотентности.
- Ретрай-слой ядра различает «запрос точно не дошёл» (connection refused — ретраим смело) и «не знаем» (таймаут после отправки — ретраим по стратегии адаптера).
- Адаптер декларирует `creation_strategy`:
  - `:idempotent` — служба сама разруливает повтор по `reference` (СДЭК `number`) или поддерживает `Idempotency-Key`. Ретраим POST смело.
  - `:check_on_ambiguous` — после неоднозначного сбоя адаптер ищет по `reference` (GET), нашёлся → вернуть, нет → повторить POST. Проверка только в аварийной ветке, не перед каждым созданием.
  - `:unsafe` — ретрай POST отключён, ограничение документируется в README плагина.

## 4. Асинхронность

- Контракт синхронный по форме; асинхронность выражена **состоянием сущности**:
  - `create_order` возвращает `Parcel` сразу, с `registration_state: :pending | :registered | :rejected` и `external_id`, если служба его выдала.
  - Клиент узнаёт итог сам: поллинг через `carrier.parcel(external_id)` или по своему вебхуку вызывает refresh.
- Тот же паттерн для мерчанта, вызова курьера, генерации этикеток: сущность + lifecycle-стейт + refresh-метод. Блокирующих ожиданий в ядре нет.
- `Merchant` — НЕ в ядре (у Яндекс.Доставки регистрация через API, асинхронная — это сущность с жизненным циклом, но пока нужна одной службе). Живёт в плагине как расширение, использует общие примитивы ядра. Поднимается в ядро, когда понадобится второму адаптеру.

## 5. Правило расширения ядра

Сущности/методы попадают в ядро, когда нужны **минимум двум** адаптерам. До этого:
- аккаунтная статика → конфиг адаптера;
- специфика службы → методы плагина сверх контракта (публичный API плагина, свои тесты);
- аварийный выход → `carrier_options:` (типизированный хеш в вызовах, валидируется адаптером, документируется в README плагина).

Правила для `carrier_options`:
- **Многоуровневость**: может жить не только на вызове/Parcel, но и на вложенных сущностях (напр. `Place#carrier_options` для per-package параметров). Добавляем не превентивно на все сущности, а только там, где реальный API текущего плагина этого требует (для v0.1 — по факту нужд СДЭК).
- **Валидация с путём**: адаптер отвергает неизвестный ключ/кривое значение через `Result.err(:validation_failed)`, в `details.path` указывает место (напр. `places[2].carrier_options.barcode_format`).
- **Повышение независимо по уровням**: ключ, понадобившийся второму адаптеру, поднимается в атрибут той сущности, на которой живёт.

---

## 6. Доменная модель — атрибуты (черновик)

Единицы жёстко: **вес в граммах, габариты в см, деньги — Integer в копейках**. Конвертация — забота адаптеров.

### Value-объекты

```ruby
Money    # amount: Integer (копейки), currency: String ("RUB")
         # сравнение, сложение; без зависимости от гема money
```

Вес и габариты — не объекты, а поля с суффиксом единицы (`weight_g`, `length_cm`).

### Сущности

```ruby
Parcel
  reference          # String, ОБЯЗАТЕЛЬНЫЙ — якорь идемпотентности
  external_id        # String, nil до создания — id у службы
  carrier            # Symbol, проставляет адаптер
  registration_state # :pending / :registered / :rejected
  sender             # Contact
  recipient          # Contact
  origin             # Point
  destination        # Point
  delivery_type      # Symbol, вычисляемый: destination.type
                     #   (режим первой мили — origin.type)
  items              # [Item] — декларация содержимого
  places             # [Place]
  services           # [ParcelService]
  comment            # String, опционально

Contact
  name               # String — ФИО физлица или название юрлица
  company            # Company, опционально — реквизиты юрлица
  phone              # String
  email              # String, опционально

Company              # реквизиты юрлица
  inn                # String — ИНН

Point
  country_code       # String, дефолт "RU"
  region             # String, опционально
  city               # String
  address            # String — улица, дом, кв одной строкой
  index              # String (почтовый), опционально
  pickup_point_code  # String, опционально — код ПВЗ
  type               # Symbol, вычисляемый: :door | :pickup_point
                     #   (задан pickup_point_code → :pickup_point)
# Валидность комбинации (адрес И/ИЛИ код ПВЗ) проверяет адаптер.
# Подтипы точек у служб (delivery_point / postamat / terminal) —
# частные случаи :pickup_point, в ядре не различаем.

Item
  name               # String
  sku                # String (артикул), опционально
  quantity           # Integer
  price              # Money — за единицу
  weight_g           # Integer, опционально (граммы)
  vat_rate           # Integer, опционально

Place                # грузоместо
  weight_g           # Integer (граммы)
  length_cm          # Integer, опционально
  width_cm           # Integer, опционально
  height_cm          # Integer, опционально
  place_items        # [PlaceItem] — раскладка товаров
  labels             # [PlaceLabel]

PlaceItem            # связь: какой товар и сколько лежит в месте
  item               # Item
  quantity           # Integer
# Ядро валидирует: сумма quantity по местам ≤ item.quantity.

PlaceLabel
  format             # :pdf / :png / :zpl
  content            # String (бинарные данные) ИЛИ
  url                # String — некоторые службы отдают ссылку

ParcelService        # допуслуга — двухслойная схема, как у статусов
  kind               # канонический: :insurance / :cod / :try_on /
                     #   :sms_notification / :carrier_specific
  carrier_code       # String — код услуги у службы
  amount             # Money, опционально (нет у :try_on, :sms_notification)
# Прочие параметры услуг (не деньги) — через carrier_options.

TrackingEvent
  status             # канонический Symbol (см. таксономию ниже)
  problem_kind       # Symbol, только при status == :problem (см. ниже)
  carrier_code       # String — исходный код события у службы
  occurred_at        # Time
  raw                # Hash, опционально — сырой payload
```

## Скоуп v0.1

Только **создание отправления** (+ refresh состояния регистрации). Отложено в v0.2:
`Rate` (расчёт тарифа), `PickupPoint` (список ПВЗ), `PickupRequest` (вызов курьера) —
атрибуты этих сущностей проектируем, когда дойдём до соответствующих операций.

## 7. Статусы и problem_kind

### Канонические статусы (status у TrackingEvent)

```
unknown           # нераспознанный статус службы (+ хук on_unknown_status)
created           # создано
in_transit        # в пути (включая сортировки, склады)
ready_for_pickup  # прибыло в ПВЗ, ждёт получателя
delivered         # вручено (ТЕРМИНАЛЬНЫЙ)
to_return         # уехало обратно отправителю
lost              # утеряно (ТЕРМИНАЛЬНЫЙ)
problem           # нештатная ситуация, см. problem_kind
```

- Маппинг «код службы → канонический» — таблицей данных в адаптере.
- Ядро валидирует: целевые статусы только из списка.
- Неизвестный код → `unknown` + вызов хука `config.on_unknown_status`.

### Конечный автомат переходов

```
         прямой поток                          возвратный поток
created ──→ in_transit ──→ ready_for_pickup ──→ delivered ⏹ (получателю)
              │  │              │
              │  └──(до двери)→ delivered ⏹
              ↓                 ↓ (истёк срок хранения и т.п.)
            to_return ──→ in_transit ──→ ready_for_pickup ──→ delivered ⏹ (отправителю)
              │             │
              ↓             ↓
            lost ⏹ ←── возможен на любом участке (туда и обратно)
 problem ⇄ из любого не-терминального состояния, возврат в поток
```

Допустимые переходы:

| Откуда | Куда |
|---|---|
| `created` | `in_transit`, `problem`, `lost` |
| `in_transit` | `ready_for_pickup`, `delivered`, `problem`, `to_return`, `lost` |
| `ready_for_pickup` | `delivered`, `problem`, `to_return`, `lost` |
| `to_return` | `in_transit` (возвратный поток), `problem`, `lost` |
| `problem` | `in_transit`, `ready_for_pickup`, `delivered`, `to_return`, `lost` |
| `delivered`, `lost` | — (терминальные) |
| `unknown` | вне автомата (fallback нераспознанного кода, переходы не проверяются) |

Нюансы:
- Статусы не различают направление: всё, что после `to_return`, — возвратный поток (`in_transit` = едет к отправителю, `delivered` = вручено отправителю). Отдельный статус `returned` сознательно не вводим; клиент восстанавливает направление по предыстории событий.
- `problem` — «петля», а не тупик: возможна из любого не-терминального состояния, из него — возврат в поток любым исходом.
- Автомат **справочный, не принудительный**: службы присылают события не по порядку и с ошибками, ядро не отвергает «невалидные» переходы. Автомат доступен как хелперы `Yamshik::Status.terminal?(s)` / `Yamshik::Status.allowed_transition?(from, to)` для клиентов, желающих флаговать аномалии. Дедупликация и «события из прошлого» — на стороне клиента (вебхуки/поллинг вне ядра).

### problem_kind (только при status == :problem)

```
:delay                  # задержка
:damage                 # повреждение
:customs                # таможня
:recipient_unreachable  # получатель не выходит на связь
:address_issue          # проблема с адресом
:weight_mismatch        # расхождение веса/габаритов
:payment_issue          # проблема с оплатой (наложка и т.п.)
:other                  # + carrier_code/raw для деталей
```

