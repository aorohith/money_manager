import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../core/widgets/widgets.dart';

class ThemeShowcaseScreen extends StatefulWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  State<ThemeShowcaseScreen> createState() => _ThemeShowcaseScreenState();
}

class _ThemeShowcaseScreenState extends State<ThemeShowcaseScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    assert(kDebugMode, 'ThemeShowcaseScreen must only be used in debug mode');
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Showcase')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // ─── Color Swatches ──────────────────────────────────────────────
          _Section(
            title: 'Brand Colors',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _Swatch('Brand', AppColors.brand),
                _Swatch('Income', ext.incomeColor),
                _Swatch('Income BG', ext.incomeSurface),
                _Swatch('Expense', ext.expenseColor),
                _Swatch('Expense BG', ext.expenseSurface),
                _Swatch('Warning', ext.warningColor),
              ],
            ),
          ),
          _Section(
            title: 'Material Color Scheme',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _Swatch('Primary', theme.colorScheme.primary),
                _Swatch('On Primary', theme.colorScheme.onPrimary, dark: true),
                _Swatch('Secondary', theme.colorScheme.secondary),
                _Swatch('Surface', theme.colorScheme.surface),
                _Swatch('Card', ext.cardSurface),
                _Swatch('Outline', theme.colorScheme.outline),
                _Swatch('Error', theme.colorScheme.error),
              ],
            ),
          ),

          // ─── Typography ──────────────────────────────────────────────────
          _Section(
            title: 'Typography',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Display Large', style: theme.textTheme.displayLarge),
                Text('Headline Medium', style: theme.textTheme.headlineMedium),
                Text('Title Large', style: theme.textTheme.titleLarge),
                Text('Title Medium', style: theme.textTheme.titleMedium),
                Text('Body Large', style: theme.textTheme.bodyLarge),
                Text('Body Medium', style: theme.textTheme.bodyMedium),
                Text('Body Small', style: theme.textTheme.bodySmall),
                Text('Label Large', style: theme.textTheme.labelLarge),
                Text('Label Small', style: theme.textTheme.labelSmall),
              ],
            ),
          ),

          // ─── Buttons ─────────────────────────────────────────────────────
          _Section(
            title: 'AppButton — 3 Variants',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  label: 'Filled Button',
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton.outlined(
                  label: 'Outlined Button',
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton.text(
                  label: 'Text Button',
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Loading…',
                  onPressed: () {},
                  loading: true,
                ),
              ],
            ),
          ),

          // ─── TextField ───────────────────────────────────────────────────
          _Section(
            title: 'AppTextField',
            child: Column(
              children: [
                const AppTextField(
                  label: 'Amount',
                  hint: '0.00',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.sm),
                const AppTextField(
                  label: 'Note (optional)',
                  hint: 'Add a note…',
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.sm),
                const AppTextField(
                  label: 'Disabled field',
                  hint: 'Cannot edit',
                  enabled: false,
                ),
              ],
            ),
          ),

          // ─── Card ────────────────────────────────────────────────────────
          _Section(
            title: 'AppCard',
            child: Column(
              children: [
                AppCard(
                  child: const Text('Tappable card — tap me!'),
                  onTap: () => showAppSnackBar(
                    context,
                    message: 'Card tapped!',
                    type: AppSnackBarType.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const AppCard(
                  child: Text('Non-interactive card'),
                ),
              ],
            ),
          ),

          // ─── Empty State ─────────────────────────────────────────────────
          _Section(
            title: 'EmptyState',
            child: EmptyState(
              title: 'No transactions yet',
              subtitle: 'Tap + to add your first transaction.',
              icon: Icons.receipt_long_rounded,
              actionLabel: 'Add Transaction',
              action: () {},
            ),
          ),

          // ─── Shimmer ─────────────────────────────────────────────────────
          _Section(
            title: 'ShimmerLoader',
            child: ShimmerLoader(
              isLoading: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: double.infinity, height: 120),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: const [
                      ShimmerBox(width: 48, height: 48, borderRadius: 24),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(width: double.infinity, height: 14),
                            SizedBox(height: 6),
                            ShimmerBox(width: 120, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Bottom Sheet ────────────────────────────────────────────────
          _Section(
            title: 'AppBottomSheet',
            child: AppButton(
              label: 'Open Bottom Sheet',
              onPressed: () => showAppBottomSheet(
                context: context,
                title: 'Sample Bottom Sheet',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Bottom sheet content goes here.'),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      variant: AppButtonVariant.outlined,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Snackbars ───────────────────────────────────────────────────
          _Section(
            title: 'SnackBars',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ElevatedButton(
                  onPressed: () => showAppSnackBar(context,
                      message: 'Transaction saved!',
                      type: AppSnackBarType.success),
                  child: const Text('Success'),
                ),
                ElevatedButton(
                  onPressed: () => showAppSnackBar(context,
                      message: 'Something went wrong.',
                      type: AppSnackBarType.error),
                  child: const Text('Error'),
                ),
                ElevatedButton(
                  onPressed: () => showAppSnackBar(context,
                      message: 'Budget at 80%!',
                      type: AppSnackBarType.warning),
                  child: const Text('Warning'),
                ),
                ElevatedButton(
                  onPressed: () => showAppSnackBar(context,
                      message: 'Sync complete.',
                      type: AppSnackBarType.info),
                  child: const Text('Info'),
                ),
              ],
            ),
          ),

          // ─── Loading Overlay ─────────────────────────────────────────────
          _Section(
            title: 'LoadingOverlay',
            child: LoadingOverlay(
              isLoading: _loading,
              child: AppButton(
                label: _loading ? 'Loading…' : 'Trigger Loading Overlay',
                onPressed: () async {
                  setState(() => _loading = true);
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) setState(() => _loading = false);
                },
              ),
            ),
          ),

          // ─── Category Color Palette ───────────────────────────────────────
          _Section(
            title: 'Category Palette',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: AppColors.categoryPalette
                  .map((c) => _Swatch('', c, showLabel: false))
                  .toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color,
      {this.dark = false, this.showLabel = true});
  final String label;
  final Color color;
  final bool dark;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ],
    );
  }
}
