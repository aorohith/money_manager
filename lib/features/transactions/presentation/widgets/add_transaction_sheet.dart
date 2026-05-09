import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/providers/transaction_providers.dart';
import 'add_edit_category_sheet.dart';

/// Shows the Add / Edit Transaction bottom sheet.
Future<void> showAddTransactionSheet(
  BuildContext context, {
  TransactionModel? existing,
}) {
  return showAppBottomSheet(
    context: context,
    title: existing == null ? 'Add Transaction' : 'Edit Transaction',
    maxHeightFraction: 0.92,
    child: _AddTransactionForm(existing: existing),
  );
}

class _AddTransactionForm extends ConsumerStatefulWidget {
  const _AddTransactionForm({this.existing});
  final TransactionModel? existing;

  @override
  ConsumerState<_AddTransactionForm> createState() =>
      _AddTransactionFormState();
}

class _AddTransactionFormState extends ConsumerState<_AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late bool _isIncome;
  late DateTime _date;
  int? _selectedCategoryId;
  int? _selectedAccountId;
  RecurrenceType _recurrence = RecurrenceType.none;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _isIncome = e?.isIncome ?? false;
    _date = e?.date ?? DateTime.now();
    _selectedCategoryId = e?.categoryId;
    _selectedAccountId = e?.accountId;
    _recurrence = e?.recurrence ?? RecurrenceType.none;
    if (e != null) {
      _amountCtrl.text = e.amount.toStringAsFixed(2);
      _noteCtrl.text = e.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategoryId == null) {
      showAppSnackBar(
        context,
        message: 'Please select a category',
        type: AppSnackBarType.error,
      );
      return;
    }
    if (_selectedAccountId == null) {
      showAppSnackBar(
        context,
        message: 'Please select an account',
        type: AppSnackBarType.error,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final tx =
          widget.existing ??
          TransactionModel(
            amount: 0,
            categoryId: 0,
            accountId: 0,
            date: DateTime.now(),
            isIncome: false,
          );

      tx
        ..amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0
        ..categoryId = _selectedCategoryId!
        ..accountId = _selectedAccountId!
        ..date = _date
        ..isIncome = _isIncome
        ..note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim()
        ..recurrence = _recurrence;

      if (widget.existing == null) {
        await ref.read(addTransactionUseCaseProvider)(tx);
      } else {
        await ref.read(editTransactionUseCaseProvider)(tx);
      }

      if (mounted) {
        Navigator.of(context).pop();
        showAppSnackBar(
          context,
          message: widget.existing == null
              ? 'Transaction added'
              : 'Transaction updated',
          type: AppSnackBarType.success,
        );
      }
    } catch (e) {
      // Reset loading state so the user can retry — without this the button
      // stays in a spinner indefinitely after an error.
      if (mounted) {
        setState(() => _loading = false);
        showAppSnackBar(
          context,
          message: 'Something went wrong. Please try again.',
          type: AppSnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final accounts = ref.watch(accountsProvider).valueOrNull ?? [];

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Income / Expense toggle
          Semantics(
            label: _isIncome ? 'Income selected' : 'Expense selected',
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward_rounded),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward_rounded),
                ),
              ],
              selected: {_isIncome},
              onSelectionChanged: (s) => setState(() {
                // Update the transaction type AND clear the category
                // selection — categories are filtered by income/expense,
                // so the previous selection would be invalid after switch.
                _isIncome = s.first;
                _selectedCategoryId = null;
              }),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Amount
          AppTextField(
            controller: _amountCtrl,
            label: 'Amount',
            hint: '0.00',
            prefixIcon: const Icon(Icons.attach_money_rounded),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            textInputAction: TextInputAction.next,
            semanticLabel: 'Transaction amount',
            validator: (v) {
              if (v == null || v.isEmpty) return 'Amount is required';
              final n = double.tryParse(v.replaceAll(',', ''));
              if (n == null || n <= 0) {
                return 'Enter a valid positive amount';
              }
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Category selector
          Row(
            children: [
              const Expanded(child: _SectionLabel('Category')),
              TextButton.icon(
                onPressed: () => showAddEditCategorySheet(
                  context,
                  initialIsIncome: _isIncome,
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Category'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildCategoryGrid(
            categories.where((c) => c.isIncome == _isIncome).toList(),
          ),

          const SizedBox(height: AppSpacing.md),

          // Date picker
          _SectionLabel('Date'),
          const SizedBox(height: AppSpacing.xs),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_date.day}/${_date.month}/${_date.year}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Account selector
          _SectionLabel('Account'),
          const SizedBox(height: AppSpacing.xs),
          if (accounts.isEmpty)
            const Text('No accounts found')
          else
            Wrap(
              spacing: AppSpacing.sm,
              children: accounts.map((acc) {
                final selected = acc.id == _selectedAccountId;
                return ChoiceChip(
                  label: Text(acc.name),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedAccountId = acc.id),
                );
              }).toList(),
            ),

          const SizedBox(height: AppSpacing.md),

          // Note
          AppTextField(
            controller: _noteCtrl,
            label: 'Note (optional)',
            hint: 'Add a note…',
            prefixIcon: const Icon(Icons.notes_rounded),
            maxLines: 2,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: AppSpacing.md),

          // Recurrence
          _SectionLabel('Recurrence'),
          const SizedBox(height: AppSpacing.xs),
          InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.repeat_rounded),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<RecurrenceType>(
                value: _recurrence,
                isExpanded: true,
                items: RecurrenceType.values
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(_recurrenceLabel(r)),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _recurrence = v ?? RecurrenceType.none),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          AppButton(
            expanded: true,
            label: widget.existing == null ? 'Add Transaction' : 'Save',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(List cats) {
    if (cats.isEmpty) {
      return const Text('No categories available');
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        mainAxisSpacing: AppSpacing.xs,
        crossAxisSpacing: AppSpacing.xs,
      ),
      itemCount: cats.length,
      itemBuilder: (_, i) {
        final cat = cats[i];
        final selected = cat.id == _selectedCategoryId;
        return Semantics(
          label: cat.name,
          button: true,
          selected: selected,
          child: GestureDetector(
            onTap: () => setState(() => _selectedCategoryId = cat.id),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              decoration: BoxDecoration(
                color: selected ? cat.color.withAlpha(50) : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: selected
                    ? Border.all(color: cat.color, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.icon, color: cat.color, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    cat.name,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected
                          ? cat.color
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  String _recurrenceLabel(RecurrenceType r) => switch (r) {
    RecurrenceType.none => 'One-time',
    RecurrenceType.daily => 'Daily',
    RecurrenceType.weekly => 'Weekly',
    RecurrenceType.monthly => 'Monthly',
    RecurrenceType.yearly => 'Yearly',
  };
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
