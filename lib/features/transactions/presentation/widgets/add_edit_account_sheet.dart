import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/account_model.dart';
import '../../domain/providers/transaction_providers.dart';

final _accountIcons = [
  Icons.payments_rounded,
  Icons.account_balance_rounded,
  Icons.credit_card_rounded,
  Icons.savings_rounded,
  Icons.account_balance_wallet_rounded,
  Icons.currency_rupee_rounded,
  Icons.attach_money_rounded,
  Icons.euro_rounded,
  Icons.monetization_on_rounded,
  Icons.wallet_rounded,
  Icons.contactless_rounded,
  Icons.qr_code_rounded,
  Icons.phone_android_rounded,
  Icons.business_rounded,
  Icons.work_rounded,
  Icons.trending_up_rounded,
  Icons.home_rounded,
  Icons.local_atm_rounded,
];

Future<void> showAddEditAccountSheet(
  BuildContext context, {
  AccountModel? existing,
}) {
  return showAppBottomSheet(
    context: context,
    title: existing == null ? 'Add Account' : 'Edit Account',
    maxHeightFraction: 0.92,
    child: _AddEditAccountForm(existing: existing),
  );
}

class _AddEditAccountForm extends ConsumerStatefulWidget {
  const _AddEditAccountForm({this.existing});
  final AccountModel? existing;

  @override
  ConsumerState<_AddEditAccountForm> createState() =>
      _AddEditAccountFormState();
}

class _AddEditAccountFormState
    extends ConsumerState<_AddEditAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();

  late int _selectedColorValue;
  late int _selectedIconCodePoint;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _selectedColorValue =
        e?.colorValue ?? AppColors.categoryPalette[1].toARGB32();
    _selectedIconCodePoint =
        e?.iconCodePoint ?? Icons.account_balance_wallet_rounded.codePoint;
    if (e != null) {
      _nameCtrl.text = e.name;
      _balanceCtrl.text = e.initialBalance.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(accountRepositoryProvider);
      if (widget.existing == null) {
        final account = AccountModel(
          name: _nameCtrl.text.trim(),
          iconCodePoint: _selectedIconCodePoint,
          colorValue: _selectedColorValue,
          initialBalance:
              double.tryParse(_balanceCtrl.text.replaceAll(',', '')) ?? 0,
          isDefault: false,
        );
        await repo.add(account);
      } else {
        widget.existing!
          ..name = _nameCtrl.text.trim()
          ..iconCodePoint = _selectedIconCodePoint
          ..colorValue = _selectedColorValue
          ..initialBalance =
              double.tryParse(_balanceCtrl.text.replaceAll(',', '')) ?? 0;
        await repo.update(widget.existing!);
      }
      if (mounted) {
        Navigator.of(context).pop();
        showAppSnackBar(
          context,
          message:
              widget.existing == null ? 'Account added' : 'Account updated',
          type: AppSnackBarType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        showAppSnackBar(context,
            message: 'Something went wrong', type: AppSnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Color(_selectedColorValue);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          AppTextField(
            controller: _nameCtrl,
            label: 'Account name',
            hint: 'e.g. Cash, SBI Savings…',
            prefixIcon: const Icon(Icons.label_rounded),
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name is required';
              if (v.trim().length > 30) return 'Name too long';
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Initial balance
          AppTextField(
            controller: _balanceCtrl,
            label: 'Opening balance',
            hint: '0.00',
            prefixIcon: const Icon(Icons.attach_money_rounded),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
            ],
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v != null && v.isNotEmpty) {
                if (double.tryParse(v.replaceAll(',', '')) == null) {
                  return 'Enter a valid number';
                }
              }
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Color picker
          _SectionLabel('Color'),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AppColors.categoryPalette.map((color) {
              final selected = color.toARGB32() == _selectedColorValue;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedColorValue = color.toARGB32()),
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 2.5,
                          )
                        : null,
                    boxShadow: selected
                        ? [BoxShadow(color: color.withAlpha(100), blurRadius: 6)]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.md),

          // Icon picker
          _SectionLabel('Icon'),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 120,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                mainAxisSpacing: AppSpacing.xs,
                crossAxisSpacing: AppSpacing.xs,
              ),
              itemCount: _accountIcons.length,
              itemBuilder: (_, i) {
                final icon = _accountIcons[i];
                final selected =
                    icon.codePoint == _selectedIconCodePoint;
                return GestureDetector(
                  onTap: () => setState(
                      () => _selectedIconCodePoint = icon.codePoint),
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    decoration: BoxDecoration(
                      color: selected
                          ? selectedColor.withAlpha(40)
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      border: selected
                          ? Border.all(color: selectedColor, width: 1.5)
                          : null,
                    ),
                    child: Icon(icon,
                        color: selected
                            ? selectedColor
                            : Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                        size: 22),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          AppButton(
            expanded: true,
            label: widget.existing == null ? 'Add Account' : 'Save',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
}
