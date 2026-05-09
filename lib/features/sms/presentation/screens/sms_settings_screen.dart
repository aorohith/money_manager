import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/sms_rule_model.dart';
import '../../domain/models/sms_settings.dart';
import '../../domain/providers/sms_providers.dart';

class SmsSettingsScreen extends ConsumerStatefulWidget {
  const SmsSettingsScreen({super.key});

  @override
  ConsumerState<SmsSettingsScreen> createState() => _SmsSettingsScreenState();
}

class _SmsSettingsScreenState extends ConsumerState<SmsSettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check notification permission whenever the app returns to foreground.
    // This covers the case where the user taps "Grant", leaves to system
    // Settings, grants access, and returns — the banner updates automatically.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(smsPermissionProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(smsSettingsProvider);
    final permissionAsync = ref.watch(smsPermissionProvider);
    final rulesAsync = ref.watch(smsRulesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Auto-Detection'),
            floating: true,
            snap: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Permission status banner
                permissionAsync.when(
                  data: (enabled) => _PermissionBanner(enabled: enabled),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: AppSpacing.lg),
                _SectionHeader('Detection'),
                const SizedBox(height: AppSpacing.sm),

                settingsAsync.when(
                  loading: () => const ShimmerBox(
                      width: double.infinity,
                      height: 160,
                      borderRadius: 16),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (settings) => Column(
                    children: [
                      // Master toggle
                      AppCard(
                        child: SwitchListTile(
                          title: const Text('Enable auto-detection',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          subtitle: const Text(
                            'Scan bank notifications for transactions',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: settings.enabled,
                          onChanged: (v) => ref
                              .read(smsSettingsProvider.notifier)
                              .setEnabled(v),
                          activeThumbColor: AppColors.brand,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Auto-add mode
                      if (settings.enabled) ...[
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Auto-add mode',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              RadioGroup<SmsAutoAddMode>(
                                groupValue: settings.autoAddMode,
                                onChanged: (v) {
                                  if (v != null) {
                                    ref
                                        .read(smsSettingsProvider
                                            .notifier)
                                        .setAutoAddMode(v);
                                  }
                                },
                                child: Column(
                                  children: SmsAutoAddMode.values
                                      .map((mode) {
                                    return RadioListTile<SmsAutoAddMode>(
                                      title: Text(
                                        mode.label,
                                        style: const TextStyle(
                                            fontSize: 13),
                                      ),
                                      subtitle: Text(
                                        mode.description,
                                        style: const TextStyle(
                                            fontSize: 11),
                                      ),
                                      value: mode,
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Confidence threshold
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Confidence threshold',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                            fontWeight:
                                                FontWeight.w600),
                                  ),
                                  Text(
                                    '${settings.confidenceThreshold}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.brand,
                                        ),
                                  ),
                                ],
                              ),
                              Text(
                                'Ask for confirmation below this score',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .brightness ==
                                          Brightness.dark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                              ),
                              Slider(
                                value: settings.confidenceThreshold
                                    .toDouble(),
                                min: 30,
                                max: 100,
                                divisions: 14,
                                activeColor: AppColors.brand,
                                onChanged: (v) => ref
                                    .read(smsSettingsProvider.notifier)
                                    .setConfidenceThreshold(
                                        v.round()),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Extra detection toggles
                        AppCard(
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text(
                                    'Detect subscriptions',
                                    style: TextStyle(fontSize: 14)),
                                subtitle: const Text(
                                    'Flag recurring monthly payments',
                                    style: TextStyle(fontSize: 12)),
                                value: settings.detectSubscriptions,
                                onChanged: (v) => ref
                                    .read(smsSettingsProvider.notifier)
                                    .setDetectSubscriptions(v),
                                activeThumbColor: AppColors.brand,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                              SwitchListTile(
                                title: const Text('Detect refunds',
                                    style: TextStyle(fontSize: 14)),
                                subtitle: const Text(
                                    'Log credited amounts as income',
                                    style: TextStyle(fontSize: 12)),
                                value: settings.detectRefunds,
                                onChanged: (v) => ref
                                    .read(smsSettingsProvider.notifier)
                                    .setDetectRefunds(v),
                                activeThumbColor: AppColors.brand,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
                _SectionHeader('Merchant Rules'),
                const SizedBox(height: AppSpacing.sm),

                rulesAsync.when(
                  loading: () => const ShimmerBox(
                      width: double.infinity,
                      height: 80,
                      borderRadius: 16),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (rules) => rules.isEmpty
                      ? AppCard(
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(AppSpacing.md),
                              child: Text(
                                'No rules yet — they\'ll appear here as you categorise merchants.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                                  .brightness ==
                                              Brightness.dark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                              ),
                            ),
                          ),
                        )
                      : AppCard(
                          child: Column(
                            children: rules
                                .map((rule) => _RuleTile(rule: rule))
                                .toList(),
                          ),
                        ),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Permission Banner ─────────────────────────────────────────────────────────

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.enabled});
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color: AppColors.income.withAlpha(18),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.income.withAlpha(60)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.income, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Notification access granted',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.income,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      decoration: BoxDecoration(
        color: AppColors.budgetHigh.withAlpha(18),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.budgetHigh.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.budgetHigh, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Notification access not granted',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.budgetHigh,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          TextButton(
            onPressed: _openSettings,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.budgetHigh,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Grant',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings() async {
    await const MethodChannel('com.example.money_manager/sms')
        .invokeMethod<void>('openNotificationSettings');
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
    );
  }
}

// ── Rule Tile ─────────────────────────────────────────────────────────────────

class _RuleTile extends ConsumerWidget {
  const _RuleTile({required this.rule});
  final SmsRuleModel rule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.brand.withAlpha(18),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: const Icon(Icons.store_rounded,
            size: 18, color: AppColors.brand),
      ),
      title: Text(
        rule.userAlias ?? rule.merchantKey,
        style:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${rule.useCount} confirmation${rule.useCount == 1 ? '' : 's'}'
        '${rule.alwaysApply ? ' · Auto-apply' : ''}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded, size: 18),
        onPressed: () =>
            ref.read(smsRepositoryProvider).deleteRule(rule.id),
        color: AppColors.budgetOver,
        tooltip: 'Delete rule',
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
