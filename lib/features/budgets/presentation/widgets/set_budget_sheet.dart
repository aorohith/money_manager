import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../transactions/data/models/category_model.dart';
import '../../../transactions/domain/providers/transaction_providers.dart';
import '../../data/models/budget_model.dart';
import '../../domain/providers/budget_providers.dart';

Future<void> showSetBudgetSheet(
  BuildContext context, {
  BudgetModel? existing,
  int? preselectedCategoryId,
}) {
  return showAppBottomSheet(
    context: context,
    title: existing == null ? 'Set Budget' : 'Edit Budget',
    child: _SetBudgetForm(
      existing: existing,
      preselectedCategoryId: preselectedCategoryId,
    ),
  );
}

class _SetBudgetForm extends ConsumerStatefulWidget {
  const _SetBudgetForm({this.existing, this.preselectedCategoryId});
  final BudgetModel? existing;
  final int? preselectedCategoryId;

  @override
  ConsumerState<_SetBudgetForm> createState() => _SetBudgetFormState();
}

class _SetBudgetFormState extends ConsumerState<_SetBudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();

  bool _isOverall = false;
  int? _selectedCategoryId;
  BudgetPeriod _period = BudgetPeriod.monthly;
  bool _rollover = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _amountCtrl.text = e.limitAmount.toStringAsFixed(2);
      _isOverall = e.categoryId == null;
      _selectedCategoryId = e.categoryId;
      _period = e.period;
      _rollover = e.rolloverEnabled;
    } else {
      _isOverall = widget.preselectedCategoryId == null;
      _selectedCategoryId = widget.preselectedCategoryId;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_isOverall && _selectedCategoryId == null) {
      showAppSnackBar(context,
          message: 'Please select a category',
          type: AppSnackBarType.error);
      return;
    }

    setState(() => _loading = true);

    final month = ref.read(budgetSelectedMonthProvider);
    final budget = widget.existing ??
        BudgetModel(
          limitAmount: 0,
          period: _period,
          month: month,
        );

    budget
      ..limitAmount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0
      ..categoryId = _isOverall ? null : _selectedCategoryId
      ..period = _period
      ..month = month
      ..rolloverEnabled = _rollover;

    await ref.read(setBudgetUseCaseProvider)(budget);

    if (mounted) {
      Navigator.of(context).pop();
      showAppSnackBar(context,
          message: widget.existing == null ? 'Budget set' : 'Budget updated',
          type: AppSnackBarType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(expenseCategoriesProvider).valueOrNull ?? [];

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Overall vs category toggle
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                  value: true,
                  label: Text('Overall'),
                  icon: Icon(Icons.pie_chart_rounded)),
              ButtonSegment(
                  value: false,
                  label: Text('Category'),
                  icon: Icon(Icons.category_rounded)),
            ],
            selected: {_isOverall},
            onSelectionChanged: (s) => setState(() {
              _isOverall = s.first;
              _selectedCategoryId = null;
            }),
          ),
          const SizedBox(height: AppSpacing.md),

          // Amount
          AppTextField(
            controller: _amountCtrl,
            label: 'Budget Limit',
            hint: '0.00',
            prefixIcon: const Icon(Icons.attach_money_rounded),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Amount is required';
              final n = double.tryParse(v.replaceAll(',', ''));
              if (n == null || n <= 0) return 'Enter a valid positive amount';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Category grid (shown only for category budget)
          if (!_isOverall) ...[
            Text('Category',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
            const SizedBox(height: AppSpacing.xs),
            _CategoryPicker(
              categories: categories,
              selectedId: _selectedCategoryId,
              onSelected: (id) => setState(() => _selectedCategoryId = id),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Period selector
          Text('Period',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<BudgetPeriod>(
            segments: const [
              ButtonSegment(
                  value: BudgetPeriod.weekly, label: Text('Weekly')),
              ButtonSegment(
                  value: BudgetPeriod.monthly, label: Text('Monthly')),
              ButtonSegment(
                  value: BudgetPeriod.yearly, label: Text('Yearly')),
            ],
            selected: {_period},
            onSelectionChanged: (s) =>
                setState(() => _period = s.first),
          ),
          const SizedBox(height: AppSpacing.md),

          // Rollover toggle
          SwitchListTile(
            value: _rollover,
            onChanged: (v) => setState(() => _rollover = v),
            title: const Text('Roll over unspent budget'),
            subtitle: const Text(
                'Unused amount carries to the next period'),
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: AppSpacing.xl),

          AppButton(
            expanded: true,
            label: widget.existing == null ? 'Set Budget' : 'Save',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Text('No categories available');
    }
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: categories.map((cat) {
        final selected = cat.id == selectedId;
        return GestureDetector(
          onTap: () => onSelected(cat.id),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color:
                  selected ? cat.color.withAlpha(40) : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: selected
                    ? cat.color
                    : Theme.of(context).colorScheme.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon, size: 16, color: cat.color),
                const SizedBox(width: 4),
                Text(cat.name,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(
                          color: selected
                              ? cat.color
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
