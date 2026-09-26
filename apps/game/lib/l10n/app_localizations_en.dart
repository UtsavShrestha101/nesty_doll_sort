// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nesty';

  @override
  String get splashLoading => 'Loading…';

  @override
  String get genericLoadFailed => 'Something went wrong.';

  @override
  String get retry => 'Try again';

  @override
  String levelTitle(int level) {
    return 'Level $level';
  }

  @override
  String get pause => 'Pause';

  @override
  String get boosterUndo => 'Undo';

  @override
  String get boosterHint => 'Hint';

  @override
  String get boosterExtraSlot => '+Slot';

  @override
  String get restart => 'Restart';
}
