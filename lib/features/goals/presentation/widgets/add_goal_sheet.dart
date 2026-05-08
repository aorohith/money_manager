import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/goal_model.dart';
import '../../domain/providers/goal_providers.dart';

Future<void> showAddGoalSheet(BuildContext context, {GoalModel? existing}) {
  return showAppBottomSheet(
    context: context,
    title: existing == null ? 'Add Goal' : 'Edit Goal',
    maxHeightFraction: 0.92,
    child: _AddGoalForm(existing: existing),
  );
}

class _AddGoalForm extends ConsumerStatefulWidget {
  const _AddGoalForm({this.existing});
  final GoalModel? existing;

  @override
  ConsumerState<_AddGoalForm> createState() => _AddGoalFormState();
}

class _AddGoalFormState extends ConsumerState<_AddGoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _deadline;
  int _selectedIcon = Icons.savings_rounded.codePoint;
  int _selectedColor = AppColors.brand.toARGB32();
  bool _loading = false;

  static const _goalIcons = [
    Icons.savings_rounded,
    Icons.home_rounded,
    Icons.directions_car_rounded,
    Icons.flight_rounded,
    Icons.school_rounded,
    Icons.phone_iphone_rounded,
    Icons.laptop_mac_rounded,
    Icons.health_and_safety_rounded,
    Icons.diamond_rounded,
    Icons.celebration_rounded,
    Icons.shopping_bag_rounded,
    Icons.sports_esports_rounded,
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text = e.name;
      _amountCtrl.text = e.targetAmount.toStringAsFixed(2);
      _notesCtrl.text = e.notes ?? '';
      _deadline = e.deadline;
      _selectedIcon = e.iconCodePoint;
      _selectedColor = e.colorValue;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    try {
      final goal = widget.existing ??
          GoalModel(
            name: '',
            targetAmount: 0,
          );

      goal
        ..name = _nameCtrl.text.trim()
        ..targetAmount =
            double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0
        ..deadline = _deadline
        ..iconCodePoint = _selectedIcon
        ..colorValue = _selectedColor
        ..notes = _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim();

      if (widget.existing == null) {
        await ref.read(addGoalUseCaseProvider)(goal);
      } else {
        await ref.read(updateGoalUseCaseProvider)(goal);
      }

      if (mounted) {
        Navigator.of(context).pop();
        showAppSnackBar(
          context,
          message:
              widget.existing == null ? 'Goal created' : 'Goal updated',
          type: AppSnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showAppSnackBar(context,
            message: 'Something went wrong', type: AppSnackBarType.error);
      }
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
            controller: _nameCtrl,
            label: 'Goal Name',
            hint: 'e.g. Emergency Fund',
            prefixIcon: const Icon(Icons.flag_rounded),
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _amountCtrl,
            label: 'Target Amount',
            hint: '0.00',
            prefixIcon: const Icon(Icons.attach_money_rounded),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Amount is required';
              final n = double.tryParse(v.replaceAll(',', ''));
              if (n == null || n <= 0) return 'Enter a valid positive amount';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Deadline
          _Label('Deadline (optional)'),
          const SizedBox(height: AppSpacing.xs),
          InkWell(
            onTap: _pickDeadline,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _deadline != null
                        ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                        : 'No deadline set',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  if (_deadline != null)
                    GestureDetector(
                      onTap: () => setState(() => _deadline = null),
                      child: const Icon(Icons.close_rounded, size: 18),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Icon picker
          _Label('Icon'),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _goalIcons.map((icon) {
              final isSelected = icon.codePoint == _selectedIcon;
              final color = Color(_selectedColor);
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedIcon = icon.codePoint),
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(30) : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: isSelected
                        ? Border.all(color: color, width: 2)
                        : Border.all(
                            color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Icon(icon,
                      color: isSelected
                          ? color
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 22),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Color picker
          _Label('Color'),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: AppColors.categoryPalette.take(8).map((c) {
              final isSelected = c.toARGB32() == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c.toARGB32()),
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 3)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Notes
          AppTextField(
            controller: _notesCtrl,
            label: 'Notes (optional)',
            hint: 'Add a note...',
            prefixIcon: const Icon(Icons.notes_rounded),
            maxLines: 2,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.xl),

          AppButton(
            expanded: true,
            label: widget.existing == null ? 'Create Goal' : 'Save',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
}
