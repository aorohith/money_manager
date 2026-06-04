# Testing Standards

## Mandatory For Every Feature/UI Change

- Add test cases for all new logic/UI behavior.
- Run and verify new tests locally.
- Run dependent-feature regression tests when shared layers are touched:
  - routing (`lib/core/router`)
  - providers (`lib/features/**/domain/providers`)
  - repositories (`lib/features/**/data/repositories`)
  - shared widgets/services

## Test Layers

- `test/unit`: business logic, repositories, providers, pure helpers
- `test/widgets`: UI behavior, interactions, render states
- `integration_test`: critical user journeys and cross-feature behavior

## Local Commands

- Full suite:
  - `flutter analyze`
  - `flutter test`
- Layered runs:
  - `flutter test test/unit`
  - `flutter test test/widgets test/widget_test.dart`
  - `flutter test integration_test`

## Pre-merge Gate

- Analyze passes
- Unit + widget tests pass
- Integration suite passes
- No silent skips for critical paths
