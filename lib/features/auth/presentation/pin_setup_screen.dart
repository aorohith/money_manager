import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../domain/auth_config.dart';
import '../providers/auth_provider.dart';
import 'pin_pad.dart';

enum _PinSetupStep { enter, confirm }

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  static const _pinLength = AuthConfig.pinLength;

  _PinSetupStep _step = _PinSetupStep.enter;
  String _firstPin = '';
  String _current = '';
  bool _shake = false;
  String? _error;

  void _onDigit(String d) {
    if (_current.length >= _pinLength) return;
    setState(() {
      _current += d;
      _shake = false;
      _error = null;
    });
    if (_current.length == _pinLength) _handleComplete();
  }

  void _onDelete() {
    if (_current.isEmpty) return;
    setState(() => _current = _current.substring(0, _current.length - 1));
  }

  Future<void> _handleComplete() async {
    if (_step == _PinSetupStep.enter) {
      await Future.delayed(AppDurations.fast);
      setState(() {
        _firstPin = _current;
        _current = '';
        _step = _PinSetupStep.confirm;
      });
    } else {
      if (_current == _firstPin) {
        await ref.read(authProvider.notifier).setupPin(_current);
        // authProvider status change triggers GoRouter redirect
      } else {
        setState(() {
          _shake = true;
          _error = "PINs don't match. Try again.";
          _current = '';
          _step = _PinSetupStep.enter;
          _firstPin = '';
        });
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) setState(() => _shake = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConfirm = _step == _PinSetupStep.confirm;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Your App'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              Icon(
                Icons.lock_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                isConfirm
                    ? 'Confirm your PIN'
                    : 'Create a ${AuthConfig.pinLengthLabel} PIN',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
                semanticsLabel: isConfirm
                    ? 'Confirm your PIN'
                    : 'Create a $_pinLength digit PIN',
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isConfirm
                    ? 'Enter the same PIN again to confirm.'
                    : 'Your PIN keeps your financial data private.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PinPad(
                enteredLength: _current.length,
                pinLength: _pinLength,
                onDigit: _onDigit,
                onDelete: _onDelete,
                shake: _shake,
                errorMessage: _error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
