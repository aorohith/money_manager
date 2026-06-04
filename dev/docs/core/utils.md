# Core — Utils

## Purpose

Pure Dart helpers for formatting and icon resolution — no Flutter UI, no side effects.

## Entry points

| File | Role |
|------|------|
| [`lib/core/utils/formatters.dart`](../../../lib/core/utils/formatters.dart) | Currency, date, amount formatting |
| [`lib/core/utils/material_icon_resolver.dart`](../../../lib/core/utils/material_icon_resolver.dart) | String → `IconData` for category icons |

## Folder map

```text
lib/core/utils/
├── formatters.dart
└── material_icon_resolver.dart
```

## Key types

| API | Description |
|-----|-------------|
| Currency formatters | Locale-aware display using app currency symbol |
| Date formatters | Transaction dates, period labels |
| `MaterialIconResolver` | Maps stored icon name strings to Material icons |

## Dependencies

- **intl** package
- Used by transactions, dashboard, analytics, settings export

## How to extend

### Add a formatter

Add a top-level or static function in `formatters.dart`. Use in one place first; promote here when a second caller appears.

```dart
String formatCompactAmount(double amount, String symbol) {
  // ...
}
```

### Add an icon alias

Extend `MaterialIconResolver` map when users can pick new category icons in manage categories.

## Tests

```bash
flutter test test/unit/core/formatters_test.dart
flutter test test/unit/core/material_icon_resolver_test.dart
```

## Related docs

- [../features/transactions.md](../features/transactions.md) — Category icons
- [../features/settings.md](../features/settings.md) — PDF export formatting
