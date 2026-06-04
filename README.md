# Money Manager

A local-first personal finance app built with Flutter. Track transactions, budgets, and goals; analyze spending; import bank exports; and auto-parse transaction SMS on Android.

## Getting started

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs   # if needed
flutter run
```

## Documentation & tools

Developer docs, scripts, and testing standards: **[dev/README.md](dev/README.md)**

Full module reference: **[dev/docs/README.md](dev/docs/README.md)**

## Tech stack

- Flutter 3+ / Dart 3
- Riverpod — state management
- Isar — local database
- GoRouter — navigation
- local_auth + flutter_secure_storage — PIN and biometrics
