import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/constants.dart';
import '../../../transactions/data/models/category_model.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/models/analytics_data.dart';

// ── Grouped expense list ──────────────────────────────────────────────────────
/// Day-wise groups with per-transaction rows.
/// Designed to be embedded inside a CustomScrollView as a sliver.

class GroupedExpenseList extends StatelessWidget {
  const GroupedExpenseList({
    super.key,
    required this.dayGroups,
    required this.monthGroups,
    required this.categoryMap,
    required this.currencySymbol,
    required this.period,
    required this.onCategoryTap,
  });

  final List<DayGroup> dayGroups;
  final List<MonthGroup> monthGroups;
  final Map<int, CategoryModel> categoryMap;
  final String currencySymbol;
  final AnalyticsPeriod period;
  final ValueChanged<int> onCategoryTap; // categoryId

  @override
  Widget build(BuildContext context) {
    if (period == AnalyticsPeriod.year) {
      return _buildMonthList(context);
    }
    return _buildDayList(context);
  }

  Widget _buildDayList(BuildContext context) {
    if (dayGroups.isEmpty) return const _EmptyTransactions();

    return Column(
      children: dayGroups.map((group) => _DayGroupTile(
        group: group,
        categoryMap: categoryMap,
        currencySymbol: currencySymbol,
        onCategoryTap: onCategoryTap,
      )).toList(),
    );
  }

  Widget _buildMonthList(BuildContext context) {
    if (monthGroups.isEmpty) return const _EmptyTransactions();

    return Column(
      children: monthGroups.map((group) => _MonthGroupTile(
        group: group,
        currencySymbol: currencySymbol,
      )).toList(),
    );
  }
}

// ── Day group tile ────────────────────────────────────────────────────────────

class _DayGroupTile extends StatelessWidget {
  const _DayGroupTile({
    required this.group,
    required this.categoryMap,
    required this.currencySymbol,
    required this.onCategoryTap,
  });

  final DayGroup group;
  final Map<int, CategoryModel> categoryMap;
  final String currencySymbol;
  final ValueChanged<int> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final expenses = group.transactions.where((t) => !t.isIncome).toList();
    if (expenses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, AppSpacing.md, AppSpacing.screenPadding, AppSpacing.xs),
          child: Row(
            children: [
              Text(
                _formatDate(group.date),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              if (group.totalExpense > 0)
                Text(
                  '-$currencySymbol${_fmt(group.totalExpense)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.expense.withAlpha(200),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        ),
        // Transaction rows
        ...expenses.map((tx) => _TransactionRow(
              transaction: tx,
              category: categoryMap[tx.categoryId],
              currencySymbol: currencySymbol,
              onCategoryTap: onCategoryTap,
            )),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (d == today) return 'TODAY';
    if (d == yesterday) return 'YESTERDAY';
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(2);
  }
}

// ── Transaction row ───────────────────────────────────────────────────────────

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.transaction,
    required this.category,
    required this.currencySymbol,
    required this.onCategoryTap,
  });

  final TransactionModel transaction;
  final CategoryModel? category;
  final String currencySymbol;
  final ValueChanged<int> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = category;
    final color = cat?.color ?? AppColors.categoryPalette[
        transaction.categoryId % AppColors.categoryPalette.length];
    final icon = cat?.icon ??
        const IconData(0xe25a, fontFamily: 'MaterialIcons');

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onCategoryTap(transaction.categoryId);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: 8,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(isDark ? 40 : 25),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.note?.isNotEmpty == true
                        ? transaction.note!
                        : (cat?.name ?? 'Transaction'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (transaction.note?.isNotEmpty == true &&
                      cat != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              transaction.isIncome
                  ? '+$currencySymbol${_fmt(transaction.amount)}'
                  : '-$currencySymbol${_fmt(transaction.amount)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: transaction.isIncome ? AppColors.income : AppColors.expense,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(2);
  }
}

// ── Month group tile (year view) ──────────────────────────────────────────────

class _MonthGroupTile extends StatelessWidget {
  const _MonthGroupTile({
    required this.group,
    required this.currencySymbol,
  });

  final MonthGroup group;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: 4,
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceElevatedDark
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            alignment: Alignment.center,
            child: Text(
              group.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${group.transactions.length} transactions',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (group.totalIncome > 0)
                      Text(
                        '+$currencySymbol${_fmt(group.totalIncome)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.income,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    if (group.totalIncome > 0 && group.totalExpense > 0)
                      const Text('  '),
                    if (group.totalExpense > 0)
                      Text(
                        '-$currencySymbol${_fmt(group.totalExpense)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.expense,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(2);
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceElevatedDark
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 28,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No expenses here',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different period',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
