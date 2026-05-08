import 'dart:async';

import 'package:flutter/foundation.dart';
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
  final _localAuth = LocalAuthentication();
  AuthLocalDatasource get _ds => ref.read(authDatasourceProvider);

  @override
  Future<AuthStatus> build() async {
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
    final biometricEnabled = await _ds.getBiometricEnabled();
    if (!biometricEnabled) return false;

    final ok = await _authenticateBiometric(
      localizedReason: 'Unlock Money Manager',
    );
    if (ok) state = const AsyncData(AuthStatus.authenticated);
    return ok;
  }

  Future<bool> confirmBiometricIdentity({
    required String localizedReason,
  }) {
    return _authenticateBiometric(localizedReason: localizedReason);
  }

  Future<bool> _authenticateBiometric({
    required String localizedReason,
  }) async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return false;

      final ok = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return ok;
    } catch (e, st) {
      // Log so that biometric failures are visible during debugging.
      // PlatformException is the most common cause (e.g. biometrics not
      // enrolled, hardware unavailable).
      debugPrint('[AuthNotifier] unlockWithBiometric failed: $e\n$st');
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
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e, st) {
      debugPrint('[AuthNotifier] hasBiometrics check failed: $e\n$st');
      return false;
    }
  }

  Future<bool> get isBiometricUnlockEnabled => _ds.getBiometricEnabled();
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
