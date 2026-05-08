import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Money Manager'**
  String get appName;

  /// Onboarding first page title
  ///
  /// In en, this message translates to:
  /// **'Take control of your money'**
  String get onboardingWelcomeTitle;

  /// Onboarding first page subtitle
  ///
  /// In en, this message translates to:
  /// **'Track spending, set budgets, and reach your goals — all in one place.'**
  String get onboardingWelcomeSubtitle;

  /// Onboarding second page title
  ///
  /// In en, this message translates to:
  /// **'Track every transaction'**
  String get onboardingTrackTitle;

  /// Onboarding second page subtitle
  ///
  /// In en, this message translates to:
  /// **'Easily log income and expenses with smart categories.'**
  String get onboardingTrackSubtitle;

  /// Onboarding third page title
  ///
  /// In en, this message translates to:
  /// **'Know where your money goes'**
  String get onboardingInsightTitle;

  /// Onboarding third page subtitle
  ///
  /// In en, this message translates to:
  /// **'Beautiful charts and smart insights help you make better decisions.'**
  String get onboardingInsightSubtitle;

  /// Primary CTA on onboarding last page
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Skip button label
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Currency setup screen title
  ///
  /// In en, this message translates to:
  /// **'Select your currency'**
  String get currencySetupTitle;

  /// Currency search field hint
  ///
  /// In en, this message translates to:
  /// **'Search currencies…'**
  String get currencySearchHint;

  /// Profile setup screen title
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get profileSetupTitle;

  /// Name input label on profile setup
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileNameLabel;

  /// Avatar color picker title
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get profileAvatarTitle;

  /// PIN setup screen title
  ///
  /// In en, this message translates to:
  /// **'Create your PIN'**
  String get pinSetupTitle;

  /// PIN setup subtitle
  ///
  /// In en, this message translates to:
  /// **'Your PIN keeps your financial data private.'**
  String get pinSetupSubtitle;

  /// PIN confirmation step title
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get pinConfirmTitle;

  /// PIN lock screen title
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get pinEnterTitle;

  /// Error shown when PINs don't match during setup
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Please try again.'**
  String get pinMismatch;

  /// Error shown when entered PIN is wrong
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get pinWrong;

  /// Message shown during lockout
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds}s.'**
  String pinLockout(int seconds);

  /// Bottom nav label for home/dashboard
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav label for transactions
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// Bottom nav label for budgets
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get navBudgets;

  /// Bottom nav label for analytics
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// Bottom nav label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// FAB label and sheet title for adding a transaction
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// Income transaction type label
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Expense transaction type label
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Note field label
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get note;

  /// Date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Account field label
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Empty state title for transactions list
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsTitle;

  /// Empty state subtitle for transactions list
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first transaction.'**
  String get noTransactionsSubtitle;

  /// Confirmation dialog title for deleting a transaction
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get deleteTransactionTitle;

  /// Confirmation dialog message for deleting a transaction
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteTransactionMessage;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Settings tile and import screen title
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importData;

  /// Import preview screen title
  ///
  /// In en, this message translates to:
  /// **'Import preview'**
  String get importPreview;

  /// Import summary screen title
  ///
  /// In en, this message translates to:
  /// **'Import summary'**
  String get importSummary;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
