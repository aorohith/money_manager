import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/providers/analytics_providers.dart';
import '../widgets/category_bar_list.dart';
import '../widgets/date_navigator.dart';
import '../widgets/donut_chart.dart';
import '../widgets/grouped_expense_list.dart';
import '../widgets/period_selector.dart';

// ── Local state ───────────────────────────────────────────────────────────────

final _selectedDonutIndexProvider = StateProvider<int?>((_) => null);
final _isListViewProvider = StateProvider<bool>((_) => false);

// ── Analytics screen ──────────────────────────────────────────────────────────

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(analyticsParamsProvider);
    final analyticsAsync = ref.watch(analyticsProvider(params));
    final isListView = ref.watch(_isListViewProvider);
    final currencySymbol =
        ref.watch(currencySymbolProvider).valueOrNull ?? '\$';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor:
                isDark ? AppColors.backgroundDark : AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Analytics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              // Chart ↔ List view toggle
              Semantics(
                button: true,
                label: isListView ? 'Switch to chart view' : 'Switch to list view',
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(_isListViewProvider.notifier).state = !isListView;
                  },
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    width: 36,
                    height: 36,
                    margin:
                        const EdgeInsets.only(right: AppSpacing.screenPadding),
                    decoration: BoxDecoration(
                      color: isListView
                          ? AppColors.brand.withAlpha(isDark ? 40 : 20)
                          : (isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceVariant),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: isListView
                            ? AppColors.brand.withAlpha(80)
                            : (isDark
                                ? AppColors.outlineDark
                                : AppColors.outline),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      isListView
                          ? Icons.donut_large_rounded
                          : Icons.list_rounded,
                      size: 18,
                      color: isListView
                          ? AppColors.brand
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky controls ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                const PeriodSelector(),
                const SizedBox(height: AppSpacing.sm),
                const DateNavigator(),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),

          // ── Balance summary ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: analyticsAsync.when(
              data: (data) => _CompactBalanceSummary(
                data: data,
                currencySymbol: currencySymbol,
                isDark: isDark,
              ),
              loading: () => _BalanceSkeleton(isDark: isDark),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // ── Chart section (hidden in list view) ───────────────────────────────
          if (!isListView)
            SliverToBoxAdapter(
              child: analyticsAsync.when(
                data: (data) => _ChartSection(
                  data: data,
                  currencySymbol: currencySymbol,
                  isDark: isDark,
                  onCategoryDrillDown: (categoryId) =>
                      _goToCategoryDetail(context, categoryId, params),
                ),
                loading: () => _ChartSkeleton(isDark: isDark),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

          // ── Transactions header ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: analyticsAsync.maybeWhen(
              data: (data) => data.isEmpty
                  ? const SizedBox.shrink()
                  : _SectionHeader(title: 'Transactions', isDark: isDark),
              orElse: () => const SizedBox.shrink(),
            ),
          ),

          // ── Transaction list ──────────────────────────────────────────────────
          analyticsAsync.when(
            data: (data) {
              if (data.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyState(isDark: isDark),
                );
              }
              return SliverToBoxAdapter(
                child: GroupedExpenseList(
                  dayGroups: data.dayGroups,
                  monthGroups: data.monthGroups,
                  categoryMap: data.categoryMap,
                  currencySymbol: currencySymbol,
                  period: params.period,
                  onCategoryTap: (categoryId) =>
                      _goToCategoryDetail(context, categoryId, params),
                ),
              );
            },
            loading: () =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Unable to load data',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _goToCategoryDetail(
      BuildContext context, int categoryId, AnalyticsParams params) {
    context.push(
      '${AppRoutes.analytics}/category/$categoryId',
      extra: params,
    );
  }
}

// ── Compact balance summary ───────────────────────────────────────────────────

class _CompactBalanceSummary extends StatelessWidget {
  const _CompactBalanceSummary({
    required this.data,
    required this.currencySymbol,
    required this.isDark,
  });

  final AnalyticsData data;
  final String currencySymbol;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0,
          AppSpacing.screenPadding, AppSpacing.md),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding, vertical: 12),
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
          Expanded(
            child: _BalancePill(
              label: 'Income',
              amount: data.totalIncome,
              symbol: currencySymbol,
              color: AppColors.income,
              icon: Icons.arrow_downward_rounded,
              isDark: isDark,
            ),
          ),
          Container(
              width: 1,
              height: 32,
              color: isDark ? AppColors.outlineDark : AppColors.outline),
          Expanded(
            child: _BalancePill(
              label: 'Expense',
              amount: data.totalExpense,
              symbol: currencySymbol,
              color: AppColors.expense,
              icon: Icons.arrow_upward_rounded,
              isDark: isDark,
            ),
          ),
          Container(
              width: 1,
              height: 32,
              color: isDark ? AppColors.outlineDark : AppColors.outline),
          Expanded(
            child: _BalancePill(
              label: 'Net',
              amount: data.netBalance,
              symbol: currencySymbol,
              color: data.netBalance >= 0
                  ? AppColors.income
                  : AppColors.expense,
              icon: data.netBalance >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalancePill extends StatelessWidget {
  const _BalancePill({
    required this.label,
    required this.amount,
    required this.symbol,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final double amount;
  final String symbol;
  final Color color;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '$symbol${_fmt(amount.abs())}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Chart section ─────────────────────────────────────────────────────────────

class _ChartSection extends ConsumerWidget {
  const _ChartSection({
    required this.data,
    required this.currencySymbol,
    required this.isDark,
    required this.onCategoryDrillDown,
  });

  final AnalyticsData data;
  final String currencySymbol;
  final bool isDark;
  final ValueChanged<int> onCategoryDrillDown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(_selectedDonutIndexProvider);

    if (data.categorySummaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final useDonut = data.categorySummaries.length <= 7;

    return Column(
      children: [
        if (useDonut) ...[
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: AnimatedDonutChart(
              categories: data.categorySummaries,
              totalExpense: data.totalExpense,
              selectedIndex: selectedIndex,
              size: 200,
              onTap: (i) {
                ref.read(_selectedDonutIndexProvider.notifier).state = i;
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        // Category breakdown header
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0,
              AppSpacing.screenPadding, AppSpacing.xs),
          child: Row(
            children: [
              Text(
                'CATEGORIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Builder(
                builder: (context) => Text(
                  AppLocalizations.of(context)
                      .categoriesCount(data.categorySummaries.length),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
        CategoryBarList(
          categories: data.categorySummaries,
          currencySymbol: currencySymbol,
          selectedIndex: selectedIndex,
          onTap: (i) {
            // First tap: highlight; second tap same: drill-down
            if (selectedIndex == i) {
              onCategoryDrillDown(data.categorySummaries[i].categoryId);
            } else {
              ref.read(_selectedDonutIndexProvider.notifier).state = i;
            }
          },
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color:
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Skeletons ─────────────────────────────────────────────────────────────────

class _BalanceSkeleton extends StatelessWidget {
  const _BalanceSkeleton({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0,
          AppSpacing.screenPadding, AppSpacing.md),
      height: 58,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceVariant;
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        ),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(
          3,
          (i) => Container(
            margin: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0,
                AppSpacing.screenPadding, 10),
            height: 52,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceElevatedDark
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                size: 32,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No data for this period',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add transactions to see your\nspending breakdown',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
