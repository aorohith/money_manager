import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/domain/auth_config.dart';
import '../../../auth/providers/auth_provider.dart';

Future<void> showChangePinSheet(BuildContext context) {
  return showAppBottomSheet(
    context: context,
    title: 'Change PIN',
    child: const _ChangePinForm(),
  );
}

class _ChangePinForm extends ConsumerStatefulWidget {
  const _ChangePinForm();

  @override
  ConsumerState<_ChangePinForm> createState() => _ChangePinFormState();
}

class _ChangePinFormState extends ConsumerState<_ChangePinForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    // Reuse the persistent lockout path so this surface can't be used to
    // brute-force the current PIN (it would otherwise bypass the lock screen
    // counter entirely).
    final result = await ref
        .read(authProvider.notifier)
        .verifyPinWithLockout(_currentCtrl.text);

    if (!result.success) {
      setState(() => _loading = false);
      if (!mounted) return;
      final message = result.lockout.isLocked
          ? 'Too many attempts. Try again in '
              '${_formatRemaining(result.lockout.remaining)}.'
          : 'Current PIN is incorrect';
      showAppSnackBar(
        context,
        message: message,
        type: AppSnackBarType.error,
      );
      return;
    }

    await ref.read(authProvider.notifier).changePin(_newCtrl.text);

    if (mounted) {
      Navigator.of(context).pop();
      showAppSnackBar(context,
          message: 'PIN changed successfully',
          type: AppSnackBarType.success);
    }
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

  @override
  Widget build(BuildContext context) {
    final pinLength = AuthConfig.pinLength;
    final pinHint = '${AuthConfig.pinLengthLabel} PIN';
    final pinFormatters = <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(pinLength),
    ];

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _currentCtrl,
            label: 'Current PIN',
            hint: pinHint,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: pinFormatters,
            validator: (v) => (v == null || v.length != pinLength)
                ? 'Enter your current $pinHint'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _newCtrl,
            label: 'New PIN',
            hint: pinHint,
            prefixIcon: const Icon(Icons.lock_rounded),
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: pinFormatters,
            validator: (v) => (v == null || v.length != pinLength)
                ? 'Enter a $pinHint'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _confirmCtrl,
            label: 'Confirm New PIN',
            hint: pinHint,
            prefixIcon: const Icon(Icons.lock_rounded),
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: pinFormatters,
            validator: (v) {
              if (v == null || v.length != pinLength) return 'Enter a $pinHint';
              if (v != _newCtrl.text) return 'PINs do not match';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            expanded: true,
            label: 'Change PIN',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
