# Testing Overview

## Purpose

Maps the test layout for Money Manager — unit tests for domain logic, widget tests for UI regression, helpers for pumping the app, and SMS corpus fixtures for parser regression.

## Folder map

```text
test/
├── unit/                    # Pure logic, repositories, providers
│   ├── auth/
│   ├── analytics/
│   ├── budgets/
│   ├── core/
│   ├── dashboard/
│   ├── goals/
│   ├── import/
│   ├── security/
│   ├── settings/
│   ├── sms/
│   └── transactions/
├── widgets/                 # Screen/sheet/widget regression
├── helpers/
│   ├── pump_app.dart        # ProviderScope + MaterialApp wrapper
│   └── test_factories.dart  # Model factories
├── fixtures/
│   └── sms_corpus/          # Parser regression JSON
└── widget_test.dart         # Default smoke test
```

## Test types

| Type | Location | When to use |
|------|----------|-------------|
| Unit | `test/unit/` | Repositories, use cases, parsers, pure functions |
| Widget | `test/widgets/` | Screens, sheets, overflow/layout regression |
| Integration | `integration_test/` | Full app flows (if added) |

## Helpers

### `pump_app.dart`

Wraps widgets under test with:

- `ProviderScope` + optional overrides (e.g. `isarProvider`)
- `MaterialApp` or router config

Use for any widget that reads Riverpod providers.

### `test_factories.dart`

Builds test `TransactionModel`, categories, accounts with sensible defaults.

## Coverage by module

| Module | Unit tests | Widget tests |
|--------|------------|--------------|
| Auth | `unit/auth/` | `pin_lock_screen_test.dart`, `biometric_tile_test.dart` |
| Transactions | `unit/transactions/` | `transaction_tile_test.dart`, `reconciliation_screen_test.dart` |
| SMS | `unit/sms/` + corpus | `sms_message_reference_test.dart` |
| Import | `unit/import/` | `import_preview_screen_test.dart` |
| Dashboard | `unit/dashboard/` | `dashboard_balance_section_test.dart`, `home_layout_screen_test.dart` |
| Budgets | `unit/budgets/` | — |
| Settings | `unit/settings/` | — |

## Mandatory patterns (from project rules)

- **Feature changes:** happy path + edge case + affected dependents
- **Sheets with lists:** multi-viewport overflow tests (see `.cursor/rules/flutter-overflow-safety.mdc`)
- **SMS regex changes:** corpus fixture first, then code

## Related docs

- [running-tests.md](running-tests.md) — Commands
- [sms-corpus.md](sms-corpus.md) — Parser fixtures
- [../README.md](../README.md) — Module index
