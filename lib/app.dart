import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/isar_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/domain/providers/settings_providers.dart';
import 'features/sms/data/repositories/sms_repository.dart';
import 'features/transactions/domain/providers/transaction_providers.dart';
import 'l10n/app_localizations.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  DateTime? _backgroundedAt;
  bool _showPrivacyOverlay = false;
  static const _autoLockDuration = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Seed default categories & accounts on first launch
    ref.read(dbSeederProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      // `inactive` fires for transient interruptions (incoming call, biometric
      // sheet, Control Center). Treating it as backgrounded would lock the
      // user mid-biometric-auth, so we only react to `paused`/`hidden`.
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt = DateTime.now();
        if (Platform.isIOS) {
          // iOS snapshots the screen when the app moves to the background;
          // showing the overlay before the snapshot keeps balances + PIN
          // entry out of the task-switcher preview.
          if (mounted && !_showPrivacyOverlay) {
            setState(() => _showPrivacyOverlay = true);
          }
        }
      case AppLifecycleState.inactive:
        if (Platform.isIOS && mounted && !_showPrivacyOverlay) {
          setState(() => _showPrivacyOverlay = true);
        }
      case AppLifecycleState.resumed:
        if (mounted && _showPrivacyOverlay) {
          setState(() => _showPrivacyOverlay = false);
        }
        final bg = _backgroundedAt;
        if (bg != null &&
            DateTime.now().difference(bg) >= _autoLockDuration) {
          ref.read(authProvider.notifier).lock();
        }
        _backgroundedAt = null;
        // Cheap maintenance work that should run more often than once per
        // cold start. Keeps the parsed-SMS table from accumulating
        // privacy-sensitive history forever.
        unawaited(_pruneSmsHistory());
      default:
        break;
    }
  }

  Future<void> _pruneSmsHistory() async {
    try {
      final isar = ref.read(isarProvider);
      await SmsRepository(isar).pruneOldParsedTransactions();
    } catch (_) {
      // SMS table may not be open in tests; swallow silently.
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Money Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (_showPrivacyOverlay) const _PrivacyOverlay(),
          ],
        );
      },
    );
  }
}

/// Opaque scrim shown while the iOS task switcher captures its snapshot of
/// the app. Android relies on `FLAG_SECURE` (set in `MainActivity.kt`) which
/// blacks out the snapshot at the OS level instead.
class _PrivacyOverlay extends StatelessWidget {
  const _PrivacyOverlay();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF0F1115),
      child: SizedBox.expand(
        child: Center(
          child: Icon(
            Icons.lock_rounded,
            size: 56,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
