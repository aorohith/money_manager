import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dev/theme_showcase_screen.dart';

part 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: kDebugMode,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRouteNames.splash,
      builder: (context, state) => const _StubScreen(label: 'Splash'),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRouteNames.onboarding,
      builder: (context, state) => const _StubScreen(label: 'Onboarding'),
    ),
    GoRoute(
      path: AppRoutes.currencySetup,
      name: AppRouteNames.currencySetup,
      builder: (context, state) => const _StubScreen(label: 'Currency Setup'),
    ),
    GoRoute(
      path: AppRoutes.profileSetup,
      name: AppRouteNames.profileSetup,
      builder: (context, state) => const _StubScreen(label: 'Profile Setup'),
    ),
    GoRoute(
      path: AppRoutes.pinSetup,
      name: AppRouteNames.pinSetup,
      builder: (context, state) => const _StubScreen(label: 'PIN Setup'),
    ),
    GoRoute(
      path: AppRoutes.pinLock,
      name: AppRouteNames.pinLock,
      builder: (context, state) => const _StubScreen(label: 'PIN Lock'),
    ),
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          name: AppRouteNames.dashboard,
          builder: (context, state) => const _StubScreen(label: 'Dashboard'),
        ),
        GoRoute(
          path: AppRoutes.transactions,
          name: AppRouteNames.transactions,
          builder: (context, state) => const _StubScreen(label: 'Transactions'),
          routes: [
            GoRoute(
              path: 'add',
              name: AppRouteNames.addTransaction,
              builder: (context, state) =>
                  const _StubScreen(label: 'Add Transaction'),
            ),
            GoRoute(
              path: ':id',
              name: AppRouteNames.transactionDetail,
              builder: (context, state) =>
                  const _StubScreen(label: 'Transaction Detail'),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.budgets,
          name: AppRouteNames.budgets,
          builder: (context, state) => const _StubScreen(label: 'Budgets'),
        ),
        GoRoute(
          path: AppRoutes.analytics,
          name: AppRouteNames.analytics,
          builder: (context, state) => const _StubScreen(label: 'Analytics'),
        ),
        GoRoute(
          path: AppRoutes.goals,
          name: AppRouteNames.goals,
          builder: (context, state) => const _StubScreen(label: 'Goals'),
          routes: [
            GoRoute(
              path: 'add',
              name: AppRouteNames.addGoal,
              builder: (context, state) =>
                  const _StubScreen(label: 'Add Goal'),
            ),
            GoRoute(
              path: ':id',
              name: AppRouteNames.goalDetail,
              builder: (context, state) =>
                  const _StubScreen(label: 'Goal Detail'),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.insights,
          name: AppRouteNames.insights,
          builder: (context, state) => const _StubScreen(label: 'Insights'),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: AppRouteNames.settings,
          builder: (context, state) => const _StubScreen(label: 'Settings'),
        ),
        if (kDebugMode)
          GoRoute(
            path: AppRoutes.themeShowcase,
            name: AppRouteNames.themeShowcase,
            builder: (context, state) => const ThemeShowcaseScreen(),
          ),
      ],
    ),
  ],
);

/// Temporary stub screen used until real screens are implemented.
class _StubScreen extends StatelessWidget {
  const _StubScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text(label)),
    );
  }
}

/// Bottom navigation shell.
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

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
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
            icon: Icon(Icons.bar_chart_rounded),
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
    );
  }
}
