import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/navigation/app_back_handler.dart';
import 'package:money_manager/l10n/app_localizations.dart';

void main() {
  Future<void> simulateSystemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  Future<void> invokeShellBack(
    WidgetTester tester, {
    required Finder from,
    required int bottomNavIndex,
  }) async {
    final context = tester.element(from);
    unawaited(
      AppBackHandler.handleShellBack(
        context,
        bottomNavIndex: bottomNavIndex,
      ),
    );
    await tester.pump();
  }

  Future<void> invokeOutsideShellBack(
    WidgetTester tester, {
    required Finder from,
  }) async {
    final context = tester.element(from);
    unawaited(AppBackHandler.handleOutsideShellBack(context));
    await tester.pump();
  }

  group('AppBackHandler — shell', () {
    testWidgets('pops nested route before exit dialog', (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          ShellRoute(
            builder: (context, state, child) => PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                AppBackHandler.handleShellBack(
                  context,
                  bottomNavIndex: 0,
                );
              },
              child: child,
            ),
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const Scaffold(body: Text('home')),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (_, __) =>
                        const Scaffold(body: Text('detail')),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(_routerApp(router));
      router.go('/home/detail');
      await tester.pumpAndSettle();

      expect(find.text('detail'), findsOneWidget);

      await simulateSystemBack(tester);

      expect(find.text('Exit Money Manager?'), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('non-home tab navigates home before exit dialog', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          ShellRoute(
            builder: (context, state, child) {
              final index = state.uri.path == '/settings' ? 1 : 0;
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) {
                  if (didPop) return;
                  AppBackHandler.handleShellBack(
                    context,
                    bottomNavIndex: index,
                  );
                },
                child: child,
              );
            },
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const Scaffold(body: Text('home')),
              ),
              GoRoute(
                path: '/settings',
                builder: (_, __) =>
                    const Scaffold(body: Text('settings')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(_routerApp(router));
      router.go('/settings');
      await tester.pumpAndSettle();

      await invokeShellBack(
        tester,
        from: find.text('settings'),
        bottomNavIndex: 1,
      );
      await tester.pumpAndSettle();

      expect(find.text('Exit Money Manager?'), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('home tab shows exit confirmation dialog', (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          ShellRoute(
            builder: (context, state, child) => PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                AppBackHandler.handleShellBack(
                  context,
                  bottomNavIndex: 0,
                );
              },
              child: child,
            ),
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const Scaffold(body: Text('home')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(_routerApp(router));
      await tester.pumpAndSettle();

      await invokeShellBack(
        tester,
        from: find.text('home'),
        bottomNavIndex: 0,
      );

      expect(find.text('Exit Money Manager?'), findsOneWidget);
    });
  });

  group('AppBackHandler — outside shell', () {
    testWidgets('shows exit confirmation when stack cannot pop', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/lock',
        routes: [
          GoRoute(
            path: '/lock',
            builder: (_, __) => const Scaffold(body: Text('lock')),
          ),
        ],
      );

      await tester.pumpWidget(
        _routerApp(
          router,
          wrapExitPopScope: true,
        ),
      );
      await tester.pumpAndSettle();

      await invokeOutsideShellBack(tester, from: find.text('lock'));

      expect(find.text('Exit Money Manager?'), findsOneWidget);
    });
  });
}

Widget _routerApp(GoRouter router, {bool wrapExitPopScope = false}) {
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: wrapExitPopScope
        ? (context, child) => PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                AppBackHandler.handleOutsideShellBack(context);
              },
              child: child ?? const SizedBox.shrink(),
            )
        : null,
  );
}
