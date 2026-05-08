import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/sms/sms_ingestion_service.dart';
import '../../domain/providers/sms_providers.dart';

class SmsOnboardingScreen extends ConsumerStatefulWidget {
  const SmsOnboardingScreen({super.key});

  @override
  ConsumerState<SmsOnboardingScreen> createState() =>
      _SmsOnboardingScreenState();
}

class _SmsOnboardingScreenState extends ConsumerState<SmsOnboardingScreen>
    with WidgetsBindingObserver {
  bool _waitingForReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called automatically whenever the app returns to the foreground.
  ///
  /// If the user left to grant notification access and has now returned,
  /// re-check the permission and navigate back if it was granted.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForReturn) {
      _waitingForReturn = false;
      _onReturnFromSettings();
    }
  }

  Future<void> _onReturnFromSettings() async {
    // Refresh the permission provider so the banner/settings update everywhere
    ref.invalidate(smsPermissionProvider);

    final granted = await SmsIngestionService.isNotificationListenerEnabled();
    if (granted && mounted) {
      _safeBack();
    }
    // If not granted, stay on screen so the user can try again or skip
  }

  /// Navigates back safely regardless of how this screen was reached.
  ///
  /// Using `context.go()` to reach this screen replaces the stack (nothing
  /// to pop); `context.push()` leaves a previous route to pop back to.
  /// `canPop()` handles both cases.
  void _safeBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  Future<void> _grantAccess() async {
    // Mark that we are leaving to system settings so that
    // didChangeAppLifecycleState knows to re-check when we return.
    setState(() => _waitingForReturn = true);
    await SmsIngestionService.openNotificationSettings();
    // Note: openNotificationSettings() returns immediately after launching
    // the Android Settings intent. The actual navigation back into the app
    // is handled by didChangeAppLifecycleState(AppLifecycleState.resumed).
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _safeBack,
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Hero icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brand, AppColors.brandLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: const Icon(Icons.sms_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Smart Expense\nDetection',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Automatically detect expenses from your bank notifications. No manual entry needed.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Feature bullets
              ..._bullets(context, isDark),
              const Spacer(),
              // Privacy note
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                      color:
                          isDark ? AppColors.outlineDark : AppColors.outline),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '100% on-device. Your bank messages never leave your phone.',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Primary CTA
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: _grantAccess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Enable Notification Access',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Skip
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: TextButton(
                  onPressed: _safeBack,
                  child: Text(
                    "I'll do it manually",
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _bullets(BuildContext context, bool isDark) {
    const items = [
      (Icons.notifications_active_outlined, 'Reads banking notifications only',
          'Ignores OTPs, spam, and promotions'),
      (Icons.category_outlined, 'Smart categorisation',
          'Swiggy → Food, Uber → Transport — auto-learned'),
      (Icons.reviews_outlined, 'You stay in control',
          'Review and approve before anything is saved'),
    ];
    return items
        .map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.brand.withAlpha(18),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(item.$1,
                        size: 18, color: AppColors.brand),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$2,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.$3,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}
