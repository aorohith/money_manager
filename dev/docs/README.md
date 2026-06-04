# Money Manager — Developer Documentation

> Located at `dev/docs/`. See [../README.md](../README.md) for tools and repo layout.

Personal finance Flutter app with local-first storage (Isar), PIN/biometric auth, SMS transaction parsing (Android), budgets, goals, analytics, and import.

## Quick start

```bash
git clone <repo-url>
cd money_manager
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs   # if *.g.dart missing
flutter run
```

Run tests: see [testing/running-tests.md](testing/running-tests.md).

## How to read these docs

Every module doc follows the same template:

1. Purpose
2. Entry points
3. Folder map
4. Key types
5. Data flow
6. Dependencies
7. How to extend
8. Tests
9. Related docs

Start with **Architecture** if you are new to the codebase.

## Architecture

| Doc | Description |
|-----|-------------|
| [architecture/overview.md](architecture/overview.md) | Clean Architecture, Riverpod, Isar, feature-first layout |
| [architecture/data-model.md](architecture/data-model.md) | All 8 Isar collections and relationships |
| [architecture/navigation-and-auth.md](architecture/navigation-and-auth.md) | GoRouter, auth redirect matrix, bottom nav shell |
| [architecture/bootstrap-and-lifecycle.md](architecture/bootstrap-and-lifecycle.md) | `main.dart`, `app.dart`, background jobs, auto-lock |

## Core modules

| Module | Description |
|--------|-------------|
| [core/database.md](core/database.md) | Isar singleton, `isarProvider` |
| [core/constants.md](core/constants.md) | Colors, spacing, typography, app config |
| [core/security.md](core/security.md) | PIN hashing |
| [core/theme.md](core/theme.md) | Light/dark themes, extensions |
| [core/widgets.md](core/widgets.md) | Shared UI components |
| [core/utils.md](core/utils.md) | Formatters, icon resolver |
| [core/notifications.md](core/notifications.md) | Local notifications |
| [core/sms/overview.md](core/sms/overview.md) | SMS parser pipeline |
| [core/sms/extraction-modules.md](core/sms/extraction-modules.md) | Amount, date, merchant extractors |
| [core/sms/ingestion-and-policy.md](core/sms/ingestion-and-policy.md) | Ingestion service, auto-add policy |
| [core/sms/gap-analysis.md](core/sms/gap-analysis.md) | Parser coverage gaps and corpus maintenance |

## Features

| Feature | User-facing summary |
|---------|---------------------|
| [features/auth.md](features/auth.md) | PIN setup, lock screen, biometrics, lockout |
| [features/onboarding.md](features/onboarding.md) | First-run splash, currency, profile |
| [features/transactions.md](features/transactions.md) | Transactions, accounts, categories, recurrence, reconciliation |
| [features/dashboard.md](features/dashboard.md) | Home screen, balance, customizable layout |
| [features/sms.md](features/sms.md) | SMS inbox, rules, merchant mapping, settings |
| [features/budgets.md](features/budgets.md) | Category budgets and progress |
| [features/goals.md](features/goals.md) | Savings goals |
| [features/analytics.md](features/analytics.md) | Spending analytics and category drill-down |
| [features/insights.md](features/insights.md) | Trends and insights |
| [features/import.md](features/import.md) | CSV/Excel/PDF import |
| [features/settings.md](features/settings.md) | Profile, export, biometrics, home layout |
| [features/dev-tools.md](features/dev-tools.md) | Debug theme showcase |

> **Note:** Categories live under the **transactions** feature (`lib/features/transactions/`). The empty `lib/features/categories/` folder is a placeholder — do not document it separately.

## Platform

| Doc | Description |
|-----|-------------|
| [platform/android-sms-listener.md](platform/android-sms-listener.md) | Kotlin SMS listener, MethodChannel, permissions |
| [platform/android-build-notes.md](platform/android-build-notes.md) | compileSdk compatibility for plugins |

## Testing

| Doc | Description |
|-----|-------------|
| [testing/overview.md](testing/overview.md) | Test folder layout |
| [testing/running-tests.md](testing/running-tests.md) | Commands by module |
| [testing/sms-corpus.md](testing/sms-corpus.md) | SMS regression corpus |

## Keeping docs updated

When you add or change a feature:

1. Update the module doc's **Key types**, **Entry points**, and **Tests** sections.
2. If you add an Isar collection, update [architecture/data-model.md](architecture/data-model.md) and `main.dart` schema list.
3. If you add a route, update [architecture/navigation-and-auth.md](architecture/navigation-and-auth.md) and the feature's route table.
4. Follow the project rule: fix + regression test + rulebook delta (see `.cursor/rules/learn-from-mistakes.mdc`).
