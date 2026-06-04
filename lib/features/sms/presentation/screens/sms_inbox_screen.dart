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
import '../widgets/sms_message_reference.dart';

class SmsInboxScreen extends ConsumerWidget {
  const SmsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(smsPendingProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final settingsAsync = ref.watch(smsSettingsProvider);
    final threshold =
        (settingsAsync.valueOrNull?.confidenceThreshold ?? 75) / 100.0;
    final showParseDebug = settingsAsync.valueOrNull?.showParseDebug ?? false;
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
                data: (list) {
                  if (list.isEmpty) return const SizedBox.shrink();
                  final highConfidence = list.where((item) {
                    final catConf = item.confidence ?? 0.0;
                    final dirConf = item.directionConfidence ?? 0.0;
                    return catConf >= threshold &&
                        dirConf >= threshold &&
                        item.suggestedCategoryId != null;
                  }).toList();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (highConfidence.isNotEmpty)
                        TextButton(
                          onPressed: () => _approveHighConfidence(
                            context,
                            ref,
                            highConfidence,
                          ),
                          child: Text(
                            'Approve ${highConfidence.length}',
                            style: TextStyle(
                              color: AppColors.brand,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      TextButton(
                        onPressed: () => _skipAll(context, ref, list),
                        child: Text(
                          'Skip all',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
            error: (e, _) =>
                SliverFillRemaining(child: Center(child: Text('Error: $e'))),
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
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final item = pending[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AnimatedListItem(
                        index: i,
                        child: _SmsTransactionTile(
                          item: item,
                          categories: categoriesAsync.valueOrNull ?? [],
                          confidenceThreshold: threshold,
                          showParseDebug: showParseDebug,
                          onApprove: (categoryId) =>
                              _approve(context, ref, item, categoryId),
                          onSkip: () => _skip(ref, item),
                          onTap: () => _openMerchantSheet(context, ref, item),
                        ),
                      ),
                    );
                  }, childCount: pending.length),
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
      isIncome: item.isIncome,
      note: item.merchantRaw,
    );

    // Single atomic write: transaction + SMS status update
    final txId = await repo.approveTransaction(smsId: item.id, tx: tx);

    if (context.mounted) {
      showAppSnackBar(
        context,
        message: '₹${item.amount.toStringAsFixed(0)} saved',
        type: AppSnackBarType.success,
        actionLabel: 'UNDO',
        onAction: () => _undoApproval(context, ref, item, txId),
      );
    }
  }

  Future<void> _undoApproval(
    BuildContext context,
    WidgetRef ref,
    SmsParsedTransaction item,
    int transactionId,
  ) async {
    HapticFeedback.selectionClick();
    await ref
        .read(smsRepositoryProvider)
        .undoApproval(
          smsId: item.id,
          transactionId: transactionId,
          rawText: item.rawText,
        );

    if (context.mounted) {
      showAppSnackBar(
        context,
        message: 'Transaction moved back to review',
        type: AppSnackBarType.info,
      );
    }
  }

  Future<void> _skip(WidgetRef ref, SmsParsedTransaction item) async {
    HapticFeedback.selectionClick();
    await ref
        .read(smsRepositoryProvider)
        .updateStatus(item.id, SmsReviewStatus.skipped);
  }

  Future<void> _approveHighConfidence(
    BuildContext context,
    WidgetRef ref,
    List<SmsParsedTransaction> items,
  ) async {
    HapticFeedback.mediumImpact();
    final accounts = await ref.read(accountsProvider.future);
    final account = accounts.where((a) => a.isDefault).firstOrNull ??
        accounts.firstOrNull;
    if (account == null) return;

    var saved = 0;
    for (final item in items) {
      final categoryId = item.suggestedCategoryId;
      if (categoryId == null) continue;
      await ref.read(smsRepositoryProvider).approveTransaction(
            smsId: item.id,
            tx: TransactionModel(
              amount: item.amount,
              categoryId: categoryId,
              accountId: account.id,
              date: item.transactionDate,
              isIncome: item.isIncome,
              note: item.merchantRaw,
            ),
          );
      saved++;
    }
    if (context.mounted && saved > 0) {
      showAppSnackBar(
        context,
        message: '$saved transaction${saved == 1 ? '' : 's'} saved',
        type: AppSnackBarType.success,
      );
    }
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
      showAppSnackBar(context, message: '${items.length} transactions skipped');
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

class _SmsTransactionTile extends StatefulWidget {
  const _SmsTransactionTile({
    required this.item,
    required this.categories,
    required this.confidenceThreshold,
    required this.showParseDebug,
    required this.onApprove,
    required this.onSkip,
    required this.onTap,
  });

  final SmsParsedTransaction item;
  final List<CategoryModel> categories;
  final double confidenceThreshold;
  final bool showParseDebug;
  final ValueChanged<int> onApprove;
  final VoidCallback onSkip;
  final VoidCallback onTap;

  @override
  State<_SmsTransactionTile> createState() => _SmsTransactionTileState();
}

class _SmsTransactionTileState extends State<_SmsTransactionTile> {
  bool _animatingSkip = false;
  bool _animatingClassify = false;

  Future<void> _animateSkip() async {
    if (_animatingSkip || _animatingClassify) return;
    setState(() => _animatingSkip = true);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    widget.onSkip();
    setState(() => _animatingSkip = false);
  }

  Future<void> _animateClassify() async {
    if (_animatingSkip || _animatingClassify) return;
    setState(() => _animatingClassify = true);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    final categoryConfidence = widget.item.confidence ?? 0.0;
    final directionConfidence = widget.item.directionConfidence ?? 0.0;
    final canQuickSave =
        categoryConfidence >= 0.75 && directionConfidence >= 0.75;
    final suggestedCategoryId = widget.item.suggestedCategoryId;
    if (suggestedCategoryId != null && canQuickSave) {
      widget.onApprove(suggestedCategoryId);
    } else {
      widget.onTap();
    }
    setState(() => _animatingClassify = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = widget.categories
        .where((c) => c.id == widget.item.suggestedCategoryId)
        .firstOrNull;
    final confidence = widget.item.confidence ?? 0.0;
    final directionConfidence = widget.item.directionConfidence ?? 0.0;
    final isHighConfidence = confidence >= widget.confidenceThreshold;
    final canQuickSave =
        isHighConfidence && directionConfidence >= widget.confidenceThreshold;
    final isAnimating = _animatingSkip || _animatingClassify;

    return AnimatedScale(
      scale: isAnimating ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isAnimating ? 0.78 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AppCard(
          onTap: isAnimating ? null : widget.onTap,
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
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
                          widget.item.merchantNormalized,
                          style: Theme.of(context).textTheme.labelMedium
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
                              widget.item.paymentMethod,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                            ),
                            if (widget.item.accountHint != null) ...[
                              Text(
                                ' · ${widget.item.accountHint}',
                                style: Theme.of(context).textTheme.labelSmall
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
                        '₹${widget.item.amount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: widget.item.isIncome
                                  ? AppColors.income
                                  : AppColors.expense,
                            ),
                      ),
                            if (cat != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: cat.color.withAlpha(20),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  cat.name,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: cat.color,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: (widget.item.isIncome
                                          ? AppColors.income
                                          : AppColors.expense)
                                      .withAlpha(20),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.item.isIncome ? 'Income' : 'Expense',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: widget.item.isIncome
                                            ? AppColors.income
                                            : AppColors.expense,
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
              if (!canQuickSave) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        directionConfidence < widget.confidenceThreshold
                            ? 'Confirm expense or income before saving'
                            : 'Suggested — tap to change category',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              if (widget.item.isRecurring) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Likely subscription / recurring',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.brand,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],

              if (widget.showParseDebug &&
                  (widget.item.directionSignals?.isNotEmpty ?? false)) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Signals: ${widget.item.directionSignals}'
                  '${widget.item.merchantExtractionSource != null ? ' · ${widget.item.merchantExtractionSource}' : ''}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              if (widget.item.rawText.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                SmsMessageReference(
                  key: Key('sms_ref_${widget.item.id}'),
                  rawText: widget.item.rawText,
                  senderAddress: widget.item.senderAddress,
                  expandable: true,
                  initiallyExpanded: false,
                ),
              ],

              const SizedBox(height: AppSpacing.sm),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: AnimatedScale(
                      scale: _animatingSkip ? 0.94 : 1,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOutCubic,
                      child: OutlinedButton(
                        onPressed: isAnimating ? null : _animateSkip,
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
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 120),
                          child: _animatingSkip
                              ? const SizedBox(
                                  key: ValueKey('skip-progress'),
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  key: ValueKey('skip-label'),
                                  'Skip',
                                  style: TextStyle(fontSize: 13),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: AnimatedScale(
                      scale: _animatingClassify ? 0.96 : 1,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOutCubic,
                      child: ElevatedButton(
                        onPressed: isAnimating ? null : _animateClassify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 120),
                          child: _animatingClassify
                              ? const SizedBox(
                                  key: ValueKey('classify-progress'),
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  key: const ValueKey('classify-label'),
                                  canQuickSave
                                      ? '✓ Save as ${cat?.name ?? (widget.item.isIncome ? "Income" : "Expense")}'
                                      : 'Classify',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
