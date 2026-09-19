# Changelog

## [Unreleased]

- Initial gem skeleton: bundler layout, RSpec, RuboCop, GitHub Actions CI.
- Domain models v0.1 (DESIGN.md §6): `Money`, `Contact`, `Company`, `Point`, `Item`, `Place`, `PlaceItem`, `PlaceLabel`, `ParcelService`, `Parcel`, `TrackingEvent` — immutable value objects/entities built on `Data.define` with constructor validation.
- `Yamshik::Status` (DESIGN.md §7): canonical tracking statuses, problem kinds and the reference transition machine (`valid?`, `terminal?`, `valid_problem_kind?`, `allowed_transition?`).
