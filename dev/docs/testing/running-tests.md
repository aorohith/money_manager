# Running Tests

## Purpose

Quick reference for running tests by module and for static analysis.

## All tests

```bash
flutter test
```

## Static analysis

```bash
dart analyze lib/
dart analyze test/
```

## By module

### Architecture / core

```bash
dart analyze lib/
flutter test test/unit/core/
flutter test test/unit/security/pin_hasher_test.dart
```

### Auth & security

```bash
flutter test test/unit/auth/
flutter test test/unit/security/
flutter test test/widgets/pin_lock_screen_test.dart
flutter test test/widgets/biometric_tile_test.dart
```

### Transactions

```bash
flutter test test/unit/transactions/
flutter test test/widgets/transaction_tile_test.dart
flutter test test/widgets/transaction_filter_chips_test.dart
flutter test test/widgets/reconciliation_screen_test.dart
```

### SMS & parser

```bash
flutter test test/unit/sms/
flutter test test/widgets/sms_message_reference_test.dart
```

Corpus-only:

```bash
flutter test test/unit/sms/transaction_parser_corpus_test.dart
```

Debug corpus locally:

```bash
dart run dev/tool/corpus_debug.dart
```

### Dashboard

```bash
flutter test test/unit/dashboard/
flutter test test/widgets/dashboard_balance_section_test.dart
flutter test test/widgets/home_layout_screen_test.dart
```

### Budgets & goals

```bash
flutter test test/unit/budgets/
flutter test test/unit/goals/
```

### Import

```bash
flutter test test/unit/import/
flutter test test/widgets/import_preview_screen_test.dart
```

### Analytics & settings

```bash
flutter test test/unit/analytics/
flutter test test/unit/settings/
```

### Widget suite

```bash
flutter test test/widgets/
```

## Release build verification (Android)

```bash
flutter build apk --release
```

See [platform/android-build-notes.md](../platform/android-build-notes.md).

## CI-friendly one-liner

```bash
dart analyze lib/ && flutter test
```

## Related docs

- [overview.md](overview.md)
- [sms-corpus.md](sms-corpus.md)
