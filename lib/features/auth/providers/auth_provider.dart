import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../data/auth_local_datasource.dart';
import '../domain/auth_state.dart';

final authDatasourceProvider = Provider<AuthLocalDatasource>(
  (_) => AuthLocalDatasource(),
);

final localAuthProvider = Provider<LocalAuthentication>(
  (_) => LocalAuthentication(),
);

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthStatus>(AuthNotifier.new);

/// Live persistent PIN lockout state. Surfaces the latest values so the lock
/// screen never has to maintain its own in-memory counter (those reset on
/// process kill).
final pinLockoutProvider =
    AsyncNotifierProvider<PinLockoutNotifier, PinLockoutState>(
  PinLockoutNotifier.new,
);

/// Result of a PIN verification attempt.
class PinUnlockResult {
  const PinUnlockResult({required this.success, required this.lockout});

  final bool success;
  final PinLockoutState lockout;
}

/// Persistent brute-force lockout snapshot.
class PinLockoutState {
  const PinLockoutState({
    required this.failedAttempts,
    required this.lockoutLevel,
    required this.lockoutUntil,
  });

  static const empty = PinLockoutState(
    failedAttempts: 0,
    lockoutLevel: 0,
    lockoutUntil: null,
  );

  /// Failed attempts since the last successful unlock or expired lockout.
  final int failedAttempts;

  /// Number of full lockout cycles served since the last successful unlock.
  /// Index into [AuthNotifier.lockoutDurations] to get the next penalty.
  final int lockoutLevel;

  /// Absolute time at which the current lockout expires. `null` when no
  /// lockout is active.
  final DateTime? lockoutUntil;

  bool get isLocked {
    final until = lockoutUntil;
    return until != null && until.isAfter(DateTime.now());
  }

  Duration get remaining {
    final until = lockoutUntil;
    if (until == null) return Duration.zero;
    final diff = until.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}

class AuthNotifier extends AsyncNotifier<AuthStatus> {
  AuthLocalDatasource get _ds => ref.read(authDatasourceProvider);
  LocalAuthentication get _localAuth => ref.read(localAuthProvider);

  /// Number of failed attempts that triggers a lockout escalation.
  static const int maxAttemptsPerCycle = 5;

  /// Lockout durations, indexed by [PinLockoutState.lockoutLevel] (after
  /// increment). Capped at the last entry — the user must reset the PIN to
  /// recover after that point in practice.
  static const List<Duration> lockoutDurations = [
    Duration(seconds: 60),
    Duration(minutes: 5),
    Duration(minutes: 30),
    Duration(hours: 24),
  ];

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
    await _clearPinLockout();
    state = const AsyncData(AuthStatus.authenticated);
  }

  // ── Unlock ────────────────────────────────────────────────────────────

  /// Returns true if PIN matched; false otherwise.
  ///
  /// Prefer [verifyPinWithLockout] for new code so the call site can render
  /// the persistent lockout state.
  Future<bool> unlockWithPin(String pin) async {
    final result = await verifyPinWithLockout(pin);
    return result.success;
  }

  /// Verifies a PIN through the persistent rate limiter.
  ///
  /// While a lockout is active, every call returns `success: false` without
  /// touching the stored hash. On a successful unlock, the auth status moves
  /// to [AuthStatus.authenticated] and lockout state is cleared. On failure
  /// the failed-attempt counter is bumped and a new lockout window may be
  /// armed — see [lockoutDurations].
  Future<PinUnlockResult> verifyPinWithLockout(String pin) async {
    final current = await _readPinLockout();
    if (current.isLocked) {
      return PinUnlockResult(success: false, lockout: current);
    }

    final ok = await _ds.verifyPin(pin);
    if (ok) {
      final cleared = await _clearPinLockout();
      state = const AsyncData(AuthStatus.authenticated);
      return PinUnlockResult(success: true, lockout: cleared);
    }

    final updated = await _recordFailedPinAttempt(current);
    return PinUnlockResult(success: false, lockout: updated);
  }

  Future<PinLockoutState> _readPinLockout() async {
    return PinLockoutState(
      failedAttempts: await _ds.getFailedPinAttempts(),
      lockoutLevel: await _ds.getPinLockoutLevel(),
      lockoutUntil: await _ds.getPinLockoutUntil(),
    );
  }

  Future<PinLockoutState> _recordFailedPinAttempt(PinLockoutState current) async {
    final attempts = current.failedAttempts + 1;
    var level = current.lockoutLevel;
    DateTime? until = current.lockoutUntil;
    var resetAttempts = attempts;

    if (attempts >= maxAttemptsPerCycle) {
      level = (level + 1).clamp(1, lockoutDurations.length);
      final duration = lockoutDurations[(level - 1).clamp(0, lockoutDurations.length - 1)];
      until = DateTime.now().add(duration);
      resetAttempts = 0;
    }

    await _ds.setFailedPinAttempts(resetAttempts);
    await _ds.setPinLockoutLevel(level);
    await _ds.setPinLockoutUntil(until);

    final next = PinLockoutState(
      failedAttempts: resetAttempts,
      lockoutLevel: level,
      lockoutUntil: until,
    );
    ref.invalidate(pinLockoutProvider);
    return next;
  }

  Future<PinLockoutState> _clearPinLockout() async {
    await _ds.setFailedPinAttempts(0);
    await _ds.setPinLockoutLevel(0);
    await _ds.setPinLockoutUntil(null);
    ref.invalidate(pinLockoutProvider);
    return PinLockoutState.empty;
  }

  /// Returns true if biometric succeeded.
  Future<bool> unlockWithBiometric() async {
    final biometricEnabled = await _ds.getBiometricEnabled();
    if (!biometricEnabled) return false;

    // Don't bypass an active PIN lockout via biometrics.
    final lockout = await _readPinLockout();
    if (lockout.isLocked) return false;

    final ok = await _authenticateBiometric(
      localizedReason: 'Unlock Money Manager',
    );
    if (ok) {
      await _clearPinLockout();
      state = const AsyncData(AuthStatus.authenticated);
    }
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
      // PlatformException is the most common cause (e.g. biometrics not
      // enrolled, hardware unavailable). Hide internal class names from
      // production logs to limit info leakage in crash dumps.
      if (kDebugMode) {
        debugPrint('[AuthNotifier] biometric auth failed: $e\n$st');
      }
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
    await _clearPinLockout();
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  Future<bool> get hasBiometrics async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AuthNotifier] hasBiometrics check failed: $e\n$st');
      }
      return false;
    }
  }

  Future<bool> get isBiometricUnlockEnabled => _ds.getBiometricEnabled();

  Future<PinLockoutState> readLockoutState() => _readPinLockout();
}

/// Polls the persistent lockout state once a second so the lock screen can
/// render the remaining countdown without owning a timer.
class PinLockoutNotifier extends AsyncNotifier<PinLockoutState> {
  Timer? _ticker;

  @override
  Future<PinLockoutState> build() async {
    ref.onDispose(() => _ticker?.cancel());
    final initial = await ref.read(authProvider.notifier).readLockoutState();
    if (initial.isLocked) _ensureTicker();
    return initial;
  }

  void _ensureTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    final next = await ref.read(authProvider.notifier).readLockoutState();
    state = AsyncData(next);
    if (!next.isLocked) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  /// Force a refresh (e.g. after a PIN attempt mutates persistent state).
  Future<void> refresh() async {
    final next = await ref.read(authProvider.notifier).readLockoutState();
    state = AsyncData(next);
    if (next.isLocked) {
      _ensureTicker();
    } else {
      _ticker?.cancel();
      _ticker = null;
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
