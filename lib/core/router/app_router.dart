import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/pin_lock_screen.dart';
import '../../features/auth/presentation/pin_setup_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dev/theme_showcase_screen.dart';
import '../../features/onboarding/presentation/currency_setup_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/profile_setup_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';

part 'app_routes.dart';

/// GoRouter exposed as a Riverpod provider so that the redirect guard can
/// read [authProvider] through a proper [Ref], not [WidgetRef].
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final authAsync = ref.read(authProvider);
      if (authAsync.isLoading || authAsync.hasError) return null;

      final status = authAsync.value!;
      final loc = state.uri.path;

      const publicPaths = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.currencySetup,
        AppRoutes.profileSetup,
        AppRoutes.pinSetup,
        AppRoutes.pinLock,
      ];
      if (publicPaths.contains(loc)) return null;

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
            builder: (_, __) => const _StubScreen(label: 'Dashboard'),
          ),
          GoRoute(
            path: AppRoutes.transactions,
            name: AppRouteNames.transactions,
            builder: (_, __) => const _StubScreen(label: 'Transactions'),
            routes: [
              GoRoute(
                path: 'add',
                name: AppRouteNames.addTransaction,
                builder: (_, __) =>
                    const _StubScreen(label: 'Add Transaction'),
              ),
              GoRoute(
                path: ':id',
                name: AppRouteNames.transactionDetail,
                builder: (_, __) =>
                    const _StubScreen(label: 'Transaction Detail'),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.budgets,
            name: AppRouteNames.budgets,
            builder: (_, __) => const _StubScreen(label: 'Budgets'),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            name: AppRouteNames.analytics,
            builder: (_, __) => const _StubScreen(label: 'Analytics'),
          ),
          GoRoute(
            path: AppRoutes.goals,
            name: AppRouteNames.goals,
            builder: (_, __) => const _StubScreen(label: 'Goals'),
            routes: [
              GoRoute(
                path: 'add',
                name: AppRouteNames.addGoal,
                builder: (_, __) => const _StubScreen(label: 'Add Goal'),
              ),
              GoRoute(
                path: ':id',
                name: AppRouteNames.goalDetail,
                builder: (_, __) => const _StubScreen(label: 'Goal Detail'),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.insights,
            name: AppRouteNames.insights,
            builder: (_, __) => const _StubScreen(label: 'Insights'),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: AppRouteNames.settings,
            builder: (_, __) => const _StubScreen(label: 'Settings'),
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

/// Bridges Riverpod [authProvider] into a [Listenable] for GoRouter.
class _AuthStatusListenable extends ChangeNotifier {
  _AuthStatusListenable(Ref ref) {
    ref.listen<AsyncValue<AuthStatus>>(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

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
