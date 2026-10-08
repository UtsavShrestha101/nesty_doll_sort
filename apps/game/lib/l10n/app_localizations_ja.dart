// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Nesty';

  @override
  String get splashLoading => '読み込み中…';

  @override
  String progressPercent(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString';
  }

  @override
  String get genericLoadFailed => '問題が発生しました。';

  @override
  String get splashStorageTitle => '空き容量がほとんどありません';

  @override
  String splashStorageBody(int size) {
    final intl.NumberFormat sizeNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String sizeString = sizeNumberFormat.format(size);

    return 'Nestyの準備に約${sizeString}MB必要です。空き容量を増やしてから、もう一度お試しください。';
  }

  @override
  String get splashContentTitle => '棚が開きませんでした';

  @override
  String get splashContentBody => '読み込み中に問題が発生しました。もう一度試すか、Nestyを再起動してください。';

  @override
  String get retry => 'もう一度';

  @override
  String levelTitle(int level) {
    return 'レベル$level';
  }

  @override
  String get pause => '一時停止';

  @override
  String get boosterUndo => '戻す';

  @override
  String get boosterUndoShort => '戻す';

  @override
  String get boosterHint => 'ヒント';

  @override
  String get boosterHintShort => 'ヒント';

  @override
  String get boosterExtraSlot => '+マス';

  @override
  String get boosterExtraSlotShort => '+1';

  @override
  String get restart => 'やり直す';

  @override
  String get restartShort => 'やり直す';

  @override
  String get splashDollSort => 'ドールソート';

  @override
  String get splashCaption => '棚のほこりを払っています…';

  @override
  String get homePlay => 'プレイ';

  @override
  String get homeAllLevelsDone => '全部クリア！';

  @override
  String playSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'レベル$levelStringをプレイ';
  }

  @override
  String playLevelSemantics(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'レベル$levelString、$tierをプレイ';
  }

  @override
  String coinPillShopSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringコイン。ショップを開きます。',
    );
    return '$_temp0';
  }

  @override
  String get tierHard => 'ハード';

  @override
  String get tierSuperHard => '超ハード';

  @override
  String get tierSuperShort => '超';

  @override
  String tierName(String tier) {
    String _temp0 = intl.Intl.selectLogic(tier, {
      'easy': 'イージー',
      'medium': 'ノーマル',
      'hard': 'ハード',
      'superhard': '超ハード',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String levelWithTier(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'レベル$levelString・$tier';
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
  String familyCounterSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$totalString家族中$countString家族が完成',
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
      other: '$countStringコイン',
    );
    return '$_temp0';
  }

  @override
  String get levelDaily => 'デイリー';

  @override
  String levelDailySemantics(String date) {
    return 'デイリーパズル、$date';
  }

  @override
  String bonusLevelTitle(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'ボーナスレベル$levelString';
  }

  @override
  String get closeSemantics => '閉じる';

  @override
  String get backSemantics => '戻る';

  @override
  String boosterAdSemantics(String booster) {
    return '$booster、動画を見る';
  }

  @override
  String boosterCoinSemantics(String booster, int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$booster、$priceStringコイン',
    );
    return '$_temp0';
  }

  @override
  String boosterUndoCountSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '戻す、あと$countString回',
    );
    return '$_temp0';
  }

  @override
  String boosterHintCountSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ヒント、あと$countString回',
    );
    return '$_temp0';
  }

  @override
  String boosterSlotCountSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '追加マス、あと$countString回',
    );
    return '$_temp0';
  }

  @override
  String get softStuckTitle => 'うーん、行き詰まったかも';

  @override
  String get softStuckBody => '「戻す」を試してみますか？そのまま続けてもOKです。';

  @override
  String get softStuckBodyRestart => '「やり直す」を試してみますか？そのまま続けてもOKです。';

  @override
  String get softStuckAction => '戻す';

  @override
  String get oomTitle => '動かせる手がありません！';

  @override
  String get oomSubtitle => '続ける方法を選んでください。';

  @override
  String get oomUndoSubtitle => '直前の手を戻します';

  @override
  String oomUndoFree(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '無料・あと$countString回',
    );
    return '$_temp0';
  }

  @override
  String get oomSlotTitle => '+1マス';

  @override
  String get oomSlotSubtitle => 'このレベルにマスを1つ追加';

  @override
  String get oomSlotOffline => 'オフライン中はコインのみ';

  @override
  String get oomRestartSubtitle => 'このレベルを無料で最初から';

  @override
  String coinPrice(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringコイン',
    );
    return '$_temp0';
  }

  @override
  String get watchAd => '広告を見る';

  @override
  String get watchAdSemantics => '広告を見る';

  @override
  String get offlineTitle => 'オフライン';

  @override
  String get offlineAds => '広告ボタンはコインの価格になります';

  @override
  String get connectToWatchAd => '広告を見るには接続してください';

  @override
  String get winTitle => 'レベルクリア！';

  @override
  String get winTitleShort => 'クリア！';

  @override
  String get winContinue => 'つづける';

  @override
  String get winTripleCoins => '×3コイン';

  @override
  String get winRewardAdded => '報酬を追加しました';

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

    return '第$numberString章';
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
    return '次：$name';
  }

  @override
  String get winChapterDone => '章クリア！次はごほうびです。';

  @override
  String figurineName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'クラシックの家族',
      'sailor': '船乗りの家族',
      'baker': 'パン屋の家族',
      'astronaut': '宇宙飛行士の家族',
      'gardener': '庭師の家族',
      'snow': '雪の家族',
      'circus': 'サーカスの家族',
      'musician': '音楽家の家族',
      'royal': '王さまの家族',
      'explorer': '探検家の家族',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String chapterRibbon(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return '第$numberString章・$name';
  }

  @override
  String chapterRibbonShort(String name) {
    return '$name';
  }

  @override
  String chapterName(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'ch01': 'ひなたのおもちゃ屋',
      'ch02': '雨のカフェの一角',
      'ch03': '海辺のマーケット',
      'ch04': '雪のキャビン',
      'ch05': '夜のカーニバル',
      'ch06': '春の庭の物置',
      'ch07': '人形劇場',
      'ch08': '秋の野外音楽堂',
      'ch09': '城の図書室',
      'ch10': '日の出の展望台',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get pauseTitle => '一時停止中';

  @override
  String get resume => '再開';

  @override
  String get home => 'ホーム';

  @override
  String get settings => '設定';

  @override
  String get settingSound => 'サウンド';

  @override
  String get settingMusic => '音楽';

  @override
  String get settingHaptics => '振動';

  @override
  String get allLevelsTitle => 'すべてのレベルをクリアしました！';

  @override
  String get allLevelsBody => '新しい章が登場予定です。それまでボーナスレベルをどうぞ。';

  @override
  String allLevelsPlayBonus(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'ボーナスレベル$numberStringをプレイ';
  }

  @override
  String get allLevelsBackHome => 'ホームへ戻る';

  @override
  String get nextLevelFailedHome => 'ホームへ戻る';

  @override
  String get gameplayFailedTitle => '棚の準備に少し時間が必要です';

  @override
  String get gameplayFailedBody => 'このレベルを準備できませんでした。もう一度試すか、ホームに戻ってください。';

  @override
  String get devLevelPickerTitle => 'レベルへジャンプ';

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

    return '第$numberString章・レベル$startString–$endString';
  }

  @override
  String get navShop => 'ショップ';

  @override
  String get navHomeShort => 'ホーム';

  @override
  String get navShopShort => 'ショップ';

  @override
  String get navMuseum => 'ミュージアム';

  @override
  String get navMuseumShort => 'ミュージアム';

  @override
  String get homeDailyTile => 'デイリーパズル';

  @override
  String get homeMuseumTile => 'ミュージアム';

  @override
  String get homeRemoveAdsTile => '広告を消す';

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
  String homeDailyLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Lv.$levelStringクリア後';
  }

  @override
  String get homeBonusBadge => 'ボーナス';

  @override
  String get homeBonusKicker => 'エンドレスボーナス';

  @override
  String get homeBonusName => 'ボーナスレベル';

  @override
  String streakBadgeSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString日連続',
    );
    return '$_temp0';
  }

  @override
  String get settingColorSymbols => '色の記号';

  @override
  String get symbolsSubtle => '控えめ';

  @override
  String get symbolsLarge => '大きい';

  @override
  String get settingLanguage => '言語';

  @override
  String get settingRestorePurchases => '購入の復元';

  @override
  String get settingPrivacyChoices => 'プライバシー設定';

  @override
  String get settingPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingSupport => 'サポート';

  @override
  String get settingSupportValue => 'メールを送る';

  @override
  String settingsFooter(String version, String build, String playerId) {
    return 'Nesty: Doll Sort · v$version（ビルド$build）· プレイヤーID $playerId';
  }

  @override
  String get languageSheetTitle => '言語';

  @override
  String get languageSheetDone => '完了';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': '英語',
      'es': 'スペイン語',
      'pt_BR': 'ポルトガル語',
      'id': 'インドネシア語',
      'hi': 'ヒンディー語',
      'de': 'ドイツ語',
      'fr': 'フランス語',
      'tr': 'トルコ語',
      'ja': '日本語',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String a11yJoinList(String first, String second) {
    return '$first、$second';
  }

  @override
  String a11yJoinSentences(String first, String second) {
    return '$first。$second';
  }

  @override
  String languageRowSemantics(String autonym, String detail) {
    return '$autonym、$detail';
  }

  @override
  String dailyStreakDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString日',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakKeep => '今日プレイして、連続記録を伸ばしましょう';

  @override
  String get dailyStreakStart => '今日のパズルを解いて、最初の炎をともしましょう。';

  @override
  String get dailyStreakDone => '炎がともりました。また明日。';

  @override
  String get dailyStreakWeek => 'まる1週間！';

  @override
  String dailyFreezes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'フリーズ$countString個',
      zero: 'フリーズなし',
    );
    return '$_temp0';
  }

  @override
  String dailyFreezesSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '連続記録フリーズ$countString個',
    );
    return '$_temp0';
  }

  @override
  String get dailyDay => 'DAY';

  @override
  String get dailyToday => '今日';

  @override
  String get dailyTomorrow => '明日';

  @override
  String dailyDaySemantics(String state, int day) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'done': '$day日目、完了',
      'today': '今日、$day日目',
      'tomorrow': '明日、$day日目',
      'chest': '$day日目、宝箱',
      'other': '$day日目',
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
      other: 'プレイ、$countStringコイン',
    );
    return '$_temp0';
  }

  @override
  String dailyChestRow(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '7日目の宝箱・$countStringコイン',
    );
    return '$_temp0';
  }

  @override
  String dailyChestToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと$countString日',
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
      other: '今日を含めてあと$countString日',
    );
    return '$_temp0';
  }

  @override
  String get dailyChestOpenedToday => '今日開けました';

  @override
  String dailyPuzzleTitle(String weekday) {
    return '$weekdayのパズル';
  }

  @override
  String dailyPuzzleInfo(int colors, String tier) {
    final intl.NumberFormat colorsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String colorsString = colorsNumberFormat.format(colors);

    String _temp0 = intl.Intl.pluralLogic(
      colors,
      locale: localeName,
      other: '$colorsString色',
    );
    return '$_temp0・$tier';
  }

  @override
  String get dailyPlay => 'プレイ';

  @override
  String dailySolvedChip(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return 'クリア・+$coinsString';
  }

  @override
  String dailyNextPuzzle(String time) {
    return '次のパズルまで$time';
  }

  @override
  String dailyCountdown(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString時間$minutesString分';
  }

  @override
  String playLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'レベル$levelStringをプレイ';
  }

  @override
  String get dailySavedTitle => 'フリーズが炎を守りました。';

  @override
  String dailySavedBody(String weekday) {
    return '$weekdayはフリーズでカバーされました。来週、新しいフリーズがもらえます。';
  }

  @override
  String get dailyChestTitle => '7日連続！';

  @override
  String get dailyChestBody => '7日続けて達成。中身を見てみましょう。';

  @override
  String get dailyChestDouble => '2倍にする';

  @override
  String get dailyChestCollect => '受け取る';

  @override
  String get dailyWinTitle => 'デイリークリア！';

  @override
  String dailyWinStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString日連続';
  }

  @override
  String dailyWinChestHint(String count) {
    String _temp0 = intl.Intl.selectLogic(count, {
      '0': '7日目の宝箱の準備ができました！',
      '1': '7日目の宝箱まであと1日',
      '2': '7日目の宝箱まであと2日',
      '3': '7日目の宝箱まであと3日',
      '4': '7日目の宝箱まであと4日',
      '5': '7日目の宝箱まであと5日',
      '6': '7日目の宝箱まであと6日',
      'other': '7日目の宝箱まであと$count日',
    });
    return '$_temp0';
  }

  @override
  String get dailyBackToDaily => 'デイリーに戻る';

  @override
  String get museumTitle => 'ミュージアム';

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
      other: '第$chapterString章・あと$countStringレベル',
    );
    return '$_temp0';
  }

  @override
  String get museumAllHome => 'どの家族も帰ってきました。';

  @override
  String get museumNextFamily => '次の家族';

  @override
  String get museumNextFamilyKicker => '次の家族';

  @override
  String museumFamilyLabel(String name) {
    return '$nameの家族';
  }

  @override
  String museumSoonLabel(String name) {
    return '$name・準備中';
  }

  @override
  String figurineShortName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'クラシック',
      'sailor': '船乗り',
      'baker': 'パン屋',
      'astronaut': '宇宙飛行士',
      'gardener': '庭師',
      'snow': '雪',
      'circus': 'サーカス',
      'musician': '音楽家',
      'royal': '王さま',
      'explorer': '探検家',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String figurineFlavor(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': '「いちばん小さな人形は、かくれんぼでいつも勝ちます。」',
      'sailor': '「いちばん小さな人形に、念のため貝殻を入れています。」',
      'baker': '「どのパンも4サイズ焼くので、誰も分け合わずにすみます。」',
      'astronaut': '「月へ出発する前に、大きい順から小さい順へカウントダウンします。」',
      'gardener': '「どの帽子の下にも、春にまくための種がかくれています。」',
      'snow': '「誰も見ていないときは、重なって雪だるまになります。」',
      'circus': '「いちばんの芸は、おたがいの中にもぐりこむこと。拍手が鳴りやみません。」',
      'musician': '「同じ曲を4つのサイズで奏でます。高い音は、いちばん小さな人形の担当です。」',
      'royal': '「どの王冠も次の王冠の中におさまるので、場所をとりません。」',
      'explorer': '「お店の棚はぜんぶ地図にしました。でも、まだ続きます。」',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String museumChapterChip(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return '第$numberString章・$name';
  }

  @override
  String museumCollectedOn(String date) {
    return '入手・$date';
  }

  @override
  String get museumCollected => '入手済み';

  @override
  String museumLockedText(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return '第$numberString章をクリアすると、この家族が帰ってきます。';
  }

  @override
  String museumIntro(int levels) {
    final intl.NumberFormat levelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelsString = levelsNumberFormat.format(levels);

    return '章ごとに人形の家族がいます。その章の$levelsStringレベルをすべてクリアして、家族を迎えましょう。';
  }

  @override
  String museumLevelsToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと$countStringレベル',
    );
    return '$_temp0';
  }

  @override
  String museumNextChip(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと$countString',
    );
    return '$_temp0';
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

    return '$chapterString章・$firstString–$lastString';
  }

  @override
  String museumLockedLine1(int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return '第$chapterString章';
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

    return 'レベル$firstString–$lastString';
  }

  @override
  String get shopTitle => 'ショップ';

  @override
  String get shopTabCoins => 'コイン';

  @override
  String get shopTabSkins => 'スキン';

  @override
  String get shopTabThemes => 'テーマ';

  @override
  String get shopTabNoAds => '広告なし';

  @override
  String get shopEquipped => '装備中';

  @override
  String get shopEquip => '装備する';

  @override
  String get skinOwnedSemantics => '所持済み';

  @override
  String skinName(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'クラシック',
      'space': 'スペース',
      'ocean': 'オーシャン',
      'sweets': 'スイーツ',
      'forest': '森のなかま',
      'winter': 'ウィンター',
      'forest_bear': '森のクマ',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String skinDescription(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': '描かれた花、金色の水玉、小さなリボン。',
      'ocean': 'セーラーカラー、小さな錨、波のふちどり。',
      'space': '丸いヘルメット、小さなアンテナ、輪のある惑星。',
      'sweets': 'とろけるフロスティング、スプリンクル、キャンディ柄。',
      'forest': 'とがった耳、パールつきのフード、舞い落ちる葉。',
      'winter': 'ポンポンつきの帽子、雪の結晶、真珠色のふちどり。',
      'forest_bear': '丸いクマの耳、あったかフード、葉っぱの中のどんぐり。',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get skinDetailTitle => 'スキン';

  @override
  String get skinDetailColors => '全11色・記号つき';

  @override
  String get skinDetailSizes => 'どのサイズも同じようにはまります。変わるのはペイントだけ。';

  @override
  String get shopBuy => '買う';

  @override
  String shopBuySemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '買う、$countStringコイン',
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
      other: '$countStringコイン持っています',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsTitle => 'コインがあと少し必要です';

  @override
  String notEnoughCoinsNeeded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと$countStringコイン必要です',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsSource => 'コインはレベルのクリア、デイリーパズル、宝箱で手に入ります。';

  @override
  String get notEnoughCoinsGoToShop => 'ショップへ';

  @override
  String get notNow => '今はやめておく';

  @override
  String shopDownloading(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'ダウンロード中 $percentString%';
  }

  @override
  String get themesMatchTitle => '章に合わせる';

  @override
  String get themesMatchSubtitle => 'いま遊んでいる章のテーマを使います';

  @override
  String get themeInUse => '使用中';

  @override
  String get themeUse => '使う';

  @override
  String themeChapterLock(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return '第$numberString章';
  }

  @override
  String get shopClosedTitle => 'ショップはいまお休み中です';

  @override
  String get shopClosedBody => 'コインパックと広告削除は、今後のアップデートで登場します。';

  @override
  String buyUndoText(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '無料の「戻す」$countString回を使いました。もう1手戻せます。',
    );
    return '$_temp0';
  }

  @override
  String get buyHintText => '次のおすすめの手を表示します。';

  @override
  String get buySlotText => 'このレベルに空きマスを1つ追加します。';

  @override
  String get tutorialStep1Title => '小さい人形をタップ';

  @override
  String tutorialStepChip(int step, int total) {
    return 'ステップ$step/$total';
  }

  @override
  String get tutorialStep1Text => '人形は、同じ色のひとつ大きい人形に入ります。';

  @override
  String get tutorialStep2Title => '次に大きい人形をタップ';

  @override
  String get tutorialStep2Text => '小さい人形がカチャッと中に入ります。';

  @override
  String get tutorialStep3Title => '家族を完成させよう';

  @override
  String get tutorialStep3Text => '最後の人形を入れましょう。すべてのサイズが入ると家族の完成です。';

  @override
  String tutorialStepSemantics(int step, String title) {
    final intl.NumberFormat stepNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String stepString = stepNumberFormat.format(step);

    return 'ステップ$stepString/3。$title';
  }

  @override
  String get tutorialSwallowChip => '新しい動き';

  @override
  String get tutorialSwallowTitle => '大きい人形は小さい人形にかぶせられる';

  @override
  String get tutorialSwallowText => '大きい人形をひとつ小さい人形の上に置くと、すっぽりかぶさります。';

  @override
  String get introNew => 'NEW';

  @override
  String get introTowersTitle => 'タワー！';

  @override
  String get introTowersText => '動かせるのは一番上の人形だけ。どけると、下に隠れた人形が現れます。';

  @override
  String get introGlassTitle => 'ガラスケース';

  @override
  String get introGlassText => '鍵のかかった人形は、鍵に描かれた家族が完成すると自由になります。';

  @override
  String get introIceTitle => '氷';

  @override
  String get introIceText => '家族を完成させるたびに氷が割れます。ゼロになると人形が自由に。';

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
  String get introGotIt => 'わかった';

  @override
  String chapterCompleteTitle(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return '第$numberString章クリア';
  }

  @override
  String get chapterCompleteAdded => 'ミュージアムに追加されました！';

  @override
  String chapterCompleteCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countStringコイン';
  }

  @override
  String chapterCompleteNext(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return '次：第$numberString章・$name';
  }

  @override
  String get gameplayGenerating => '棚を準備中…';

  @override
  String dailyStreakPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString日連続の記録はお休み中です。今日のパズルを解いて、もう一度ともしましょう。';
  }

  @override
  String get dailyStreakPausedChip => 'お休み中';

  @override
  String get dailyStreakRelitTitle => '連続記録が復活！';

  @override
  String dailyStreakRelitBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString日連続の記録がまた輝いています。';
  }

  @override
  String streakBadgeSemanticsPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString日連続、お休み中',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => '章';

  @override
  String chaptersOverallProgress(int level, int total) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '全$totalStringレベル中レベル$levelString';
  }

  @override
  String chaptersWonCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countStringクリア';
  }

  @override
  String chaptersBestMoves(int best) {
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'ベスト$bestString';
  }

  @override
  String get chaptersLevelPlay => 'プレイ';

  @override
  String chaptersLevelSemanticsWon(int level, int count, int best) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'レベル$levelString、星$countStringつ。ベスト$bestString手。',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsWonNoBest(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'レベル$levelString、クリア済み';
  }

  @override
  String chaptersLevelSemanticsWonBestOnly(int level, int best) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    String _temp0 = intl.Intl.pluralLogic(
      best,
      locale: localeName,
      other: 'レベル$levelString、クリア済み。ベスト$bestString手。',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsCurrent(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'レベル$levelString、次にプレイ';
  }

  @override
  String chaptersLevelSemanticsLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'レベル$levelString、ロック中';
  }

  @override
  String get recordsTitle => '記録';

  @override
  String get homeRecordsButton => '記録';

  @override
  String get recordsLevelsWon => 'クリアしたレベル';

  @override
  String get recordsFamilies => '完成した家族';

  @override
  String get recordsRacesHeader => '勝利したレース';

  @override
  String get recordsDolls => '入れた人形';

  @override
  String get recordsDailies => '解いたデイリーパズル';

  @override
  String get recordsLongestStreak => '最長の連続記録';

  @override
  String get recordsBestMovesLink => 'レベル別のベスト手数';

  @override
  String get recordsBadgesHeader => 'バッジ';

  @override
  String badgeName(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'ぴったりおさまる',
      'glass_breaker': 'ガラスの達人',
      'ice_melter': '氷くだき',
      'tall_order': '背高ノッポ',
      'grand_nest': '入れ子の極み',
      'level_100': '折り返し地点',
      'level_200': 'いちばん上の棚',
      'dailies_7': 'パズル仲間',
      'dailies_30': 'なじみの友',
      'first_race': '棚いちばん乗り',
      'all_rivals': 'ライバル総ざらい',
      'museum_full': '満員御礼',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeLine(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': '初めて家族を完成させました。',
      'glass_breaker': '初めてガラスケースを開けました。',
      'ice_melter': '人形を氷から助け出しました。',
      'tall_order': 'サイズ5の人形があるレベルをクリアしました。',
      'grand_nest': 'サイズ6の人形があるレベルをクリアしました。',
      'level_100': 'レベル100をクリアしました。',
      'level_200': '最後のレベル、レベル200をクリアしました。',
      'dailies_7': 'デイリーパズルを7回解きました。',
      'dailies_30': 'デイリーパズルを30回解きました。',
      'first_race': 'レースでコンピューターに勝ちました。',
      'all_rivals': 'すべてのコンピューターライバルに勝ちました。',
      'museum_full': 'ミュージアムにすべての家族が帰ってきました。',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeHint(String badge, int level, int count) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': '家族を1つ完成させよう。',
      'glass_breaker': 'ガラスケースを開けよう。',
      'ice_melter': '人形を氷から助けよう。',
      'tall_order': 'サイズ5の人形があるレベルをクリアしよう。',
      'grand_nest': 'サイズ6の人形があるレベルをクリアしよう。',
      'level_100': 'レベル$levelStringをクリアしよう。',
      'level_200': 'レベル$levelStringをクリアしよう。',
      'dailies_7': 'デイリーパズルを$countString回解こう。',
      'dailies_30': 'デイリーパズルを$countString回解こう。',
      'first_race': 'レースでコンピューターに勝とう。',
      'all_rivals': 'すべてのコンピューターライバルに勝とう。',
      'museum_full': 'すべての家族をミュージアムに迎えよう。',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeSemanticsEarned(String badge) {
    return '$badge、獲得済み';
  }

  @override
  String badgeSemanticsLocked(String badge, String how) {
    return '$badge、未獲得。$how';
  }

  @override
  String badgeEarnedToastTitle(String badge) {
    return 'バッジ獲得・$badge';
  }

  @override
  String get badgeLockedLine => '未獲得';

  @override
  String winMovesBest(int moves, int best) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return '手数$movesString・ベスト$bestString';
  }

  @override
  String winMovesOnly(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return '手数$movesString';
  }

  @override
  String winChestCountdown(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '宝箱まであと$countStringレベル',
    );
    return '$_temp0';
  }

  @override
  String get winReplayReason => '楽しむためのリプレイです。コインは新しいレベルで手に入ります。';

  @override
  String get winBackToChapters => '章に戻る';

  @override
  String get chestMilestoneTitle => '節目の宝箱';

  @override
  String chestMilestoneBody(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'レベル$levelString到達の宝箱です。中身を見てみましょう。';
  }

  @override
  String chestMilestoneBodyBonus(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'ボーナスレベル$levelStringの宝箱です。中身を見てみましょう。';
  }

  @override
  String chestContentsCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countStringコイン',
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
      other: '+$countStringヒント',
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
      other: '$coinsStringコイン',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hints,
      locale: localeName,
      other: '$hintsStringヒント',
    );
    return '$_temp0、$_temp1';
  }

  @override
  String chestSemantics(String contents) {
    return '宝箱。中身：$contents。';
  }

  @override
  String get chestOpen => '開ける';

  @override
  String get settingRelaxedMode => 'リラックスモード';

  @override
  String get settingRelaxedModeSubtitle => '「戻す」が無制限・無料';

  @override
  String get relaxedModeOn => 'リラックスモードがオンです。何度でも戻せます。';

  @override
  String get settingReduceMotion => '動きを減らす';

  @override
  String get reduceMotionSystem => 'システム';

  @override
  String get reduceMotionOn => 'オン';

  @override
  String get reduceMotionOff => 'オフ';

  @override
  String get oomUndoFreeUnlimited => '無料・何度でも';

  @override
  String oomUndoSpent(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '無料の「戻す」$countString回を使いました',
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
      other: '追加マスは1レベルにつき最大$countStringつまでです。',
    );
    return '$_temp0';
  }

  @override
  String get boosterUndoUnlimitedSemantics => '戻す、無制限';

  @override
  String get oomUndoFreeChip => '無料';

  @override
  String boosterLimitSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '+マス、$totalString回中$countString回使用';
  }

  @override
  String hintGainedTag(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString';
  }

  @override
  String boosterSuggestedSemantics(String booster) {
    return '$booster、おすすめ';
  }

  @override
  String get boosterRestartSemantics => 'レベルをやり直す';

  @override
  String get homeVsComputerTile => 'コンピューター戦';

  @override
  String homeVsComputerLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Lv.$levelStringクリア後';
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
  String get raceSelectTitle => 'コンピューター対戦';

  @override
  String get raceSelectSubtitle => '同じパズルでコンピューターとレース';

  @override
  String get raceComputerTag => 'コンピューター';

  @override
  String raceRivalName(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'コメット',
      two: 'ボタン',
      one: 'コイシ',
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
      other: '元気いっぱいで手際がよく、なかなか追いつけません。',
      two: '1手ずつ慎重に確かめてから動かします。',
      one: 'マイペースに、人形ひとつひとつを楽しみながら進みます。',
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
      other: '軽快なペース',
      two: '安定したペース',
      one: 'ゆっくりペース',
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
      other: '$coinsStringコインをゲット',
    );
    return '$_temp0';
  }

  @override
  String raceRivalLocked(String rival) {
    return '$rivalに勝つと解放';
  }

  @override
  String get raceRivalNew => 'NEW';

  @override
  String raceRivalSemantics(String name) {
    return '$name、コンピューター';
  }

  @override
  String raceRivalCardSemantics(String rival, String skill) {
    return '$rival、コンピューターライバル。$skill。';
  }

  @override
  String raceRivalLockedSemantics(String rival) {
    return 'ロック中のコンピューターライバル。$rivalに勝つと解放されます。';
  }

  @override
  String get raceRivalSelectedSemantics => '選択中';

  @override
  String get raceStart => 'スタート';

  @override
  String get raceStartHint => '同じパズルを2つのボードで。先にすべての家族を完成させましょう。';

  @override
  String get raceStripReady => '準備ができたらどうぞ';

  @override
  String get raceStripThinking => '考え中…';

  @override
  String get raceStripStartingOver => '最初から';

  @override
  String get raceStripFinished => '完成';

  @override
  String get raceStripPlayerFinished => 'こちらが先に完成';

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
  String raceStripSemantics(String name, int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$name、コンピューター：$totalString家族中$countString家族',
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

    return 'コンピューターが家族を完成させました：$totalString中$doneString';
  }

  @override
  String raceAnnounceStart(String rival) {
    return '$rival（コンピューター）とのレースを開始しました。';
  }

  @override
  String get raceAnnounceStartingOver => 'コンピューターが最初からやり直しています。';

  @override
  String get raceAnnounceFinished => 'コンピューターがすべての家族を完成させました。';

  @override
  String get raceAnnounceWon => 'レースに勝ちました。';

  @override
  String get raceAnnounceLost => 'コンピューターが先に完成させました。';

  @override
  String get raceWinTitle => 'レースに勝ちました！';

  @override
  String get raceWinTitleShort => '勝ちました！';

  @override
  String raceWinBody(String rival) {
    return 'すべての家族が完成しました。$rivalはまだ並べている途中でした。';
  }

  @override
  String raceWinCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countStringコイン',
    );
    return '$_temp0';
  }

  @override
  String get raceLossTitle => '惜しい！再戦しますか？';

  @override
  String get raceLossTitleShort => '惜しい！';

  @override
  String raceLossBody(String rival) {
    return '今回は$rivalが先に完成させました。再戦は無料です。';
  }

  @override
  String get raceRivalUnlockedTitle => '新ライバル解放！';

  @override
  String raceRivalUnlockedBody(String rival) {
    return '$rivalがレースの準備を整えました。';
  }

  @override
  String raceRivalUnlockedRace(String rival) {
    return '$rivalとレース';
  }

  @override
  String get raceLeaveTitle => 'このレースをやめますか？';

  @override
  String get raceLeaveBody => 'ここでレースを止めます。コインはもらえませんが、ほかはそのままです。';

  @override
  String get raceLeaveKeep => 'レースを続ける';

  @override
  String get raceRematch => '再戦';

  @override
  String get raceNewRace => '新しいレース';

  @override
  String get raceBackToRivals => 'レース一覧へ';

  @override
  String get raceFailedTitle => '棚の準備に少し時間が必要です';

  @override
  String get raceFailedBody => 'このレースを準備できませんでした。もう一度試すか、別のレースを選んでください。';

  @override
  String racePauseSubtitle(String rival) {
    return '$rivalも一時停止中です。';
  }

  @override
  String racePauseHeader(String rival) {
    return 'コンピューター対戦・$rival';
  }

  @override
  String get raceRivalBeaten => '勝利済み';

  @override
  String raceStartFor(String rival) {
    return '$rivalとのレースを始める';
  }

  @override
  String get raceQuit => 'レースをやめる';

  @override
  String starsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '星3つ中$countつ',
    );
    return '$_temp0';
  }

  @override
  String starsNewBestSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ベスト更新、星3つ中$countつ',
    );
    return '$_temp0';
  }

  @override
  String winStarsTarget(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return '$movesString手以内で星3つ';
  }

  @override
  String get winStarsNewBest => 'ベスト更新！';

  @override
  String get starsFirstTip => '手数が少ないほど星が増えます。どのレベルも「章」から遊び直せます。';

  @override
  String get starsHelperNote => 'ヒントや追加マスを使ったクリアは、星2つまでです。';

  @override
  String chaptersStarsTotal(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString/$totalString';
  }

  @override
  String chaptersStarsTotalAll(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString/$totalString';
  }

  @override
  String get chaptersAllThreeStars => '全レベル星3つ';

  @override
  String chaptersStarsSemantics(int earned, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      earned,
      locale: localeName,
      other: '星$total個中$earned個',
    );
    return '$_temp0';
  }

  @override
  String get recordsStars => '星';

  @override
  String recordsStarsValue(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalString中$countString';
  }

  @override
  String get dailyShare => 'シェア';

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
  String get dailyShareSemantics => '今日の結果をシェア';

  @override
  String dailyShareText(String date, String glyphs, int moves, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves手でクリア・$day日目 🔥',
    );
    return 'Nestyデイリー・$date\n$glyphs\n$_temp0';
  }

  @override
  String dailyShareTextNoStreak(String date, String glyphs, int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves手でクリア',
    );
    return 'Nestyデイリー・$date\n$glyphs\n$_temp0';
  }

  @override
  String get reminderOfferTitle => '明日のパズルができたらお知らせしますか？';

  @override
  String get reminderOfferBody => '1日1回、決めた時間にそっとお知らせします。設定でオフにできます。';

  @override
  String reminderOfferTime(String time) {
    return '毎日$time';
  }

  @override
  String get reminderOfferChangeTime => '時間を変更';

  @override
  String reminderTimeChipSemantics(String time) {
    return 'お知らせの時間、毎日$time。時間を変更。';
  }

  @override
  String get reminderPickerTitle => 'お知らせの時間';

  @override
  String get reminderOfferYes => 'お知らせを受け取る';

  @override
  String get reminderOfferNo => 'いいえ、けっこうです';

  @override
  String reminderOfferDone(String time) {
    return '$timeにお知らせを設定しました。';
  }

  @override
  String get reminderOfferDeniedTitle => 'Nestyの通知がオフです';

  @override
  String reminderOfferDenied(String time) {
    return 'スマホの設定でオンにすると、$timeにお知らせが届きます。';
  }

  @override
  String get reminderNotificationTitle => 'Nesty';

  @override
  String get reminderNotificationBody => '今日のパズルが棚に並びました。';

  @override
  String get reminderNotificationBody2 => '新しいデイリーパズルの準備ができました。';

  @override
  String get reminderNotificationBody3 =>
      '新しい人形たちが入る場所を待っています。今日のパズルの準備ができました。';

  @override
  String get reminderChannelName => 'デイリーパズル';

  @override
  String get reminderChannelDescription => '新しいデイリーパズルができたときに届く、1日1回のお知らせ。';

  @override
  String get settingReminder => '毎日のお知らせ';

  @override
  String get settingReminderTime => '時間';

  @override
  String get settingReminderBlocked => 'スマホの設定でオフになっています';

  @override
  String get settingOpenPhoneSettings => 'スマホの設定を開く';

  @override
  String get settingReminderTurnOff => 'オフにする';

  @override
  String homeChapterKicker(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return '第$numberString章';
  }

  @override
  String homeChapterCardSemantics(
    int chapter,
    String name,
    int count,
    int total,
  ) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '第$chapterString章、$name。星$totalString個中$countString個。章の画面を開きます。';
  }

  @override
  String homeBonusCardSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'ボーナスレベル。星$totalString個中$countString個。章の画面を開きます。';
  }

  @override
  String get homeVsComputerSemantics => 'コンピューター対戦。同じパズルでコンピューターとレース。';

  @override
  String homeVsComputerLockedSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'コンピューター対戦、ロック中。レベル$levelStringクリア後。';
  }

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

    return '第$numberString章・レベル$firstString–$lastString';
  }

  @override
  String chaptersRowSemantics(int chapter, String name, int count, int total) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '第$chapterString章、$name。星$totalString個中$countString個。';
  }

  @override
  String chaptersRowLockedSemantics(int chapter, String name) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return '第$chapterString章、$name。ロック中。';
  }

  @override
  String get chaptersLevelChestSemantics => 'このレベルに宝箱があります';

  @override
  String get chaptersLevelFinaleSemantics => '章の最後のレベル';

  @override
  String museumNicheCollectedSemantics(String name) {
    return '$name、ミュージアムに帰ってきました';
  }

  @override
  String museumNicheNextSemantics(String name, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name、次に帰ってくる家族。あと$countStringレベル。',
    );
    return '$_temp0';
  }

  @override
  String museumNicheLockedSemantics(String name, int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return '$name、まだ帰っていません。第$chapterString章。';
  }

  @override
  String museumCountSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalString家族中$countString家族が帰ってきました';
  }

  @override
  String museumFullSub(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '満員御礼・全$countString家族';
  }

  @override
  String recordsRaceSemantics(String rival, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$rival、コンピューター。$countString勝。',
    );
    return '$_temp0';
  }

  @override
  String recordsRaceLockedSemantics(String rival) {
    return '$rival、コンピューター。ロック中。';
  }

  @override
  String recordsStatSemantics(String label, String value) {
    return '$label：$value';
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

  @override
  String get giftTitle => '毎日のプレゼント';

  @override
  String giftDay(int day) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return '$dayString日目';
  }

  @override
  String get giftClaim => '受け取る';

  @override
  String get giftClaimedLine => '今日のプレゼントは受け取りました。';

  @override
  String giftTomorrow(String gift) {
    return '明日：$gift';
  }

  @override
  String giftNext(String gift) {
    return '次のプレゼント：$gift';
  }

  @override
  String get giftButtonReadySemantics => '毎日のプレゼント。受け取れるプレゼントがあります。';

  @override
  String get giftButtonSemantics => '毎日のプレゼント';

  @override
  String giftTileSemantics(int day, String gift, String state) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return '$dayString日目、$gift。$state';
  }

  @override
  String get giftTileDone => '受け取り済み';

  @override
  String get giftTileToday => '今日のプレゼント';

  @override
  String get giftTileLater => 'これから';

  @override
  String get giftChestTitle => '7日目のプレゼント';

  @override
  String get giftChestBody => '7日目の宝箱です。中身を見てみましょう。';

  @override
  String giftCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringコイン',
    );
    return '$_temp0';
  }

  @override
  String giftHints(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringヒント',
    );
    return '$_temp0';
  }

  @override
  String giftSlots(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '追加マス$countStringつ',
    );
    return '$_temp0';
  }

  @override
  String giftRewardPair(String first, String second) {
    return '$firstと$second';
  }

  @override
  String chestContentsSlot(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countStringマス',
    );
    return '$_temp0';
  }

  @override
  String chestContentsSlotSemantics(int coins, int slots) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);
    final intl.NumberFormat slotsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String slotsString = slotsNumberFormat.format(slots);

    String _temp0 = intl.Intl.pluralLogic(
      coins,
      locale: localeName,
      other: '$coinsStringコイン',
    );
    String _temp1 = intl.Intl.pluralLogic(
      slots,
      locale: localeName,
      other: '追加マス$slotsStringつ',
    );
    return '$_temp0、$_temp1';
  }

  @override
  String get giftSubtitle => '1日1つのプレゼント。マイペースでどうぞ。';

  @override
  String get giftTitleShort => 'プレゼント';

  @override
  String get giftChestTitleShort => '7日目';

  @override
  String giftSlotsShort(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringマス',
    );
    return '$_temp0';
  }

  @override
  String chestContentsSlotShort(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString';
  }

  @override
  String giftA11yChestContents(String first, String second) {
    return '$first、$second';
  }

  @override
  String giftA11yClaimed(String gift) {
    return 'プレゼントの$giftを受け取りました。';
  }

  @override
  String giftA11yAdded(String gift, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$giftが加わりました。合計は$countStringです。';
  }

  @override
  String get welcomeBackTitle => 'おかえりなさい！';

  @override
  String get welcomeBackFreeze => 'フリーズが炎を守りました。今日のパズルの準備ができました。';

  @override
  String get welcomeBackFreezeShort => 'フリーズが炎を守りました。';

  @override
  String welcomeBackPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString日連続の記録はお休み中です。今日のパズルの準備ができました。';
  }

  @override
  String welcomeBackPausedShort(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString日連続の記録はお休み中です。';
  }

  @override
  String get welcomeBackNew => '今日のパズルは、いつでもプレイできます。';

  @override
  String get welcomeBackNewShort => '今日のパズルの準備ができました。';

  @override
  String get welcomeBackPlay => 'プレイ';

  @override
  String get welcomeBackPlaySemantics => '今日のパズルをプレイ';

  @override
  String get welcomeBackHideSemantics => 'このカードを非表示にする';

  @override
  String dailyMonthTitle(String month) {
    return '$month';
  }

  @override
  String get dailyMonthHint => 'この7日間のどの日も、気軽にプレイできます。';

  @override
  String get dailyMonthHintShort => 'この7日間のパズルをプレイできます。';

  @override
  String get dailyMonthKeyLit => '当日クリア';

  @override
  String get dailyMonthKeyLater => 'あとからクリア';

  @override
  String get dailyMonthKeyFreeze => 'フリーズ';

  @override
  String dailyMonthShowSemantics(String month) {
    return '$monthを表示';
  }

  @override
  String dailyMonthDaySemantics(String state, String date) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'solved': '$date、クリア',
      'later': '$date、あとからクリア',
      'frozen': '$date、フリーズでカバー',
      'today': '$date、今日',
      'todaySolved': '$date、今日、クリア',
      'future': '$date',
      'other': '$date、未プレイ',
    });
    return '$_temp0';
  }

  @override
  String dailyMonthDayOpenSemantics(String label) {
    return '$label、プレイできます';
  }

  @override
  String pastDailyTitle(String date) {
    return '$date';
  }

  @override
  String get pastDailyNote => '気軽にどうぞ。連続記録は変わりません。';

  @override
  String get pastDailySolvedOnDay => '当日にクリア';

  @override
  String get pastDailySolvedLater => 'あとからクリア';

  @override
  String get pastDailyPlayAgain => 'もう一度プレイ';

  @override
  String get pastDailyWinTitle => 'パズルクリア！';

  @override
  String get pastDailyWinTitleShort => 'クリア！';

  @override
  String pastDailyWinDate(String date) {
    return '$date';
  }

  @override
  String get pastDailyWinLine => 'あとから気軽にプレイしました。';

  @override
  String pastDailyWinSemantics(String date, int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return '$date、$movesString手でクリア。あとから気軽にプレイしました。';
  }

  @override
  String get dailyLockedTitle => 'はじめてのデイリーパズルまで、あと少し';

  @override
  String dailyLockedBody(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'レベル$levelStringをクリアすると、毎日ここに新しいパズルが届きます。みんな同じパズルです。';
  }

  @override
  String get widgetGalleryName => 'デイリーパズル';

  @override
  String get widgetGalleryDescription => '連続記録と今日のパズルをひと目でチェック。';

  @override
  String widgetPuzzleTitle(String weekday) {
    return '$weekdayのパズル';
  }

  @override
  String widgetStreakLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '日連続',
    );
    return '$_temp0';
  }

  @override
  String widgetStreakResting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '日連続・お休み中',
    );
    return '$_temp0';
  }

  @override
  String get widgetStreakRestingShort => 'お休み中';

  @override
  String get widgetFirstFlame => '最初の炎';

  @override
  String get widgetReady => '今日のパズルの準備ができました';

  @override
  String get widgetReadyShort => 'プレイできます';

  @override
  String get widgetSolved => 'クリア。また明日。';

  @override
  String get widgetSolvedShort => 'クリア！';

  @override
  String get widgetLockedTitle => 'デイリーパズル';

  @override
  String widgetLockedSmall(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'レベル$levelStringクリアで開放';
  }

  @override
  String widgetLockedMedium(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'はじめてのデイリーパズルは、レベル$levelStringクリアで開放されます。';
  }

  @override
  String widgetReadySemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Nestyのデイリーパズル。$countString日連続。今日のパズルの準備ができました。';
  }

  @override
  String widgetSolvedSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Nestyのデイリーパズル。$countString日連続、炎がともっています。今日のパズルはクリア済みです。';
  }

  @override
  String widgetPausedSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Nestyのデイリーパズル。$countString日連続、お休み中。今日のパズルの準備ができました。';
  }

  @override
  String get widgetZeroSemantics => 'Nestyのデイリーパズル。今日のパズルの準備ができました。';

  @override
  String widgetLockedSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Nestyのデイリーパズル。レベル$levelStringクリアで開放されます。';
  }

  @override
  String dailyFreezesShort(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString';
  }
}
