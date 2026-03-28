import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../data/auth_local_datasource.dart';
import '../domain/auth_state.dart';

final authDatasourceProvider = Provider<AuthLocalDatasource>(
  (_) => AuthLocalDatasource(),
);

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthStatus>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthStatus> {
  late AuthLocalDatasource _ds;
  final _localAuth = LocalAuthentication();

  @override
  Future<AuthStatus> build() async {
    _ds = ref.read(authDatasourceProvider);
    return _resolveInitialStatus();
  }

  Future<AuthStatus> _resolveInitialStatus() async {
    final onboardingDone = await _ds.isOnboardingDone();
    if (!onboardingDone) return AuthStatus.unauthenticated;
    final hasPin = await _ds.hasPin();
    if (!hasPin) return AuthStatus.pinSetup;
    return AuthStatus.locked;
  }

  // ── Onboarding ────────────────────────────────────────────────────────

  Future<void> completeOnboarding() async {
    await _ds.setOnboardingDone();
    state = const AsyncData(AuthStatus.pinSetup);
  }

  // ── PIN setup ─────────────────────────────────────────────────────────

  Future<void> setupPin(String pin) async {
    await _ds.savePin(pin);
    state = const AsyncData(AuthStatus.authenticated);
  }

  // ── Unlock ────────────────────────────────────────────────────────────

  /// Returns true if PIN matched; false otherwise.
  Future<bool> unlockWithPin(String pin) async {
    final ok = await _ds.verifyPin(pin);
    if (ok) state = const AsyncData(AuthStatus.authenticated);
    return ok;
  }

  /// Returns true if biometric succeeded.
  Future<bool> unlockWithBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!canCheck && !isDeviceSupported) return false;

      final ok = await _localAuth.authenticate(
        localizedReason: 'Unlock Money Manager',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (ok) state = const AsyncData(AuthStatus.authenticated);
      return ok;
    } catch (_) {
      return false;
    }
  }

  // ── Lock ──────────────────────────────────────────────────────────────

  void lock() {
    state = const AsyncData(AuthStatus.locked);
  }

  // ── PIN change ────────────────────────────────────────────────────────

  Future<void> changePin(String newPin) async {
    await _ds.savePin(newPin);
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  Future<bool> get hasBiometrics async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }
}

// ── Convenience derived providers ─────────────────────────────────────────

final isAuthenticatedProvider = Provider<bool>((ref) {
  final status = ref.watch(authProvider).valueOrNull;
  return status == AuthStatus.authenticated;
});

final currencyCodeProvider = FutureProvider<String>((ref) {
  final ds = ref.read(authDatasourceProvider);
  return ds.getCurrencyCode();
});

final currencySymbolProvider = FutureProvider<String>((ref) {
  final ds = ref.read(authDatasourceProvider);
  return ds.getCurrencySymbol();
});

final profileNameProvider = FutureProvider<String>((ref) {
  final ds = ref.read(authDatasourceProvider);
  return ds.getProfileName();
});
