import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../transactions/data/models/category_model.dart';
import '../../../transactions/domain/providers/transaction_providers.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';
import '../../domain/providers/budget_providers.dart';
import '../widgets/budget_card.dart';
import '../widgets/set_budget_sheet.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  late final PageController _pageCtrl;
  static const int _base = 600; // large middle value so we can go left/right

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: _base);

    // Over-budget listener wired after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenOverBudget();
    });
  }

  void _listenOverBudget() {
    ref.listenManual(
      transactionListProvider,
      (_, __) async {
        final month = ref.read(budgetSelectedMonthProvider);
        final progresses = await ref
            .read(budgetRepositoryProvider)
            .getBudgetsForMonth(month)
            .then((budgets) => Future.wait(
                  budgets.map(
                    (b) => ref
                        .read(budgetRepositoryProvider)
                        .getBudgetProgress(budget: b, month: month),
                  ),
                ));

        for (final p in progresses) {
          if (p.isOver && mounted) {
            final name =
                p.budget.categoryId == null ? 'Overall' : 'Category';
            showAppSnackBar(
              context,
              message:
                  '$name budget exceeded by \$${(-p.remaining).toStringAsFixed(0)}',
              type: AppSnackBarType.error,
              actionLabel: 'View',
            );
            break; // Show one at a time
          }
        }
      },
      fireImmediately: false,
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  int _pageToMonth(int page) {
    final now = DateTime.now();
    final offset = page - _base;
    final target = DateTime(now.year, now.month + offset, 1);
    return toMonthInt(target);
  }

  String _monthLabel(int month) {
    final year = month ~/ 100;
    final mo = month % 100;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    final suffix =
        (year != now.year) ? ' $year' : '';
    return '${months[mo]}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(budgetSelectedMonthProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Budgets'),
            floating: true,
            snap: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Set budget',
                onPressed: () => showSetBudgetSheet(context),
              ),
            ],
          ),

          // Month selector
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (page) {
                  HapticFeedback.selectionClick();
                  ref
                      .read(budgetSelectedMonthProvider.notifier)
                      .state = _pageToMonth(page);
                },
                itemBuilder: (_, page) {
                  final month = _pageToMonth(page);
                  final isSelected = month == selectedMonth;
                  return _MonthTab(
                    label: _monthLabel(month),
                    isSelected: isSelected,
                    onTap: () {
                      _pageCtrl.animateToPage(
                        page,
                        duration: AppDurations.standard,
                        curve: Curves.easeInOutCubic,
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Body content
          _BudgetBody(month: selectedMonth),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSetBudgetSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Set Budget'),
      ),
    );
  }
}

class _MonthTab extends StatelessWidget {
  const _MonthTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brand
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius:
              BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Body: watches providers for given month ────────────────────────────────

class _BudgetBody extends ConsumerWidget {
  const _BudgetBody({required this.month});
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(budgetProgressListProvider);
    final overallAsync = ref.watch(overallBudgetProgressProvider);

    return progressAsync.when(
      loading: () => _buildLoading(),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Error: $e')),
      ),
      data: (progresses) {
        final categoryProgresses = progresses
            .where((p) => p.budget.categoryId != null)
            .toList();

        if (progresses.isEmpty) {
          return SliverFillRemaining(
            child: EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No budgets yet',
              subtitle: 'Set a budget to start tracking your spending',
              actionLabel: 'Set Budget',
              action: () => showSetBudgetSheet(context),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Overall budget arc card
              overallAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (overall) {
                  if (overall == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.lg),
                    child: _OverallBudgetArcCard(progress: overall,
                      month: month,),
                  );
                },
              ),

              // Category grid header
              if (categoryProgresses.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppSpacing.md),
                  child: Text(
                    'Category Budgets',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                // 2-col grid
                _CategoryBudgetGrid(
                    progresses: categoryProgresses,
                    month: month),
              ],
            ]),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          ShimmerBox(
              width: double.infinity, height: 200),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 160)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 160)),
          ]),
        ]),
      ),
    );
  }
}

// ── Overall arc card ───────────────────────────────────────────────────────

class _OverallBudgetArcCard extends ConsumerWidget {
  const _OverallBudgetArcCard({
    required this.progress,
    required this.month,
  });
  final BudgetProgress progress;
  final int month;

