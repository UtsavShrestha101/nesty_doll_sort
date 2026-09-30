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
  String get splashStorageTitle => 'Your phone is nearly full';

  @override
  String splashStorageBody(int megabytes) {
    final intl.NumberFormat megabytesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String megabytesString = megabytesNumberFormat.format(megabytes);

    return 'Nesty needs about $megabytesString MB to set up the shelves. Free some space, then try again.';
  }

  @override
  String get splashContentTitle => 'The shelves didn’t unpack';

  @override
  String get splashContentBody =>
      'Something went wrong while loading. Try again, or restart Nesty.';

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
  String bonusLevelTitle(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Bonus Level $levelString';
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
      'ch07': 'Puppet Theater',
      'ch08': 'Autumn Bandstand',
      'ch09': 'Castle Library',
      'ch10': 'Sunrise Lookout',
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
  String get gameplayFailedTitle => 'The shelves need a moment';

  @override
  String get gameplayFailedBody =>
      'This level didn’t set up. Try again, or head back home.';

  @override
  String get devLevelPickerTitle => 'Jump to a level';

  @override
  String devLevelPickerChapterHeader(int number, int start, int end) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);
    final intl.NumberFormat startNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String startString = startNumberFormat.format(start);
    final intl.NumberFormat endNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String endString = endNumberFormat.format(end);

    return 'Chapter $numberString · Levels $startString–$endString';
  }

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
  String get homeBonusBadge => 'BONUS';

  @override
  String get homeBonusKicker => 'BONUS ENDLESS';

  @override
  String get homeBonusName => 'Bonus levels';

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
  String get dailyStreakKeep => 'Play today to add to your streak';

  @override
  String get dailyStreakStart =>
      'Solve today’s puzzle to light your first flame.';

  @override
  String get dailyStreakDone => 'Your flame is lit. See you tomorrow.';

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
      zero: 'No freeze',
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
  String get dailySavedTitle => 'A freeze kept your flame lit.';

  @override
  String dailySavedBody(String weekday) {
    return 'A freeze covered $weekday. You\'ll earn a new one next week.';
  }

  @override
  String get dailyChestTitle => '7-day streak!';

  @override
  String get dailyChestBody => 'Seven days in a row. Here’s what’s inside.';

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
  String museumNextLine(int chapter, int count) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chapter $chapterString · $countString levels to go',
      one: 'Chapter $chapterString · 1 level to go',
    );
    return '$_temp0';
  }

  @override
  String get museumAllHome => 'Every family is home.';

  @override
  String get museumNextFamily => 'Next family';

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
      'classic': '“The smallest one wins every game of hide-and-seek.”',
      'sailor': '“They keep a seashell in the smallest doll, just in case.”',
      'baker': '“They bake every loaf in four sizes, so nobody has to share.”',
      'astronaut':
          '“They count down from the biggest to the smallest before every trip to the moon.”',
      'gardener': '“Each hat hides a seed they’re saving for spring.”',
      'snow': '“When nobody is looking, they stack up into a snowman.”',
      'circus':
          '“Their best act is climbing inside each other, to great applause.”',
      'musician':
          '“They play one song in four sizes. The smallest takes the high notes.”',
      'royal':
          '“Every crown fits inside the next one, which saves a lot of room.”',
      'explorer':
          '“They’ve mapped every shelf in the shop, and they’re not done yet.”',
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
  String museumIntro(int levels) {
    final intl.NumberFormat levelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelsString = levelsNumberFormat.format(levels);

    return 'Every chapter has a doll family. Win all $levelsString of its levels to bring that family home.';
  }

  @override
  String museumLevelsToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString levels to go',
      one: '1 level to go',
    );
    return '$_temp0';
  }

  @override
  String museumLockedShelfLabel(int chapter, int first, int last) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);
    final intl.NumberFormat firstNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String firstString = firstNumberFormat.format(first);
    final intl.NumberFormat lastNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String lastString = lastNumberFormat.format(last);

    return 'Chapter $chapterString · Levels $firstString–$lastString';
  }

  @override
  String museumLockedShelfShort(int chapter, int first, int last) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);
    final intl.NumberFormat firstNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String firstString = firstNumberFormat.format(first);
    final intl.NumberFormat lastNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String lastString = lastNumberFormat.format(last);

    return 'Ch $chapterString · $firstString–$lastString';
  }

  @override
  String museumLockedLine1(int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'Chapter $chapterString';
  }

  @override
  String museumLockedLine2(int first, int last) {
    final intl.NumberFormat firstNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String firstString = firstNumberFormat.format(first);
    final intl.NumberFormat lastNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String lastString = lastNumberFormat.format(last);

    return 'Levels $firstString–$lastString';
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
  String get shopOwned => 'Owned';

  @override
  String skinName(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Classic',
      'space': 'Space',
      'ocean': 'Ocean',
      'sweets': 'Sweets',
      'forest': 'Forest Friends',
      'winter': 'Winter',
      'forest_bear': 'Forest Bear',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String skinDescription(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Painted flowers, gold dots and a little bow.',
      'ocean': 'Sailor collars, tiny anchors and wave trims.',
      'space': 'Round helmets, tiny antennas and ringed planets.',
      'sweets': 'Frosting drips, sprinkles and candy stripes.',
      'forest': 'Pointy ears, pearl-trimmed hoods and falling leaves.',
      'winter': 'Pompom hats, snowflakes and pearly trims.',
      'forest_bear': 'Round bear ears, cozy hoods and acorns in the leaves.',
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
  String get notEnoughCoinsTitle => 'A few more coins';

  @override
  String notEnoughCoinsNeeded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You need $countString more coins',
      one: 'You need 1 more coin',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsSource =>
      'Coins come from winning levels, the daily puzzle and chests.';

  @override
  String get notEnoughCoinsGoToShop => 'Go to Shop';

  @override
  String get notNow => 'Not now';

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
  String get tutorialStep1Title => 'Tap the small doll';

  @override
  String tutorialStepChip(int step, int total) {
    return 'STEP $step OF $total';
  }

  @override
  String get tutorialStep1Text =>
      'Dolls nest into the same color, one size bigger.';

  @override
  String get tutorialStep2Title => 'Now tap the big one';

  @override
  String get tutorialStep2Text => 'The small doll drops inside with a clack.';

  @override
  String get tutorialStep3Title => 'Finish the family';

  @override
  String get tutorialStep3Text =>
      'Put the last doll in. A family is done when every size is nested.';

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

  @override
  String dailyStreakPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Your $countString-day streak is resting. Solve today’s puzzle to light it again.';
  }

  @override
  String get dailyStreakPausedChip => 'Paused';

  @override
  String get dailyStreakRelitTitle => 'Streak relit!';

  @override
  String dailyStreakRelitBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Your $countString-day streak is glowing again.';
  }

  @override
  String streakBadgeSemanticsPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString-day streak, paused',
      one: '1-day streak, paused',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => 'Chapters';

  @override
  String chaptersOverallProgress(int level, int total) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Level $levelString of $totalString';
  }

  @override
  String chaptersWonCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString won';
  }

  @override
  String chaptersBestMoves(int best) {
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Best $bestString';
  }

  @override
  String get chaptersLevelPlay => 'Play';

  @override
  String chaptersLevelSemanticsWon(int level, int moves) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'Level $levelString, won, best $movesString moves',
      one: 'Level $levelString, won, best 1 move',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsWonNoBest(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString, won';
  }

  @override
  String chaptersLevelSemanticsCurrent(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString, play next';
  }

  @override
  String chaptersLevelSemanticsLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString, locked';
  }

  @override
  String get recordsTitle => 'Records';

  @override
  String get homeRecordsButton => 'Records';

  @override
  String get recordsLevelsWon => 'Levels won';

  @override
  String get recordsFamilies => 'Families completed';

  @override
  String get recordsRacesHeader => 'Races won';

  @override
  String get recordsDolls => 'Dolls nested';

  @override
  String get recordsDailies => 'Daily puzzles solved';

  @override
  String get recordsLongestStreak => 'Longest streak';

  @override
  String get recordsBestMovesLink => 'Best moves by level';

  @override
  String get recordsBadgesHeader => 'Badges';

  @override
  String badgeName(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Snug as a Doll',
      'glass_breaker': 'Glass Act',
      'ice_melter': 'Ice Breaker',
      'tall_order': 'Tall Order',
      'grand_nest': 'Grand Nest',
      'level_100': 'Halfway Home',
      'level_200': 'Top Shelf',
      'dailies_7': 'Puzzle Pal',
      'dailies_30': 'Old Friend',
      'first_race': 'First Past the Shelf',
      'all_rivals': 'Rival Round-Up',
      'museum_full': 'Full House',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeLine(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'You nested your first family.',
      'glass_breaker': 'You opened your first glass case.',
      'ice_melter': 'You freed a doll from the ice.',
      'tall_order': 'You won a level with size-5 dolls.',
      'grand_nest': 'You won a level with size-6 dolls.',
      'level_100': 'You won level 100.',
      'level_200': 'You won level 200, the very last one.',
      'dailies_7': 'You solved 7 daily puzzles.',
      'dailies_30': 'You solved 30 daily puzzles.',
      'first_race': 'You beat the computer in a race.',
      'all_rivals': 'You beat every computer rival.',
      'museum_full': 'Every family is home in your Museum.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeHint(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Complete a family',
      'glass_breaker': 'Open a glass case',
      'ice_melter': 'Melt the ice on a stand',
      'tall_order': 'Win a level with size-5 dolls',
      'grand_nest': 'Win a level with size-6 dolls',
      'level_100': 'Win Level 100',
      'level_200': 'Win Level 200',
      'dailies_7': 'Solve 7 daily puzzles',
      'dailies_30': 'Solve 30 daily puzzles',
      'first_race': 'Win a race against the computer',
      'all_rivals': 'Beat every computer rival',
      'museum_full': 'Bring every Museum family home',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeSemanticsEarned(String name) {
    return '$name, earned';
  }

  @override
  String badgeSemanticsLocked(String name, String hint) {
    return '$name, not earned yet. $hint';
  }

  @override
  String badgeEarnedToastTitle(String badge) {
    return 'Badge earned · $badge';
  }

  @override
  String get badgeLockedLine => 'Not earned yet';

  @override
  String winMovesBest(int moves, int best) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Moves $movesString · Best $bestString';
  }

  @override
  String winMovesOnly(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return 'Moves $movesString';
  }

  @override
  String winChestCountdown(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString levels to the chest',
      one: '1 level to the chest',
    );
    return '$_temp0';
  }

  @override
  String get winReplayReason => 'A replay for fun: coins come from new levels.';

  @override
  String get winBackToChapters => 'Back to Chapters';

  @override
  String get chestMilestoneTitle => 'Milestone chest';

  @override
  String chestMilestoneBody(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'A chest for reaching level $levelString. Here’s what’s inside.';
  }

  @override
  String chestMilestoneBodyBonus(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'A chest for bonus level $levelString. Here’s what’s inside.';
  }

  @override
  String chestContentsCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString coins',
      one: '+1 coin',
    );
    return '$_temp0';
  }

  @override
  String chestContentsHint(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString hints',
      one: '+1 hint',
    );
    return '$_temp0';
  }

  @override
  String chestContentsSemantics(int coins, int hints) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);
    final intl.NumberFormat hintsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hintsString = hintsNumberFormat.format(hints);

    String _temp0 = intl.Intl.pluralLogic(
      coins,
      locale: localeName,
      other: '$coinsString coins',
      one: '1 coin',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hints,
      locale: localeName,
      other: '$hintsString hints',
      one: '1 hint',
    );
    return '$_temp0 and $_temp1';
  }

  @override
  String get chestOpen => 'Open';

  @override
  String get settingRelaxedMode => 'Relaxed mode';

  @override
  String get settingRelaxedModeSubtitle => 'Unlimited free undo';

  @override
  String get relaxedModeOn => 'Relaxed mode is on. Undo as often as you like.';

  @override
  String get settingReduceMotion => 'Reduce motion';

  @override
  String get reduceMotionSystem => 'System';

  @override
  String get reduceMotionOn => 'On';

  @override
  String get reduceMotionOff => 'Off';

  @override
  String get oomUndoFreeUnlimited => 'Free, as often as you like';

  @override
  String oomUndoSpent(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your $countString free undos are used',
      one: 'Your 1 free undo is used',
    );
    return '$_temp0';
  }

  @override
  String extraSlotLimitToast(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString extra slots is the most for one level.',
      two: 'Two extra slots is the most for one level.',
      one: 'One extra slot is the most for one level.',
    );
    return '$_temp0';
  }

  @override
  String boosterUndoUnlimitedSemantics(String booster) {
    return '$booster, unlimited';
  }

  @override
  String get oomUndoFreeChip => 'Free';

  @override
  String boosterLimitSemantics(String booster, int used, int total) {
    return '$booster, $used of $total used';
  }

  @override
  String hintGainedTag(int count) {
    return '+$count';
  }

  @override
  String get restartSuggestedHint => 'Suggested';

  @override
  String get homeVsComputerTile => 'vs Computer';

  @override
  String homeVsComputerLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'After Level $levelString';
  }

  @override
  String boardTowerHidden(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString';
  }

  @override
  String boardIceCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString';
  }

  @override
  String get raceSelectTitle => 'vs Computer';

  @override
  String get raceSelectSubtitle => 'Race a computer on the same puzzle';

  @override
  String get raceComputerTag => 'Computer';

  @override
  String raceRivalName(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Comet',
      two: 'Button',
      one: 'Pebble',
    );
    return '$_temp0';
  }

  @override
  String raceRivalBlurb(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Quick, tidy and hard to catch.',
      two: 'Checks each move twice before it makes it.',
      one: 'Takes its time and enjoys every doll along the way.',
    );
    return '$_temp0';
  }

  @override
  String raceRivalSkill(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Careful · Quick',
      two: 'Careful · Slow',
      one: 'Relaxed · Slow',
    );
    return '$_temp0';
  }

  @override
  String raceRivalReward(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    String _temp0 = intl.Intl.pluralLogic(
      coins,
      locale: localeName,
      other: 'Win $coinsString coins',
      one: 'Win 1 coin',
    );
    return '$_temp0';
  }

  @override
  String raceRivalLocked(String rival) {
    return 'Beat $rival to unlock';
  }

  @override
  String get raceRivalNew => 'New';

  @override
  String raceRivalSemantics(String name) {
    return '$name, Computer';
  }

  @override
  String get raceStart => 'Start';

  @override
  String get raceStartHint =>
      'Same puzzle, two boards. Complete every family first.';

  @override
  String get raceStripReady => 'Ready when you are';

  @override
  String get raceStripThinking => 'Thinking…';

  @override
  String get raceStripStartingOver => 'Starting over';

  @override
  String get raceStripFinished => 'Finished';

  @override
  String get raceStripPlayerFinished => 'You finished first';

  @override
  String raceStripFamilies(int done, int total) {
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
  String raceStripSemantics(String name, int done, int total) {
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
      other: '$name, Computer: $doneString of $totalString families',
      one: '$name, Computer: $doneString of 1 family',
    );
    return '$_temp0';
  }

  @override
  String raceAnnounceFamily(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'The computer completed a family: $doneString of $totalString';
  }

  @override
  String raceAnnounceStart(String rival) {
    return 'Race started against $rival, a computer player.';
  }

  @override
  String get raceAnnounceStartingOver => 'The computer is starting over.';

  @override
  String get raceAnnounceFinished => 'The computer completed every family.';

  @override
  String get raceAnnounceWon => 'You won the race.';

  @override
  String get raceAnnounceLost => 'The computer finished first.';

  @override
  String get raceWinTitle => 'You won the race!';

  @override
  String raceWinBody(String rival) {
    return 'You completed every family before $rival.';
  }

  @override
  String raceWinCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString coins',
      one: '+1 coin',
    );
    return '$_temp0';
  }

  @override
  String get raceLossTitle => 'So close! Rematch?';

  @override
  String raceLossBody(String rival) {
    return '$rival finished first this time. A rematch costs nothing.';
  }

  @override
  String get raceRivalUnlockedTitle => 'New rival unlocked!';

  @override
  String raceRivalUnlockedBody(String rival) {
    return '$rival is ready to race.';
  }

  @override
  String get raceLeaveTitle => 'Leave this race?';

  @override
  String get raceLeaveBody => 'The race ends here. No coins, and nothing lost.';

  @override
  String get raceLeaveKeep => 'Keep racing';

  @override
  String get raceRematch => 'Rematch';

  @override
  String get raceNewRace => 'New race';

  @override
  String get raceBackToRivals => 'Back to races';

  @override
  String get raceFailedTitle => 'The shelves need a moment';

  @override
  String get raceFailedBody =>
      'This race didn’t set up. Try again, or pick another race.';

  @override
  String racePauseSubtitle(String rival) {
    return '$rival is paused too.';
  }

  @override
  String racePauseHeader(String rival) {
    return 'vs Computer · $rival';
  }

  @override
  String get raceRivalBeaten => 'Beaten';

  @override
  String raceStartFor(String rival) {
    return 'Start race against $rival';
  }

  @override
  String get raceQuit => 'Leave race';

  @override
  String starsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of 3 stars',
      one: '1 of 3 stars',
    );
    return '$_temp0';
  }

  @override
  String starsNewBestSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'New best, $count of 3 stars',
      one: 'New best, 1 of 3 stars',
    );
    return '$_temp0';
  }

  @override
  String winStarsTarget(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return '3 stars at $movesString moves or fewer';
  }

  @override
  String get winStarsNewBest => 'New best!';

  @override
  String get starsFirstTip =>
      'Fewer moves earn more stars. Replay any level from Chapters.';

  @override
  String get starsHelperNote =>
      'Wins with a hint or an extra slot earn up to 2 stars.';

  @override
  String chaptersStarsTotal(int earned, int total) {
    final intl.NumberFormat earnedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String earnedString = earnedNumberFormat.format(earned);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$earnedString/$totalString';
  }

  @override
  String get chaptersAllThreeStars => 'Every level at 3 stars';

  @override
  String chaptersStarsSemantics(int earned, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      earned,
      locale: localeName,
      other: '$earned of $total stars',
      one: '1 of $total stars',
    );
    return '$_temp0';
  }

  @override
  String get recordsStars => 'Stars';

  @override
  String recordsStarsValue(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString of $totalString';
  }

  @override
  String get dailyShare => 'Share';

  @override
  String dailyShareGlyph(String color) {
    String _temp0 = intl.Intl.selectLogic(color, {
      'red': '❤️',
      'orange': '🌼',
      'yellow': '☀️',
      'green': '🍃',
      'teal': '🌊',
      'blue': '💧',
      'purple': '⭐',
      'pink': '🎀',
      'navy': '🌙',
      'brown': '🌰',
      'gold': '👑',
      'other': '🪆',
    });
    return '$_temp0';
  }

  @override
  String get dailyShareSemantics => 'Share today\'s result';

  @override
  String dailyShareText(String date, String glyphs, int moves, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'Solved in $moves moves · Day $day 🔥',
      one: 'Solved in 1 move · Day $day 🔥',
    );
    return 'Nesty Daily · $date\n$glyphs\n$_temp0';
  }

  @override
  String dailyShareTextNoStreak(String date, String glyphs, int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'Solved in $moves moves',
      one: 'Solved in 1 move',
    );
    return 'Nesty Daily · $date\n$glyphs\n$_temp0';
  }

  @override
  String get reminderOfferTitle =>
      'Want a note when tomorrow’s puzzle is ready?';

  @override
  String get reminderOfferBody =>
      'One quiet note a day, at a time you pick. You can turn it off in Settings.';

  @override
  String reminderOfferTime(String time) {
    return 'Every day at $time';
  }

  @override
  String get reminderOfferChangeTime => 'Change time';

  @override
  String get reminderOfferYes => 'Yes, remind me';

  @override
  String get reminderOfferNo => 'No thanks';

  @override
  String reminderOfferDone(String time) {
    return 'Reminder set for $time.';
  }

  @override
  String get reminderOfferDeniedTitle => 'Notifications are off for Nesty';

  @override
  String reminderOfferDenied(String time) {
    return 'Turn them on in your phone’s settings, and your note will arrive at $time.';
  }

  @override
  String get reminderNotificationTitle => 'Nesty';

  @override
  String get reminderNotificationBody => 'Today’s puzzle is on the shelf.';

  @override
  String get reminderNotificationBody2 =>
      'A fresh daily puzzle is ready when you are.';

  @override
  String get reminderNotificationBody3 =>
      'New dolls are waiting to be nested. Today’s puzzle is ready.';

  @override
  String get reminderChannelName => 'Daily reminder';

  @override
  String get reminderChannelDescription =>
      'One note a day when the daily puzzle is ready';

  @override
  String get settingReminder => 'Daily reminder';

  @override
  String get settingReminderTime => 'Time';

  @override
  String settingReminderOn(String time) {
    return 'Every day at $time';
  }

  @override
  String get settingReminderOff => 'Off';

  @override
  String get settingReminderBlocked => 'Off in your phone’s settings';

  @override
  String get settingOpenPhoneSettings => 'Open phone settings';

  @override
  String homeChapterKicker(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'CHAPTER $numberString';
  }

  @override
  String homeChapterCardSemantics(
    int number,
    String name,
    int earned,
    int total,
  ) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);
    final intl.NumberFormat earnedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String earnedString = earnedNumberFormat.format(earned);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Chapter $numberString, $name, $earnedString of $totalString stars. Opens chapters.';
  }

  @override
  String homeBonusCardSemantics(int earned, int total) {
    final intl.NumberFormat earnedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String earnedString = earnedNumberFormat.format(earned);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Bonus levels, $earnedString of $totalString stars. Opens chapters.';
  }

  @override
  String get homeVsComputerSemantics => 'vs Computer, computer player';

  @override
  String chaptersKicker(int number, int first, int last) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);
    final intl.NumberFormat firstNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String firstString = firstNumberFormat.format(first);
    final intl.NumberFormat lastNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String lastString = lastNumberFormat.format(last);

    return 'CHAPTER $numberString · LEVELS $firstString–$lastString';
  }

  @override
  String chaptersRowSemantics(
    int number,
    String name,
    int first,
    int last,
    int earned,
    int total,
  ) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);
    final intl.NumberFormat firstNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String firstString = firstNumberFormat.format(first);
    final intl.NumberFormat lastNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String lastString = lastNumberFormat.format(last);
    final intl.NumberFormat earnedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String earnedString = earnedNumberFormat.format(earned);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Chapter $numberString, $name, levels $firstString to $lastString, $earnedString of $totalString stars';
  }

  @override
  String chaptersRowLockedSemantics(
    int number,
    String name,
    int first,
    int last,
  ) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);
    final intl.NumberFormat firstNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String firstString = firstNumberFormat.format(first);
    final intl.NumberFormat lastNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String lastString = lastNumberFormat.format(last);

    return 'Chapter $numberString, $name, levels $firstString to $lastString, locked';
  }

  @override
  String get chaptersLevelChestSemantics => 'has a milestone chest';

  @override
  String get chaptersLevelFinaleSemantics => 'last level of the chapter';

  @override
  String museumNicheCollectedSemantics(String name) {
    return '$name, collected';
  }

  @override
  String museumNicheNextSemantics(String name, int chapter, int count) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, next, chapter $chapterString, $countString levels to go',
      one: '$name, next, chapter $chapterString, 1 level to go',
    );
    return '$_temp0';
  }

  @override
  String museumNicheLockedSemantics(int chapter, int first, int last) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);
    final intl.NumberFormat firstNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String firstString = firstNumberFormat.format(first);
    final intl.NumberFormat lastNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String lastString = lastNumberFormat.format(last);

    return 'Chapter $chapterString, levels $firstString to $lastString, locked';
  }

  @override
  String museumCountSemantics(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$doneString of $totalString families home';
  }

  @override
  String museumFullSub(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Full House · all $countString families';
  }

  @override
  String recordsRaceSemantics(String rival, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$rival, computer player, races won: $countString';
  }

  @override
  String recordsRaceLockedSemantics(String rival) {
    return '$rival, computer player, not unlocked yet';
  }

  @override
  String recordsStatSemantics(String label, String value) {
    return '$label, $value';
  }

  @override
  String recordsBadgesCount(int earned, int total) {
    final intl.NumberFormat earnedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String earnedString = earnedNumberFormat.format(earned);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$earnedString/$totalString';
  }
}
