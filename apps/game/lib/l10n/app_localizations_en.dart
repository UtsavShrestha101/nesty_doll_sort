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
  String progressPercent(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString';
  }

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

  @override
  String get splashDollSort => 'DOLL SORT';

  @override
  String get splashCaption => 'Dusting the shelves…';

  @override
  String get homePlay => 'PLAY';

  @override
  String get homeAllLevelsDone => 'All done!';

  @override
  String playSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Play level $levelString';
  }

  @override
  String playLevelSemantics(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Play level $levelString, $tier';
  }

  @override
  String coinPillShopSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString coins. Get more coins',
      one: '1 coin. Get more coins',
    );
    return '$_temp0';
  }

  @override
  String get tierHard => 'HARD';

  @override
  String get tierSuperHard => 'SUPER HARD';

  @override
  String tierName(String tier) {
    String _temp0 = intl.Intl.selectLogic(tier, {
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'superhard': 'Super Hard',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String levelWithTier(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString · $tier';
  }

  @override
  String familyCounter(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$doneString / $totalString';
  }

  @override
  String familyCounterSemantics(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$doneString of $totalString families done',
      one: '$doneString of 1 family done',
    );
    return '$_temp0';
  }

  @override
  String coinsSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString coins',
      one: '1 coin',
    );
    return '$_temp0';
  }

  @override
  String get levelDaily => 'Daily';

  @override
  String levelDailySemantics(String date) {
    return 'Daily puzzle, $date';
  }

  @override
  String bonusLevelTitle(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Bonus Level $numberString';
  }

  @override
  String get closeSemantics => 'Close';

  @override
  String get backSemantics => 'Back';

  @override
  String boosterCountSemantics(String booster, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$booster, $countString left',
      one: '$booster, 1 left',
    );
    return '$_temp0';
  }

  @override
  String boosterAdSemantics(String booster) {
    return '$booster, watch an ad for one more';
  }

  @override
  String boosterCoinSemantics(String booster, int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$booster, $priceString coins',
      one: '$booster, 1 coin',
    );
    return '$_temp0';
  }

  @override
  String get softStuckTitle => 'Hmm, this looks stuck';

  @override
  String get softStuckBody => 'Try Undo? You can keep playing too.';

  @override
  String get softStuckBodyRestart => 'Try Restart? You can keep playing too.';

  @override
  String get softStuckAction => 'Undo';

  @override
  String get oomTitle => 'No moves left!';

  @override
  String get oomSubtitle => 'Pick a way to keep sorting.';

  @override
  String get oomUndoSubtitle => 'Take back your last move';

  @override
  String oomUndoFree(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Free · $countString left',
      one: 'Free · 1 left',
    );
    return '$_temp0';
  }

  @override
  String get oomSlotTitle => '+1 Slot';

  @override
  String get oomSlotSubtitle => 'Add a stand for this level';

  @override
  String get oomSlotOffline => 'Coins only while offline';

  @override
  String get oomRestartSubtitle => 'Start this level fresh, for free';

  @override
  String coinPrice(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString coins',
      one: '1 coin',
    );
    return '$_temp0';
  }

  @override
  String get watchAd => 'Watch ad';

  @override
  String get watchAdSemantics => 'Watch an ad';

  @override
  String get offlineTitle => 'Offline';

  @override
  String get offlineAds => 'Ad buttons switch to coin prices';

  @override
  String get connectToWatchAd => 'Connect to watch an ad';

  @override
  String get winTitle => 'Level Complete!';

  @override
  String get winContinue => 'Continue';

  @override
  String get winTripleCoins => '×3 coins';

  @override
  String get winRewardAdded => 'Reward added';

  @override
  String winCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString';
  }

  @override
  String winChapter(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Chapter $numberString';
  }

  @override
  String winChapterProgress(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$doneString / $totalString';
  }

  @override
  String winNextUp(String name) {
    return 'Next up: $name';
  }

  @override
  String get winChapterDone => 'Chapter complete! Your prize is next.';

  @override
  String figurineName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'The Classic Family',
      'sailor': 'The Sailor Family',
      'baker': 'The Baker Family',
      'astronaut': 'The Astronaut Family',
      'gardener': 'The Gardener Family',
      'snow': 'The Snow Family',
      'circus': 'The Circus Family',
      'musician': 'The Musician Family',
      'royal': 'The Royal Family',
      'explorer': 'The Explorer Family',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String chapterRibbon(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'CHAPTER $numberString · $name';
  }

  @override
  String chapterName(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'ch01': 'Sunny Toy Shop',
      'ch02': 'Rainy Café Corner',
      'ch03': 'Seaside Market',
      'ch04': 'Snowy Cabin',
      'ch05': 'Night Carnival',
      'ch06': 'Spring Garden Shed',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get pauseTitle => 'Paused';

  @override
  String get resume => 'Resume';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get settingSound => 'Sound';

  @override
  String get settingMusic => 'Music';

  @override
  String get settingHaptics => 'Haptics';

  @override
  String get allLevelsTitle => 'You\'ve finished all levels!';

  @override
  String get allLevelsBody =>
      'New chapters are coming — play bonus levels meanwhile.';

  @override
  String allLevelsPlayBonus(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Play Bonus Level $numberString';
  }

  @override
  String get allLevelsBackHome => 'Back to Home';

  @override
  String get nextLevelFailedHome => 'Back to Home';

  @override
  String get devLevelPickerTitle => 'Jump to a level';

  @override
  String get navShop => 'Shop';

  @override
  String get navMuseum => 'Museum';

  @override
  String get homeDailyTile => 'Daily Puzzle';

  @override
  String get homeMuseumTile => 'Museum';

  @override
  String get homeRemoveAdsTile => 'Remove Ads';

  @override
  String homeMuseumProgress(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$doneString/$totalString';
  }

  @override
  String get homeDailyLocked => 'After Level 2';

  @override
  String streakBadgeSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString-day streak',
      one: '1-day streak',
    );
    return '$_temp0';
  }

  @override
  String get settingColorSymbols => 'Color symbols';

  @override
  String get symbolsSubtle => 'Subtle';

  @override
  String get symbolsLarge => 'Large';

  @override
  String get settingLanguage => 'Language';

  @override
  String get settingRestorePurchases => 'Restore Purchases';

  @override
  String get settingPrivacyChoices => 'Privacy choices';

  @override
  String get settingPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingSupport => 'Support';

  @override
  String get settingSupportValue => 'Email us';

  @override
  String settingsFooter(String version, String build, String playerId) {
    return 'Nesty: Doll Sort · v$version (build $build) · Player ID $playerId';
  }

  @override
  String get languageSheetTitle => 'Language';

  @override
  String get languageSheetDone => 'Done';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'es': 'Spanish',
      'pt_BR': 'Portuguese',
      'id': 'Indonesian',
      'hi': 'Hindi',
      'de': 'German',
      'fr': 'French',
      'tr': 'Turkish',
      'ja': 'Japanese',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get languageComingSoon => 'Coming soon';

  @override
  String languageRowSemantics(String autonym, String detail) {
    return '$autonym, $detail';
  }

  @override
  String dailyStreakDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakKeep => 'Play today to keep your streak';

  @override
  String get dailyStreakStart => 'Play today to start a streak';

  @override
  String get dailyStreakDone => 'Done for today. See you tomorrow!';

  @override
  String get dailyStreakWeek => 'A full week!';

  @override
  String dailyFreezes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString freezes',
      one: '1 freeze',
      zero: '0 left',
    );
    return '$_temp0';
  }

  @override
  String get dailyDay => 'Day';

  @override
  String get dailyToday => 'Today';

  @override
  String get dailyTomorrow => 'Tmrw';

  @override
  String dailyDaySemantics(String state, int day) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'done': 'Day $day, done',
      'today': 'Today, day $day',
      'tomorrow': 'Tomorrow, day $day',
      'chest': 'Day $day, chest',
      'other': 'Day $day',
    });
    return '$_temp0';
  }

  @override
  String dailyPlaySemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Play, $countString coins',
      one: 'Play, 1 coin',
    );
    return '$_temp0';
  }

  @override
  String dailyChestRow(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return 'Day 7 chest · $coinsString coins';
  }

  @override
  String dailyChestToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString days to go',
      one: '1 day to go',
    );
    return '$_temp0';
  }

  @override
  String dailyChestToGoToday(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString days to go, counting today',
      one: '1 day to go, counting today',
    );
    return '$_temp0';
  }

  @override
  String get dailyChestOpenedToday => 'Opened today';

  @override
  String dailyPuzzleTitle(String weekday) {
    return '$weekday’s puzzle';
  }

  @override
  String dailyPuzzleInfo(int colors, String tier) {
    final intl.NumberFormat colorsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String colorsString = colorsNumberFormat.format(colors);

    String _temp0 = intl.Intl.pluralLogic(
      colors,
      locale: localeName,
      other: '$colorsString colors',
      one: '1 color',
    );
    return '$_temp0 · $tier';
  }

  @override
  String get dailyPlay => 'Play';

  @override
  String dailySolvedChip(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return 'Solved · +$coinsString';
  }

  @override
  String dailyNextPuzzle(String time) {
    return 'Next puzzle in $time';
  }

  @override
  String dailyCountdown(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '${hoursString}h ${minutesString}m';
  }

  @override
  String playLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Play Level $levelString';
  }

  @override
  String get dailySavedTitle => 'Streak saved!';

  @override
  String dailySavedBody(String weekday) {
    return 'A freeze covered $weekday. You\'ll earn a new one next week.';
  }

  @override
  String get dailyChestTitle => '7-day streak!';

  @override
  String get dailyChestBody => 'A full week of puzzles. Your chest is open.';

  @override
  String get dailyChestDouble => 'Double it';

  @override
  String get dailyChestCollect => 'Collect';

  @override
  String get dailyWinTitle => 'Daily solved!';

  @override
  String dailyWinStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString-day streak';
  }

  @override
  String dailyWinChestHint(String count) {
    String _temp0 = intl.Intl.selectLogic(count, {
      '0': 'Your Day 7 chest is ready!',
      '1': 'One more day to the Day 7 chest',
      '2': 'Two more days to the Day 7 chest',
      '3': 'Three more days to the Day 7 chest',
      '4': 'Four more days to the Day 7 chest',
      '5': 'Five more days to the Day 7 chest',
      '6': 'Six more days to the Day 7 chest',
      'other': '$count more days to the Day 7 chest',
    });
    return '$_temp0';
  }

  @override
  String get dailyBackToDaily => 'Back to Daily';

  @override
  String get museumTitle => 'Museum';

  @override
  String get museumCollection => 'Collection';

  @override
  String museumCount(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$doneString / $totalString';
  }

  @override
  String museumNextLine(int number, int done, int total, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Chapter $numberString: $doneString of $totalString levels to $name';
  }

  @override
  String get museumAllHome => 'Every family is home.';

  @override
  String museumFamilyLabel(String name) {
    return '$name Family';
  }

  @override
  String museumSoonLabel(String name) {
    return '$name · soon';
  }

  @override
  String figurineShortName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'Classic',
      'sailor': 'Sailor',
      'baker': 'Baker',
      'astronaut': 'Astronaut',
      'gardener': 'Gardener',
      'snow': 'Snow',
      'circus': 'Circus',
      'musician': 'Musician',
      'royal': 'Royal',
      'explorer': 'Explorer',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String figurineFlavor(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'sailor': '“They keep a seashell in the smallest doll, just in case.”',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String museumChapterChip(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Chapter $numberString · $name';
  }

  @override
  String museumCollectedOn(String date) {
    return 'Collected · $date';
  }

  @override
  String get museumCollected => 'Collected';

  @override
  String museumLockedText(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Finish Chapter $numberString to bring this family home.';
  }

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopTabCoins => 'Coins';

  @override
  String get shopTabSkins => 'Skins';

  @override
  String get shopTabThemes => 'Themes';

  @override
  String get shopTabNoAds => 'No Ads';

  @override
  String get shopEquipped => 'Equipped';

  @override
  String get shopEquip => 'Equip';

  @override
  String skinName(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Classic',
      'space': 'Space',
      'ocean': 'Ocean',
      'sweets': 'Sweets',
      'forest': 'Forest Friends',
      'winter': 'Winter',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String skinDescription(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'ocean': 'Sailor collars, tiny anchors and wave trims.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get skinDetailTitle => 'Skin';

  @override
  String get skinDetailColors => 'All 11 colors · symbols kept';

  @override
  String get skinDetailSizes =>
      'Every size nests the same way. Only the paint changes.';

  @override
  String get shopBuy => 'Buy';

  @override
  String shopBuySemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Buy, $countString coins',
      one: 'Buy, 1 coin',
    );
    return '$_temp0';
  }

  @override
  String balanceLine(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $countString coins',
      one: 'You have 1 coin',
    );
    return '$_temp0';
  }

  @override
  String shopDownloading(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'Downloading $percentString%';
  }

  @override
  String get themesMatchTitle => 'Match each chapter';

  @override
  String get themesMatchSubtitle => 'Uses the theme of the chapter you\'re in';

  @override
  String get themeInUse => 'In use';

  @override
  String get themeUse => 'Use';

  @override
  String themeChapterLock(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Ch $numberString';
  }

  @override
  String get shopClosedTitle => 'The store is closed for now';

  @override
  String get shopClosedBody =>
      'Coin packs and Remove Ads come in a later update.';

  @override
  String buyUndoText(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your $countString free undos are used. Take back one more move.',
      one: 'Your 1 free undo is used. Take back one more move.',
    );
    return '$_temp0';
  }

  @override
  String get buyHintText => 'Shows your next best move.';

  @override
  String get buySlotText => 'Adds one empty stand for this level.';

  @override
  String get tutorialStep1Chip => 'STEP 1 OF 2';

  @override
  String get tutorialStep1Title => 'Tap the small doll';

  @override
  String get tutorialStep1Text =>
      'Dolls nest into the same color, one size bigger.';

  @override
  String get tutorialStep2Chip => 'STEP 2 OF 2';

  @override
  String get tutorialStep2Title => 'Now tap the big one';

  @override
  String get tutorialStep2Text => 'The small doll drops inside with a clack.';

  @override
  String get tutorialStep3Title => 'Finish the family';

  @override
  String get tutorialStep3Text => 'Tap the smallest doll, then the family.';

  @override
  String get tutorialSwallowChip => 'NEW MOVE';

  @override
  String get tutorialSwallowTitle => 'Big can swallow small';

  @override
  String get tutorialSwallowText =>
      'Drop a big doll onto the next size down and it closes right over it.';

  @override
  String get introNew => 'NEW';

  @override
  String get introTowersTitle => 'Towers!';

  @override
  String get introTowersText =>
      'Only the top nest can move. Clear it to reveal the doll hiding underneath.';

  @override
  String get introGlassTitle => 'Glass Cases';

  @override
  String get introGlassText =>
      'A locked doll is freed when the family on its padlock is complete.';

  @override
  String get introIceTitle => 'Ice';

  @override
  String get introIceText =>
      'Every family you finish cracks the ice. At zero, the doll is free.';

  @override
  String introTowersBuriedTag(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString';
  }

  @override
  String introIceCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString';
  }

  @override
  String get introGotIt => 'Got it';

  @override
  String chapterCompleteTitle(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'CHAPTER $numberString COMPLETE';
  }

  @override
  String get chapterCompleteAdded => 'Added to your Museum!';

  @override
  String chapterCompleteCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString coins';
  }

  @override
  String chapterCompleteNext(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Next: Chapter $numberString · $name';
  }

  @override
  String get gameplayGenerating => 'Setting up the shelves…';
}
