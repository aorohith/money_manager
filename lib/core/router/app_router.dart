import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/constants.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/pin_lock_screen.dart';
import '../../features/auth/presentation/pin_setup_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dev/theme_showcase_screen.dart';
import '../../features/onboarding/presentation/currency_setup_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/profile_setup_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/analytics/presentation/screens/category_detail_screen.dart';
import '../../features/analytics/domain/models/analytics_data.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/budgets/presentation/screens/budgets_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/goals/presentation/screens/goal_detail_screen.dart';
import '../../features/insights/presentation/screens/insights_screen.dart';
import '../../features/import/presentation/screens/import_preview_screen.dart';
import '../../features/import/presentation/screens/import_screen.dart';
import '../../features/import/presentation/screens/import_summary_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/sms/presentation/screens/sms_inbox_screen.dart';
import '../../features/sms/presentation/screens/sms_onboarding_screen.dart';
import '../../features/sms/presentation/screens/sms_settings_screen.dart';
import '../../features/transactions/presentation/screens/manage_accounts_screen.dart';
import '../../features/transactions/presentation/screens/manage_categories_screen.dart';
import '../../features/transactions/presentation/screens/account_detail_screen.dart';
import '../../features/transactions/presentation/screens/reconciliation_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../widgets/exit_confirmation_dialog.dart';

part 'app_routes.dart';

