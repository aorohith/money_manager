import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/providers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/add_transaction_sheet.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';
import '../../domain/models/analytics_data.dart';
import '../../domain/providers/analytics_providers.dart'
    show
        CategoryDetailParams,
        categoryDetailProvider,
        periodLabel;

class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.analyticsParams,
  });

  final int categoryId;
  final AnalyticsParams analyticsParams;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = CategoryDetailParams(
      categoryId: categoryId,
      analyticsParams: analyticsParams,
    );
    final txAsync = ref.watch(categoryDetailProvider(params));
    final categoriesAsync = ref.watch(categoriesProvider);
    final currencySymbol =
        ref.watch(currencySymbolProvider).valueOrNull ?? '\$';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find the category model for name/icon/color
    final category = categoriesAsync.valueOrNull
        ?.where((c) => c.id == categoryId)
        .firstOrNull;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor:
                isDark ? AppColors.backgroundDark : AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                if (category != null) ...[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: category.color.withAlpha(isDark ? 40 : 25),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child:
                        Icon(category.icon, size: 15, color: category.color),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  category?.name ?? 'Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                color: isDark ? AppColors.outlineDark : AppColors.outline,
              ),
            ),
          ),

          // ── Period label ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                0,
              ),
              child: Text(
                periodLabel(analyticsParams),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // ── Stats card + list ──────────────────────────────────────────────
          txAsync.when(
            loading: () => SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const ShimmerLoader(
                    child: ShimmerBox(width: double.infinity, height: 84),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...List.generate(
                    4,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.xs),
                      child: ShimmerLoader(
                        child:
                            ShimmerBox(width: double.infinity, height: 64),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: EmptyState(
                icon: Icons.error_rounded,
                title: 'Something went wrong',
                subtitle: e.toString(),
              ),
            ),
            data: (txs) {
              if (txs.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'No transactions',
                    subtitle:
                        'No ${category?.name ?? 'category'} transactions for this period.',
                  ),
                );
              }

              final expense =
                  txs.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);
              final income =
                  txs.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
              final avg = txs.isEmpty ? 0.0 : expense / txs.where((t) => !t.isIncome).length;
              final largest = txs
                  .where((t) => !t.isIncome)
                  .fold<double>(0, (m, t) => t.amount > m ? t.amount : m);

              final catMap = {
                for (final c in categoriesAsync.valueOrNull ?? []) c.id: c
              };

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                  AppSpacing.screenPadding,
                  80,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Summary card ─────────────────────────────────────────
                    _SummaryCard(
                      txCount: txs.length,
                      expense: expense,
                      income: income,
                      avg: avg,
                      largest: largest,
                      currencySymbol: currencySymbol,
                      color: category?.color ?? AppColors.brand,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Section header ───────────────────────────────────────
                    Text(
                      'TRANSACTIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Transaction list ─────────────────────────────────────
                    ..._groupByDate(txs).map((entry) {
                      if (entry is DateTime) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: AppSpacing.sm, bottom: AppSpacing.xs),
                          child: Text(
                            AppFormatters.groupDate(entry),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      final tx = entry as TransactionModel;
                      return TransactionTile(
                        transaction: tx,
                        category: catMap[tx.categoryId],
                        currencySymbol: currencySymbol,
                        onTap: () =>
                            showAddTransactionSheet(context, existing: tx),
                        onDismissed: () => ref
                            .read(deleteTransactionUseCaseProvider)(tx.id),
                      );
                    }),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Groups transactions into alternating [DateTime] headers + [TransactionModel].
  List<Object> _groupByDate(List<TransactionModel> txs) {
    final sorted = [...txs]..sort((a, b) => b.date.compareTo(a.date));
    final result = <Object>[];
    DateTime? last;
    for (final tx in sorted) {
      final d = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (last == null || d != last) {
        result.add(d);
        last = d;
      }
      result.add(tx);
    }
    return result;
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.txCount,
    required this.expense,
    required this.income,
    required this.avg,
    required this.largest,
    required this.currencySymbol,
    required this.color,
    required this.isDark,
  });

  final int txCount;
  final double expense;
  final double income;
  final double avg;
  final double largest;
  final String currencySymbol;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surf = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.outlineDark : AppColors.outline;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total spent',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                AppFormatters.currency(expense, currencySymbol),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Divider(),
          const SizedBox(height: AppSpacing.xs),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  label: 'Transactions',
                  value: '$txCount',
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _StatCell(
                  label: 'Average',
                  value: AppFormatters.currency(avg, currencySymbol),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _StatCell(
                  label: 'Largest',
                  value: AppFormatters.currency(largest, currencySymbol),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if (income > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            const Divider(),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Income in this category',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  '+${AppFormatters.currency(income, currencySymbol)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
