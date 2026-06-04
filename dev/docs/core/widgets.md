# Core — Widgets

## Purpose

Shared UI primitives used across features — buttons, cards, sheets, snackbars, loading states, and layout-safe bottom sheets. Keeps presentation consistent and enforces overflow-safe patterns.

## Entry points

| File | Role |
|------|------|
| [`lib/core/widgets/widgets.dart`](../../../lib/core/widgets/widgets.dart) | Barrel export |

## Folder map

```text
lib/core/widgets/
├── widgets.dart
├── app_button.dart
├── app_card.dart
├── app_text_field.dart
├── app_bottom_sheet.dart      # Modal sheet helper
├── app_snackbar.dart
├── loading_overlay.dart
├── empty_state.dart
├── shimmer_loader.dart
├── animated_list_item.dart
└── exit_confirmation_dialog.dart
```

## Key widgets

| Widget | Use |
|--------|-----|
| `AppButton` | Primary/secondary actions |
| `AppCard` | Elevated content container |
| `AppTextField` | Styled text input |
| `AppBottomSheet` | Standard sheet wrapper |
| `LoadingOverlay` | Full-screen or inline loading |
| `EmptyState` | Zero-data placeholder |
| `ExitConfirmationDialog` | Home back → exit app |
| `ShimmerLoader` | Skeleton loading |

## Data flow

Stateless presentation components — they receive data/callbacks from feature screens. No Riverpod inside core widgets (except where noted in feature-specific wrappers).

## Dependencies

- [constants.md](constants.md), [theme.md](theme.md)
- [../architecture/navigation-and-auth.md](../architecture/navigation-and-auth.md) — `ExitConfirmationDialog` on home back

## How to extend

### Add a data-driven bottom sheet with a list

Follow the overflow-safe recipe in `.cursor/rules/flutter-overflow-safety.mdc`:

1. `showModalBottomSheet(isScrollControlled: true, useSafeArea: true, showDragHandle: true)`
2. Cap with `BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85)`
3. **`LayoutBuilder`** inside builder — size body to `constraints.maxHeight`
4. Column: fixed header → `Expanded(ListView)` → fixed footer
5. Stable `Key` on the list for widget tests

### Add a new shared widget

1. Create `lib/core/widgets/my_widget.dart`.
2. Export from `widgets.dart`.
3. Add widget test if the widget has scroll/overflow risk or non-trivial interaction.

## Tests

```bash
flutter test test/widgets/exit_confirmation_dialog_test.dart
flutter test test/widgets/
```

Mandatory regression: multi-viewport sheet tests per `.cursor/rules/variable-content-layout-safety.mdc`.

## Related docs

- [constants.md](constants.md)
- [theme.md](theme.md)
