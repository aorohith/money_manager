import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/core/constants/app_colors.dart';
import 'package:money_manager/core/widgets/app_card.dart';
import 'package:money_manager/features/auth/data/auth_local_datasource.dart';
import 'package:money_manager/features/auth/providers/auth_provider.dart';
import 'package:money_manager/features/settings/presentation/widgets/biometric_tile.dart';

import '../helpers/pump_app.dart';

class _MockAuthDatasource extends Mock implements AuthLocalDatasource {}

void main() {
  late _MockAuthDatasource ds;

  setUp(() {
    ds = _MockAuthDatasource();
    // Both build paths need these stubs.
    when(() => ds.isOnboardingDone()).thenAnswer((_) async => true);
    when(() => ds.hasPin()).thenAnswer((_) async => true);
    when(() => ds.saveBiometricEnabled(any())).thenAnswer((_) async {});
  });

  Future<void> pumpTile(WidgetTester tester) async {
    await tester.pumpApp(
      const Scaffold(body: BiometricTile()),
      overrides: [authDatasourceProvider.overrideWithValue(ds)],
    );
    await tester.pumpAndSettle();
  }

  group('BiometricTile', () {
    testWidgets('uses brand colour for the active thumb', (tester) async {
      when(() => ds.getBiometricEnabled()).thenAnswer((_) async => true);

      await pumpTile(tester);

      final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(tile.activeThumbColor, AppColors.brand);
      expect(tile.value, isTrue);
    });

    testWidgets('whole card is tappable (no dead zone around the switch)',
        (tester) async {
      when(() => ds.getBiometricEnabled()).thenAnswer((_) async => false);

      await pumpTile(tester);

      final card = tester.widget<AppCard>(find.byType(AppCard));
      expect(
        card.onTap,
        isNotNull,
        reason: 'Whole card should be tappable so the row has no dead zone.',
      );
    });

    testWidgets(
      'tapping the card while enabled disables biometrics via the datasource',
      (tester) async {
        when(() => ds.getBiometricEnabled()).thenAnswer((_) async => true);

        await pumpTile(tester);

        await tester.tap(find.byType(AppCard));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        verify(() => ds.saveBiometricEnabled(false)).called(1);
      },
    );

    testWidgets('inner switch ignores direct gestures (no double-fire)',
        (tester) async {
      when(() => ds.getBiometricEnabled()).thenAnswer((_) async => true);

      await pumpTile(tester);

      // SwitchListTile is wrapped in IgnorePointer so only the parent AppCard
      // receives the tap. Tapping at the switch position should fire the
      // toggle exactly once (via the card), not twice.
      await tester.tap(find.byType(Switch), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      verify(() => ds.saveBiometricEnabled(false)).called(1);
    });
  });
}
