import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../widgets/exit_confirmation_dialog.dart';

/// Centralized device-back handling so leaving the app always requires
/// explicit confirmation.
abstract final class AppBackHandler {
  /// Back pressed inside the main [ShellRoute] (bottom-nav shell).
  ///
  /// Order: pop nested routes → return to home tab → confirm exit.
  static Future<void> handleShellBack(
    BuildContext context, {
    required int bottomNavIndex,
  }) async {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    if (bottomNavIndex != 0) {
      router.go(AppRoutes.dashboard);
      return;
    }
    await _confirmAndExit(context);
  }

  /// Back pressed on routes outside the shell (splash, onboarding, lock).
  ///
  /// Order: pop in-app stack → confirm exit.
  static Future<void> handleOutsideShellBack(BuildContext context) async {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    await _confirmAndExit(context);
  }

  static Future<void> _confirmAndExit(BuildContext context) async {
    final shouldExit = await ExitConfirmationDialog.show(context);
    if (shouldExit && context.mounted) {
      await SystemNavigator.pop();
    }
  }
}
