import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/isar_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../transactions/domain/providers/transaction_providers.dart';
import '../../data/export_service.dart';
import '../../domain/providers/settings_providers.dart';
import '../widgets/biometric_tile.dart';
import '../widgets/change_currency_sheet.dart';
import '../widgets/change_pin_sheet.dart';
import '../widgets/edit_profile_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Settings'),
            floating: true,
            snap: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile card
                _ProfileCard(),
                const SizedBox(height: AppSpacing.lg),

                // Appearance
                _SectionHeader('Appearance'),
                const SizedBox(height: AppSpacing.sm),
                _ThemeTile(),
                const SizedBox(height: AppSpacing.sm),
                _HomeLayoutTile(),
                const SizedBox(height: AppSpacing.lg),

                // Currency
                _SectionHeader('Currency'),
                const SizedBox(height: AppSpacing.sm),
                _CurrencyTile(),
                const SizedBox(height: AppSpacing.lg),

                // Security
                _SectionHeader('Security'),
                const SizedBox(height: AppSpacing.sm),
                _ChangePinTile(),
                const SizedBox(height: AppSpacing.sm),
                const BiometricTile(),
                const SizedBox(height: AppSpacing.lg),

                // Manage
                _SectionHeader('Manage'),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  onTap: () => context.push(AppRoutes.manageCategories),
                  child: const ListTile(
                    leading: Icon(Icons.label_rounded),
                    title: Text('Categories'),
                    subtitle: Text('Add, edit or delete categories'),
                    trailing: Icon(Icons.chevron_right_rounded, size: 18),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  onTap: () => context.push(AppRoutes.manageAccounts),
                  child: const ListTile(
                    leading: Icon(Icons.account_balance_wallet_rounded),
                    title: Text('Accounts'),
                    subtitle: Text('Add, edit or delete accounts'),
                    trailing: Icon(Icons.chevron_right_rounded, size: 18),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  onTap: () => context.push(AppRoutes.reconciliation),
                  child: const ListTile(
                    leading: Icon(Icons.balance_rounded),
                    title: Text('Reconciliation'),
                    subtitle: Text('Resolve account balance discrepancies'),
                    trailing: Icon(Icons.chevron_right_rounded, size: 18),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Auto-detection
                _SectionHeader('Auto-Detection'),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  onTap: () => context.push(AppRoutes.smsSettings),
                  child: const ListTile(
                    leading: Icon(Icons.sms_rounded),
                    title: Text('SMS Expense Detection'),
                    subtitle: Text('Auto-log from bank notifications'),
                    trailing: Icon(Icons.chevron_right_rounded, size: 18),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Data
                _SectionHeader('Data'),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  onTap: () => context.push(AppRoutes.importData),
                  child: const ListTile(
                    leading: Icon(Icons.upload_file_rounded),
                    title: Text('Import data'),
                    subtitle: Text('Import transactions from Excel or PDF'),
                    trailing: Icon(Icons.chevron_right_rounded, size: 18),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ExportCsvTile(),
                const SizedBox(height: AppSpacing.sm),
                _ExportPdfTile(),
                const SizedBox(height: AppSpacing.lg),

                // About
                _SectionHeader('About'),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('Money Manager'),
                    subtitle: const Text('Version 1.0.0'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Danger zone
                _SectionHeader('Danger Zone'),
                const SizedBox(height: AppSpacing.sm),
                _ClearDataTile(),
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.titleSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    ),
  );
}

// ── Profile card ──────────────────────────────────────────────────────────────

class _ProfileCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileNameProvider).valueOrNull ?? '';
    final colorVal = ref.watch(profileColorProvider).valueOrNull ?? 0xFF00BFA5;
    final color = Color(colorVal);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return AppCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          radius: 24,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          name.isNotEmpty ? name : 'Set up profile',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Tap to edit profile'),
        trailing: const Icon(Icons.chevron_right_rounded),
        contentPadding: EdgeInsets.zero,
        onTap: () => showEditProfileSheet(context),
      ),
    );
  }
}

// ── Theme tile ────────────────────────────────────────────────────────────────

