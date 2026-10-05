// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Nesty';

  @override
  String get splashLoading => 'Memuat…';

  @override
  String progressPercent(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString';
  }

  @override
  String get genericLoadFailed => 'Ada yang tidak beres.';

  @override
  String get splashStorageTitle => 'Penyimpanan ponselmu hampir penuh';

  @override
  String splashStorageBody(int size) {
    final intl.NumberFormat sizeNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String sizeString = sizeNumberFormat.format(size);

    return 'Nesty butuh sekitar $sizeString MB untuk menata rak. Kosongkan sedikit ruang, lalu coba lagi.';
  }

  @override
  String get splashContentTitle => 'Raknya tidak bisa disiapkan';

  @override
  String get splashContentBody =>
      'Ada masalah saat memuat. Coba lagi, atau mulai ulang Nesty.';

  @override
  String get retry => 'Coba lagi';

  @override
  String levelTitle(int level) {
    return 'Level $level';
  }

  @override
  String get pause => 'Jeda';

  @override
  String get boosterUndo => 'Urungkan';

  @override
  String get boosterUndoShort => 'Urungkan';

  @override
  String get boosterHint => 'Petunjuk';

  @override
  String get boosterHintShort => 'Petunjuk';

  @override
  String get boosterExtraSlot => '+Tempat';

  @override
  String get boosterExtraSlotShort => '+1';

  @override
  String get restart => 'Ulangi';

  @override
  String get restartShort => 'Ulangi';

  @override
  String get splashDollSort => 'SUSUN BONEKA';

  @override
  String get splashCaption => 'Membersihkan debu rak…';

  @override
  String get homePlay => 'MAIN';

  @override
  String get homeAllLevelsDone => 'Semua selesai!';

  @override
  String playSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Main level $levelString';
  }

  @override
  String playLevelSemantics(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Main level $levelString, $tier';
  }

  @override
  String coinPillShopSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString koin. Membuka Toko.',
    );
    return '$_temp0';
  }

  @override
  String get tierHard => 'SULIT';

  @override
  String get tierSuperHard => 'EKSTREM';

  @override
  String get tierSuperShort => 'EKSTREM';

  @override
  String tierName(String tier) {
    String _temp0 = intl.Intl.selectLogic(tier, {
      'easy': 'Mudah',
      'medium': 'Sedang',
      'hard': 'Sulit',
      'superhard': 'Ekstrem',
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
      other: '$countString dari $totalString keluarga selesai',
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
      other: '$countString koin',
    );
    return '$_temp0';
  }

  @override
  String get levelDaily => 'Harian';

  @override
  String levelDailySemantics(String date) {
    return 'Teka-teki harian, $date';
  }

  @override
  String bonusLevelTitle(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level Bonus $levelString';
  }

  @override
  String get closeSemantics => 'Tutup';

  @override
  String get backSemantics => 'Kembali';

  @override
  String boosterAdSemantics(String booster) {
    return '$booster, tonton video';
  }

  @override
  String boosterCoinSemantics(String booster, int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$booster, $priceString koin',
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
      other: 'Urungkan, sisa $countString',
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
      other: 'Petunjuk, sisa $countString',
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
      other: 'Tempat ekstra, sisa $countString',
    );
    return '$_temp0';
  }

  @override
  String get softStuckTitle => 'Hmm, sepertinya buntu';

  @override
  String get softStuckBody => 'Coba Urungkan? Kamu juga boleh terus bermain.';

  @override
  String get softStuckBodyRestart =>
      'Coba Ulangi? Kamu juga boleh terus bermain.';

  @override
  String get softStuckAction => 'Urungkan';

  @override
  String get oomTitle => 'Langkah habis!';

  @override
  String get oomSubtitle => 'Pilih cara untuk lanjut menyusun.';

  @override
  String get oomUndoSubtitle => 'Tarik kembali langkah terakhirmu';

  @override
  String oomUndoFree(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gratis · $countString lagi',
    );
    return '$_temp0';
  }

  @override
  String get oomSlotTitle => '+1 Tempat';

  @override
  String get oomSlotSubtitle => 'Tambah satu tempat untuk level ini';

  @override
  String get oomSlotOffline => 'Hanya dengan koin saat offline';

  @override
  String get oomRestartSubtitle => 'Mulai level ini dari awal, gratis';

  @override
  String coinPrice(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString koin',
    );
    return '$_temp0';
  }

  @override
  String get watchAd => 'Tonton iklan';

  @override
  String get watchAdSemantics => 'Tonton iklan';

  @override
  String get offlineTitle => 'Offline';

  @override
  String get offlineAds => 'Tombol iklan berganti jadi harga koin';

  @override
  String get connectToWatchAd => 'Sambungkan internet untuk menonton iklan';

  @override
  String get winTitle => 'Level Selesai!';

  @override
  String get winTitleShort => 'Selesai!';

  @override
  String get winContinue => 'Lanjut';

  @override
  String get winTripleCoins => 'Koin ×3';

  @override
  String get winRewardAdded => 'Hadiah ditambahkan';

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

    return 'Bab $numberString';
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
    return 'Berikutnya: $name';
  }

  @override
  String get winChapterDone => 'Bab selesai! Hadiahmu menyusul.';

  @override
  String figurineName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'Keluarga Klasik',
      'sailor': 'Keluarga Pelaut',
      'baker': 'Keluarga Tukang Roti',
      'astronaut': 'Keluarga Astronaut',
      'gardener': 'Keluarga Tukang Kebun',
      'snow': 'Keluarga Salju',
      'circus': 'Keluarga Sirkus',
      'musician': 'Keluarga Musisi',
      'royal': 'Keluarga Kerajaan',
      'explorer': 'Keluarga Penjelajah',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String chapterRibbon(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'BAB $numberString · $name';
  }

  @override
  String chapterRibbonShort(String name) {
    return '$name';
  }

  @override
  String chapterName(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'ch01': 'Toko Mainan Cerah',
      'ch02': 'Sudut Kafe Hujan',
      'ch03': 'Pasar Tepi Laut',
      'ch04': 'Pondok Bersalju',
      'ch05': 'Karnaval Malam',
      'ch06': 'Gudang Taman Musim Semi',
      'ch07': 'Teater Boneka',
      'ch08': 'Panggung Musim Gugur',
      'ch09': 'Perpustakaan Kastel',
      'ch10': 'Pos Pengamatan Matahari Terbit',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get pauseTitle => 'Dijeda';

  @override
  String get resume => 'Lanjutkan';

  @override
  String get home => 'Beranda';

  @override
  String get settings => 'Pengaturan';

  @override
  String get settingSound => 'Suara';

  @override
  String get settingMusic => 'Musik';

  @override
  String get settingHaptics => 'Getaran';

  @override
  String get allLevelsTitle => 'Kamu sudah menamatkan semua level!';

  @override
  String get allLevelsBody =>
      'Bab baru akan datang — sementara itu, mainkan level bonus.';

  @override
  String allLevelsPlayBonus(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Main Level Bonus $numberString';
  }

  @override
  String get allLevelsBackHome => 'Kembali ke Beranda';

  @override
  String get nextLevelFailedHome => 'Kembali ke Beranda';

  @override
  String get gameplayFailedTitle => 'Raknya butuh waktu sebentar';

  @override
  String get gameplayFailedBody =>
      'Level ini tidak bisa disiapkan. Coba lagi, atau kembali ke beranda.';

  @override
  String get devLevelPickerTitle => 'Loncat ke level';

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

    return 'Bab $numberString · Level $startString–$endString';
  }

  @override
  String get navShop => 'Toko';

  @override
  String get navHomeShort => 'Beranda';

  @override
  String get navShopShort => 'Toko';

  @override
  String get navMuseum => 'Museum';

  @override
  String get navMuseumShort => 'Museum';

  @override
  String get homeDailyTile => 'Teka-teki Harian';

  @override
  String get homeMuseumTile => 'Museum';

  @override
  String get homeRemoveAdsTile => 'Hapus Iklan';

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

    return 'Setelah Level $levelString';
  }

  @override
  String get homeBonusBadge => 'BONUS';

  @override
  String get homeBonusKicker => 'BONUS TANPA BATAS';

  @override
  String get homeBonusName => 'Level bonus';

  @override
  String streakBadgeSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Streak $countString hari',
    );
    return '$_temp0';
  }

  @override
  String get settingColorSymbols => 'Simbol warna';

  @override
  String get symbolsSubtle => 'Halus';

  @override
  String get symbolsLarge => 'Besar';

  @override
  String get settingLanguage => 'Bahasa';

  @override
  String get settingRestorePurchases => 'Pulihkan Pembelian';

  @override
  String get settingPrivacyChoices => 'Pilihan privasi';

  @override
  String get settingPrivacyPolicy => 'Kebijakan Privasi';

  @override
  String get settingSupport => 'Bantuan';

  @override
  String get settingSupportValue => 'Kirim email';

  @override
  String settingsFooter(String version, String build, String playerId) {
    return 'Nesty: Doll Sort · v$version (build $build) · ID Pemain $playerId';
  }

  @override
  String get languageSheetTitle => 'Bahasa';

  @override
  String get languageSheetDone => 'Selesai';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'Inggris',
      'es': 'Spanyol',
      'pt_BR': 'Portugis',
      'id': 'Indonesia',
      'hi': 'Hindi',
      'de': 'Jerman',
      'fr': 'Prancis',
      'tr': 'Turki',
      'ja': 'Jepang',
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
      other: '$countString hari',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakKeep => 'Main hari ini untuk menambah streak-mu';

  @override
  String get dailyStreakStart =>
      'Selesaikan teka-teki hari ini untuk menyalakan api pertamamu.';

  @override
  String get dailyStreakDone => 'Apimu menyala. Sampai besok.';

  @override
  String get dailyStreakWeek => 'Seminggu penuh!';

  @override
  String dailyFreezes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString pelindung',
      zero: 'Tanpa pelindung',
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
      other: '$countString pelindung streak',
    );
    return '$_temp0';
  }

  @override
  String get dailyDay => 'Hari';

  @override
  String get dailyToday => 'Hari ini';

  @override
  String get dailyTomorrow => 'Besok';

  @override
  String dailyDaySemantics(String state, int day) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'done': 'Hari $day, selesai',
      'today': 'Hari ini, hari $day',
      'tomorrow': 'Besok, hari $day',
      'chest': 'Hari $day, peti',
      'other': 'Hari $day',
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
      other: 'Main, $countString koin',
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
      other: 'Peti hari ke-7 · $countString koin',
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
      other: '$countString hari lagi',
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
      other: '$countString hari lagi, termasuk hari ini',
    );
    return '$_temp0';
  }

  @override
  String get dailyChestOpenedToday => 'Dibuka hari ini';

  @override
  String dailyPuzzleTitle(String weekday) {
    return 'Teka-teki $weekday';
  }

  @override
  String dailyPuzzleInfo(int colors, String tier) {
    final intl.NumberFormat colorsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String colorsString = colorsNumberFormat.format(colors);

    String _temp0 = intl.Intl.pluralLogic(
      colors,
      locale: localeName,
      other: '$colorsString warna',
    );
    return '$_temp0 · $tier';
  }

  @override
  String get dailyPlay => 'Main';

  @override
  String dailySolvedChip(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return 'Selesai · +$coinsString';
  }

  @override
  String dailyNextPuzzle(String time) {
    return 'Teka-teki berikutnya dalam $time';
  }

  @override
  String dailyCountdown(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString j $minutesString m';
  }

  @override
  String playLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Main Level $levelString';
  }

  @override
  String get dailySavedTitle => 'Sebuah pelindung menjaga apimu tetap menyala.';

  @override
  String dailySavedBody(String weekday) {
    return 'Sebuah pelindung menutupi hari $weekday. Minggu depan kamu akan mendapat yang baru.';
  }

  @override
  String get dailyChestTitle => 'Streak 7 hari!';

  @override
  String get dailyChestBody => 'Tujuh hari berturut-turut. Ini isinya.';

  @override
  String get dailyChestDouble => 'Gandakan';

  @override
  String get dailyChestCollect => 'Ambil';

  @override
  String get dailyWinTitle => 'Teka-teki harian selesai!';

  @override
  String dailyWinStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Streak $countString hari';
  }

  @override
  String dailyWinChestHint(String count) {
    String _temp0 = intl.Intl.selectLogic(count, {
      '0': 'Peti hari ke-7 sudah siap!',
      '1': 'Satu hari lagi menuju peti hari ke-7',
      '2': 'Dua hari lagi menuju peti hari ke-7',
      '3': 'Tiga hari lagi menuju peti hari ke-7',
      '4': 'Empat hari lagi menuju peti hari ke-7',
      '5': 'Lima hari lagi menuju peti hari ke-7',
      '6': 'Enam hari lagi menuju peti hari ke-7',
      'other': '$count hari lagi menuju peti hari ke-7',
    });
    return '$_temp0';
  }

  @override
  String get dailyBackToDaily => 'Kembali ke Teka-teki Harian';

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
      other: 'Bab $chapterString · $countString level lagi',
    );
    return '$_temp0';
  }

  @override
  String get museumAllHome => 'Semua keluarga sudah pulang.';

  @override
  String get museumNextFamily => 'Keluarga berikutnya';

  @override
  String get museumNextFamilyKicker => 'KELUARGA BERIKUTNYA';

  @override
  String museumFamilyLabel(String name) {
    return 'Keluarga $name';
  }

  @override
  String museumSoonLabel(String name) {
    return '$name · segera';
  }

  @override
  String figurineShortName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'Klasik',
      'sailor': 'Pelaut',
      'baker': 'Tukang Roti',
      'astronaut': 'Astronaut',
      'gardener': 'Tukang Kebun',
      'snow': 'Salju',
      'circus': 'Sirkus',
      'musician': 'Musisi',
      'royal': 'Kerajaan',
      'explorer': 'Penjelajah',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String figurineFlavor(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': '“Si paling kecil selalu menang main petak umpet.”',
      'sailor':
          '“Mereka menyimpan kerang di dalam boneka terkecil, jaga-jaga.”',
      'baker':
          '“Setiap roti mereka panggang dalam empat ukuran, jadi tak perlu berbagi.”',
      'astronaut':
          '“Mereka menghitung mundur dari yang terbesar sampai terkecil setiap kali berangkat ke bulan.”',
      'gardener':
          '“Setiap topi menyembunyikan biji yang disimpan untuk musim semi.”',
      'snow':
          '“Kalau tak ada yang melihat, mereka menumpuk jadi manusia salju.”',
      'circus':
          '“Atraksi terbaik mereka: masuk satu ke dalam yang lain, disambut tepuk tangan meriah.”',
      'musician':
          '“Mereka memainkan satu lagu dalam empat ukuran. Yang terkecil memainkan nada tinggi.”',
      'royal':
          '“Setiap mahkota muat di dalam mahkota berikutnya, jadi hemat tempat.”',
      'explorer':
          '“Mereka sudah memetakan setiap rak di toko, dan belum selesai.”',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String museumChapterChip(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Bab $numberString · $name';
  }

  @override
  String museumCollectedOn(String date) {
    return 'Didapat · $date';
  }

  @override
  String get museumCollected => 'Didapat';

  @override
  String museumLockedText(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Selesaikan Bab $numberString untuk membawa keluarga ini pulang.';
  }

  @override
  String museumIntro(int levels) {
    final intl.NumberFormat levelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelsString = levelsNumberFormat.format(levels);

    return 'Setiap bab punya satu keluarga boneka. Menangkan semua $levelsString level-nya untuk membawa keluarga itu pulang.';
  }

  @override
  String museumLevelsToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString level lagi',
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
      other: '$countString lagi',
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

    return 'Bab $chapterString · $firstString–$lastString';
  }

  @override
  String museumLockedLine1(int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'Bab $chapterString';
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

    return 'Level $firstString–$lastString';
  }

  @override
  String get shopTitle => 'Toko';

  @override
  String get shopTabCoins => 'Koin';

  @override
  String get shopTabSkins => 'Skin';

  @override
  String get shopTabThemes => 'Tema';

  @override
  String get shopTabNoAds => 'Tanpa Iklan';

  @override
  String get shopEquipped => 'Dipakai';

  @override
  String get shopEquip => 'Pakai';

  @override
  String get skinOwnedSemantics => 'Dimiliki';

  @override
  String skinName(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Klasik',
      'space': 'Luar Angkasa',
      'ocean': 'Samudra',
      'sweets': 'Manisan',
      'forest': 'Sahabat Hutan',
      'winter': 'Musim Dingin',
      'forest_bear': 'Beruang Hutan',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String skinDescription(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Bunga lukis, titik emas, dan pita kecil.',
      'ocean': 'Kerah pelaut, jangkar mungil, dan hiasan ombak.',
      'space': 'Helm bulat, antena mungil, dan planet bercincin.',
      'sweets': 'Lelehan krim, taburan warna-warni, dan garis permen.',
      'forest': 'Telinga runcing, tudung berhias mutiara, dan daun berguguran.',
      'winter': 'Topi pompom, kepingan salju, dan hiasan mutiara.',
      'forest_bear':
          'Telinga beruang bulat, tudung hangat, dan biji ek di antara dedaunan.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get skinDetailTitle => 'Skin';

  @override
  String get skinDetailColors => 'Semua 11 warna · simbol tetap ada';

  @override
  String get skinDetailSizes =>
      'Setiap ukuran tersusun dengan cara yang sama. Hanya catnya yang berubah.';

  @override
  String get shopBuy => 'Beli';

  @override
  String shopBuySemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Beli, $countString koin',
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
      other: 'Kamu punya $countString koin',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsTitle => 'Butuh beberapa koin lagi';

  @override
  String notEnoughCoinsNeeded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kamu butuh $countString koin lagi',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsSource =>
      'Koin didapat dari memenangkan level, teka-teki harian, dan peti.';

  @override
  String get notEnoughCoinsGoToShop => 'Ke Toko';

  @override
  String get notNow => 'Nanti saja';

  @override
  String shopDownloading(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'Mengunduh $percentString%';
  }

  @override
  String get themesMatchTitle => 'Samakan dengan tiap bab';

  @override
  String get themesMatchSubtitle => 'Memakai tema bab yang sedang kamu mainkan';

  @override
  String get themeInUse => 'Dipakai';

  @override
  String get themeUse => 'Pakai';

  @override
  String themeChapterLock(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Bab $numberString';
  }

  @override
  String get shopClosedTitle => 'Toko tutup untuk sementara';

  @override
  String get shopClosedBody =>
      'Paket koin dan Hapus Iklan hadir di pembaruan berikutnya.';

  @override
  String buyUndoText(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countString urungkan gratismu sudah terpakai. Tarik kembali satu langkah lagi.',
    );
    return '$_temp0';
  }

  @override
  String get buyHintText => 'Menunjukkan langkah terbaik berikutnya.';

  @override
  String get buySlotText => 'Menambah satu tempat kosong untuk level ini.';

  @override
  String get tutorialStep1Title => 'Ketuk boneka kecil';

  @override
  String tutorialStepChip(int step, int total) {
    return 'LANGKAH $step DARI $total';
  }

  @override
  String get tutorialStep1Text =>
      'Boneka masuk ke boneka sewarna yang satu ukuran lebih besar.';

  @override
  String get tutorialStep2Title => 'Sekarang ketuk yang besar';

  @override
  String get tutorialStep2Text =>
      'Boneka kecil jatuh ke dalam dengan bunyi klak.';

  @override
  String get tutorialStep3Title => 'Selesaikan keluarganya';

  @override
  String get tutorialStep3Text =>
      'Masukkan boneka terakhir. Keluarga selesai saat setiap ukuran sudah tersusun.';

  @override
  String tutorialStepSemantics(int step, String title) {
    final intl.NumberFormat stepNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String stepString = stepNumberFormat.format(step);

    return 'Langkah $stepString dari 3. $title';
  }

  @override
  String get tutorialSwallowChip => 'LANGKAH BARU';

  @override
  String get tutorialSwallowTitle => 'Yang besar bisa menelan yang kecil';

  @override
  String get tutorialSwallowText =>
      'Letakkan boneka besar di atas ukuran di bawahnya, dan ia menutupinya.';

  @override
  String get introNew => 'BARU';

  @override
  String get introTowersTitle => 'Menara!';

  @override
  String get introTowersText =>
      'Hanya boneka paling atas yang bisa dipindah. Singkirkan untuk menemukan boneka yang bersembunyi di bawahnya.';

  @override
  String get introGlassTitle => 'Kotak Kaca';

  @override
  String get introGlassText =>
      'Boneka yang terkunci bebas saat keluarga pada gemboknya selesai.';

  @override
  String get introIceTitle => 'Es';

  @override
  String get introIceText =>
      'Setiap keluarga yang selesai memecahkan es. Saat mencapai nol, boneka bebas.';

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
  String get introGotIt => 'Mengerti';

  @override
  String chapterCompleteTitle(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'BAB $numberString SELESAI';
  }

  @override
  String get chapterCompleteAdded => 'Ditambahkan ke Museum-mu!';

  @override
  String chapterCompleteCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString koin';
  }

  @override
  String chapterCompleteNext(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Berikutnya: Bab $numberString · $name';
  }

  @override
  String get gameplayGenerating => 'Menata rak…';

  @override
  String dailyStreakPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Streak $countString harimu sedang istirahat. Selesaikan teka-teki hari ini untuk menyalakannya lagi.';
  }

  @override
  String get dailyStreakPausedChip => 'Dijeda';

  @override
  String get dailyStreakRelitTitle => 'Streak menyala lagi!';

  @override
  String dailyStreakRelitBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Streak $countString harimu bersinar lagi.';
  }

  @override
  String streakBadgeSemanticsPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Streak $countString hari, dijeda',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => 'Bab';

  @override
  String chaptersOverallProgress(int level, int total) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Level $levelString dari $totalString';
  }

  @override
  String chaptersWonCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString menang';
  }

  @override
  String chaptersBestMoves(int best) {
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Terbaik $bestString';
  }

  @override
  String get chaptersLevelPlay => 'Main';

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
          'Level $levelString, $countString bintang. Terbaik $bestString langkah.',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsWonNoBest(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString, menang';
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
      other: 'Level $levelString, menang. Terbaik $bestString langkah.',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsCurrent(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString, siap dimainkan';
  }

  @override
  String chaptersLevelSemanticsLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString, terkunci';
  }

  @override
  String get recordsTitle => 'Rekor';

  @override
  String get homeRecordsButton => 'Rekor';

  @override
  String get recordsLevelsWon => 'Level dimenangkan';

  @override
  String get recordsFamilies => 'Keluarga diselesaikan';

  @override
  String get recordsRacesHeader => 'Balapan dimenangkan';

  @override
  String get recordsDolls => 'Boneka tersusun';

  @override
  String get recordsDailies => 'Teka-teki harian selesai';

  @override
  String get recordsLongestStreak => 'Streak terpanjang';

  @override
  String get recordsBestMovesLink => 'Langkah terbaik per level';

  @override
  String get recordsBadgesHeader => 'Lencana';

  @override
  String badgeName(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Pas di Tempatnya',
      'glass_breaker': 'Jago Kaca',
      'ice_melter': 'Pemecah Es',
      'tall_order': 'Susunan Tinggi',
      'grand_nest': 'Susunan Agung',
      'level_100': 'Separuh Jalan',
      'level_200': 'Rak Teratas',
      'dailies_7': 'Teman Teka-teki',
      'dailies_30': 'Sahabat Lama',
      'first_race': 'Juara Rak Pertama',
      'all_rivals': 'Semua Lawan',
      'museum_full': 'Rumah Penuh',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeLine(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Kamu menyusun keluarga pertamamu.',
      'glass_breaker': 'Kamu membuka kotak kaca pertamamu.',
      'ice_melter': 'Kamu membebaskan boneka dari es.',
      'tall_order': 'Kamu memenangkan level dengan boneka ukuran 5.',
      'grand_nest': 'Kamu memenangkan level dengan boneka ukuran 6.',
      'level_100': 'Kamu memenangkan level 100.',
      'level_200': 'Kamu memenangkan level 200, yang paling akhir.',
      'dailies_7': 'Kamu menyelesaikan 7 teka-teki harian.',
      'dailies_30': 'Kamu menyelesaikan 30 teka-teki harian.',
      'first_race': 'Kamu mengalahkan komputer dalam balapan.',
      'all_rivals': 'Kamu mengalahkan semua lawan komputer.',
      'museum_full': 'Setiap keluarga sudah pulang ke Museum-mu.',
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
      'first_family': 'Susun satu keluarga penuh.',
      'glass_breaker': 'Buka satu kotak kaca.',
      'ice_melter': 'Bebaskan boneka dari es.',
      'tall_order': 'Menangkan level dengan boneka ukuran 5.',
      'grand_nest': 'Menangkan level dengan boneka ukuran 6.',
      'level_100': 'Menangkan level $levelString.',
      'level_200': 'Menangkan level $levelString.',
      'dailies_7': 'Selesaikan $countString teka-teki harian.',
      'dailies_30': 'Selesaikan $countString teka-teki harian.',
      'first_race': 'Kalahkan komputer dalam balapan.',
      'all_rivals': 'Kalahkan semua lawan komputer.',
      'museum_full': 'Bawa pulang setiap keluarga ke Museum-mu.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeSemanticsEarned(String badge) {
    return '$badge, diraih';
  }

  @override
  String badgeSemanticsLocked(String badge, String how) {
    return '$badge, belum diraih. $how';
  }

  @override
  String badgeEarnedToastTitle(String badge) {
    return 'Lencana diraih · $badge';
  }

  @override
  String get badgeLockedLine => 'Belum diraih';

  @override
  String winMovesBest(int moves, int best) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Langkah $movesString · Terbaik $bestString';
  }

  @override
  String winMovesOnly(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return 'Langkah $movesString';
  }

  @override
  String winChestCountdown(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString level menuju peti',
    );
    return '$_temp0';
  }

  @override
  String get winReplayReason =>
      'Main ulang untuk seru-seruan: koin datang dari level baru.';

  @override
  String get winBackToChapters => 'Kembali ke Bab';

  @override
  String get chestMilestoneTitle => 'Peti pencapaian';

  @override
  String chestMilestoneBody(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Peti karena mencapai level $levelString. Ini isinya.';
  }

  @override
  String chestMilestoneBodyBonus(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Peti untuk level bonus $levelString. Ini isinya.';
  }

  @override
  String chestContentsCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString koin',
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
      other: '+$countString petunjuk',
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
      other: '$coinsString koin',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hints,
      locale: localeName,
      other: '$hintsString petunjuk',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String chestSemantics(String contents) {
    return 'Peti. Isinya: $contents.';
  }

  @override
  String get chestOpen => 'Buka';

  @override
  String get settingRelaxedMode => 'Mode santai';

  @override
  String get settingRelaxedModeSubtitle => 'Urungkan gratis tanpa batas';

  @override
  String get relaxedModeOn =>
      'Mode santai aktif. Urungkan sesering yang kamu mau.';

  @override
  String get settingReduceMotion => 'Kurangi gerakan';

  @override
  String get reduceMotionSystem => 'Sistem';

  @override
  String get reduceMotionOn => 'Nyala';

  @override
  String get reduceMotionOff => 'Mati';

  @override
  String get oomUndoFreeUnlimited => 'Gratis, sesering yang kamu mau';

  @override
  String oomUndoSpent(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString urungkan gratismu sudah terpakai',
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
      other: 'Satu level paling banyak $countString tempat ekstra.',
    );
    return '$_temp0';
  }

  @override
  String get boosterUndoUnlimitedSemantics => 'Urungkan, tanpa batas';

  @override
  String get oomUndoFreeChip => 'Gratis';

  @override
  String boosterLimitSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '+Tempat, $countString dari $totalString terpakai';
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
    return '$booster, disarankan';
  }

  @override
  String get boosterRestartSemantics => 'Ulangi level';

  @override
  String get homeVsComputerTile => 'Lawan Komputer';

  @override
  String homeVsComputerLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Setelah Level $levelString';
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
  String get raceSelectTitle => 'Lawan Komputer';

  @override
  String get raceSelectSubtitle =>
      'Balapan melawan komputer di teka-teki yang sama';

  @override
  String get raceComputerTag => 'Komputer';

  @override
  String raceRivalName(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Komet',
      two: 'Kancing',
      one: 'Kerikil',
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
      other: 'Lincah, rapi, dan sulit dikejar.',
      two: 'Memeriksa tiap langkah dua kali, lalu melangkah.',
      one: 'Santai dan menikmati setiap boneka di sepanjang jalan.',
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
      other: 'Tempo lincah',
      two: 'Tempo stabil',
      one: 'Tempo santai',
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
      other: 'Menangkan $coinsString koin',
    );
    return '$_temp0';
  }

  @override
  String raceRivalLocked(String rival) {
    return 'Kalahkan $rival untuk membuka';
  }

  @override
  String get raceRivalNew => 'Baru';

  @override
  String raceRivalSemantics(String name) {
    return '$name, Komputer';
  }

  @override
  String raceRivalCardSemantics(String rival, String skill) {
    return '$rival, lawan komputer. $skill.';
  }

  @override
  String raceRivalLockedSemantics(String rival) {
    return 'Lawan komputer terkunci. Kalahkan $rival untuk membuka.';
  }

  @override
  String get raceRivalSelectedSemantics => 'Dipilih';

  @override
  String get raceStart => 'Mulai';

  @override
  String get raceStartHint =>
      'Teka-teki sama, dua papan. Selesaikan semua keluarga lebih dulu.';

  @override
  String get raceStripReady => 'Siap saat kamu siap';

  @override
  String get raceStripThinking => 'Berpikir…';

  @override
  String get raceStripStartingOver => 'Mulai dari awal';

  @override
  String get raceStripFinished => 'Selesai';

  @override
  String get raceStripPlayerFinished => 'Kamu selesai lebih dulu';

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
      other: '$name, komputer: $countString dari $totalString keluarga',
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

    return 'Komputer menyelesaikan satu keluarga: $doneString dari $totalString';
  }

  @override
  String raceAnnounceStart(String rival) {
    return 'Balapan dimulai melawan $rival, pemain komputer.';
  }

  @override
  String get raceAnnounceStartingOver => 'Komputer mulai dari awal.';

  @override
  String get raceAnnounceFinished => 'Komputer menyelesaikan semua keluarga.';

  @override
  String get raceAnnounceWon => 'Kamu memenangkan balapan.';

  @override
  String get raceAnnounceLost => 'Komputer selesai lebih dulu.';

  @override
  String get raceWinTitle => 'Kamu menang balapan!';

  @override
  String get raceWinTitleShort => 'Kamu menang!';

  @override
  String raceWinBody(String rival) {
    return 'Semua keluarga selesai. $rival masih menyusun.';
  }

  @override
  String raceWinCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString koin',
    );
    return '$_temp0';
  }

  @override
  String get raceLossTitle => 'Nyaris! Tanding ulang?';

  @override
  String get raceLossTitleShort => 'Nyaris!';

  @override
  String raceLossBody(String rival) {
    return '$rival selesai lebih dulu kali ini. Tanding ulang gratis.';
  }

  @override
  String get raceRivalUnlockedTitle => 'Lawan baru terbuka!';

  @override
  String raceRivalUnlockedBody(String rival) {
    return '$rival siap balapan.';
  }

  @override
  String raceRivalUnlockedRace(String rival) {
    return 'Balapan melawan $rival';
  }

  @override
  String get raceLeaveTitle => 'Keluar dari balapan ini?';

  @override
  String get raceLeaveBody =>
      'Balapan berhenti di sini. Tanpa koin, dan semua milikmu tetap ada.';

  @override
  String get raceLeaveKeep => 'Lanjut balapan';

  @override
  String get raceRematch => 'Tanding ulang';

  @override
  String get raceNewRace => 'Balapan baru';

  @override
  String get raceBackToRivals => 'Kembali ke balapan';

  @override
  String get raceFailedTitle => 'Raknya butuh waktu sebentar';

  @override
  String get raceFailedBody =>
      'Balapan ini tidak bisa disiapkan. Coba lagi, atau pilih balapan lain.';

  @override
  String racePauseSubtitle(String rival) {
    return '$rival juga dijeda.';
  }

  @override
  String racePauseHeader(String rival) {
    return 'Lawan Komputer · $rival';
  }

  @override
  String get raceRivalBeaten => 'Dikalahkan';

  @override
  String raceStartFor(String rival) {
    return 'Mulai balapan melawan $rival';
  }

  @override
  String get raceQuit => 'Keluar dari balapan';

  @override
  String starsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dari 3 bintang',
    );
    return '$_temp0';
  }

  @override
  String starsNewBestSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rekor baru, $count dari 3 bintang',
    );
    return '$_temp0';
  }

  @override
  String winStarsTarget(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return '3 bintang dengan $movesString langkah atau kurang';
  }

  @override
  String get winStarsNewBest => 'Rekor baru!';

  @override
  String get starsFirstTip =>
      'Makin sedikit langkah, makin banyak bintang. Main ulang level mana pun dari Bab.';

  @override
  String get starsHelperNote =>
      'Kemenangan dengan petunjuk atau tempat ekstra mendapat maksimal 2 bintang.';

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
  String get chaptersAllThreeStars => 'Semua level 3 bintang';

  @override
  String chaptersStarsSemantics(int earned, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      earned,
      locale: localeName,
      other: '$earned dari $total bintang',
    );
    return '$_temp0';
  }

  @override
  String get recordsStars => 'Bintang';

  @override
  String recordsStarsValue(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString dari $totalString';
  }

  @override
  String get dailyShare => 'Bagikan';

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
  String get dailyShareSemantics => 'Bagikan hasil hari ini';

  @override
  String dailyShareText(String date, String glyphs, int moves, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'Selesai dalam $moves langkah · Hari $day 🔥',
    );
    return 'Nesty Teka-teki Harian · $date\n$glyphs\n$_temp0';
  }

  @override
  String dailyShareTextNoStreak(String date, String glyphs, int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'Selesai dalam $moves langkah',
    );
    return 'Nesty Teka-teki Harian · $date\n$glyphs\n$_temp0';
  }

  @override
  String get reminderOfferTitle => 'Mau diberi tahu saat teka-teki besok siap?';

  @override
  String get reminderOfferBody =>
      'Satu catatan tenang sehari, pada jam yang kamu pilih. Bisa dimatikan di Pengaturan.';

  @override
  String reminderOfferTime(String time) {
    return 'Setiap hari pukul $time';
  }

  @override
  String get reminderOfferChangeTime => 'Ubah jam';

  @override
  String reminderTimeChipSemantics(String time) {
    return 'Jam pengingat, setiap hari pukul $time. Ubah jam.';
  }

  @override
  String get reminderPickerTitle => 'Jam pengingat';

  @override
  String get reminderOfferYes => 'Ya, ingatkan';

  @override
  String get reminderOfferNo => 'Tidak, terima kasih';

  @override
  String reminderOfferDone(String time) {
    return 'Pengingat diatur pukul $time.';
  }

  @override
  String get reminderOfferDeniedTitle => 'Notifikasi untuk Nesty mati';

  @override
  String reminderOfferDenied(String time) {
    return 'Nyalakan di pengaturan ponselmu, dan catatanmu akan tiba pukul $time.';
  }

  @override
  String get reminderNotificationTitle => 'Nesty';

  @override
  String get reminderNotificationBody => 'Teka-teki hari ini ada di rak.';

  @override
  String get reminderNotificationBody2 =>
      'Teka-teki harian baru menunggumu kapan pun kamu siap.';

  @override
  String get reminderNotificationBody3 =>
      'Boneka baru menunggu untuk disusun. Teka-teki hari ini sudah siap.';

  @override
  String get reminderChannelName => 'Teka-teki harian';

  @override
  String get reminderChannelDescription =>
      'Satu catatan sehari saat teka-teki harian baru siap.';

  @override
  String get settingReminder => 'Pengingat harian';

  @override
  String get settingReminderTime => 'Jam';

  @override
  String get settingReminderBlocked => 'Mati di pengaturan ponselmu';

  @override
  String get settingOpenPhoneSettings => 'Buka pengaturan ponsel';

  @override
  String get settingReminderTurnOff => 'Matikan';

  @override
  String homeChapterKicker(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'BAB $numberString';
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

    return 'Bab $chapterString, $name. $countString dari $totalString bintang. Membuka Bab.';
  }

  @override
  String homeBonusCardSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Level bonus. $countString dari $totalString bintang. Membuka Bab.';
  }

  @override
  String get homeVsComputerSemantics =>
      'Lawan Komputer. Balapan melawan komputer di teka-teki yang sama.';

  @override
  String homeVsComputerLockedSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Lawan Komputer, terkunci. Setelah Level $levelString.';
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

    return 'BAB $numberString · LEVEL $firstString–$lastString';
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

    return 'Bab $chapterString, $name. $countString dari $totalString bintang.';
  }

  @override
  String chaptersRowLockedSemantics(int chapter, String name) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'Bab $chapterString, $name. Terkunci.';
  }

  @override
  String get chaptersLevelChestSemantics => 'Ada peti di level ini';

  @override
  String get chaptersLevelFinaleSemantics => 'Level terakhir bab ini';

  @override
  String museumNicheCollectedSemantics(String name) {
    return '$name, sudah pulang ke Museum-mu';
  }

  @override
  String museumNicheNextSemantics(String name, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, berikutnya yang pulang. $countString level lagi.',
    );
    return '$_temp0';
  }

  @override
  String museumNicheLockedSemantics(String name, int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return '$name, belum pulang. Bab $chapterString.';
  }

  @override
  String museumCountSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString dari $totalString keluarga sudah pulang';
  }

  @override
  String museumFullSub(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Rumah Penuh · semua $countString keluarga';
  }

  @override
  String recordsRaceSemantics(String rival, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$rival, komputer. $countString kemenangan.',
    );
    return '$_temp0';
  }

  @override
  String recordsRaceLockedSemantics(String rival) {
    return '$rival, komputer. Terkunci.';
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
}
