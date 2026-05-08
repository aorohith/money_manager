import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../budgets/domain/providers/budget_providers.dart';
import '../../../goals/data/models/goal_model.dart';
import '../../../goals/domain/providers/goal_providers.dart';
import '../../../insights/domain/providers/insights_providers.dart';
import '../../../sms/domain/providers/sms_providers.dart';
import '../../../transactions/presentation/widgets/add_transaction_sheet.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';
import '../../domain/providers/dashboard_providers.dart';
import '../widgets/balance_card.dart';
import '../widgets/spending_ring.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scrollController = ScrollController();
  bool _fabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrollingDown = _scrollController.position.userScrollDirection ==
        ScrollDirection.reverse;
    final scrollingUp = _scrollController.position.userScrollDirection ==
        ScrollDirection.forward;
    if (scrollingDown && _fabVisible) setState(() => _fabVisible = false);
    if (scrollingUp && !_fabVisible) setState(() => _fabVisible = true);
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    ref.invalidate(dashboardProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final profileName = ref.watch(profileNameProvider).valueOrNull ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.brand,
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surface,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(context, profileName),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  const BalanceCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _QuickStatsRow(),
                  const SizedBox(height: AppSpacing.lg),
                  _SmsDetectionBanner(),
                  const SizedBox(height: AppSpacing.lg),
                  _InsightsSummaryCard(),
                  const SizedBox(height: AppSpacing.lg),
                  const SpendingRing(),
                  const SizedBox(height: AppSpacing.lg),
                  _BudgetHealthBanner(),
                  const SizedBox(height: AppSpacing.lg),
                  _GoalsSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _RecentTransactionsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: AppDurations.standard,
        offset: _fabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: AppDurations.standard,
          opacity: _fabVisible ? 1.0 : 0.0,
          child: _GradientFAB(
            onPressed: () => showAddTransactionSheet(context),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, String profileName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName =
        profileName.isNotEmpty ? profileName.split(' ').first : 'there';
    final initials = profileName.isNotEmpty
        ? profileName
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : 'U';

    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.background,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brand, AppColors.brandLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $firstName',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
              ),
              Text(
                'Financial overview',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        _NotificationButton(),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

// ── Notification Button ───────────────────────────────────────────────────────

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        icon: Icon(
          Icons.notifications_outlined,
          size: 22,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondary,
        ),
        onPressed: () => context.go(AppRoutes.insights),
        tooltip: 'Notifications',
        style: IconButton.styleFrom(
          backgroundColor: isDark
              ? AppColors.outlineDark
              : AppColors.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(40, 40),
          padding: const EdgeInsets.all(AppSpacing.xs + 2),
        ),
      ),
    );
  }
}

// ── Gradient FAB ──────────────────────────────────────────────────────────────

class _GradientFAB extends StatelessWidget {
  const _GradientFAB({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.brand, AppColors.brandLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.brand.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Stats Row ───────────────────────────────────────────────────────────

class _QuickStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider).valueOrNull;
    final currencySymbol =
        ref.watch(currencySymbolProvider).valueOrNull ?? '\$';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Today',
              value: data == null
                  ? '—'
                  : '$currencySymbol${_fmt(data.todayExpense)}',
              icon: Icons.today_rounded,
              accentColor: AppColors.brand,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              label: 'This Week',
              value: data == null
                  ? '—'
                  : '$currencySymbol${_fmt(data.weekExpense)}',
              icon: Icons.date_range_rounded,
              accentColor: const Color(0xFF8B5CF6),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              label: 'Txns',
              value: data == null
                  ? '—'
                  : '${data.recentTransactions.length}',
              icon: Icons.receipt_long_rounded,
              accentColor: AppColors.income,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: accentColor),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Transactions ───────────────────────────────────────────────────────

class _RecentTransactionsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
              ),
              TextButton(
                // Navigate to the full Transactions screen.
                onPressed: () => context.go(AppRoutes.transactions),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brand,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See all',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right_rounded,
                        size: 16, color: AppColors.brand),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        data.when(
          data: (d) {
            if (d.recentTransactions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No transactions yet',
                  subtitle: 'Tap Add to record your first transaction.',
                ),
              );
            }
            return Column(
              children: [
                for (int i = 0; i < d.recentTransactions.length; i++)
                  _StaggeredTile(
                    index: i,
                    child: _buildTile(ref, d, i),
                  ),
              ],
            );
          },
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Column(
              children: List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ShimmerBox(
                      width: double.infinity,
                      height: 68,
                      borderRadius: 14),
                ),
              ),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTile(WidgetRef ref, DashboardData d, int i) {
    final tx = d.recentTransactions[i];
    final cat = d.categories.where((c) => c.id == tx.categoryId).firstOrNull;
    final symbol = ref.read(currencySymbolProvider).valueOrNull ?? '\$';
    return TransactionTile(
      transaction: tx,
      category: cat,
      currencySymbol: symbol,
    );
  }
}

