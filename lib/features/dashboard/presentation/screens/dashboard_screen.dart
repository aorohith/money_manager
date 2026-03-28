import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
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
    // Invalidate dashboard to force re-fetch
    ref.invalidate(dashboardProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final profileName = ref.watch(profileNameProvider).valueOrNull ?? '';
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: scheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(context, profileName, scheme),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  const BalanceCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _QuickStatsRow(),
                  const SizedBox(height: AppSpacing.lg),
                  const SpendingRing(),
                  const SizedBox(height: AppSpacing.lg),
                  _RecentTransactionsSection(),
                  const SizedBox(height: 100), // FAB clearance
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
          child: FloatingActionButton.extended(
            onPressed: () => showAddTransactionSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add'),
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, String profileName, ColorScheme scheme) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profileName.isNotEmpty
                    ? 'Hello, ${profileName.split(' ').first} 👋'
                    : 'Hello 👋',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Your financial overview',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
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
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          Expanded(
            child: _QuickStatCard(
              label: 'Today',
              value: data == null
                  ? '—'
                  : '$currencySymbol${_fmt(data.todayExpense)}',
              icon: Icons.today_rounded,
              color: scheme.tertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _QuickStatCard(
              label: 'This Week',
              value: data == null
                  ? '—'
                  : '$currencySymbol${_fmt(data.weekExpense)}',
              icon: Icons.date_range_rounded,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _QuickStatCard(
              label: 'Transactions',
              value: data == null
                  ? '—'
                  : '${data.recentTransactions.length}',
              icon: Icons.receipt_long_rounded,
              color: scheme.secondary,
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

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full transactions screen
                },
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        data.when(
          data: (d) {
            if (d.recentTransactions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No transactions yet',
                  subtitle: 'Tap + Add to record your first transaction.',
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
                            height: 72,
                            borderRadius: 12),
                      )),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTile(WidgetRef ref, DashboardData d, int i) {
    final tx = d.recentTransactions[i];
    final cat =
        d.categories.where((c) => c.id == tx.categoryId).firstOrNull;
    final symbol =
        ref.read(currencySymbolProvider).valueOrNull ?? '\$';
    return TransactionTile(
      transaction: tx,
      category: cat,
      currencySymbol: symbol,
    );
  }
}

// ── Staggered slide-in animation ──────────────────────────────────────────────

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
    _ctrl = AnimationController(
      vsync: this,
      duration: AppDurations.standard,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(_ctrl);

    // Stagger by index
    Future.delayed(
      Duration(milliseconds: 80 * widget.index),
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
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
