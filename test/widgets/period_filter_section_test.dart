import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/auth/providers/auth_provider.dart';
import 'package:money_manager/features/dashboard/domain/providers/dashboard_providers.dart';
import 'package:money_manager/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:money_manager/features/transactions/domain/providers/transaction_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const sampleDashboard = DashboardData(
    totalIncome: 0,
    totalExpense: 0,
    recentTransactions: [],
    categoryExpenseSummary: {},
    categories: [],
    todayExpense: 0,
    weekExpense: 0,
  );

  Future<void> pumpDashboard(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpApp(
      const DashboardScreen(),
      overrides: [
        dashboardProvider.overrideWith((_) => Stream.value(sampleDashboard)),
        currencySymbolProvider.overrideWith((_) async => '\$'),
        accountsProvider.overrideWith((_) => Stream.value([])),
      ],
    );
    await tester.pump();
  }

  testWidgets('renders Day/Week/Month/Year and defaults to Day',
      (tester) async {
    await pumpDashboard(tester);

    expect(find.byKey(const Key('home_period_filter')), findsOneWidget);
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    // Default period subtitle ("Today") shows on the chip header.
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('tapping Week updates dashboardPeriodProvider', (tester) async {
    await pumpDashboard(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(DashboardScreen)),
    );
    expect(container.read(dashboardPeriodProvider), HomePeriod.day);

    await tester.tap(find.byKey(const Key('home_period_week')));
    await tester.pump();

    expect(container.read(dashboardPeriodProvider), HomePeriod.week);
  });
}
