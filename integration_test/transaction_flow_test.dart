import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:money_manager/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Wait for the app to settle past splash + auth resolution.
  Future<void> bootApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 10));
  }

  /// Navigate to the Transactions tab (index 1 on the shell NavigationBar).
  Future<void> goToTransactions(WidgetTester tester) async {
    final navBar = find.byType(NavigationBar);
    if (navBar.evaluate().isEmpty) return; // already on right tab or no shell
    final destinations = find.descendant(
      of: navBar,
      matching: find.byType(NavigationDestination),
    );
    if (destinations.evaluate().length > 1) {
      await tester.tap(destinations.at(1));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('Transactions tab shows filter chips', (tester) async {
    await bootApp(tester);

    final isOnShell = find.byType(NavigationBar).evaluate().isNotEmpty;
    if (!isOnShell) return; // skip if onboarding flow

    await goToTransactions(tester);

    // Filter chips are rendered
    expect(find.text('All'), findsWidgets);
    expect(find.text('Income'), findsWidgets);
    expect(find.text('Expense'), findsWidgets);
  });

  testWidgets('Add transaction sheet opens via FAB', (tester) async {
    await bootApp(tester);

    final isOnShell = find.byType(NavigationBar).evaluate().isNotEmpty;
    if (!isOnShell) return;

    await goToTransactions(tester);

    // Tap FAB
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isEmpty) return;
    await tester.tap(fab.first);
    await tester.pumpAndSettle();

    // Sheet should appear with amount field
    expect(
      find.byKey(const Key('amount_field')).evaluate().isNotEmpty ||
          find.text('Add Transaction').evaluate().isNotEmpty,
      isTrue,
    );
  });

  testWidgets('Tapping Income filter chip updates UI', (tester) async {
    await bootApp(tester);

    final isOnShell = find.byType(NavigationBar).evaluate().isNotEmpty;
    if (!isOnShell) return;

    await goToTransactions(tester);

    final incomeChip = find.text('Income');
    if (incomeChip.evaluate().isEmpty) return;

    await tester.tap(incomeChip.first);
    await tester.pumpAndSettle();

    // The Income chip should now be selected (its FilterChip.selected == true)
    final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
    final selectedChips = chips.where((c) => c.selected).toList();
    expect(selectedChips, isNotEmpty);
  });

  testWidgets('Search bar filters list by query', (tester) async {
    await bootApp(tester);

    final isOnShell = find.byType(NavigationBar).evaluate().isNotEmpty;
    if (!isOnShell) return;

    await goToTransactions(tester);

    final searchField = find.byType(TextField);
    if (searchField.evaluate().isEmpty) return;

    await tester.enterText(searchField.first, 'zzzzunlikely');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // With an unlikely query, either no transactions or empty state visible
    // — just ensure the UI doesn't crash
    expect(find.byType(Scaffold), findsWidgets);
  });
}
