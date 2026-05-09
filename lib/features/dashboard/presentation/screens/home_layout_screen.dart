import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/models/home_section.dart';
import '../../domain/providers/home_layout_provider.dart';

/// Settings screen that lets the user customise which dashboard sections
/// appear on Home. The compact total balance chip and expandable balance
/// card are always shown and are therefore not listed here.
class HomeLayoutScreen extends ConsumerWidget {
  const HomeLayoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutAsync = ref.watch(homeLayoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home screen'),
        actions: [
          TextButton(
            onPressed: layoutAsync.isLoading
                ? null
                : () => _confirmReset(context, ref),
            child: const Text('Reset'),
          ),
        ],
      ),
      body: layoutAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Couldn\'t load layout: $e')),
        data: (enabled) => ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            _Header(),
            const SizedBox(height: AppSpacing.lg),
            const _AlwaysOnTile(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Optional sections',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final section in HomeSection.values) ...[
              _SectionTile(section: section, enabled: enabled.contains(section)),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              'You can re-enable any section later from this screen. We\'ll add a guided showcase to introduce these in a future update.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset to defaults?'),
        content: const Text(
          'This restores the home screen to the simplified layout new users see by default.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(homeLayoutProvider.notifier).resetToDefaults();
    }
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customise your home',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Show only the sections that matter to you. Hidden sections stay one tap away — you can turn them back on any time.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _AlwaysOnTile extends StatelessWidget {
  const _AlwaysOnTile();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: const Icon(Icons.account_balance_rounded),
        title: const Text('Balance card'),
        subtitle: const Text(
          'Always shown — tap the chip for details and period breakdown.',
        ),
        trailing: Icon(
          Icons.lock_outline_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 18,
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _SectionTile extends ConsumerWidget {
  const _SectionTile({required this.section, required this.enabled});

  final HomeSection section;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      onTap: () =>
          ref.read(homeLayoutProvider.notifier).setEnabled(section, !enabled),
      child: Row(
        children: [
          Icon(section.icon),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  section.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: (v) =>
                ref.read(homeLayoutProvider.notifier).setEnabled(section, v),
          ),
        ],
      ),
    );
  }
}