/// GoRouter exposed as a Riverpod provider so that the redirect guard can
/// read [authProvider] through a proper [Ref], not [WidgetRef].
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final authAsync = ref.read(authProvider);
      if (authAsync.isLoading) return null;

      final loc = state.uri.path;

      const publicPaths = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.currencySetup,
        AppRoutes.profileSetup,
        AppRoutes.pinSetup,
        AppRoutes.pinLock,
      ];

      // If auth resolution failed (e.g. transient secure-storage IO error),
      // fail closed: keep the user out of protected routes by sending them
      // to the lock screen rather than rendering a screen that may read
      // private data.
      if (authAsync.hasError) {
        if (publicPaths.contains(loc)) return null;
        return AppRoutes.pinLock;
      }

      final status = authAsync.value!;

      if (publicPaths.contains(loc)) {
        // Once authenticated (PIN set or unlocked), leave the auth flow.
        // Splash handles its own navigation, so skip it here.
        if (status == AuthStatus.authenticated && loc != AppRoutes.splash) {
          return AppRoutes.dashboard;
        }
        return null;
      }

      return switch (status) {
        AuthStatus.unauthenticated => AppRoutes.onboarding,
        AuthStatus.pinSetup => AppRoutes.pinSetup,
        AuthStatus.locked => AppRoutes.pinLock,
        AuthStatus.authenticated => null,
      };
    },
    refreshListenable: _AuthStatusListenable(ref),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRouteNames.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.currencySetup,
        name: AppRouteNames.currencySetup,
        builder: (_, __) => const CurrencySetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        name: AppRouteNames.profileSetup,
        builder: (_, __) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.pinSetup,
        name: AppRouteNames.pinSetup,
        builder: (_, __) => const PinSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.pinLock,
        name: AppRouteNames.pinLock,
        builder: (_, __) => const PinLockScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: AppRouteNames.dashboard,
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.transactions,
            name: AppRouteNames.transactions,
            builder: (_, __) => const TransactionsScreen(),
          ),
          GoRoute(
            path: AppRoutes.budgets,
            name: AppRouteNames.budgets,
            builder: (_, __) => const BudgetsScreen(),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            name: AppRouteNames.analytics,
            builder: (_, __) => const AnalyticsScreen(),
            routes: [
              GoRoute(
                path: 'category/:id',
                name: AppRouteNames.analyticsCategory,
                builder: (_, state) {
                  final categoryId =
                      int.tryParse(state.pathParameters['id'] ?? '');
                  if (categoryId == null) {
                    return const _RouteNotFoundScreen(
                      message: 'Invalid category link.',
                    );
                  }
                  final params = state.extra as AnalyticsParams?;
                  return CategoryDetailScreen(
                    categoryId: categoryId,
                    analyticsParams:
                        params ??
                        AnalyticsParams(
                          period: AnalyticsPeriod.month,
                          referenceDate: DateTime.now(),
                        ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.goals,
            name: AppRouteNames.goals,
            builder: (_, __) => const GoalsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: AppRouteNames.goalDetail,
                builder: (_, state) {
                  final goalId =
                      int.tryParse(state.pathParameters['id'] ?? '');
                  if (goalId == null) {
                    return const _RouteNotFoundScreen(
                      message: 'Invalid goal link.',
                    );
                  }
                  return GoalDetailScreen(goalId: goalId);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.insights,
            name: AppRouteNames.insights,
            builder: (_, __) => const InsightsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: AppRouteNames.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.smsInbox,
            name: AppRouteNames.smsInbox,
            builder: (_, __) => const SmsInboxScreen(),
          ),
          GoRoute(
            path: AppRoutes.smsOnboarding,
            name: AppRouteNames.smsOnboarding,
            builder: (_, __) => const SmsOnboardingScreen(),
          ),
          GoRoute(
            path: AppRoutes.smsSettings,
            name: AppRouteNames.smsSettings,
            builder: (_, __) => const SmsSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.manageCategories,
            name: AppRouteNames.manageCategories,
            builder: (_, __) => const ManageCategoriesScreen(),
          ),
          GoRoute(
            path: AppRoutes.manageAccounts,
            name: AppRouteNames.manageAccounts,
            builder: (_, __) => const ManageAccountsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: AppRouteNames.accountDetail,
                builder: (_, state) {
                  final accountId =
                      int.tryParse(state.pathParameters['id'] ?? '');
                  if (accountId == null) {
                    return const _RouteNotFoundScreen(
                      message: 'Invalid account link.',
                    );
                  }
                  return AccountDetailScreen(accountId: accountId);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.reconciliation,
            name: AppRouteNames.reconciliation,
            builder: (_, __) => const ReconciliationScreen(),
          ),
          GoRoute(
            path: AppRoutes.importData,
            name: AppRouteNames.importData,
            builder: (_, __) => const ImportScreen(),
          ),
          GoRoute(
            path: AppRoutes.importPreview,
            name: AppRouteNames.importPreview,
            builder: (_, __) => const ImportPreviewScreen(),
          ),
          GoRoute(
            path: AppRoutes.importSummary,
            name: AppRouteNames.importSummary,
            builder: (_, __) => const ImportSummaryScreen(),
          ),
          if (kDebugMode)
            GoRoute(
              path: AppRoutes.themeShowcase,
              name: AppRouteNames.themeShowcase,
              builder: (_, __) => const ThemeShowcaseScreen(),
            ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Shown when a deep link with an unparseable id (e.g. `goals/abc`) lands on
/// a route that expects an integer id. We render a friendly message and
/// offer a one-tap exit instead of crashing during route build.
class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_off_rounded, size: 56),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.dashboard);
                  }
                },
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bridges Riverpod [authProvider] into a [Listenable] for GoRouter.
class _AuthStatusListenable extends ChangeNotifier {
  _AuthStatusListenable(Ref ref) {
    ref.listen<AsyncValue<AuthStatus>>(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});
  final Widget child;

  int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.transactions)) return 1;
    if (location.startsWith(AppRoutes.budgets)) return 2;
    if (location.startsWith(AppRoutes.analytics)) return 3;
    if (location.startsWith(AppRoutes.settings)) return 4;
    return 0;
  }

  Future<void> _handleSystemPop(BuildContext context, int currentIndex) async {
    // From any non-home tab, the device back button should bring the user
    // back to Home rather than exit the app.
    if (currentIndex != 0) {
      context.go(AppRoutes.dashboard);
      return;
    }
    final shouldExit = await ExitConfirmationDialog.show(context);
    if (shouldExit) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _locationToIndex(location);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _handleSystemPop(context, currentIndex);
        },
        child: child,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.outlineDark : AppColors.outline,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          animationDuration: const Duration(milliseconds: 250),
          onDestinationSelected: (index) {
            HapticFeedback.selectionClick();
            switch (index) {
              case 0:
                context.go(AppRoutes.dashboard);
              case 1:
                context.go(AppRoutes.transactions);
              case 2:
                context.go(AppRoutes.budgets);
              case 3:
                context.go(AppRoutes.analytics);
              case 4:
                context.go(AppRoutes.settings);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Transactions',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: Icon(Icons.pie_chart_rounded),
              label: 'Budgets',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

