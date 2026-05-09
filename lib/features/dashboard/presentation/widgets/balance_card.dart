import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../transactions/data/models/account_model.dart';
import '../../../transactions/domain/providers/transaction_providers.dart';
import '../../domain/providers/dashboard_providers.dart';

// ── Balance hide/show state ───────────────────────────────────────────────────

final _balanceHiddenProvider = StateProvider<bool>((_) => false);

/// Whether the large gradient [BalanceCard] is expanded below the compact
/// total-balance chip on the dashboard.
final balanceCardExpandedProvider = StateProvider<bool>((_) => false);

/// Shared formatting for dashboard money amounts (chip + animated balance).
class _DashboardMoneyFormat {
  static String format(double v) {
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

// ── Compact total-balance chip (tap to expand detailed card) ────────────────

class _BalanceTopChip extends ConsumerWidget {
  const _BalanceTopChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = ref.watch(dashboardProvider);
    final hidden = ref.watch(_balanceHiddenProvider);
    final currencySymbol =
        ref.watch(currencySymbolProvider).valueOrNull ?? '\$';
    final expanded = ref.watch(balanceCardExpandedProvider);

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('dashboard_balance_chip'),
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(balanceCardExpandedProvider.notifier).state = !expanded;
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.surfaceDark,
                        AppColors.surfaceDark,
                      ]
                    : [
                        AppColors.surface,
                        AppColors.surface,
                      ],
              ),
              border: Border.all(
                color: AppColors.brand.withAlpha(isDark ? 90 : 70),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand.withAlpha(28),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0052FF), Color(0xFF0A1E6E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total balance',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      data.when(
                        data: (d) => Text(
                          hidden
                              ? '$currencySymbol••••••'
                              : '$currencySymbol${_DashboardMoneyFormat.format(d.netBalance)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                        ),
                        loading: () => Container(
                          height: 22,
                          width: 120,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.outlineDark
                                : AppColors.outline,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        error: (_, __) => const Text('—'),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: AppDurations.fast,
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dashboard balance (chip + optional card) ─────────────────────────────────

class DashboardBalanceSection extends ConsumerWidget {
  const DashboardBalanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(balanceCardExpandedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _BalanceTopChip(),
        AnimatedSize(
          duration: AppDurations.standard,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: expanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    BalanceCard(
                      onRequestAccountBreakdown: () =>
                          _showAccountBalancesSheet(context),
                    ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

// ── Balance Card ─────────────────────────────────────────────────────────────

class BalanceCard extends ConsumerWidget {
  const BalanceCard({
    super.key,
    this.onRequestAccountBreakdown,
  });

  /// Tapped on the card chrome (period/hide controls handle their own taps).
  final VoidCallback? onRequestAccountBreakdown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider);
    final activePeriod = ref.watch(effectiveDashboardPeriodProvider);
    final hidden = ref.watch(_balanceHiddenProvider);
    final currencySymbol =
        ref.watch(currencySymbolProvider).valueOrNull ?? '\$';
    final periodSubtitle = homePeriodLabel(activePeriod);

    return GestureDetector(
      onTap: onRequestAccountBreakdown == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onRequestAccountBreakdown!();
            },
      behavior: HitTestBehavior.deferToChild,
      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
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
                    // Active period label + hide button. The period itself
                    // is selected by the dashboard's _PeriodFilterSection;
                    // the card just reflects what's currently scoped.
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                'Net Balance',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFB3C6FF),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(28),
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusFull),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(40),
                                    ),
                                  ),
                                  child: Text(
                                    periodSubtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _HideButton(hidden: hidden),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
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
      label: 'Balance: $symbol${_DashboardMoneyFormat.format(amount)}',
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
            builder: (_, v, __) =>
                Text(_DashboardMoneyFormat.format(v), style: _style),
          ),
        ],
      ),
    );
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
        // Wrap in Expanded so long values (e.g. large currencies/symbols)
        // ellipsise inside the pill instead of overflowing the row.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Account breakdown sheet ────────────────────────────────────────────────────

/// Opens the per-account balance breakdown.
///
/// Layout strategy (overflow-proof on every device size):
///   1. `isScrollControlled: true` + outer `maxHeight` cap so the modal
///      can't grow past 85% of the viewport.
///   2. `LayoutBuilder` so we read the *real* available height **after**
///      the modal subtracts the drag handle and bottom safe-area inset
///      (using the parent's `MediaQuery.height` directly here under-counts
///      and was the source of the original overflow).
///   3. `Column(MainAxisSize.max) + Expanded(ListView)` so the list always
///      fills exactly the leftover space and scrolls instead of overshooting.
Future<void> _showAccountBalancesSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
    ),
    builder: (sheetContext) {
      final scheme = Theme.of(sheetContext).colorScheme;

      return Consumer(
        builder: (context, ref, _) {
          final accountsAsync = ref.watch(accountsProvider);
          final currencySymbol =
              ref.watch(currencySymbolProvider).valueOrNull ?? '\$';

          return LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Balances by account',
                        textAlign: TextAlign.center,
                        style: Theme.of(sheetContext)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: accountsAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (e, _) => Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              child: Text(
                                '$e',
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: scheme.error),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          data: (accounts) {
                            if (accounts.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md),
                                  child: Text(
                                    'No accounts yet. Add one from '
                                    'Manage accounts.',
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: scheme.onSurfaceVariant),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              key: const Key(
                                  'dashboard_account_balances_list'),
                              padding: EdgeInsets.zero,
                              itemCount: accounts.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: scheme.outlineVariant.withAlpha(128),
                              ),
                              itemBuilder: (_, i) => _AccountBalanceRow(
                                account: accounts[i],
                                currencySymbol: currencySymbol,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FilledButton.tonal(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          sheetContext.go(AppRoutes.manageAccounts);
                        },
                        child: const Text('Manage accounts'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

class _AccountBalanceRow extends ConsumerWidget {
  const _AccountBalanceRow({
    required this.account,
    required this.currencySymbol,
  });

  final AccountModel account;
  final String currencySymbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final balanceAsync = ref.watch(accountBalanceProvider(account));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: account.color.withAlpha(22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(account.icon, size: 18, color: account.color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              account.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          balanceAsync.when(
            data: (b) => Text(
              '$currencySymbol${_DashboardMoneyFormat.format(b)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            loading: () => SizedBox(
              width: 64,
              height: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.outlineDark.withAlpha(140)
                      : AppColors.outline.withAlpha(140),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            error: (_, __) => const Text('—'),
          ),
        ],
      ),
    );
  }
}
