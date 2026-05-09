import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../providers/auth_provider.dart';
import 'pin_pad.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  static const _pinLength = 6;

  String _current = '';
  bool _shake = false;
  String? _error;
  bool _showBiometric = true;
  bool _autoBiometricTried = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initBiometricState());
  }

  Future<void> _initBiometricState() async {
    final notifier = ref.read(authProvider.notifier);
    final enabled = await notifier.isBiometricUnlockEnabled;
    final hasBiometricHardware = await notifier.hasBiometrics;
    final canUseBiometric = enabled && hasBiometricHardware;

    if (!mounted) return;
    setState(() => _showBiometric = canUseBiometric);

    final lockout = ref.read(pinLockoutProvider).valueOrNull;
    if (canUseBiometric &&
        !_autoBiometricTried &&
        !(lockout?.isLocked ?? false)) {
      _autoBiometricTried = true;
      await _tryBiometricOnOpen();
    }
  }

  Future<void> _tryBiometricOnOpen() async {
    final ok = await ref.read(authProvider.notifier).unlockWithBiometric();
    if (!ok && mounted) {
      setState(() {
        _error = 'Biometric unlock failed. Use your PIN.';
      });
    }
  }

  Future<void> _onBiometricTap() async {
    final lockout = ref.read(pinLockoutProvider).valueOrNull;
    if (lockout?.isLocked ?? false) return;
    final ok = await ref.read(authProvider.notifier).unlockWithBiometric();
    if (!ok && mounted) {
      setState(() {
        _error = 'Biometric unlock failed. Use your PIN.';
      });
    }
  }

  void _onDigit(String d) {
    final lockout = ref.read(pinLockoutProvider).valueOrNull;
    if (lockout?.isLocked ?? false) return;
    if (_current.length >= _pinLength) return;
    setState(() {
      _current += d;
      _shake = false;
      _error = null;
    });
    if (_current.length == _pinLength) _verify();
  }

  void _onDelete() {
    if (_current.isEmpty) return;
    setState(() => _current = _current.substring(0, _current.length - 1));
  }

  Future<void> _verify() async {
    final result = await ref
        .read(authProvider.notifier)
        .verifyPinWithLockout(_current);

    // Force the lockout state provider to re-read so the UI sees the new
    // counter / lockoutUntil immediately.
    await ref.read(pinLockoutProvider.notifier).refresh();

    if (result.success) return; // GoRouter redirect takes over.

    if (!mounted) return;
    final lockout = result.lockout;
    if (lockout.isLocked) {
      setState(() {
        _shake = true;
        _error = null;
        _current = '';
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _shake = false);
    } else {
      final attemptsLeft =
          AuthNotifier.maxAttemptsPerCycle - lockout.failedAttempts;
      setState(() {
        _shake = true;
        _error = attemptsLeft == 1
            ? 'Incorrect PIN. 1 attempt left.'
            : 'Incorrect PIN. $attemptsLeft attempts left.';
        _current = '';
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _shake = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockoutState = ref.watch(pinLockoutProvider).valueOrNull;
    final isLocked = lockoutState?.isLocked ?? false;
    final remaining = lockoutState?.remaining ?? Duration.zero;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Icon(
                Icons.lock_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Enter your PIN',
                style: Theme.of(context).textTheme.headlineSmall,
                semanticsLabel: 'Enter your PIN to unlock the app',
              ),
              const Spacer(),
              if (isLocked)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'Too many attempts.\nTry again in ${_formatRemaining(remaining)}.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                )
              else
                PinPad(
                  enteredLength: _current.length,
                  pinLength: _pinLength,
                  onDigit: _onDigit,
                  onDelete: _onDelete,
                  shake: _shake,
                  errorMessage: _error,
                  biometricButton: _showBiometric
                      ? Semantics(
                          label: 'Use biometric authentication',
                          button: true,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull),
                            onTap: _onBiometricTap,
                            child: const Center(
                              child: Icon(Icons.fingerprint_rounded, size: 32),
                            ),
                          ),
                        )
                      : null,
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatRemaining(Duration d) {
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return m == 0 ? '${h}h' : '${h}h ${m}m';
    }
    if (d.inMinutes >= 1) {
      final m = d.inMinutes;
      final s = d.inSeconds.remainder(60);
      return s == 0 ? '${m}m' : '${m}m ${s}s';
    }
    return '${d.inSeconds.clamp(0, 60)}s';
  }
}
