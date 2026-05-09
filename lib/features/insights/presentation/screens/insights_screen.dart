import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/providers/insights_providers.dart';
import '../widgets/spending_trend_chart.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Insights'),
            floating: true,
            snap: true,
          ),
          insightsAsync.when(
            loading: () => _buildLoading(),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (data) {
              if (!data.hasData) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.insights_rounded,
                    title: 'No insights yet',
                    subtitle:
                        'Add some transactions to see your spending insights',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Spending trend chart
                    _SpendingTrendCard(data: data),
                    const SizedBox(height: AppSpacing.md),

                    // Spending change
                    _SpendingChangeCard(data: data),
                    const SizedBox(height: AppSpacing.md),

                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStatCard(
                            title: 'Savings Rate',
                            value:
                                '${data.savingsRate.toStringAsFixed(0)}%',
                            icon: Icons.savings_rounded,
                            color: data.savingsRate >= 0
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _MiniStatCard(
                            title: 'Daily Avg',
                            value:
                                '\$${data.dailyAverage.toStringAsFixed(0)}',
                            icon: Icons.trending_flat_rounded,
                            color: AppColors.brand,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Top categories
                    if (data.topCategories.isNotEmpty) ...[
                      Text('Top Spending Categories',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.md),
                      ...data.topCategories.map(
                        (cat) => _CategoryRow(cat: cat),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          ShimmerBox(width: double.infinity, height: 200),
          const SizedBox(height: AppSpacing.md),
          ShimmerBox(width: double.infinity, height: 80),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(
                child: ShimmerBox(width: double.infinity, height: 100)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: ShimmerBox(width: double.infinity, height: 100)),
          ]),
        ]),
      ),
    );
  }
}

// ── Spending trend card ───────────────────────────────────────────────────────

class _SpendingTrendCard extends StatelessWidget {
  const _SpendingTrendCard({required this.data});
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending Trend',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'This month',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 160,
              child: SpendingTrendChart(
                dailySpending: data.dailySpending,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Spending change card ──────────────────────────────────────────────────────

class _SpendingChangeCard extends StatelessWidget {
  const _SpendingChangeCard({required this.data});
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final up = data.spendingUp;
    final color = up ? AppColors.expense : AppColors.income;
    final icon = up
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    final label = up ? 'more' : 'less';

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending is ${data.spendingChangePercent.abs().toStringAsFixed(0)}% $label',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'compared to last month',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$${data.totalExpenseThisPeriod.toStringAsFixed(0)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini stat card ────────────────────────────────────────────────────────────

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                )),
            Text(title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Category row ──────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.cat});
  final dynamic cat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (cat.color as Color).withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(cat.icon as IconData,
                    color: cat.color as Color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name as String,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                      child: LinearProgressIndicator(
                        value: (cat.percentage as double) / 100,
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                            cat.color as Color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${(cat.amount as double).toStringAsFixed(0)}',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text('${(cat.percentage as double).toStringAsFixed(0)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
