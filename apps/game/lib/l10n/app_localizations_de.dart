// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Nesty';

  @override
  String get splashLoading => 'Lädt…';

  @override
  String progressPercent(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString';
  }

  @override
  String get genericLoadFailed => 'Etwas ist schiefgelaufen.';

  @override
  String get splashStorageTitle => 'Dein Telefon ist fast voll';

  @override
  String splashStorageBody(int size) {
    final intl.NumberFormat sizeNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String sizeString = sizeNumberFormat.format(size);

    return 'Nesty braucht etwa $sizeString MB, um die Regale aufzubauen. Gib etwas Speicher frei und versuche es dann erneut.';
  }

  @override
  String get splashContentTitle => 'Die Regale ließen sich nicht auspacken';

  @override
  String get splashContentBody =>
      'Beim Laden ist etwas schiefgelaufen. Versuche es erneut oder starte Nesty neu.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String levelTitle(int level) {
    return 'Level $level';
  }

  @override
  String get pause => 'Pause';

  @override
  String get boosterUndo => 'Zurück';

  @override
  String get boosterUndoShort => 'Zurück';

  @override
  String get boosterHint => 'Tipp';

  @override
  String get boosterHintShort => 'Tipp';

  @override
  String get boosterExtraSlot => '+Platz';

  @override
  String get boosterExtraSlotShort => '+1';

  @override
  String get restart => 'Neustart';

  @override
  String get restartShort => 'Neustart';

  @override
  String get splashDollSort => 'PUPPEN SORTIEREN';

  @override
  String get splashCaption => 'Die Regale werden abgestaubt…';

  @override
  String get homePlay => 'SPIELEN';

  @override
  String get homeAllLevelsDone => 'Alles geschafft!';

  @override
  String playSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString spielen';
  }

  @override
  String playLevelSemantics(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString spielen, $tier';
  }

  @override
  String coinPillShopSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Münzen. Öffnet den Shop.',
      one: '$countString Münze. Öffnet den Shop.',
    );
    return '$_temp0';
  }

  @override
  String get tierHard => 'SCHWER';

  @override
  String get tierSuperHard => 'EXTREM';

  @override
  String get tierSuperShort => 'EXTREM';

  @override
  String tierName(String tier) {
    String _temp0 = intl.Intl.selectLogic(tier, {
      'easy': 'Leicht',
      'medium': 'Mittel',
      'hard': 'Schwer',
      'superhard': 'Extrem',
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
      other: '$countString von $totalString Familien komplett',
      one: '$countString von $totalString Familie komplett',
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
      other: '$countString Münzen',
      one: '$countString Münze',
    );
    return '$_temp0';
  }

  @override
  String get levelDaily => 'Tagesrätsel';

  @override
  String levelDailySemantics(String date) {
    return 'Tagesrätsel, $date';
  }

  @override
  String bonusLevelTitle(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Bonuslevel $levelString';
  }

  @override
  String get closeSemantics => 'Schließen';

  @override
  String get backSemantics => 'Zurück';

  @override
  String boosterAdSemantics(String booster) {
    return '$booster, Video ansehen';
  }

  @override
  String boosterCoinSemantics(String booster, int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$booster, $priceString Münzen',
      one: '$booster, $priceString Münze',
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
      other: 'Zurück, noch $countString',
      one: 'Zurück, noch $countString',
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
      other: 'Tipp, noch $countString',
      one: 'Tipp, noch $countString',
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
      other: 'Zusätzlicher Platz, noch $countString',
      one: 'Zusätzlicher Platz, noch $countString',
    );
    return '$_temp0';
  }

  @override
  String get softStuckTitle => 'Hmm, das sieht festgefahren aus';

  @override
  String get softStuckBody =>
      'Probier doch Zurück. Du kannst auch einfach weiterspielen.';

  @override
  String get softStuckBodyRestart =>
      'Probier doch Neustart. Du kannst auch einfach weiterspielen.';

  @override
  String get softStuckAction => 'Zurück';

  @override
  String get oomTitle => 'Keine Züge mehr!';

  @override
  String get oomSubtitle => 'Such dir aus, wie du weitersortierst.';

  @override
  String get oomUndoSubtitle => 'Nimm deinen letzten Zug zurück';

  @override
  String oomUndoFree(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gratis · $countString verfügbar',
      one: 'Gratis · $countString verfügbar',
    );
    return '$_temp0';
  }

  @override
  String get oomSlotTitle => '+1 Platz';

  @override
  String get oomSlotSubtitle => 'Füge für dieses Level einen Platz hinzu';

  @override
  String get oomSlotOffline => 'Offline mit Münzen';

  @override
  String get oomRestartSubtitle => 'Starte dieses Level kostenlos neu';

  @override
  String coinPrice(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Münzen',
      one: '$countString Münze',
    );
    return '$_temp0';
  }

  @override
  String get watchAd => 'Werbung ansehen';

  @override
  String get watchAdSemantics => 'Werbung ansehen';

  @override
  String get offlineTitle => 'Offline';

  @override
  String get offlineAds => 'Werbe-Buttons zeigen Münzpreise';

  @override
  String get connectToWatchAd => 'Verbinde dich, um Werbung zu sehen';

  @override
  String get winTitle => 'Level geschafft!';

  @override
  String get winTitleShort => 'Geschafft!';

  @override
  String get winContinue => 'Weiter';

  @override
  String get winTripleCoins => '×3 Münzen';

  @override
  String get winRewardAdded => 'Belohnung hinzugefügt';

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

    return 'Kapitel $numberString';
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
    return 'Als Nächstes: $name';
  }

  @override
  String get winChapterDone => 'Kapitel geschafft! Gleich kommt dein Preis.';

  @override
  String figurineName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'Die Klassik-Familie',
      'sailor': 'Die Matrosen-Familie',
      'baker': 'Die Bäcker-Familie',
      'astronaut': 'Die Astronauten-Familie',
      'gardener': 'Die Gärtner-Familie',
      'snow': 'Die Schnee-Familie',
      'circus': 'Die Zirkus-Familie',
      'musician': 'Die Musiker-Familie',
      'royal': 'Die königliche Familie',
      'explorer': 'Die Entdecker-Familie',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String chapterRibbon(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'KAPITEL $numberString · $name';
  }

  @override
  String chapterRibbonShort(String name) {
    return '$name';
  }

  @override
  String chapterName(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'ch01': 'Sonniger Spielzeugladen',
      'ch02': 'Café-Ecke im Regen',
      'ch03': 'Markt am Meer',
      'ch04': 'Verschneite Hütte',
      'ch05': 'Karneval bei Nacht',
      'ch06': 'Gartenhaus im Frühling',
      'ch07': 'Puppentheater',
      'ch08': 'Herbst-Musikpavillon',
      'ch09': 'Schlossbibliothek',
      'ch10': 'Aussichtspunkt bei Sonnenaufgang',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get pauseTitle => 'Pausiert';

  @override
  String get resume => 'Weiter';

  @override
  String get home => 'Start';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingSound => 'Ton';

  @override
  String get settingMusic => 'Musik';

  @override
  String get settingHaptics => 'Vibration';

  @override
  String get allLevelsTitle => 'Du hast alle Level geschafft!';

  @override
  String get allLevelsBody =>
      'Neue Kapitel kommen bald. Spiele in der Zwischenzeit Bonuslevel.';

  @override
  String allLevelsPlayBonus(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Bonuslevel $numberString spielen';
  }

  @override
  String get allLevelsBackHome => 'Zurück zum Start';

  @override
  String get nextLevelFailedHome => 'Zurück zum Start';

  @override
  String get gameplayFailedTitle => 'Die Regale brauchen einen Moment';

  @override
  String get gameplayFailedBody =>
      'Dieses Level ließ sich nicht aufbauen. Versuche es erneut oder geh zurück zum Start.';

  @override
  String get devLevelPickerTitle => 'Zu einem Level springen';

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

    return 'Kapitel $numberString · Level $startString–$endString';
  }

  @override
  String get navShop => 'Shop';

  @override
  String get navHomeShort => 'Start';

  @override
  String get navShopShort => 'Shop';

  @override
  String get navMuseum => 'Museum';

  @override
  String get navMuseumShort => 'Museum';

  @override
  String get homeDailyTile => 'Tagesrätsel';

  @override
  String get homeMuseumTile => 'Museum';

  @override
  String get homeRemoveAdsTile => 'Werbung entfernen';

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

    return 'Nach Level $levelString';
  }

  @override
  String get homeBonusBadge => 'BONUS';

  @override
  String get homeBonusKicker => 'ENDLOS-BONUS';

  @override
  String get homeBonusName => 'Bonuslevel';

  @override
  String streakBadgeSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serie: $countString Tage',
      one: 'Serie: $countString Tag',
    );
    return '$_temp0';
  }

  @override
  String get settingColorSymbols => 'Farbsymbole';

  @override
  String get symbolsSubtle => 'Dezent';

  @override
  String get symbolsLarge => 'Groß';

  @override
  String get settingLanguage => 'Sprache';

  @override
  String get settingRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get settingPrivacyChoices => 'Datenschutzoptionen';

  @override
  String get settingPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get settingSupport => 'Support';

  @override
  String get settingSupportValue => 'Schreib uns';

  @override
  String settingsFooter(String version, String build, String playerId) {
    return 'Nesty: Doll Sort · v$version (Build $build) · Spieler-ID $playerId';
  }

  @override
  String get languageSheetTitle => 'Sprache';

  @override
  String get languageSheetDone => 'Fertig';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'Englisch',
      'es': 'Spanisch',
      'pt_BR': 'Portugiesisch',
      'id': 'Indonesisch',
      'hi': 'Hindi',
      'de': 'Deutsch',
      'fr': 'Französisch',
      'tr': 'Türkisch',
      'ja': 'Japanisch',
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
      other: '$countString Tage',
      one: '$countString Tag',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakKeep => 'Spiele heute, um deine Serie zu verlängern';

  @override
  String get dailyStreakStart =>
      'Löse das heutige Rätsel, um deine erste Flamme zu entzünden.';

  @override
  String get dailyStreakDone => 'Deine Flamme brennt. Bis morgen.';

  @override
  String get dailyStreakWeek => 'Eine ganze Woche!';

  @override
  String dailyFreezes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString× Schutz',
      one: '$countString Schutz',
      zero: 'Kein Schutz',
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
      other: '$countString Serienschutz',
      one: '$countString Serienschutz',
    );
    return '$_temp0';
  }

  @override
  String get dailyDay => 'Tag';

  @override
  String get dailyToday => 'Heute';

  @override
  String get dailyTomorrow => 'Morgen';

  @override
  String dailyDaySemantics(String state, int day) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'done': 'Tag $day, geschafft',
      'today': 'Heute, Tag $day',
      'tomorrow': 'Morgen, Tag $day',
      'chest': 'Tag $day, Truhe',
      'other': 'Tag $day',
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
      other: 'Spielen, $countString Münzen',
      one: 'Spielen, $countString Münze',
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
      other: 'Truhe an Tag 7 · $countString Münzen',
      one: 'Truhe an Tag 7 · $countString Münze',
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
      other: 'Noch $countString Tage',
      one: 'Noch $countString Tag',
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
      other: 'Noch $countString Tage, heute mitgezählt',
      one: 'Noch $countString Tag, heute mitgezählt',
    );
    return '$_temp0';
  }

  @override
  String get dailyChestOpenedToday => 'Heute geöffnet';

  @override
  String dailyPuzzleTitle(String weekday) {
    return 'Rätsel vom $weekday';
  }

  @override
  String dailyPuzzleInfo(int colors, String tier) {
    final intl.NumberFormat colorsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String colorsString = colorsNumberFormat.format(colors);

    String _temp0 = intl.Intl.pluralLogic(
      colors,
      locale: localeName,
      other: '$colorsString Farben',
      one: '$colorsString Farbe',
    );
    return '$_temp0 · $tier';
  }

  @override
  String get dailyPlay => 'Spielen';

  @override
  String dailySolvedChip(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return 'Gelöst · +$coinsString';
  }

  @override
  String dailyNextPuzzle(String time) {
    return 'Nächstes Rätsel in $time';
  }

  @override
  String dailyCountdown(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString Std. $minutesString Min.';
  }

  @override
  String playLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString spielen';
  }

  @override
  String get dailySavedTitle =>
      'Ein Schutz hat deine Flamme am Brennen gehalten.';

  @override
  String dailySavedBody(String weekday) {
    return 'Ein Schutz hat den $weekday abgedeckt. Nächste Woche bekommst du einen neuen.';
  }

  @override
  String get dailyChestTitle => '7-Tage-Serie!';

  @override
  String get dailyChestBody => 'Sieben Tage am Stück. Das steckt drin.';

  @override
  String get dailyChestDouble => 'Verdoppeln';

  @override
  String get dailyChestCollect => 'Einsammeln';

  @override
  String get dailyWinTitle => 'Tagesrätsel gelöst!';

  @override
  String dailyWinStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serie: $countString Tage',
      one: 'Serie: $countString Tag',
    );
    return '$_temp0';
  }

  @override
  String dailyWinChestHint(String count) {
    String _temp0 = intl.Intl.selectLogic(count, {
      '0': 'Deine Truhe für Tag 7 ist bereit!',
      '1': 'Noch ein Tag bis zur Truhe von Tag 7',
      '2': 'Noch zwei Tage bis zur Truhe von Tag 7',
      '3': 'Noch drei Tage bis zur Truhe von Tag 7',
      '4': 'Noch vier Tage bis zur Truhe von Tag 7',
      '5': 'Noch fünf Tage bis zur Truhe von Tag 7',
      '6': 'Noch sechs Tage bis zur Truhe von Tag 7',
      'other': 'Noch $count Tage bis zur Truhe von Tag 7',
    });
    return '$_temp0';
  }

  @override
  String get dailyBackToDaily => 'Zurück zum Tagesrätsel';

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
      other: 'Kapitel $chapterString · noch $countString Level',
      one: 'Kapitel $chapterString · noch $countString Level',
    );
    return '$_temp0';
  }

  @override
  String get museumAllHome => 'Jede Familie ist zu Hause.';

  @override
  String get museumNextFamily => 'Nächste Familie';

  @override
  String get museumNextFamilyKicker => 'NÄCHSTE FAMILIE';

  @override
  String museumFamilyLabel(String name) {
    return 'Familie $name';
  }

  @override
  String museumSoonLabel(String name) {
    return '$name · demnächst';
  }

  @override
  String figurineShortName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'Klassik',
      'sailor': 'Matrose',
      'baker': 'Bäcker',
      'astronaut': 'Astronaut',
      'gardener': 'Gärtner',
      'snow': 'Schnee',
      'circus': 'Zirkus',
      'musician': 'Musiker',
      'royal': 'Royal',
      'explorer': 'Entdecker',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String figurineFlavor(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': '„Die Kleinste gewinnt jedes Versteckspiel.“',
      'sailor':
          '„Sie halten in der kleinsten Puppe eine Muschel bereit, für alle Fälle.“',
      'baker':
          '„Sie backen jedes Brot in vier Größen, damit niemand teilen muss.“',
      'astronaut':
          '„Vor jeder Reise zum Mond zählen sie von der Größten zur Kleinsten herunter.“',
      'gardener':
          '„Unter jedem Hut steckt ein Samenkorn, das sie für den Frühling aufheben.“',
      'snow':
          '„Wenn gerade niemand hinsieht, stapeln sie sich zu einem Schneemann.“',
      'circus':
          '„Ihre beste Nummer: ineinanderklettern, unter großem Applaus.“',
      'musician':
          '„Sie spielen ein Lied in vier Größen. Die Kleinste übernimmt die hohen Töne.“',
      'royal': '„Jede Krone passt in die nächste, das spart viel Platz.“',
      'explorer':
          '„Sie haben jedes Regal im Laden vermessen, und fertig sind sie noch lange nicht.“',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String museumChapterChip(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Kapitel $numberString · $name';
  }

  @override
  String museumCollectedOn(String date) {
    return 'Gesammelt · $date';
  }

  @override
  String get museumCollected => 'Gesammelt';

  @override
  String museumLockedText(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Schließe Kapitel $numberString ab, um diese Familie nach Hause zu holen.';
  }

  @override
  String museumIntro(int levels) {
    final intl.NumberFormat levelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelsString = levelsNumberFormat.format(levels);

    return 'Jedes Kapitel hat eine Puppenfamilie. Gewinne alle $levelsString Level, um diese Familie nach Hause zu holen.';
  }

  @override
  String museumLevelsToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'noch $countString Level',
      one: 'noch $countString Level',
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
      other: 'noch $countString',
      one: 'noch $countString',
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

    return 'Kap. $chapterString · $firstString–$lastString';
  }

  @override
  String museumLockedLine1(int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'Kapitel $chapterString';
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
  String get shopTitle => 'Shop';

  @override
  String get shopTabCoins => 'Münzen';

  @override
  String get shopTabSkins => 'Skins';

  @override
  String get shopTabThemes => 'Themen';

  @override
  String get shopTabNoAds => 'Werbefrei';

  @override
  String get shopEquipped => 'Ausgewählt';

  @override
  String get shopEquip => 'Auswählen';

  @override
  String get skinOwnedSemantics => 'Im Besitz';

  @override
  String skinName(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Klassik',
      'space': 'Weltraum',
      'ocean': 'Ozean',
      'sweets': 'Süßigkeiten',
      'forest': 'Waldfreunde',
      'winter': 'Winter',
      'forest_bear': 'Waldbär',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String skinDescription(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Gemalte Blumen, goldene Punkte und eine kleine Schleife.',
      'ocean': 'Matrosenkragen, winzige Anker und Wellenborten.',
      'space': 'Runde Helme, winzige Antennen und Planeten mit Ringen.',
      'sweets': 'Zuckerguss-Tropfen, Streusel und Zuckerstreifen.',
      'forest': 'Spitze Ohren, Kapuzen mit Perlenrand und fallende Blätter.',
      'winter': 'Bommelmützen, Schneeflocken und perlmuttfarbene Borten.',
      'forest_bear':
          'Runde Bärenohren, kuschelige Kapuzen und Eicheln im Laub.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get skinDetailTitle => 'Skin';

  @override
  String get skinDetailColors => 'Alle 11 Farben · Symbole bleiben';

  @override
  String get skinDetailSizes =>
      'Jede Größe steckt gleich ineinander. Nur die Farbe ändert sich.';

  @override
  String get shopBuy => 'Kaufen';

  @override
  String shopBuySemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kaufen, $countString Münzen',
      one: 'Kaufen, $countString Münze',
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
      other: 'Du hast $countString Münzen',
      one: 'Du hast $countString Münze',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsTitle => 'Noch ein paar Münzen';

  @override
  String notEnoughCoinsNeeded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Du brauchst $countString Münzen mehr',
      one: 'Du brauchst $countString Münze mehr',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsSource =>
      'Münzen bekommst du für gewonnene Level, das Tagesrätsel und Truhen.';

  @override
  String get notEnoughCoinsGoToShop => 'Zum Shop';

  @override
  String get notNow => 'Später';

  @override
  String shopDownloading(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'Download $percentString %';
  }

  @override
  String get themesMatchTitle => 'Passend zum Kapitel';

  @override
  String get themesMatchSubtitle => 'Nutzt das Thema des aktuellen Kapitels';

  @override
  String get themeInUse => 'Aktiv';

  @override
  String get themeUse => 'Nutzen';

  @override
  String themeChapterLock(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Kap. $numberString';
  }

  @override
  String get shopClosedTitle => 'Der Shop ist vorerst geschlossen';

  @override
  String get shopClosedBody =>
      'Münzpakete und „Werbefrei“ kommen mit einem späteren Update.';

  @override
  String buyUndoText(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Deine $countString Gratis-Rücknahmen sind verbraucht. Nimm einen weiteren Zug zurück.',
      one:
          'Deine $countString Gratis-Rücknahme ist verbraucht. Nimm einen weiteren Zug zurück.',
    );
    return '$_temp0';
  }

  @override
  String get buyHintText => 'Zeigt dir deinen nächsten besten Zug.';

  @override
  String get buySlotText => 'Fügt für dieses Level einen leeren Platz hinzu.';

  @override
  String get tutorialStep1Title => 'Tippe auf die kleine Puppe';

  @override
  String tutorialStepChip(int step, int total) {
    return 'SCHRITT $step VON $total';
  }

  @override
  String get tutorialStep1Text =>
      'Puppen stecken ineinander, wenn die Farbe passt, immer eine Größe größer.';

  @override
  String get tutorialStep2Title => 'Tippe nun auf die große';

  @override
  String get tutorialStep2Text =>
      'Die kleine Puppe fällt mit einem Klack hinein.';

  @override
  String get tutorialStep3Title => 'Schließe die Familie ab';

  @override
  String get tutorialStep3Text =>
      'Stecke die letzte Puppe hinein. Eine Familie ist fertig, wenn alle Größen ineinanderstecken.';

  @override
  String tutorialStepSemantics(int step, String title) {
    final intl.NumberFormat stepNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String stepString = stepNumberFormat.format(step);

    return 'Schritt $stepString von 3. $title';
  }

  @override
  String get tutorialSwallowChip => 'NEUER ZUG';

  @override
  String get tutorialSwallowTitle => 'Groß verschluckt Klein';

  @override
  String get tutorialSwallowText =>
      'Setze eine große Puppe auf die nächstkleinere Größe, und sie schließt sich darüber.';

  @override
  String get introNew => 'NEU';

  @override
  String get introTowersTitle => 'Türme!';

  @override
  String get introTowersText =>
      'Nur die oberste Puppe kann sich bewegen. Räume sie weg, dann siehst du die Puppe darunter.';

  @override
  String get introGlassTitle => 'Vitrinen';

  @override
  String get introGlassText =>
      'Eine eingeschlossene Puppe wird frei, sobald die Familie auf ihrem Schloss komplett ist.';

  @override
  String get introIceTitle => 'Eis';

  @override
  String get introIceText =>
      'Jede fertige Familie lässt das Eis springen. Bei null ist die Puppe frei.';

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
  String get introGotIt => 'Verstanden';

  @override
  String chapterCompleteTitle(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'KAPITEL $numberString GESCHAFFT';
  }

  @override
  String get chapterCompleteAdded => 'Zu deinem Museum hinzugefügt!';

  @override
  String chapterCompleteCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString Münzen',
      one: '+$countString Münze',
    );
    return '$_temp0';
  }

  @override
  String chapterCompleteNext(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Als Nächstes: Kapitel $numberString · $name';
  }

  @override
  String get gameplayGenerating => 'Die Regale werden aufgebaut…';

  @override
  String dailyStreakPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Deine Serie von $countString Tagen ruht. Löse das heutige Rätsel, um sie neu zu entfachen.',
      one:
          'Deine Serie von $countString Tag ruht. Löse das heutige Rätsel, um sie neu zu entfachen.',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakPausedChip => 'Pausiert';

  @override
  String get dailyStreakRelitTitle => 'Serie neu entfacht!';

  @override
  String dailyStreakRelitBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deine Serie von $countString Tagen leuchtet wieder.',
      one: 'Deine Serie von $countString Tag leuchtet wieder.',
    );
    return '$_temp0';
  }

  @override
  String streakBadgeSemanticsPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serie: $countString Tage, pausiert',
      one: 'Serie: $countString Tag, pausiert',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => 'Kapitel';

  @override
  String chaptersOverallProgress(int level, int total) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Level $levelString von $totalString';
  }

  @override
  String chaptersWonCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString gewonnen';
  }

  @override
  String chaptersBestMoves(int best) {
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Bestwert $bestString';
  }

  @override
  String get chaptersLevelPlay => 'Spielen';

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
          'Level $levelString, $countString Sterne. Bestwert in Zügen: $bestString.',
      one:
          'Level $levelString, $countString Stern. Bestwert in Zügen: $bestString.',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsWonNoBest(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString, gewonnen';
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
      other: 'Level $levelString, gewonnen. Bestwert: $bestString Züge.',
      one: 'Level $levelString, gewonnen. Bestwert: $bestString Zug.',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsCurrent(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString, als Nächstes dran';
  }

  @override
  String chaptersLevelSemanticsLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString, gesperrt';
  }

  @override
  String get recordsTitle => 'Rekorde';

  @override
  String get homeRecordsButton => 'Rekorde';

  @override
  String get recordsLevelsWon => 'Gewonnene Level';

  @override
  String get recordsFamilies => 'Fertige Familien';

  @override
  String get recordsRacesHeader => 'Gewonnene Rennen';

  @override
  String get recordsDolls => 'Gesteckte Puppen';

  @override
  String get recordsDailies => 'Gelöste Tagesrätsel';

  @override
  String get recordsLongestStreak => 'Längste Serie';

  @override
  String get recordsBestMovesLink => 'Bestwerte pro Level';

  @override
  String get recordsBadgesHeader => 'Abzeichen';

  @override
  String badgeName(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Kuschelig',
      'glass_breaker': 'Glasklare Sache',
      'ice_melter': 'Eisbrecher',
      'tall_order': 'Hoch hinaus',
      'grand_nest': 'Großes Nest',
      'level_100': 'Halbzeit',
      'level_200': 'Ganz oben im Regal',
      'dailies_7': 'Rätselfreund',
      'dailies_30': 'Alter Freund',
      'first_race': 'Erster im Regal',
      'all_rivals': 'Alle Gegner',
      'museum_full': 'Volles Haus',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeLine(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Du hast deine erste Familie ineinandergesteckt.',
      'glass_breaker': 'Du hast deine erste Vitrine geöffnet.',
      'ice_melter': 'Du hast eine Puppe aus dem Eis befreit.',
      'tall_order': 'Du hast ein Level mit Puppen der Größe 5 gewonnen.',
      'grand_nest': 'Du hast ein Level mit Puppen der Größe 6 gewonnen.',
      'level_100': 'Du hast Level 100 gewonnen.',
      'level_200': 'Du hast Level 200 gewonnen, das allerletzte.',
      'dailies_7': 'Du hast 7 Tagesrätsel gelöst.',
      'dailies_30': 'Du hast 30 Tagesrätsel gelöst.',
      'first_race': 'Du hast den Computer in einem Rennen besiegt.',
      'all_rivals': 'Du hast jeden Computer-Gegner besiegt.',
      'museum_full': 'Jede Familie ist in deinem Museum zu Hause.',
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
      'first_family': 'Stecke eine ganze Familie ineinander.',
      'glass_breaker': 'Öffne eine Vitrine.',
      'ice_melter': 'Befreie eine Puppe aus dem Eis.',
      'tall_order': 'Gewinne ein Level mit Puppen der Größe 5.',
      'grand_nest': 'Gewinne ein Level mit Puppen der Größe 6.',
      'level_100': 'Gewinne Level $levelString.',
      'level_200': 'Gewinne Level $levelString.',
      'dailies_7': 'Löse $countString Tagesrätsel.',
      'dailies_30': 'Löse $countString Tagesrätsel.',
      'first_race': 'Besiege den Computer in einem Rennen.',
      'all_rivals': 'Besiege jeden Computer-Gegner.',
      'museum_full': 'Hole jede Familie in dein Museum.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeSemanticsEarned(String badge) {
    return '$badge, erhalten';
  }

  @override
  String badgeSemanticsLocked(String badge, String how) {
    return '$badge, noch nicht erhalten. $how';
  }

  @override
  String badgeEarnedToastTitle(String badge) {
    return 'Abzeichen erhalten · $badge';
  }

  @override
  String get badgeLockedLine => 'Noch nicht erhalten';

  @override
  String winMovesBest(int moves, int best) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Züge $movesString · Bestwert $bestString';
  }

  @override
  String winMovesOnly(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return 'Züge $movesString';
  }

  @override
  String winChestCountdown(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Level bis zur Truhe',
      one: '$countString Level bis zur Truhe',
    );
    return '$_temp0';
  }

  @override
  String get winReplayReason =>
      'Eine Wiederholung zum Spaß: Münzen gibt es für neue Level.';

  @override
  String get winBackToChapters => 'Zurück zu den Kapiteln';

  @override
  String get chestMilestoneTitle => 'Meilensteintruhe';

  @override
  String chestMilestoneBody(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Eine Truhe fürs Erreichen von Level $levelString. Das steckt drin.';
  }

  @override
  String chestMilestoneBodyBonus(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Eine Truhe für Bonuslevel $levelString. Das steckt drin.';
  }

  @override
  String chestContentsCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString Münzen',
      one: '+$countString Münze',
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
      other: '+$countString Tipps',
      one: '+$countString Tipp',
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
      other: '$coinsString Münzen',
      one: '$coinsString Münze',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hints,
      locale: localeName,
      other: '$hintsString Tipps',
      one: '$hintsString Tipp',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String chestSemantics(String contents) {
    return 'Truhe. Inhalt: $contents.';
  }

  @override
  String get chestOpen => 'Öffnen';

  @override
  String get settingRelaxedMode => 'Entspannter Modus';

  @override
  String get settingRelaxedModeSubtitle => 'Unbegrenzte Gratis-Rücknahmen';

  @override
  String get relaxedModeOn =>
      'Der entspannte Modus ist an. Nimm Züge so oft zurück, wie du magst.';

  @override
  String get settingReduceMotion => 'Bewegung reduzieren';

  @override
  String get reduceMotionSystem => 'System';

  @override
  String get reduceMotionOn => 'An';

  @override
  String get reduceMotionOff => 'Aus';

  @override
  String get oomUndoFreeUnlimited => 'Gratis, so oft du magst';

  @override
  String oomUndoSpent(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deine $countString Gratis-Rücknahmen sind verbraucht',
      one: 'Deine $countString Gratis-Rücknahme ist verbraucht',
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
      other: '$countString zusätzliche Plätze sind pro Level das Maximum.',
      one: 'Ein zusätzlicher Platz ist pro Level das Maximum.',
    );
    return '$_temp0';
  }

  @override
  String get boosterUndoUnlimitedSemantics => 'Zurück, unbegrenzt';

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

    return '+Platz, $countString von $totalString genutzt';
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
    return '$booster, empfohlen';
  }

  @override
  String get boosterRestartSemantics => 'Level neu starten';

  @override
  String get homeVsComputerTile => 'vs. Computer';

  @override
  String homeVsComputerLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Nach Level $levelString';
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
  String get raceSelectTitle => 'vs. Computer';

  @override
  String get raceSelectSubtitle =>
      'Tritt im selben Rätsel gegen einen Computer an';

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
      other: 'Komet',
      two: 'Knopf',
      one: 'Kiesel',
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
      other: 'Flott und ordentlich, kaum einzuholen.',
      two: 'Prüft jeden Zug zweimal und macht ihn dann.',
      one: 'Lässt sich Zeit und genießt jede Puppe.',
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
      other: 'Flottes Tempo',
      two: 'Gleichmäßiges Tempo',
      one: 'Gemütliches Tempo',
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
      other: 'Gewinne $coinsString Münzen',
      one: 'Gewinne $coinsString Münze',
    );
    return '$_temp0';
  }

  @override
  String raceRivalLocked(String rival) {
    return 'Besiege $rival zum Freischalten';
  }

  @override
  String get raceRivalNew => 'Neu';

  @override
  String raceRivalSemantics(String name) {
    return '$name, Computer';
  }

  @override
  String raceRivalCardSemantics(String rival, String skill) {
    return '$rival, Computer-Gegner. $skill.';
  }

  @override
  String raceRivalLockedSemantics(String rival) {
    return 'Gesperrter Computer-Gegner. Besiege $rival zum Freischalten.';
  }

  @override
  String get raceRivalSelectedSemantics => 'Ausgewählt';

  @override
  String get raceStart => 'Start';

  @override
  String get raceStartHint =>
      'Gleiches Rätsel, zwei Spielfelder. Wer zuerst alle Familien abschließt, gewinnt.';

  @override
  String get raceStripReady => 'Bereit, wenn du es bist';

  @override
  String get raceStripThinking => 'Überlegt…';

  @override
  String get raceStripStartingOver => 'Fängt neu an';

  @override
  String get raceStripFinished => 'Fertig';

  @override
  String get raceStripPlayerFinished => 'Du warst zuerst fertig';

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
      other: '$name, Computer: $countString von $totalString Familien',
      one: '$name, Computer: $countString von $totalString Familie',
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

    return 'Der Computer hat eine Familie abgeschlossen: $doneString von $totalString';
  }

  @override
  String raceAnnounceStart(String rival) {
    return 'Rennen gestartet gegen $rival, einen Computer-Gegner.';
  }

  @override
  String get raceAnnounceStartingOver => 'Der Computer fängt neu an.';

  @override
  String get raceAnnounceFinished =>
      'Der Computer hat alle Familien abgeschlossen.';

  @override
  String get raceAnnounceWon => 'Du hast das Rennen gewonnen.';

  @override
  String get raceAnnounceLost => 'Der Computer war zuerst fertig.';

  @override
  String get raceWinTitle => 'Du hast das Rennen gewonnen!';

  @override
  String get raceWinTitleShort => 'Gewonnen!';

  @override
  String raceWinBody(String rival) {
    return 'Alle Familien sind komplett. $rival sortierte noch.';
  }

  @override
  String raceWinCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString Münzen',
      one: '+$countString Münze',
    );
    return '$_temp0';
  }

  @override
  String get raceLossTitle => 'Knapp! Revanche?';

  @override
  String get raceLossTitleShort => 'Knapp!';

  @override
  String raceLossBody(String rival) {
    return '$rival war diesmal zuerst fertig. Eine Revanche kostet nichts.';
  }

  @override
  String get raceRivalUnlockedTitle => 'Neuer Gegner!';

  @override
  String raceRivalUnlockedBody(String rival) {
    return '$rival wartet auf ein Rennen.';
  }

  @override
  String raceRivalUnlockedRace(String rival) {
    return 'Rennen gegen $rival';
  }

  @override
  String get raceLeaveTitle => 'Dieses Rennen verlassen?';

  @override
  String get raceLeaveBody =>
      'Das Rennen stoppt hier. Keine Münzen, aber du behältst alles.';

  @override
  String get raceLeaveKeep => 'Weiterrennen';

  @override
  String get raceRematch => 'Revanche';

  @override
  String get raceNewRace => 'Neues Rennen';

  @override
  String get raceBackToRivals => 'Zurück zu den Rennen';

  @override
  String get raceFailedTitle => 'Die Regale brauchen einen Moment';

  @override
  String get raceFailedBody =>
      'Dieses Rennen ließ sich nicht aufbauen. Versuche es erneut oder wähle ein anderes Rennen.';

  @override
  String racePauseSubtitle(String rival) {
    return '$rival macht auch Pause.';
  }

  @override
  String racePauseHeader(String rival) {
    return 'vs. Computer · $rival';
  }

  @override
  String get raceRivalBeaten => 'Besiegt';

  @override
  String raceStartFor(String rival) {
    return 'Rennen gegen $rival starten';
  }

  @override
  String get raceQuit => 'Rennen verlassen';

  @override
  String starsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count von 3 Sternen',
      one: '$count von 3 Sternen',
    );
    return '$_temp0';
  }

  @override
  String starsNewBestSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Neuer Bestwert, $count von 3 Sternen',
      one: 'Neuer Bestwert, $count von 3 Sternen',
    );
    return '$_temp0';
  }

  @override
  String winStarsTarget(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return '3 Sterne mit $movesString Zügen oder weniger';
  }

  @override
  String get winStarsNewBest => 'Neuer Bestwert!';

  @override
  String get starsFirstTip =>
      'Weniger Züge, mehr Sterne. Spiele jedes Level aus den Kapiteln noch einmal.';

  @override
  String get starsHelperNote =>
      'Siege mit Tipp oder zusätzlichem Platz bringen bis zu 2 Sterne.';

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
  String get chaptersAllThreeStars => 'Jedes Level mit 3 Sternen';

  @override
  String chaptersStarsSemantics(int earned, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      earned,
      locale: localeName,
      other: '$earned von $total Sternen',
      one: '$earned von $total Sternen',
    );
    return '$_temp0';
  }

  @override
  String get recordsStars => 'Sterne';

  @override
  String recordsStarsValue(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString von $totalString';
  }

  @override
  String get dailyShare => 'Teilen';

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
  String get dailyShareSemantics => 'Heutiges Ergebnis teilen';

  @override
  String dailyShareText(String date, String glyphs, int moves, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'In $moves Zügen gelöst · Tag $day 🔥',
      one: 'In $moves Zug gelöst · Tag $day 🔥',
    );
    return 'Nesty Tagesrätsel · $date\n$glyphs\n$_temp0';
  }

  @override
  String dailyShareTextNoStreak(String date, String glyphs, int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'In $moves Zügen gelöst',
      one: 'In $moves Zug gelöst',
    );
    return 'Nesty Tagesrätsel · $date\n$glyphs\n$_temp0';
  }

  @override
  String get reminderOfferTitle =>
      'Eine Nachricht, wenn das Rätsel von morgen bereit ist?';

  @override
  String get reminderOfferBody =>
      'Eine ruhige Nachricht pro Tag, zur Uhrzeit deiner Wahl. In den Einstellungen kannst du sie ausschalten.';

  @override
  String reminderOfferTime(String time) {
    return 'Jeden Tag um $time';
  }

  @override
  String get reminderOfferChangeTime => 'Uhrzeit ändern';

  @override
  String reminderTimeChipSemantics(String time) {
    return 'Erinnerungszeit, jeden Tag um $time. Uhrzeit ändern.';
  }

  @override
  String get reminderPickerTitle => 'Erinnerungszeit';

  @override
  String get reminderOfferYes => 'Ja, erinnere mich';

  @override
  String get reminderOfferNo => 'Nein danke';

  @override
  String reminderOfferDone(String time) {
    return 'Erinnerung für $time eingestellt.';
  }

  @override
  String get reminderOfferDeniedTitle =>
      'Benachrichtigungen für Nesty sind aus';

  @override
  String reminderOfferDenied(String time) {
    return 'Schalte sie in den Einstellungen deines Telefons ein, dann kommt deine Nachricht um $time.';
  }

  @override
  String get reminderNotificationTitle => 'Nesty';

  @override
  String get reminderNotificationBody => 'Das heutige Rätsel steht im Regal.';

  @override
  String get reminderNotificationBody2 =>
      'Ein frisches Tagesrätsel wartet auf dich, wann immer du magst.';

  @override
  String get reminderNotificationBody3 =>
      'Neue Puppen warten darauf, ineinandergesteckt zu werden. Das heutige Rätsel ist bereit.';

  @override
  String get reminderChannelName => 'Tagesrätsel';

  @override
  String get reminderChannelDescription =>
      'Eine Nachricht pro Tag, wenn ein neues Tagesrätsel bereit ist.';

  @override
  String get settingReminder => 'Tägliche Erinnerung';

  @override
  String get settingReminderTime => 'Uhrzeit';

  @override
  String get settingReminderBlocked => 'In den Telefoneinstellungen aus';

  @override
  String get settingOpenPhoneSettings => 'Telefoneinstellungen öffnen';

  @override
  String get settingReminderTurnOff => 'Ausschalten';

  @override
  String homeChapterKicker(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'KAPITEL $numberString';
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

    return 'Kapitel $chapterString, $name. $countString von $totalString Sternen. Öffnet die Kapitel.';
  }

  @override
  String homeBonusCardSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Bonuslevel. $countString von $totalString Sternen. Öffnet die Kapitel.';
  }

  @override
  String get homeVsComputerSemantics =>
      'vs. Computer. Tritt im selben Rätsel gegen einen Computer an.';

  @override
  String homeVsComputerLockedSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'vs. Computer, gesperrt. Nach Level $levelString.';
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

    return 'KAPITEL $numberString · LEVEL $firstString–$lastString';
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

    return 'Kapitel $chapterString, $name. $countString von $totalString Sternen.';
  }

  @override
  String chaptersRowLockedSemantics(int chapter, String name) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'Kapitel $chapterString, $name. Gesperrt.';
  }

  @override
  String get chaptersLevelChestSemantics => 'Eine Truhe in diesem Level';

  @override
  String get chaptersLevelFinaleSemantics => 'Das letzte Level des Kapitels';

  @override
  String museumNicheCollectedSemantics(String name) {
    return '$name, im Museum zu Hause';
  }

  @override
  String museumNicheNextSemantics(String name, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, kommt als Nächstes nach Hause. Noch $countString Level.',
      one: '$name, kommt als Nächstes nach Hause. Noch $countString Level.',
    );
    return '$_temp0';
  }

  @override
  String museumNicheLockedSemantics(String name, int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return '$name, noch nicht zu Hause. Kapitel $chapterString.';
  }

  @override
  String museumCountSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString von $totalString Familien zu Hause';
  }

  @override
  String museumFullSub(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Volles Haus · alle $countString Familien';
  }

  @override
  String recordsRaceSemantics(String rival, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$rival, Computer. $countString Siege.',
      one: '$rival, Computer. $countString Sieg.',
    );
    return '$_temp0';
  }

  @override
  String recordsRaceLockedSemantics(String rival) {
    return '$rival, Computer. Gesperrt.';
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
