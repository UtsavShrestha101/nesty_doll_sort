// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Nesty';

  @override
  String get splashLoading => 'Yükleniyor…';

  @override
  String progressPercent(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString';
  }

  @override
  String get genericLoadFailed => 'Bir şeyler ters gitti.';

  @override
  String get splashStorageTitle => 'Telefonunun hafızası neredeyse dolu';

  @override
  String splashStorageBody(int size) {
    final intl.NumberFormat sizeNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String sizeString = sizeNumberFormat.format(size);

    return 'Nesty’nin rafları kurması için yaklaşık $sizeString MB gerekiyor. Biraz yer aç, sonra tekrar dene.';
  }

  @override
  String get splashContentTitle => 'Raflar kurulamadı';

  @override
  String get splashContentBody =>
      'Yüklenirken bir sorun oldu. Tekrar dene ya da Nesty’yi yeniden başlat.';

  @override
  String get retry => 'Tekrar dene';

  @override
  String levelTitle(int level) {
    return 'Seviye $level';
  }

  @override
  String get pause => 'Duraklat';

  @override
  String get boosterUndo => 'Geri al';

  @override
  String get boosterUndoShort => 'Geri al';

  @override
  String get boosterHint => 'İpucu';

  @override
  String get boosterHintShort => 'İpucu';

  @override
  String get boosterExtraSlot => '+Yuva';

  @override
  String get boosterExtraSlotShort => '+1';

  @override
  String get restart => 'Yeniden başla';

  @override
  String get restartShort => 'Başa dön';

  @override
  String get splashDollSort => 'BEBEK SIRALAMA';

  @override
  String get splashCaption => 'Rafların tozu alınıyor…';

  @override
  String get homePlay => 'OYNA';

  @override
  String get homeAllLevelsDone => 'Hepsi tamamlandı!';

  @override
  String playSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return '$levelString. seviyeyi oyna';
  }

  @override
  String playLevelSemantics(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return '$levelString. seviyeyi oyna, $tier';
  }

  @override
  String coinPillShopSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString altın. Mağazayı açar.',
      one: '$countString altın. Mağazayı açar.',
    );
    return '$_temp0';
  }

  @override
  String get tierHard => 'ZOR';

  @override
  String get tierSuperHard => 'ÇOK ZOR';

  @override
  String get tierSuperShort => 'ÇOK ZOR';

  @override
  String tierName(String tier) {
    String _temp0 = intl.Intl.selectLogic(tier, {
      'easy': 'Kolay',
      'medium': 'Orta',
      'hard': 'Zor',
      'superhard': 'Çok Zor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String levelWithTier(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Seviye $levelString · $tier';
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
      other: '$totalString aileden $countString tamamlandı',
      one: '$totalString aileden $countString tamamlandı',
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
      other: '$countString altın',
      one: '1 altın',
    );
    return '$_temp0';
  }

  @override
  String get levelDaily => 'Günlük';

  @override
  String levelDailySemantics(String date) {
    return 'Günlük bulmaca, $date';
  }

  @override
  String bonusLevelTitle(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Bonus Seviye $levelString';
  }

  @override
  String get closeSemantics => 'Kapat';

  @override
  String get backSemantics => 'Geri';

  @override
  String boosterAdSemantics(String booster) {
    return '$booster, video izle';
  }

  @override
  String boosterCoinSemantics(String booster, int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$booster, $priceString altın',
      one: '$booster, $priceString altın',
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
      other: 'Geri al, $countString hak var',
      one: 'Geri al, $countString hak var',
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
      other: 'İpucu, $countString hak var',
      one: 'İpucu, $countString hak var',
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
      other: 'Ek yuva, $countString hak var',
      one: 'Ek yuva, $countString hak var',
    );
    return '$_temp0';
  }

  @override
  String get softStuckTitle => 'Hmm, sıkışmış gibi görünüyor';

  @override
  String get softStuckBody =>
      'Geri almayı denemek ister misin? Oynamaya devam da edebilirsin.';

  @override
  String get softStuckBodyRestart =>
      'Yeniden başlamayı denemek ister misin? Oynamaya devam da edebilirsin.';

  @override
  String get softStuckAction => 'Geri al';

  @override
  String get oomTitle => 'Hamle kalmadı!';

  @override
  String get oomSubtitle => 'Dizmeye devam etmek için bir yol seç.';

  @override
  String get oomUndoSubtitle => 'Son hamleni geri al';

  @override
  String oomUndoFree(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ücretsiz · $countString hak',
      one: 'Ücretsiz · 1 hak',
    );
    return '$_temp0';
  }

  @override
  String get oomSlotTitle => '+1 Yuva';

  @override
  String get oomSlotSubtitle => 'Bu seviyeye bir yuva ekle';

  @override
  String get oomSlotOffline => 'Çevrimdışıyken yalnızca altınla';

  @override
  String get oomRestartSubtitle => 'Seviyeyi ücretsiz baştan başlat';

  @override
  String coinPrice(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString altın',
      one: '1 altın',
    );
    return '$_temp0';
  }

  @override
  String get watchAd => 'Reklam izle';

  @override
  String get watchAdSemantics => 'Bir reklam izle';

  @override
  String get offlineTitle => 'Çevrimdışı';

  @override
  String get offlineAds => 'Reklam düğmeleri altın fiyatına döner';

  @override
  String get connectToWatchAd => 'Reklam izlemek için bağlan';

  @override
  String get winTitle => 'Seviye Tamamlandı!';

  @override
  String get winTitleShort => 'Tamamlandı!';

  @override
  String get winContinue => 'Devam';

  @override
  String get winTripleCoins => '×3 altın';

  @override
  String get winRewardAdded => 'Ödül eklendi';

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

    return 'Bölüm $numberString';
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
    return 'Sıradaki: $name';
  }

  @override
  String get winChapterDone => 'Bölüm tamamlandı! Ödülün sırada.';

  @override
  String figurineName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'Klasik Aile',
      'sailor': 'Denizci Ailesi',
      'baker': 'Fırıncı Ailesi',
      'astronaut': 'Astronot Ailesi',
      'gardener': 'Bahçıvan Ailesi',
      'snow': 'Kar Ailesi',
      'circus': 'Sirk Ailesi',
      'musician': 'Müzisyen Ailesi',
      'royal': 'Kraliyet Ailesi',
      'explorer': 'Kaşif Ailesi',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String chapterRibbon(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'BÖLÜM $numberString · $name';
  }

  @override
  String chapterRibbonShort(String name) {
    return '$name';
  }

  @override
  String chapterName(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'ch01': 'Güneşli Oyuncak Dükkânı',
      'ch02': 'Yağmurlu Kafe Köşesi',
      'ch03': 'Deniz Kenarı Pazarı',
      'ch04': 'Karlı Kulübe',
      'ch05': 'Gece Karnavalı',
      'ch06': 'Bahar Bahçe Kulübesi',
      'ch07': 'Kukla Tiyatrosu',
      'ch08': 'Sonbahar Müzik Köşkü',
      'ch09': 'Şato Kütüphanesi',
      'ch10': 'Gün Doğumu Seyir Tepesi',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get pauseTitle => 'Duraklatıldı';

  @override
  String get resume => 'Devam et';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get settings => 'Ayarlar';

  @override
  String get settingSound => 'Ses';

  @override
  String get settingMusic => 'Müzik';

  @override
  String get settingHaptics => 'Titreşim';

  @override
  String get allLevelsTitle => 'Tüm seviyeleri bitirdin!';

  @override
  String get allLevelsBody =>
      'Yeni bölümler geliyor — bu arada bonus seviyeleri oyna.';

  @override
  String allLevelsPlayBonus(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return '$numberString. bonus seviyeyi oyna';
  }

  @override
  String get allLevelsBackHome => 'Ana Sayfaya dön';

  @override
  String get nextLevelFailedHome => 'Ana Sayfaya dön';

  @override
  String get gameplayFailedTitle => 'Raflar biraz zaman istiyor';

  @override
  String get gameplayFailedBody =>
      'Bu seviye kurulamadı. Tekrar dene ya da ana sayfaya dön.';

  @override
  String get devLevelPickerTitle => 'Bir seviyeye git';

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

    return 'Bölüm $numberString · Seviye $startString–$endString';
  }

  @override
  String get navShop => 'Mağaza';

  @override
  String get navHomeShort => 'Ana Sayfa';

  @override
  String get navShopShort => 'Mağaza';

  @override
  String get navMuseum => 'Müze';

  @override
  String get navMuseumShort => 'Müze';

  @override
  String get homeDailyTile => 'Günlük Bulmaca';

  @override
  String get homeMuseumTile => 'Müze';

  @override
  String get homeRemoveAdsTile => 'Reklamları Kaldır';

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

    return '$levelString. seviyeden sonra';
  }

  @override
  String get homeBonusBadge => 'BONUS';

  @override
  String get homeBonusKicker => 'SONSUZ BONUS';

  @override
  String get homeBonusName => 'Bonus seviyeler';

  @override
  String streakBadgeSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString günlük seri',
      one: '1 günlük seri',
    );
    return '$_temp0';
  }

  @override
  String get settingColorSymbols => 'Renk simgeleri';

  @override
  String get symbolsSubtle => 'Sade';

  @override
  String get symbolsLarge => 'Büyük';

  @override
  String get settingLanguage => 'Dil';

  @override
  String get settingRestorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String get settingPrivacyChoices => 'Gizlilik tercihleri';

  @override
  String get settingPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get settingSupport => 'Destek';

  @override
  String get settingSupportValue => 'Bize e-posta gönder';

  @override
  String settingsFooter(String version, String build, String playerId) {
    return 'Nesty: Doll Sort · v$version (derleme $build) · Oyuncu Kimliği $playerId';
  }

  @override
  String get languageSheetTitle => 'Dil';

  @override
  String get languageSheetDone => 'Tamam';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'İngilizce',
      'es': 'İspanyolca',
      'pt_BR': 'Portekizce',
      'id': 'Endonezce',
      'hi': 'Hintçe',
      'de': 'Almanca',
      'fr': 'Fransızca',
      'tr': 'Türkçe',
      'ja': 'Japonca',
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
    return '$first. $second';
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
      other: '$countString gün',
      one: '1 gün',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakKeep => 'Bugün oyna, serine bir gün ekle';

  @override
  String get dailyStreakStart =>
      'İlk alevini yakmak için bugünün bulmacasını çöz.';

  @override
  String get dailyStreakDone => 'Alevin yanıyor. Yarın görüşürüz.';

  @override
  String get dailyStreakWeek => 'Koca bir hafta!';

  @override
  String dailyFreezes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString koruma',
      one: '1 koruma',
      zero: 'Koruma yok',
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
      other: '$countString seri koruması',
      one: '$countString seri koruması',
    );
    return '$_temp0';
  }

  @override
  String get dailyDay => 'Gün';

  @override
  String get dailyToday => 'Bugün';

  @override
  String get dailyTomorrow => 'Yarın';

  @override
  String dailyDaySemantics(String state, int day) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'done': '$day. gün, tamamlandı',
      'today': 'Bugün, $day. gün',
      'tomorrow': 'Yarın, $day. gün',
      'chest': '$day. gün, sandık',
      'other': '$day. gün',
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
      other: 'Oyna, $countString altın',
      one: 'Oyna, 1 altın',
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
      other: '7. gün sandığı · $countString altın',
      one: '7. gün sandığı · $countString altın',
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
      other: '$countString gün daha',
      one: '1 gün daha',
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
      other: '$countString gün daha, bugün dahil',
      one: '1 gün daha, bugün dahil',
    );
    return '$_temp0';
  }

  @override
  String get dailyChestOpenedToday => 'Bugün açıldı';

  @override
  String dailyPuzzleTitle(String weekday) {
    return '$weekday bulmacası';
  }

  @override
  String dailyPuzzleInfo(int colors, String tier) {
    final intl.NumberFormat colorsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String colorsString = colorsNumberFormat.format(colors);

    String _temp0 = intl.Intl.pluralLogic(
      colors,
      locale: localeName,
      other: '$colorsString renk',
      one: '1 renk',
    );
    return '$_temp0 · $tier';
  }

  @override
  String get dailyPlay => 'Oyna';

  @override
  String dailySolvedChip(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return 'Çözüldü · +$coinsString';
  }

  @override
  String dailyNextPuzzle(String time) {
    return 'Sonraki bulmaca: $time';
  }

  @override
  String dailyCountdown(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString sa $minutesString dk';
  }

  @override
  String playLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return '$levelString. seviyeyi oyna';
  }

  @override
  String get dailySavedTitle => 'Bir koruma alevini yanık tuttu.';

  @override
  String dailySavedBody(String weekday) {
    return 'Bir koruma $weekday gününü kapsadı. Gelecek hafta yenisini kazanacaksın.';
  }

  @override
  String get dailyChestTitle => '7 günlük seri!';

  @override
  String get dailyChestBody => 'Üst üste yedi gün. İçindekilere bak.';

  @override
  String get dailyChestDouble => 'İkiye katla';

  @override
  String get dailyChestCollect => 'Topla';

  @override
  String get dailyWinTitle => 'Günlük bulmaca çözüldü!';

  @override
  String dailyWinStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString günlük seri';
  }

  @override
  String dailyWinChestHint(String count) {
    String _temp0 = intl.Intl.selectLogic(count, {
      '0': '7. gün sandığın hazır!',
      '1': '7. gün sandığına bir gün daha',
      '2': '7. gün sandığına iki gün daha',
      '3': '7. gün sandığına üç gün daha',
      '4': '7. gün sandığına dört gün daha',
      '5': '7. gün sandığına beş gün daha',
      '6': '7. gün sandığına altı gün daha',
      'other': '7. gün sandığına $count gün daha',
    });
    return '$_temp0';
  }

  @override
  String get dailyBackToDaily => 'Günlük Bulmaca’ya dön';

  @override
  String get museumTitle => 'Müze';

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
      other: 'Bölüm $chapterString · $countString seviye daha',
      one: 'Bölüm $chapterString · 1 seviye daha',
    );
    return '$_temp0';
  }

  @override
  String get museumAllHome => 'Her aile evinde.';

  @override
  String get museumNextFamily => 'Sıradaki aile';

  @override
  String get museumNextFamilyKicker => 'SIRADAKİ AİLE';

  @override
  String museumFamilyLabel(String name) {
    return '$name Ailesi';
  }

  @override
  String museumSoonLabel(String name) {
    return '$name · yakında';
  }

  @override
  String figurineShortName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'Klasik',
      'sailor': 'Denizci',
      'baker': 'Fırıncı',
      'astronaut': 'Astronot',
      'gardener': 'Bahçıvan',
      'snow': 'Kar',
      'circus': 'Sirk',
      'musician': 'Müzisyen',
      'royal': 'Kraliyet',
      'explorer': 'Kaşif',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String figurineFlavor(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': '“Saklambaçta her seferinde en küçük olan kazanır.”',
      'sailor':
          '“Her ihtimale karşı en küçük bebeğin içinde bir deniz kabuğu saklarlar.”',
      'baker':
          '“Her somunu dört boyda pişirirler, kimse paylaşmak zorunda kalmasın diye.”',
      'astronaut':
          '“Aya her yolculuktan önce en büyükten en küçüğe geri sayarlar.”',
      'gardener': '“Her şapka, ilkbahar için sakladıkları bir tohumu gizler.”',
      'snow': '“Kimse bakmıyorken üst üste çıkıp kardan adam olurlar.”',
      'circus':
          '“En iyi numaraları, alkışlar eşliğinde birbirinin içine tırmanmak.”',
      'musician':
          '“Tek bir şarkıyı dört boyda çalarlar. En küçüğü ince notaları çalar.”',
      'royal':
          '“Her taç bir sonrakinin içine sığar, bu da epey yer kazandırır.”',
      'explorer':
          '“Dükkândaki her rafın haritasını çıkardılar, ama işleri henüz bitmedi.”',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String museumChapterChip(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Bölüm $numberString · $name';
  }

  @override
  String museumCollectedOn(String date) {
    return 'Toplandı · $date';
  }

  @override
  String get museumCollected => 'Toplandı';

  @override
  String museumLockedText(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Bu aileyi eve getirmek için $numberString. bölümü bitir.';
  }

  @override
  String museumIntro(int levels) {
    final intl.NumberFormat levelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelsString = levelsNumberFormat.format(levels);

    return 'Her bölümün bir bebek ailesi var. O aileyi eve getirmek için bölümün $levelsString seviyesinin hepsini kazan.';
  }

  @override
  String museumLevelsToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString seviye daha',
      one: '1 seviye daha',
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
      other: '$countString daha',
      one: '$countString daha',
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

    return 'Böl. $chapterString · $firstString–$lastString';
  }

  @override
  String museumLockedLine1(int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'Bölüm $chapterString';
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

    return 'Seviye $firstString–$lastString';
  }

  @override
  String get shopTitle => 'Mağaza';

  @override
  String get shopTabCoins => 'Altın';

  @override
  String get shopTabSkins => 'Görünüm';

  @override
  String get shopTabThemes => 'Temalar';

  @override
  String get shopTabNoAds => 'Reklamsız';

  @override
  String get shopEquipped => 'Seçili';

  @override
  String get shopEquip => 'Seç';

  @override
  String get skinOwnedSemantics => 'Sahipsin';

  @override
  String skinName(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Klasik',
      'space': 'Uzay',
      'ocean': 'Okyanus',
      'sweets': 'Tatlılar',
      'forest': 'Orman Dostları',
      'winter': 'Kış',
      'forest_bear': 'Orman Ayısı',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String skinDescription(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Boyalı çiçekler, altın noktalar ve küçük bir fiyonk.',
      'ocean': 'Denizci yakalar, minik çapalar ve dalga şeritleri.',
      'space': 'Yuvarlak kasklar, minik antenler ve halkalı gezegenler.',
      'sweets': 'Akan krema, renkli şekerler ve şeker çizgileri.',
      'forest': 'Sivri kulaklar, inci şeritli kapüşonlar ve dökülen yapraklar.',
      'winter': 'Ponponlu bereler, kar taneleri ve inci şeritler.',
      'forest_bear':
          'Yuvarlak ayı kulakları, rahat kapüşonlar ve yapraklar arasında meşe palamutları.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get skinDetailTitle => 'Görünüm';

  @override
  String get skinDetailColors => '11 rengin hepsi · simgeler duruyor';

  @override
  String get skinDetailSizes =>
      'Her boy aynı şekilde iç içe geçer. Yalnızca boya değişir.';

  @override
  String get shopBuy => 'Satın al';

  @override
  String shopBuySemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Satın al, $countString altın',
      one: 'Satın al, 1 altın',
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
      other: '$countString altının var',
      one: '1 altının var',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsTitle => 'Birkaç altın daha';

  @override
  String notEnoughCoinsNeeded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString altın daha lazım',
      one: '1 altın daha lazım',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsSource =>
      'Altınlar seviye kazanmaktan, günlük bulmacadan ve sandıklardan gelir.';

  @override
  String get notEnoughCoinsGoToShop => 'Mağazaya git';

  @override
  String get notNow => 'Şimdi değil';

  @override
  String shopDownloading(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'İndiriliyor %$percentString';
  }

  @override
  String get themesMatchTitle => 'Her bölüme uydur';

  @override
  String get themesMatchSubtitle =>
      'İçinde bulunduğun bölümün temasını kullanır';

  @override
  String get themeInUse => 'Kullanımda';

  @override
  String get themeUse => 'Kullan';

  @override
  String themeChapterLock(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Böl. $numberString';
  }

  @override
  String get shopClosedTitle => 'Mağaza şimdilik kapalı';

  @override
  String get shopClosedBody =>
      'Altın paketleri ve Reklamları Kaldır sonraki bir güncellemeyle geliyor.';

  @override
  String buyUndoText(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countString ücretsiz geri alma hakkın bitti. Bir hamle daha geri al.',
      one: '1 ücretsiz geri alma hakkın bitti. Bir hamle daha geri al.',
    );
    return '$_temp0';
  }

  @override
  String get buyHintText => 'Sıradaki en iyi hamleni gösterir.';

  @override
  String get buySlotText => 'Bu seviye için bir boş yuva ekler.';

  @override
  String get tutorialStep1Title => 'Küçük bebeğe dokun';

  @override
  String tutorialStepChip(int step, int total) {
    return 'ADIM $step / $total';
  }

  @override
  String get tutorialStep1Text =>
      'Bebekler aynı renkte, bir boy büyüğünün içine girer.';

  @override
  String get tutorialStep2Title => 'Şimdi büyük olana dokun';

  @override
  String get tutorialStep2Text => 'Küçük bebek tık sesiyle içine düşer.';

  @override
  String get tutorialStep3Title => 'Aileyi tamamla';

  @override
  String get tutorialStep3Text =>
      'Son bebeği de yerleştir. Her boy iç içe geçince aile tamamlanır.';

  @override
  String tutorialStepSemantics(int step, String title) {
    final intl.NumberFormat stepNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String stepString = stepNumberFormat.format(step);

    return 'Adım $stepString / 3. $title';
  }

  @override
  String get tutorialSwallowChip => 'YENİ HAMLE';

  @override
  String get tutorialSwallowTitle => 'Büyük, küçüğü yutabilir';

  @override
  String get tutorialSwallowText =>
      'Büyük bir bebeği bir alt boya bırak, tam üstünü kapatır.';

  @override
  String get introNew => 'YENİ';

  @override
  String get introTowersTitle => 'Kuleler!';

  @override
  String get introTowersText =>
      'Yalnızca en üstteki bebek hareket edebilir. Altında saklanan bebeği ortaya çıkarmak için onu başka yere taşı.';

  @override
  String get introGlassTitle => 'Cam Vitrinler';

  @override
  String get introGlassText =>
      'Kilitli bir bebek, kilidindeki aile tamamlanınca serbest kalır.';

  @override
  String get introIceTitle => 'Buz';

  @override
  String get introIceText =>
      'Bitirdiğin her aile buzu çatlatır. Sıfıra inince bebek serbest kalır.';

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
  String get introGotIt => 'Anladım';

  @override
  String chapterCompleteTitle(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'BÖLÜM $numberString TAMAMLANDI';
  }

  @override
  String get chapterCompleteAdded => 'Müzene eklendi!';

  @override
  String chapterCompleteCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString altın';
  }

  @override
  String chapterCompleteNext(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Sıradaki: Bölüm $numberString · $name';
  }

  @override
  String get gameplayGenerating => 'Raflar hazırlanıyor…';

  @override
  String dailyStreakPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString günlük serin dinleniyor. Yeniden yakmak için bugünün bulmacasını çöz.';
  }

  @override
  String get dailyStreakPausedChip => 'Duraklatıldı';

  @override
  String get dailyStreakRelitTitle => 'Seri yeniden alevlendi!';

  @override
  String dailyStreakRelitBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString günlük serin yeniden parlıyor.';
  }

  @override
  String streakBadgeSemanticsPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString günlük seri, duraklatıldı',
      one: '1 günlük seri, duraklatıldı',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => 'Bölümler';

  @override
  String chaptersOverallProgress(int level, int total) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Seviye $levelString / $totalString';
  }

  @override
  String chaptersWonCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString kazanıldı';
  }

  @override
  String chaptersBestMoves(int best) {
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'En iyi $bestString';
  }

  @override
  String get chaptersLevelPlay => 'Oyna';

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
          'Seviye $levelString, $countString yıldız. En iyi $bestString hamle.',
      one:
          'Seviye $levelString, $countString yıldız. En iyi $bestString hamle.',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsWonNoBest(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Seviye $levelString, kazanıldı';
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
      other: 'Seviye $levelString, kazanıldı. En iyi $bestString hamle.',
      one: 'Seviye $levelString, kazanıldı. En iyi $bestString hamle.',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsCurrent(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Seviye $levelString, sıradaki';
  }

  @override
  String chaptersLevelSemanticsLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Seviye $levelString, kilitli';
  }

  @override
  String get recordsTitle => 'Rekorlar';

  @override
  String get homeRecordsButton => 'Rekorlar';

  @override
  String get recordsLevelsWon => 'Kazanılan seviyeler';

  @override
  String get recordsFamilies => 'Tamamlanan aileler';

  @override
  String get recordsRacesHeader => 'Kazanılan yarışlar';

  @override
  String get recordsDolls => 'İç içe geçen bebekler';

  @override
  String get recordsDailies => 'Çözülen günlük bulmacalar';

  @override
  String get recordsLongestStreak => 'En uzun seri';

  @override
  String get recordsBestMovesLink => 'Seviyeye göre en iyi hamleler';

  @override
  String get recordsBadgesHeader => 'Rozetler';

  @override
  String badgeName(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Tam Oturdu',
      'glass_breaker': 'Cam Ustası',
      'ice_melter': 'Buz Eriten',
      'tall_order': 'Dev Boy',
      'grand_nest': 'Koca Yuva',
      'level_100': 'Yolun Yarısı',
      'level_200': 'En Üst Raf',
      'dailies_7': 'Bulmaca Dostu',
      'dailies_30': 'Eski Dost',
      'first_race': 'Rafta Birinci',
      'all_rivals': 'Tüm Rakipler',
      'museum_full': 'Tam Kadro',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeLine(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'İlk aileni iç içe geçirdin.',
      'glass_breaker': 'İlk cam vitrinini açtın.',
      'ice_melter': 'Bir bebeği buzdan kurtardın.',
      'tall_order': '5 boy bebeklerle bir seviye kazandın.',
      'grand_nest': '6 boy bebeklerle bir seviye kazandın.',
      'level_100': '100. seviyeyi kazandın.',
      'level_200': '200. seviyeyi, en sonuncuyu kazandın.',
      'dailies_7': '7 tane günlük bulmaca çözdün.',
      'dailies_30': '30 tane günlük bulmaca çözdün.',
      'first_race': 'Bir yarışta bilgisayarı yendin.',
      'all_rivals': 'Her bilgisayar rakibini yendin.',
      'museum_full': 'Müzende her aile evinde.',
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
      'first_family': 'Bir aileyi tamamen iç içe geçir.',
      'glass_breaker': 'Bir cam vitrin aç.',
      'ice_melter': 'Bir bebeği buzdan kurtar.',
      'tall_order': '5 boy bebeklerle bir seviye kazan.',
      'grand_nest': '6 boy bebeklerle bir seviye kazan.',
      'level_100': '$levelString. seviyeyi kazan.',
      'level_200': '$levelString. seviyeyi kazan.',
      'dailies_7': '$countString tane günlük bulmaca çöz.',
      'dailies_30': '$countString tane günlük bulmaca çöz.',
      'first_race': 'Bir yarışta bilgisayarı yen.',
      'all_rivals': 'Her bilgisayar rakibini yen.',
      'museum_full': 'Her aileyi Müzene getir.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeSemanticsEarned(String badge) {
    return '$badge, kazanıldı';
  }

  @override
  String badgeSemanticsLocked(String badge, String how) {
    return '$badge, henüz kazanılmadı. $how';
  }

  @override
  String badgeEarnedToastTitle(String badge) {
    return 'Rozet kazanıldı · $badge';
  }

  @override
  String get badgeLockedLine => 'Henüz kazanılmadı';

  @override
  String winMovesBest(int moves, int best) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Hamle $movesString · En iyi $bestString';
  }

  @override
  String winMovesOnly(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return 'Hamle $movesString';
  }

  @override
  String winChestCountdown(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sandığa $countString seviye',
      one: 'Sandığa 1 seviye',
    );
    return '$_temp0';
  }

  @override
  String get winReplayReason =>
      'Eğlence için tekrar: altınlar yeni seviyelerden gelir.';

  @override
  String get winBackToChapters => 'Bölümlere dön';

  @override
  String get chestMilestoneTitle => 'Aşama sandığı';

  @override
  String chestMilestoneBody(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return '$levelString. seviyeye ulaştığın için bir sandık. İçindekilere bak.';
  }

  @override
  String chestMilestoneBodyBonus(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return '$levelString. bonus seviye için bir sandık. İçindekilere bak.';
  }

  @override
  String chestContentsCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString altın',
      one: '+1 altın',
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
      other: '+$countString ipucu',
      one: '+1 ipucu',
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
      other: '$coinsString altın',
      one: '$coinsString altın',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hints,
      locale: localeName,
      other: '$hintsString ipucu',
      one: '$hintsString ipucu',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String chestSemantics(String contents) {
    return 'Sandık. İçinde: $contents.';
  }

  @override
  String get chestOpen => 'Aç';

  @override
  String get settingRelaxedMode => 'Rahat mod';

  @override
  String get settingRelaxedModeSubtitle => 'Sınırsız ücretsiz geri alma';

  @override
  String get relaxedModeOn => 'Rahat mod açık. İstediğin kadar geri al.';

  @override
  String get settingReduceMotion => 'Hareketi azalt';

  @override
  String get reduceMotionSystem => 'Sistem';

  @override
  String get reduceMotionOn => 'Açık';

  @override
  String get reduceMotionOff => 'Kapalı';

  @override
  String get oomUndoFreeUnlimited => 'Ücretsiz, istediğin kadar';

  @override
  String oomUndoSpent(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ücretsiz geri alma hakkın bitti',
      one: '$countString ücretsiz geri alma hakkın bitti',
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
      other: 'Bir seviye için en fazla $countString ek yuva.',
      one: 'Bir seviye için en fazla bir ek yuva.',
    );
    return '$_temp0';
  }

  @override
  String get boosterUndoUnlimitedSemantics => 'Geri al, sınırsız';

  @override
  String get oomUndoFreeChip => 'Ücretsiz';

  @override
  String boosterLimitSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '+Yuva, $totalString yuvadan $countString kullanıldı';
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
    return '$booster, önerilen';
  }

  @override
  String get boosterRestartSemantics => 'Seviyeyi yeniden başlat';

  @override
  String get homeVsComputerTile => 'Bilgisayara Karşı';

  @override
  String homeVsComputerLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return '$levelString. seviyeden sonra';
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
  String get raceSelectTitle => 'Bilgisayara Karşı';

  @override
  String get raceSelectSubtitle => 'Aynı bulmacada bir bilgisayarla yarış';

  @override
  String get raceComputerTag => 'Bilgisayar';

  @override
  String raceRivalName(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Komet',
      two: 'Düğme',
      one: 'Çakıl',
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
      other: 'Canlı, düzenli ve yakalaması zor.',
      two: 'Her hamleyi iki kez kontrol eder, sonra yapar.',
      one: 'Kendi temposunda gider, yol boyunca her bebeğin keyfini çıkarır.',
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
      other: 'Canlı tempo',
      two: 'Dengeli tempo',
      one: 'Sakin tempo',
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
      other: '$coinsString altın kazan',
      one: '1 altın kazan',
    );
    return '$_temp0';
  }

  @override
  String raceRivalLocked(String rival) {
    return 'Kilidi açmak için $rival rakibini yen';
  }

  @override
  String get raceRivalNew => 'Yeni';

  @override
  String raceRivalSemantics(String name) {
    return '$name, Bilgisayar';
  }

  @override
  String raceRivalCardSemantics(String rival, String skill) {
    return '$rival, bilgisayar rakibi. $skill.';
  }

  @override
  String raceRivalLockedSemantics(String rival) {
    return 'Kilitli bilgisayar rakibi. Kilidi açmak için $rival rakibini yen.';
  }

  @override
  String get raceRivalSelectedSemantics => 'Seçildi';

  @override
  String get raceStart => 'Başla';

  @override
  String get raceStartHint =>
      'Aynı bulmaca, iki tahta. Tüm aileleri ilk tamamlayan kazanır.';

  @override
  String get raceStripReady => 'Sen hazır olunca';

  @override
  String get raceStripThinking => 'Düşünüyor…';

  @override
  String get raceStripStartingOver => 'Baştan başlıyor';

  @override
  String get raceStripFinished => 'Bitirdi';

  @override
  String get raceStripPlayerFinished => 'İlk sen bitirdin';

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
      other: '$name, bilgisayar: $totalString aileden $countString',
      one: '$name, bilgisayar: $totalString aileden $countString',
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

    return 'Bilgisayar bir aileyi tamamladı: $totalString aileden $doneString';
  }

  @override
  String raceAnnounceStart(String rival) {
    return 'Yarış başladı: rakip $rival, bir bilgisayar oyuncusu.';
  }

  @override
  String get raceAnnounceStartingOver => 'Bilgisayar baştan başlıyor.';

  @override
  String get raceAnnounceFinished => 'Bilgisayar tüm aileleri tamamladı.';

  @override
  String get raceAnnounceWon => 'Yarışı kazandın.';

  @override
  String get raceAnnounceLost => 'Bilgisayar ilk bitirdi.';

  @override
  String get raceWinTitle => 'Yarışı kazandın!';

  @override
  String get raceWinTitleShort => 'Kazandın!';

  @override
  String raceWinBody(String rival) {
    return 'Tüm aileler tamamlandı. $rival hâlâ diziyordu.';
  }

  @override
  String raceWinCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString altın',
      one: '+1 altın',
    );
    return '$_temp0';
  }

  @override
  String get raceLossTitle => 'Çok yaklaştın! Rövanş?';

  @override
  String get raceLossTitleShort => 'Çok yaklaştın!';

  @override
  String raceLossBody(String rival) {
    return '$rival bu sefer ilk bitirdi. Rövanşın bedeli yok.';
  }

  @override
  String get raceRivalUnlockedTitle => 'Yeni rakip açıldı!';

  @override
  String raceRivalUnlockedBody(String rival) {
    return '$rival yarışa hazır.';
  }

  @override
  String raceRivalUnlockedRace(String rival) {
    return '$rival ile yarış';
  }

  @override
  String get raceLeaveTitle => 'Yarıştan çıkılsın mı?';

  @override
  String get raceLeaveBody =>
      'Yarış burada durur. Altın yok, ama her şeyin sende kalır.';

  @override
  String get raceLeaveKeep => 'Yarışa devam';

  @override
  String get raceRematch => 'Rövanş';

  @override
  String get raceNewRace => 'Yeni yarış';

  @override
  String get raceBackToRivals => 'Yarışlara dön';

  @override
  String get raceFailedTitle => 'Raflar biraz zaman istiyor';

  @override
  String get raceFailedBody =>
      'Bu yarış kurulamadı. Tekrar dene ya da başka bir yarış seç.';

  @override
  String racePauseSubtitle(String rival) {
    return '$rival rakibi de duraklatıldı.';
  }

  @override
  String racePauseHeader(String rival) {
    return 'Bilgisayara karşı · $rival';
  }

  @override
  String get raceRivalBeaten => 'Yenildi';

  @override
  String raceStartFor(String rival) {
    return '$rival karşısında yarışı başlat';
  }

  @override
  String get raceQuit => 'Yarıştan çık';

  @override
  String starsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '3 yıldızdan $count',
      one: '3 yıldızdan 1',
    );
    return '$_temp0';
  }

  @override
  String starsNewBestSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yeni rekor, 3 yıldızdan $count',
      one: 'Yeni rekor, 3 yıldızdan 1',
    );
    return '$_temp0';
  }

  @override
  String winStarsTarget(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return '$movesString hamle veya daha azıyla 3 yıldız';
  }

  @override
  String get winStarsNewBest => 'Yeni rekor!';

  @override
  String get starsFirstTip =>
      'Daha az hamle daha çok yıldız getirir. İstediğin seviyeyi Bölümler’den tekrar oyna.';

  @override
  String get starsHelperNote =>
      'İpucu veya ek yuvayla kazanılan zaferler en fazla 2 yıldız getirir.';

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
  String get chaptersAllThreeStars => 'Her seviye 3 yıldızlı';

  @override
  String chaptersStarsSemantics(int earned, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      earned,
      locale: localeName,
      other: '$total yıldızdan $earned',
      one: '$total yıldızdan 1',
    );
    return '$_temp0';
  }

  @override
  String get recordsStars => 'Yıldızlar';

  @override
  String recordsStarsValue(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString/$totalString';
  }

  @override
  String get dailyShare => 'Paylaş';

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
  String get dailyShareSemantics => 'Bugünün sonucunu paylaş';

  @override
  String dailyShareText(String date, String glyphs, int moves, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves hamlede çözüldü · $day. gün 🔥',
      one: '1 hamlede çözüldü · $day. gün 🔥',
    );
    return 'Nesty Günlük Bulmaca · $date\n$glyphs\n$_temp0';
  }

  @override
  String dailyShareTextNoStreak(String date, String glyphs, int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves hamlede çözüldü',
      one: '1 hamlede çözüldü',
    );
    return 'Nesty Günlük Bulmaca · $date\n$glyphs\n$_temp0';
  }

  @override
  String get reminderOfferTitle =>
      'Yarının bulmacası hazır olunca haber verelim mi?';

  @override
  String get reminderOfferBody =>
      'Günde bir kez, seçtiğin saatte küçük bir not. Ayarlar’dan kapatabilirsin.';

  @override
  String reminderOfferTime(String time) {
    return 'Her gün $time';
  }

  @override
  String get reminderOfferChangeTime => 'Saati değiştir';

  @override
  String reminderTimeChipSemantics(String time) {
    return 'Hatırlatıcı saati, her gün $time. Saati değiştir.';
  }

  @override
  String get reminderPickerTitle => 'Hatırlatıcı saati';

  @override
  String get reminderOfferYes => 'Evet, hatırlat';

  @override
  String get reminderOfferNo => 'Hayır, teşekkürler';

  @override
  String reminderOfferDone(String time) {
    return 'Hatırlatıcı $time için ayarlandı.';
  }

  @override
  String get reminderOfferDeniedTitle => 'Nesty için bildirimler kapalı';

  @override
  String reminderOfferDenied(String time) {
    return 'Telefonunun ayarlarından aç, notun $time saatinde gelsin.';
  }

  @override
  String get reminderNotificationTitle => 'Nesty';

  @override
  String get reminderNotificationBody => 'Bugünün bulmacası rafta.';

  @override
  String get reminderNotificationBody2 =>
      'Taze bir günlük bulmaca seni bekliyor, ne zaman istersen.';

  @override
  String get reminderNotificationBody3 =>
      'Yeni bebekler iç içe geçmeyi bekliyor. Bugünün bulmacası hazır.';

  @override
  String get reminderChannelName => 'Günlük bulmaca';

  @override
  String get reminderChannelDescription =>
      'Yeni bir günlük bulmaca hazır olduğunda günde bir not.';

  @override
  String get settingReminder => 'Günlük hatırlatıcı';

  @override
  String get settingReminderTime => 'Saat';

  @override
  String get settingReminderBlocked => 'Telefonunun ayarlarında kapalı';

  @override
  String get settingOpenPhoneSettings => 'Telefon ayarlarını aç';

  @override
  String get settingReminderTurnOff => 'Kapat';

  @override
  String homeChapterKicker(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'BÖLÜM $numberString';
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

    return 'Bölüm $chapterString, $name. $totalString yıldızdan $countString. Bölümleri açar.';
  }

  @override
  String homeBonusCardSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Bonus seviyeler. $totalString yıldızdan $countString. Bölümleri açar.';
  }

  @override
  String get homeVsComputerSemantics =>
      'Bilgisayara karşı. Aynı bulmacada bir bilgisayarla yarış.';

  @override
  String homeVsComputerLockedSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Bilgisayara karşı, kilitli. $levelString. seviyeden sonra.';
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

    return 'BÖLÜM $numberString · SEVİYE $firstString–$lastString';
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

    return 'Bölüm $chapterString, $name. $totalString yıldızdan $countString.';
  }

  @override
  String chaptersRowLockedSemantics(int chapter, String name) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'Bölüm $chapterString, $name. Kilitli.';
  }

  @override
  String get chaptersLevelChestSemantics => 'Bu seviyede bir sandık';

  @override
  String get chaptersLevelFinaleSemantics => 'Bölümün son seviyesi';

  @override
  String museumNicheCollectedSemantics(String name) {
    return '$name, Müzende evinde';
  }

  @override
  String museumNicheNextSemantics(String name, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, eve dönecek sıradaki aile. $countString seviye daha.',
      one: '$name, eve dönecek sıradaki aile. $countString seviye daha.',
    );
    return '$_temp0';
  }

  @override
  String museumNicheLockedSemantics(String name, int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return '$name, henüz evinde değil. Bölüm $chapterString.';
  }

  @override
  String museumCountSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalString aileden $countString evinde';
  }

  @override
  String museumFullSub(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Tam Kadro · $countString ailenin hepsi';
  }

  @override
  String recordsRaceSemantics(String rival, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$rival, bilgisayar. $countString galibiyet.',
      one: '$rival, bilgisayar. $countString galibiyet.',
    );
    return '$_temp0';
  }

  @override
  String recordsRaceLockedSemantics(String rival) {
    return '$rival, bilgisayar. Kilitli.';
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
  String get giftTitle => 'Günlük hediye';

  @override
  String giftDay(int day) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return '$dayString. gün';
  }

  @override
  String get giftClaim => 'Topla';

  @override
  String get giftClaimedLine => 'Bugünkü hediye senin.';

  @override
  String giftTomorrow(String gift) {
    return 'Yarın: $gift';
  }

  @override
  String giftNext(String gift) {
    return 'Sıradaki hediye: $gift';
  }

  @override
  String get giftButtonReadySemantics => 'Günlük hediye. Bir hediye hazır.';

  @override
  String get giftButtonSemantics => 'Günlük hediye';

  @override
  String giftTileSemantics(int day, String gift, String state) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return '$dayString. gün, $gift. $state';
  }

  @override
  String get giftTileDone => 'Toplandı';

  @override
  String get giftTileToday => 'Bugünün hediyesi';

  @override
  String get giftTileLater => 'Sırada';

  @override
  String get giftChestTitle => '7. gün hediyesi';

  @override
  String get giftChestBody => '7. gün için bir sandık. İçindekilere bak.';

  @override
  String giftCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString altın',
      one: '1 altın',
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
      other: '$countString ipucu',
      one: '1 ipucu',
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
      other: '$countString ek yuva',
      one: '1 ek yuva',
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
      other: '+$countString yuva',
      one: '+1 yuva',
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
      other: '$coinsString altın',
      one: '1 altın',
    );
    String _temp1 = intl.Intl.pluralLogic(
      slots,
      locale: localeName,
      other: '$slotsString ek yuva',
      one: '1 ek yuva',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get giftSubtitle => 'Günde bir hediye, kendi temponda.';

  @override
  String get giftTitleShort => 'Hediyeler';

  @override
  String get giftChestTitleShort => '7. gün';

  @override
  String giftSlotsShort(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString yuva',
      one: '1 yuva',
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
    return 'Hediye toplandı: $gift.';
  }

  @override
  String giftA11yAdded(String gift, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$gift eklendi. Toplam $countString.';
  }
}
