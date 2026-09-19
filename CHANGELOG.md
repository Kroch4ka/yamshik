# Changelog

## [Unreleased]

- Initial gem skeleton: bundler layout, RSpec, RuboCop, GitHub Actions CI.
- Domain models v0.1 (DESIGN.md §6): `Money`, `Contact`, `Company`, `Point`, `Item`, `Place`, `PlaceItem`, `PlaceLabel`, `ParcelService`, `Parcel`, `TrackingEvent` — immutable value objects/entities built on `Data.define` with constructor validation.
- `Yamshik::Status` (DESIGN.md §7): canonical tracking statuses, problem kinds and the reference transition machine (`valid?`, `terminal?`, `valid_problem_kind?`, `allowed_transition?`).
- Result/error model (DESIGN.md §2): `Yamshik::Result` (`ok`/`err`, `success?`, `value`, `error`), `Yamshik::CarrierError` as business-failure data with canonical codes, infrastructural exception hierarchy (`TimeoutError`, `ConnectionError`, `AuthenticationError`, `InvalidResponseError`, `RateLimitedError` with `retry_after`).
- Configuration and registry (DESIGN.md §1): `Yamshik.configure` / `Configuration#register` for per-carrier configs, `default_timeout`, `logger`, `on_unknown_status` hook; `Yamshik.register_adapter` for plugins, `Yamshik.carrier(name)` to build configured adapters.
- HTTP layer (DESIGN.md §1, §3): `Yamshik::HTTP::Client` on Faraday — exponential-backoff retries distinguishing "definitely not sent" from ambiguous failures (non-idempotent requests retried only when not sent), `Yamshik::HTTP::CircuitBreaker` (closed/open/half-open), status/error mapping into the exception hierarchy; new exceptions `CarrierUnavailableError` and `CircuitOpenError`.
- Plugin customization points for quirky carriers: injectable `classifier:` on the HTTP client (default `Yamshik::HTTP::StatusClassifier`) and `count_failure:` predicate on the circuit breaker (only yamshik infrastructural errors counted by default).
- Carrier contract (DESIGN.md §1, §3): `Yamshik::Carrier` abstract class (`create_order`, `parcel`, `creation_strategy` declaration), `Yamshik::StatusMapper` with canonical-status validation and the `on_unknown_status` hook, reference adapter `Yamshik::Adapters::Fake` (in-memory, idempotent, strict about `carrier_options`), and the contract RSpec suite `Yamshik::Spec::Contract` (`it_behaves_like "a yamshik carrier"`) that plugins run in their own CI.
