import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/providers/dashboard_providers.dart';

// ── Balance hide/show state ───────────────────────────────────────────────────

final _balanceHiddenProvider = StateProvider<bool>((_) => false);

// ── Balance Card ─────────────────────────────────────────────────────────────

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider);
    final period = ref.watch(dashboardPeriodProvider);
    final hidden = ref.watch(_balanceHiddenProvider);
    final currencySymbol =
        ref.watch(currencySymbolProvider).valueOrNull ?? '\$';
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withAlpha(204)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glassmorphism overlay circle
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(13),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period selector + hide button
                Row(
                  children: [
                    _PeriodChips(period: period),
                    const Spacer(),
                    _HideButton(hidden: hidden),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Balance label
                Text(
                  'Net Balance',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onPrimary.withAlpha(179),
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Digit-roll balance
                data.when(
                  data: (d) => _DigitRollBalance(
                    amount: d.netBalance,
                    symbol: currencySymbol,
                    hidden: hidden,
                    textStyle:
                        Theme.of(context).textTheme.displaySmall!.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                  ),
                  loading: () => _skeletonBalance(context, scheme),
                  error: (_, __) => _skeletonBalance(context, scheme),
                ),
                const SizedBox(height: AppSpacing.md),
                // Income / Expense row
                data.when(
                  data: (d) => _IncomeExpenseRow(
                    income: d.totalIncome,
                    expense: d.totalExpense,
                    symbol: currencySymbol,
                    hidden: hidden,
                  ),
                  loading: () => const SizedBox(height: 40),
                  error: (_, __) => const SizedBox(height: 40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBalance(BuildContext context, ColorScheme scheme) {
    return Container(
      height: 44,
      width: 160,
      decoration: BoxDecoration(
        color: scheme.onPrimary.withAlpha(51),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
    );
  }
}

// ── Period chips ──────────────────────────────────────────────────────────────

class _PeriodChips extends ConsumerWidget {
  const _PeriodChips({required this.period});
  final DashboardPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: DashboardPeriod.values.map((p) {
        final selected = p == period;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(dashboardPeriodProvider.notifier).state = p;
          },
          child: AnimatedContainer(
            duration: AppDurations.fast,
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? scheme.onPrimary.withAlpha(51)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: selected
                    ? scheme.onPrimary.withAlpha(128)
                    : scheme.onPrimary.withAlpha(51),
                width: 1,
              ),
            ),
            child: Text(
              _label(p),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimary
                        .withAlpha(selected ? 255 : 179),
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(DashboardPeriod p) => switch (p) {
        DashboardPeriod.thisMonth => 'This Month',
        DashboardPeriod.lastMonth => 'Last Month',
        DashboardPeriod.last3Months => '3 Months',
      };
}

// ── Hide button ───────────────────────────────────────────────────────────────

class _HideButton extends ConsumerWidget {
  const _HideButton({required this.hidden});
  final bool hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: hidden ? 'Show balance' : 'Hide balance',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(_balanceHiddenProvider.notifier).state = !hidden;
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xs + 2),
          decoration: BoxDecoration(
            color: scheme.onPrimary.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(
            hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            size: 18,
            color: scheme.onPrimary.withAlpha(204),
          ),
        ),
      ),
    );
  }
}

// ── Digit-roll balance ────────────────────────────────────────────────────────

class _DigitRollBalance extends StatelessWidget {
  const _DigitRollBalance({
    required this.amount,
    required this.symbol,
    required this.hidden,
    required this.textStyle,
  });

  final double amount;
  final String symbol;
  final bool hidden;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    if (hidden) {
      return Text('$symbol ••••••', style: textStyle);
    }
    final formatted = _formatAmount(amount);
    return Semantics(
      label: 'Balance: $symbol$formatted',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(symbol, style: textStyle.copyWith(fontSize: 20)),
          const SizedBox(width: 2),
          _AnimatedNumber(value: amount, style: textStyle),
        ],
      ),
    );
  }

  String _formatAmount(double v) {
    final abs = v.abs();
    if (abs >= 1000000) return '${(abs / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000) {
      // Show with comma
      final parts = abs.toStringAsFixed(2).split('.');
      final intPart = parts[0];
      final decPart = parts[1];
      final reversed = intPart.split('').reversed.toList();
      final withCommas = <String>[];
      for (int i = 0; i < reversed.length; i++) {
        if (i > 0 && i % 3 == 0) withCommas.add(',');
        withCommas.add(reversed[i]);
      }
      return '${withCommas.reversed.join()}.$decPart';
    }
    return abs.toStringAsFixed(2);
  }
}

class _AnimatedNumber extends StatelessWidget {
  const _AnimatedNumber({required this.value, required this.style});

  final double value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final formatted = _format(value);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value, end: value),
      duration: AppDurations.emphasis,
      builder: (_, v, __) {
        return Text(_format(v), style: style);
      },
      child: Text(formatted, style: style),
    );
  }

  String _format(double v) {
    final neg = v < 0;
    final abs = v.abs();
    final parts = abs.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final reversed = intPart.split('').reversed.toList();
    final withCommas = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) withCommas.add(',');
      withCommas.add(reversed[i]);
    }
    final formatted = '${withCommas.reversed.join()}.$decPart';
    return neg ? '-$formatted' : formatted;
  }
}

// ── Income/Expense row ────────────────────────────────────────────────────────

class _IncomeExpenseRow extends StatelessWidget {
  const _IncomeExpenseRow({
    required this.income,
    required this.expense,
    required this.symbol,
    required this.hidden,
  });

  final double income;
  final double expense;
  final String symbol;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.arrow_downward_rounded,
            label: 'Income',
            value: hidden ? '••••' : _fmt(income),
            symbol: symbol,
            iconBg: Colors.white.withAlpha(38),
            scheme: scheme,
          ),
        ),
        Container(
          width: 1,
          height: 36,
          color: scheme.onPrimary.withAlpha(51),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        Expanded(
          child: _StatItem(
            icon: Icons.arrow_upward_rounded,
            label: 'Expense',
            value: hidden ? '••••' : _fmt(expense),
            symbol: symbol,
            iconBg: Colors.white.withAlpha(38),
            scheme: scheme,
          ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(2);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.symbol,
    required this.iconBg,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final String value;
  final String symbol;
  final Color iconBg;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
          child: Icon(icon, size: 14, color: scheme.onPrimary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimary.withAlpha(153),
                  ),
            ),
            Text(
              '$symbol$value',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
