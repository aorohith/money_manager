import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/auth_local_datasource.dart';
import '../../../auth/providers/auth_provider.dart';

// ── Theme mode ───────────────────────────────────────────────────────────────

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  late AuthLocalDatasource _ds;

  @override
  Future<ThemeMode> build() async {
    _ds = ref.read(authDatasourceProvider);
    final mode = await _ds.getThemeMode();
    return _fromString(mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _ds.saveThemeMode(_toString(mode));
    state = AsyncData(mode);
  }

  static ThemeMode _fromString(String s) => switch (s) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _toString(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}

// ── Profile color ────────────────────────────────────────────────────────────

final profileColorProvider = FutureProvider<int>((ref) {
  final ds = ref.read(authDatasourceProvider);
  return ds.getProfileColor();
});

// ── Biometric preference ─────────────────────────────────────────────────────

final biometricEnabledProvider =
    AsyncNotifierProvider<BiometricEnabledNotifier, bool>(
        BiometricEnabledNotifier.new);

class BiometricEnabledNotifier extends AsyncNotifier<bool> {
  late AuthLocalDatasource _ds;

  @override
  Future<bool> build() async {
    _ds = ref.read(authDatasourceProvider);
    return _ds.getBiometricEnabled();
  }

  Future<void> toggle(bool enabled) async {
    await _ds.saveBiometricEnabled(enabled);
    state = AsyncData(enabled);
  }
}
