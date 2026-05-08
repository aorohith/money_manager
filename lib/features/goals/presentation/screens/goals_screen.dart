import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/providers/goal_providers.dart';
import '../widgets/add_goal_sheet.dart';
import '../widgets/goal_card.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Goals'),
            floating: true,
            snap: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add goal',
                onPressed: () => showAddGoalSheet(context),
              ),
            ],
          ),
          goalsAsync.when(
            loading: () => _buildLoading(),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (goals) {
              if (goals.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.flag_rounded,
                    title: 'No goals yet',
                    subtitle: 'Set a savings goal to start tracking your progress',
                    actionLabel: 'Add Goal',
                    action: () => showAddGoalSheet(context),
                  ),
                );
              }

              final active = goals.where((g) => !g.isCompleted).toList();
              final completed = goals.where((g) => g.isCompleted).toList();

              return SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (active.isNotEmpty) ...[
                      Text('Active Goals',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.md),
                      ...active.map((g) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: GoalCard(
                              goal: g,
                              onTap: () => context.go(
                                  '${AppRoutes.goals}/${g.id}'),
                            ),
                          )),
                    ],
                    if (completed.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text('Completed',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.md),
                      ...completed.map((g) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: GoalCard(
                              goal: g,
                              onTap: () => context.go(
                                  '${AppRoutes.goals}/${g.id}'),
                            ),
                          )),
                    ],
                  ]),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          showAddGoalSheet(context);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Goal'),
      ),
    );
  }

  Widget _buildLoading() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          ShimmerBox(width: double.infinity, height: 120),
          const SizedBox(height: AppSpacing.md),
          ShimmerBox(width: double.infinity, height: 120),
        ]),
      ),
    );
  }
}
