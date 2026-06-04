# Core — Theme

## Purpose

Defines light/dark **Material 3** themes using FlexColorScheme and custom extensions. Theme mode (system/light/dark) is persisted via settings providers.

## Entry points

| File | Role |
|------|------|
| [`lib/core/theme/app_theme.dart`](../../../lib/core/theme/app_theme.dart) | `AppTheme.light`, `AppTheme.dark` |
| [`lib/core/theme/app_theme_extension.dart`](../../../lib/core/theme/app_theme_extension.dart) | Custom theme extension |
| [`lib/app.dart`](../../../lib/app.dart) | `theme`, `darkTheme`, `themeMode` |

## Folder map

```text
lib/core/theme/
├── theme.dart              # Barrel
├── app_theme.dart          # ThemeData builders
└── app_theme_extension.dart
```

## Key types

| Symbol | Description |
|--------|-------------|
| `AppTheme.light` / `.dark` | Full `ThemeData` |
| `AppThemeExtension` | Extra semantic colors (access via `Theme.of(context).extension`) |
| `themeModeProvider` | In settings — `ThemeMode.system/light/dark` |

Uses **google_fonts** and **flex_color_scheme** (see `pubspec.yaml`).

## Dependencies

- [constants.md](constants.md) — Color and typography tokens
- [../features/settings.md](../features/settings.md) — Theme mode toggle

## How to extend

### Add a semantic color to the extension

1. Add field to `AppThemeExtension` in `app_theme_extension.dart`.
2. Set values in `AppTheme.light` and `AppTheme.dark`.
3. Read in widgets: `Theme.of(context).extension<AppThemeExtension>()!.myColor`.

### Add a new theme mode option

Extend `themeModeProvider` persistence in settings — keep `App` reading `ref.watch(themeModeProvider)`.

## Tests

Theme is covered by widget tests and debug [dev-tools](../features/dev-tools.md) showcase.

```bash
flutter test test/widgets/
```

## Related docs

- [constants.md](constants.md)
- [widgets.md](widgets.md)
- [../features/settings.md](../features/settings.md)
