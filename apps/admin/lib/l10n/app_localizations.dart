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

  /// Product name at the top of the sign-in form (spec §15).
  ///
  /// In en, this message translates to:
  /// **'Nesty Admin'**
  String get appName;

  /// Label of the email field on the sign-in form (spec §15 Auth).
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Label of the password field on the sign-in form (spec §15 Auth).
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Validation message when the sign-in email field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get emailRequired;

  /// Validation message when the sign-in password field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get passwordRequired;

  /// Button that submits the sign-in form (spec §15 Auth).
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Accessibility label for the progress indicator shown in the sign-in button while signing in.
  ///
  /// In en, this message translates to:
  /// **'Signing in'**
  String get signingIn;

  /// Signs the current user out. Navigation rail button and the Not authorized screen.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Shows which account is signed in, on the Not authorized screen.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// Title shown to signed-in users without an admins/{uid} document (spec §15 Auth).
  ///
  /// In en, this message translates to:
  /// **'Not authorized'**
  String get notAuthorizedTitle;

  /// Explains the Not authorized screen. Admin documents are created by hand in the console (spec §14.1).
  ///
  /// In en, this message translates to:
  /// **'This account doesn\'t have admin access. The owner adds admins in the Firebase console.'**
  String get notAuthorizedMessage;

  /// Sign-in failed because the email or password was rejected.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get errorInvalidCredentials;

  /// A request failed because Firebase could not be reached.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection and try again.'**
  String get errorNetwork;

  /// Fallback for any other failure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;

  /// Note under the title of a screen that isn't built yet. The placeholder is a milestone code from the project plan (spec §18); don't translate it.
  ///
  /// In en, this message translates to:
  /// **'Coming in {milestone}'**
  String comingInMilestone(String milestone);

  /// Dashboard screen title and navigation label (spec §15 #1).
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// Levels list screen title and navigation label (spec §15 #2).
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levelsTitle;

  /// Level editor screen title (spec §15 #3). The placeholder is a level id, not translated.
  ///
  /// In en, this message translates to:
  /// **'Edit level {levelId}'**
  String levelEditorTitle(String levelId);

  /// Level generator screen title and navigation label (spec §15 #4).
  ///
  /// In en, this message translates to:
  /// **'Generator'**
  String get generatorTitle;

  /// Chapters screen title and navigation label (spec §15 #5).
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chaptersTitle;

  /// Doll skins screen title and navigation label (spec §15 #6).
  ///
  /// In en, this message translates to:
  /// **'Skins'**
  String get skinsTitle;

  /// Board themes screen title and navigation label (spec §15 #7).
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themesTitle;

  /// Doll Museum items screen title and navigation label (spec §15 #7, §7.2).
  ///
  /// In en, this message translates to:
  /// **'Museum items'**
  String get museumItemsTitle;

  /// Daily puzzle overrides screen title and navigation label (spec §15 #8, §7.5).
  ///
  /// In en, this message translates to:
  /// **'Daily overrides'**
  String get dailyOverridesTitle;

  /// Export level bundle screen title and navigation label (spec §15 #9).
  ///
  /// In en, this message translates to:
  /// **'Export bundle'**
  String get exportBundleTitle;
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
