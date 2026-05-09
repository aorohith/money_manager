import 'package:flutter/material.dart';

/// Sections of the dashboard the user can toggle on or off from
/// Settings → Home screen.
///
/// The `id` is a stable string serialised to disk so that reordering this
/// enum (or renaming a member) never silently corrupts persisted preferences.
enum HomeSection {
  periodSelector(
    id: 'period_selector',
    label: 'Period filter',
    description:
        'Day, week, month, or year filter that drives the dashboard.',
    icon: Icons.calendar_month_rounded,
    defaultEnabled: true,
  ),
  quickStats(
    id: 'quick_stats',
    label: 'Quick stats',
    description: 'Today, this week, and transaction count tiles.',
    icon: Icons.speed_rounded,
    defaultEnabled: true,
  ),
  smsBanner(
    id: 'sms_banner',
    label: 'SMS auto-detect banner',
    description:
        'Setup CTA + new-expense alerts from bank notifications. Hides itself when nothing is pending.',
    icon: Icons.sms_rounded,
    defaultEnabled: true,
  ),
  insightsSummary(
    id: 'insights_summary',
    label: 'Insights summary',
    description: 'Savings rate and month-over-month spending trend.',
    icon: Icons.insights_rounded,
    defaultEnabled: false,
  ),
  spendingRing(
    id: 'spending_ring',
    label: 'Spending breakdown',
    description: 'Donut chart of this month\'s expenses by category.',
    icon: Icons.pie_chart_rounded,
    defaultEnabled: false,
  ),
  budgetHealth(
    id: 'budget_health',
    label: 'Budget health',
    description: 'Progress bar for your overall monthly budget.',
    icon: Icons.account_balance_wallet_rounded,
    defaultEnabled: false,
  ),
  goals(
    id: 'goals',
    label: 'Goals',
    description: 'Top active savings goals with progress.',
    icon: Icons.flag_rounded,
    defaultEnabled: false,
  ),
  categorySpending(
    // Stable persisted id retained so previously customised layouts
    // continue to honour the user's enable/disable choice.
    id: 'recent_transactions',
    label: 'Category spending',
    description: 'How much you spent in each category this period.',
    icon: Icons.donut_small_rounded,
    defaultEnabled: true,
  );

  const HomeSection({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.defaultEnabled,
  });

  final String id;
  final String label;
  final String description;
  final IconData icon;
  final bool defaultEnabled;

  /// The set of sections enabled when the user has never customised the
  /// home layout (or has just hit "Reset to defaults").
  static Set<HomeSection> get defaultEnabledSet =>
      values.where((s) => s.defaultEnabled).toSet();

  /// Resolve a section by its stable [id]. Returns `null` for unknown ids
  /// (e.g. a section persisted by a newer build that's been removed since).
  static HomeSection? fromId(String id) {
    for (final s in values) {
      if (s.id == id) return s;
    }
    return null;
  }
}
