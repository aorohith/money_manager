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
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final double elevation;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final radius =
        borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Card(
        margin: margin ?? EdgeInsets.zero,
        elevation: elevation,
        color: color ?? ext.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ??
                const EdgeInsets.all(AppSpacing.cardPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}
