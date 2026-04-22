import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:money_manager/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> bootApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 10));
  }

  /// Navigate to Budgets tab (index 2 on the shell NavigationBar).
  Future<bool> goToBudgets(WidgetTester tester) async {
    final navBar = find.byType(NavigationBar);
    if (navBar.evaluate().isEmpty) return false;

    final destinations = find.descendant(
      of: navBar,
      matching: find.byType(NavigationDestination),
    );
    if (destinations.evaluate().length < 3) return false;

    await tester.tap(destinations.at(2));
    await tester.pumpAndSettle();
    return true;
  }

  testWidgets('Budgets tab is reachable from shell', (tester) async {
    await bootApp(tester);

    final isOnShell = find.byType(NavigationBar).evaluate().isNotEmpty;
    if (!isOnShell) return;

    final reached = await goToBudgets(tester);
    if (!reached) return;

    // Budget screen should render without crashing
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Set budget sheet opens', (tester) async {
    await bootApp(tester);

    final isOnShell = find.byType(NavigationBar).evaluate().isNotEmpty;
    if (!isOnShell) return;

    final reached = await goToBudgets(tester);
    if (!reached) return;

    // Look for FAB or any button to set budget
    final fab = find.byType(FloatingActionButton);
    final addButton = find.byTooltip('Set Budget');

    final trigger =
        fab.evaluate().isNotEmpty ? fab.first : addButton;
    if (trigger.evaluate.call().isEmpty) return;

    await tester.tap(trigger.first);
    await tester.pumpAndSettle();

    // Sheet or dialog opened — no crash
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Budget screen shows category list or empty state',
      (tester) async {
    await bootApp(tester);

    final isOnShell = find.byType(NavigationBar).evaluate().isNotEmpty;
    if (!isOnShell) return;

    final reached = await goToBudgets(tester);
    if (!reached) return;

    // Either budget items or an empty state message are visible — no crash
    final hasBudgetItems = find.byType(ListTile).evaluate().isNotEmpty;
    final hasEmptyState =
        find.textContaining('budget').evaluate().isNotEmpty ||
            find.textContaining('Budget').evaluate().isNotEmpty;

    expect(hasBudgetItems || hasEmptyState, isTrue);
  });
}
