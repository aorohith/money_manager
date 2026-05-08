import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/auth/data/auth_local_datasource.dart';
import 'package:money_manager/features/auth/providers/auth_provider.dart';
import 'package:money_manager/features/settings/domain/providers/settings_providers.dart';

class _MockAuthDatasource extends Mock implements AuthLocalDatasource {}

void main() {
  late _MockAuthDatasource ds;
  late ProviderContainer container;

  setUp(() {
    ds = _MockAuthDatasource();
    container = ProviderContainer(
      overrides: [authDatasourceProvider.overrideWithValue(ds)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('themeModeProvider reads persisted mode', () async {
    when(() => ds.getThemeMode()).thenAnswer((_) async => 'dark');

    final mode = await container.read(themeModeProvider.future);
    expect(mode, ThemeMode.dark);
  });

  test('themeModeProvider setThemeMode persists and updates state', () async {
    when(() => ds.getThemeMode()).thenAnswer((_) async => 'system');
    when(() => ds.saveThemeMode('light')).thenAnswer((_) async {});
    await container.read(themeModeProvider.future);

    await container
        .read(themeModeProvider.notifier)
        .setThemeMode(ThemeMode.light);

    expect(container.read(themeModeProvider).value, ThemeMode.light);
    verify(() => ds.saveThemeMode('light')).called(1);
  });

  test('biometricEnabledProvider loads and toggles persisted state', () async {
    when(() => ds.getBiometricEnabled()).thenAnswer((_) async => false);
    when(() => ds.saveBiometricEnabled(true)).thenAnswer((_) async {});

    final initial = await container.read(biometricEnabledProvider.future);
    expect(initial, isFalse);

    await container.read(biometricEnabledProvider.notifier).toggle(true);
    expect(container.read(biometricEnabledProvider).value, isTrue);
    verify(() => ds.saveBiometricEnabled(true)).called(1);
  });
}
