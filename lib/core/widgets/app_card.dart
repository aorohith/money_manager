import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../theme/app_theme_extension.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.elevation = 0,
    this.semanticLabel,
    this.showBorder = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final double elevation;
  final String? semanticLabel;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius =
        borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Container(
        margin: margin ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: color ?? ext.cardSurface,
          borderRadius: radius,
          border: showBorder
              ? Border.all(
                  color: isDark
                      ? AppColors.outlineDark
                      : AppColors.outline,
                  width: 1,
                )
              : null,
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withAlpha(60)
                        : Colors.black.withAlpha(10),
                    blurRadius: elevation * 4,
                    spreadRadius: -1,
                    offset: Offset(0, elevation),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashColor:
                Theme.of(context).colorScheme.primary.withAlpha(12),
            highlightColor:
                Theme.of(context).colorScheme.primary.withAlpha(6),
            child: Padding(
              padding: padding ??
                  const EdgeInsets.all(AppSpacing.cardPadding),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
