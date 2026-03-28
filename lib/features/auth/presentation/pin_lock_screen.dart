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

class _PinLockScreenState extends ConsumerState<PinLockScreen>
    with WidgetsBindingObserver {
  static const _pinLength = 6;
  static const _maxAttempts = 5;
  static const _lockoutSeconds = 60;

  String _current = '';
  bool _shake = false;
  String? _error;
  int _attempts = 0;
  int _lockoutRemaining = 0;
  Timer? _lockoutTimer;
  bool _showBiometric = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tryBiometricOnOpen();
  }

  Future<void> _tryBiometricOnOpen() async {
    final ok = await ref.read(authProvider.notifier).unlockWithBiometric();
    if (!ok && mounted) setState(() => _showBiometric = true);
  }

  void _onDigit(String d) {
    if (_lockoutRemaining > 0) return;
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
    final ok =
        await ref.read(authProvider.notifier).unlockWithPin(_current);
    if (ok) return; // GoRouter redirect takes over

    _attempts++;
    final attemptsLeft = _maxAttempts - _attempts;

    if (_attempts >= _maxAttempts) {
      _startLockout();
    } else {
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

  void _startLockout() {
    setState(() {
      _lockoutRemaining = _lockoutSeconds;
      _current = '';
      _error = null;
      _attempts = 0;
    });
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _lockoutRemaining--);
      if (_lockoutRemaining <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              if (_lockoutRemaining > 0)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'Too many attempts.\nTry again in $_lockoutRemaining seconds.',
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
                            onTap: () => ref
                                .read(authProvider.notifier)
                                .unlockWithBiometric(),
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
}
