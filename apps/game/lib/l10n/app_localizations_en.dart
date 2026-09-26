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
  String get devLevelPickerTitle => 'Jump to a level';
}