class _ThemeTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.palette_outlined),
              title: Text('Theme'),
              contentPadding: EdgeInsets.zero,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.settings_brightness_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_rounded),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (s) =>
                    ref.read(themeModeProvider.notifier).setThemeMode(s.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home layout tile ──────────────────────────────────────────────────────────

class _HomeLayoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(AppRoutes.homeLayout),
      child: const ListTile(
        leading: Icon(Icons.dashboard_customize_rounded),
        title: Text('Home screen'),
        subtitle: Text('Choose which sections appear on Home'),
        trailing: Icon(Icons.chevron_right_rounded, size: 18),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Currency tile ─────────────────────────────────────────────────────────────

class _CurrencyTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(currencyCodeProvider).valueOrNull ?? 'USD';
    final symbol = ref.watch(currencySymbolProvider).valueOrNull ?? '\$';

    return AppCard(
      onTap: () => showChangeCurrencySheet(context),
      child: ListTile(
        leading: const Icon(Icons.currency_exchange_rounded),
        title: const Text('Currency'),
        subtitle: Text('$code ($symbol)'),
        trailing: const Icon(Icons.chevron_right_rounded),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Security tiles ────────────────────────────────────────────────────────────

class _ChangePinTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => showChangePinSheet(context),
      child: const ListTile(
        leading: Icon(Icons.lock_outline_rounded),
        title: Text('Change PIN'),
        trailing: Icon(Icons.chevron_right_rounded),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Export tiles ───────────────────────────────────────────────────────────────

class _ExportCsvTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      onTap: () => _export(context, ref, csv: true),
      child: const ListTile(
        leading: Icon(Icons.table_chart_outlined),
        title: Text('Export as CSV'),
        subtitle: Text('Share your transactions as a spreadsheet'),
        trailing: Icon(Icons.share_rounded),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _ExportPdfTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      onTap: () => _export(context, ref, csv: false),
      child: const ListTile(
        leading: Icon(Icons.picture_as_pdf_outlined),
        title: Text('Export as PDF'),
        subtitle: Text('Share a formatted report'),
        trailing: Icon(Icons.share_rounded),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

Future<void> _export(
  BuildContext context,
  WidgetRef ref, {
  required bool csv,
}) async {
  String? exportedPath;
  try {
    showAppSnackBar(
      context,
      message: 'Preparing export…',
      type: AppSnackBarType.info,
    );
    final repo = ref.read(transactionRepositoryProvider);
    final categories = ref.read(categoriesProvider).valueOrNull ?? [];
    final symbol = ref.read(currencySymbolProvider).valueOrNull ?? r'$';
    final service =
        ExportService(repo, categories, currencySymbol: symbol);
    exportedPath =
        csv ? await service.exportCsv() : await service.exportPdf();
    await Share.shareXFiles(
      [XFile(exportedPath)],
      subject: csv
          ? 'Money Manager — Transactions CSV'
          : 'Money Manager — Transactions Report',
    );
  } catch (e, st) {
    // Keep the raw exception out of the user-facing snackbar (it can leak
    // file paths / internal class names) but log it for debugging.
    if (kDebugMode) debugPrint('[Export] failed: $e\n$st');
    if (context.mounted) {
      showAppSnackBar(
        context,
        message: csv
            ? 'Failed to export CSV. Please try again.'
            : 'Failed to export PDF. Please try again.',
        type: AppSnackBarType.error,
      );
    }
  } finally {
    if (exportedPath != null) {
      // The share sheet returns once the user dismisses it; the file has
      // been read by the receiving app by that point so we can safely
      // reclaim the cache space.
      unawaited(ExportService.deleteExportFile(exportedPath));
    }
  }
}

// ── Clear data ────────────────────────────────────────────────────────────────

class _ClearDataTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      onTap: () => _confirmClear(context, ref),
      child: ListTile(
        leading: Icon(
          Icons.delete_forever_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(
          'Clear All Data',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        subtitle: const Text('Delete all transactions, budgets, and settings'),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your data and reset the app. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Clear Everything',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final isar = ref.read(isarProvider);
      await isar.writeTxn(() => isar.clear());
      final ds = ref.read(authDatasourceProvider);
      await ds.clearAllData();
      if (context.mounted) {
        ref.invalidate(authProvider);
        context.go(AppRoutes.splash);
      }
    }
  }
}
