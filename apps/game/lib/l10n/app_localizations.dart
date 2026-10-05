import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('ja'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('tr'),
  ];

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

  /// The splash's storage error title (frame 12.10). copy.md E `splash_storage_title`.
  ///
  /// In en, this message translates to:
  /// **'Your phone is nearly full'**
  String get splashStorageTitle;

  /// The splash's storage error line (frame 12.10). {size} is `SplashCopy.storageMegabytes` (60: the figure lives in code, not in the translations; Q157 asks the owner to confirm it). copy.md E `splash_storage_body`.
  ///
  /// In en, this message translates to:
  /// **'Nesty needs about {size} MB to set up the shelves. Free some space, then try again.'**
  String splashStorageBody(int size);

  /// The splash's content error title (frame 12.11). copy.md E `splash_content_title`.
  ///
  /// In en, this message translates to:
  /// **'The shelves didn’t unpack'**
  String get splashContentTitle;

  /// The splash's content error line (frame 12.11). copy.md E `splash_content_body`.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading. Try again, or restart Nesty.'**
  String get splashContentBody;

  /// Try again: every failed-load card (the splash's two error views 12.10 and 12.11, a level or a race that didn't set up 12.6 and 9.3f, Continue's retry card). copy.md G.5 `race_failed_retry`, E `gen_failed_retry`, `splash_retry`.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// Level label on the Home play button and the gameplay top bar (spec §10.2 #2, #3).
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelTitle(int level);

  /// The gameplay pause button's tooltip and screen-reader label (spec §10.2 #3). copy.md A11y `a11y_pause`.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Undo booster button label (spec §8). copy.md Short forms `booster_undo`.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get boosterUndo;

  /// The Undo booster label's short form (textFit.boosterLabels). copy.md Short forms `booster_undo_short`.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get boosterUndoShort;

  /// Hint booster button label (spec §8). copy.md Short forms `booster_hint`.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get boosterHint;

  /// The Hint booster label's short form (textFit.boosterLabels). copy.md Short forms `booster_hint_short`.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get boosterHintShort;

  /// Extra slot booster button label (spec §3.6, §8). Keep it short. copy.md Short forms `booster_slot`.
  ///
  /// In en, this message translates to:
  /// **'+Slot'**
  String get boosterExtraSlot;

  /// The +Slot booster label's short form (textFit.boosterLabels). The booster bar and frame 12.9 read +Slot; the sheets keep "+1 Slot" as their title. copy.md Short forms `booster_slot_short`.
  ///
  /// In en, this message translates to:
  /// **'+1'**
  String get boosterExtraSlotShort;

  /// Restart the current level (spec §2.4). Always free. copy.md Short forms `booster_restart`.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// The Restart booster label's short form (textFit.boosterLabels). copy.md Short forms `booster_restart_short`.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restartShort;

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

  /// Screen-reader label of the Home coin pill, whose green plus opens the Shop (frame 2.1, spec §10.2 #2). copy.md A11y `a11y_coins`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} coin. Opens the Shop.} other{{count} coins. Opens the Shop.}}'**
  String coinPillShopSemantics(int count);

  /// Red tier badge on the level pill and the Home play button for hard levels (spec §6.6, frames 2.1, 2.2). Keep it very short and uppercase. copy.md Short forms `tier_hard`.
  ///
  /// In en, this message translates to:
  /// **'HARD'**
  String get tierHard;

  /// Purple tier badge on the level pill for super hard levels (spec §6.6, frame 4.4). Keep it very short and uppercase; the chip is tiny. copy.md Short forms `tier_super`.
  ///
  /// In en, this message translates to:
  /// **'SUPER HARD'**
  String get tierSuperHard;

  /// The Super Hard pill's short form (textFit.hudPills). HARD and BONUS have no short form: they drop to their glyph. copy.md Short forms `tier_super_short`.
  ///
  /// In en, this message translates to:
  /// **'SUPER'**
  String get tierSuperShort;

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

  /// Screen-reader label of the family counter (frame 2.2, spec §10.2 #3). The one-family case (Level 1) reads "family"; every other count is copy.md's wording. copy.md A11y `a11y_family_counter`.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{{count} of {total} family complete} other{{count} of {total} families complete}}'**
  String familyCounterSemantics(int count, int total);

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

  /// A Bonus Endless level's name: the level pill, Home's Play button and the win card (frames 4.10, 12.2, 12.4). copy.md E `bonus_win_label`.
  ///
  /// In en, this message translates to:
  /// **'Bonus Level {level}'**
  String bonusLevelTitle(int level);

  /// Screen-reader label of the round close button on cards and popups (frames 3.2, 3.9). copy.md A11y `a11y_close`.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeSemantics;

  /// Screen-reader label of the back arrow in screen headers (spec §10.2). copy.md A11y `a11y_back`.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backSemantics;

  /// Screen-reader label of a booster with none left whose badge offers a rewarded video (frame 3.2, spec §8, §9.1). {booster} is its label. copy.md A11y `a11y_booster_ad`.
  ///
  /// In en, this message translates to:
  /// **'{booster}, watch a video'**
  String boosterAdSemantics(String booster);

  /// Screen-reader label of a booster with none left whose badge shows its coin price (frame 3.3, spec §8). {booster} is its label. copy.md A11y `a11y_booster_price`.
  ///
  /// In en, this message translates to:
  /// **'{price, plural, =1{{booster}, {price} coin} other{{booster}, {price} coins}}'**
  String boosterCoinSemantics(String booster, int price);

  /// Screen-reader label of the Undo booster when its badge shows how many are left (frame 2.2, spec §8). copy.md A11y `a11y_booster_undo`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Undo, {count} left} other{Undo, {count} left}}'**
  String boosterUndoCountSemantics(int count);

  /// Screen-reader label of the Hint booster when its badge shows how many are left (frame 2.2, spec §8). copy.md A11y `a11y_booster_hint`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Hint, {count} left} other{Hint, {count} left}}'**
  String boosterHintCountSemantics(int count);

  /// Screen-reader label of the +1 Slot booster when its badge shows how many are left (frame 2.2, spec §8). Spoken as "Extra slot": a screen reader would read "+Slot" as "plus slot". copy.md A11y `a11y_booster_slot`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Extra slot, {count} left} other{Extra slot, {count} left}}'**
  String boosterSlotCountSemantics(int count);

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

  /// The soft-stuck banner's line when nothing can be undone; Restart glows (frame 12.7). copy.md E `stuck_restart`.
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

  /// The win ribbon, drawn over the ui_win_ribbon animation (frame 2.8, spec §10.2 #4). The band fits about 22 characters; longer text shrinks. copy.md Short forms `win_title`.
  ///
  /// In en, this message translates to:
  /// **'Level Complete!'**
  String get winTitle;

  /// The win ribbon's short form, used only when winTitle doesn't fit the band at its minimum scale (tokens.json textFit.winRibbon). copy.md Short forms `win_title_short`.
  ///
  /// In en, this message translates to:
  /// **'Complete!'**
  String get winTitleShort;

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

  /// A museum figurine family's name (spec §7.2, frames 1.5, 2.8, 4.6, 6.1; m3 §9.3). {figurine} is the museum item id; ids without a name are empty and their line is hidden. Final English (copy.md G.1 `01_classic`…`10_explorer`; Q73).
  ///
  /// In en, this message translates to:
  /// **'{figurine, select, classic{The Classic Family} sailor{The Sailor Family} baker{The Baker Family} astronaut{The Astronaut Family} gardener{The Gardener Family} snow{The Snow Family} circus{The Circus Family} musician{The Musician Family} royal{The Royal Family} explorer{The Explorer Family} other{}}'**
  String figurineName(String figurine);

  /// The ribbon on a chapter's first level, drawn over the ui_chapter_ribbon animation, fading after about 2 s (frame 4.7, spec §7.1). {name} is chapterName. The band fits about 22 characters; longer text shrinks. copy.md Short forms `chapter_ribbon`.
  ///
  /// In en, this message translates to:
  /// **'CHAPTER {number} · {name}'**
  String chapterRibbon(int number, String name);

  /// The chapter ribbon's short form (textFit.chapterRibbon) when chapterRibbon doesn't fit: the name alone. {name} is chapterName. copy.md Short forms `chapter_ribbon_short`.
  ///
  /// In en, this message translates to:
  /// **'{name}'**
  String chapterRibbonShort(String name);

  /// A chapter's name, which is its board theme's name (spec §7.1, §12.4; frames 4.6, 4.7, 7.7, 10.4). {theme} is the theme id. ch07–ch10 are copy.md G.4 `7`…`10`; tokens.json `theme.chapters.N.name` repeats them (checked by design_tokens_codegen_test).
  ///
  /// In en, this message translates to:
  /// **'{theme, select, ch01{Sunny Toy Shop} ch02{Rainy Café Corner} ch03{Seaside Market} ch04{Snowy Cabin} ch05{Night Carnival} ch06{Spring Garden Shed} ch07{Puppet Theater} ch08{Autumn Bandstand} ch09{Castle Library} ch10{Sunrise Lookout} other{}}'**
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

  /// Pause card tile that leaves the level for Home (frame 3.9, spec §10.2 #14). copy.md Short forms `tab_home`.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Pause card tile and Home gear that open Settings (frames 2.1, 3.9, spec §10.2 #13). Also the gear's screen-reader label. copy.md A11y `a11y_settings`.
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

  /// The failure card's text link back Home (frame 12.6). copy.md E `gen_failed_home`.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get nextLevelFailedHome;

  /// The card when a level couldn't be set up (frame 12.6). copy.md E `gen_failed_title`.
  ///
  /// In en, this message translates to:
  /// **'The shelves need a moment'**
  String get gameplayFailedTitle;

  /// The line under gameplayFailedTitle (frame 12.6). copy.md E `gen_failed_body`.
  ///
  /// In en, this message translates to:
  /// **'This level didn’t set up. Try again, or head back home.'**
  String get gameplayFailedBody;

  /// Title of the dev-flavor level picker sheet (dev builds only; plan P4).
  ///
  /// In en, this message translates to:
  /// **'Jump to a level'**
  String get devLevelPickerTitle;

  /// Section header grouping the dev-flavor level picker's tiles by chapter, so a 200-level bundle scrolls in bounded sections instead of one long grid (dev builds only; owner 2026-09-28 simulator review).
  ///
  /// In en, this message translates to:
  /// **'Chapter {number} · Levels {start}–{end}'**
  String devLevelPickerChapterHeader(int number, int start, int end);

  /// The shell's bottom-nav Shop tab label (frame 2.1; m3 §10.1, §10.9). copy.md Short forms `tab_shop`.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// The Home tab label's short form (textFit.tabBar). copy.md Short forms `tab_home_short`.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHomeShort;

  /// The Shop tab label's short form (textFit.tabBar). copy.md Short forms `tab_shop_short`.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShopShort;

  /// The shell's bottom-nav Museum tab label (frame 2.1; m3 §10.1, §10.9). copy.md Short forms `tab_museum`.
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get navMuseum;

  /// The Museum tab label's short form (textFit.tabBar). copy.md Short forms `tab_museum_short`.
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get navMuseumShort;

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

  /// Home's Daily tile, and the Daily screen, before the daily opens (frames 12.3, 12.2). {level} is `DailyService.unlockAfterLevel` (2: the level to win first, Q67). copy.md E `daily_locked`.
  ///
  /// In en, this message translates to:
  /// **'After Level {level}'**
  String homeDailyLocked(int level);

  /// Home's Play button badge on a bonus level (frame 12.2). copy.md E `home_bonus_badge`. Also copy.md Short forms `tier_bonus`.
  ///
  /// In en, this message translates to:
  /// **'BONUS'**
  String get homeBonusBadge;

  /// Home's chapter card kicker once every campaign level is won (frame 12.2). copy.md E `home_bonus_kicker`.
  ///
  /// In en, this message translates to:
  /// **'BONUS ENDLESS'**
  String get homeBonusKicker;

  /// Home's chapter card name once every campaign level is won (frame 12.2). copy.md E `home_bonus_name`.
  ///
  /// In en, this message translates to:
  /// **'Bonus levels'**
  String get homeBonusName;

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

  /// A launch language's name in the UI language, next to its autonym, which is data rather than ARB since it reads the same in every locale (frame 8.2, m3 §10.2). {language} is the locale code. The English row draws no name, but a screen reader and Settings' fallback use the en branch.
  ///
  /// In en, this message translates to:
  /// **'{language, select, en{English} es{Spanish} pt_BR{Portuguese} id{Indonesian} hi{Hindi} de{German} fr{French} tr{Turkish} ja{Japanese} other{}}'**
  String languageName(String language);

  /// Joins two parts of one screen-reader label, such as a level's number and its stars (spec §16). Each language writes its own separator (Japanese uses 、). A longer label folds its parts through this one pair at a time.
  ///
  /// In en, this message translates to:
  /// **'{first}, {second}'**
  String a11yJoinList(String first, String second);

  /// Joins two sentences of one screen-reader label (a card's title, then its explanation; spec §16). Each language writes its own full stop (Japanese uses 。 with no space). Folded through this one pair at a time.
  ///
  /// In en, this message translates to:
  /// **'{first}. {second}'**
  String a11yJoinSentences(String first, String second);

  /// Screen-reader label of an unselected language sheet row (frame 8.2, spec §16): the language's own name, then its languageName. The selected row is read by its own name alone.
  ///
  /// In en, this message translates to:
  /// **'{autonym}, {detail}'**
  String languageRowSemantics(String autonym, String detail);

  /// The Daily streak card's big number (frames 5.1, 10.7). copy.md G.9 `streak_days`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String dailyStreakDays(int count);

  /// The Daily streak card's line while a lit streak waits for today's solve. Not in copy.md m7-3: M7 phase 1's value-framed line, kept.
  ///
  /// In en, this message translates to:
  /// **'Play today to add to your streak'**
  String get dailyStreakKeep;

  /// The Daily streak card's line before any streak (streak 0). copy.md G.9 `streak_zero`.
  ///
  /// In en, this message translates to:
  /// **'Solve today’s puzzle to light your first flame.'**
  String get dailyStreakStart;

  /// The Daily streak card's line once today's puzzle is solved (frames 5.5, 10.7). copy.md G.9 `streak_lit`.
  ///
  /// In en, this message translates to:
  /// **'Your flame is lit. See you tomorrow.'**
  String get dailyStreakDone;

  /// The Daily streak card's line on a 7-day week. Not in copy.md m7-3: M3's line, kept.
  ///
  /// In en, this message translates to:
  /// **'A full week!'**
  String get dailyStreakWeek;

  /// The Daily streak card's freeze count. Not in copy.md m7-3: M3's line, kept.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No freeze} =1{1 freeze} other{{count} freezes}}'**
  String dailyFreezes(int count);

  /// Screen-reader label of the Daily streak card's freezes (frame 5.1). Visible: dailyFreezes. copy.md A11y `a11y_freezes` says "{count} streak freeze left"; "left" is the respect rules' scarcity word (spec-prop §1.1, E1), so the string keeps the rule and drops the word (an owner question).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} streak freeze} other{{count} streak freezes}}'**
  String dailyFreezesSemantics(int count);

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

  /// The 7-day strip's chest row caption (frame 5.1). {count} is the chest's coins (the app fills it). copy.md E `daily_chest_title`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Day 7 chest · {count} coin} other{Day 7 chest · {count} coins}}'**
  String dailyChestRow(int count);

  /// The Daily chest row's days still to go (frame 5.1). {count} is the days. copy.md E `daily_chest_to_go`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day to go} other{{count} days to go}}'**
  String dailyChestToGo(int count);

  /// The Daily chest row's days still to go while today's puzzle is unsolved (frame 5.1). {count} is the days. copy.md E `daily_chest_to_go_today`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day to go, counting today} other{{count} days to go, counting today}}'**
  String dailyChestToGoToday(int count);

  /// The Daily chest row once the chest was opened today (frame 5.1). copy.md E `daily_chest_opened`.
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

  /// Play Level N: the Daily solved state's button back to the campaign (frame 5.5) and the Museum's next-family card (frame 6.1). copy.md G.10 `museum_play`.
  ///
  /// In en, this message translates to:
  /// **'Play Level {level}'**
  String playLevel(int level);

  /// The freeze notice's title, shown once after a freeze covers a missed day (frame 5.2). copy.md G.9 `streak_freeze_used`.
  ///
  /// In en, this message translates to:
  /// **'A freeze kept your flame lit.'**
  String get dailySavedTitle;

  /// The freeze notice's line (frame 5.2). Not in copy.md m7-3: M3's line, kept.
  ///
  /// In en, this message translates to:
  /// **'A freeze covered {weekday}. You\'ll earn a new one next week.'**
  String dailySavedBody(String weekday);

  /// The day-7 chest card's ribbon title (frame 5.6). copy.md G.9 `chest_streak_title`.
  ///
  /// In en, this message translates to:
  /// **'7-day streak!'**
  String get dailyChestTitle;

  /// The day-7 chest card's line (frame 5.6); "Seven" is spec-prop §7.5's fixed day-7 cadence, not a number the app fills. copy.md G.9 `chest_streak_body`.
  ///
  /// In en, this message translates to:
  /// **'Seven days in a row. Here’s what’s inside.'**
  String get dailyChestBody;

  /// The day-7 chest's Double it (a rewarded ad, M6; frame 5.6b). copy.md G.9 `chest_double`.
  ///
  /// In en, this message translates to:
  /// **'Double it'**
  String get dailyChestDouble;

  /// A chest card's Collect button once open: the rewards fly to the coin pill and Hint (frames 10.3d, 5.6b). copy.md G.9 `chest_collect`.
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

  /// The Museum screen's collection card count, e.g. "2 / 10" (frame 6.1). Distinct from homeMuseumProgress, which has no spaces.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String museumCount(int done, int total);

  /// The Museum's next-family line: the chapter and the levels left (frame 6.1; Q115). copy.md G.10 `museum_next_line`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Chapter {chapter} · 1 level to go} other{Chapter {chapter} · {count} levels to go}}'**
  String museumNextLine(int chapter, int count);

  /// The Museum's line once every family is home (frame 6.1c). copy.md G.10 `museum_all_home`.
  ///
  /// In en, this message translates to:
  /// **'Every family is home.'**
  String get museumAllHome;

  /// The Museum's next-family card's kicker (frame 6.1). copy.md G.10 `museum_next`.
  ///
  /// In en, this message translates to:
  /// **'Next family'**
  String get museumNextFamily;

  /// museumNextFamily as the card's capitalised kicker (frame 6.1). Each language writes its own capitals (Turkish keeps İ and I apart), so the code never changes the case of a string.
  ///
  /// In en, this message translates to:
  /// **'NEXT FAMILY'**
  String get museumNextFamilyKicker;

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

  /// A figurine's italic flavor text in its detail modal (frame 6.2); an id without one is empty and the line is hidden. {figurine} is the museum item id (copy.md G.2 `01_classic`…`10_explorer`).
  ///
  /// In en, this message translates to:
  /// **'{figurine, select, classic{“The smallest one wins every game of hide-and-seek.”} sailor{“They keep a seashell in the smallest doll, just in case.”} baker{“They bake every loaf in four sizes, so nobody has to share.”} astronaut{“They count down from the biggest to the smallest before every trip to the moon.”} gardener{“Each hat hides a seed they’re saving for spring.”} snow{“When nobody is looking, they stack up into a snowman.”} circus{“Their best act is climbing inside each other, to great applause.”} musician{“They play one song in four sizes. The smallest takes the high notes.”} royal{“Every crown fits inside the next one, which saves a lot of room.”} explorer{“They’ve mapped every shelf in the shop, and they’re not done yet.”} other{}}'**
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

  /// The Museum's one-line explainer (frame 6.1). {levels} is a chapter's level count (ChapterInfo.levelsPerChapter, 20 in the bundle; the app fills it). copy.md G.10 `museum_intro`.
  ///
  /// In en, this message translates to:
  /// **'Every chapter has a doll family. Win all {levels} of its levels to bring that family home.'**
  String museumIntro(int levels);

  /// The Museum's next-family card: the levels left in its chapter (frame 6.1). copy.md G.10 `museum_next_to_go`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 level to go} other{{count} levels to go}}'**
  String museumLevelsToGo(int count);

  /// The count chip on the Museum's next-family niche (frame 6.1). {count} is the levels still to win. The two forms read alike in English; translators may differ. copy.md G.10 `museum_next_chip`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} to go} other{{count} to go}}'**
  String museumNextChip(int count);

  /// A locked shelf's label where one line is too narrow. copy.md G.10 `museum_locked_shelf_short`.
  ///
  /// In en, this message translates to:
  /// **'Ch {chapter} · {first}–{last}'**
  String museumLockedShelfShort(int chapter, int first, int last);

  /// A locked shelf's two-line 11 px label, first line (frame 6.1; Q123). copy.md G.10 `museum_locked_line_1`.
  ///
  /// In en, this message translates to:
  /// **'Chapter {chapter}'**
  String museumLockedLine1(int chapter);

  /// A locked shelf's two-line label, second line (frame 6.1). copy.md G.10 `museum_locked_line_2`.
  ///
  /// In en, this message translates to:
  /// **'Levels {first}–{last}'**
  String museumLockedLine2(int first, int last);

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

  /// A Shop skin card's screen-reader value for a skin the player owns but has not equipped, read after its name; the card itself shows Equip (frame 7.3). copy.md A11y `a11y_skin_owned`.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get skinOwnedSemantics;

  /// A skin's display name (frames 7.3, 7.4, 7.4b). {skin} is the catalog skin id with `-` as `_` (an ICU select key can't hold `-`: `forest-bear` is `forest_bear`; `CatalogL10n.skinNameOf` maps it). Forest Bear is copy.md H `forest_bear_name`; the others are M3's names.
  ///
  /// In en, this message translates to:
  /// **'{skin, select, classic{Classic} space{Space} ocean{Ocean} sweets{Sweets} forest{Forest Friends} winter{Winter} forest_bear{Forest Bear} other{}}'**
  String skinName(String skin);

  /// A skin's Shop card and detail-page description (frames 7.3, 7.4); an id without one is empty and the line is hidden. {skin} is the skin id with `-` as `_` (`CatalogL10n.skinDescriptionOf`). copy.md G.3 `classic`…`winter` and H `forest_bear_description`.
  ///
  /// In en, this message translates to:
  /// **'{skin, select, classic{Painted flowers, gold dots and a little bow.} ocean{Sailor collars, tiny anchors and wave trims.} space{Round helmets, tiny antennas and ringed planets.} sweets{Frosting drips, sprinkles and candy stripes.} forest{Pointy ears, pearl-trimmed hoods and falling leaves.} winter{Pompom hats, snowflakes and pearly trims.} forest_bear{Round bear ears, cozy hoods and acorns in the leaves.} other{}}'**
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

  /// NotEnoughCoinsDialog's title (frames 7.3b, 7.4c; D112). copy.md G.10 `coins_needed_title`.
  ///
  /// In en, this message translates to:
  /// **'A few more coins'**
  String get notEnoughCoinsTitle;

  /// NotEnoughCoinsDialog's line: how many more coins the balance is short. copy.md G.10 `coins_needed_body`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You need 1 more coin} other{You need {count} more coins}}'**
  String notEnoughCoinsNeeded(int count);

  /// NotEnoughCoinsDialog's line naming where coins come from. copy.md G.10 `coins_needed_where`.
  ///
  /// In en, this message translates to:
  /// **'Coins come from winning levels, the daily puzzle and chests.'**
  String get notEnoughCoinsSource;

  /// NotEnoughCoinsDialog's Go to Shop button. copy.md G.10 `coins_needed_shop`.
  ///
  /// In en, this message translates to:
  /// **'Go to Shop'**
  String get notEnoughCoinsGoToShop;

  /// A dialog's secondary "Not now" button: NotEnoughCoinsDialog, the New rival unlocked card and the reminder's denied card. It is deliberately not under a respect-test prefix (its "now" is the opposite of urgency). copy.md G.10 `coins_needed_later`. copy.md G.5 `rival_unlocked_later`. copy.md G.7 `reminder_not_now`.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

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

  /// L1's tutorial step 1 title (frames 1.3, 10.8b). copy.md E `tut_step_1_title`.
  ///
  /// In en, this message translates to:
  /// **'Tap the small doll'**
  String get tutorialStep1Title;

  /// The chip on Level 1's three tutorial steps (frames 1.3, 1.4, 10.8b; lead note 6: copy.md is newer than the frames' "OF 2"). {total} is the script's step count (3). copy.md E `tut_step_chip`.
  ///
  /// In en, this message translates to:
  /// **'STEP {step} OF {total}'**
  String tutorialStepChip(int step, int total);

  /// L1's tutorial step 1 body (frames 1.3, 10.8b). copy.md E `tut_step_1_body`.
  ///
  /// In en, this message translates to:
  /// **'Dolls nest into the same color, one size bigger.'**
  String get tutorialStep1Text;

  /// L1's tutorial step 2 title (frames 1.4, 10.8b). copy.md E `tut_step_2_title`.
  ///
  /// In en, this message translates to:
  /// **'Now tap the big one'**
  String get tutorialStep2Title;

  /// L1's tutorial step 2 body (frames 1.4, 10.8b). copy.md E `tut_step_2_body`.
  ///
  /// In en, this message translates to:
  /// **'The small doll drops inside with a clack.'**
  String get tutorialStep2Text;

  /// L1's tutorial step 3 title (frames 1.5, 10.8b). copy.md E `tut_step_3_title`.
  ///
  /// In en, this message translates to:
  /// **'Finish the family'**
  String get tutorialStep3Title;

  /// Level 1's tutorial step 3 line (frame 10.8b). copy.md E `tut_step_3_body`.
  ///
  /// In en, this message translates to:
  /// **'Put the last doll in. A family is done when every size is nested.'**
  String get tutorialStep3Text;

  /// Screen-reader announcement of a tutorial step's card (frames 1.3-1.5). {step} is 1-3, {title} the step's title (tutorialStep1Title...). copy.md A11y `a11y_tut_step`.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 3. {title}'**
  String tutorialStepSemantics(int step, String title);

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

  /// The generating card's line under `ui_spinner` while a level is made (frame 12.5). copy.md E `gen_busy`.
  ///
  /// In en, this message translates to:
  /// **'Setting up the shelves…'**
  String get gameplayGenerating;

  /// The Daily streak card's line while the flame is paused: a missed day no freeze covered, streak > 0, today unsolved (spec-prop §7.5; frame 10.7). A missed day never lowers the number. copy.md G.9 `streak_paused`.
  ///
  /// In en, this message translates to:
  /// **'Your {count}-day streak is resting. Solve today’s puzzle to light it again.'**
  String dailyStreakPaused(int count);

  /// The Daily streak card's chip while the flame is paused (frame 10.7). copy.md G.9 `streak_paused_chip`.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get dailyStreakPausedChip;

  /// The daily win card's title when the solve relit a paused streak (frame 10.7b). copy.md G.9 `streak_relit_title`.
  ///
  /// In en, this message translates to:
  /// **'Streak relit!'**
  String get dailyStreakRelitTitle;

  /// The daily win card's line when the solve relit a paused streak (frame 10.7b). {count} is the streak after the solve. copy.md G.9 `streak_relit_body`.
  ///
  /// In en, this message translates to:
  /// **'Your {count}-day streak is glowing again.'**
  String dailyStreakRelitBody(int count);

  /// Home's streak badge's screen-reader label while paused (spec §16). Not in copy.md m7-3: a screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1-day streak, paused} other{{count}-day streak, paused}}'**
  String streakBadgeSemanticsPaused(int count);

  /// The Chapters screen's title (frame 10.4). copy.md G.10 `chapters_title`.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chaptersTitle;

  /// The Chapters header's overall line and its bar's semantics: the current campaign level over every catalog level (frame 10.4). copy.md G.10 `chapters_progress`.
  ///
  /// In en, this message translates to:
  /// **'Level {level} of {total}'**
  String chaptersOverallProgress(int level, int total);

  /// A folded chapter row's levels won (frame 10.4). copy.md G.10 `chapters_won`.
  ///
  /// In en, this message translates to:
  /// **'{count} won'**
  String chaptersWonCount(int count);

  /// The level card's and a won cell's best moves (frames 10.4, 10.4b). copy.md G.11 `level_best`.
  ///
  /// In en, this message translates to:
  /// **'Best {best}'**
  String chaptersBestMoves(int best);

  /// The Chapters level card's Play button (frame 10.4b). copy.md G.11 `level_play`.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get chaptersLevelPlay;

  /// A won Chapters level cell's screen-reader label (frame 10.4, spec §16). {count} is the cell's stars (1-3), {best} its best moves. copy.md A11y `a11y_level_won`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Level {level}, {count} star. Best {best} moves.} other{Level {level}, {count} stars. Best {best} moves.}}'**
  String chaptersLevelSemanticsWon(int level, int count, int best);

  /// A won Chapters level cell's screen-reader label when the save holds no best or stars for it (a save from before they were kept). Not in copy.md m7-4: the fallback beside a11y_level_won.
  ///
  /// In en, this message translates to:
  /// **'Level {level}, won'**
  String chaptersLevelSemanticsWonNoBest(int level);

  /// A won Chapters level cell's screen-reader label when the save holds a best but no stars for it (a level without a par). Not in copy.md m7-4: the fallback beside a11y_level_won, in its words.
  ///
  /// In en, this message translates to:
  /// **'{best, plural, =1{Level {level}, won. Best {best} move.} other{Level {level}, won. Best {best} moves.}}'**
  String chaptersLevelSemanticsWonBestOnly(int level, int best);

  /// The Chapters level cell for the level to play next (frame 10.4, spec §16). copy.md A11y `a11y_level_current`.
  ///
  /// In en, this message translates to:
  /// **'Level {level}, next to play'**
  String chaptersLevelSemanticsCurrent(int level);

  /// A locked Chapters level cell's screen-reader label (spec §16). copy.md A11y `a11y_level_locked`.
  ///
  /// In en, this message translates to:
  /// **'Level {level}, locked'**
  String chaptersLevelSemanticsLocked(int level);

  /// The Records screen's title (frame 10.6). copy.md G.10 `records_title`.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get recordsTitle;

  /// Home's Records button's label (frame 2.1). Not in copy.md m7-3: a label for the button.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get homeRecordsButton;

  /// Records' Levels won cell. copy.md G.10 `records_levels_won`.
  ///
  /// In en, this message translates to:
  /// **'Levels won'**
  String get recordsLevelsWon;

  /// Records' families cell label (frame 10.6), under the lifetime count of every family a won board completed, shown with the family counter's doll mark (`records.families`, spec-prop §7.9). It is not the Museum's "of 10" count: `records_families_value` is withdrawn (Q159). copy.md G.10 `records_families`.
  ///
  /// In en, this message translates to:
  /// **'Families completed'**
  String get recordsFamilies;

  /// Records' races card header, with a row per rival: portrait, name and the Computer tag (frame 10.6). copy.md G.10 `records_races`.
  ///
  /// In en, this message translates to:
  /// **'Races won'**
  String get recordsRacesHeader;

  /// Records' Dolls nested cell. copy.md G.10 `records_dolls_nested`.
  ///
  /// In en, this message translates to:
  /// **'Dolls nested'**
  String get recordsDolls;

  /// Records' Daily puzzles solved cell (frame 10.6). copy.md G.10 `records_dailies`.
  ///
  /// In en, this message translates to:
  /// **'Daily puzzles solved'**
  String get recordsDailies;

  /// Records' Longest streak cell. copy.md G.10 `records_longest_streak`.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get recordsLongestStreak;

  /// Records' link to the Chapters screen's best moves, with the `route` glyph (frame 10.6). copy.md G.10 `records_best_moves`.
  ///
  /// In en, this message translates to:
  /// **'Best moves by level'**
  String get recordsBestMovesLink;

  /// Records' badge grid header (frame 10.6). copy.md G.8 `records_badges`.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get recordsBadgesHeader;

  /// A badge's name on Records and its toast (spec-prop §7.8; frame 10.6). {badge} is BadgeId.id. copy.md G.8 `<id>`.
  ///
  /// In en, this message translates to:
  /// **'{badge, select, first_family{Snug as a Doll} glass_breaker{Glass Act} ice_melter{Ice Breaker} tall_order{Tall Order} grand_nest{Grand Nest} level_100{Halfway Home} level_200{Top Shelf} dailies_7{Puzzle Pal} dailies_30{Old Friend} first_race{First Past the Shelf} all_rivals{Rival Round-Up} museum_full{Full House} other{}}'**
  String badgeName(String badge);

  /// An earned badge's one-liner on its Records card: how it was earned (frame 10.6b). {badge} is BadgeId.id. copy.md G.8 `<id>_line`.
  ///
  /// In en, this message translates to:
  /// **'{badge, select, first_family{You nested your first family.} glass_breaker{You opened your first glass case.} ice_melter{You freed a doll from the ice.} tall_order{You won a level with size-5 dolls.} grand_nest{You won a level with size-6 dolls.} level_100{You won level 100.} level_200{You won level 200, the very last one.} dailies_7{You solved 7 daily puzzles.} dailies_30{You solved 30 daily puzzles.} first_race{You beat the computer in a race.} all_rivals{You beat every computer rival.} museum_full{Every family is home in your Museum.} other{}}'**
  String badgeLine(String badge);

  /// A locked badge's how-to line, read after badgeSemanticsLocked and by nothing else (frame 10.6, spec §16). {badge} is BadgeId.id. {level} and {count} are the rule's numbers (BadgeRules: level 100 or 200 won; 7 or 30 dailies), so a tuning change can't contradict the copy. The ids are the select cases: `<badge>_how`. copy.md A11y `first_family_how`, `glass_breaker_how`, `ice_melter_how`, `tall_order_how`, `grand_nest_how`, `level_100_how`, `level_200_how`, `dailies_7_how`, `dailies_30_how`, `first_race_how`, `all_rivals_how`, `museum_full_how`.
  ///
  /// In en, this message translates to:
  /// **'{badge, select, first_family{Nest a whole family.} glass_breaker{Open a glass case.} ice_melter{Free a doll from the ice.} tall_order{Win a level with size-5 dolls.} grand_nest{Win a level with size-6 dolls.} level_100{Win level {level}.} level_200{Win level {level}.} dailies_7{Solve {count} daily puzzles.} dailies_30{Solve {count} daily puzzles.} first_race{Beat the computer in a race.} all_rivals{Beat every computer rival.} museum_full{Bring every family home to your Museum.} other{}}'**
  String badgeHint(String badge, int level, int count);

  /// An earned badge's screen-reader label (frame 10.6). {badge} is badgeName. copy.md A11y `a11y_badge_earned`.
  ///
  /// In en, this message translates to:
  /// **'{badge}, earned'**
  String badgeSemanticsEarned(String badge);

  /// A locked badge's screen-reader label (frame 10.6). {badge} is badgeName, {how} is badgeHint, the how-to line only a screen reader hears; the visible line stays badgeLockedLine. copy.md A11y `a11y_badge_locked`.
  ///
  /// In en, this message translates to:
  /// **'{badge}, not earned yet. {how}'**
  String badgeSemanticsLocked(String badge, String how);

  /// The toast when a win earns a badge, at top 60 over the result card, one at a time (Q122, Q136; frame 10.6). {badge} is badgeName. copy.md G.8 `badge_earned_toast`.
  ///
  /// In en, this message translates to:
  /// **'Badge earned · {badge}'**
  String badgeEarnedToastTitle(String badge);

  /// A locked badge's line on its Records card (frame 10.6). copy.md G.8 `badge_locked_line`.
  ///
  /// In en, this message translates to:
  /// **'Not earned yet'**
  String get badgeLockedLine;

  /// The win card's moves chip on a campaign level or a replay: this win's moves and the level's best after it (frame 11.2). copy.md G.11 `moves_line`.
  ///
  /// In en, this message translates to:
  /// **'Moves {moves} · Best {best}'**
  String winMovesBest(int moves, int best);

  /// The win card's moves chip on a first win and on a board that keeps no best (daily, bonus, race). copy.md G.11 `moves_line_first`.
  ///
  /// In en, this message translates to:
  /// **'Moves {moves}'**
  String winMovesOnly(int moves);

  /// The win card's chest row: the levels to the next milestone chest (frame 10.3). copy.md G.9 `chest_progress`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 level to the chest} other{{count} levels to the chest}}'**
  String winChestCountdown(int count);

  /// The replay win card's reason line with the `replay` glyph (frame 10.5). copy.md G.11 `replay_reason`.
  ///
  /// In en, this message translates to:
  /// **'A replay for fun: coins come from new levels.'**
  String get winReplayReason;

  /// The replay win card's button back to Chapters (frame 10.5). copy.md G.11 `replay_back`.
  ///
  /// In en, this message translates to:
  /// **'Back to Chapters'**
  String get winBackToChapters;

  /// The milestone chest card's ribbon title (spec-prop §7.3; frame 10.3b). copy.md G.9 `chest_milestone_title`.
  ///
  /// In en, this message translates to:
  /// **'Milestone chest'**
  String get chestMilestoneTitle;

  /// The milestone chest card's line after a campaign chapter's level 10 (frame 10.3b); its contents show before it opens (spec-prop §1.1 rule 2). copy.md G.9 `chest_milestone_body`.
  ///
  /// In en, this message translates to:
  /// **'A chest for reaching level {level}. Here’s what’s inside.'**
  String chestMilestoneBody(int level);

  /// The milestone chest card's line after every 10th Bonus Endless level (frame 12.4). copy.md G.9 `chest_bonus_body`.
  ///
  /// In en, this message translates to:
  /// **'A chest for bonus level {level}. Here’s what’s inside.'**
  String chestMilestoneBodyBonus(int level);

  /// A chest's coin chip, shown with its promised amount from the start, with no count-up (spec-prop §1.1 rule 2; frame 10.3b). copy.md G.9 `chest_coins`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 coin} other{+{count} coins}}'**
  String chestContentsCoins(int count);

  /// A chest's hint chip, shown from the start (frame 10.3b). copy.md G.9 `chest_hints`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 hint} other{+{count} hints}}'**
  String chestContentsHint(int count);

  /// A chest's contents as one screen-reader phrase, joined by a comma ("100 coins, 1 hint"), for chestSemantics' {contents}. A coins-only chest uses coinsSemantics. Not in copy.md m7-4: copy.md says the game joins the chip labels with commas; this key does the joining so a locale controls its own separator.
  ///
  /// In en, this message translates to:
  /// **'{coins, plural, =1{{coins} coin} other{{coins} coins}}, {hints, plural, =1{{hints} hint} other{{hints} hints}}'**
  String chestContentsSemantics(int coins, int hints);

  /// A chest's screen-reader label on the milestone and streak chest cards (frames 10.3, 5.6). {contents} is chestContentsSemantics (or coinsSemantics for a coins-only chest). copy.md A11y `a11y_chest_contents`.
  ///
  /// In en, this message translates to:
  /// **'Chest. Inside: {contents}.'**
  String chestSemantics(String contents);

  /// A chest card's Open button (frames 10.3b, 5.6). copy.md G.9 `chest_open`.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get chestOpen;

  /// Settings' Relaxed mode toggle (frame 10.2e). copy.md G.9 `relaxed_title`.
  ///
  /// In en, this message translates to:
  /// **'Relaxed mode'**
  String get settingRelaxedMode;

  /// Relaxed mode's subtitle. copy.md G.9 `relaxed_sub`.
  ///
  /// In en, this message translates to:
  /// **'Unlimited free undo'**
  String get settingRelaxedModeSubtitle;

  /// The toast when Relaxed mode is on at a level's start (frame 10.9). copy.md G.9 `relaxed_on`.
  ///
  /// In en, this message translates to:
  /// **'Relaxed mode is on. Undo as often as you like.'**
  String get relaxedModeOn;

  /// Settings' Reduce motion row with its Off · On · System control (frame 10.2e). copy.md G.7 `settings_reduce_motion`. It is also the segmented control's group label for a screen reader. copy.md A11y `a11y_reduce_motion_group`.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingReduceMotion;

  /// Reduce motion's System segment (the default: the phone's setting). copy.md G.7 `settings_reduce_motion_system`.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get reduceMotionSystem;

  /// Reduce motion's On segment. copy.md G.7 `settings_reduce_motion_on`.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get reduceMotionOn;

  /// Reduce motion's Off segment. copy.md G.7 `settings_reduce_motion_off`.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reduceMotionOff;

  /// The Out of moves sheet's Undo row with Relaxed mode on, or in a race (frame 10.9b). copy.md G.9 `relaxed_undo_row`.
  ///
  /// In en, this message translates to:
  /// **'Free, as often as you like'**
  String get oomUndoFreeUnlimited;

  /// The Out of moves sheet's Undo row once the free undos are spent (frame 12.8). {count} is free_undos_per_level (2 by default; the app fills it). copy.md E `oom_undo_spent`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your {count} free undo is used} other{Your {count} free undos are used}}'**
  String oomUndoSpent(int count);

  /// The toast when the level's last +1 Slot lands (frame 12.9). {count} is LayoutLimits.maxExtraSlots (2; the app fills it). copy.md E `slot_limit`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One extra slot is the most for one level.} other{{count} extra slots is the most for one level.}}'**
  String extraSlotLimitToast(int count);

  /// Screen-reader label of the Undo booster with Relaxed mode on (its badge shows the `all_inclusive` glyph; spec §16). copy.md A11y `a11y_undo_unlimited`.
  ///
  /// In en, this message translates to:
  /// **'Undo, unlimited'**
  String get boosterUndoUnlimitedSemantics;

  /// The chip on the Out of Moves sheet's Undo row in Relaxed mode: the `all_inclusive` glyph and this word (frame 10.9b). The row's own line is oomUndoFreeUnlimited. copy.md G.9 `relaxed_free_chip`.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get oomUndoFreeChip;

  /// Screen-reader label of the +1 Slot booster at its limit: its sunk face shows "2/2" (frame 12.9; spec §16). {count} is the slots used, {total} LayoutLimits.maxExtraSlots. copy.md A11y `a11y_booster_slot_used`.
  ///
  /// In en, this message translates to:
  /// **'+Slot, {count} of {total} used'**
  String boosterLimitSemantics(int count, int total);

  /// The green tag over a booster as a chest's sprite lands on it (frame 10.3d). {count} is the number gained. copy.md E `chest_gain_tag`.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String hintGainedTag(int count);

  /// Screen-reader label of the Restart booster while it glows because the level looks stuck with nothing to undo (frame 12.7): nothing reads "Suggested" on screen, the ring alone marks it. {booster} is the Restart label. copy.md A11y `a11y_booster_suggested`.
  ///
  /// In en, this message translates to:
  /// **'{booster}, suggested'**
  String boosterSuggestedSemantics(String booster);

  /// Screen-reader label of the Restart booster's button (frame 2.2, spec §2.4); its visible label is `restart`. copy.md A11y `a11y_booster_restart`.
  ///
  /// In en, this message translates to:
  /// **'Restart the level'**
  String get boosterRestartSemantics;

  /// Home's vs Computer tile (frames 2.1, 9.1). copy.md G.5 `home_tile_versus`.
  ///
  /// In en, this message translates to:
  /// **'vs Computer'**
  String get homeVsComputerTile;

  /// Home's vs Computer tile while it is locked (frame 9.1b). {level} is `race_unlock_level` (20 by default; the app fills it from Remote Config). copy.md G.5 `rival_locked_mode`.
  ///
  /// In en, this message translates to:
  /// **'After Level {level}'**
  String homeVsComputerLocked(int level);

  /// The Flame board's tag on a tower: the nests hidden below its top (frame 2.2; spec §3.2). Through ARB for the locale's digits and direction (spec §16; m7 §18, the marker in slot_decor.dart).
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String boardTowerHidden(int count);

  /// The ice badge's counter on a frozen slot: the sets still to complete (frame 2.4; spec §3.4). Through ARB for the locale's digits (spec §16; m7 §18).
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String boardIceCount(int count);

  /// Rival select's title (frame 9.2). copy.md G.5 `mode_title`.
  ///
  /// In en, this message translates to:
  /// **'vs Computer'**
  String get raceSelectTitle;

  /// Rival select's line under the title (frame 9.2). copy.md G.5 `mode_sub`.
  ///
  /// In en, this message translates to:
  /// **'Race a computer on the same puzzle'**
  String get raceSelectSubtitle;

  /// The Computer tag beside every computer rival's name, with the `computer` glyph: select, the strip, the results, Pause and Records (spec-prop §1.1 rule 5; frames 9.2–9.7b). copy.md G.5 `tag_computer`.
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get raceComputerTag;

  /// A computer rival's name by number 1-3, on select, the strip, the results, Pause and Records. Always shown with the Computer tag (Q-P4-7's decision; spec-prop §1.1 rule 5). copy.md G.5 `rival_1_name`…`rival_3_name`.
  ///
  /// In en, this message translates to:
  /// **'{number, plural, =1{Pebble} =2{Button} other{Comet}}'**
  String raceRivalName(int number);

  /// A computer rival's one-line personality on its select card, by rival number 1-3 (frame 9.2). It describes the computer, never the player, and uses none of the respect rules' denied words. copy.md G.5 `rival_1_personality`, `rival_2_personality`, `rival_3_personality`.
  ///
  /// In en, this message translates to:
  /// **'{number, plural, =1{Takes its time and enjoys every doll along the way.} =2{Checks each move twice, then makes it.} other{Lively, tidy and hard to catch.}}'**
  String raceRivalBlurb(int number);

  /// A computer rival's pace label on its select card, by rival number 1-3: rival 1 plays like the casual bot at 3 s a move, rival 2 the smart bot at 2.4 s, rival 3 the smart bot at 1.6 s (spec-prop §7.7; frame 9.2). No rival is called slow and no two read alike, so no respect-test exemption is needed. copy.md G.5 `rival_1_skill`, `rival_2_skill`, `rival_3_skill`.
  ///
  /// In en, this message translates to:
  /// **'{number, plural, =1{Gentle pace} =2{Steady pace} other{Lively pace}}'**
  String raceRivalSkill(int number);

  /// What a win against a rival pays, shown on its select card before the race (race_reward_n; spec-prop §1.1 rule 2, §7.7; frame 9.2). copy.md G.5 `rival_reward` ({count} is {coins} here).
  ///
  /// In en, this message translates to:
  /// **'{coins, plural, =1{Win 1 coin} other{Win {coins} coins}}'**
  String raceRivalReward(int coins);

  /// A locked rival's select card: the rival before it, whose first win unlocks it (spec-prop §7.7 'Three rivals unlock in turn'; frame 9.2). {rival} is that rival's raceRivalName. copy.md G.5 `rival_locked`.
  ///
  /// In en, this message translates to:
  /// **'Beat {rival} to unlock'**
  String raceRivalLocked(String rival);

  /// The chip on a rival card that is unlocked and not raced yet (rival 2 or 3; frame 9.2). copy.md G.5 `rival_new`.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get raceRivalNew;

  /// A computer rival's name for a screen reader on the pause and result cards, which says "Computer" (spec-prop §1.1 rule 5; the visible name sits beside the tag). Not in copy.md m7-4: built on `tag_computer`.
  ///
  /// In en, this message translates to:
  /// **'{name}, Computer'**
  String raceRivalSemantics(String name);

  /// A rival's select card, for a screen reader (frame 9.2). {rival} is raceRivalName, {skill} raceRivalSkill. Says "computer" (spec-prop §1.1 rule 5). The pick adds raceRivalSelectedSemantics. copy.md A11y `a11y_rival_card`.
  ///
  /// In en, this message translates to:
  /// **'{rival}, computer rival. {skill}.'**
  String raceRivalCardSemantics(String rival, String skill);

  /// A locked rival's select card, for a screen reader (frame 9.2b). {rival} is the rival before it (raceRivalName). copy.md A11y `a11y_rival_locked`.
  ///
  /// In en, this message translates to:
  /// **'Locked computer rival. Beat {rival} to unlock.'**
  String raceRivalLockedSemantics(String rival);

  /// The word a screen reader adds to the rival select card the player has picked (frame 9.2). copy.md A11y `a11y_rival_selected`.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get raceRivalSelectedSemantics;

  /// The Start button, on rival select (one Start for the selected rival) and on the race board in the booster bar's middle slots: both sides rest until it is tapped, with no countdown (vs-computer rule 4; frames 9.2, 9.3). copy.md G.5 `race_start`.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get raceStart;

  /// Rival select's bottom line above Start (frame 9.2). copy.md G.5 `race_start_hint`.
  ///
  /// In en, this message translates to:
  /// **'Same puzzle, two boards. Complete every family first.'**
  String get raceStartHint;

  /// The rival strip's state line before Start (frame 9.3). copy.md G.5 `strip_ready`.
  ///
  /// In en, this message translates to:
  /// **'Ready when you are'**
  String get raceStripReady;

  /// The rival strip's state line while the computer plays (frame 9.3b). copy.md G.5 `strip_thinking`.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get raceStripThinking;

  /// The rival strip's state line while the computer restarts its board (frame 9.3c). copy.md G.5 `strip_starting_over`.
  ///
  /// In en, this message translates to:
  /// **'Starting over'**
  String get raceStripStartingOver;

  /// The rival strip's state line once the computer has completed every family (frame 9.3d). copy.md G.5 `strip_finished`.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get raceStripFinished;

  /// The rival strip's state line once the player has won the race (frame 9.3e). copy.md G.5 `strip_after_you_won`.
  ///
  /// In en, this message translates to:
  /// **'You finished first'**
  String get raceStripPlayerFinished;

  /// The rival strip's family counter: the families the computer has completed of the board's (frame 9.3). copy.md G.5 `strip_families` ({count} is {done} here).
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String raceStripFamilies(int done, int total);

  /// The rival strip's screen-reader label, which says "computer" (spec-prop §1.1 rule 5). {name} is raceRivalName. copy.md A11y `a11y_rival_strip`.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{{name}, computer: {count} of {total} family} other{{name}, computer: {count} of {total} families}}'**
  String raceStripSemantics(String name, int count, int total);

  /// The rival strip's live screen-reader announcement when the computer completes a family, rate-limited (spec §16). copy.md A11y `a11y_rival_family`.
  ///
  /// In en, this message translates to:
  /// **'The computer completed a family: {done} of {total}'**
  String raceAnnounceFamily(int done, int total);

  /// The live screen-reader announcement when Start is tapped (spec §16). Says "computer" (spec-prop §1.1 rule 5). copy.md A11y `a11y_race_start`.
  ///
  /// In en, this message translates to:
  /// **'Race started against {rival}, a computer player.'**
  String raceAnnounceStart(String rival);

  /// The rival strip's live announcement when the computer restarts (spec §16). copy.md A11y `a11y_rival_starting_over`.
  ///
  /// In en, this message translates to:
  /// **'The computer is starting over.'**
  String get raceAnnounceStartingOver;

  /// The rival strip's live announcement when the computer finishes (spec §16). copy.md A11y `a11y_rival_finished`.
  ///
  /// In en, this message translates to:
  /// **'The computer completed every family.'**
  String get raceAnnounceFinished;

  /// The live announcement as the race win card opens (spec §16). copy.md A11y `a11y_race_won`.
  ///
  /// In en, this message translates to:
  /// **'You won the race.'**
  String get raceAnnounceWon;

  /// The live announcement as the race loss card opens (spec §16). copy.md A11y `a11y_race_lost`.
  ///
  /// In en, this message translates to:
  /// **'The computer finished first.'**
  String get raceAnnounceLost;

  /// The race win card's ribbon title (frame 9.4). copy.md G.5 `race_win_title`.
  ///
  /// In en, this message translates to:
  /// **'You won the race!'**
  String get raceWinTitle;

  /// The race win ribbon's short form (textFit.winRibbon) when raceWinTitle doesn't fit. copy.md Short forms `race_win_title_short`.
  ///
  /// In en, this message translates to:
  /// **'You won!'**
  String get raceWinTitleShort;

  /// The race win card's line under the title (frame 9.4). {rival} is raceRivalName. copy.md G.5 `race_win_body`.
  ///
  /// In en, this message translates to:
  /// **'Every family is complete. {rival} was still sorting.'**
  String raceWinBody(String rival);

  /// The race win card's coin chip: the rival's race_reward_n, counted up (frame 9.4). copy.md G.5 `race_win_coins`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 coin} other{+{count} coins}}'**
  String raceWinCoins(int count);

  /// The race loss card's ribbon title (frame 9.5). Warm, never a taunt (vs-computer rule 10). copy.md G.5 `race_lose_title`.
  ///
  /// In en, this message translates to:
  /// **'So close! Rematch?'**
  String get raceLossTitle;

  /// The race result ribbon's short form (textFit.winRibbon) when raceLossTitle doesn't fit. copy.md Short forms `race_lose_title_short`.
  ///
  /// In en, this message translates to:
  /// **'So close!'**
  String get raceLossTitleShort;

  /// The race loss card's line under the title (frame 9.5). {rival} is raceRivalName. No loss or streak wording. copy.md G.5 `race_lose_body`.
  ///
  /// In en, this message translates to:
  /// **'{rival} finished first this time. A rematch costs nothing.'**
  String raceLossBody(String rival);

  /// The card after 9.4 when the win unlocked the next rival, once per rival (frame 9.6; Q131). copy.md G.5 `rival_unlocked_title`.
  ///
  /// In en, this message translates to:
  /// **'New rival unlocked!'**
  String get raceRivalUnlockedTitle;

  /// The line under raceRivalUnlockedTitle naming the rival just unlocked (frame 9.6). {rival} is raceRivalName; the card shows the Computer tag beside it. copy.md G.5 `rival_unlocked_body`.
  ///
  /// In en, this message translates to:
  /// **'{rival} is ready to race.'**
  String raceRivalUnlockedBody(String rival);

  /// The New rival unlocked card's primary button: it races the new rival (frame 9.6). {rival} is raceRivalName. The card's secondary button is `notNow`. copy.md G.5 `rival_unlocked_race`.
  ///
  /// In en, this message translates to:
  /// **'Race {rival}'**
  String raceRivalUnlockedRace(String rival);

  /// The confirm card when Pause's Leave race is tapped (frame 9.7b; Q133). copy.md G.5 `race_quit_title`.
  ///
  /// In en, this message translates to:
  /// **'Leave this race?'**
  String get raceLeaveTitle;

  /// The confirm card's line (frame 9.7b): nothing is lost by leaving (spec-prop §7.7). copy.md G.5 `race_quit_body`.
  ///
  /// In en, this message translates to:
  /// **'The race stops here. No coins, and you keep everything.'**
  String get raceLeaveBody;

  /// The confirm card's button back to the race (frame 9.7b). copy.md G.5 `race_quit_no`.
  ///
  /// In en, this message translates to:
  /// **'Keep racing'**
  String get raceLeaveKeep;

  /// The race results' Rematch button: the same board again (frames 9.4, 9.5). copy.md G.5 `race_rematch`.
  ///
  /// In en, this message translates to:
  /// **'Rematch'**
  String get raceRematch;

  /// The race results' New race button: a new board against the same rival (frames 9.4, 9.5). copy.md G.5 `race_new`.
  ///
  /// In en, this message translates to:
  /// **'New race'**
  String get raceNewRace;

  /// The text link back to rival select: the race failure card (frame 9.3f). copy.md G.5 `race_failed_back`.
  ///
  /// In en, this message translates to:
  /// **'Back to races'**
  String get raceBackToRivals;

  /// The card when a race board couldn't be made (frame 9.3f). copy.md G.5 `race_failed_title`.
  ///
  /// In en, this message translates to:
  /// **'The shelves need a moment'**
  String get raceFailedTitle;

  /// The line under raceFailedTitle (frame 9.3f). copy.md G.5 `race_failed_body`.
  ///
  /// In en, this message translates to:
  /// **'This race didn’t set up. Try again, or pick another race.'**
  String get raceFailedBody;

  /// The Pause dialog's line during a race, under racePauseHeader (frame 9.7). {rival} is raceRivalName. copy.md G.5 `race_pause_rival`.
  ///
  /// In en, this message translates to:
  /// **'{rival} is paused too.'**
  String racePauseSubtitle(String rival);

  /// The Pause dialog's header in a race, beside the rival's portrait and Computer tag (frame 9.7). {rival} is raceRivalName. copy.md G.5 `race_pause_title`.
  ///
  /// In en, this message translates to:
  /// **'vs Computer · {rival}'**
  String racePauseHeader(String rival);

  /// Rival select's screen-reader word for a rival the player has beaten (the check on its portrait, frame 9.2b). copy.md A11y `a11y_rival_beaten`.
  ///
  /// In en, this message translates to:
  /// **'Beaten'**
  String get raceRivalBeaten;

  /// Rival select's Start button label for a screen reader, naming the selected computer rival (frame 9.2). {rival} is raceRivalName. copy.md A11y `a11y_race_start_button`.
  ///
  /// In en, this message translates to:
  /// **'Start race against {rival}'**
  String raceStartFor(String rival);

  /// Pause's Leave race button during a race, and the confirm card's own (frames 9.7, 9.7b). copy.md G.5 `race_pause_leave`, `race_quit_yes`.
  ///
  /// In en, this message translates to:
  /// **'Leave race'**
  String get raceQuit;

  /// The screen-reader label of every star row: a level's stars out of 3 (StarRating.maxStars, a rule constant; spec-prop §7.10). copy.md A11y `a11y_stars`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 of 3 stars} other{{count} of 3 stars}}'**
  String starsSemantics(int count);

  /// The win card's star row's screen-reader label on a new best (frame 11.4b). copy.md A11y `a11y_stars_new_best`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{New best, 1 of 3 stars} other{New best, {count} of 3 stars}}'**
  String starsNewBestSemantics(int count);

  /// The replay win card's target row below 3 stars: the moves that earn 3 stars (par + the 3-star slack; par is at least 2, so no singular). Information, never 'try again' (frame 11.4). copy.md G.11 `replay_target`.
  ///
  /// In en, this message translates to:
  /// **'3 stars at {moves} moves or fewer'**
  String winStarsTarget(int moves);

  /// The chip on the win card's moves chip on a new best (frame 11.4b). copy.md G.11 `new_best`.
  ///
  /// In en, this message translates to:
  /// **'New best!'**
  String get winStarsNewBest;

  /// The one-time tip on a first win below 3 stars; it waits for a card with room for it (frame 11.2c). copy.md G.11 `stars_tip`.
  ///
  /// In en, this message translates to:
  /// **'Fewer moves earn more stars. Replay any level from Chapters.'**
  String get starsFirstTip;

  /// The win card's note pill when a hint or +1 Slot capped the stars (Q145; frame 11.2d); it takes the tip's place. copy.md G.11 `stars_helper_note`.
  ///
  /// In en, this message translates to:
  /// **'Wins with a hint or an extra slot earn up to 2 stars.'**
  String get starsHelperNote;

  /// Stars earned out of the stars possible: a chapter's card and folded row in Chapters, Home's chapter card (frame 11.5). {count} is the stars earned, {total} the stars possible for the chapter's levels with a par (the app fills both). copy.md G.11 `chapter_stars_total`.
  ///
  /// In en, this message translates to:
  /// **'{count}/{total}'**
  String chaptersStarsTotal(int count, int total);

  /// The stars total on Home's Bonus Endless chip (frame 12.2): the whole campaign's stars. {count} is the stars earned, {total} the stars possible (600 in the bundle; the app fills both). copy.md G.11 `chapter_stars_total_all`.
  ///
  /// In en, this message translates to:
  /// **'{count}/{total}'**
  String chaptersStarsTotalAll(int count, int total);

  /// A chapter's line once all 20 levels have 3 stars (frame 11.5). copy.md G.11 `chapter_all_three_stars`.
  ///
  /// In en, this message translates to:
  /// **'Every level at 3 stars'**
  String get chaptersAllThreeStars;

  /// A chapter's stars as a screen-reader label. Not in copy.md m7-3: a screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'{earned, plural, =1{1 of {total} stars} other{{earned} of {total} stars}}'**
  String chaptersStarsSemantics(int earned, int total);

  /// Records' Stars cell (frame 11.5). copy.md G.11 `records_stars`.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get recordsStars;

  /// Records' Stars cell value (frame 10.6). {count} is the stars earned, {total} the stars possible over the levels with a par (600 in the bundle; the app fills both). copy.md G.10 `records_stars_value`.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total}'**
  String recordsStarsValue(int count, int total);

  /// The daily win card's Share button, above Back to Daily (frame 10.1; phase 4 decision on Q-P4-1). copy.md G.6 `share_button`.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get dailyShare;

  /// One family's glyph in the daily share text: its DollColor id's belly symbol as an emoji, so no two families look alike and nothing depends on colour (phase 4 architecture §3.10). {color} is `DollColor.id`; `other` is a defensive nesting doll. copy.md G.6 `glyph_<color>`.
  ///
  /// In en, this message translates to:
  /// **'{color, select, red{❤️} orange{🌼} yellow{☀️} green{🍃} teal{🌊} blue{💧} purple{⭐} pink{🎀} navy{🌙} brown{🌰} gold{👑} other{🪆}}'**
  String dailyShareGlyph(String color);

  /// The Share button's screen-reader label (frame 5.2). copy.md A11y `a11y_share_daily`.
  ///
  /// In en, this message translates to:
  /// **'Share today’s result'**
  String get dailyShareSemantics;

  /// The text the daily win card's Share hands the share sheet while the streak is lit (spec-prop §10.2 #11; frame 10.1): the date, one dailyShareGlyph per family in board order (at most 12), the moves and the streak day. Spoiler-free: never the board or a move. copy.md G.6 `share_line_1`…`share_line_3`.
  ///
  /// In en, this message translates to:
  /// **'Nesty Daily · {date}\n{glyphs}\n{moves, plural, =1{Solved in 1 move · Day {day} 🔥} other{Solved in {moves} moves · Day {day} 🔥}}'**
  String dailyShareText(String date, String glyphs, int moves, int day);

  /// The daily share text when the streak is 0 or paused (frame 10.1c): no day or flame. copy.md G.6 `share_line_1`, `share_line_2`, `share_line_3_no_streak`.
  ///
  /// In en, this message translates to:
  /// **'Nesty Daily · {date}\n{glyphs}\n{moves, plural, =1{Solved in 1 move} other{Solved in {moves} moves}}'**
  String dailyShareTextNoStreak(String date, String glyphs, int moves);

  /// The one-time reminder offer's question on the Daily solved screen (spec-prop §7.9; frame 10.2). copy.md G.7 `reminder_offer_title`.
  ///
  /// In en, this message translates to:
  /// **'Want a note when tomorrow’s puzzle is ready?'**
  String get reminderOfferTitle;

  /// The offer's line under the question (frame 10.2). copy.md G.7 `reminder_offer_body`.
  ///
  /// In en, this message translates to:
  /// **'One quiet note a day, at a time you pick. You can turn it off in Settings.'**
  String get reminderOfferBody;

  /// The offer's time chip: the reminder's local time, the hour of the first solve by default (Q81; frame 10.2). copy.md G.7 `reminder_time_chip`.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String reminderOfferTime(String time);

  /// The offer's Change time link: the phone's time picker (frame 10.2b). copy.md G.7 `reminder_change_time`.
  ///
  /// In en, this message translates to:
  /// **'Change time'**
  String get reminderOfferChangeTime;

  /// The reminder offer's time chip, for a screen reader (frame 10.2b). {time} is the locale's time. Visible: reminderOfferTime. copy.md A11y `a11y_reminder_time_chip`.
  ///
  /// In en, this message translates to:
  /// **'Reminder time, every day at {time}. Change time.'**
  String reminderTimeChipSemantics(String time);

  /// The title (helpText) of the system time picker the reminder's time chip and Settings' Time row open (frames 10.2c, 10.2e). copy.md G.7 `reminder_picker_title`.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderPickerTitle;

  /// The offer's Yes button: asks the phone for notifications, then turns the reminder on (spec-prop §1.1 rule 7). copy.md G.7 `reminder_yes`.
  ///
  /// In en, this message translates to:
  /// **'Yes, remind me'**
  String get reminderOfferYes;

  /// The offer's No thanks: the offer never shows again (spec-prop §7.9). copy.md G.7 `reminder_no`.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get reminderOfferNo;

  /// The toast once the phone allowed notifications and the reminder is on (frame 10.2c). copy.md G.7 `reminder_set`.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for {time}.'**
  String reminderOfferDone(String time);

  /// The offer's denied step's title when the phone refused notifications (frame 10.2d). copy.md G.7 `reminder_denied_title`.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for Nesty'**
  String get reminderOfferDeniedTitle;

  /// The denied step's line, with Open phone settings under it (frame 10.2d; Q140). The reminder stays on and blocked, so the note does arrive once the phone allows it (phase 4 decision on Q-P4-4). copy.md G.7 `reminder_denied_body`.
  ///
  /// In en, this message translates to:
  /// **'Turn them on in your phone’s settings, and your note will arrive at {time}.'**
  String reminderOfferDenied(String time);

  /// The daily reminder notification's title (spec-prop §7.9; frame 10.2g). copy.md G.7 `notification_title`.
  ///
  /// In en, this message translates to:
  /// **'Nesty'**
  String get reminderNotificationTitle;

  /// The notification's first body line; the three lines rotate by the next fire date at each re-plan (phase 4 decision on Q-P4-5). Never mentions a streak (spec-prop §7.9). copy.md G.7 `notification_1`.
  ///
  /// In en, this message translates to:
  /// **'Today’s puzzle is on the shelf.'**
  String get reminderNotificationBody;

  /// The notification's second body line (rotation as reminderNotificationBody). copy.md G.7 `notification_2`.
  ///
  /// In en, this message translates to:
  /// **'A fresh daily puzzle is ready when you are.'**
  String get reminderNotificationBody2;

  /// The notification's third body line (rotation as reminderNotificationBody). copy.md G.7 `notification_3`.
  ///
  /// In en, this message translates to:
  /// **'New dolls are waiting to be nested. Today’s puzzle is ready.'**
  String get reminderNotificationBody3;

  /// The Android notification channel's name in the phone's settings. copy.md G.7 `notification_channel_name`.
  ///
  /// In en, this message translates to:
  /// **'Daily puzzle'**
  String get reminderChannelName;

  /// The Android notification channel's description in the phone's settings. copy.md G.7 `notification_channel_description`.
  ///
  /// In en, this message translates to:
  /// **'One note a day when a new daily puzzle is ready.'**
  String get reminderChannelDescription;

  /// Settings' Daily reminder toggle (frame 10.2e). copy.md G.7 `settings_reminder`.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get settingReminder;

  /// Settings' reminder time row under the toggle, with the time and a chevron (frame 10.2e). copy.md G.7 `settings_reminder_time`.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get settingReminderTime;

  /// The Daily reminder row's value while the phone blocks notifications (frame 10.2f). copy.md G.7 `settings_reminder_blocked`.
  ///
  /// In en, this message translates to:
  /// **'Off in your phone’s settings'**
  String get settingReminderBlocked;

  /// The button to the phone's notification settings, on the offer's denied step and Settings' blocked row (frames 10.2d, 10.2f; Q140). copy.md G.7 `settings_open_phone_settings`.
  ///
  /// In en, this message translates to:
  /// **'Open phone settings'**
  String get settingOpenPhoneSettings;

  /// The Turn off link under Settings' Daily reminder row while the phone blocks notifications (frame 10.2f): it switches the reminder off in the app. copy.md G.7 `settings_reminder_turn_off`.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get settingReminderTurnOff;

  /// Lane M, phase 4 (menus spec). Not in copy.md m7-3: the kicker over the chapter name on Home's chapter card (frame 2.1). copy.md draws it as a fixed uppercase line; the number is the PLAY level's chapter.
  ///
  /// In en, this message translates to:
  /// **'CHAPTER {number}'**
  String homeChapterKicker(int number);

  /// Screen-reader label of Home's chapter card (frame 2.1): the chapter, its name, its stars and where a tap goes. copy.md A11y `a11y_home_chapter`.
  ///
  /// In en, this message translates to:
  /// **'Chapter {chapter}, {name}. {count} of {total} stars. Opens Chapters.'**
  String homeChapterCardSemantics(
    int chapter,
    String name,
    int count,
    int total,
  );

  /// Screen-reader label of Home's chapter card in Bonus Endless (frame 12.2): the whole campaign's stars. copy.md A11y `a11y_home_bonus`.
  ///
  /// In en, this message translates to:
  /// **'Bonus levels. {count} of {total} stars. Opens Chapters.'**
  String homeBonusCardSemantics(int count, int total);

  /// Screen-reader label of Home's vs Computer tile (frame 9.1; spec-prop §1.1 rule 5: a computer is always called one). copy.md A11y `a11y_home_versus`.
  ///
  /// In en, this message translates to:
  /// **'vs Computer. Race a computer on the same puzzle.'**
  String get homeVsComputerSemantics;

  /// Screen-reader label of Home's vs Computer tile while it is locked (frame 9.1b). {level} is `race_unlock_level` (the app fills it). copy.md A11y `a11y_home_versus_locked`.
  ///
  /// In en, this message translates to:
  /// **'vs Computer, locked. After Level {level}.'**
  String homeVsComputerLockedSemantics(int level);

  /// Lane M, phase 4 (menus spec). Not in copy.md m7-3: a Chapters row's and the open chapter header's kicker (frames 10.4, 11.5). A fixed uppercase line.
  ///
  /// In en, this message translates to:
  /// **'CHAPTER {number} · LEVELS {first}–{last}'**
  String chaptersKicker(int number, int first, int last);

  /// Screen-reader label of a Chapters row (frame 10.4). The row adds its expanded or collapsed state. {count} is the stars earned, {total} the stars possible. copy.md A11y `a11y_chapter_row`.
  ///
  /// In en, this message translates to:
  /// **'Chapter {chapter}, {name}. {count} of {total} stars.'**
  String chaptersRowSemantics(int chapter, String name, int count, int total);

  /// Screen-reader label of a locked Chapters row (frame 10.4). copy.md A11y `a11y_chapter_locked`.
  ///
  /// In en, this message translates to:
  /// **'Chapter {chapter}, {name}. Locked.'**
  String chaptersRowLockedSemantics(int chapter, String name);

  /// Appended to the screen-reader label of a Chapters cell that carries a milestone chest (frame 10.4). copy.md A11y `a11y_level_chest`.
  ///
  /// In en, this message translates to:
  /// **'A chest at this level'**
  String get chaptersLevelChestSemantics;

  /// Appended to the screen-reader label of a Chapters cell that is the chapter's last level (frame 10.4). copy.md A11y `a11y_level_finale`.
  ///
  /// In en, this message translates to:
  /// **'The last level of the chapter'**
  String get chaptersLevelFinaleSemantics;

  /// Screen-reader label of a collected family's niche in the Museum cabinet (frame 6.1). {name} is figurineName ("The Baker Family"). copy.md A11y `a11y_figurine_home`.
  ///
  /// In en, this message translates to:
  /// **'{name}, home in your Museum'**
  String museumNicheCollectedSemantics(String name);

  /// Screen-reader label of the next family's niche (frame 6.1). {count} is the levels still to win. copy.md A11y `a11y_figurine_next`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{name}, next to come home. {count} level to go.} other{{name}, next to come home. {count} levels to go.}}'**
  String museumNicheNextSemantics(String name, int count);

  /// Screen-reader label of a locked family's niche (frame 6.1). {name} is figurineName. copy.md A11y `a11y_figurine_locked`.
  ///
  /// In en, this message translates to:
  /// **'{name}, not home yet. Chapter {chapter}.'**
  String museumNicheLockedSemantics(String name, int chapter);

  /// Screen-reader label of the Museum's count chip (frame 6.1, "3 / 10"). copy.md A11y `a11y_museum_count`.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} families home'**
  String museumCountSemantics(int count, int total);

  /// The Museum's celebration card sub line once every family is home (frame 6.1c), under the badge name (`museum_full`, "Full House"). {count} is the number of families. copy.md G.10 `museum_all_home_sub`.
  ///
  /// In en, this message translates to:
  /// **'Full House · all {count} families'**
  String museumFullSub(int count);

  /// Screen-reader label of a Records races row (frame 10.6, spec-prop §1.1 rule 5: a computer is always called one). A rival with no wins reads 0. copy.md A11y `a11y_race_row`.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{rival}, computer. {count} win.} other{{rival}, computer. {count} wins.}}'**
  String recordsRaceSemantics(String rival, int count);

  /// Screen-reader label of a Records races row for a rival the player has not unlocked (frame 10.6). copy.md A11y `a11y_race_row_locked`.
  ///
  /// In en, this message translates to:
  /// **'{rival}, computer. Locked.'**
  String recordsRaceLockedSemantics(String rival);

  /// Screen-reader label of a Records stat cell: its label, then its value ("Levels won: 55", frame 10.6). The cell's visible words are its label and its value. copy.md A11y `a11y_record_cell`.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String recordsStatSemantics(String label, String value);

  /// Lane M, phase 4 (menus spec). Not in copy.md m7-3: the Records badge heading's count (frame 10.6, "5/12"); numbers only.
  ///
  /// In en, this message translates to:
  /// **'{earned}/{total}'**
  String recordsBadgesCount(int earned, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'ja',
    'pt',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
