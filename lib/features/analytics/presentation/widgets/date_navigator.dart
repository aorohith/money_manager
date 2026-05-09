import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/providers/analytics_providers.dart';

class DateNavigator extends ConsumerWidget {
  const DateNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(analyticsParamsProvider);
    final label = periodLabel(params);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Disable "next" if it would go into the future
    final next = nextPeriod(params);
    final (nextStart, _) = periodRange(next);
    final now = DateTime.now();
    final canGoNext = nextStart.isBefore(now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding - 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Prev button
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              final prev = previousPeriod(params);
              ref.read(analyticsDateProvider.notifier).state =
                  prev.referenceDate;
            },
            isDark: isDark,
          ),
          // Label
          Expanded(
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          // Next button
          _NavButton(
            icon: Icons.chevron_right_rounded,
            enabled: canGoNext,
            onTap: canGoNext
                ? () {
                    HapticFeedback.lightImpact();
                    final n = nextPeriod(params);
                    ref.read(analyticsDateProvider.notifier).state =
                        n.referenceDate;
                  }
                : null,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.isDark,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outline,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
              : (isDark ? AppColors.textTertiaryDark : AppColors.textDisabled),
        ),
      ),
    );
  }
}
