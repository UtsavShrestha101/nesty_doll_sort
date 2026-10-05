// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Nesty';

  @override
  String get splashLoading => 'Carregando…';

  @override
  String progressPercent(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString';
  }

  @override
  String get genericLoadFailed => 'Algo deu errado.';

  @override
  String get splashStorageTitle => 'Seu celular está quase cheio';

  @override
  String splashStorageBody(int size) {
    final intl.NumberFormat sizeNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String sizeString = sizeNumberFormat.format(size);

    return 'O Nesty precisa de cerca de $sizeString MB para montar as prateleiras. Libere espaço e tente de novo.';
  }

  @override
  String get splashContentTitle => 'As prateleiras não foram desempacotadas';

  @override
  String get splashContentBody =>
      'Algo deu errado ao carregar. Tente de novo ou reinicie o Nesty.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String levelTitle(int level) {
    return 'Nível $level';
  }

  @override
  String get pause => 'Pausa';

  @override
  String get boosterUndo => 'Desfazer';

  @override
  String get boosterUndoShort => 'Desfazer';

  @override
  String get boosterHint => 'Dica';

  @override
  String get boosterHintShort => 'Dica';

  @override
  String get boosterExtraSlot => '+Espaço';

  @override
  String get boosterExtraSlotShort => '+1';

  @override
  String get restart => 'Reiniciar';

  @override
  String get restartShort => 'Reiniciar';

  @override
  String get splashDollSort => 'ORGANIZE BONECAS';

  @override
  String get splashCaption => 'Tirando o pó das prateleiras…';

  @override
  String get homePlay => 'JOGAR';

  @override
  String get homeAllLevelsDone => 'Tudo pronto!';

  @override
  String playSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Jogar o nível $levelString';
  }

  @override
  String playLevelSemantics(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Jogar o nível $levelString, $tier';
  }

  @override
  String coinPillShopSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString moedas. Abre a Loja.',
      one: '$countString moeda. Abre a Loja.',
      zero: '$countString moedas. Abre a Loja.',
    );
    return '$_temp0';
  }

  @override
  String get tierHard => 'DIFÍCIL';

  @override
  String get tierSuperHard => 'EXTREMO';

  @override
  String get tierSuperShort => 'EXTREMO';

  @override
  String tierName(String tier) {
    String _temp0 = intl.Intl.selectLogic(tier, {
      'easy': 'Fácil',
      'medium': 'Médio',
      'hard': 'Difícil',
      'superhard': 'Extremo',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String levelWithTier(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Nível $levelString · $tier';
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
      other: '$countString de $totalString famílias completas',
      one: '$countString de $totalString família completa',
      zero: '$countString de $totalString famílias completas',
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
      other: '$countString moedas',
      one: '$countString moeda',
      zero: '$countString moedas',
    );
    return '$_temp0';
  }

  @override
  String get levelDaily => 'Desafio';

  @override
  String levelDailySemantics(String date) {
    return 'Desafio diário, $date';
  }

  @override
  String bonusLevelTitle(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Nível bônus $levelString';
  }

  @override
  String get closeSemantics => 'Fechar';

  @override
  String get backSemantics => 'Voltar';

  @override
  String boosterAdSemantics(String booster) {
    return '$booster, assistir a um vídeo';
  }

  @override
  String boosterCoinSemantics(String booster, int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$booster, $priceString moedas',
      one: '$booster, $priceString moeda',
      zero: '$booster, $priceString moedas',
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
      other: 'Desfazer, $countString disponíveis',
      one: 'Desfazer, $countString disponível',
      zero: 'Desfazer, $countString disponíveis',
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
      other: 'Dica, $countString disponíveis',
      one: 'Dica, $countString disponível',
      zero: 'Dica, $countString disponíveis',
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
      other: 'Espaço extra, $countString disponíveis',
      one: 'Espaço extra, $countString disponível',
      zero: 'Espaço extra, $countString disponíveis',
    );
    return '$_temp0';
  }

  @override
  String get softStuckTitle => 'Hmm, parece que travou';

  @override
  String get softStuckBody =>
      'Que tal Desfazer? Você também pode continuar jogando.';

  @override
  String get softStuckBodyRestart =>
      'Que tal Reiniciar? Você também pode continuar jogando.';

  @override
  String get softStuckAction => 'Desfazer';

  @override
  String get oomTitle => 'Sem jogadas!';

  @override
  String get oomSubtitle => 'Escolha como continuar organizando.';

  @override
  String get oomUndoSubtitle => 'Volte atrás na sua última jogada';

  @override
  String oomUndoFree(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Grátis · $countString disponíveis',
      one: 'Grátis · $countString disponível',
      zero: 'Grátis · $countString disponíveis',
    );
    return '$_temp0';
  }

  @override
  String get oomSlotTitle => '+1 Espaço';

  @override
  String get oomSlotSubtitle => 'Adicione um espaço para este nível';

  @override
  String get oomSlotOffline => 'Só com moedas, sem conexão';

  @override
  String get oomRestartSubtitle => 'Comece este nível do zero, de graça';

  @override
  String coinPrice(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString moedas',
      one: '$countString moeda',
      zero: '$countString moedas',
    );
    return '$_temp0';
  }

  @override
  String get watchAd => 'Ver anúncio';

  @override
  String get watchAdSemantics => 'Ver um anúncio';

  @override
  String get offlineTitle => 'Sem conexão';

  @override
  String get offlineAds =>
      'Os botões de anúncio passam a mostrar preços em moedas';

  @override
  String get connectToWatchAd => 'Conecte-se para ver um anúncio';

  @override
  String get winTitle => 'Nível concluído!';

  @override
  String get winTitleShort => 'Concluído!';

  @override
  String get winContinue => 'Continuar';

  @override
  String get winTripleCoins => '×3 moedas';

  @override
  String get winRewardAdded => 'Recompensa adicionada';

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

    return 'Capítulo $numberString';
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
    return 'A seguir: $name';
  }

  @override
  String get winChapterDone => 'Capítulo concluído! Seu prêmio vem a seguir.';

  @override
  String figurineName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'A Família Clássica',
      'sailor': 'A Família Marinheira',
      'baker': 'A Família Padeira',
      'astronaut': 'A Família Astronauta',
      'gardener': 'A Família Jardineira',
      'snow': 'A Família da Neve',
      'circus': 'A Família Circense',
      'musician': 'A Família Musical',
      'royal': 'A Família Real',
      'explorer': 'A Família Exploradora',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String chapterRibbon(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'CAPÍTULO $numberString · $name';
  }

  @override
  String chapterRibbonShort(String name) {
    return '$name';
  }

  @override
  String chapterName(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'ch01': 'Loja de Brinquedos ao Sol',
      'ch02': 'Cantinho do Café Chuvoso',
      'ch03': 'Mercado à Beira-Mar',
      'ch04': 'Cabana na Neve',
      'ch05': 'Carnaval Noturno',
      'ch06': 'Casinha de Jardim da Primavera',
      'ch07': 'Teatro de Fantoches',
      'ch08': 'Coreto de Outono',
      'ch09': 'Biblioteca do Castelo',
      'ch10': 'Mirante do Amanhecer',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get pauseTitle => 'Em pausa';

  @override
  String get resume => 'Retomar';

  @override
  String get home => 'Início';

  @override
  String get settings => 'Ajustes';

  @override
  String get settingSound => 'Som';

  @override
  String get settingMusic => 'Música';

  @override
  String get settingHaptics => 'Vibração';

  @override
  String get allLevelsTitle => 'Você terminou todos os níveis!';

  @override
  String get allLevelsBody =>
      'Novos capítulos estão a caminho. Enquanto isso, jogue níveis bônus.';

  @override
  String allLevelsPlayBonus(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Jogar o nível bônus $numberString';
  }

  @override
  String get allLevelsBackHome => 'Voltar ao início';

  @override
  String get nextLevelFailedHome => 'Voltar ao início';

  @override
  String get gameplayFailedTitle => 'As prateleiras precisam de um momento';

  @override
  String get gameplayFailedBody =>
      'Não foi possível montar este nível. Tente de novo ou volte ao início.';

  @override
  String get devLevelPickerTitle => 'Ir para um nível';

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

    return 'Capítulo $numberString · Níveis $startString–$endString';
  }

  @override
  String get navShop => 'Loja';

  @override
  String get navHomeShort => 'Início';

  @override
  String get navShopShort => 'Loja';

  @override
  String get navMuseum => 'Museu';

  @override
  String get navMuseumShort => 'Museu';

  @override
  String get homeDailyTile => 'Desafio diário';

  @override
  String get homeMuseumTile => 'Museu';

  @override
  String get homeRemoveAdsTile => 'Remover anúncios';

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

    return 'Após o nível $levelString';
  }

  @override
  String get homeBonusBadge => 'BÔNUS';

  @override
  String get homeBonusKicker => 'BÔNUS SEM FIM';

  @override
  String get homeBonusName => 'Níveis bônus';

  @override
  String streakBadgeSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência de $countString dias',
      one: 'Sequência de $countString dia',
      zero: 'Sequência de $countString dias',
    );
    return '$_temp0';
  }

  @override
  String get settingColorSymbols => 'Símbolos de cor';

  @override
  String get symbolsSubtle => 'Discretos';

  @override
  String get symbolsLarge => 'Grandes';

  @override
  String get settingLanguage => 'Idioma';

  @override
  String get settingRestorePurchases => 'Restaurar compras';

  @override
  String get settingPrivacyChoices => 'Opções de privacidade';

  @override
  String get settingPrivacyPolicy => 'Política de privacidade';

  @override
  String get settingSupport => 'Suporte';

  @override
  String get settingSupportValue => 'Escreva para nós';

  @override
  String settingsFooter(String version, String build, String playerId) {
    return 'Nesty: Doll Sort · v$version (build $build) · ID do jogador $playerId';
  }

  @override
  String get languageSheetTitle => 'Idioma';

  @override
  String get languageSheetDone => 'Pronto';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'Inglês',
      'es': 'Espanhol',
      'pt_BR': 'Português',
      'id': 'Indonésio',
      'hi': 'Híndi',
      'de': 'Alemão',
      'fr': 'Francês',
      'tr': 'Turco',
      'ja': 'Japonês',
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
      other: '$countString dias',
      one: '$countString dia',
      zero: '$countString dias',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakKeep => 'Jogue hoje para aumentar sua sequência';

  @override
  String get dailyStreakStart =>
      'Resolva o desafio de hoje para acender sua primeira chama.';

  @override
  String get dailyStreakDone => 'Sua chama está acesa. Até amanhã.';

  @override
  String get dailyStreakWeek => 'Uma semana inteira!';

  @override
  String dailyFreezes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString protetores',
      one: '$countString protetor',
      zero: 'Nenhum protetor',
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
      other: '$countString protetores de sequência',
      one: '$countString protetor de sequência',
      zero: '$countString protetores de sequência',
    );
    return '$_temp0';
  }

  @override
  String get dailyDay => 'Dia';

  @override
  String get dailyToday => 'Hoje';

  @override
  String get dailyTomorrow => 'Amanhã';

  @override
  String dailyDaySemantics(String state, int day) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'done': 'Dia $day, concluído',
      'today': 'Hoje, dia $day',
      'tomorrow': 'Amanhã, dia $day',
      'chest': 'Dia $day, baú',
      'other': 'Dia $day',
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
      other: 'Jogar, $countString moedas',
      one: 'Jogar, $countString moeda',
      zero: 'Jogar, $countString moedas',
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
      other: 'Baú do dia 7 · $countString moedas',
      one: 'Baú do dia 7 · $countString moeda',
      zero: 'Baú do dia 7 · $countString moedas',
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
      other: 'Mais $countString dias',
      one: 'Mais $countString dia',
      zero: 'Mais $countString dias',
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
      other: 'Mais $countString dias, contando hoje',
      one: 'Mais $countString dia, contando hoje',
      zero: 'Mais $countString dias, contando hoje',
    );
    return '$_temp0';
  }

  @override
  String get dailyChestOpenedToday => 'Aberto hoje';

  @override
  String dailyPuzzleTitle(String weekday) {
    return 'Desafio de $weekday';
  }

  @override
  String dailyPuzzleInfo(int colors, String tier) {
    final intl.NumberFormat colorsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String colorsString = colorsNumberFormat.format(colors);

    String _temp0 = intl.Intl.pluralLogic(
      colors,
      locale: localeName,
      other: '$colorsString cores',
      one: '$colorsString cor',
      zero: '$colorsString cores',
    );
    return '$_temp0 · $tier';
  }

  @override
  String get dailyPlay => 'Jogar';

  @override
  String dailySolvedChip(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return 'Resolvido · +$coinsString';
  }

  @override
  String dailyNextPuzzle(String time) {
    return 'Próximo desafio em $time';
  }

  @override
  String dailyCountdown(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '${hoursString}h ${minutesString}min';
  }

  @override
  String playLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Jogar nível $levelString';
  }

  @override
  String get dailySavedTitle => 'Um protetor manteve sua chama acesa.';

  @override
  String dailySavedBody(String weekday) {
    return 'Um protetor cobriu o dia de $weekday. Você ganha um novo na próxima semana.';
  }

  @override
  String get dailyChestTitle => 'Sequência de 7 dias!';

  @override
  String get dailyChestBody => 'Sete dias seguidos. Veja o que tem dentro.';

  @override
  String get dailyChestDouble => 'Dobrar';

  @override
  String get dailyChestCollect => 'Coletar';

  @override
  String get dailyWinTitle => 'Desafio resolvido!';

  @override
  String dailyWinStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência de $countString dias',
      one: 'Sequência de $countString dia',
      zero: 'Sequência de $countString dias',
    );
    return '$_temp0';
  }

  @override
  String dailyWinChestHint(String count) {
    String _temp0 = intl.Intl.selectLogic(count, {
      '0': 'Seu baú do dia 7 está pronto!',
      '1': 'Mais um dia para o baú do dia 7',
      '2': 'Mais dois dias para o baú do dia 7',
      '3': 'Mais três dias para o baú do dia 7',
      '4': 'Mais quatro dias para o baú do dia 7',
      '5': 'Mais cinco dias para o baú do dia 7',
      '6': 'Mais seis dias para o baú do dia 7',
      'other': 'Mais $count dias para o baú do dia 7',
    });
    return '$_temp0';
  }

  @override
  String get dailyBackToDaily => 'Voltar ao desafio';

  @override
  String get museumTitle => 'Museu';

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
      other: 'Capítulo $chapterString · mais $countString níveis',
      one: 'Capítulo $chapterString · mais $countString nível',
      zero: 'Capítulo $chapterString · mais $countString níveis',
    );
    return '$_temp0';
  }

  @override
  String get museumAllHome => 'Todas as famílias estão em casa.';

  @override
  String get museumNextFamily => 'Próxima família';

  @override
  String get museumNextFamilyKicker => 'PRÓXIMA FAMÍLIA';

  @override
  String museumFamilyLabel(String name) {
    return 'Família $name';
  }

  @override
  String museumSoonLabel(String name) {
    return '$name · em breve';
  }

  @override
  String figurineShortName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'Clássica',
      'sailor': 'Marinheira',
      'baker': 'Padeira',
      'astronaut': 'Astronauta',
      'gardener': 'Jardineira',
      'snow': 'Nevada',
      'circus': 'Circense',
      'musician': 'Musical',
      'royal': 'Real',
      'explorer': 'Exploradora',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String figurineFlavor(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': '“A menorzinha ganha todas as partidas de esconde-esconde.”',
      'sailor':
          '“Elas guardam uma conchinha na boneca menor, só por precaução.”',
      'baker':
          '“Elas assam cada pão em quatro tamanhos, para ninguém ter que dividir.”',
      'astronaut': '“Elas contam da maior à menor antes de cada viagem à lua.”',
      'gardener':
          '“Cada chapéu esconde uma semente guardada para a primavera.”',
      'snow':
          '“Quando ninguém está olhando, elas se empilham e viram um boneco de neve.”',
      'circus':
          '“O melhor número delas é entrar umas dentro das outras, sob muitos aplausos.”',
      'musician':
          '“Elas tocam uma canção em quatro tamanhos. A menorzinha faz os agudos.”',
      'royal':
          '“Cada coroa cabe dentro da seguinte, o que economiza muito espaço.”',
      'explorer':
          '“Elas já mapearam todas as prateleiras da loja, e ainda não terminaram.”',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String museumChapterChip(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Capítulo $numberString · $name';
  }

  @override
  String museumCollectedOn(String date) {
    return 'Conquistada · $date';
  }

  @override
  String get museumCollected => 'Conquistada';

  @override
  String museumLockedText(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Conclua o capítulo $numberString para levar esta família para casa.';
  }

  @override
  String museumIntro(int levels) {
    final intl.NumberFormat levelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelsString = levelsNumberFormat.format(levels);

    return 'Cada capítulo tem uma família de bonecas. Vença os $levelsString níveis dele para levar a família para casa.';
  }

  @override
  String museumLevelsToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mais $countString níveis',
      one: 'mais $countString nível',
      zero: 'mais $countString níveis',
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
      other: 'mais $countString',
      one: 'mais $countString',
      zero: 'mais $countString',
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

    return 'Cap. $chapterString · $firstString–$lastString';
  }

  @override
  String museumLockedLine1(int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'Capítulo $chapterString';
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

    return 'Níveis $firstString–$lastString';
  }

  @override
  String get shopTitle => 'Loja';

  @override
  String get shopTabCoins => 'Moedas';

  @override
  String get shopTabSkins => 'Aparências';

  @override
  String get shopTabThemes => 'Temas';

  @override
  String get shopTabNoAds => 'Sem anúncios';

  @override
  String get shopEquipped => 'Em uso';

  @override
  String get shopEquip => 'Usar';

  @override
  String get skinOwnedSemantics => 'Adquirido';

  @override
  String skinName(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Clássico',
      'space': 'Espaço',
      'ocean': 'Oceano',
      'sweets': 'Doces',
      'forest': 'Amigos da Floresta',
      'winter': 'Inverno',
      'forest_bear': 'Urso da Floresta',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String skinDescription(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Flores pintadas, bolinhas douradas e um lacinho.',
      'ocean': 'Golas de marinheiro, âncoras pequeninas e barras de ondas.',
      'space': 'Capacetes redondos, antenas pequeninas e planetas com anéis.',
      'sweets': 'Cobertura escorrendo, granulados e listras de doce.',
      'forest': 'Orelhas pontudas, capuzes com pérolas e folhas caindo.',
      'winter': 'Gorros com pompom, flocos de neve e barras perolados.',
      'forest_bear':
          'Orelhas redondas de urso, capuzes aconchegantes e bolotas entre as folhas.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get skinDetailTitle => 'Aparência';

  @override
  String get skinDetailColors => 'Todas as 11 cores · símbolos mantidos';

  @override
  String get skinDetailSizes =>
      'Todos os tamanhos se encaixam do mesmo jeito. Só a pintura muda.';

  @override
  String get shopBuy => 'Comprar';

  @override
  String shopBuySemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Comprar, $countString moedas',
      one: 'Comprar, $countString moeda',
      zero: 'Comprar, $countString moedas',
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
      other: 'Você tem $countString moedas',
      one: 'Você tem $countString moeda',
      zero: 'Você tem $countString moedas',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsTitle => 'Mais algumas moedas';

  @override
  String notEnoughCoinsNeeded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você precisa de mais $countString moedas',
      one: 'Você precisa de mais $countString moeda',
      zero: 'Você precisa de mais $countString moedas',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsSource =>
      'As moedas vêm de vencer níveis, do desafio diário e dos baús.';

  @override
  String get notEnoughCoinsGoToShop => 'Ir à Loja';

  @override
  String get notNow => 'Agora não';

  @override
  String shopDownloading(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'Baixando $percentString%';
  }

  @override
  String get themesMatchTitle => 'Acompanhar cada capítulo';

  @override
  String get themesMatchSubtitle => 'Usa o tema do capítulo em que você está';

  @override
  String get themeInUse => 'Em uso';

  @override
  String get themeUse => 'Usar';

  @override
  String themeChapterLock(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Cap. $numberString';
  }

  @override
  String get shopClosedTitle => 'A loja está fechada por enquanto';

  @override
  String get shopClosedBody =>
      'Os pacotes de moedas e o Remover anúncios chegam em uma próxima atualização.';

  @override
  String buyUndoText(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Você já usou seus $countString usos grátis de Desfazer. Desfaça mais uma jogada.',
      one:
          'Você já usou $countString uso grátis de Desfazer. Desfaça mais uma jogada.',
      zero:
          'Você já usou seus $countString usos grátis de Desfazer. Desfaça mais uma jogada.',
    );
    return '$_temp0';
  }

  @override
  String get buyHintText => 'Mostra sua melhor jogada seguinte.';

  @override
  String get buySlotText => 'Adiciona um espaço vazio para este nível.';

  @override
  String get tutorialStep1Title => 'Toque na boneca pequena';

  @override
  String tutorialStepChip(int step, int total) {
    return 'PASSO $step DE $total';
  }

  @override
  String get tutorialStep1Text =>
      'As bonecas se encaixam na da mesma cor, um tamanho maior.';

  @override
  String get tutorialStep2Title => 'Agora toque na grande';

  @override
  String get tutorialStep2Text => 'A boneca pequena cai dentro com um clac.';

  @override
  String get tutorialStep3Title => 'Complete a família';

  @override
  String get tutorialStep3Text =>
      'Coloque a última boneca. A família está completa quando todos os tamanhos estão encaixados.';

  @override
  String tutorialStepSemantics(int step, String title) {
    final intl.NumberFormat stepNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String stepString = stepNumberFormat.format(step);

    return 'Passo $stepString de 3. $title';
  }

  @override
  String get tutorialSwallowChip => 'NOVA JOGADA';

  @override
  String get tutorialSwallowTitle => 'A grande pode engolir a pequena';

  @override
  String get tutorialSwallowText =>
      'Solte uma boneca grande sobre a do tamanho seguinte e ela se fecha bem em cima.';

  @override
  String get introNew => 'NOVO';

  @override
  String get introTowersTitle => 'Torres!';

  @override
  String get introTowersText =>
      'Só a boneca de cima pode se mover. Tire-a para revelar a que está escondida embaixo.';

  @override
  String get introGlassTitle => 'Vitrines';

  @override
  String get introGlassText =>
      'Uma boneca com cadeado é libertada quando a família do cadeado está completa.';

  @override
  String get introIceTitle => 'Gelo';

  @override
  String get introIceText =>
      'Cada família que você completa quebra o gelo. Ao chegar a zero, a boneca fica livre.';

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
  String get introGotIt => 'Entendi';

  @override
  String chapterCompleteTitle(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'CAPÍTULO $numberString CONCLUÍDO';
  }

  @override
  String get chapterCompleteAdded => 'Adicionada ao seu Museu!';

  @override
  String chapterCompleteCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString moedas';
  }

  @override
  String chapterCompleteNext(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'A seguir: capítulo $numberString · $name';
  }

  @override
  String get gameplayGenerating => 'Montando as prateleiras…';

  @override
  String dailyStreakPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Sua sequência de $countString dias está descansando. Resolva o desafio de hoje para acendê-la de novo.',
      one:
          'Sua sequência de $countString dia está descansando. Resolva o desafio de hoje para acendê-la de novo.',
      zero:
          'Sua sequência de $countString dias está descansando. Resolva o desafio de hoje para acendê-la de novo.',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakPausedChip => 'Em pausa';

  @override
  String get dailyStreakRelitTitle => 'Sequência acesa de novo!';

  @override
  String dailyStreakRelitBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sua sequência de $countString dias está brilhando de novo.',
      one: 'Sua sequência de $countString dia está brilhando de novo.',
      zero: 'Sua sequência de $countString dias está brilhando de novo.',
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
      other: 'Sequência de $countString dias, em pausa',
      one: 'Sequência de $countString dia, em pausa',
      zero: 'Sequência de $countString dias, em pausa',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => 'Capítulos';

  @override
  String chaptersOverallProgress(int level, int total) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Nível $levelString de $totalString';
  }

  @override
  String chaptersWonCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString vencidos',
      one: '$countString vencido',
      zero: '$countString vencidos',
    );
    return '$_temp0';
  }

  @override
  String chaptersBestMoves(int best) {
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Melhor $bestString';
  }

  @override
  String get chaptersLevelPlay => 'Jogar';

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
          'Nível $levelString, $countString estrelas. Melhor: $bestString jogadas.',
      one:
          'Nível $levelString, $countString estrela. Melhor: $bestString jogadas.',
      zero:
          'Nível $levelString, $countString estrelas. Melhor: $bestString jogadas.',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsWonNoBest(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Nível $levelString, vencido';
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
      other: 'Nível $levelString, vencido. Melhor: $bestString jogadas.',
      one: 'Nível $levelString, vencido. Melhor: $bestString jogada.',
      zero: 'Nível $levelString, vencido. Melhor: $bestString jogadas.',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsCurrent(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Nível $levelString, o próximo a jogar';
  }

  @override
  String chaptersLevelSemanticsLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Nível $levelString, bloqueado';
  }

  @override
  String get recordsTitle => 'Recordes';

  @override
  String get homeRecordsButton => 'Recordes';

  @override
  String get recordsLevelsWon => 'Níveis vencidos';

  @override
  String get recordsFamilies => 'Famílias completas';

  @override
  String get recordsRacesHeader => 'Corridas vencidas';

  @override
  String get recordsDolls => 'Bonecas encaixadas';

  @override
  String get recordsDailies => 'Desafios diários resolvidos';

  @override
  String get recordsLongestStreak => 'Maior sequência';

  @override
  String get recordsBestMovesLink => 'Recordes por nível';

  @override
  String get recordsBadgesHeader => 'Insígnias';

  @override
  String badgeName(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Aconchego no Ninho',
      'glass_breaker': 'Golpe de Vidro',
      'ice_melter': 'Quebra-Gelo',
      'tall_order': 'Desafio nas Alturas',
      'grand_nest': 'Grande Ninho',
      'level_100': 'Meio Caminho',
      'level_200': 'No Topo',
      'dailies_7': 'Parceria Diária',
      'dailies_30': 'Amizade Antiga',
      'first_race': 'Primeira Chegada',
      'all_rivals': 'Todos os Rivais',
      'museum_full': 'Casa Cheia',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeLine(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Você encaixou sua primeira família.',
      'glass_breaker': 'Você abriu sua primeira vitrine.',
      'ice_melter': 'Você libertou uma boneca do gelo.',
      'tall_order': 'Você venceu um nível com bonecas de tamanho 5.',
      'grand_nest': 'Você venceu um nível com bonecas de tamanho 6.',
      'level_100': 'Você venceu o nível 100.',
      'level_200': 'Você venceu o nível 200, o último de todos.',
      'dailies_7': 'Você resolveu 7 desafios diários.',
      'dailies_30': 'Você resolveu 30 desafios diários.',
      'first_race': 'Você venceu o computador em uma corrida.',
      'all_rivals': 'Você venceu todos os rivais controlados pelo computador.',
      'museum_full': 'Todas as famílias estão em casa, no seu Museu.',
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
      'first_family': 'Encaixe uma família inteira.',
      'glass_breaker': 'Abra uma vitrine.',
      'ice_melter': 'Liberte uma boneca do gelo.',
      'tall_order': 'Vença um nível com bonecas de tamanho 5.',
      'grand_nest': 'Vença um nível com bonecas de tamanho 6.',
      'level_100': 'Vença o nível $levelString.',
      'level_200': 'Vença o nível $levelString.',
      'dailies_7': 'Resolva $countString desafios diários.',
      'dailies_30': 'Resolva $countString desafios diários.',
      'first_race': 'Vença o computador em uma corrida.',
      'all_rivals': 'Vença todos os rivais controlados pelo computador.',
      'museum_full': 'Leve todas as famílias para casa, no seu Museu.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeSemanticsEarned(String badge) {
    return '$badge, conquistada';
  }

  @override
  String badgeSemanticsLocked(String badge, String how) {
    return '$badge, ainda não conquistada. $how';
  }

  @override
  String badgeEarnedToastTitle(String badge) {
    return 'Insígnia conquistada · $badge';
  }

  @override
  String get badgeLockedLine => 'Ainda não conquistada';

  @override
  String winMovesBest(int moves, int best) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Jogadas $movesString · Melhor $bestString';
  }

  @override
  String winMovesOnly(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return 'Jogadas $movesString';
  }

  @override
  String winChestCountdown(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString níveis para o baú',
      one: '$countString nível para o baú',
      zero: '$countString níveis para o baú',
    );
    return '$_temp0';
  }

  @override
  String get winReplayReason =>
      'Uma repetição por diversão: as moedas vêm de níveis novos.';

  @override
  String get winBackToChapters => 'Voltar aos Capítulos';

  @override
  String get chestMilestoneTitle => 'Baú de conquista';

  @override
  String chestMilestoneBody(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Um baú por chegar ao nível $levelString. Veja o que tem dentro.';
  }

  @override
  String chestMilestoneBodyBonus(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Um baú pelo nível bônus $levelString. Veja o que tem dentro.';
  }

  @override
  String chestContentsCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString moedas',
      one: '+$countString moeda',
      zero: '+$countString moedas',
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
      other: '+$countString dicas',
      one: '+$countString dica',
      zero: '+$countString dicas',
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
      other: '$coinsString moedas',
      one: '$coinsString moeda',
      zero: '$coinsString moedas',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hints,
      locale: localeName,
      other: '$hintsString dicas',
      one: '$hintsString dica',
      zero: '$hintsString dicas',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String chestSemantics(String contents) {
    return 'Baú. Dentro: $contents.';
  }

  @override
  String get chestOpen => 'Abrir';

  @override
  String get settingRelaxedMode => 'Modo tranquilo';

  @override
  String get settingRelaxedModeSubtitle => 'Desfazer grátis sem limite';

  @override
  String get relaxedModeOn =>
      'O modo tranquilo está ligado. Desfaça quantas vezes quiser.';

  @override
  String get settingReduceMotion => 'Reduzir movimento';

  @override
  String get reduceMotionSystem => 'Sistema';

  @override
  String get reduceMotionOn => 'Ligado';

  @override
  String get reduceMotionOff => 'Desligado';

  @override
  String get oomUndoFreeUnlimited => 'Grátis, quantas vezes quiser';

  @override
  String oomUndoSpent(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você já usou seus $countString usos grátis de Desfazer',
      one: 'Você já usou $countString uso grátis de Desfazer',
      zero: 'Você já usou seus $countString usos grátis de Desfazer',
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
      other: '$countString espaços extras são o máximo por nível.',
      one: 'Um espaço extra é o máximo por nível.',
    );
    return '$_temp0';
  }

  @override
  String get boosterUndoUnlimitedSemantics => 'Desfazer, sem limite';

  @override
  String get oomUndoFreeChip => 'Grátis';

  @override
  String boosterLimitSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '+Espaço, $countString de $totalString usados';
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
    return '$booster, sugerido';
  }

  @override
  String get boosterRestartSemantics => 'Reiniciar o nível';

  @override
  String get homeVsComputerTile => 'vs. Computador';

  @override
  String homeVsComputerLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Após o nível $levelString';
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
  String get raceSelectTitle => 'vs. Computador';

  @override
  String get raceSelectSubtitle => 'Dispute o mesmo desafio com um computador';

  @override
  String get raceComputerTag => 'Computador';

  @override
  String raceRivalName(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Cometa',
      two: 'Botão',
      one: 'Pedrinha',
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
      other: 'Muita energia, capricho e um ritmo difícil de alcançar.',
      two: 'Confere cada jogada duas vezes e depois joga.',
      one: 'Leva o tempo que precisa e curte cada boneca pelo caminho.',
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
      other: 'Ritmo animado',
      two: 'Ritmo constante',
      one: 'Ritmo suave',
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
      other: 'Ganhe $coinsString moedas',
      one: 'Ganhe $coinsString moeda',
      zero: 'Ganhe $coinsString moedas',
    );
    return '$_temp0';
  }

  @override
  String raceRivalLocked(String rival) {
    return 'Vença $rival para desbloquear';
  }

  @override
  String get raceRivalNew => 'Novo';

  @override
  String raceRivalSemantics(String name) {
    return '$name, Computador';
  }

  @override
  String raceRivalCardSemantics(String rival, String skill) {
    return '$rival, rival controlado pelo computador. $skill.';
  }

  @override
  String raceRivalLockedSemantics(String rival) {
    return 'Rival bloqueado, controlado pelo computador. Vença $rival para desbloquear.';
  }

  @override
  String get raceRivalSelectedSemantics => 'Selecionado';

  @override
  String get raceStart => 'Começar';

  @override
  String get raceStartHint =>
      'O mesmo desafio, dois tabuleiros. Ganha quem completar todas as famílias primeiro.';

  @override
  String get raceStripReady => 'Tudo pronto quando você estiver';

  @override
  String get raceStripThinking => 'Pensando…';

  @override
  String get raceStripStartingOver => 'Recomeçando';

  @override
  String get raceStripFinished => 'Concluiu';

  @override
  String get raceStripPlayerFinished => 'Você concluiu primeiro';

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
      other: '$name, computador: $countString de $totalString famílias',
      one: '$name, computador: $countString de $totalString família',
      zero: '$name, computador: $countString de $totalString famílias',
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

    return 'O computador completou uma família: $doneString de $totalString';
  }

  @override
  String raceAnnounceStart(String rival) {
    return 'Começou a corrida contra $rival, rival controlado pelo computador.';
  }

  @override
  String get raceAnnounceStartingOver => 'O computador está recomeçando.';

  @override
  String get raceAnnounceFinished =>
      'O computador completou todas as famílias.';

  @override
  String get raceAnnounceWon => 'Você venceu a corrida.';

  @override
  String get raceAnnounceLost => 'O computador concluiu primeiro.';

  @override
  String get raceWinTitle => 'Você venceu a corrida!';

  @override
  String get raceWinTitleShort => 'Você venceu!';

  @override
  String raceWinBody(String rival) {
    return 'Todas as famílias estão completas. $rival ainda estava organizando.';
  }

  @override
  String raceWinCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString moedas',
      one: '+$countString moeda',
      zero: '+$countString moedas',
    );
    return '$_temp0';
  }

  @override
  String get raceLossTitle => 'Quase! Revanche?';

  @override
  String get raceLossTitleShort => 'Quase!';

  @override
  String raceLossBody(String rival) {
    return '$rival chegou primeiro desta vez. Uma revanche não custa nada.';
  }

  @override
  String get raceRivalUnlockedTitle => 'Novo rival!';

  @override
  String raceRivalUnlockedBody(String rival) {
    return '$rival já pode correr com você.';
  }

  @override
  String raceRivalUnlockedRace(String rival) {
    return 'Correr contra $rival';
  }

  @override
  String get raceLeaveTitle => 'Sair desta corrida?';

  @override
  String get raceLeaveBody =>
      'Sair interrompe a corrida. Sem moedas, e você mantém todo o resto.';

  @override
  String get raceLeaveKeep => 'Continuar a corrida';

  @override
  String get raceRematch => 'Revanche';

  @override
  String get raceNewRace => 'Nova corrida';

  @override
  String get raceBackToRivals => 'Voltar às corridas';

  @override
  String get raceFailedTitle => 'As prateleiras precisam de um momento';

  @override
  String get raceFailedBody =>
      'Não foi possível montar esta corrida. Tente de novo ou escolha outra corrida.';

  @override
  String racePauseSubtitle(String rival) {
    return '$rival também está em pausa.';
  }

  @override
  String racePauseHeader(String rival) {
    return 'vs. Computador · $rival';
  }

  @override
  String get raceRivalBeaten => 'Vitória';

  @override
  String raceStartFor(String rival) {
    return 'Começar corrida contra $rival';
  }

  @override
  String get raceQuit => 'Sair da corrida';

  @override
  String starsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de 3 estrelas',
      one: '$count de 3 estrelas',
      zero: '$count de 3 estrelas',
    );
    return '$_temp0';
  }

  @override
  String starsNewBestSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Novo recorde, $count de 3 estrelas',
      one: 'Novo recorde, $count de 3 estrelas',
      zero: 'Novo recorde, $count de 3 estrelas',
    );
    return '$_temp0';
  }

  @override
  String winStarsTarget(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return '3 estrelas com $movesString jogadas ou menos';
  }

  @override
  String get winStarsNewBest => 'Novo recorde!';

  @override
  String get starsFirstTip =>
      'Com menos jogadas você ganha mais estrelas. Repita qualquer nível pelos Capítulos.';

  @override
  String get starsHelperNote =>
      'Vencer com uma dica ou um espaço extra dá até 2 estrelas.';

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
  String get chaptersAllThreeStars => 'Todos os níveis com 3 estrelas';

  @override
  String chaptersStarsSemantics(int earned, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      earned,
      locale: localeName,
      other: '$earned de $total estrelas',
      one: '$earned de $total estrelas',
      zero: '$earned de $total estrelas',
    );
    return '$_temp0';
  }

  @override
  String get recordsStars => 'Estrelas';

  @override
  String recordsStarsValue(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString de $totalString';
  }

  @override
  String get dailyShare => 'Compartilhar';

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
  String get dailyShareSemantics => 'Compartilhar o resultado de hoje';

  @override
  String dailyShareText(String date, String glyphs, int moves, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'Resolvido em $moves jogadas · Dia $day 🔥',
      one: 'Resolvido em $moves jogada · Dia $day 🔥',
      zero: 'Resolvido em $moves jogadas · Dia $day 🔥',
    );
    return 'Nesty Desafio diário · $date\n$glyphs\n$_temp0';
  }

  @override
  String dailyShareTextNoStreak(String date, String glyphs, int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'Resolvido em $moves jogadas',
      one: 'Resolvido em $moves jogada',
      zero: 'Resolvido em $moves jogadas',
    );
    return 'Nesty Desafio diário · $date\n$glyphs\n$_temp0';
  }

  @override
  String get reminderOfferTitle =>
      'Quer um aviso quando o desafio de amanhã estiver pronto?';

  @override
  String get reminderOfferBody =>
      'Um aviso tranquilo por dia, no horário que você escolher. Você pode desligar em Ajustes.';

  @override
  String reminderOfferTime(String time) {
    return 'Todo dia às $time';
  }

  @override
  String get reminderOfferChangeTime => 'Mudar horário';

  @override
  String reminderTimeChipSemantics(String time) {
    return 'Horário do lembrete, todo dia às $time. Mudar horário.';
  }

  @override
  String get reminderPickerTitle => 'Horário do lembrete';

  @override
  String get reminderOfferYes => 'Sim, me avise';

  @override
  String get reminderOfferNo => 'Não, obrigado';

  @override
  String reminderOfferDone(String time) {
    return 'Lembrete marcado para as $time.';
  }

  @override
  String get reminderOfferDeniedTitle =>
      'As notificações do Nesty estão desligadas';

  @override
  String reminderOfferDenied(String time) {
    return 'Ligue-as nos ajustes do celular e seu aviso chegará às $time.';
  }

  @override
  String get reminderNotificationTitle => 'Nesty';

  @override
  String get reminderNotificationBody =>
      'O desafio de hoje já está na prateleira.';

  @override
  String get reminderNotificationBody2 =>
      'Um novo desafio diário está pronto, para quando você quiser.';

  @override
  String get reminderNotificationBody3 =>
      'Há bonecas novas esperando para se encaixar. O desafio de hoje está pronto.';

  @override
  String get reminderChannelName => 'Desafio diário';

  @override
  String get reminderChannelDescription =>
      'Um aviso por dia quando há um novo desafio diário.';

  @override
  String get settingReminder => 'Lembrete diário';

  @override
  String get settingReminderTime => 'Horário';

  @override
  String get settingReminderBlocked => 'Desligado nos ajustes do celular';

  @override
  String get settingOpenPhoneSettings => 'Abrir ajustes do celular';

  @override
  String get settingReminderTurnOff => 'Desligar';

  @override
  String homeChapterKicker(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'CAPÍTULO $numberString';
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

    return 'Capítulo $chapterString, $name. $countString de $totalString estrelas. Abre os Capítulos.';
  }

  @override
  String homeBonusCardSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Níveis bônus. $countString de $totalString estrelas. Abre os Capítulos.';
  }

  @override
  String get homeVsComputerSemantics =>
      'vs. Computador. Dispute o mesmo desafio com um computador.';

  @override
  String homeVsComputerLockedSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'vs. Computador, bloqueado. Após o nível $levelString.';
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

    return 'CAPÍTULO $numberString · NÍVEIS $firstString–$lastString';
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

    return 'Capítulo $chapterString, $name. $countString de $totalString estrelas.';
  }

  @override
  String chaptersRowLockedSemantics(int chapter, String name) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'Capítulo $chapterString, $name. Bloqueado.';
  }

  @override
  String get chaptersLevelChestSemantics => 'Um baú neste nível';

  @override
  String get chaptersLevelFinaleSemantics => 'O último nível do capítulo';

  @override
  String museumNicheCollectedSemantics(String name) {
    return '$name, em casa, no seu Museu';
  }

  @override
  String museumNicheNextSemantics(String name, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, a próxima a chegar em casa. Mais $countString níveis.',
      one: '$name, a próxima a chegar em casa. Mais $countString nível.',
      zero: '$name, a próxima a chegar em casa. Mais $countString níveis.',
    );
    return '$_temp0';
  }

  @override
  String museumNicheLockedSemantics(String name, int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return '$name, ainda não está em casa. Capítulo $chapterString.';
  }

  @override
  String museumCountSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString de $totalString famílias em casa';
  }

  @override
  String museumFullSub(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Casa Cheia · as $countString famílias';
  }

  @override
  String recordsRaceSemantics(String rival, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$rival, computador. $countString vitórias.',
      one: '$rival, computador. $countString vitória.',
      zero: '$rival, computador. $countString vitórias.',
    );
    return '$_temp0';
  }

  @override
  String recordsRaceLockedSemantics(String rival) {
    return '$rival, computador. Bloqueado.';
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

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');
}
