import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
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

    final ds = ref.read(authDatasourceProvider);
    final ok = await ds.verifyPin(_currentCtrl.text);
    if (!ok) {
      setState(() => _loading = false);
      if (mounted) {
        showAppSnackBar(context,
            message: 'Current PIN is incorrect',
            type: AppSnackBarType.error);
      }
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _currentCtrl,
            label: 'Current PIN',
            hint: '6-digit PIN',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (v) => (v == null || v.length != 6)
                ? 'Enter your current 6-digit PIN'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _newCtrl,
            label: 'New PIN',
            hint: '6-digit PIN',
            prefixIcon: const Icon(Icons.lock_rounded),
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (v) =>
                (v == null || v.length != 6) ? 'Enter a 6-digit PIN' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _confirmCtrl,
            label: 'Confirm New PIN',
            hint: '6-digit PIN',
            prefixIcon: const Icon(Icons.lock_rounded),
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (v) {
              if (v == null || v.length != 6) return 'Enter a 6-digit PIN';
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
