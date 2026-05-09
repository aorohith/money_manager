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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0052FF), Color(0xFF0A1E6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052FF).withAlpha(70),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -48,
              right: -32,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x14FFFFFF),
                ),
              ),
            ),
            Positioned(
              bottom: -64,
              left: -24,
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0AFFFFFF),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 80,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x08FFFFFF),
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
                  const SizedBox(height: AppSpacing.lg),
                  // Balance label
                  const Text(
                    'Net Balance',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB3C6FF),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Balance value
                  data.when(
                    data: (d) => _DigitRollBalance(
                      amount: d.netBalance,
                      symbol: currencySymbol,
                      hidden: hidden,
                    ),
                    loading: () => _skeletonBalance(),
                    error: (_, __) => _skeletonBalance(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Divider
                  Container(
                    height: 1,
                    color: Colors.white.withAlpha(25),
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
                    loading: () => const SizedBox(height: 48),
                    error: (_, __) => const SizedBox(height: 48),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonBalance() {
    return Container(
      height: 48,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
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
              horizontal: AppSpacing.sm + 2,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withAlpha(36)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: selected
                    ? Colors.white.withAlpha(80)
                    : Colors.white.withAlpha(30),
                width: 1,
              ),
            ),
            child: Text(
              _label(p),
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: Colors.white
                    .withAlpha(selected ? 255 : 160),
                letterSpacing: 0.1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(DashboardPeriod p) => switch (p) {
        DashboardPeriod.thisMonth => 'Month',
        DashboardPeriod.lastMonth => 'Last',
        DashboardPeriod.last3Months => '3M',
      };
}

// ── Hide button ───────────────────────────────────────────────────────────────

class _HideButton extends ConsumerWidget {
  const _HideButton({required this.hidden});
  final bool hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: hidden ? 'Show balance' : 'Hide balance',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(_balanceHiddenProvider.notifier).state = !hidden;
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(
            hidden
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            size: 16,
            color: Colors.white.withAlpha(200),
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
  });

  final double amount;
  final String symbol;
  final bool hidden;

  static const _style = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -1.5,
    height: 1.1,
  );

  @override
  Widget build(BuildContext context) {
    if (hidden) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(symbol,
              style: _style.copyWith(
                  fontSize: 22, color: Colors.white.withAlpha(200))),
          const SizedBox(width: 4),
          const Text('••••••', style: _style),
        ],
      );
    }
    return Semantics(
      label: 'Balance: $symbol${_format(amount)}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            symbol,
            style: _style.copyWith(
              fontSize: 22,
              color: Colors.white.withAlpha(200),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 3),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: amount),
            duration: AppDurations.emphasis,
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Text(_format(v), style: _style),
          ),
        ],
      ),
    );
  }

  String _format(double v) {
    final neg = v < 0;
    final abs = v.abs();
    if (abs >= 1000000) {
      return '${neg ? '-' : ''}${(abs / 1000000).toStringAsFixed(2)}M';
    }
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
    return Row(
      children: [
        Expanded(
          child: _FinancialPill(
            icon: Icons.arrow_downward_rounded,
            label: 'Income',
            value: hidden ? '••••' : _fmt(income),
            symbol: symbol,
            iconColor: AppColors.incomeChip,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: Colors.white.withAlpha(25),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        Expanded(
          child: _FinancialPill(
            icon: Icons.arrow_upward_rounded,
            label: 'Expenses',
            value: hidden ? '••••' : _fmt(expense),
            symbol: symbol,
            iconColor: AppColors.expenseChip,
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

class _FinancialPill extends StatelessWidget {
  const _FinancialPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.symbol,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String symbol;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(30),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '$symbol$value',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
