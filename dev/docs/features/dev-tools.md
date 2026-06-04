# Feature — Dev Tools

## Purpose

Debug-only utilities for development. Currently exposes a **theme showcase** screen to preview design tokens and components. Not available in release builds.

## Entry points

| Route | Screen | Availability |
|-------|--------|--------------|
| `/dev/theme` | `ThemeShowcaseScreen` | `kDebugMode` only |

Route registered conditionally in [`app_router.dart`](../../../lib/core/router/app_router.dart):

```dart
if (kDebugMode)
  GoRoute(path: AppRoutes.themeShowcase, ...),
```

## Folder map

```text
lib/features/dev/
└── theme_showcase_screen.dart
```

## Key types

| Symbol | Description |
|--------|-------------|
| `ThemeShowcaseScreen` | Displays colors, typography, sample widgets |

## Dependencies

| Module | Relationship |
|--------|--------------|
| [core/theme](../core/theme.md) | Theme under test |
| [core/constants](../core/constants.md) | Token display |
| [core/widgets](../core/widgets.md) | Sample components |

## How to extend

### Add a debug screen

1. Create screen under `lib/features/dev/`.
2. Register route inside `if (kDebugMode)` block in `app_router.dart`.
3. Add dev-only navigation link (e.g. hidden gesture on settings in debug).
4. Document here — do not expose in production UI.

## Tests

No dedicated tests. Manual verification in debug profile.

## Related docs

- [../core/theme.md](../core/theme.md)
- [settings.md](settings.md)
