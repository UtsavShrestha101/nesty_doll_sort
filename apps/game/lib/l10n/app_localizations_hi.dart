// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Nesty';

  @override
  String get splashLoading => 'लोड हो रहा है…';

  @override
  String progressPercent(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString';
  }

  @override
  String get genericLoadFailed => 'कुछ गड़बड़ हो गई।';

  @override
  String get splashStorageTitle => 'आपका फ़ोन लगभग भर चुका है';

  @override
  String splashStorageBody(int size) {
    final intl.NumberFormat sizeNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String sizeString = sizeNumberFormat.format(size);

    return 'Nesty को शेल्फ़ सजाने के लिए लगभग $sizeString MB चाहिए। थोड़ी जगह खाली करें, फिर दोबारा कोशिश करें।';
  }

  @override
  String get splashContentTitle => 'शेल्फ़ खुल नहीं पाए';

  @override
  String get splashContentBody =>
      'लोड करते समय कुछ गड़बड़ हो गई। फिर कोशिश करें, या Nesty दोबारा खोलें।';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String levelTitle(int level) {
    return 'लेवल $level';
  }

  @override
  String get pause => 'रोकें';

  @override
  String get boosterUndo => 'वापस';

  @override
  String get boosterUndoShort => 'वापस';

  @override
  String get boosterHint => 'हिंट';

  @override
  String get boosterHintShort => 'हिंट';

  @override
  String get boosterExtraSlot => '+जगह';

  @override
  String get boosterExtraSlotShort => '+1';

  @override
  String get restart => 'फिर से शुरू';

  @override
  String get restartShort => 'फिर से';

  @override
  String get splashDollSort => 'डॉल सॉर्ट';

  @override
  String get splashCaption => 'शेल्फ़ की धूल झाड़ रहे हैं…';

  @override
  String get homePlay => 'खेलें';

  @override
  String get homeAllLevelsDone => 'सब पूरा!';

  @override
  String playSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'लेवल $levelString खेलें';
  }

  @override
  String playLevelSemantics(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'लेवल $levelString खेलें, $tier';
  }

  @override
  String coinPillShopSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString सिक्के। दुकान खुलती है।',
      one: '$countString सिक्का। दुकान खुलती है।',
    );
    return '$_temp0';
  }

  @override
  String get tierHard => 'कठिन';

  @override
  String get tierSuperHard => 'बहुत कठिन';

  @override
  String get tierSuperShort => 'सुपर';

  @override
  String tierName(String tier) {
    String _temp0 = intl.Intl.selectLogic(tier, {
      'easy': 'आसान',
      'medium': 'मध्यम',
      'hard': 'कठिन',
      'superhard': 'बहुत कठिन',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String levelWithTier(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'लेवल $levelString · $tier';
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
      other: '$totalString में से $countString परिवार पूरे',
      one: '$totalString में से $countString परिवार पूरा',
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
      other: '$countString सिक्के',
      one: '$countString सिक्का',
    );
    return '$_temp0';
  }

  @override
  String get levelDaily => 'रोज़ की पहेली';

  @override
  String levelDailySemantics(String date) {
    return 'रोज़ की पहेली, $date';
  }

  @override
  String bonusLevelTitle(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'बोनस लेवल $levelString';
  }

  @override
  String get closeSemantics => 'बंद करें';

  @override
  String get backSemantics => 'वापस जाएं';

  @override
  String boosterAdSemantics(String booster) {
    return '$booster, वीडियो देखें';
  }

  @override
  String boosterCoinSemantics(String booster, int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$booster, $priceString सिक्के',
      one: '$booster, $priceString सिक्का',
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
      other: 'वापस, $countString उपलब्ध',
      one: 'वापस, $countString उपलब्ध',
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
      other: 'हिंट, $countString उपलब्ध',
      one: 'हिंट, $countString उपलब्ध',
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
      other: 'अतिरिक्त जगह, $countString उपलब्ध',
      one: 'अतिरिक्त जगह, $countString उपलब्ध',
    );
    return '$_temp0';
  }

  @override
  String get softStuckTitle => 'हम्म, लगता है अटक गए';

  @override
  String get softStuckBody => 'चाल वापस लेकर देखें? आप खेलते भी रह सकते हैं।';

  @override
  String get softStuckBodyRestart =>
      'फिर से शुरू करके देखें? आप खेलते भी रह सकते हैं।';

  @override
  String get softStuckAction => 'वापस';

  @override
  String get oomTitle => 'कोई चाल नहीं बची!';

  @override
  String get oomSubtitle => 'आगे सजाने का तरीका चुनें।';

  @override
  String get oomUndoSubtitle => 'पिछली चाल वापस लें';

  @override
  String oomUndoFree(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'मुफ़्त · $countString उपलब्ध',
      one: 'मुफ़्त · $countString उपलब्ध',
    );
    return '$_temp0';
  }

  @override
  String get oomSlotTitle => '+1 जगह';

  @override
  String get oomSlotSubtitle => 'इस लेवल के लिए एक जगह और जोड़ें';

  @override
  String get oomSlotOffline => 'ऑफ़लाइन में सिर्फ़ सिक्कों से';

  @override
  String get oomRestartSubtitle => 'इस लेवल को मुफ़्त में नए सिरे से शुरू करें';

  @override
  String coinPrice(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString सिक्के',
      one: '$countString सिक्का',
    );
    return '$_temp0';
  }

  @override
  String get watchAd => 'विज्ञापन देखें';

  @override
  String get watchAdSemantics => 'एक विज्ञापन देखें';

  @override
  String get offlineTitle => 'ऑफ़लाइन';

  @override
  String get offlineAds => 'विज्ञापन के बटन सिक्कों की कीमत दिखाएंगे';

  @override
  String get connectToWatchAd => 'विज्ञापन देखने के लिए इंटरनेट से जुड़ें';

  @override
  String get winTitle => 'लेवल पूरा!';

  @override
  String get winTitleShort => 'पूरा!';

  @override
  String get winContinue => 'आगे बढ़ें';

  @override
  String get winTripleCoins => '×3 सिक्के';

  @override
  String get winRewardAdded => 'इनाम जुड़ गया';

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

    return 'अध्याय $numberString';
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
    return 'अगला: $name';
  }

  @override
  String get winChapterDone => 'अध्याय पूरा! अब आपका इनाम।';

  @override
  String figurineName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'क्लासिक परिवार',
      'sailor': 'नाविक परिवार',
      'baker': 'बेकर परिवार',
      'astronaut': 'अंतरिक्ष यात्री परिवार',
      'gardener': 'माली परिवार',
      'snow': 'स्नो परिवार',
      'circus': 'सर्कस परिवार',
      'musician': 'संगीतकार परिवार',
      'royal': 'शाही परिवार',
      'explorer': 'खोजी परिवार',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String chapterRibbon(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'अध्याय $numberString · $name';
  }

  @override
  String chapterRibbonShort(String name) {
    return '$name';
  }

  @override
  String chapterName(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'ch01': 'धूप वाली खिलौना दुकान',
      'ch02': 'बारिश वाला कैफ़े कोना',
      'ch03': 'समुद्र किनारे का बाज़ार',
      'ch04': 'बर्फ़ीला केबिन',
      'ch05': 'रात का कार्निवल',
      'ch06': 'वसंत के बगीचे का शेड',
      'ch07': 'कठपुतली थिएटर',
      'ch08': 'पतझड़ का बैंडस्टैंड',
      'ch09': 'किले की लाइब्रेरी',
      'ch10': 'सूर्योदय का नज़ारा',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get pauseTitle => 'रुका हुआ';

  @override
  String get resume => 'जारी रखें';

  @override
  String get home => 'होम';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get settingSound => 'आवाज़';

  @override
  String get settingMusic => 'संगीत';

  @override
  String get settingHaptics => 'कंपन';

  @override
  String get allLevelsTitle => 'आपने सारे लेवल पूरे कर लिए!';

  @override
  String get allLevelsBody => 'नए अध्याय आने वाले हैं — तब तक बोनस लेवल खेलें।';

  @override
  String allLevelsPlayBonus(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'बोनस लेवल $numberString खेलें';
  }

  @override
  String get allLevelsBackHome => 'होम पर वापस';

  @override
  String get nextLevelFailedHome => 'होम पर वापस';

  @override
  String get gameplayFailedTitle => 'शेल्फ़ को ज़रा समय चाहिए';

  @override
  String get gameplayFailedBody =>
      'यह लेवल तैयार नहीं हो पाया। फिर कोशिश करें, या होम पर लौटें।';

  @override
  String get devLevelPickerTitle => 'किसी लेवल पर जाएं';

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

    return 'अध्याय $numberString · लेवल $startString–$endString';
  }

  @override
  String get navShop => 'दुकान';

  @override
  String get navHomeShort => 'होम';

  @override
  String get navShopShort => 'दुकान';

  @override
  String get navMuseum => 'संग्रहालय';

  @override
  String get navMuseumShort => 'संग्रहालय';

  @override
  String get homeDailyTile => 'रोज़ की पहेली';

  @override
  String get homeMuseumTile => 'संग्रहालय';

  @override
  String get homeRemoveAdsTile => 'विज्ञापन हटाएं';

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

    return 'लेवल $levelString के बाद';
  }

  @override
  String get homeBonusBadge => 'बोनस';

  @override
  String get homeBonusKicker => 'अनंत बोनस';

  @override
  String get homeBonusName => 'बोनस लेवल';

  @override
  String streakBadgeSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString दिन की स्ट्रीक',
      one: '$countString दिन की स्ट्रीक',
    );
    return '$_temp0';
  }

  @override
  String get settingColorSymbols => 'रंग के चिह्न';

  @override
  String get symbolsSubtle => 'हल्के';

  @override
  String get symbolsLarge => 'बड़े';

  @override
  String get settingLanguage => 'भाषा';

  @override
  String get settingRestorePurchases => 'खरीदारी वापस पाएं';

  @override
  String get settingPrivacyChoices => 'गोपनीयता विकल्प';

  @override
  String get settingPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get settingSupport => 'सहायता';

  @override
  String get settingSupportValue => 'हमें ईमेल करें';

  @override
  String settingsFooter(String version, String build, String playerId) {
    return 'Nesty: Doll Sort · v$version (बिल्ड $build) · प्लेयर ID $playerId';
  }

  @override
  String get languageSheetTitle => 'भाषा';

  @override
  String get languageSheetDone => 'हो गया';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'अंग्रेज़ी',
      'es': 'स्पेनिश',
      'pt_BR': 'पुर्तगाली',
      'id': 'इंडोनेशियाई',
      'hi': 'हिंदी',
      'de': 'जर्मन',
      'fr': 'फ़्रेंच',
      'tr': 'तुर्की',
      'ja': 'जापानी',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String a11yJoinList(String first, String second) {
    return '$first, $second';
  }

  @override
  String a11yJoinSentences(String first, String second) {
    return '$first। $second';
  }

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
      other: '$countString दिन',
      one: '$countString दिन',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakKeep => 'स्ट्रीक बढ़ाने के लिए आज खेलें';

  @override
  String get dailyStreakStart =>
      'अपनी पहली लौ जलाने के लिए आज की पहेली हल करें।';

  @override
  String get dailyStreakDone => 'आपकी लौ जल रही है। कल मिलते हैं।';

  @override
  String get dailyStreakWeek => 'पूरा एक हफ़्ता!';

  @override
  String dailyFreezes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString फ़्रीज़',
      one: '$countString फ़्रीज़',
      zero: 'कोई फ़्रीज़ नहीं',
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
      other: '$countString स्ट्रीक फ़्रीज़',
      one: '$countString स्ट्रीक फ़्रीज़',
    );
    return '$_temp0';
  }

  @override
  String get dailyDay => 'दिन';

  @override
  String get dailyToday => 'आज';

  @override
  String get dailyTomorrow => 'कल';

  @override
  String dailyDaySemantics(String state, int day) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'done': 'दिन $day, पूरा',
      'today': 'आज, दिन $day',
      'tomorrow': 'कल, दिन $day',
      'chest': 'दिन $day, संदूक',
      'other': 'दिन $day',
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
      other: 'खेलें, $countString सिक्के',
      one: 'खेलें, $countString सिक्का',
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
      other: 'दिन 7 का संदूक · $countString सिक्के',
      one: 'दिन 7 का संदूक · $countString सिक्का',
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
      other: '$countString दिन और',
      one: '$countString दिन और',
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
      other: 'आज को मिलाकर $countString दिन और',
      one: 'आज को मिलाकर $countString दिन और',
    );
    return '$_temp0';
  }

  @override
  String get dailyChestOpenedToday => 'आज खुल गया';

  @override
  String dailyPuzzleTitle(String weekday) {
    return '$weekday की पहेली';
  }

  @override
  String dailyPuzzleInfo(int colors, String tier) {
    final intl.NumberFormat colorsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String colorsString = colorsNumberFormat.format(colors);

    String _temp0 = intl.Intl.pluralLogic(
      colors,
      locale: localeName,
      other: '$colorsString रंग',
      one: '$colorsString रंग',
    );
    return '$_temp0 · $tier';
  }

  @override
  String get dailyPlay => 'खेलें';

  @override
  String dailySolvedChip(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return 'हल हुआ · +$coinsString';
  }

  @override
  String dailyNextPuzzle(String time) {
    return 'अगली पहेली $time में';
  }

  @override
  String dailyCountdown(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString घं $minutesString मि';
  }

  @override
  String playLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'लेवल $levelString खेलें';
  }

  @override
  String get dailySavedTitle => 'एक फ़्रीज़ ने आपकी लौ जलाए रखी।';

  @override
  String dailySavedBody(String weekday) {
    return '$weekday को एक फ़्रीज़ ने संभाल लिया। अगले हफ़्ते आपको नया मिलेगा।';
  }

  @override
  String get dailyChestTitle => '7 दिन की स्ट्रीक!';

  @override
  String get dailyChestBody => 'लगातार सात दिन। देखें अंदर क्या है।';

  @override
  String get dailyChestDouble => 'दोगुना करें';

  @override
  String get dailyChestCollect => 'लें';

  @override
  String get dailyWinTitle => 'रोज़ की पहेली हल!';

  @override
  String dailyWinStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString दिन की स्ट्रीक';
  }

  @override
  String dailyWinChestHint(String count) {
    String _temp0 = intl.Intl.selectLogic(count, {
      '0': 'आपका दिन 7 का संदूक तैयार है!',
      '1': 'दिन 7 के संदूक तक बस एक दिन और',
      '2': 'दिन 7 के संदूक तक दो दिन और',
      '3': 'दिन 7 के संदूक तक तीन दिन और',
      '4': 'दिन 7 के संदूक तक चार दिन और',
      '5': 'दिन 7 के संदूक तक पाँच दिन और',
      '6': 'दिन 7 के संदूक तक छह दिन और',
      'other': 'दिन 7 के संदूक तक $count दिन और',
    });
    return '$_temp0';
  }

  @override
  String get dailyBackToDaily => 'रोज़ की पहेली पर वापस';

  @override
  String get museumTitle => 'संग्रहालय';

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
      other: 'अध्याय $chapterString · $countString लेवल और',
      one: 'अध्याय $chapterString · $countString लेवल और',
    );
    return '$_temp0';
  }

  @override
  String get museumAllHome => 'हर परिवार घर पहुंच गया।';

  @override
  String get museumNextFamily => 'अगला परिवार';

  @override
  String get museumNextFamilyKicker => 'अगला परिवार';

  @override
  String museumFamilyLabel(String name) {
    return '$name परिवार';
  }

  @override
  String museumSoonLabel(String name) {
    return '$name · आने वाला';
  }

  @override
  String figurineShortName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'क्लासिक',
      'sailor': 'नाविक',
      'baker': 'बेकर',
      'astronaut': 'अंतरिक्ष यात्री',
      'gardener': 'माली',
      'snow': 'स्नो',
      'circus': 'सर्कस',
      'musician': 'संगीतकार',
      'royal': 'शाही',
      'explorer': 'खोजी',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String figurineFlavor(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': '“सबसे छोटी गुड़िया छुपन-छुपाई हमेशा जीतती है।”',
      'sailor':
          '“वे सबसे छोटी गुड़िया में एक सीपी रखते हैं, क्या पता कब काम आ जाए।”',
      'baker':
          '“वे हर ब्रेड चार साइज़ में बेक करते हैं, ताकि किसी को बांटना न पड़े।”',
      'astronaut':
          '“चांद की हर यात्रा से पहले वे सबसे बड़ी से सबसे छोटी तक गिनती करते हैं।”',
      'gardener':
          '“हर टोपी के नीचे एक बीज छुपा है, जो वे वसंत के लिए रख रहे हैं।”',
      'snow': '“जब कोई नहीं देखता, वे एक-दूसरे पर चढ़कर स्नोमैन बन जाते हैं।”',
      'circus':
          '“उनका सबसे बढ़िया करतब है एक-दूसरे के अंदर चढ़ना, और खूब तालियां मिलती हैं।”',
      'musician':
          '“वे एक ही गाना चार साइज़ में बजाते हैं। ऊंचे सुर सबसे छोटी के हिस्से आते हैं।”',
      'royal': '“हर ताज अगले ताज के अंदर आ जाता है, इससे बहुत जगह बचती है।”',
      'explorer':
          '“उन्होंने दुकान की हर शेल्फ़ का नक्शा बना लिया है, और अभी जारी है।”',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String museumChapterChip(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'अध्याय $numberString · $name';
  }

  @override
  String museumCollectedOn(String date) {
    return 'मिला · $date';
  }

  @override
  String get museumCollected => 'मिल गया';

  @override
  String museumLockedText(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'इस परिवार को घर लाने के लिए अध्याय $numberString पूरा करें।';
  }

  @override
  String museumIntro(int levels) {
    final intl.NumberFormat levelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelsString = levelsNumberFormat.format(levels);

    return 'हर अध्याय का एक गुड़िया परिवार है। उसके सभी $levelsString लेवल जीतें और उस परिवार को घर लाएं।';
  }

  @override
  String museumLevelsToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString लेवल और',
      one: '$countString लेवल और',
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
      other: '$countString और',
      one: '$countString और',
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

    return 'अ.$chapterString · $firstString–$lastString';
  }

  @override
  String museumLockedLine1(int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'अध्याय $chapterString';
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

    return 'लेवल $firstString–$lastString';
  }

  @override
  String get shopTitle => 'दुकान';

  @override
  String get shopTabCoins => 'सिक्के';

  @override
  String get shopTabSkins => 'स्किन';

  @override
  String get shopTabThemes => 'थीम';

  @override
  String get shopTabNoAds => 'बिना विज्ञापन';

  @override
  String get shopEquipped => 'लगा हुआ';

  @override
  String get shopEquip => 'लगाएं';

  @override
  String get skinOwnedSemantics => 'आपके पास है';

  @override
  String skinName(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'क्लासिक',
      'space': 'अंतरिक्ष',
      'ocean': 'समुद्र',
      'sweets': 'मिठाई',
      'forest': 'जंगल के दोस्त',
      'winter': 'सर्दी',
      'forest_bear': 'जंगल का भालू',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String skinDescription(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'रंगे हुए फूल, सुनहरे बिंदु और एक छोटा-सा फ़ीता।',
      'ocean': 'नाविक कॉलर, नन्हे लंगर और लहरों की किनारी।',
      'space': 'गोल हेलमेट, नन्हे एंटीना और छल्लेदार ग्रह।',
      'sweets': 'क्रीम की बूंदें, स्प्रिंकल और कैंडी की धारियां।',
      'forest': 'नुकीले कान, मोती जड़े हुड और गिरते पत्ते।',
      'winter': 'पोमपोम वाली टोपियां, बर्फ़ के फाहे और मोती-सी किनारी।',
      'forest_bear': 'गोल भालू कान, आरामदायक हुड और पत्तों में बलूत के फल।',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get skinDetailTitle => 'स्किन';

  @override
  String get skinDetailColors => 'सभी 11 रंग · चिह्न बरकरार';

  @override
  String get skinDetailSizes =>
      'हर साइज़ एक जैसे अंदर जाता है। बस रंग-रोगन बदलता है।';

  @override
  String get shopBuy => 'खरीदें';

  @override
  String shopBuySemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'खरीदें, $countString सिक्के',
      one: 'खरीदें, $countString सिक्का',
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
      other: 'आपके पास $countString सिक्के हैं',
      one: 'आपके पास $countString सिक्का है',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsTitle => 'कुछ और सिक्के चाहिए';

  @override
  String notEnoughCoinsNeeded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString सिक्के और चाहिए',
      one: '$countString सिक्का और चाहिए',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsSource =>
      'सिक्के लेवल जीतने, रोज़ की पहेली और संदूक से मिलते हैं।';

  @override
  String get notEnoughCoinsGoToShop => 'दुकान पर जाएं';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String shopDownloading(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'डाउनलोड हो रहा है $percentString%';
  }

  @override
  String get themesMatchTitle => 'हर अध्याय से मिलाएं';

  @override
  String get themesMatchSubtitle => 'आप जिस अध्याय में हैं, उसकी थीम लगती है';

  @override
  String get themeInUse => 'इस्तेमाल में';

  @override
  String get themeUse => 'लगाएं';

  @override
  String themeChapterLock(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'अ.$numberString';
  }

  @override
  String get shopClosedTitle => 'फ़िलहाल दुकान बंद है';

  @override
  String get shopClosedBody =>
      'सिक्कों के पैक और विज्ञापन हटाने का विकल्प अगले अपडेट में आएंगे।';

  @override
  String buyUndoText(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'आपके $countString मुफ़्त वापस इस्तेमाल हो चुके हैं। एक और चाल वापस लें।',
      one:
          'आपका $countString मुफ़्त वापस इस्तेमाल हो चुका है। एक और चाल वापस लें।',
    );
    return '$_temp0';
  }

  @override
  String get buyHintText => 'आपकी अगली सबसे अच्छी चाल दिखाता है।';

  @override
  String get buySlotText => 'इस लेवल के लिए एक खाली जगह जोड़ता है।';

  @override
  String get tutorialStep1Title => 'छोटी गुड़िया पर टैप करें';

  @override
  String tutorialStepChip(int step, int total) {
    return 'स्टेप $step / $total';
  }

  @override
  String get tutorialStep1Text =>
      'गुड़िया उसी रंग की एक साइज़ बड़ी गुड़िया के अंदर जाती है।';

  @override
  String get tutorialStep2Title => 'अब बड़ी वाली पर टैप करें';

  @override
  String get tutorialStep2Text => 'छोटी गुड़िया खट से अंदर गिर जाती है।';

  @override
  String get tutorialStep3Title => 'परिवार पूरा करें';

  @override
  String get tutorialStep3Text =>
      'आखिरी गुड़िया अंदर रखें। हर साइज़ अंदर जाने पर परिवार पूरा होता है।';

  @override
  String tutorialStepSemantics(int step, String title) {
    final intl.NumberFormat stepNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String stepString = stepNumberFormat.format(step);

    return 'स्टेप $stepString / 3। $title';
  }

  @override
  String get tutorialSwallowChip => 'नई चाल';

  @override
  String get tutorialSwallowTitle => 'बड़ी गुड़िया छोटी को निगल सकती है';

  @override
  String get tutorialSwallowText =>
      'बड़ी गुड़िया को अगले छोटे साइज़ पर रखें, वह उसे पूरा ढक लेगी।';

  @override
  String get introNew => 'नया';

  @override
  String get introTowersTitle => 'टावर!';

  @override
  String get introTowersText =>
      'सिर्फ़ ऊपर वाली गुड़िया हिल सकती है। उसे हटाएं तो नीचे छुपी गुड़िया दिखेगी।';

  @override
  String get introGlassTitle => 'काँच के बक्से';

  @override
  String get introGlassText =>
      'ताले वाली गुड़िया तब छूटती है, जब ताले पर बना परिवार पूरा हो जाए।';

  @override
  String get introIceTitle => 'बर्फ़';

  @override
  String get introIceText =>
      'हर पूरा परिवार बर्फ़ को तोड़ता है। शून्य होने पर गुड़िया आज़ाद हो जाती है।';

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
  String get introGotIt => 'ठीक है';

  @override
  String chapterCompleteTitle(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'अध्याय $numberString पूरा';
  }

  @override
  String get chapterCompleteAdded => 'आपके संग्रहालय में जुड़ गया!';

  @override
  String chapterCompleteCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString सिक्के';
  }

  @override
  String chapterCompleteNext(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'अगला: अध्याय $numberString · $name';
  }

  @override
  String get gameplayGenerating => 'शेल्फ़ सजा रहे हैं…';

  @override
  String dailyStreakPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'आपकी $countString दिन की स्ट्रीक आराम कर रही है। उसे फिर जलाने के लिए आज की पहेली हल करें।';
  }

  @override
  String get dailyStreakPausedChip => 'रुकी';

  @override
  String get dailyStreakRelitTitle => 'स्ट्रीक फिर जली!';

  @override
  String dailyStreakRelitBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'आपकी $countString दिन की स्ट्रीक फिर चमक रही है।';
  }

  @override
  String streakBadgeSemanticsPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString दिन की स्ट्रीक, रुकी हुई',
      one: '$countString दिन की स्ट्रीक, रुकी हुई',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => 'अध्याय';

  @override
  String chaptersOverallProgress(int level, int total) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalString में से लेवल $levelString';
  }

  @override
  String chaptersWonCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString जीते',
      one: '$countString जीता',
    );
    return '$_temp0';
  }

  @override
  String chaptersBestMoves(int best) {
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'सबसे अच्छा $bestString';
  }

  @override
  String get chaptersLevelPlay => 'खेलें';

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
      other:
          'लेवल $levelString, $countString सितारे। सबसे अच्छा: $bestString चालें।',
      one:
          'लेवल $levelString, $countString सितारा। सबसे अच्छा: $bestString चालें।',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsWonNoBest(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'लेवल $levelString, जीता';
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
      other: 'लेवल $levelString, जीता। सबसे अच्छा: $bestString चालें।',
      one: 'लेवल $levelString, जीता। सबसे अच्छा: $bestString चाल।',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsCurrent(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'लेवल $levelString, अगला खेलने के लिए';
  }

  @override
  String chaptersLevelSemanticsLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'लेवल $levelString, बंद';
  }

  @override
  String get recordsTitle => 'रिकॉर्ड';

  @override
  String get homeRecordsButton => 'रिकॉर्ड';

  @override
  String get recordsLevelsWon => 'जीते हुए लेवल';

  @override
  String get recordsFamilies => 'पूरे किए परिवार';

  @override
  String get recordsRacesHeader => 'जीती हुई रेस';

  @override
  String get recordsDolls => 'अंदर रखी गुड़ियाँ';

  @override
  String get recordsDailies => 'हल की गई रोज़ की पहेलियाँ';

  @override
  String get recordsLongestStreak => 'सबसे लंबी स्ट्रीक';

  @override
  String get recordsBestMovesLink => 'हर लेवल की सबसे अच्छी चालें';

  @override
  String get recordsBadgesHeader => 'बैज';

  @override
  String badgeName(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'गुड़िया-सी फिट',
      'glass_breaker': 'काँच का कमाल',
      'ice_melter': 'बर्फ़ तोड़ू',
      'tall_order': 'ऊँची चुनौती',
      'grand_nest': 'परत-दर-परत',
      'level_100': 'आधा रास्ता',
      'level_200': 'सबसे ऊपरी शेल्फ़',
      'dailies_7': 'पहेली का साथी',
      'dailies_30': 'पुराना दोस्त',
      'first_race': 'शेल्फ़ पर सबसे पहले',
      'all_rivals': 'सब प्रतिद्वंद्वी पार',
      'museum_full': 'भरा-पूरा घर',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeLine(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'आपने अपना पहला परिवार पूरा किया।',
      'glass_breaker': 'आपने पहला काँच का बक्सा खोला।',
      'ice_melter': 'आपने एक गुड़िया को बर्फ़ से आज़ाद किया।',
      'tall_order': 'आपने साइज़-5 गुड़ियों वाला लेवल जीता।',
      'grand_nest': 'आपने साइज़-6 गुड़ियों वाला लेवल जीता।',
      'level_100': 'आपने लेवल 100 जीता।',
      'level_200': 'आपने लेवल 200 जीता, जो सबसे आखिरी है।',
      'dailies_7': 'आपने 7 रोज़ की पहेलियाँ हल कीं।',
      'dailies_30': 'आपने 30 रोज़ की पहेलियाँ हल कीं।',
      'first_race': 'आपने रेस में कंप्यूटर को हराया।',
      'all_rivals': 'आपने हर कंप्यूटर प्रतिद्वंद्वी को हराया।',
      'museum_full': 'आपके संग्रहालय में हर परिवार घर पहुंच गया।',
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
      'first_family': 'एक पूरा परिवार अंदर रखें।',
      'glass_breaker': 'एक काँच का बक्सा खोलें।',
      'ice_melter': 'एक गुड़िया को बर्फ़ से आज़ाद करें।',
      'tall_order': 'साइज़-5 गुड़ियों वाला लेवल जीतें।',
      'grand_nest': 'साइज़-6 गुड़ियों वाला लेवल जीतें।',
      'level_100': 'लेवल $levelString जीतें।',
      'level_200': 'लेवल $levelString जीतें।',
      'dailies_7': '$countString रोज़ की पहेलियाँ हल करें।',
      'dailies_30': '$countString रोज़ की पहेलियाँ हल करें।',
      'first_race': 'रेस में कंप्यूटर को हराएं।',
      'all_rivals': 'हर कंप्यूटर प्रतिद्वंद्वी को हराएं।',
      'museum_full': 'हर परिवार को अपने संग्रहालय में घर लाएं।',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeSemanticsEarned(String badge) {
    return '$badge, मिल गया';
  }

  @override
  String badgeSemanticsLocked(String badge, String how) {
    return '$badge, अभी नहीं मिला। $how';
  }

  @override
  String badgeEarnedToastTitle(String badge) {
    return 'बैज मिला · $badge';
  }

  @override
  String get badgeLockedLine => 'अभी नहीं मिला';

  @override
  String winMovesBest(int moves, int best) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'चालें $movesString · सबसे अच्छा $bestString';
  }

  @override
  String winMovesOnly(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return 'चालें $movesString';
  }

  @override
  String winChestCountdown(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'संदूक तक $countString लेवल',
      one: 'संदूक तक $countString लेवल',
    );
    return '$_temp0';
  }

  @override
  String get winReplayReason =>
      'यह मज़े के लिए दोबारा खेलना है: सिक्के नए लेवल से मिलते हैं।';

  @override
  String get winBackToChapters => 'अध्यायों पर वापस';

  @override
  String get chestMilestoneTitle => 'उपलब्धि संदूक';

  @override
  String chestMilestoneBody(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'लेवल $levelString तक पहुंचने का संदूक। देखें अंदर क्या है।';
  }

  @override
  String chestMilestoneBodyBonus(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'बोनस लेवल $levelString का संदूक। देखें अंदर क्या है।';
  }

  @override
  String chestContentsCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString सिक्के',
      one: '+$countString सिक्का',
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
      other: '+$countString हिंट',
      one: '+$countString हिंट',
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
      other: '$coinsString सिक्के',
      one: '$coinsString सिक्का',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hints,
      locale: localeName,
      other: '$hintsString हिंट',
      one: '$hintsString हिंट',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String chestSemantics(String contents) {
    return 'संदूक। अंदर: $contents।';
  }

  @override
  String get chestOpen => 'खोलें';

  @override
  String get settingRelaxedMode => 'आराम मोड';

  @override
  String get settingRelaxedModeSubtitle => 'असीमित मुफ़्त वापस';

  @override
  String get relaxedModeOn =>
      'आराम मोड चालू है। जितनी बार चाहें, चाल वापस लें।';

  @override
  String get settingReduceMotion => 'गति कम करें';

  @override
  String get reduceMotionSystem => 'सिस्टम';

  @override
  String get reduceMotionOn => 'चालू';

  @override
  String get reduceMotionOff => 'बंद';

  @override
  String get oomUndoFreeUnlimited => 'मुफ़्त, जितनी बार चाहें';

  @override
  String oomUndoSpent(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आपके $countString मुफ़्त वापस इस्तेमाल हो चुके हैं',
      one: 'आपका $countString मुफ़्त वापस इस्तेमाल हो चुका है',
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
      other: 'एक लेवल में अधिकतम $countString अतिरिक्त जगहें मिलती हैं।',
      one: 'एक लेवल में एक अतिरिक्त जगह की ही सीमा है।',
    );
    return '$_temp0';
  }

  @override
  String get boosterUndoUnlimitedSemantics => 'वापस, असीमित';

  @override
  String get oomUndoFreeChip => 'मुफ़्त';

  @override
  String boosterLimitSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '+जगह, $totalString में से $countString इस्तेमाल हुई';
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
    return '$booster, सुझाया गया';
  }

  @override
  String get boosterRestartSemantics => 'लेवल फिर से शुरू करें';

  @override
  String get homeVsComputerTile => 'कंप्यूटर से मुकाबला';

  @override
  String homeVsComputerLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'लेवल $levelString के बाद';
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
  String get raceSelectTitle => 'कंप्यूटर से मुकाबला';

  @override
  String get raceSelectSubtitle => 'उसी पहेली पर कंप्यूटर से रेस करें';

  @override
  String get raceComputerTag => 'कंप्यूटर';

  @override
  String raceRivalName(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'धूमकेतु',
      two: 'बटन',
      one: 'कंकड़',
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
      other: 'ज़िंदादिल चाल, सलीकेदार खेल, पकड़ना मुश्किल।',
      two: 'हर चाल को दो बार परखना, फिर चलना।',
      one: 'आराम से, हर गुड़िया का मज़ा लेते हुए।',
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
      other: 'फुर्तीली चाल',
      two: 'एक-सी चाल',
      one: 'आराम की चाल',
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
      other: '$coinsString सिक्के जीतें',
      one: '$coinsString सिक्का जीतें',
    );
    return '$_temp0';
  }

  @override
  String raceRivalLocked(String rival) {
    return 'अनलॉक करने के लिए $rival को हराएं';
  }

  @override
  String get raceRivalNew => 'नया';

  @override
  String raceRivalSemantics(String name) {
    return '$name, कंप्यूटर';
  }

  @override
  String raceRivalCardSemantics(String rival, String skill) {
    return '$rival, कंप्यूटर प्रतिद्वंद्वी। $skill।';
  }

  @override
  String raceRivalLockedSemantics(String rival) {
    return 'बंद कंप्यूटर प्रतिद्वंद्वी। अनलॉक करने के लिए $rival को हराएं।';
  }

  @override
  String get raceRivalSelectedSemantics => 'चुना हुआ';

  @override
  String get raceStart => 'शुरू करें';

  @override
  String get raceStartHint =>
      'वही पहेली, दो बोर्ड। हर परिवार सबसे पहले पूरा करें।';

  @override
  String get raceStripReady => 'आप तैयार हों तब';

  @override
  String get raceStripThinking => 'सोच-विचार जारी…';

  @override
  String get raceStripStartingOver => 'फिर से शुरू';

  @override
  String get raceStripFinished => 'पूरा';

  @override
  String get raceStripPlayerFinished => 'आपने सबसे पहले पूरा किया';

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
      other: '$name, कंप्यूटर: $totalString में से $countString परिवार',
      one: '$name, कंप्यूटर: $totalString में से $countString परिवार',
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

    return 'कंप्यूटर ने एक परिवार पूरा किया: $totalString में से $doneString';
  }

  @override
  String raceAnnounceStart(String rival) {
    return '$rival के खिलाफ़ रेस शुरू हुई, जो एक कंप्यूटर खिलाड़ी है।';
  }

  @override
  String get raceAnnounceStartingOver => 'कंप्यूटर फिर से शुरू कर रहा है।';

  @override
  String get raceAnnounceFinished => 'कंप्यूटर ने हर परिवार पूरा कर लिया।';

  @override
  String get raceAnnounceWon => 'आपने रेस जीत ली।';

  @override
  String get raceAnnounceLost => 'कंप्यूटर ने पहले पूरा किया।';

  @override
  String get raceWinTitle => 'आपने रेस जीत ली!';

  @override
  String get raceWinTitleShort => 'आप जीते!';

  @override
  String raceWinBody(String rival) {
    return 'हर परिवार पूरा हो गया। $rival का काम जारी था।';
  }

  @override
  String raceWinCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString सिक्के',
      one: '+$countString सिक्का',
    );
    return '$_temp0';
  }

  @override
  String get raceLossTitle => 'बहुत करीब! फिर से मुकाबला?';

  @override
  String get raceLossTitleShort => 'बहुत करीब!';

  @override
  String raceLossBody(String rival) {
    return 'इस बार $rival ने पहले पूरा किया। फिर से मुकाबला मुफ़्त है।';
  }

  @override
  String get raceRivalUnlockedTitle => 'नया प्रतिद्वंद्वी अनलॉक!';

  @override
  String raceRivalUnlockedBody(String rival) {
    return '$rival रेस के लिए तैयार है।';
  }

  @override
  String raceRivalUnlockedRace(String rival) {
    return '$rival से रेस करें';
  }

  @override
  String get raceLeaveTitle => 'यह रेस छोड़ें?';

  @override
  String get raceLeaveBody =>
      'रेस यहीं रुक जाएगी। कोई सिक्का नहीं मिलेगा, और बाकी सब आपके पास रहेगा।';

  @override
  String get raceLeaveKeep => 'रेस जारी रखें';

  @override
  String get raceRematch => 'फिर से मुकाबला';

  @override
  String get raceNewRace => 'नई रेस';

  @override
  String get raceBackToRivals => 'रेस पर वापस';

  @override
  String get raceFailedTitle => 'शेल्फ़ को ज़रा समय चाहिए';

  @override
  String get raceFailedBody =>
      'यह रेस तैयार नहीं हो पाई। फिर कोशिश करें, या कोई और रेस चुनें।';

  @override
  String racePauseSubtitle(String rival) {
    return '$rival की रेस भी रुकी है।';
  }

  @override
  String racePauseHeader(String rival) {
    return 'कंप्यूटर से मुकाबला · $rival';
  }

  @override
  String get raceRivalBeaten => 'हराया';

  @override
  String raceStartFor(String rival) {
    return '$rival के खिलाफ़ रेस शुरू करें';
  }

  @override
  String get raceQuit => 'रेस छोड़ें';

  @override
  String starsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '3 में से $count सितारे',
      one: '3 में से $count सितारा',
    );
    return '$_temp0';
  }

  @override
  String starsNewBestSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'नया रिकॉर्ड, 3 में से $count सितारे',
      one: 'नया रिकॉर्ड, 3 में से $count सितारा',
    );
    return '$_temp0';
  }

  @override
  String winStarsTarget(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return '$movesString या कम चालों में 3 सितारे';
  }

  @override
  String get winStarsNewBest => 'नया रिकॉर्ड!';

  @override
  String get starsFirstTip =>
      'कम चालों में ज़्यादा सितारे मिलते हैं। अध्यायों से कोई भी लेवल दोबारा खेलें।';

  @override
  String get starsHelperNote =>
      'हिंट या अतिरिक्त जगह के साथ जीत पर ज़्यादा से ज़्यादा 2 सितारे मिलते हैं।';

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
  String get chaptersAllThreeStars => 'हर लेवल पर 3 सितारे';

  @override
  String chaptersStarsSemantics(int earned, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      earned,
      locale: localeName,
      other: '$total में से $earned सितारे',
      one: '$total में से $earned सितारा',
    );
    return '$_temp0';
  }

  @override
  String get recordsStars => 'सितारे';

  @override
  String recordsStarsValue(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalString में से $countString';
  }

  @override
  String get dailyShare => 'शेयर करें';

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
  String get dailyShareSemantics => 'आज का नतीजा शेयर करें';

  @override
  String dailyShareText(String date, String glyphs, int moves, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves चालों में हल · दिन $day 🔥',
      one: '$moves चाल में हल · दिन $day 🔥',
    );
    return 'Nesty रोज़ की पहेली · $date\n$glyphs\n$_temp0';
  }

  @override
  String dailyShareTextNoStreak(String date, String glyphs, int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves चालों में हल',
      one: '$moves चाल में हल',
    );
    return 'Nesty रोज़ की पहेली · $date\n$glyphs\n$_temp0';
  }

  @override
  String get reminderOfferTitle => 'कल की पहेली तैयार होने पर सूचना चाहिए?';

  @override
  String get reminderOfferBody =>
      'दिन में एक शांत सूचना, आपके चुने समय पर। इसे सेटिंग्स में बंद कर सकते हैं।';

  @override
  String reminderOfferTime(String time) {
    return 'हर दिन $time';
  }

  @override
  String get reminderOfferChangeTime => 'समय बदलें';

  @override
  String reminderTimeChipSemantics(String time) {
    return 'रिमाइंडर का समय, हर दिन $time। समय बदलें।';
  }

  @override
  String get reminderPickerTitle => 'रिमाइंडर का समय';

  @override
  String get reminderOfferYes => 'हाँ, याद दिलाएं';

  @override
  String get reminderOfferNo => 'नहीं, धन्यवाद';

  @override
  String reminderOfferDone(String time) {
    return 'रिमाइंडर $time के लिए सेट हो गया।';
  }

  @override
  String get reminderOfferDeniedTitle => 'Nesty के लिए सूचनाएं बंद हैं';

  @override
  String reminderOfferDenied(String time) {
    return 'इन्हें फ़ोन की सेटिंग्स में चालू करें, तो आपकी सूचना $time पर आएगी।';
  }

  @override
  String get reminderNotificationTitle => 'Nesty';

  @override
  String get reminderNotificationBody => 'आज की पहेली शेल्फ़ पर है।';

  @override
  String get reminderNotificationBody2 =>
      'एक नई रोज़ की पहेली आपके लिए तैयार है।';

  @override
  String get reminderNotificationBody3 =>
      'नई गुड़ियाँ अंदर जाने को तैयार हैं। आज की पहेली हाज़िर है।';

  @override
  String get reminderChannelName => 'रोज़ की पहेली';

  @override
  String get reminderChannelDescription =>
      'नई रोज़ की पहेली तैयार होने पर दिन में एक सूचना।';

  @override
  String get settingReminder => 'रोज़ का रिमाइंडर';

  @override
  String get settingReminderTime => 'समय';

  @override
  String get settingReminderBlocked => 'फ़ोन की सेटिंग्स में बंद है';

  @override
  String get settingOpenPhoneSettings => 'फ़ोन की सेटिंग्स खोलें';

  @override
  String get settingReminderTurnOff => 'बंद करें';

  @override
  String homeChapterKicker(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'अध्याय $numberString';
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

    return 'अध्याय $chapterString, $name। $totalString में से $countString सितारे। अध्याय खुलते हैं।';
  }

  @override
  String homeBonusCardSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'बोनस लेवल। $totalString में से $countString सितारे। अध्याय खुलते हैं।';
  }

  @override
  String get homeVsComputerSemantics =>
      'कंप्यूटर से मुकाबला। उसी पहेली पर कंप्यूटर से रेस करें।';

  @override
  String homeVsComputerLockedSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'कंप्यूटर से मुकाबला, बंद। लेवल $levelString के बाद।';
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

    return 'अध्याय $numberString · लेवल $firstString–$lastString';
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

    return 'अध्याय $chapterString, $name। $totalString में से $countString सितारे।';
  }

  @override
  String chaptersRowLockedSemantics(int chapter, String name) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'अध्याय $chapterString, $name। बंद।';
  }

  @override
  String get chaptersLevelChestSemantics => 'इस लेवल पर एक संदूक है';

  @override
  String get chaptersLevelFinaleSemantics => 'अध्याय का आखिरी लेवल';

  @override
  String museumNicheCollectedSemantics(String name) {
    return '$name, आपके संग्रहालय में घर पर';
  }

  @override
  String museumNicheNextSemantics(String name, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, घर आने वाला अगला। $countString लेवल और।',
      one: '$name, घर आने वाला अगला। $countString लेवल और।',
    );
    return '$_temp0';
  }

  @override
  String museumNicheLockedSemantics(String name, int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return '$name, अभी घर नहीं पहुंचा। अध्याय $chapterString।';
  }

  @override
  String museumCountSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalString में से $countString परिवार घर पर';
  }

  @override
  String museumFullSub(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'भरा-पूरा घर · सभी $countString परिवार';
  }

  @override
  String recordsRaceSemantics(String rival, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$rival, कंप्यूटर। $countString जीत।',
      one: '$rival, कंप्यूटर। $countString जीत।',
    );
    return '$_temp0';
  }

  @override
  String recordsRaceLockedSemantics(String rival) {
    return '$rival, कंप्यूटर। बंद।';
  }

  @override
  String recordsStatSemantics(String label, String value) {
    return '$label: $value';
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
  String get giftTitle => 'रोज़ का तोहफ़ा';

  @override
  String giftDay(int day) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return 'दिन $dayString';
  }

  @override
  String get giftClaim => 'लें';

  @override
  String get giftClaimedLine => 'आज का तोहफ़ा आपका है।';

  @override
  String giftTomorrow(String gift) {
    return 'कल: $gift';
  }

  @override
  String giftNext(String gift) {
    return 'अगला तोहफ़ा: $gift';
  }

  @override
  String get giftButtonReadySemantics => 'रोज़ का तोहफ़ा। एक तोहफ़ा तैयार है।';

  @override
  String get giftButtonSemantics => 'रोज़ का तोहफ़ा';

  @override
  String giftTileSemantics(int day, String gift, String state) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return 'दिन $dayString, $gift। $state';
  }

  @override
  String get giftTileDone => 'ले लिया';

  @override
  String get giftTileToday => 'आज का तोहफ़ा';

  @override
  String get giftTileLater => 'आने वाला';

  @override
  String get giftChestTitle => 'दिन 7 का तोहफ़ा';

  @override
  String get giftChestBody => 'दिन 7 के लिए एक संदूक। देखें अंदर क्या है।';

  @override
  String giftCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString सिक्के',
      one: '$countString सिक्का',
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
      other: '$countString हिंट',
      one: '$countString हिंट',
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
      other: '$countString अतिरिक्त जगहें',
      one: '$countString अतिरिक्त जगह',
    );
    return '$_temp0';
  }

  @override
  String giftRewardPair(String first, String second) {
    return '$first + $second';
  }

  @override
  String chestContentsSlot(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString जगहें',
      one: '+$countString जगह',
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
      other: '$coinsString सिक्के',
      one: '$coinsString सिक्का',
    );
    String _temp1 = intl.Intl.pluralLogic(
      slots,
      locale: localeName,
      other: '$slotsString अतिरिक्त जगहें',
      one: '$slotsString अतिरिक्त जगह',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get giftSubtitle => 'रोज़ एक तोहफ़ा, आपकी अपनी रफ़्तार से।';

  @override
  String get giftTitleShort => 'तोहफ़े';

  @override
  String get giftChestTitleShort => 'दिन 7';

  @override
  String giftSlotsShort(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString जगहें',
      one: '$countString जगह',
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
    return '$first, $second';
  }

  @override
  String giftA11yClaimed(String gift) {
    return 'तोहफ़ा ले लिया: $gift।';
  }

  @override
  String giftA11yAdded(String gift, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'जोड़ा गया: $gift। कुल $countString।';
  }
}
