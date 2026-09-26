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

  /// Short product name shown on the splash screen. The final name is TBD (spec header).
  ///
  /// In en, this message translates to:
  /// **'Nesty'**
  String get appName;

  /// Accessibility label for the splash loading bar (spec §10.2 #1).
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get splashLoading;

  /// Screen-reader value of a progress bar (the splash loader, frame 1.1, and the win card's chapter bar, frame 2.8; spec §16): the progress as a percentage in the locale's format (42%, %42, 42 %). {value} runs from 0 to 1.
  ///
  /// In en, this message translates to:
  /// **'{value}'**
  String progressPercent(double value);

  /// Shown when local data (save file, bundled levels) fails to load.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get genericLoadFailed;

  /// Button that retries a failed load.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// Level label on the Home play button and the gameplay top bar (spec §10.2 #2, #3).
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelTitle(int level);

  /// Tooltip for the gameplay pause button (spec §10.2 #3).
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Undo booster button label (spec §8).
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get boosterUndo;

  /// Hint booster button label (spec §8).
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get boosterHint;

  /// Extra slot booster button label (spec §3.6, §8). Keep it short.
  ///
  /// In en, this message translates to:
  /// **'+Slot'**
  String get boosterExtraSlot;

  /// Restart the current level (spec §2.4). Always free.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// The orange chip under the wordmark on the splash screen (frame 1.1, spec §10.2 #1). Keep it short and uppercase; it has +0.12 em letter spacing.
  ///
  /// In en, this message translates to:
  /// **'DOLL SORT'**
  String get splashDollSort;

  /// Caption under the splash loading bar while the save, levels and art load (frame 1.1, spec §10.2 #1).
  ///
  /// In en, this message translates to:
  /// **'Dusting the shelves…'**
  String get splashCaption;

  /// Small caption above "Level N" on the Home play button (frame 2.1, spec §10.2 #2). Uppercase, +0.14 em letter spacing.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get homePlay;

  /// Big line of the Home play button, in place of "Level N", once every bundled level is won; the button then opens All Levels Done (frame 4.9, spec §7.1, §10.2 #15). No frame shows this state; M3's Bonus Endless replaces it with the bonus level. Keep it short: it is set at 36 pt.
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get homeAllLevelsDone;

  /// Screen-reader label of the Home play button for an easy or medium level (frame 2.1, spec §10.2 #2).
  ///
  /// In en, this message translates to:
  /// **'Play level {level}'**
  String playSemantics(int level);

  /// Screen-reader label of the Home play button for a hard or super hard level (frame 2.1, spec §6.6). {tier} is tierName.
  ///
  /// In en, this message translates to:
  /// **'Play level {level}, {tier}'**
  String playLevelSemantics(int level, String tier);

  /// Screen-reader label of the Home coin pill, whose green plus opens the Shop (frame 2.1, spec §10.2 #2).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 coin. Get more coins} other{{count} coins. Get more coins}}'**
  String coinPillShopSemantics(int count);

  /// Red tier badge on the level pill and the Home play button for hard levels (spec §6.6, frames 2.1, 2.2). Keep it very short and uppercase.
  ///
  /// In en, this message translates to:
  /// **'HARD'**
  String get tierHard;

  /// Purple tier badge on the level pill for super hard levels (spec §6.6, frame 4.4). Keep it very short and uppercase; the chip is tiny.
  ///
  /// In en, this message translates to:
  /// **'SUPER HARD'**
  String get tierSuperHard;

  /// A level tier's name in running text, e.g. the Pause card's "Level 56 · Hard" (spec §6.6, frame 3.9). {tier} is the nesty_core Tier id.
  ///
  /// In en, this message translates to:
  /// **'{tier, select, easy{Easy} medium{Medium} hard{Hard} superhard{Super Hard} other{}}'**
  String tierName(String tier);

  /// The Pause card's subtitle and the level pill's screen-reader label (frame 3.9, spec §6.6). {tier} is tierName.
  ///
  /// In en, this message translates to:
  /// **'Level {level} · {tier}'**
  String levelWithTier(int level, String tier);

  /// The family counter under the level pill: families completed of the level's total, drawn over the ui_family_counter animation (frame 2.2, spec §10.2 #3, §11.1). Keep the digits and slash.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String familyCounter(int done, int total);

  /// Screen-reader label of the family counter (frame 2.2, spec §10.2 #3).
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{{done} of 1 family done} other{{done} of {total} families done}}'**
  String familyCounterSemantics(int done, int total);

  /// Screen-reader label of the HUD coin pill (frame 2.2, spec §7).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 coin} other{{count} coins}}'**
  String coinsSemantics(int count);

  /// The daily puzzle's level pill, next to a date chip (frame 5.3, spec §7.4). Stub until the daily puzzle ships.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get levelDaily;

  /// Screen-reader label of the daily puzzle's level pill (frame 5.3, spec §7.4). {date} is the short date shown on the chip.
  ///
  /// In en, this message translates to:
  /// **'Daily puzzle, {date}'**
  String levelDailySemantics(String date);

  /// The level pill on a device-generated Bonus Endless level (frame 4.10, spec §7.1). Stub until bonus levels ship.
  ///
  /// In en, this message translates to:
  /// **'Bonus Level {number}'**
  String bonusLevelTitle(int number);

  /// Screen-reader label of the round close button on cards and popups (frames 3.2, 3.9).
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeSemantics;

  /// Screen-reader label of the back arrow in screen headers (spec §10.2).
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backSemantics;

  /// Screen-reader label of a booster button whose badge shows how many are left (frame 2.2, spec §8). {booster} is its label (Undo, Hint, +Slot).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{booster}, 1 left} other{{booster}, {count} left}}'**
  String boosterCountSemantics(String booster, int count);

  /// Screen-reader label of a booster with none left whose badge offers a rewarded ad (frame 3.2, spec §8, §9.1).
  ///
  /// In en, this message translates to:
  /// **'{booster}, watch an ad for one more'**
  String boosterAdSemantics(String booster);

  /// Screen-reader label of a booster with none left whose badge shows its coin price (frame 3.3, spec §8).
  ///
  /// In en, this message translates to:
  /// **'{price, plural, =1{{booster}, 1 coin} other{{booster}, {price} coins}}'**
  String boosterCoinSemantics(String booster, int price);

  /// Title of the banner shown when legal moves remain but the solver finds no win (frame 3.4, spec §2.4).
  ///
  /// In en, this message translates to:
  /// **'Hmm, this looks stuck'**
  String get softStuckTitle;

  /// Second line of the soft-stuck banner (frame 3.4, spec §2.4).
  ///
  /// In en, this message translates to:
  /// **'Try Undo? You can keep playing too.'**
  String get softStuckBody;

  /// Second line of the soft-stuck banner when nothing can be undone (a completed family cleared the undo history, or the free undos are used up); its button restarts the level, which is always free (frame 3.4's banner, spec §2.3, §2.4). No frame shows this state.
  ///
  /// In en, this message translates to:
  /// **'Try Restart? You can keep playing too.'**
  String get softStuckBodyRestart;

  /// The soft-stuck banner's button, which undoes the last move (frame 3.4, spec §8).
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get softStuckAction;

  /// Title of the out-of-moves sheet (frame 3.5, spec §2.4, §10.2 #5).
  ///
  /// In en, this message translates to:
  /// **'No moves left!'**
  String get oomTitle;

  /// Subtitle of the out-of-moves sheet (frame 3.5).
  ///
  /// In en, this message translates to:
  /// **'Pick a way to keep sorting.'**
  String get oomSubtitle;

  /// Undo row subtitle in the out-of-moves sheet (frame 3.5, spec §8).
  ///
  /// In en, this message translates to:
  /// **'Take back your last move'**
  String get oomUndoSubtitle;

  /// Tag on the Undo row while free undos remain this level (frame 3.5, spec §8).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Free · 1 left} other{Free · {count} left}}'**
  String oomUndoFree(int count);

  /// Extra-slot row title in the out-of-moves sheet (frame 3.5, spec §3.6, §8).
  ///
  /// In en, this message translates to:
  /// **'+1 Slot'**
  String get oomSlotTitle;

  /// Extra-slot row subtitle when an ad or coins can pay for it (frame 3.5, spec §3.6).
  ///
  /// In en, this message translates to:
  /// **'Add a stand for this level'**
  String get oomSlotSubtitle;

  /// Extra-slot row subtitle when offline, so only the coin price is offered (frame 3.7, spec §9.1).
  ///
  /// In en, this message translates to:
  /// **'Coins only while offline'**
  String get oomSlotOffline;

  /// Restart row subtitle in the out-of-moves sheet (frame 3.5, spec §2.4).
  ///
  /// In en, this message translates to:
  /// **'Start this level fresh, for free'**
  String get oomRestartSubtitle;

  /// Label of a coin price button, e.g. buying one more hint (frames 3.2, 3.3, spec §8).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 coin} other{{count} coins}}'**
  String coinPrice(int count);

  /// Label of a rewarded-ad button that grants a booster (frames 3.2, 3.3, spec §9.1).
  ///
  /// In en, this message translates to:
  /// **'Watch ad'**
  String get watchAd;

  /// Screen-reader label of the small ▶-only rewarded-ad button (frame 3.5, spec §9.1).
  ///
  /// In en, this message translates to:
  /// **'Watch an ad'**
  String get watchAdSemantics;

  /// Title of the offline banner (frame 3.7, spec §9.1, rule 3).
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineTitle;

  /// Second line of the offline banner over the out-of-moves sheet (frame 3.7, spec §9.1).
  ///
  /// In en, this message translates to:
  /// **'Ad buttons switch to coin prices'**
  String get offlineAds;

  /// Red note under a disabled coin button when the player can't afford it and is offline (frame 3.8, spec §9.1).
  ///
  /// In en, this message translates to:
  /// **'Connect to watch an ad'**
  String get connectToWatchAd;

  /// The win ribbon, drawn over the ui_win_ribbon animation (frame 2.8, spec §10.2 #4). The band fits about 22 characters; longer text shrinks.
  ///
  /// In en, this message translates to:
  /// **'Level Complete!'**
  String get winTitle;

  /// The win screen's main button, to the next level (frame 2.8, spec §10.2 #4).
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get winContinue;

  /// Rewarded-ad button on the win screen that triples the level's coins (frame 2.8, spec §9.1). Hidden until ads ship (M6) and offline.
  ///
  /// In en, this message translates to:
  /// **'×3 coins'**
  String get winTripleCoins;

  /// The ×3 button after its ad was watched (frame 2.9, spec §9.1).
  ///
  /// In en, this message translates to:
  /// **'Reward added'**
  String get winRewardAdded;

  /// The coins won, counting up in the win screen's coin pill (frame 2.8, spec §7.3).
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String winCoins(int count);

  /// The win screen's chapter card label (frame 2.8, spec §7.1, §7.2).
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String winChapter(int number);

  /// Levels done in this chapter on the win screen's chapter card (frame 2.8, spec §7.1).
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String winChapterProgress(int done, int total);

  /// The chapter card's line naming the figurine family this chapter unlocks (frame 2.8, spec §7.2). {name} is figurineName.
  ///
  /// In en, this message translates to:
  /// **'Next up: {name}'**
  String winNextUp(String name);

  /// The chapter card's line on the chapter's last level (frame 2.8 at 20 / 20, spec §7.2).
  ///
  /// In en, this message translates to:
  /// **'Chapter complete! Your prize is next.'**
  String get winChapterDone;

  /// A museum figurine family's name (spec §7.2, frames 1.5, 2.8). {figurine} is the museum item id; ids without a design name are empty and their line is hidden.
  ///
  /// In en, this message translates to:
  /// **'{figurine, select, classic{The Classic Family} sailor{The Sailor Family} baker{The Baker Family} other{}}'**
  String figurineName(String figurine);

  /// The ribbon on a chapter's first level, drawn over the ui_chapter_ribbon animation, fading after about 2 s (frame 4.7, spec §7.1). {name} is chapterName. The band fits about 22 characters; longer text shrinks.
  ///
  /// In en, this message translates to:
  /// **'CHAPTER {number} · {name}'**
  String chapterRibbon(int number, String name);

  /// A chapter's name, which is its board theme's name (spec §7.1, §12.4; frames 4.6, 4.7, 7.7). {theme} is the theme id.
  ///
  /// In en, this message translates to:
  /// **'{theme, select, ch01{Sunny Toy Shop} ch02{Rainy Café Corner} ch03{Seaside Market} ch04{Snowy Cabin} ch05{Night Carnival} ch06{Spring Garden Shed} other{}}'**
  String chapterName(String theme);

  /// The pause card's ribbon title (frame 3.9, spec §10.2 #14).
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pauseTitle;

  /// Closes the pause card and returns to the level (frame 3.9, spec §10.2 #14).
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Pause card tile that leaves the level for Home (frame 3.9, spec §10.2 #14).
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Pause card tile and Home gear that open Settings (frames 2.1, 3.9, spec §10.2 #13). Also the gear's screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Sound effects toggle in Pause and Settings (frames 3.9, 8.1, spec §11.3).
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingSound;

  /// Music toggle in Pause and Settings (frames 3.9, 8.1, spec §11.3).
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingMusic;

  /// Vibration toggle in Pause and Settings (frames 3.9, 8.1, spec §11.2).
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get settingHaptics;

  /// Title shown after the last published level (frame 4.9, spec §7.1, §10.2 #15).
  ///
  /// In en, this message translates to:
  /// **'You\'ve finished all levels!'**
  String get allLevelsTitle;

  /// Body of the all-levels-done card (frame 4.9, spec §10.2 #15).
  ///
  /// In en, this message translates to:
  /// **'New chapters are coming — play bonus levels meanwhile.'**
  String get allLevelsBody;

  /// Teal button on the all-levels-done card that starts a generated bonus level (frame 4.9, spec §7.1).
  ///
  /// In en, this message translates to:
  /// **'Play Bonus Level {number}'**
  String allLevelsPlayBonus(int number);

  /// Text button under the all-levels-done card (frame 4.9).
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get allLevelsBackHome;

  /// Title of the dev-flavor level picker sheet (dev builds only; plan P4).
  ///
  /// In en, this message translates to:
  /// **'Jump to a level'**
  String get devLevelPickerTitle;
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
