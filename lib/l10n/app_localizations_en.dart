// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Money Manager';

  @override
  String get onboardingWelcomeTitle => 'Take control of your money';

  @override
  String get onboardingWelcomeSubtitle =>
      'Track spending, set budgets, and reach your goals — all in one place.';

  @override
  String get onboardingTrackTitle => 'Track every transaction';

  @override
  String get onboardingTrackSubtitle =>
      'Easily log income and expenses with smart categories.';

  @override
  String get onboardingInsightTitle => 'Know where your money goes';

  @override
  String get onboardingInsightSubtitle =>
      'Beautiful charts and smart insights help you make better decisions.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get currencySetupTitle => 'Select your currency';

  @override
  String get currencySearchHint => 'Search currencies…';

  @override
  String get profileSetupTitle => 'What should we call you?';

  @override
  String get profileNameLabel => 'Your name';

  @override
  String get profileAvatarTitle => 'Pick a color';

  @override
  String get pinSetupTitle => 'Create your PIN';

  @override
  String get pinSetupSubtitle => 'Your PIN keeps your financial data private.';

  @override
  String get pinConfirmTitle => 'Confirm your PIN';

  @override
  String get pinEnterTitle => 'Enter your PIN';

  @override
  String get pinMismatch => 'PINs don\'t match. Please try again.';

  @override
  String get pinWrong => 'Incorrect PIN';

  @override
  String pinLockout(int seconds) {
    return 'Too many attempts. Try again in ${seconds}s.';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navBudgets => 'Budgets';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navSettings => 'Settings';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get note => 'Note (optional)';

  @override
  String get date => 'Date';

  @override
  String get account => 'Account';

  @override
  String get noTransactionsTitle => 'No transactions yet';

  @override
  String get noTransactionsSubtitle => 'Tap + to add your first transaction.';

  @override
  String get deleteTransactionTitle => 'Delete transaction?';

  @override
  String get deleteTransactionMessage => 'This action cannot be undone.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get importData => 'Import data';

  @override
  String get importPreview => 'Import preview';

  @override
  String get importSummary => 'Import summary';
}
