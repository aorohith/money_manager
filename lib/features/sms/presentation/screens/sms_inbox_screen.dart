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
import '../widgets/new_merchant_sheet.dart';

class SmsInboxScreen extends ConsumerWidget {
  const SmsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(smsPendingProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('SMS Inbox'),
            floating: true,
            snap: true,
            actions: [
              pendingAsync.maybeWhen(
                data: (list) => list.isEmpty
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: () =>
                            _skipAll(context, ref, list),
                        child: Text(
                          'Skip all',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          pendingAsync.when(
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brand),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (pending) {
              if (pending.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: EmptyState(
                      icon: Icons.mark_email_read_outlined,
                      title: 'All caught up!',
                      subtitle:
                          'New bank transactions will appear here automatically.',
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final item = pending[i];
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm),
                        child: _SmsTransactionTile(
                          item: item,
                          categories:
                              categoriesAsync.valueOrNull ?? [],
                          onApprove: (categoryId) =>
                              _approve(context, ref, item, categoryId),
                          onSkip: () => _skip(ref, item),
                          onTap: () => _openMerchantSheet(
                              context, ref, item),
                        ),
                      );
                    },
                    childCount: pending.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    SmsParsedTransaction item,
    int categoryId,
  ) async {
    HapticFeedback.mediumImpact();
    final repo = ref.read(smsRepositoryProvider);
    final accounts = await ref.read(accountsProvider.future);
    final account = accounts.firstOrNull;
    if (account == null) return;

    final tx = TransactionModel(
      amount: item.amount,
      categoryId: categoryId,
      accountId: account.id,
      date: item.transactionDate,
      isIncome: false,
      note: item.merchantRaw,
    );

    // Single atomic write: transaction + SMS status update
    await repo.approveTransaction(smsId: item.id, tx: tx);

    if (context.mounted) {
      showAppSnackBar(context,
          message: '₹${item.amount.toStringAsFixed(0)} saved',
          type: AppSnackBarType.success);
    }
  }

  Future<void> _skip(WidgetRef ref, SmsParsedTransaction item) async {
    HapticFeedback.selectionClick();
    await ref
        .read(smsRepositoryProvider)
        .updateStatus(item.id, SmsReviewStatus.skipped);
  }

  Future<void> _skipAll(
    BuildContext context,
    WidgetRef ref,
    List<SmsParsedTransaction> items,
  ) async {
    HapticFeedback.mediumImpact();
    final repo = ref.read(smsRepositoryProvider);
    for (final item in items) {
      await repo.updateStatus(item.id, SmsReviewStatus.skipped);
    }
    if (context.mounted) {
      showAppSnackBar(context,
          message: '${items.length} transactions skipped');
    }
  }

  Future<void> _openMerchantSheet(
    BuildContext context,
    WidgetRef ref,
    SmsParsedTransaction item,
  ) async {
    await showNewMerchantSheet(context, pending: item);
  }
}

// ── SMS Transaction Tile ──────────────────────────────────────────────────────

class _SmsTransactionTile extends StatelessWidget {
  const _SmsTransactionTile({
    required this.item,
    required this.categories,
    required this.onApprove,
    required this.onSkip,
    required this.onTap,
  });

  final SmsParsedTransaction item;
  final List<CategoryModel> categories;
  final ValueChanged<int> onApprove;
  final VoidCallback onSkip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = categories
        .where((c) => c.id == item.suggestedCategoryId)
        .firstOrNull;
    final confidence = item.confidence ?? 0.0;
    final isHighConfidence = confidence >= 0.75;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (cat?.color ?? AppColors.brand).withAlpha(20),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  cat?.icon ?? Icons.receipt_outlined,
                  size: 18,
                  color: cat?.color ?? AppColors.brand,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.merchantNormalized,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          item.paymentMethod,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                        ),
                        if (item.accountHint != null) ...[
                          Text(
                            ' · ${item.accountHint}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${item.amount.toStringAsFixed(0)}',
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.expense,
                            ),
                  ),
                  if (cat != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cat.color.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        cat.name,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: cat.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Confidence indicator (only show when low)
          if (!isHighConfidence) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Suggested — tap to change category',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.sm),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSkip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.outlineDark
                          : AppColors.outline,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                  child: const Text('Skip',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: item.suggestedCategoryId != null
                      ? () => onApprove(item.suggestedCategoryId!)
                      : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                  child: Text(
                    isHighConfidence
                        ? '✓ Save as ${cat?.name ?? "Expense"}'
                        : 'Classify',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
