import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/auth/providers/auth_provider.dart';
import 'package:money_manager/features/dashboard/domain/providers/dashboard_providers.dart';
import 'package:money_manager/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/domain/providers/transaction_providers.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_factories.dart';

void main() {
  const sampleDashboard = DashboardData(
    totalIncome: 100,
    totalExpense: 40,
    recentTransactions: [],
    categoryExpenseSummary: {},
    categories: [],
    todayExpense: 0,
    weekExpense: 0,
  );

  group('DashboardBalanceSection', () {
    testWidgets('chip shows total; detailed card hidden until chip tapped',
        (tester) async {
      await tester.pumpApp(
        const DashboardBalanceSection(),
        overrides: [
          dashboardProvider.overrideWith((ref) => Stream.value(sampleDashboard)),
          currencySymbolProvider.overrideWith((_) async => '\$'),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Total balance'), findsOneWidget);
      expect(find.text('\$60.00'), findsOneWidget);
      expect(find.text('Net Balance'), findsNothing);

      await tester.tap(find.byKey(const Key('dashboard_balance_chip')));
      await tester.pumpAndSettle();

      expect(find.text('Net Balance'), findsOneWidget);
    });

    testWidgets('tapping expanded balance headline opens account breakdown sheet',
        (tester) async {
      await tester.pumpApp(
        const DashboardBalanceSection(),
        overrides: [
          dashboardProvider.overrideWith((ref) => Stream.value(sampleDashboard)),
          currencySymbolProvider.overrideWith((_) async => '\$'),
          accountsProvider.overrideWith((ref) => Stream.value([])),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dashboard_balance_chip')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Net Balance'));
      await tester.pumpAndSettle();

      expect(find.text('Balances by account'), findsOneWidget);
      expect(find.text('Manage accounts'), findsOneWidget);
    });

    // Regression guard: with many accounts the modal must scroll instead
    // of overflowing. We rely on `tester.takeException()` to surface any
    // RenderFlex / hit-test errors that would silently degrade in prod.
    //
    // We exercise THREE viewport sizes — small phone, standard phone, and
    // a constrained landscape-ish height — because the original bug only
    // manifested when the modal sheet's drag handle + bottom safe-area
    // ate enough vertical space to push the column past its constraint.
    for (final size in const [
      Size(360, 640), // small phone (e.g. older Android)
      Size(390, 720), // standard iOS-class phone
      Size(412, 540), // short height, exposes drag-handle/safe-area math
    ]) {
      testWidgets(
        'account breakdown sheet scrolls without overflow @ ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          final accounts = List<AccountModel>.generate(
            25,
            (i) => makeAccount(id: i + 1, name: 'Account ${i + 1}'),
          );

          await tester.pumpApp(
            const DashboardBalanceSection(),
            overrides: [
              dashboardProvider
                  .overrideWith((ref) => Stream.value(sampleDashboard)),
              currencySymbolProvider.overrideWith((_) async => '\$'),
              accountsProvider.overrideWith((ref) => Stream.value(accounts)),
            ],
          );
          await tester.pumpAndSettle();

          // Sanity: chip + collapsed dashboard renders cleanly.
          expect(tester.takeException(), isNull,
              reason: 'collapsed dashboard must lay out without overflow');

          await tester.tap(find.byKey(const Key('dashboard_balance_chip')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason:
                  'expanded balance card must lay out without overflow');

          await tester.tap(find.text('Net Balance'));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull,
              reason:
                  'sheet must lay out without RenderFlex overflow');

          // First account visible, action button anchored at bottom.
          expect(find.text('Account 1'), findsOneWidget);
          expect(find.text('Manage accounts'), findsOneWidget);

          // Scrolling reveals rows that didn't fit on screen.
          await tester.drag(
            find.byKey(const Key('dashboard_account_balances_list')),
            const Offset(0, -2000),
          );
          await tester.pumpAndSettle();
          expect(find.text('Account 25'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
