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

  /// A museum figurine family's name (spec §7.2, frames 1.5, 2.8, 4.6; m3 §9.3). {figurine} is the museum item id; ids without a design name are empty and their line is hidden. astronaut/gardener/snow/circus/musician/royal/explorer are placeholder title-cased names pending the owner's figurine names 4-10 (Q73); update them, not the id list, once the owner answers.
  ///
  /// In en, this message translates to:
  /// **'{figurine, select, classic{The Classic Family} sailor{The Sailor Family} baker{The Baker Family} astronaut{The Astronaut Family} gardener{The Gardener Family} snow{The Snow Family} circus{The Circus Family} musician{The Musician Family} royal{The Royal Family} explorer{The Explorer Family} other{}}'**
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

  /// Text link under 'Try again' on the card shown over the win overlay when Continue's next level (a generated Bonus Endless level) couldn't be made (spec §7.1; no frame yet, review CORRECTNESS-3). Leaves the level for Home.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get nextLevelFailedHome;

  /// Title of the dev-flavor level picker sheet (dev builds only; plan P4).
  ///
  /// In en, this message translates to:
  /// **'Jump to a level'**
  String get devLevelPickerTitle;

  /// The shell's bottom-nav Shop tab label (frame 2.1; m3 §10.1, §10.9).
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// The shell's bottom-nav Museum tab label (frame 2.1; m3 §10.1, §10.9).
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get navMuseum;

  /// Home's Daily Puzzle tile label (frame 2.1; m3 §10.3).
  ///
  /// In en, this message translates to:
  /// **'Daily Puzzle'**
  String get homeDailyTile;

  /// Home's Museum tile label (frame 2.1; m3 §10.3).
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get homeMuseumTile;

  /// Home's Remove Ads tile label, hidden once ads are removed (frame 2.1; m3 §10.3).
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get homeRemoveAdsTile;

  /// Home's Museum tile progress bar caption: levels done of the current chapter, no spaces around the slash (frame 2.1; m3 §10.3). Distinct from museumCount, which the Museum screen's collection card uses.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String homeMuseumProgress(int done, int total);

  /// Home's Daily Puzzle tile before Level 2, replacing homeDailyTile while the tile is locked (m3 §10.3, Q67; a design gap, no frame shows this state).
  ///
  /// In en, this message translates to:
  /// **'After Level 2'**
  String get homeDailyLocked;

  /// Screen-reader label of the Daily Puzzle tile's flame streak badge (frame 2.1; m3 §10.9).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1-day streak} other{{count}-day streak}}'**
  String streakBadgeSemantics(int count);

  /// Settings' Subtle/Large segmented row label (frame 8.1; spec §11.1, m3 §10.2).
  ///
  /// In en, this message translates to:
  /// **'Color symbols'**
  String get settingColorSymbols;

  /// Settings' Color symbols segment for DollSymbols.subtle (frame 8.1).
  ///
  /// In en, this message translates to:
  /// **'Subtle'**
  String get symbolsSubtle;

  /// Settings' Color symbols segment for DollSymbols.assist (frame 8.1).
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get symbolsLarge;

  /// Settings' Language row label, opening the language sheet (frame 8.1).
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingLanguage;

  /// Settings' Restore Purchases row label, shown disabled until M6 (frame 8.1, TODO(M6)).
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get settingRestorePurchases;

  /// Settings' Privacy choices row label (UMP consent), shown disabled until M6 (frame 8.1, TODO(M6)).
  ///
  /// In en, this message translates to:
  /// **'Privacy choices'**
  String get settingPrivacyChoices;

  /// Settings' Privacy Policy row label; hidden while AppLinks.privacyPolicyUrl is empty (frame 8.1, Q73).
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingPrivacyPolicy;

  /// Settings' Support row label; hidden while AppLinks.supportEmail is empty (frame 8.1, Q73).
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingSupport;

  /// Settings' Support row's trailing value (frame 8.1).
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get settingSupportValue;

  /// Settings' footer caption: the app version and build (AppInfoService) and the local player id (SaveService.playerId; frame 8.1, m3 §10.2, D79).
  ///
  /// In en, this message translates to:
  /// **'Nesty: Doll Sort · v{version} (build {build}) · Player ID {playerId}'**
  String settingsFooter(String version, String build, String playerId);

  /// Title of the language sheet (frame 8.2).
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSheetTitle;

  /// Closes the language sheet (frame 8.2).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get languageSheetDone;

  /// A launch language's name in the UI language, next to its autonym, which is data rather than ARB since it reads the same in every locale (frame 8.2, m3 §10.2). {language} is the locale code.
  ///
  /// In en, this message translates to:
  /// **'{language, select, es{Spanish} pt_BR{Portuguese} id{Indonesian} hi{Hindi} de{German} fr{French} tr{Turkish} ja{Japanese} other{}}'**
  String languageName(String language);

  /// Screen-reader note on a language sheet row that is disabled until its ARB file exists (frame 8.2, TODO(M7)).
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get languageComingSoon;

  /// Screen-reader label of an unselected language sheet row (frame 8.2, spec §16): the language's own name, then its languageName, or languageComingSoon when the row is disabled.
  ///
  /// In en, this message translates to:
  /// **'{autonym}, {detail}'**
  String languageRowSemantics(String autonym, String detail);

  /// The Daily streak card's big number (frame 5.1: "4 days"; m3 §10.5).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String dailyStreakDays(int count);

  /// The Daily streak card's subtitle while today isn't solved yet, streak > 0 (frame 5.1).
  ///
  /// In en, this message translates to:
  /// **'Play today to keep your streak'**
  String get dailyStreakKeep;

  /// The Daily streak card's subtitle before any streak has started (streak = 0; m3 §10.5, a design gap).
  ///
  /// In en, this message translates to:
  /// **'Play today to start a streak'**
  String get dailyStreakStart;

  /// The Daily streak card's subtitle once today's puzzle is solved (frame 5.5: dailyDone scene).
  ///
  /// In en, this message translates to:
  /// **'Done for today. See you tomorrow!'**
  String get dailyStreakDone;

  /// The Daily streak card's subtitle on the streak's 7th day, once the chest is reached (frame 5.6: dailyChest scene).
  ///
  /// In en, this message translates to:
  /// **'A full week!'**
  String get dailyStreakWeek;

  /// The Daily streak card's freeze chip (frame 5.1; m3 §8, D76: freeze cap 1 per ISO week).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 left} =1{1 freeze} other{{count} freezes}}'**
  String dailyFreezes(int count);

  /// Prefix on the 7-day strip's day-7 chest label (frame 5.1).
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dailyDay;

  /// The 7-day strip's label for today's cell (frame 5.1).
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dailyToday;

  /// The 7-day strip's label for tomorrow's cell; kept short to fit the strip (frame 5.1).
  ///
  /// In en, this message translates to:
  /// **'Tmrw'**
  String get dailyTomorrow;

  /// Screen-reader label of one cell of the Daily 7-day strip (frame 5.1, spec §16): the cell's day of the cycle and its state. Spell out 'Tomorrow' here, unlike the strip's short dailyTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{state, select, done{Day {day}, done} today{Today, day {day}} tomorrow{Tomorrow, day {day}} chest{Day {day}, chest} other{Day {day}}}'**
  String dailyDaySemantics(String state, int day);

  /// Screen-reader label of the Daily puzzle card's Play button and its coin reward chip (frame 5.1, spec §16).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Play, 1 coin} other{Play, {count} coins}}'**
  String dailyPlaySemantics(int count);

  /// The 7-day strip's chest row caption (frame 5.1).
  ///
  /// In en, this message translates to:
  /// **'Day 7 chest · {coins} coins'**
  String dailyChestRow(int coins);

  /// Days left to the Day 7 chest, not counting today (frame 5.5: dailyDone scene, "2 days to go"; m3 §8.4).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day to go} other{{count} days to go}}'**
  String dailyChestToGo(int count);

  /// Days left to the Day 7 chest, counting today (frame 5.1, "3 days to go, counting today"; m3 §8.4).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day to go, counting today} other{{count} days to go, counting today}}'**
  String dailyChestToGoToday(int count);

  /// The 7-day strip's chest row once the Day 7 chest has been collected (frame 5.6: dailyChest scene, "chestSub: 'Opened today'").
  ///
  /// In en, this message translates to:
  /// **'Opened today'**
  String get dailyChestOpenedToday;

  /// The Daily puzzle card's title (frame 5.1; m3 §8.4).
  ///
  /// In en, this message translates to:
  /// **'{weekday}’s puzzle'**
  String dailyPuzzleTitle(String weekday);

  /// The Daily puzzle card's subtitle: colors and tier (frame 5.1, "5 colors · Hard"). {tier} is tierName.
  ///
  /// In en, this message translates to:
  /// **'{colors, plural, =1{1 color} other{{colors} colors}} · {tier}'**
  String dailyPuzzleInfo(int colors, String tier);

  /// The Daily puzzle card's Play button (frame 5.1).
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get dailyPlay;

  /// The Daily puzzle card's chip once solved, replacing dailyPlay (frame 5.5, m3 §8.4).
  ///
  /// In en, this message translates to:
  /// **'Solved · +{coins}'**
  String dailySolvedChip(int coins);

  /// The Daily solved state's countdown line (frame 5.5). {time} is dailyCountdown.
  ///
  /// In en, this message translates to:
  /// **'Next puzzle in {time}'**
  String dailyNextPuzzle(String time);

  /// The Daily countdown's hours and minutes to the next puzzle (frame 5.5).
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String dailyCountdown(int hours, int minutes);

  /// The Daily solved state's button back to the campaign (frame 5.5). {level} is the campaign level number.
  ///
  /// In en, this message translates to:
  /// **'Play Level {level}'**
  String playLevel(int level);

  /// The "streak saved" info toast's title, shown once after a freeze covers a missed day (frame 5.2).
  ///
  /// In en, this message translates to:
  /// **'Streak saved!'**
  String get dailySavedTitle;

  /// The "streak saved" toast's body (frame 5.2).
  ///
  /// In en, this message translates to:
  /// **'A freeze covered {weekday}. You\'ll earn a new one next week.'**
  String dailySavedBody(String weekday);

  /// The Day 7 chest modal's ribbon title (frame 5.6).
  ///
  /// In en, this message translates to:
  /// **'7-day streak!'**
  String get dailyChestTitle;

  /// The Day 7 chest modal's body (frame 5.6).
  ///
  /// In en, this message translates to:
  /// **'A full week of puzzles. Your chest is open.'**
  String get dailyChestBody;

  /// The Day 7 chest modal's rewarded-ad button; hidden until M6 (frame 5.6, TODO(M6)).
  ///
  /// In en, this message translates to:
  /// **'Double it'**
  String get dailyChestDouble;

  /// The Day 7 chest modal's main button (frame 5.6).
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get dailyChestCollect;

  /// The daily win card's ribbon title, in place of winTitle (frame 5.4, m3 §8.4).
  ///
  /// In en, this message translates to:
  /// **'Daily solved!'**
  String get dailyWinTitle;

  /// The daily win card's streak line (frame 5.4).
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String dailyWinStreak(int count);

  /// The daily win card's line about the Day 7 chest, days left after today's solve (frame 5.4). {count} is the day count (0-6) as a decimal string, e.g. "count.toString()": gen-l10n's `select` only accepts String placeholders, unlike `plural`, which can't express six distinct spelled-out numbers for English (only "one"/"other" ever apply).
  ///
  /// In en, this message translates to:
  /// **'{count, select, 0{Your Day 7 chest is ready!} 1{One more day to the Day 7 chest} 2{Two more days to the Day 7 chest} 3{Three more days to the Day 7 chest} 4{Four more days to the Day 7 chest} 5{Five more days to the Day 7 chest} 6{Six more days to the Day 7 chest} other{{count} more days to the Day 7 chest}}'**
  String dailyWinChestHint(String count);

  /// The daily win card's secondary action, back to the Daily screen instead of the next campaign level (m3 §10.1).
  ///
  /// In en, this message translates to:
  /// **'Back to Daily'**
  String get dailyBackToDaily;

  /// The Museum screen's header title (frame 6.1).
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get museumTitle;

  /// The Museum screen's collection card label (frame 6.1).
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get museumCollection;

  /// The Museum screen's collection card count, e.g. "2 / 10" (frame 6.1). Distinct from homeMuseumProgress, which has no spaces.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String museumCount(int done, int total);

  /// The Museum screen's collection card line naming the next figurine (frame 6.1). {name} is figurineName.
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}: {done} of {total} levels to {name}'**
  String museumNextLine(int number, int done, int total, String name);

  /// The Museum screen's collection card once all ten figurines are collected, replacing museumNextLine (m3 §10.6, a design gap: no frame shows this state).
  ///
  /// In en, this message translates to:
  /// **'Every family is home.'**
  String get museumAllHome;

  /// A figurine's cabinet label once earned, e.g. "Classic Family" (frame 6.1). {name} is figurineShortName.
  ///
  /// In en, this message translates to:
  /// **'{name} Family'**
  String museumFamilyLabel(String name);

  /// The next figurine's cabinet label, not yet earned (frame 6.1, "Baker · soon"). {name} is figurineShortName.
  ///
  /// In en, this message translates to:
  /// **'{name} · soon'**
  String museumSoonLabel(String name);

  /// A figurine's short name, without "The … Family" (frame 6.1's cabinet labels, museumFamilyLabel/museumSoonLabel; m3 §10.6). {figurine} is the museum item id.
  ///
  /// In en, this message translates to:
  /// **'{figurine, select, classic{Classic} sailor{Sailor} baker{Baker} astronaut{Astronaut} gardener{Gardener} snow{Snow} circus{Circus} musician{Musician} royal{Royal} explorer{Explorer} other{}}'**
  String figurineShortName(String figurine);

  /// A figurine's italic flavor text in its detail modal; ids without one are empty and the line is hidden (frame 6.2; Q73 asks the owner for the other nine). {figurine} is the museum item id.
  ///
  /// In en, this message translates to:
  /// **'{figurine, select, sailor{“They keep a seashell in the smallest doll, just in case.”} other{}}'**
  String figurineFlavor(String figurine);

  /// The figurine detail modal's chapter chip (frame 6.2). {name} is chapterName.
  ///
  /// In en, this message translates to:
  /// **'Chapter {number} · {name}'**
  String museumChapterChip(int number, String name);

  /// The figurine detail modal's collected date, when known (frame 6.2, "Collected · Sep 12").
  ///
  /// In en, this message translates to:
  /// **'Collected · {date}'**
  String museumCollectedOn(String date);

  /// The figurine detail modal's collected line when the date isn't known (frame 6.2, spec §13.3 museum entries added before the date field).
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get museumCollected;

  /// The locked figurine modal's body (frame 6.3).
  ///
  /// In en, this message translates to:
  /// **'Finish Chapter {number} to bring this family home.'**
  String museumLockedText(int number);

  /// The Shop screen's header title (frame 7.3).
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// The Shop's Coins tab label (frame 7.3).
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get shopTabCoins;

  /// The Shop's Skins tab label (frame 7.3).
  ///
  /// In en, this message translates to:
  /// **'Skins'**
  String get shopTabSkins;

  /// The Shop's Themes tab label (frame 7.7).
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get shopTabThemes;

  /// The Shop's No Ads tab label (frame 7.8).
  ///
  /// In en, this message translates to:
  /// **'No Ads'**
  String get shopTabNoAds;

  /// A skin card's state once it's the equipped skin (frame 7.3).
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get shopEquipped;

  /// An owned, unequipped skin card's button (frame 7.3, 7.4).
  ///
  /// In en, this message translates to:
  /// **'Equip'**
  String get shopEquip;

  /// A skin's display name (frame 7.3, 7.4). {skin} is the SkinService/catalog skin id; forest-bear ships unsold and unnamed here (D75).
  ///
  /// In en, this message translates to:
  /// **'{skin, select, classic{Classic} space{Space} ocean{Ocean} sweets{Sweets} forest{Forest Friends} winter{Winter} other{}}'**
  String skinName(String skin);

  /// A skin's detail-page description; ids without one are empty and the line is hidden (frame 7.4; Q73 asks the owner for the other five). {skin} is the skin id.
  ///
  /// In en, this message translates to:
  /// **'{skin, select, ocean{Sailor collars, tiny anchors and wave trims.} other{}}'**
  String skinDescription(String skin);

  /// The skin detail screen's header title (frame 7.4).
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get skinDetailTitle;

  /// The skin detail screen's colors caption, over the two shelves of all 11 colors (frame 7.4).
  ///
  /// In en, this message translates to:
  /// **'All 11 colors · symbols kept'**
  String get skinDetailColors;

  /// The skin detail screen's size-lineup caption (frame 7.4).
  ///
  /// In en, this message translates to:
  /// **'Every size nests the same way. Only the paint changes.'**
  String get skinDetailSizes;

  /// The skin detail screen's buy button label; a coin chip with the price trails it (frame 7.4).
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get shopBuy;

  /// Screen-reader label of the skin detail screen's Buy button and its trailing coin-price chip (frame 7.4, spec §16).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Buy, 1 coin} other{Buy, {count} coins}}'**
  String shopBuySemantics(int count);

  /// The player's coin balance line: the skin detail screen (frame 7.4) and the buy popup's BuyPopupBody (frames 3.2, 3.3).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You have 1 coin} other{You have {count} coins}}'**
  String balanceLine(int count);

  /// A skin card's downloading state; built for M4 and unreachable while every skin is bundled (frame 7.5).
  ///
  /// In en, this message translates to:
  /// **'Downloading {percent}%'**
  String shopDownloading(int percent);

  /// The Themes tab's toggle row title (frame 7.7).
  ///
  /// In en, this message translates to:
  /// **'Match each chapter'**
  String get themesMatchTitle;

  /// The Themes tab's toggle row subtitle (frame 7.7).
  ///
  /// In en, this message translates to:
  /// **'Uses the theme of the chapter you\'re in'**
  String get themesMatchSubtitle;

  /// A theme card's state once it's the selected theme (frame 7.7).
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get themeInUse;

  /// An owned, unselected theme card's button (frame 7.7); turns the "Match each chapter" toggle off.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get themeUse;

  /// A locked theme card's chip, the chapter that unlocks it (frame 7.7).
  ///
  /// In en, this message translates to:
  /// **'Ch {number}'**
  String themeChapterLock(int number);

  /// The Coins and No Ads tabs' store-closed card title, shown until M6 (m3 §10.7, D75, Q75, TODO(M6)).
  ///
  /// In en, this message translates to:
  /// **'The store is closed for now'**
  String get shopClosedTitle;

  /// The store-closed card's body (m3 §10.7, TODO(M6)).
  ///
  /// In en, this message translates to:
  /// **'Coin packs and Remove Ads come in a later update.'**
  String get shopClosedBody;

  /// The Undo buy popup's benefit line (frame 3.2, "Your 2 free undos are used…"; spec §8). {count} is the level's free-undo count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your 1 free undo is used. Take back one more move.} other{Your {count} free undos are used. Take back one more move.}}'**
  String buyUndoText(int count);

  /// The Hint buy popup's benefit line (frame 3.3).
  ///
  /// In en, this message translates to:
  /// **'Shows your next best move.'**
  String get buyHintText;

  /// The +1 Slot buy popup's benefit line (frame 3.6, spec §3.6).
  ///
  /// In en, this message translates to:
  /// **'Adds one empty stand for this level.'**
  String get buySlotText;

  /// L1's tutorial step 1 chip (frame 1.3; m3 §10.4).
  ///
  /// In en, this message translates to:
  /// **'STEP 1 OF 2'**
  String get tutorialStep1Chip;

  /// L1's tutorial step 1 title (frame 1.3).
  ///
  /// In en, this message translates to:
  /// **'Tap the small doll'**
  String get tutorialStep1Title;

  /// L1's tutorial step 1 body (frame 1.3).
  ///
  /// In en, this message translates to:
  /// **'Dolls nest into the same color, one size bigger.'**
  String get tutorialStep1Text;

  /// L1's tutorial step 2 chip (frame 1.4).
  ///
  /// In en, this message translates to:
  /// **'STEP 2 OF 2'**
  String get tutorialStep2Chip;

  /// L1's tutorial step 2 title (frame 1.4).
  ///
  /// In en, this message translates to:
  /// **'Now tap the big one'**
  String get tutorialStep2Title;

  /// L1's tutorial step 2 body (frame 1.4).
  ///
  /// In en, this message translates to:
  /// **'The small doll drops inside with a clack.'**
  String get tutorialStep2Text;

  /// L1's tutorial step 3 title; no frame or chip (m3 §10.4, a design gap).
  ///
  /// In en, this message translates to:
  /// **'Finish the family'**
  String get tutorialStep3Title;

  /// L1's tutorial step 3 body; no frame or chip (m3 §10.4, a design gap).
  ///
  /// In en, this message translates to:
  /// **'Tap the smallest doll, then the family.'**
  String get tutorialStep3Text;

  /// L2's tutorial swallow-move chip (frame 1.6).
  ///
  /// In en, this message translates to:
  /// **'NEW MOVE'**
  String get tutorialSwallowChip;

  /// L2's tutorial swallow-move title (frame 1.6).
  ///
  /// In en, this message translates to:
  /// **'Big can swallow small'**
  String get tutorialSwallowTitle;

  /// L2's tutorial swallow-move body (frame 1.6).
  ///
  /// In en, this message translates to:
  /// **'Drop a big doll onto the next size down and it closes right over it.'**
  String get tutorialSwallowText;

  /// The mechanic intro card's chip for the towers/glass/ice cards (frames 4.1-4.3; m3 §10.4). The gold-doll card uses a different chip, TODO(v1.1).
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get introNew;

  /// The towers intro card's title (frame 4.1, first met at L16).
  ///
  /// In en, this message translates to:
  /// **'Towers!'**
  String get introTowersTitle;

  /// The towers intro card's body (frame 4.1).
  ///
  /// In en, this message translates to:
  /// **'Only the top nest can move. Clear it to reveal the doll hiding underneath.'**
  String get introTowersText;

  /// The glass-case intro card's title (frame 4.2, first met at L31).
  ///
  /// In en, this message translates to:
  /// **'Glass Cases'**
  String get introGlassTitle;

  /// The glass-case intro card's body (frame 4.2).
  ///
  /// In en, this message translates to:
  /// **'A locked doll is freed when the family on its padlock is complete.'**
  String get introGlassText;

  /// The ice intro card's title (frame 4.3, first met at L51).
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get introIceTitle;

  /// The ice intro card's body (frame 4.3).
  ///
  /// In en, this message translates to:
  /// **'Every family you finish cracks the ice. At zero, the doll is free.'**
  String get introIceText;

  /// The walnut tag at a tower's stand in the Towers intro card's illustration: how many nests are still buried in it (frame 4.1, NestyOverlay INTRO; the board's own tag, spec §3.2).
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String introTowersBuriedTag(int count);

  /// The blue chip over an iced doll in the Ice intro card's illustration: how many cracks are left (frame 4.3, NestyOverlay INTRO; the board's ice badge, spec §3.4).
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String introIceCount(int count);

  /// Every mechanic intro card's dismiss button (frames 4.1-4.3, 4.8).
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get introGotIt;

  /// The chapter-complete overlay's title (frame 4.6, spec §7.2).
  ///
  /// In en, this message translates to:
  /// **'CHAPTER {number} COMPLETE'**
  String chapterCompleteTitle(int number);

  /// The chapter-complete overlay's museum line (frame 4.6).
  ///
  /// In en, this message translates to:
  /// **'Added to your Museum!'**
  String get chapterCompleteAdded;

  /// The chapter-complete overlay's coin pill, reward_chapter (frame 4.6, D72).
  ///
  /// In en, this message translates to:
  /// **'+{count} coins'**
  String chapterCompleteCoins(int count);

  /// The chapter-complete overlay's next-chapter line (frame 4.6). {name} is chapterName.
  ///
  /// In en, this message translates to:
  /// **'Next: Chapter {number} · {name}'**
  String chapterCompleteNext(int number, String name);

  /// The generating-board state's caption over the old board's ui_spinner while a bonus level generates (m3 §10.8, a design gap: no frame shows this state).
  ///
  /// In en, this message translates to:
  /// **'Setting up the shelves…'**
  String get gameplayGenerating;
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
