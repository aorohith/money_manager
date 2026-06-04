# Core — Constants

## Purpose

Centralizes design tokens and app-wide configuration values so screens, themes, and platform code share a single source of truth.

## Entry points

| File | Role |
|------|------|
| [`lib/core/constants/constants.dart`](../../../lib/core/constants/constants.dart) | Barrel export |
| [`lib/core/constants/app_config.dart`](../../../lib/core/constants/app_config.dart) | App ID, SMS MethodChannel name |

## Folder map

```text
lib/core/constants/
├── constants.dart          # Barrel
├── app_config.dart         # Application ID, channel names
├── app_colors.dart         # Color palette
├── app_spacing.dart        # Padding, gaps
├── app_typography.dart     # Text styles
├── app_icons.dart          # Icon name mappings
└── app_durations.dart      # Animation durations
```

## Key types

| Class | Contents |
|-------|----------|
| `AppConfig` | `applicationId`, `smsMethodChannel` — must match Android Kotlin channel |
| `AppColors` | Light/dark semantic colors, outlines |
| `AppSpacing` | `screenPadding`, `md`, `lg`, etc. |
| `AppTypography` | Font sizes and weights (works with Google Fonts in theme) |
| `AppDurations` | Shared animation timing |

Feature-specific constants (e.g. PIN length) live in feature `domain/` — see [`AuthConfig`](../../../lib/features/auth/domain/auth_config.dart).

## Dependencies

- Used by **theme**, **widgets**, **router shell**, and all presentation layers
- `AppConfig.smsMethodChannel` must stay in sync with Android `SmsListenerService`

## How to extend

### Add an app-wide constant

```dart
// lib/core/constants/app_config.dart
abstract final class AppConfig {
  static const int maxExportRows = 10_000;
}
```

Use `abstract final class` for static-only holders (Dart 3 idiom).

### Add a design token

Add to the appropriate file (`app_colors.dart`, `app_spacing.dart`, …) and export via `constants.dart`. Do not duplicate literals in feature screens.

**Rule:** If a value appears in two+ files or in user-facing copy, hoist it to a constant (see `.cursor/rules/single-source-of-truth-constants.mdc`).

## Tests

Constants are validated indirectly via widget tests that assert layout uses `AppSpacing`.

```bash
dart analyze lib/core/constants/
```

## Related docs

- [theme.md](theme.md) — Consumes color/typography tokens
- [widgets.md](widgets.md) — Uses spacing and colors
- [../platform/android-sms-listener.md](../platform/android-sms-listener.md) — Channel name contract
