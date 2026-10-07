// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Nesty';

  @override
  String get splashLoading => 'Chargement…';

  @override
  String progressPercent(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString';
  }

  @override
  String get genericLoadFailed => 'Un problème est survenu.';

  @override
  String get splashStorageTitle => 'Ton téléphone est presque plein';

  @override
  String splashStorageBody(int size) {
    final intl.NumberFormat sizeNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String sizeString = sizeNumberFormat.format(size);

    return 'Nesty a besoin d’environ $sizeString Mo pour installer les étagères. Libère de l’espace, puis réessaie.';
  }

  @override
  String get splashContentTitle => 'Les étagères ne se sont pas déballées';

  @override
  String get splashContentBody =>
      'Un problème est survenu pendant le chargement. Réessaie ou redémarre Nesty.';

  @override
  String get retry => 'Réessayer';

  @override
  String levelTitle(int level) {
    return 'Niveau $level';
  }

  @override
  String get pause => 'Pause';

  @override
  String get boosterUndo => 'Annuler';

  @override
  String get boosterUndoShort => 'Annuler';

  @override
  String get boosterHint => 'Indice';

  @override
  String get boosterHintShort => 'Indice';

  @override
  String get boosterExtraSlot => '+Place';

  @override
  String get boosterExtraSlotShort => '+1';

  @override
  String get restart => 'Recommencer';

  @override
  String get restartShort => 'Rejouer';

  @override
  String get splashDollSort => 'TRI DE POUPÉES';

  @override
  String get splashCaption => 'On dépoussière les étagères…';

  @override
  String get homePlay => 'JOUER';

  @override
  String get homeAllLevelsDone => 'Tout est terminé !';

  @override
  String playSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Jouer le niveau $levelString';
  }

  @override
  String playLevelSemantics(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Jouer le niveau $levelString, $tier';
  }

  @override
  String coinPillShopSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString pièces. Ouvre la boutique.',
      one: '$countString pièce. Ouvre la boutique.',
    );
    return '$_temp0';
  }

  @override
  String get tierHard => 'DIFFICILE';

  @override
  String get tierSuperHard => 'EXTRÊME';

  @override
  String get tierSuperShort => 'EXTRÊME';

  @override
  String tierName(String tier) {
    String _temp0 = intl.Intl.selectLogic(tier, {
      'easy': 'Facile',
      'medium': 'Moyen',
      'hard': 'Difficile',
      'superhard': 'Extrême',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String levelWithTier(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Niveau $levelString · $tier';
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
      other: '$countString sur $totalString familles terminées',
      one: '$countString sur $totalString famille terminée',
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
      other: '$countString pièces',
      one: '$countString pièce',
    );
    return '$_temp0';
  }

  @override
  String get levelDaily => 'Défi';

  @override
  String levelDailySemantics(String date) {
    return 'Défi du jour, $date';
  }

  @override
  String bonusLevelTitle(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Niveau bonus $levelString';
  }

  @override
  String get closeSemantics => 'Fermer';

  @override
  String get backSemantics => 'Retour';

  @override
  String boosterAdSemantics(String booster) {
    return '$booster, regarder une vidéo';
  }

  @override
  String boosterCoinSemantics(String booster, int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$booster, $priceString pièces',
      one: '$booster, $priceString pièce',
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
      other: 'Annuler, $countString disponibles',
      one: 'Annuler, $countString disponible',
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
      other: 'Indice, $countString restants',
      one: 'Indice, $countString restant',
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
      other: 'Place en plus, $countString restantes',
      one: 'Place en plus, $countString restante',
    );
    return '$_temp0';
  }

  @override
  String get softStuckTitle => 'Hmm, ça semble bloqué';

  @override
  String get softStuckBody =>
      'Et si tu annulais ? Tu peux aussi continuer à jouer.';

  @override
  String get softStuckBodyRestart =>
      'Et si tu recommençais ? Tu peux aussi continuer à jouer.';

  @override
  String get softStuckAction => 'Annuler';

  @override
  String get oomTitle => 'Plus aucun coup !';

  @override
  String get oomSubtitle => 'Choisis comment continuer à ranger.';

  @override
  String get oomUndoSubtitle => 'Reviens sur ton dernier coup';

  @override
  String oomUndoFree(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gratuit · $countString dispo',
      one: 'Gratuit · $countString dispo',
    );
    return '$_temp0';
  }

  @override
  String get oomSlotTitle => '+1 place';

  @override
  String get oomSlotSubtitle => 'Ajoute une place pour ce niveau';

  @override
  String get oomSlotOffline => 'Hors ligne, en pièces';

  @override
  String get oomRestartSubtitle => 'Recommence ce niveau, gratuitement';

  @override
  String coinPrice(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString pièces',
      one: '$countString pièce',
    );
    return '$_temp0';
  }

  @override
  String get watchAd => 'Voir une pub';

  @override
  String get watchAdSemantics => 'Regarder une pub';

  @override
  String get offlineTitle => 'Hors ligne';

  @override
  String get offlineAds => 'Les boutons de pub passent aux prix en pièces';

  @override
  String get connectToWatchAd => 'Connecte-toi pour voir une pub';

  @override
  String get winTitle => 'Niveau terminé !';

  @override
  String get winTitleShort => 'Terminé !';

  @override
  String get winContinue => 'Continuer';

  @override
  String get winTripleCoins => '×3 pièces';

  @override
  String get winRewardAdded => 'Récompense ajoutée';

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

    return 'Chapitre $numberString';
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
    return 'À suivre : $name';
  }

  @override
  String get winChapterDone => 'Chapitre terminé ! Ta récompense arrive.';

  @override
  String figurineName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'La famille Classique',
      'sailor': 'La famille des marins',
      'baker': 'La famille des boulangers',
      'astronaut': 'La famille des astronautes',
      'gardener': 'La famille des jardiniers',
      'snow': 'La famille des neiges',
      'circus': 'La famille du cirque',
      'musician': 'La famille des musiciens',
      'royal': 'La famille royale',
      'explorer': 'La famille des explorateurs',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String chapterRibbon(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'CHAPITRE $numberString · $name';
  }

  @override
  String chapterRibbonShort(String name) {
    return '$name';
  }

  @override
  String chapterName(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'ch01': 'Boutique de jouets ensoleillée',
      'ch02': 'Coin café sous la pluie',
      'ch03': 'Marché du bord de mer',
      'ch04': 'Chalet enneigé',
      'ch05': 'Carnaval de nuit',
      'ch06': 'Cabane de jardin au printemps',
      'ch07': 'Théâtre de marionnettes',
      'ch08': 'Kiosque à musique d’automne',
      'ch09': 'Bibliothèque du château',
      'ch10': 'Belvédère au lever du soleil',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get pauseTitle => 'En pause';

  @override
  String get resume => 'Reprendre';

  @override
  String get home => 'Accueil';

  @override
  String get settings => 'Paramètres';

  @override
  String get settingSound => 'Sons';

  @override
  String get settingMusic => 'Musique';

  @override
  String get settingHaptics => 'Vibrations';

  @override
  String get allLevelsTitle => 'Tu as terminé tous les niveaux !';

  @override
  String get allLevelsBody =>
      'De nouveaux chapitres arrivent. En attendant, joue aux niveaux bonus.';

  @override
  String allLevelsPlayBonus(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Jouer le niveau bonus $numberString';
  }

  @override
  String get allLevelsBackHome => 'Retour à l’accueil';

  @override
  String get nextLevelFailedHome => 'Retour à l’accueil';

  @override
  String get gameplayFailedTitle => 'Les étagères ont besoin d’un instant';

  @override
  String get gameplayFailedBody =>
      'Ce niveau n’a pas pu être préparé. Réessaie ou retourne à l’accueil.';

  @override
  String get devLevelPickerTitle => 'Aller à un niveau';

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

    return 'Chapitre $numberString · Niveaux $startString–$endString';
  }

  @override
  String get navShop => 'Boutique';

  @override
  String get navHomeShort => 'Accueil';

  @override
  String get navShopShort => 'Boutique';

  @override
  String get navMuseum => 'Musée';

  @override
  String get navMuseumShort => 'Musée';

  @override
  String get homeDailyTile => 'Défi du jour';

  @override
  String get homeMuseumTile => 'Musée';

  @override
  String get homeRemoveAdsTile => 'Sans pub';

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

    return 'Après le niveau $levelString';
  }

  @override
  String get homeBonusBadge => 'BONUS';

  @override
  String get homeBonusKicker => 'BONUS INFINI';

  @override
  String get homeBonusName => 'Niveaux bonus';

  @override
  String streakBadgeSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Série de $countString jours',
      one: 'Série de $countString jour',
    );
    return '$_temp0';
  }

  @override
  String get settingColorSymbols => 'Symboles de couleur';

  @override
  String get symbolsSubtle => 'Discrets';

  @override
  String get symbolsLarge => 'Grands';

  @override
  String get settingLanguage => 'Langue';

  @override
  String get settingRestorePurchases => 'Restaurer les achats';

  @override
  String get settingPrivacyChoices => 'Choix de confidentialité';

  @override
  String get settingPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingSupport => 'Assistance';

  @override
  String get settingSupportValue => 'Écris-nous';

  @override
  String settingsFooter(String version, String build, String playerId) {
    return 'Nesty: Doll Sort · v$version (build $build) · ID joueur $playerId';
  }

  @override
  String get languageSheetTitle => 'Langue';

  @override
  String get languageSheetDone => 'OK';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'Anglais',
      'es': 'Espagnol',
      'pt_BR': 'Portugais',
      'id': 'Indonésien',
      'hi': 'Hindi',
      'de': 'Allemand',
      'fr': 'Français',
      'tr': 'Turc',
      'ja': 'Japonais',
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
      other: '$countString jours',
      one: '$countString jour',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakKeep => 'Joue aujourd’hui pour allonger ta série';

  @override
  String get dailyStreakStart =>
      'Résous le défi du jour pour allumer ta première flamme.';

  @override
  String get dailyStreakDone => 'Ta flamme est allumée. À demain.';

  @override
  String get dailyStreakWeek => 'Une semaine complète !';

  @override
  String dailyFreezes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString gels',
      one: '$countString gel',
      zero: 'Aucun gel',
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
      other: '$countString gels de série',
      one: '$countString gel de série',
    );
    return '$_temp0';
  }

  @override
  String get dailyDay => 'Jour';

  @override
  String get dailyToday => 'Auj.';

  @override
  String get dailyTomorrow => 'Demain';

  @override
  String dailyDaySemantics(String state, int day) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'done': 'Jour $day, terminé',
      'today': 'Aujourd’hui, jour $day',
      'tomorrow': 'Demain, jour $day',
      'chest': 'Jour $day, coffre',
      'other': 'Jour $day',
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
      other: 'Jouer, $countString pièces',
      one: 'Jouer, $countString pièce',
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
      other: 'Coffre du jour 7 · $countString pièces',
      one: 'Coffre du jour 7 · $countString pièce',
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
      other: 'Encore $countString jours',
      one: 'Encore $countString jour',
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
      other: 'Encore $countString jours, aujourd’hui compris',
      one: 'Encore $countString jour, aujourd’hui compris',
    );
    return '$_temp0';
  }

  @override
  String get dailyChestOpenedToday => 'Ouvert aujourd’hui';

  @override
  String dailyPuzzleTitle(String weekday) {
    return 'Le défi de $weekday';
  }

  @override
  String dailyPuzzleInfo(int colors, String tier) {
    final intl.NumberFormat colorsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String colorsString = colorsNumberFormat.format(colors);

    String _temp0 = intl.Intl.pluralLogic(
      colors,
      locale: localeName,
      other: '$colorsString couleurs',
      one: '$colorsString couleur',
    );
    return '$_temp0 · $tier';
  }

  @override
  String get dailyPlay => 'Jouer';

  @override
  String dailySolvedChip(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return 'Résolu · +$coinsString';
  }

  @override
  String dailyNextPuzzle(String time) {
    return 'Prochain défi dans $time';
  }

  @override
  String dailyCountdown(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString h $minutesString min';
  }

  @override
  String playLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Jouer le niveau $levelString';
  }

  @override
  String get dailySavedTitle => 'Un gel a gardé ta flamme allumée.';

  @override
  String dailySavedBody(String weekday) {
    return 'Un gel a couvert ton $weekday. Tu en gagneras un nouveau la semaine prochaine.';
  }

  @override
  String get dailyChestTitle => 'Série de 7 jours !';

  @override
  String get dailyChestBody =>
      'Sept jours d’affilée. Voici ce qu’il y a dedans.';

  @override
  String get dailyChestDouble => 'Doubler';

  @override
  String get dailyChestCollect => 'Récupérer';

  @override
  String get dailyWinTitle => 'Défi résolu !';

  @override
  String dailyWinStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Série de $countString jours',
      one: 'Série de $countString jour',
    );
    return '$_temp0';
  }

  @override
  String dailyWinChestHint(String count) {
    String _temp0 = intl.Intl.selectLogic(count, {
      '0': 'Ton coffre du jour 7 est prêt !',
      '1': 'Encore un jour jusqu’au coffre du jour 7',
      '2': 'Encore deux jours jusqu’au coffre du jour 7',
      '3': 'Encore trois jours jusqu’au coffre du jour 7',
      '4': 'Encore quatre jours jusqu’au coffre du jour 7',
      '5': 'Encore cinq jours jusqu’au coffre du jour 7',
      '6': 'Encore six jours jusqu’au coffre du jour 7',
      'other': 'Encore $count jours jusqu’au coffre du jour 7',
    });
    return '$_temp0';
  }

  @override
  String get dailyBackToDaily => 'Retour au défi du jour';

  @override
  String get museumTitle => 'Musée';

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
      other: 'Chapitre $chapterString · encore $countString niveaux',
      one: 'Chapitre $chapterString · encore $countString niveau',
    );
    return '$_temp0';
  }

  @override
  String get museumAllHome => 'Chaque famille est rentrée.';

  @override
  String get museumNextFamily => 'Prochaine famille';

  @override
  String get museumNextFamilyKicker => 'PROCHAINE FAMILLE';

  @override
  String museumFamilyLabel(String name) {
    return 'Famille $name';
  }

  @override
  String museumSoonLabel(String name) {
    return '$name · bientôt';
  }

  @override
  String figurineShortName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'Classique',
      'sailor': 'Marin',
      'baker': 'Boulanger',
      'astronaut': 'Astronaute',
      'gardener': 'Jardinier',
      'snow': 'Neige',
      'circus': 'Cirque',
      'musician': 'Musicien',
      'royal': 'Royale',
      'explorer': 'Explorateur',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String figurineFlavor(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': '« La plus petite gagne à chaque partie de cache-cache. »',
      'sailor':
          '« Elles gardent un coquillage dans la plus petite poupée, au cas où. »',
      'baker':
          '« Elles cuisent chaque pain en quatre tailles, pour que personne n’ait à partager. »',
      'astronaut':
          '« Elles comptent à rebours de la plus grande à la plus petite avant chaque voyage sur la Lune. »',
      'gardener':
          '« Chaque chapeau cache une graine gardée pour le printemps. »',
      'snow':
          '« Quand personne ne regarde, elles s’empilent en bonhomme de neige. »',
      'circus':
          '« Leur plus beau numéro : se glisser les unes dans les autres, sous les applaudissements. »',
      'musician':
          '« Elles jouent un seul air en quatre tailles. La plus petite prend les notes aiguës. »',
      'royal':
          '« Chaque couronne tient dans la suivante, ce qui fait gagner beaucoup de place. »',
      'explorer':
          '« Elles ont cartographié chaque étagère de la boutique, et ce n’est pas fini. »',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String museumChapterChip(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Chapitre $numberString · $name';
  }

  @override
  String museumCollectedOn(String date) {
    return 'Récupérée · $date';
  }

  @override
  String get museumCollected => 'Récupérée';

  @override
  String museumLockedText(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Termine le chapitre $numberString pour faire rentrer cette famille.';
  }

  @override
  String museumIntro(int levels) {
    final intl.NumberFormat levelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelsString = levelsNumberFormat.format(levels);

    return 'Chaque chapitre a sa famille de poupées. Gagne ses $levelsString niveaux pour faire rentrer cette famille au musée.';
  }

  @override
  String museumLevelsToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'encore $countString niveaux',
      one: 'encore $countString niveau',
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
      other: 'encore $countString',
      one: 'encore $countString',
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

    return 'Chap. $chapterString · $firstString–$lastString';
  }

  @override
  String museumLockedLine1(int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'Chapitre $chapterString';
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

    return 'Niveaux $firstString–$lastString';
  }

  @override
  String get shopTitle => 'Boutique';

  @override
  String get shopTabCoins => 'Pièces';

  @override
  String get shopTabSkins => 'Apparences';

  @override
  String get shopTabThemes => 'Thèmes';

  @override
  String get shopTabNoAds => 'Sans pub';

  @override
  String get shopEquipped => 'Équipé';

  @override
  String get shopEquip => 'Équiper';

  @override
  String get skinOwnedSemantics => 'Possédé';

  @override
  String skinName(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Classique',
      'space': 'Espace',
      'ocean': 'Océan',
      'sweets': 'Sucreries',
      'forest': 'Amis de la forêt',
      'winter': 'Hiver',
      'forest_bear': 'Ours des bois',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String skinDescription(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Fleurs peintes, points dorés et un petit nœud.',
      'ocean': 'Cols de marin, minuscules ancres et bordures de vagues.',
      'space': 'Casques ronds, petites antennes et planètes à anneaux.',
      'sweets': 'Coulures de glaçage, vermicelles et rayures de bonbon.',
      'forest':
          'Oreilles pointues, capuches bordées de perles et feuilles qui tombent.',
      'winter': 'Bonnets à pompon, flocons et bordures nacrées.',
      'forest_bear':
          'Oreilles d’ours rondes, capuches douillettes et glands dans les feuilles.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get skinDetailTitle => 'Apparence';

  @override
  String get skinDetailColors => 'Les 11 couleurs · symboles conservés';

  @override
  String get skinDetailSizes =>
      'Chaque taille s’emboîte de la même façon. Seule la peinture change.';

  @override
  String get shopBuy => 'Acheter';

  @override
  String shopBuySemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Acheter, $countString pièces',
      one: 'Acheter, $countString pièce',
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
      other: 'Tu as $countString pièces',
      one: 'Tu as $countString pièce',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsTitle => 'Encore quelques pièces';

  @override
  String notEnoughCoinsNeeded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il te faut $countString pièces de plus',
      one: 'Il te faut $countString pièce de plus',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsSource =>
      'Les pièces viennent des niveaux gagnés, du défi du jour et des coffres.';

  @override
  String get notEnoughCoinsGoToShop => 'Aller à la boutique';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String shopDownloading(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'Téléchargement $percentString %';
  }

  @override
  String get themesMatchTitle => 'Assortir à chaque chapitre';

  @override
  String get themesMatchSubtitle => 'Utilise le thème du chapitre en cours';

  @override
  String get themeInUse => 'Utilisé';

  @override
  String get themeUse => 'Utiliser';

  @override
  String themeChapterLock(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Chap. $numberString';
  }

  @override
  String get shopClosedTitle => 'La boutique est fermée pour le moment';

  @override
  String get shopClosedBody =>
      'Les packs de pièces et « Sans pub » arrivent dans une prochaine mise à jour.';

  @override
  String buyUndoText(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tu as utilisé tes $countString annulations gratuites. Annule un coup de plus.',
      one:
          'Tu as utilisé $countString annulation gratuite. Annule un coup de plus.',
    );
    return '$_temp0';
  }

  @override
  String get buyHintText => 'Montre ton meilleur prochain coup.';

  @override
  String get buySlotText => 'Ajoute une place vide pour ce niveau.';

  @override
  String get tutorialStep1Title => 'Touche la petite poupée';

  @override
  String tutorialStepChip(int step, int total) {
    return 'ÉTAPE $step SUR $total';
  }

  @override
  String get tutorialStep1Text =>
      'Les poupées s’emboîtent dans la même couleur, une taille au-dessus.';

  @override
  String get tutorialStep2Title => 'Touche maintenant la grande';

  @override
  String get tutorialStep2Text => 'La petite poupée tombe dedans avec un clac.';

  @override
  String get tutorialStep3Title => 'Termine la famille';

  @override
  String get tutorialStep3Text =>
      'Mets la dernière poupée. Une famille est terminée quand toutes les tailles sont emboîtées.';

  @override
  String tutorialStepSemantics(int step, String title) {
    final intl.NumberFormat stepNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String stepString = stepNumberFormat.format(step);

    return 'Étape $stepString sur 3. $title';
  }

  @override
  String get tutorialSwallowChip => 'NOUVEAUTÉ';

  @override
  String get tutorialSwallowTitle => 'Les grandes avalent les petites';

  @override
  String get tutorialSwallowText =>
      'Pose une grande poupée sur la taille juste en dessous : elle se referme dessus.';

  @override
  String get introNew => 'NOUVEAU';

  @override
  String get introTowersTitle => 'Des tours !';

  @override
  String get introTowersText =>
      'Seule la poupée du dessus peut bouger. Libère-la pour révéler celle qui se cache dessous.';

  @override
  String get introGlassTitle => 'Vitrines';

  @override
  String get introGlassText =>
      'Une poupée enfermée est libérée quand la famille inscrite sur son cadenas est complète.';

  @override
  String get introIceTitle => 'Glace';

  @override
  String get introIceText =>
      'Chaque famille terminée fissure la glace. À zéro, la poupée est libre.';

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
  String get introGotIt => 'Compris';

  @override
  String chapterCompleteTitle(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'CHAPITRE $numberString TERMINÉ';
  }

  @override
  String get chapterCompleteAdded => 'Ajoutée à ton musée !';

  @override
  String chapterCompleteCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString pièces',
      one: '+$countString pièce',
    );
    return '$_temp0';
  }

  @override
  String chapterCompleteNext(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Suivant : chapitre $numberString · $name';
  }

  @override
  String get gameplayGenerating => 'On installe les étagères…';

  @override
  String dailyStreakPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Ta série de $countString jours se repose. Résous le défi du jour pour la rallumer.',
      one:
          'Ta série de $countString jour se repose. Résous le défi du jour pour la rallumer.',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakPausedChip => 'En pause';

  @override
  String get dailyStreakRelitTitle => 'Série rallumée !';

  @override
  String dailyStreakRelitBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ta série de $countString jours brille de nouveau.',
      one: 'Ta série de $countString jour brille de nouveau.',
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
      other: 'Série de $countString jours, en pause',
      one: 'Série de $countString jour, en pause',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => 'Chapitres';

  @override
  String chaptersOverallProgress(int level, int total) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Niveau $levelString sur $totalString';
  }

  @override
  String chaptersWonCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString gagnés',
      one: '$countString gagné',
    );
    return '$_temp0';
  }

  @override
  String chaptersBestMoves(int best) {
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Record $bestString';
  }

  @override
  String get chaptersLevelPlay => 'Jouer';

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
          'Niveau $levelString, $countString étoiles. Record en coups : $bestString.',
      one:
          'Niveau $levelString, $countString étoile. Record en coups : $bestString.',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsWonNoBest(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Niveau $levelString, gagné';
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
      other: 'Niveau $levelString, gagné. Record : $bestString coups.',
      one: 'Niveau $levelString, gagné. Record : $bestString coup.',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsCurrent(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Niveau $levelString, à jouer ensuite';
  }

  @override
  String chaptersLevelSemanticsLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Niveau $levelString, verrouillé';
  }

  @override
  String get recordsTitle => 'Records';

  @override
  String get homeRecordsButton => 'Records';

  @override
  String get recordsLevelsWon => 'Niveaux gagnés';

  @override
  String get recordsFamilies => 'Familles terminées';

  @override
  String get recordsRacesHeader => 'Courses gagnées';

  @override
  String get recordsDolls => 'Poupées emboîtées';

  @override
  String get recordsDailies => 'Défis du jour résolus';

  @override
  String get recordsLongestStreak => 'Plus longue série';

  @override
  String get recordsBestMovesLink => 'Records par niveau';

  @override
  String get recordsBadgesHeader => 'Badges';

  @override
  String badgeName(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Bien au chaud',
      'glass_breaker': 'Maître des vitrines',
      'ice_melter': 'Brise-glace',
      'tall_order': 'Voir grand',
      'grand_nest': 'Grand nid',
      'level_100': 'À mi-chemin',
      'level_200': 'Haut de l’étagère',
      'dailies_7': 'Pote des défis',
      'dailies_30': 'Vieil ami',
      'first_race': 'Premier sur l’étagère',
      'all_rivals': 'Rafle de rivaux',
      'museum_full': 'Maison pleine',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeLine(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Tu as emboîté ta première famille.',
      'glass_breaker': 'Tu as ouvert ta première vitrine.',
      'ice_melter': 'Tu as libéré une poupée de la glace.',
      'tall_order': 'Tu as gagné un niveau avec des poupées de taille 5.',
      'grand_nest': 'Tu as gagné un niveau avec des poupées de taille 6.',
      'level_100': 'Tu as gagné le niveau 100.',
      'level_200': 'Tu as gagné le niveau 200, le tout dernier.',
      'dailies_7': 'Tu as résolu 7 défis du jour.',
      'dailies_30': 'Tu as résolu 30 défis du jour.',
      'first_race': 'Tu as battu l’ordinateur dans une course.',
      'all_rivals': 'Tu as battu tous les adversaires ordinateur.',
      'museum_full': 'Chaque famille est rentrée dans ton musée.',
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
      'first_family': 'Emboîte une famille entière.',
      'glass_breaker': 'Ouvre une vitrine.',
      'ice_melter': 'Libère une poupée de la glace.',
      'tall_order': 'Gagne un niveau avec des poupées de taille 5.',
      'grand_nest': 'Gagne un niveau avec des poupées de taille 6.',
      'level_100': 'Gagne le niveau $levelString.',
      'level_200': 'Gagne le niveau $levelString.',
      'dailies_7': 'Résous $countString défis du jour.',
      'dailies_30': 'Résous $countString défis du jour.',
      'first_race': 'Bats l’ordinateur dans une course.',
      'all_rivals': 'Bats tous les adversaires ordinateur.',
      'museum_full': 'Fais rentrer toutes les familles dans ton musée.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeSemanticsEarned(String badge) {
    return '$badge, obtenu';
  }

  @override
  String badgeSemanticsLocked(String badge, String how) {
    return '$badge, pas encore obtenu. $how';
  }

  @override
  String badgeEarnedToastTitle(String badge) {
    return 'Badge obtenu · $badge';
  }

  @override
  String get badgeLockedLine => 'Pas encore obtenu';

  @override
  String winMovesBest(int moves, int best) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Coups $movesString · Record $bestString';
  }

  @override
  String winMovesOnly(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return 'Coups $movesString';
  }

  @override
  String winChestCountdown(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString niveaux jusqu’au coffre',
      one: '$countString niveau jusqu’au coffre',
    );
    return '$_temp0';
  }

  @override
  String get winReplayReason =>
      'Une partie pour le plaisir : les pièces viennent des nouveaux niveaux.';

  @override
  String get winBackToChapters => 'Retour aux chapitres';

  @override
  String get chestMilestoneTitle => 'Coffre d’étape';

  @override
  String chestMilestoneBody(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Un coffre pour avoir atteint le niveau $levelString. Voici ce qu’il y a dedans.';
  }

  @override
  String chestMilestoneBodyBonus(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Un coffre pour le niveau bonus $levelString. Voici ce qu’il y a dedans.';
  }

  @override
  String chestContentsCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString pièces',
      one: '+$countString pièce',
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
      other: '+$countString indices',
      one: '+$countString indice',
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
      other: '$coinsString pièces',
      one: '$coinsString pièce',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hints,
      locale: localeName,
      other: '$hintsString indices',
      one: '$hintsString indice',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String chestSemantics(String contents) {
    return 'Coffre. Contenu : $contents.';
  }

  @override
  String get chestOpen => 'Ouvrir';

  @override
  String get settingRelaxedMode => 'Mode détente';

  @override
  String get settingRelaxedModeSubtitle => 'Annulations gratuites illimitées';

  @override
  String get relaxedModeOn =>
      'Le mode détente est activé. Annule autant que tu veux.';

  @override
  String get settingReduceMotion => 'Réduire les animations';

  @override
  String get reduceMotionSystem => 'Système';

  @override
  String get reduceMotionOn => 'Oui';

  @override
  String get reduceMotionOff => 'Non';

  @override
  String get oomUndoFreeUnlimited => 'Gratuit, autant que tu veux';

  @override
  String oomUndoSpent(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tu as utilisé tes $countString annulations gratuites',
      one: 'Tu as utilisé $countString annulation gratuite',
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
      other: '$countString places en plus, c’est le maximum par niveau.',
      one: 'Une place en plus, c’est le maximum par niveau.',
    );
    return '$_temp0';
  }

  @override
  String get boosterUndoUnlimitedSemantics => 'Annuler, illimité';

  @override
  String get oomUndoFreeChip => 'Gratuit';

  @override
  String boosterLimitSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '+Place : $countString sur $totalString utilisées';
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
    return '$booster, suggéré';
  }

  @override
  String get boosterRestartSemantics => 'Recommencer le niveau';

  @override
  String get homeVsComputerTile => 'vs Ordinateur';

  @override
  String homeVsComputerLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Après le niveau $levelString';
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
  String get raceSelectTitle => 'Contre l’ordinateur';

  @override
  String get raceSelectSubtitle => 'Affronte un ordinateur sur le même défi';

  @override
  String get raceComputerTag => 'Ordinateur';

  @override
  String raceRivalName(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Comète',
      two: 'Bouton',
      one: 'Galet',
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
      other: 'Allure vive, jeu soigné. Pas facile à rattraper.',
      two: 'Vérifie chaque coup deux fois, puis le joue.',
      one: 'Prend son temps et savoure chaque poupée.',
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
      other: 'Rythme vif',
      two: 'Rythme régulier',
      one: 'Rythme tranquille',
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
      other: 'Gagne $coinsString pièces',
      one: 'Gagne $coinsString pièce',
    );
    return '$_temp0';
  }

  @override
  String raceRivalLocked(String rival) {
    return 'Bats $rival pour débloquer';
  }

  @override
  String get raceRivalNew => 'Nouv.';

  @override
  String raceRivalSemantics(String name) {
    return '$name, Ordinateur';
  }

  @override
  String raceRivalCardSemantics(String rival, String skill) {
    return '$rival, adversaire ordinateur. $skill.';
  }

  @override
  String raceRivalLockedSemantics(String rival) {
    return 'Adversaire ordinateur verrouillé. Bats $rival pour le débloquer.';
  }

  @override
  String get raceRivalSelectedSemantics => 'Sélectionné';

  @override
  String get raceStart => 'Démarrer';

  @override
  String get raceStartHint =>
      'Même défi, deux plateaux. Qui termine toutes les familles en premier gagne.';

  @override
  String get raceStripReady => 'Quand tu veux';

  @override
  String get raceStripThinking => 'Réfléchit…';

  @override
  String get raceStripStartingOver => 'Repart de zéro';

  @override
  String get raceStripFinished => 'A terminé';

  @override
  String get raceStripPlayerFinished => 'Tu as fini en premier';

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
      other: '$name, ordinateur : $countString sur $totalString familles',
      one: '$name, ordinateur : $countString sur $totalString famille',
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

    return 'L’ordinateur a terminé une famille : $doneString sur $totalString';
  }

  @override
  String raceAnnounceStart(String rival) {
    return 'Course lancée contre $rival, l’ordinateur.';
  }

  @override
  String get raceAnnounceStartingOver => 'L’ordinateur repart de zéro.';

  @override
  String get raceAnnounceFinished =>
      'L’ordinateur a terminé toutes les familles.';

  @override
  String get raceAnnounceWon => 'Tu as gagné la course.';

  @override
  String get raceAnnounceLost => 'L’ordinateur a fini en premier.';

  @override
  String get raceWinTitle => 'Tu as gagné la course !';

  @override
  String get raceWinTitleShort => 'Gagné !';

  @override
  String raceWinBody(String rival) {
    return 'Toutes les familles sont complètes. $rival était encore en train de ranger.';
  }

  @override
  String raceWinCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString pièces',
      one: '+$countString pièce',
    );
    return '$_temp0';
  }

  @override
  String get raceLossTitle => 'Presque ! Revanche ?';

  @override
  String get raceLossTitleShort => 'Presque !';

  @override
  String raceLossBody(String rival) {
    return '$rival a fini en premier cette fois. Une revanche ne coûte rien.';
  }

  @override
  String get raceRivalUnlockedTitle => 'Nouvel adversaire !';

  @override
  String raceRivalUnlockedBody(String rival) {
    return '$rival t’attend pour une course.';
  }

  @override
  String raceRivalUnlockedRace(String rival) {
    return 'Course contre $rival';
  }

  @override
  String get raceLeaveTitle => 'Quitter cette course ?';

  @override
  String get raceLeaveBody =>
      'La course s’arrête ici. Aucune pièce, mais tu gardes tout.';

  @override
  String get raceLeaveKeep => 'Continuer la course';

  @override
  String get raceRematch => 'Revanche';

  @override
  String get raceNewRace => 'Nouvelle course';

  @override
  String get raceBackToRivals => 'Retour aux courses';

  @override
  String get raceFailedTitle => 'Les étagères ont besoin d’un instant';

  @override
  String get raceFailedBody =>
      'Cette course n’a pas pu être préparée. Réessaie ou choisis une autre course.';

  @override
  String racePauseSubtitle(String rival) {
    return '$rival est aussi en pause.';
  }

  @override
  String racePauseHeader(String rival) {
    return 'vs Ordinateur · $rival';
  }

  @override
  String get raceRivalBeaten => 'Victoire';

  @override
  String raceStartFor(String rival) {
    return 'Lancer la course contre $rival';
  }

  @override
  String get raceQuit => 'Quitter la course';

  @override
  String starsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étoiles sur 3',
      one: '$count étoile sur 3',
    );
    return '$_temp0';
  }

  @override
  String starsNewBestSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nouveau record, $count étoiles sur 3',
      one: 'Nouveau record, $count étoile sur 3',
    );
    return '$_temp0';
  }

  @override
  String winStarsTarget(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return '3 étoiles en $movesString coups ou moins';
  }

  @override
  String get winStarsNewBest => 'Nouveau record !';

  @override
  String get starsFirstTip =>
      'Moins de coups, plus d’étoiles. Rejoue n’importe quel niveau depuis Chapitres.';

  @override
  String get starsHelperNote =>
      'Une victoire avec un indice ou une place en plus rapporte jusqu’à 2 étoiles.';

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
  String get chaptersAllThreeStars => 'Tous les niveaux à 3 étoiles';

  @override
  String chaptersStarsSemantics(int earned, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      earned,
      locale: localeName,
      other: '$earned étoiles sur $total',
      one: '$earned étoile sur $total',
    );
    return '$_temp0';
  }

  @override
  String get recordsStars => 'Étoiles';

  @override
  String recordsStarsValue(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString sur $totalString';
  }

  @override
  String get dailyShare => 'Partager';

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
  String get dailyShareSemantics => 'Partager le résultat du jour';

  @override
  String dailyShareText(String date, String glyphs, int moves, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'Résolu en $moves coups · Jour $day 🔥',
      one: 'Résolu en $moves coup · Jour $day 🔥',
    );
    return 'Nesty Défi du jour · $date\n$glyphs\n$_temp0';
  }

  @override
  String dailyShareTextNoStreak(String date, String glyphs, int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'Résolu en $moves coups',
      one: 'Résolu en $moves coup',
    );
    return 'Nesty Défi du jour · $date\n$glyphs\n$_temp0';
  }

  @override
  String get reminderOfferTitle =>
      'Un petit rappel quand le défi de demain est prêt ?';

  @override
  String get reminderOfferBody =>
      'Une notification discrète par jour, à l’heure de ton choix. Tu peux la désactiver dans les Paramètres.';

  @override
  String reminderOfferTime(String time) {
    return 'Chaque jour à $time';
  }

  @override
  String get reminderOfferChangeTime => 'Changer l’heure';

  @override
  String reminderTimeChipSemantics(String time) {
    return 'Heure du rappel, chaque jour à $time. Changer l’heure.';
  }

  @override
  String get reminderPickerTitle => 'Heure du rappel';

  @override
  String get reminderOfferYes => 'Oui, rappelle-moi';

  @override
  String get reminderOfferNo => 'Non merci';

  @override
  String reminderOfferDone(String time) {
    return 'Rappel réglé pour $time.';
  }

  @override
  String get reminderOfferDeniedTitle =>
      'Les notifications sont désactivées pour Nesty';

  @override
  String reminderOfferDenied(String time) {
    return 'Active-les dans les réglages du téléphone et ta notification arrivera à $time.';
  }

  @override
  String get reminderNotificationTitle => 'Nesty';

  @override
  String get reminderNotificationBody => 'Le défi du jour est sur l’étagère.';

  @override
  String get reminderNotificationBody2 =>
      'Un nouveau défi du jour t’attend quand tu veux.';

  @override
  String get reminderNotificationBody3 =>
      'De nouvelles poupées attendent d’être emboîtées. Le défi du jour est prêt.';

  @override
  String get reminderChannelName => 'Défi du jour';

  @override
  String get reminderChannelDescription =>
      'Une notification par jour quand un nouveau défi du jour est prêt.';

  @override
  String get settingReminder => 'Rappel quotidien';

  @override
  String get settingReminderTime => 'Heure';

  @override
  String get settingReminderBlocked =>
      'Désactivé dans les réglages du téléphone';

  @override
  String get settingOpenPhoneSettings => 'Réglages du téléphone';

  @override
  String get settingReminderTurnOff => 'Désactiver';

  @override
  String homeChapterKicker(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'CHAPITRE $numberString';
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

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Chapitre $chapterString, $name. $countString étoiles sur $totalString. Ouvre les chapitres.',
      one:
          'Chapitre $chapterString, $name. $countString étoile sur $totalString. Ouvre les chapitres.',
    );
    return '$_temp0';
  }

  @override
  String homeBonusCardSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Niveaux bonus. $countString étoiles sur $totalString. Ouvre les chapitres.',
      one:
          'Niveaux bonus. $countString étoile sur $totalString. Ouvre les chapitres.',
    );
    return '$_temp0';
  }

  @override
  String get homeVsComputerSemantics =>
      'Contre l’ordinateur. Affronte un ordinateur sur le même défi.';

  @override
  String homeVsComputerLockedSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Contre l’ordinateur, verrouillé. Après le niveau $levelString.';
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

    return 'CHAPITRE $numberString · NIVEAUX $firstString–$lastString';
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

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Chapitre $chapterString, $name. $countString étoiles sur $totalString.',
      one:
          'Chapitre $chapterString, $name. $countString étoile sur $totalString.',
    );
    return '$_temp0';
  }

  @override
  String chaptersRowLockedSemantics(int chapter, String name) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'Chapitre $chapterString, $name. Verrouillé.';
  }

  @override
  String get chaptersLevelChestSemantics => 'Un coffre à ce niveau';

  @override
  String get chaptersLevelFinaleSemantics => 'Le dernier niveau du chapitre';

  @override
  String museumNicheCollectedSemantics(String name) {
    return '$name, au musée';
  }

  @override
  String museumNicheNextSemantics(String name, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, prochaine famille. Encore $countString niveaux.',
      one: '$name, prochaine famille. Encore $countString niveau.',
    );
    return '$_temp0';
  }

  @override
  String museumNicheLockedSemantics(String name, int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return '$name, pas encore au musée. Chapitre $chapterString.';
  }

  @override
  String museumCountSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString sur $totalString familles au musée';
  }

  @override
  String museumFullSub(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Maison pleine · les $countString familles';
  }

  @override
  String recordsRaceSemantics(String rival, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$rival, ordinateur. $countString victoires.',
      one: '$rival, ordinateur. $countString victoire.',
    );
    return '$_temp0';
  }

  @override
  String recordsRaceLockedSemantics(String rival) {
    return '$rival, ordinateur. À débloquer.';
  }

  @override
  String recordsStatSemantics(String label, String value) {
    return '$label : $value';
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
  String get giftTitle => 'Cadeau du jour';

  @override
  String giftDay(int day) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return 'Jour $dayString';
  }

  @override
  String get giftClaim => 'Récupérer';

  @override
  String get giftClaimedLine => 'Le cadeau du jour est à toi.';

  @override
  String giftTomorrow(String gift) {
    return 'Demain : $gift';
  }

  @override
  String giftNext(String gift) {
    return 'Prochain cadeau : $gift';
  }

  @override
  String get giftButtonReadySemantics => 'Cadeau du jour. Un cadeau est prêt.';

  @override
  String get giftButtonSemantics => 'Cadeau du jour';

  @override
  String giftTileSemantics(int day, String gift, String state) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return 'Jour $dayString, $gift. $state';
  }

  @override
  String get giftTileDone => 'Récupéré';

  @override
  String get giftTileToday => 'Aujourd’hui';

  @override
  String get giftTileLater => 'À venir';

  @override
  String get giftChestTitle => 'Cadeau du jour 7';

  @override
  String get giftChestBody =>
      'Un coffre pour le jour 7. Voici ce qu’il y a dedans.';

  @override
  String giftCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString pièces',
      one: '$countString pièce',
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
      other: '$countString indices',
      one: '$countString indice',
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
      other: '$countString places en plus',
      one: '$countString place en plus',
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
      other: '+$countString places',
      one: '+$countString place',
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
      other: '$coinsString pièces',
      one: '$coinsString pièce',
    );
    String _temp1 = intl.Intl.pluralLogic(
      slots,
      locale: localeName,
      other: '$slotsString places en plus',
      one: '$slotsString place en plus',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get giftSubtitle => 'Un cadeau par jour, à ton rythme.';

  @override
  String get giftTitleShort => 'Cadeaux';

  @override
  String get giftChestTitleShort => 'Jour 7';

  @override
  String giftSlotsShort(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString places',
      one: '$countString place',
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
    return 'Cadeau récupéré : $gift.';
  }

  @override
  String giftA11yAdded(String gift, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Ajouté : $gift. Tu en as $countString.';
  }
}
