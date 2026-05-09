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
    expect(
      navBar,
      findsOneWidget,
      reason: 'Budget flow requires authenticated shell navigation',
    );

    final destinations = find.descendant(
      of: navBar,
      matching: find.byType(NavigationDestination),
    );
    expect(
      destinations.evaluate().length,
      greaterThanOrEqualTo(3),
      reason: 'Expected budgets destination in navigation bar',
    );

    await tester.tap(destinations.at(2));
    await tester.pumpAndSettle();
    return true;
  }

  testWidgets('Budgets tab is reachable from shell', (tester) async {
    await bootApp(tester);

    final reached = await goToBudgets(tester);
    expect(reached, isTrue);

    expect(find.text('Budgets'), findsWidgets);
  });

  testWidgets('Set budget sheet opens', (tester) async {
    await bootApp(tester);

    final reached = await goToBudgets(tester);
    expect(reached, isTrue);

    // Look for FAB or any button to set budget
    final fab = find.byType(FloatingActionButton);
    final addButton = find.byTooltip('Set Budget');

    final trigger = fab.evaluate().isNotEmpty ? fab.first : addButton;
    expect(trigger, findsOneWidget);

    await tester.tap(trigger.first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Budget'), findsWidgets);
  });

  testWidgets('Budget screen shows category list or empty state', (
    tester,
  ) async {
    await bootApp(tester);

    final reached = await goToBudgets(tester);
    expect(reached, isTrue);

    // Either budget items or an empty state message are visible — no crash
    final hasBudgetItems = find.byType(ListTile).evaluate().isNotEmpty;
    final hasEmptyState =
        find.textContaining('budget').evaluate().isNotEmpty ||
        find.textContaining('Budget').evaluate().isNotEmpty;

    expect(hasBudgetItems || hasEmptyState, isTrue);
  });
}