  Color _stateColor(BudgetColorState state) {
    switch (state) {
      case BudgetColorState.onTrack:
        return AppColors.budgetLow;
      case BudgetColorState.moderate:
        return AppColors.budgetMid;
      case BudgetColorState.runningLow:
        return AppColors.budgetHigh;
      case BudgetColorState.over:
        return AppColors.budgetOver;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _stateColor(progress.colorState);
    final pct = progress.percentage.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
            BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
            color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Arc + numbers
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct),
                  duration: AppDurations.emphasis,
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => CustomPaint(
                    size: const Size(160, 160),
                    painter: _ArcPainter(
                      value: v,
                      color: color,
                      trackColor: theme.colorScheme
                          .surfaceContainerHighest,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${progress.spent.toStringAsFixed(0)}',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      'of \$${progress.effectiveLimit.toStringAsFixed(0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme
                            .colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusChip(
                        label: progress.statusLabel,
                        color: color),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Stats row
          Row(
            children: [
              _StatCell(
                label: 'Remaining',
                value: progress.isOver
                    ? '-\$${(-progress.remaining).toStringAsFixed(0)}'
                    : '\$${progress.remaining.toStringAsFixed(0)}',
                color: progress.isOver
                    ? AppColors.expense
                    : theme.colorScheme.onSurface,
              ),
              _Divider(),
              _StatCell(
                label: 'Daily left',
                value: progress.dailyAllowance > 0
                    ? '\$${progress.dailyAllowance.toStringAsFixed(0)}'
                    : '—',
              ),
              _Divider(),
              _StatCell(
                label: 'Projected',
                value:
                    '\$${progress.projectedMonthEnd.toStringAsFixed(0)}',
                color: progress.projectedMonthEnd >
                        progress.effectiveLimit
                    ? AppColors.expense
                    : AppColors.income,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Edit button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showSetBudgetSheet(
                context,
                existing: progress.budget,
              ),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit Overall Budget'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius:
            BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

// ── Arc painter ────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.value,
    required this.color,
    required this.trackColor,
  });

  final double value;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    const startAngle = math.pi * 0.75;
    const sweepFull = math.pi * 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Track
    canvas.drawArc(rect, startAngle, sweepFull, false, trackPaint);

    // Progress
    if (value > 0) {
      canvas.drawArc(
          rect, startAngle, sweepFull * value, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.value != value || old.color != color;
}

// ── Category budget grid ───────────────────────────────────────────────────

class _CategoryBudgetGrid extends ConsumerWidget {
  const _CategoryBudgetGrid({
    required this.progresses,
    required this.month,
  });
  final List<BudgetProgress> progresses;
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref
            .watch(expenseCategoriesProvider)
            .valueOrNull ??
        [];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.95,
      ),
      itemCount: progresses.length,
      itemBuilder: (_, i) {
        final p = progresses[i];
        final cat = categories.firstWhere(
          (c) => c.id == p.budget.categoryId,
          orElse: () => categories.isNotEmpty
              ? categories.first
              : _fallbackCategory(),
        );
        return _AnimatedGridItem(
          index: i,
          child: BudgetCard(
            progress: p,
            category:
                p.budget.categoryId != null ? cat : null,
            onEdit: () => showSetBudgetSheet(
              context,
              existing: p.budget,
            ),
            onDelete: () =>
                _confirmDelete(context, ref, p.budget),
          ),
        );
      },
    );
  }

  CategoryModel _fallbackCategory() {
    return CategoryModel(
      name: 'Other',
      iconCodePoint: Icons.category_rounded.codePoint,
      colorValue: AppColors.brand.toARGB32(),
      isIncome: false,
      isDefault: false,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BudgetModel budget,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Budget'),
        content:
            const Text('Remove this budget?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(deleteBudgetUseCaseProvider)(budget.id);
    }
  }
}

class _AnimatedGridItem extends StatefulWidget {
  const _AnimatedGridItem({
    required this.index,
    required this.child,
  });
  final int index;
  final Widget child;

  @override
  State<_AnimatedGridItem> createState() => _AnimatedGridItemState();
}

class _AnimatedGridItemState extends State<_AnimatedGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppDurations.standard,
    );
    _fade = CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(
      Duration(milliseconds: widget.index * 60),
      () {
        if (mounted) _ctrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
