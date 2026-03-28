import 'package:flutter/material.dart';
import '../constants/constants.dart';

enum AppSnackBarType { success, error, info, warning }

void showAppSnackBar(
  BuildContext context, {
  required String message,
  AppSnackBarType type = AppSnackBarType.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  final colorScheme = Theme.of(context).colorScheme;

  final (color, icon) = switch (type) {
    AppSnackBarType.success => (AppColors.success, Icons.check_circle_rounded),
    AppSnackBarType.error => (AppColors.error, Icons.error_rounded),
    AppSnackBarType.warning => (AppColors.warning, Icons.warning_rounded),
    AppSnackBarType.info => (colorScheme.primary, Icons.info_rounded),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: AppSpacing.iconMd),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
}