// ── Staggered slide-in ────────────────────────────────────────────────────────

class _StaggeredTile extends StatefulWidget {
  const _StaggeredTile({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_StaggeredTile> createState() => _StaggeredTileState();
}

class _StaggeredTileState extends State<_StaggeredTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppDurations.standard);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
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
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── SMS Detection Banner ──────────────────────────────────────────────────────

class _SmsDetectionBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(smsSettingsProvider);
    final pendingCount = ref.watch(smsPendingCountProvider);
    final permissionAsync = ref.watch(smsPermissionProvider);

    // Hide banner entirely when the feature is disabled in settings
    final smsEnabled = settingsAsync.valueOrNull?.enabled ?? true;
    if (!smsEnabled) return const SizedBox.shrink();

    // Don't show the banner if we have permission and nothing pending
    final hasPermission = permissionAsync.valueOrNull ?? false;
    if (hasPermission && pendingCount == 0) return const SizedBox.shrink();

    final isSetupCta = !hasPermission;
    final accent =
        isSetupCta ? AppColors.brand : AppColors.income;
    final icon = isSetupCta
        ? Icons.sms_outlined
        : Icons.mark_email_unread_outlined;
    final title = isSetupCta
        ? 'Enable auto expense detection'
        : '$pendingCount new expense${pendingCount == 1 ? '' : 's'} detected';
    final subtitle = isSetupCta
        ? 'Auto-log payments from bank notifications'
        : 'Tap to review and save';

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: GestureDetector(
        onTap: () => context.push(
            isSetupCta ? AppRoutes.smsOnboarding : AppRoutes.smsInbox),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
          decoration: BoxDecoration(
            color: accent.withAlpha(12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: accent.withAlpha(60)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: accent.withAlpha(180),
                          ),
                    ),
                  ],
                ),
              ),
              if (!isSetupCta)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Insights Summary Card ─────────────────────────────────────────────────────

class _InsightsSummaryCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.insights),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outline,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.brand.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(Icons.insights_rounded,
                    size: 18, color: AppColors.brand),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: insightsAsync.when(
                  loading: () => Text(
                    'Insights',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                  ),
                  error: (_, __) => Text(
                    'View Insights',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                  ),
                  data: (d) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Insights',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Savings ${d.savingsRate.toStringAsFixed(0)}%  '
                            '${d.spendingUp ? '↑' : '↓'} ${d.spendingChangePercent.abs().toStringAsFixed(0)}% vs last month',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Goals Section ─────────────────────────────────────────────────────────────

class _GoalsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);
    final currencySymbol =
        ref.watch(currencySymbolProvider).valueOrNull ?? '\$';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Goals',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.goals),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brand,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See all',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right_rounded,
                        size: 16, color: AppColors.brand),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        goalsAsync.when(
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: const ShimmerBox(
                width: double.infinity, height: 68, borderRadius: 14),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (goals) {
            final active =
                goals.where((g) => !g.isCompleted).take(3).toList();
            if (active.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.goals),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isDark
                            ? AppColors.outlineDark
                            : AppColors.outline,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flag_outlined,
                            size: 16,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Set your first goal',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: active
                  .map((g) => _GoalCard(
                      goal: g,
                      currencySymbol: currencySymbol,
                      isDark: isDark))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.currencySymbol,
    required this.isDark,
  });

  final GoalModel goal;
  final String currencySymbol;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final accent = goal.color;
    final pct = goal.progress;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        bottom: AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outline,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withAlpha(20),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(goal.icon, size: 18, color: accent),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(pct * 100).toStringAsFixed(0)}%',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor:
                          isDark ? AppColors.outlineDark : AppColors.outline,
                      valueColor: AlwaysStoppedAnimation(accent),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currencySymbol${goal.remaining.toStringAsFixed(0)} remaining',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Budget Health Banner ──────────────────────────────────────────────────────

class _BudgetHealthBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallAsync = ref.watch(overallBudgetProgressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return overallAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (overall) {
        if (overall == null) return const SizedBox.shrink();

        final pct = overall.percentage.clamp(0.0, 1.0);
        final accent = switch (true) {
          _ when overall.isOver => AppColors.budgetOver,
          _ when overall.percentage >= 0.80 => AppColors.budgetHigh,
          _ when overall.percentage >= 0.50 => AppColors.budgetMid,
          _ => AppColors.budgetLow,
        };
        final label = overall.statusLabel.replaceAll(' 🎯', '');

        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: Semantics(
            label:
                'Budget health: ${(pct * 100).toStringAsFixed(0)}% used',
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 4,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : AppColors.outline,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent.withAlpha(20),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded,
                        size: 18, color: accent),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Budget Health',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                            ),
                            Text(
                              '${(pct * 100).toStringAsFixed(0)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: isDark
                                ? AppColors.outlineDark
                                : AppColors.outline,
                            valueColor:
                                AlwaysStoppedAnimation(accent),
                            minHeight: 5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
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
      },
    );
  }
}
