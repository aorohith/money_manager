import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:money_manager/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches and navigates past splash screen', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // The Money Manager logo text should appear on the splash screen.
    expect(find.text('Money Manager'), findsWidgets);

    // Wait for the splash delay (1500ms animation + 300ms buffer) and auth
    // resolution — give 8s headroom for emulator startup latency.
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // After navigation the splash is gone; we should be on a real screen
    // (onboarding for first install, or dashboard/pin for returning user).
    // The splash screen Scaffold has a primary-coloured background — after
    // navigation that exact widget tree is no longer in the tree.
    // Verify at least one NavigationBar destination is visible (shell route),
    // OR the onboarding content is visible.
    final isOnShell = find.byType(NavigationBar).evaluate().isNotEmpty;
    final isOnOnboarding = find
        .text('Take control of\nyour money')
        .evaluate()
        .isNotEmpty;
    final isOnPin = find.byKey(const Key('pin_pad')).evaluate().isNotEmpty;

    expect(
      isOnShell || isOnOnboarding || isOnPin,
      isTrue,
      reason: 'App should have navigated away from splash to a real screen',
    );
  });
}
