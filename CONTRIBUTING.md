# CONTRIBUTING — как мы разрабатываем Yamshik

Хостинг: GitHub. Репозитории: `yamshik` (ядро) и по одному на плагин (`yamshik-cdek`, ...).

## Пайплайн задачи

1. **Ветка от `main`** → сразу **Draft PR** (даже пустой). CI запускается с первого коммита, прогресс виден сразу.
2. **Работа + тесты** в той же ветке. Тесты — обязательная часть PR, а не отдельный шаг: PR без тестов не выходит из draft. Для плагинов — VCR-кассеты + контрактный сьют ядра, для ядра — юнит-тесты + Fake-адаптер.
3. **Снятие draft → ревью.** До ревью два обязательных условия: CI зелёный, RuboCop чистый.
4. **Merge — только squash**: в `main` попадает один осмысленный коммит на задачу. Прямые пуши в `main` запрещены (защита ветки).

## Naming convention

**Ветки** — `<type>/<краткое-описание>` в kebab-case:

```
feat/carrier-contract        feat/cdek-create-order
fix/result-nil-error         chore/setup-ci
test/fake-adapter-contract   docs/design-status-fsm
```

Типы: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`.

**PR** — Conventional Commits (при squash заголовок PR становится коммитом в `main`):

```
feat(core): add Carrier contract and Result
fix(http): retry POST only for idempotent strategy
test(cdek): record VCR cassettes for create order
```

Scope в скобках: `core`, `http`, `cdek`, `ci` и т.п. Императив, маленькая буква, без точки в конце.

## CI (блокирует merge)

GitHub Actions:

- `bundle exec rspec` — матрица Ruby 3.2 / 3.3 / 3.4 (ядро работает без Rails — проверяем на чистых рубях);
- `bundle exec rubocop` — отдельной джобой, падение = merge запрещён;
- `gem build` — sanity-проверка gemspec;
- для плагина дополнительно: контрактный сьют из ядра обязан проходить.

## Стиль

- RuboCop с `rubocop-rspec`, `TargetRubyVersion` = минимальная поддерживаемая версия. Конфиг ядра копируется в плагины (плагин собирается независимо).
- Общий Ruby style guide; Rails-идиомы — только где применимо: в ядре нет ActiveSupport (DESIGN.md §1).
- Публичный API ядра документируется YARD-комментариями — его читают авторы плагинов.

## Definition of Done для PR

- [ ] CI зелёный (rspec + rubocop + gem build)
- [ ] Новое поведение покрыто тестами
- [ ] Публичный API задокументирован (YARD)
- [ ] Если изменилось архитектурное решение — обновлён DESIGN.md (и AGENTS.md, если затронуто то, что он описывает)
- [ ] Заголовок PR по конвенции (он же будущий коммит в `main`)
