import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/goal_model.dart';
import '../../domain/providers/goal_providers.dart';
import '../widgets/add_goal_sheet.dart';

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});
  final int goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailProvider(goalId));

    return goalAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error: $e'))),
      data: (goal) {
        if (goal == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Goal not found')),
          );
        }
        return _GoalDetailBody(goal: goal);
      },
    );
  }
}

class _GoalDetailBody extends ConsumerWidget {
  const _GoalDetailBody({required this.goal});
  final GoalModel goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = goal.color;
    final pct = goal.progress;

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit',
            onPressed: () => showAddGoalSheet(context, existing: goal),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Progress ring
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: AppDurations.emphasis,
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => CustomPaint(
                      size: const Size(180, 180),
                      painter: _RingPainter(
                        value: v,
                        color: color,
                        trackColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(goal.icon, color: color, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        '${(pct * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      if (goal.isCompleted)
                        Text('Completed!',
                            style: theme.textTheme.labelMedium
                                ?.copyWith(color: AppColors.income)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stats
            Row(
              children: [
                _StatCard(
                  label: 'Saved',
                  value: '\$${goal.currentAmount.toStringAsFixed(0)}',
                  color: AppColors.income,
                ),
                const SizedBox(width: AppSpacing.md),
                _StatCard(
                  label: 'Target',
                  value: '\$${goal.targetAmount.toStringAsFixed(0)}',
                ),
                const SizedBox(width: AppSpacing.md),
                _StatCard(
                  label: 'Remaining',
                  value: '\$${goal.remaining.toStringAsFixed(0)}',
                  color: goal.remaining > 0 ? AppColors.expense : AppColors.income,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            if (goal.deadline != null)
              AppCard(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: const Text('Deadline'),
                  subtitle: Text(
                    '${goal.deadline!.day}/${goal.deadline!.month}/${goal.deadline!.year}',
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),

            if (goal.notes != null && goal.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: ListTile(
                  leading: const Icon(Icons.notes_rounded),
                  title: const Text('Notes'),
                  subtitle: Text(goal.notes!),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            if (!goal.isCompleted)
              AppButton(
                expanded: true,
                label: 'Add Money',
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _showAddMoney(context, ref),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddMoney(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    await showAppBottomSheet<double>(
      context: context,
      title: 'Add Contribution',
      child: _AddContributionForm(ctrl: ctrl, goal: goal),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(deleteGoalUseCaseProvider)(goal.id);
      if (context.mounted) context.pop();
    }
  }
}

class _AddContributionForm extends ConsumerStatefulWidget {
  const _AddContributionForm({required this.ctrl, required this.goal});
  final TextEditingController ctrl;
  final GoalModel goal;

  @override
  ConsumerState<_AddContributionForm> createState() =>
      _AddContributionFormState();
}

class _AddContributionFormState
    extends ConsumerState<_AddContributionForm> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final amount =
        double.tryParse(widget.ctrl.text.replaceAll(',', '')) ?? 0;
    await ref.read(addContributionUseCaseProvider)(
        widget.goal.id, amount);

    ref.invalidate(goalDetailProvider(widget.goal.id));

    if (mounted) {
      Navigator.of(context).pop();
      showAppSnackBar(context,
          message: '\$${amount.toStringAsFixed(0)} added to ${widget.goal.name}',
          type: AppSnackBarType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Remaining: \$${widget.goal.remaining.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: widget.ctrl,
            label: 'Amount',
            hint: '0.00',
            prefixIcon: const Icon(Icons.attach_money_rounded),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Amount is required';
              final n = double.tryParse(v.replaceAll(',', ''));
              if (n == null || n <= 0) return 'Enter a valid amount';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            expanded: true,
            label: 'Add',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            children: [
              Text(value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  )),
              const SizedBox(height: 2),
              Text(label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
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

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, trackPaint);
    if (value > 0) {
      canvas.drawArc(
          rect, -math.pi / 2, math.pi * 2 * value, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}
