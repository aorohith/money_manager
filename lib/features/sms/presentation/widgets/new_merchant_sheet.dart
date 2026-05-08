import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../transactions/data/models/category_model.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/providers/transaction_providers.dart';
import '../../data/models/sms_parsed_transaction.dart';
import '../../domain/providers/sms_providers.dart';

/// Bottom sheet shown when a new / unknown merchant is detected.
/// Lets the user pick a category and optionally create a persistent rule.
Future<bool?> showNewMerchantSheet(
  BuildContext context, {
  required SmsParsedTransaction pending,
}) {
  return showAppBottomSheet<bool>(
    context: context,
    title: 'New Payment Detected',
    child: _NewMerchantSheet(pending: pending),
  );
}

class _NewMerchantSheet extends ConsumerStatefulWidget {
  const _NewMerchantSheet({required this.pending});
  final SmsParsedTransaction pending;

  @override
  ConsumerState<_NewMerchantSheet> createState() => _NewMerchantSheetState();
}

class _NewMerchantSheetState extends ConsumerState<_NewMerchantSheet> {
  int? _selectedCategoryId;
  bool _alwaysApply = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.pending.suggestedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Amount + merchant banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.surfaceDark : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${widget.pending.amount.toStringAsFixed(0)}',
                  style:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.pending.merchantRaw,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.payment_rounded,
                        size: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      widget.pending.paymentMethod,
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          Text(
            'Select category',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Category grid
          categoriesAsync.when(
            data: (cats) => _CategoryGrid(
              categories: cats,
              selectedId: _selectedCategoryId,
              onSelected: (id) => setState(() => _selectedCategoryId = id),
              suggestedId: widget.pending.suggestedCategoryId,
            ),
            loading: () =>
                const ShimmerBox(width: double.infinity, height: 100, borderRadius: 12),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: AppSpacing.md),
          // "Always use this" toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remember for ${widget.pending.merchantNormalized}',
                      style:
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                    ),
                    Text(
                      'Future payments auto-categorised',
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _alwaysApply,
                onChanged: (v) => setState(() => _alwaysApply = v),
                activeThumbColor: AppColors.brand,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : _skip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    side: BorderSide(
                      color:
                          isDark ? AppColors.outlineDark : AppColors.outline,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    minimumSize: const Size(0, AppSpacing.buttonHeight),
                  ),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed:
                      (_selectedCategoryId == null || _saving) ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    minimumSize: const Size(0, AppSpacing.buttonHeight),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ],
    );
  }

  Future<void> _save() async {
    if (_selectedCategoryId == null) return;
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);

    final repo = ref.read(smsRepositoryProvider);
    final accounts = await ref.read(accountsProvider.future);
    final account = accounts.firstOrNull;

    if (account == null) {
      setState(() => _saving = false);
      return;
    }

    final pending = widget.pending;
    final tx = TransactionModel(
      amount: pending.amount,
      categoryId: _selectedCategoryId!,
      accountId: account.id,
      date: pending.transactionDate,
      isIncome: false,
      note: pending.merchantRaw,
    );

    // Single atomic write: transaction + SMS status + merchant rule
    await repo.approveTransaction(
      smsId: pending.id,
      tx: tx,
      merchantKey: pending.merchantNormalized,
      categoryId: _selectedCategoryId!,
      alwaysApply: _alwaysApply,
    );

    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _skip() async {
    HapticFeedback.selectionClick();
    final repo = ref.read(smsRepositoryProvider);
    await repo.updateStatus(widget.pending.id, SmsReviewStatus.skipped);
    if (mounted) Navigator.of(context).pop(false);
  }
}

// ── Category grid ─────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    this.suggestedId,
  });

  final List<CategoryModel> categories;
  final int? selectedId;
  final ValueChanged<int> onSelected;
  final int? suggestedId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: categories.map((cat) {
        final selected = cat.id == selectedId;
        final suggested = cat.id == suggestedId && !selected;
        return GestureDetector(
          onTap: () => onSelected(cat.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: selected
                  ? cat.color.withAlpha(30)
                  : isDark
                      ? AppColors.surfaceDark
                      : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: selected
                    ? cat.color
                    : suggested
                        ? cat.color.withAlpha(120)
                        : isDark
                            ? AppColors.outlineDark
                            : AppColors.outline,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon,
                    size: 14,
                    color: selected
                        ? cat.color
                        : isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  cat.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected
                            ? cat.color
                            : isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                      ),
                ),
                if (suggested && !selected) ...[
                  const SizedBox(width: 3),
                  Text(
                    '✦',
                    style: TextStyle(
                        fontSize: 8,
                        color: cat.color.withAlpha(180)),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
