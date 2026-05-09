import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/dashboard/data/home_layout_repository.dart';
import 'package:money_manager/features/dashboard/domain/models/home_section.dart';
import 'package:money_manager/features/dashboard/presentation/screens/home_layout_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

void main() {
  group('HomeLayoutScreen', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<void> pumpScreen(WidgetTester tester) async {
      // The screen is tall (one tile per HomeSection); set a viewport that
      // can accommodate every tile so the lazy ListView builds them all.
      await tester.binding.setSurfaceSize(const Size(420, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpApp(const HomeLayoutScreen());
      await tester.pumpAndSettle();
    }

    testWidgets('lists every optional section + always-on balance card',
        (tester) async {
      await pumpScreen(tester);

      expect(find.text('Balance card'), findsOneWidget);
      for (final section in HomeSection.values) {
        expect(
          find.text(section.label),
          findsOneWidget,
          reason: 'missing tile for ${section.id}',
        );
      }
    });

    testWidgets('switch state mirrors the default-enabled set', (tester) async {
      await pumpScreen(tester);

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.length, HomeSection.values.length);

      for (var i = 0; i < HomeSection.values.length; i++) {
        final section = HomeSection.values[i];
        expect(
          switches[i].value,
          section.defaultEnabled,
          reason: 'wrong default for ${section.id}',
        );
      }
    });

    testWidgets('toggling a switch persists the change', (tester) async {
      await pumpScreen(tester);

      // Goals is OFF by default. Tap its switch to enable it.
      final goalsTile = find.ancestor(
        of: find.text(HomeSection.goals.label),
        matching: find.byType(InkWell),
      );
      // Tap the row (the AppCard's InkWell) which toggles the section.
      await tester.tap(goalsTile.first);
      await tester.pumpAndSettle();

      final reloaded = await HomeLayoutRepository().getEnabledSections();
      expect(reloaded, contains(HomeSection.goals));
    });

    testWidgets('Reset → confirm restores defaults', (tester) async {
      // Start with a customised set.
      await HomeLayoutRepository()
          .saveEnabledSections({HomeSection.spendingRing});
      await pumpScreen(tester);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      // Confirm in the dialog.
      await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
      await tester.pumpAndSettle();

      final reloaded = await HomeLayoutRepository().getEnabledSections();
      expect(reloaded, equals(HomeSection.defaultEnabledSet));
    });
  });
}
