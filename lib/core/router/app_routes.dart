part of 'app_router.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String currencySetup = '/onboarding/currency';
  static const String profileSetup = '/onboarding/profile';
  static const String pinSetup = '/onboarding/pin';
  static const String pinLock = '/lock';
  static const String dashboard = '/home';
  static const String transactions = '/transactions';
  static const String budgets = '/budgets';
  static const String analytics = '/analytics';
  static const String goals = '/goals';
  static const String insights = '/insights';
  static const String settings = '/settings';
  static const String smsInbox = '/sms/inbox';
  static const String smsOnboarding = '/sms/onboarding';
  static const String smsSettings = '/sms/settings';
  static const String manageCategories = '/settings/categories';
  static const String manageAccounts = '/settings/accounts';
  static const String reconciliation = '/settings/reconciliation';
  static const String analyticsCategory = '/analytics/category';
  static const String themeShowcase = '/dev/theme';
}

abstract final class AppRouteNames {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String currencySetup = 'currency-setup';
  static const String profileSetup = 'profile-setup';
  static const String pinSetup = 'pin-setup';
  static const String pinLock = 'pin-lock';
  static const String dashboard = 'dashboard';
  static const String transactions = 'transactions';
  static const String addTransaction = 'add-transaction';
  static const String transactionDetail = 'transaction-detail';
  static const String budgets = 'budgets';
  static const String analytics = 'analytics';
  static const String goals = 'goals';
  static const String addGoal = 'add-goal';
  static const String goalDetail = 'goal-detail';
  static const String insights = 'insights';
  static const String settings = 'settings';
  static const String smsInbox = 'sms-inbox';
  static const String smsOnboarding = 'sms-onboarding';
  static const String smsSettings = 'sms-settings';
  static const String manageCategories = 'manage-categories';
  static const String manageAccounts = 'manage-accounts';
  static const String accountDetail = 'account-detail';
  static const String reconciliation = 'reconciliation';
  static const String analyticsCategory = 'analytics-category';
  static const String themeShowcase = 'theme-showcase';
}
