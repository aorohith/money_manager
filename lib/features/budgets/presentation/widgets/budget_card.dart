import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../transactions/data/models/category_model.dart';
import '../../data/repositories/budget_repository.dart';

/// A budget card showing progress, color state, daily allowance, projection.
class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.progress,
    this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final BudgetProgress progress;
  final CategoryModel? category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _stateColor(progress.colorState);
    final pct = progress.percentage.clamp(0.0, 1.0);

    return Semantics(
      label:
          '${category?.name ?? "Overall"} budget, ${(pct * 100).toStringAsFixed(0)}% used, ${progress.statusLabel}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (category?.color ?? AppColors.brand)
                            .withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category?.icon ?? Icons.pie_chart_rounded,
                        size: 18,
                        color: category?.color ?? AppColors.brand,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        category?.name ?? 'Overall',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Menu
                    if (onEdit != null || onDelete != null)
                      _CardMenu(onEdit: onEdit, onDelete: onDelete),
                  ],
                ),
              ),

              // Amounts
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Text(
                      '\$${progress.spent.toStringAsFixed(0)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      ' / \$${progress.effectiveLimit.toStringAsFixed(0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Animated progress bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md),
                child: _AnimatedProgressBar(
                  value: pct,
                  color: color,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Status + daily allowance
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        progress.statusLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!progress.isOver &&
                        progress.dailyAllowance > 0)
                      Text(
                        '\$${progress.dailyAllowance.toStringAsFixed(0)}/day',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedProgressBar extends StatefulWidget {
  const _AnimatedProgressBar({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: AppDurations.emphasis);
    _anim = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedProgressBar old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _anim = Tween<double>(begin: _anim.value, end: widget.value)
          .animate(CurvedAnimation(
              parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => LinearProgressIndicator(
        value: _anim.value,
        backgroundColor:
            Theme.of(context).colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation(widget.color),
        minHeight: 6,
        borderRadius:
            BorderRadius.circular(AppSpacing.radiusFull),
      ),
    );
  }
}

class _CardMenu extends StatelessWidget {
  const _CardMenu({this.onEdit, this.onDelete});
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      itemBuilder: (_) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_rounded, size: 18),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Delete',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          ),
      ],
      onSelected: (v) {
        if (v == 'edit') onEdit?.call();
        if (v == 'delete') onDelete?.call();
      },
    );
  }
}
