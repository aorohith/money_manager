import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/providers/transaction_providers.dart';

class ReconciliationScreen extends ConsumerWidget {
  const ReconciliationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(reconciliationStateProvider);
    final currencySymbol =
        ref.watch(currencySymbolProvider).valueOrNull ?? '\$';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Reconciliation'),
            floating: true,
            snap: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            sliver: stateAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ShimmerBox(width: double.infinity, height: 84),
                  ),
                  childCount: 3,
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Text('Failed to load reconciliation: $e'),
              ),
              data: (state) {
                if (state.pending.isEmpty && state.history.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.verified_rounded,
                      title: 'All accounts are balanced ✓',
                      subtitle: 'No reconciliation needed right now.',
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildListDelegate([
                    if (state.pending.isNotEmpty) ...[
                      Text(
                        'Needs Reconciliation',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...state.pending.map(
                        (item) => _ReconciliationTile(
                          title: item.account.name,
                          calculated: item.calculatedBalance,
                          actual: item.actualBalance,
                          discrepancy: item.discrepancy,
                          currencySymbol: currencySymbol,
                          onTap: () => context.push(
                            '${AppRoutes.manageAccounts}/${item.account.id}',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (state.history.isNotEmpty) ...[
                      Text(
                        'Reconciliation History',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...state.history.map(
                        (item) => _ReconciliationTile(
                          title: item.account.name,
                          calculated: item.calculatedBalance,
                          actual: item.actualBalance,
                          discrepancy: item.discrepancy,
                          currencySymbol: currencySymbol,
                          resolved: true,
                          onTap: () => context.push(
                            '${AppRoutes.manageAccounts}/${item.account.id}',
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReconciliationTile extends StatelessWidget {
  const _ReconciliationTile({
    required this.title,
    required this.calculated,
    required this.actual,
    required this.discrepancy,
    required this.currencySymbol,
    required this.onTap,
    this.resolved = false,
  });

  final String title;
  final double calculated;
  final double actual;
  final double discrepancy;
  final String currencySymbol;
  final VoidCallback onTap;
  final bool resolved;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (resolved)
                const Icon(Icons.check_circle_rounded, color: AppColors.income),
              if (!resolved) const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            label: 'Calculated',
            value: AppFormatters.currency(calculated, currencySymbol),
          ),
          const SizedBox(height: AppSpacing.xs),
          _InfoRow(
            label: 'Actual',
            value: AppFormatters.currency(actual, currencySymbol),
          ),
          const SizedBox(height: AppSpacing.xs),
          _InfoRow(
            label: 'Gap',
            value: AppFormatters.currency(discrepancy.abs(), currencySymbol),
            valueColor: resolved ? AppColors.income : AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
