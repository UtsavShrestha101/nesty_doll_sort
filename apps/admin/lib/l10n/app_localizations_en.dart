// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nesty Admin';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailRequired => 'Enter your email.';

  @override
  String get passwordRequired => 'Enter your password.';

  @override
  String get signIn => 'Sign in';

  @override
  String get signingIn => 'Signing in';

  @override
  String get signOut => 'Sign out';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get notAuthorizedTitle => 'Not authorized';

  @override
  String get notAuthorizedMessage =>
      'This account doesn\'t have admin access. The owner adds admins in the Firebase console.';

  @override
  String get errorInvalidCredentials => 'Wrong email or password.';

  @override
  String get errorNetwork =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String comingInMilestone(String milestone) {
    return 'Coming in $milestone';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get levelsTitle => 'Levels';

  @override
  String levelEditorTitle(String levelId) {
    return 'Edit level $levelId';
  }

  @override
  String get generatorTitle => 'Generator';

  @override
  String get chaptersTitle => 'Chapters';

  @override
  String get skinsTitle => 'Skins';

  @override
  String get themesTitle => 'Themes';

  @override
  String get museumItemsTitle => 'Museum items';

  @override
  String get dailyOverridesTitle => 'Daily overrides';

  @override
  String get exportBundleTitle => 'Export bundle';
}
