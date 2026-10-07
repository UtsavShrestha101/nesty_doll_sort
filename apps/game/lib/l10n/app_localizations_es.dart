// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Nesty';

  @override
  String get splashLoading => 'Cargando…';

  @override
  String progressPercent(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString';
  }

  @override
  String get genericLoadFailed => 'Algo salió mal.';

  @override
  String get splashStorageTitle => 'Tu teléfono está casi lleno';

  @override
  String splashStorageBody(int size) {
    final intl.NumberFormat sizeNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String sizeString = sizeNumberFormat.format(size);

    return 'Nesty necesita unos $sizeString MB para preparar los estantes. Libera espacio y vuelve a intentarlo.';
  }

  @override
  String get splashContentTitle => 'Los estantes no se desempacaron';

  @override
  String get splashContentBody =>
      'Algo salió mal al cargar. Vuelve a intentarlo o reinicia Nesty.';

  @override
  String get retry => 'Reintentar';

  @override
  String levelTitle(int level) {
    return 'Nivel $level';
  }

  @override
  String get pause => 'Pausa';

  @override
  String get boosterUndo => 'Deshacer';

  @override
  String get boosterUndoShort => 'Deshacer';

  @override
  String get boosterHint => 'Pista';

  @override
  String get boosterHintShort => 'Pista';

  @override
  String get boosterExtraSlot => '+Espacio';

  @override
  String get boosterExtraSlotShort => '+1';

  @override
  String get restart => 'Reiniciar';

  @override
  String get restartShort => 'Reiniciar';

  @override
  String get splashDollSort => 'ORDENA MUÑECAS';

  @override
  String get splashCaption => 'Quitando el polvo de los estantes…';

  @override
  String get homePlay => 'JUGAR';

  @override
  String get homeAllLevelsDone => '¡Todo listo!';

  @override
  String playSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Jugar el nivel $levelString';
  }

  @override
  String playLevelSemantics(int level, String tier) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Jugar el nivel $levelString, $tier';
  }

  @override
  String coinPillShopSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString monedas. Abre la Tienda.',
      one: '$countString moneda. Abre la Tienda.',
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
      'medium': 'Medio',
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

    return 'Nivel $levelString · $tier';
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
      other: '$countString de $totalString familias completas',
      one: '$countString de $totalString familia completa',
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
      other: '$countString monedas',
      one: '1 moneda',
    );
    return '$_temp0';
  }

  @override
  String get levelDaily => 'Desafío';

  @override
  String levelDailySemantics(String date) {
    return 'Desafío diario, $date';
  }

  @override
  String bonusLevelTitle(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Nivel bonus $levelString';
  }

  @override
  String get closeSemantics => 'Cerrar';

  @override
  String get backSemantics => 'Atrás';

  @override
  String boosterAdSemantics(String booster) {
    return '$booster, ver un video';
  }

  @override
  String boosterCoinSemantics(String booster, int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$booster, $priceString monedas',
      one: '$booster, $priceString moneda',
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
      other: 'Deshacer, $countString disponibles',
      one: 'Deshacer, $countString disponible',
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
      other: 'Pista, $countString disponibles',
      one: 'Pista, $countString disponible',
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
      other: 'Espacio extra, $countString disponibles',
      one: 'Espacio extra, $countString disponible',
    );
    return '$_temp0';
  }

  @override
  String get softStuckTitle => 'Mmm, esto parece atascado';

  @override
  String get softStuckBody =>
      '¿Probamos Deshacer? También puedes seguir jugando.';

  @override
  String get softStuckBodyRestart =>
      '¿Probamos Reiniciar? También puedes seguir jugando.';

  @override
  String get softStuckAction => 'Deshacer';

  @override
  String get oomTitle => '¡Sin movimientos!';

  @override
  String get oomSubtitle => 'Elige cómo seguir ordenando.';

  @override
  String get oomUndoSubtitle => 'Deshaz tu último movimiento';

  @override
  String oomUndoFree(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gratis · $countString disponibles',
      one: 'Gratis · 1 disponible',
    );
    return '$_temp0';
  }

  @override
  String get oomSlotTitle => '+1 Espacio';

  @override
  String get oomSlotSubtitle => 'Agrega un espacio para este nivel';

  @override
  String get oomSlotOffline => 'Con monedas, sin conexión';

  @override
  String get oomRestartSubtitle => 'Empieza este nivel de nuevo, gratis';

  @override
  String coinPrice(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString monedas',
      one: '1 moneda',
    );
    return '$_temp0';
  }

  @override
  String get watchAd => 'Ver anuncio';

  @override
  String get watchAdSemantics => 'Ver un anuncio';

  @override
  String get offlineTitle => 'Sin conexión';

  @override
  String get offlineAds => 'Los botones de anuncio pasan a precios en monedas';

  @override
  String get connectToWatchAd => 'Conéctate para ver un anuncio';

  @override
  String get winTitle => '¡Nivel completado!';

  @override
  String get winTitleShort => '¡Completado!';

  @override
  String get winContinue => 'Continuar';

  @override
  String get winTripleCoins => '×3 monedas';

  @override
  String get winRewardAdded => 'Recompensa agregada';

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
    return 'Sigue: $name';
  }

  @override
  String get winChapterDone => '¡Capítulo completado! Ahí viene tu premio.';

  @override
  String figurineName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'La familia clásica',
      'sailor': 'La familia marinera',
      'baker': 'La familia panadera',
      'astronaut': 'La familia astronauta',
      'gardener': 'La familia jardinera',
      'snow': 'La familia nevada',
      'circus': 'La familia circense',
      'musician': 'La familia musical',
      'royal': 'La familia real',
      'explorer': 'La familia exploradora',
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
      'ch01': 'Juguetería soleada',
      'ch02': 'Rincón de café lluvioso',
      'ch03': 'Mercado junto al mar',
      'ch04': 'Cabaña nevada',
      'ch05': 'Carnaval nocturno',
      'ch06': 'Cobertizo de primavera',
      'ch07': 'Teatro de títeres',
      'ch08': 'Kiosco de otoño',
      'ch09': 'Biblioteca del castillo',
      'ch10': 'Mirador del amanecer',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get pauseTitle => 'En pausa';

  @override
  String get resume => 'Reanudar';

  @override
  String get home => 'Inicio';

  @override
  String get settings => 'Ajustes';

  @override
  String get settingSound => 'Sonido';

  @override
  String get settingMusic => 'Música';

  @override
  String get settingHaptics => 'Vibración';

  @override
  String get allLevelsTitle => '¡Terminaste todos los niveles!';

  @override
  String get allLevelsBody =>
      'Hay nuevos capítulos en camino. Mientras tanto, juega niveles bonus.';

  @override
  String allLevelsPlayBonus(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Jugar el nivel bonus $numberString';
  }

  @override
  String get allLevelsBackHome => 'Volver al inicio';

  @override
  String get nextLevelFailedHome => 'Volver al inicio';

  @override
  String get gameplayFailedTitle => 'Los estantes necesitan un momento';

  @override
  String get gameplayFailedBody =>
      'No se pudo preparar este nivel. Vuelve a intentarlo o regresa al inicio.';

  @override
  String get devLevelPickerTitle => 'Ir a un nivel';

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

    return 'Capítulo $numberString · Niveles $startString–$endString';
  }

  @override
  String get navShop => 'Tienda';

  @override
  String get navHomeShort => 'Inicio';

  @override
  String get navShopShort => 'Tienda';

  @override
  String get navMuseum => 'Museo';

  @override
  String get navMuseumShort => 'Museo';

  @override
  String get homeDailyTile => 'Desafío diario';

  @override
  String get homeMuseumTile => 'Museo';

  @override
  String get homeRemoveAdsTile => 'Quitar anuncios';

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

    return 'Tras el nivel $levelString';
  }

  @override
  String get homeBonusBadge => 'BONUS';

  @override
  String get homeBonusKicker => 'BONUS SIN FIN';

  @override
  String get homeBonusName => 'Niveles bonus';

  @override
  String streakBadgeSemantics(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha de $countString días',
      one: 'Racha de 1 día',
    );
    return '$_temp0';
  }

  @override
  String get settingColorSymbols => 'Símbolos de color';

  @override
  String get symbolsSubtle => 'Sutiles';

  @override
  String get symbolsLarge => 'Grandes';

  @override
  String get settingLanguage => 'Idioma';

  @override
  String get settingRestorePurchases => 'Restaurar compras';

  @override
  String get settingPrivacyChoices => 'Opciones de privacidad';

  @override
  String get settingPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingSupport => 'Soporte';

  @override
  String get settingSupportValue => 'Escríbenos';

  @override
  String settingsFooter(String version, String build, String playerId) {
    return 'Nesty: Doll Sort · v$version (compilación $build) · ID de jugador $playerId';
  }

  @override
  String get languageSheetTitle => 'Idioma';

  @override
  String get languageSheetDone => 'Listo';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'Inglés',
      'es': 'Español',
      'pt_BR': 'Portugués',
      'id': 'Indonesio',
      'hi': 'Hindi',
      'de': 'Alemán',
      'fr': 'Francés',
      'tr': 'Turco',
      'ja': 'Japonés',
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
      other: '$countString días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakKeep => 'Juega hoy para sumar a tu racha';

  @override
  String get dailyStreakStart =>
      'Resuelve el desafío de hoy para encender tu primera llama.';

  @override
  String get dailyStreakDone => 'Tu llama está encendida. Hasta mañana.';

  @override
  String get dailyStreakWeek => '¡Una semana completa!';

  @override
  String dailyFreezes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString protectores',
      one: '1 protector',
      zero: 'Sin protectores',
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
      other: '$countString protectores de racha',
      one: '$countString protector de racha',
    );
    return '$_temp0';
  }

  @override
  String get dailyDay => 'Día';

  @override
  String get dailyToday => 'Hoy';

  @override
  String get dailyTomorrow => 'Mañana';

  @override
  String dailyDaySemantics(String state, int day) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'done': 'Día $day, hecho',
      'today': 'Hoy, día $day',
      'tomorrow': 'Mañana, día $day',
      'chest': 'Día $day, cofre',
      'other': 'Día $day',
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
      other: 'Jugar, $countString monedas',
      one: 'Jugar, 1 moneda',
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
      other: 'Cofre del día 7 · $countString monedas',
      one: 'Cofre del día 7 · $countString moneda',
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
      other: '$countString días más',
      one: '1 día más',
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
      other: '$countString días más, contando hoy',
      one: '1 día más, contando hoy',
    );
    return '$_temp0';
  }

  @override
  String get dailyChestOpenedToday => 'Abierto hoy';

  @override
  String dailyPuzzleTitle(String weekday) {
    return 'Desafío del $weekday';
  }

  @override
  String dailyPuzzleInfo(int colors, String tier) {
    final intl.NumberFormat colorsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String colorsString = colorsNumberFormat.format(colors);

    String _temp0 = intl.Intl.pluralLogic(
      colors,
      locale: localeName,
      other: '$colorsString colores',
      one: '1 color',
    );
    return '$_temp0 · $tier';
  }

  @override
  String get dailyPlay => 'Jugar';

  @override
  String dailySolvedChip(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return 'Resuelto · +$coinsString';
  }

  @override
  String dailyNextPuzzle(String time) {
    return 'Próximo desafío en $time';
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

    return 'Jugar nivel $levelString';
  }

  @override
  String get dailySavedTitle => 'Un protector mantuvo encendida tu llama.';

  @override
  String dailySavedBody(String weekday) {
    return 'Un protector cubrió el $weekday. La próxima semana ganarás uno nuevo.';
  }

  @override
  String get dailyChestTitle => '¡Racha de 7 días!';

  @override
  String get dailyChestBody => 'Siete días seguidos. Mira lo que hay dentro.';

  @override
  String get dailyChestDouble => 'Duplicar';

  @override
  String get dailyChestCollect => 'Recoger';

  @override
  String get dailyWinTitle => '¡Desafío resuelto!';

  @override
  String dailyWinStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha de $countString días',
      one: 'Racha de 1 día',
    );
    return '$_temp0';
  }

  @override
  String dailyWinChestHint(String count) {
    String _temp0 = intl.Intl.selectLogic(count, {
      '0': '¡Tu cofre del día 7 está listo!',
      '1': 'Un día más para el cofre del día 7',
      '2': 'Dos días más para el cofre del día 7',
      '3': 'Tres días más para el cofre del día 7',
      '4': 'Cuatro días más para el cofre del día 7',
      '5': 'Cinco días más para el cofre del día 7',
      '6': 'Seis días más para el cofre del día 7',
      'other': '$count días más para el cofre del día 7',
    });
    return '$_temp0';
  }

  @override
  String get dailyBackToDaily => 'Volver al desafío';

  @override
  String get museumTitle => 'Museo';

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
      other: 'Capítulo $chapterString · $countString niveles más',
      one: 'Capítulo $chapterString · 1 nivel más',
    );
    return '$_temp0';
  }

  @override
  String get museumAllHome => 'Todas las familias están en casa.';

  @override
  String get museumNextFamily => 'Próxima familia';

  @override
  String get museumNextFamilyKicker => 'PRÓXIMA FAMILIA';

  @override
  String museumFamilyLabel(String name) {
    return 'Familia $name';
  }

  @override
  String museumSoonLabel(String name) {
    return '$name · próximamente';
  }

  @override
  String figurineShortName(String figurine) {
    String _temp0 = intl.Intl.selectLogic(figurine, {
      'classic': 'Clásica',
      'sailor': 'Marinera',
      'baker': 'Panadera',
      'astronaut': 'Astronauta',
      'gardener': 'Jardinera',
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
      'classic': '“La más pequeña gana todas las partidas de escondite.”',
      'sailor': '“Guardan una concha en la muñeca más pequeña, por si acaso.”',
      'baker':
          '“Hornean cada pan en cuatro tamaños, para no tener que compartir.”',
      'astronaut':
          '“Cuentan hacia atrás, de la más grande a la más pequeña, antes de cada viaje a la luna.”',
      'gardener':
          '“Cada sombrero esconde una semilla guardada para la primavera.”',
      'snow': '“Cuando nadie mira, se apilan y forman un muñeco de nieve.”',
      'circus':
          '“Su mejor número es meterse unas dentro de otras, entre aplausos.”',
      'musician':
          '“Tocan una canción en cuatro tamaños. La más pequeña hace los agudos.”',
      'royal':
          '“Cada corona cabe dentro de la siguiente, y así se ahorra mucho espacio.”',
      'explorer':
          '“Han recorrido todos los estantes de la tienda, y aún no terminan.”',
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
    return 'Conseguida · $date';
  }

  @override
  String get museumCollected => 'Conseguida';

  @override
  String museumLockedText(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Termina el capítulo $numberString para llevar a esta familia a casa.';
  }

  @override
  String museumIntro(int levels) {
    final intl.NumberFormat levelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelsString = levelsNumberFormat.format(levels);

    return 'Cada capítulo tiene una familia de muñecas. Gana sus $levelsString niveles para llevarla a casa.';
  }

  @override
  String museumLevelsToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString niveles más',
      one: '1 nivel más',
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
      other: '$countString más',
      one: '$countString más',
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

    return 'Niveles $firstString–$lastString';
  }

  @override
  String get shopTitle => 'Tienda';

  @override
  String get shopTabCoins => 'Monedas';

  @override
  String get shopTabSkins => 'Aspectos';

  @override
  String get shopTabThemes => 'Temas';

  @override
  String get shopTabNoAds => 'Sin anuncios';

  @override
  String get shopEquipped => 'En uso';

  @override
  String get shopEquip => 'Usar';

  @override
  String get skinOwnedSemantics => 'Adquirido';

  @override
  String skinName(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Clásico',
      'space': 'Espacio',
      'ocean': 'Océano',
      'sweets': 'Dulces',
      'forest': 'Amigos del bosque',
      'winter': 'Invierno',
      'forest_bear': 'Oso del bosque',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String skinDescription(String skin) {
    String _temp0 = intl.Intl.selectLogic(skin, {
      'classic': 'Flores pintadas, puntos dorados y un moñito.',
      'ocean': 'Cuellos de marinero, anclas diminutas y ribetes de olas.',
      'space': 'Cascos redondos, antenitas y planetas con anillos.',
      'sweets': 'Glaseado, chispas de colores y rayas de caramelo.',
      'forest': 'Orejas puntiagudas, capuchas con perlas y hojas que caen.',
      'winter': 'Gorros con pompón, copos de nieve y ribetes perlados.',
      'forest_bear':
          'Orejas de oso, capuchas abrigadas y bellotas entre las hojas.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get skinDetailTitle => 'Aspecto';

  @override
  String get skinDetailColors => 'Los 11 colores · símbolos incluidos';

  @override
  String get skinDetailSizes =>
      'Todos los tamaños se encajan igual. Solo cambia la pintura.';

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
      other: 'Comprar, $countString monedas',
      one: 'Comprar, 1 moneda',
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
      other: 'Tienes $countString monedas',
      one: 'Tienes 1 moneda',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsTitle => 'Unas monedas más';

  @override
  String notEnoughCoinsNeeded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Necesitas $countString monedas más',
      one: 'Necesitas 1 moneda más',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughCoinsSource =>
      'Las monedas se ganan con los niveles, el desafío diario y los cofres.';

  @override
  String get notEnoughCoinsGoToShop => 'Ir a la Tienda';

  @override
  String get notNow => 'Ahora no';

  @override
  String shopDownloading(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'Descargando $percentString%';
  }

  @override
  String get themesMatchTitle => 'Combinar con cada capítulo';

  @override
  String get themesMatchSubtitle => 'Usa el tema del capítulo en el que estás';

  @override
  String get themeInUse => 'En uso';

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
  String get shopClosedTitle => 'La tienda está cerrada por ahora';

  @override
  String get shopClosedBody =>
      'Los paquetes de monedas y Quitar anuncios llegarán en una próxima actualización.';

  @override
  String buyUndoText(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Ya usaste tus $countString usos gratis de Deshacer. Deshaz un movimiento más.',
      one:
          'Ya usaste $countString uso gratis de Deshacer. Deshaz un movimiento más.',
    );
    return '$_temp0';
  }

  @override
  String get buyHintText => 'Muestra tu mejor jugada siguiente.';

  @override
  String get buySlotText => 'Agrega un espacio vacío para este nivel.';

  @override
  String get tutorialStep1Title => 'Toca la muñeca pequeña';

  @override
  String tutorialStepChip(int step, int total) {
    return 'PASO $step DE $total';
  }

  @override
  String get tutorialStep1Text =>
      'Las muñecas se encajan en la del mismo color, un tamaño más grande.';

  @override
  String get tutorialStep2Title => 'Ahora toca la grande';

  @override
  String get tutorialStep2Text => 'La muñeca pequeña cae dentro con un clac.';

  @override
  String get tutorialStep3Title => 'Completa la familia';

  @override
  String get tutorialStep3Text =>
      'Mete la última muñeca. Una familia está lista cuando todos los tamaños están encajados.';

  @override
  String tutorialStepSemantics(int step, String title) {
    final intl.NumberFormat stepNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String stepString = stepNumberFormat.format(step);

    return 'Paso $stepString de 3. $title';
  }

  @override
  String get tutorialSwallowChip => 'NUEVO MOVIMIENTO';

  @override
  String get tutorialSwallowTitle => 'La grande puede tragarse a la pequeña';

  @override
  String get tutorialSwallowText =>
      'Suelta una muñeca grande sobre la del tamaño siguiente y se cierra justo encima.';

  @override
  String get introNew => 'NUEVO';

  @override
  String get introTowersTitle => '¡Torres!';

  @override
  String get introTowersText =>
      'Solo la muñeca de arriba puede moverse. Quítala para descubrir la que se esconde debajo.';

  @override
  String get introGlassTitle => 'Vitrinas';

  @override
  String get introGlassText =>
      'Una muñeca con candado se libera cuando la familia de su candado está completa.';

  @override
  String get introIceTitle => 'Hielo';

  @override
  String get introIceText =>
      'Cada familia que completas rompe el hielo. Al llegar a cero, la muñeca queda libre.';

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
  String get introGotIt => 'Entendido';

  @override
  String chapterCompleteTitle(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'CAPÍTULO $numberString COMPLETADO';
  }

  @override
  String get chapterCompleteAdded => '¡Agregada a tu Museo!';

  @override
  String chapterCompleteCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString monedas';
  }

  @override
  String chapterCompleteNext(int number, String name) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Sigue: capítulo $numberString · $name';
  }

  @override
  String get gameplayGenerating => 'Preparando los estantes…';

  @override
  String dailyStreakPaused(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tu racha de $countString días está descansando. Resuelve el desafío de hoy para encenderla otra vez.',
      one:
          'Tu racha de 1 día está descansando. Resuelve el desafío de hoy para encenderla otra vez.',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakPausedChip => 'En pausa';

  @override
  String get dailyStreakRelitTitle => '¡Racha encendida otra vez!';

  @override
  String dailyStreakRelitBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tu racha de $countString días vuelve a brillar.',
      one: 'Tu racha de 1 día vuelve a brillar.',
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
      other: 'Racha de $countString días, en pausa',
      one: 'Racha de 1 día, en pausa',
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

    return 'Nivel $levelString de $totalString';
  }

  @override
  String chaptersWonCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ganados',
      one: '1 ganado',
    );
    return '$_temp0';
  }

  @override
  String chaptersBestMoves(int best) {
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Mejor $bestString';
  }

  @override
  String get chaptersLevelPlay => 'Jugar';

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
          'Nivel $levelString, $countString estrellas. Mejor marca: $bestString movimientos.',
      one:
          'Nivel $levelString, $countString estrella. Mejor marca: $bestString movimientos.',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsWonNoBest(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Nivel $levelString, ganado';
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
      other:
          'Nivel $levelString, ganado. Mejor marca: $bestString movimientos.',
      one: 'Nivel $levelString, ganado. Mejor marca: $bestString movimiento.',
    );
    return '$_temp0';
  }

  @override
  String chaptersLevelSemanticsCurrent(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Nivel $levelString, el próximo por jugar';
  }

  @override
  String chaptersLevelSemanticsLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Nivel $levelString, bloqueado';
  }

  @override
  String get recordsTitle => 'Récords';

  @override
  String get homeRecordsButton => 'Récords';

  @override
  String get recordsLevelsWon => 'Niveles ganados';

  @override
  String get recordsFamilies => 'Familias completadas';

  @override
  String get recordsRacesHeader => 'Carreras ganadas';

  @override
  String get recordsDolls => 'Muñecas encajadas';

  @override
  String get recordsDailies => 'Desafíos diarios resueltos';

  @override
  String get recordsLongestStreak => 'Racha más larga';

  @override
  String get recordsBestMovesLink => 'Mejores marcas por nivel';

  @override
  String get recordsBadgesHeader => 'Insignias';

  @override
  String badgeName(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Calentita en su nido',
      'glass_breaker': 'Golpe de cristal',
      'ice_melter': 'Rompehielos',
      'tall_order': 'Gran reto',
      'grand_nest': 'Gran nido',
      'level_100': 'A medio camino',
      'level_200': 'En lo más alto',
      'dailies_7': 'Amistad diaria',
      'dailies_30': 'Amigo de siempre',
      'first_race': 'Primera meta',
      'all_rivals': 'Barrido de rivales',
      'museum_full': 'Casa llena',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeLine(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_family': 'Encajaste tu primera familia.',
      'glass_breaker': 'Abriste tu primera vitrina.',
      'ice_melter': 'Liberaste una muñeca del hielo.',
      'tall_order': 'Ganaste un nivel con muñecas de tamaño 5.',
      'grand_nest': 'Ganaste un nivel con muñecas de tamaño 6.',
      'level_100': 'Ganaste el nivel 100.',
      'level_200': 'Ganaste el nivel 200, el último de todos.',
      'dailies_7': 'Resolviste 7 desafíos diarios.',
      'dailies_30': 'Resolviste 30 desafíos diarios.',
      'first_race': 'Le ganaste a la computadora en una carrera.',
      'all_rivals':
          'Venciste a todos los rivales controlados por la computadora.',
      'museum_full': 'Todas las familias están en casa, en tu Museo.',
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
      'first_family': 'Encaja una familia completa.',
      'glass_breaker': 'Abre una vitrina.',
      'ice_melter': 'Libera una muñeca del hielo.',
      'tall_order': 'Gana un nivel con muñecas de tamaño 5.',
      'grand_nest': 'Gana un nivel con muñecas de tamaño 6.',
      'level_100': 'Gana el nivel $levelString.',
      'level_200': 'Gana el nivel $levelString.',
      'dailies_7': 'Resuelve $countString desafíos diarios.',
      'dailies_30': 'Resuelve $countString desafíos diarios.',
      'first_race': 'Gánale a la computadora en una carrera.',
      'all_rivals': 'Vence a todos los rivales controlados por la computadora.',
      'museum_full': 'Lleva todas las familias a casa, a tu Museo.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String badgeSemanticsEarned(String badge) {
    return '$badge, conseguida';
  }

  @override
  String badgeSemanticsLocked(String badge, String how) {
    return '$badge, aún sin conseguir. $how';
  }

  @override
  String badgeEarnedToastTitle(String badge) {
    return 'Insignia conseguida · $badge';
  }

  @override
  String get badgeLockedLine => 'Aún sin conseguir';

  @override
  String winMovesBest(int moves, int best) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);
    final intl.NumberFormat bestNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String bestString = bestNumberFormat.format(best);

    return 'Movimientos $movesString · Mejor $bestString';
  }

  @override
  String winMovesOnly(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return 'Movimientos $movesString';
  }

  @override
  String winChestCountdown(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString niveles para el cofre',
      one: '1 nivel para el cofre',
    );
    return '$_temp0';
  }

  @override
  String get winReplayReason =>
      'Una repetición por diversión: las monedas vienen de niveles nuevos.';

  @override
  String get winBackToChapters => 'Volver a Capítulos';

  @override
  String get chestMilestoneTitle => 'Cofre de meta';

  @override
  String chestMilestoneBody(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Un cofre por llegar al nivel $levelString. Mira lo que hay dentro.';
  }

  @override
  String chestMilestoneBodyBonus(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Un cofre por el nivel bonus $levelString. Mira lo que hay dentro.';
  }

  @override
  String chestContentsCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString monedas',
      one: '+1 moneda',
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
      other: '+$countString pistas',
      one: '+1 pista',
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
      other: '$coinsString monedas',
      one: '$coinsString moneda',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hints,
      locale: localeName,
      other: '$hintsString pistas',
      one: '$hintsString pista',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String chestSemantics(String contents) {
    return 'Cofre. Dentro hay: $contents.';
  }

  @override
  String get chestOpen => 'Abrir';

  @override
  String get settingRelaxedMode => 'Modo relajado';

  @override
  String get settingRelaxedModeSubtitle => 'Deshacer gratis sin límite';

  @override
  String get relaxedModeOn =>
      'El modo relajado está activado. Deshaz tantas veces como quieras.';

  @override
  String get settingReduceMotion => 'Reducir movimiento';

  @override
  String get reduceMotionSystem => 'Sistema';

  @override
  String get reduceMotionOn => 'Activado';

  @override
  String get reduceMotionOff => 'Apagado';

  @override
  String get oomUndoFreeUnlimited => 'Gratis, tantas veces como quieras';

  @override
  String oomUndoSpent(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ya usaste tus $countString usos gratis de Deshacer',
      one: 'Ya usaste $countString uso gratis de Deshacer',
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
      other: '$countString espacios extra son el máximo por nivel.',
      one: 'Un espacio extra es el máximo por nivel.',
    );
    return '$_temp0';
  }

  @override
  String get boosterUndoUnlimitedSemantics => 'Deshacer, sin límite';

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

    return '+Espacio, $countString de $totalString usados';
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
  String get boosterRestartSemantics => 'Reiniciar el nivel';

  @override
  String get homeVsComputerTile => 'vs. Computadora';

  @override
  String homeVsComputerLocked(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Tras el nivel $levelString';
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
  String get raceSelectTitle => 'vs. Computadora';

  @override
  String get raceSelectSubtitle =>
      'Compite con una computadora en el mismo desafío';

  @override
  String get raceComputerTag => 'Computadora';

  @override
  String raceRivalName(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Cometa',
      two: 'Botón',
      one: 'Guijarro',
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
      other: 'Mucha energía, orden y un ritmo difícil de alcanzar.',
      two: 'Revisa cada movimiento dos veces y luego lo hace.',
      one: 'Se toma su tiempo y disfruta cada muñeca del camino.',
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
      other: 'Gana $coinsString monedas',
      one: 'Gana 1 moneda',
    );
    return '$_temp0';
  }

  @override
  String raceRivalLocked(String rival) {
    return 'Gana a $rival para desbloquear';
  }

  @override
  String get raceRivalNew => 'Nuevo';

  @override
  String raceRivalSemantics(String name) {
    return '$name, Computadora';
  }

  @override
  String raceRivalCardSemantics(String rival, String skill) {
    return '$rival, rival controlado por la computadora. $skill.';
  }

  @override
  String raceRivalLockedSemantics(String rival) {
    return 'Rival bloqueado, controlado por la computadora. Gana a $rival para desbloquear.';
  }

  @override
  String get raceRivalSelectedSemantics => 'Seleccionado';

  @override
  String get raceStart => 'Empezar';

  @override
  String get raceStartHint =>
      'El mismo desafío, dos tableros. Gana quien complete primero todas las familias.';

  @override
  String get raceStripReady => 'Todo listo cuando tú quieras';

  @override
  String get raceStripThinking => 'Pensando…';

  @override
  String get raceStripStartingOver => 'Empezando de nuevo';

  @override
  String get raceStripFinished => 'Completó';

  @override
  String get raceStripPlayerFinished => 'Completaste primero';

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
      other: '$name, computadora: $countString de $totalString familias',
      one: '$name, computadora: $countString de $totalString familia',
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

    return 'La computadora completó una familia: $doneString de $totalString';
  }

  @override
  String raceAnnounceStart(String rival) {
    return 'Empezó la carrera contra $rival, rival controlado por la computadora.';
  }

  @override
  String get raceAnnounceStartingOver =>
      'La computadora está empezando de nuevo.';

  @override
  String get raceAnnounceFinished =>
      'La computadora completó todas las familias.';

  @override
  String get raceAnnounceWon => 'Ganaste la carrera.';

  @override
  String get raceAnnounceLost => 'La computadora llegó primero.';

  @override
  String get raceWinTitle => '¡Ganaste la carrera!';

  @override
  String get raceWinTitleShort => '¡Ganaste!';

  @override
  String raceWinBody(String rival) {
    return 'Todas las familias están completas. $rival aún estaba ordenando.';
  }

  @override
  String raceWinCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countString monedas',
      one: '+1 moneda',
    );
    return '$_temp0';
  }

  @override
  String get raceLossTitle => '¡Casi! ¿Revancha?';

  @override
  String get raceLossTitleShort => '¡Casi!';

  @override
  String raceLossBody(String rival) {
    return '$rival llegó primero esta vez. Una revancha no cuesta nada.';
  }

  @override
  String get raceRivalUnlockedTitle => '¡Nuevo rival!';

  @override
  String raceRivalUnlockedBody(String rival) {
    return '$rival ya puede competir contigo.';
  }

  @override
  String raceRivalUnlockedRace(String rival) {
    return 'Competir con $rival';
  }

  @override
  String get raceLeaveTitle => '¿Salir de esta carrera?';

  @override
  String get raceLeaveBody =>
      'Salir detiene la carrera. Sin monedas, y conservas todo lo demás.';

  @override
  String get raceLeaveKeep => 'Seguir compitiendo';

  @override
  String get raceRematch => 'Revancha';

  @override
  String get raceNewRace => 'Nueva carrera';

  @override
  String get raceBackToRivals => 'Volver a las carreras';

  @override
  String get raceFailedTitle => 'Los estantes necesitan un momento';

  @override
  String get raceFailedBody =>
      'No se pudo preparar esta carrera. Vuelve a intentarlo o elige otra carrera.';

  @override
  String racePauseSubtitle(String rival) {
    return '$rival también está en pausa.';
  }

  @override
  String racePauseHeader(String rival) {
    return 'vs. Computadora · $rival';
  }

  @override
  String get raceRivalBeaten => 'Victoria';

  @override
  String raceStartFor(String rival) {
    return 'Empezar carrera contra $rival';
  }

  @override
  String get raceQuit => 'Salir de la carrera';

  @override
  String starsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de 3 estrellas',
      one: '1 de 3 estrellas',
    );
    return '$_temp0';
  }

  @override
  String starsNewBestSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nueva mejor marca, $count de 3 estrellas',
      one: 'Nueva mejor marca, 1 de 3 estrellas',
    );
    return '$_temp0';
  }

  @override
  String winStarsTarget(int moves) {
    final intl.NumberFormat movesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String movesString = movesNumberFormat.format(moves);

    return '3 estrellas con $movesString movimientos o menos';
  }

  @override
  String get winStarsNewBest => '¡Nueva mejor marca!';

  @override
  String get starsFirstTip =>
      'Con menos movimientos ganas más estrellas. Repite cualquier nivel desde Capítulos.';

  @override
  String get starsHelperNote =>
      'Ganar con una pista o un espacio extra da hasta 2 estrellas.';

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
  String get chaptersAllThreeStars => 'Todos los niveles con 3 estrellas';

  @override
  String chaptersStarsSemantics(int earned, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      earned,
      locale: localeName,
      other: '$earned de $total estrellas',
      one: '1 de $total estrellas',
    );
    return '$_temp0';
  }

  @override
  String get recordsStars => 'Estrellas';

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
  String get dailyShare => 'Compartir';

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
  String get dailyShareSemantics => 'Compartir el resultado de hoy';

  @override
  String dailyShareText(String date, String glyphs, int moves, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'Resuelto en $moves movimientos · Día $day 🔥',
      one: 'Resuelto en 1 movimiento · Día $day 🔥',
    );
    return 'Nesty Desafío diario · $date\n$glyphs\n$_temp0';
  }

  @override
  String dailyShareTextNoStreak(String date, String glyphs, int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: 'Resuelto en $moves movimientos',
      one: 'Resuelto en 1 movimiento',
    );
    return 'Nesty Desafío diario · $date\n$glyphs\n$_temp0';
  }

  @override
  String get reminderOfferTitle =>
      '¿Quieres un aviso cuando esté listo el desafío de mañana?';

  @override
  String get reminderOfferBody =>
      'Un aviso tranquilo al día, a la hora que elijas. Puedes desactivarlo en Ajustes.';

  @override
  String reminderOfferTime(String time) {
    return 'Todos los días a las $time';
  }

  @override
  String get reminderOfferChangeTime => 'Cambiar hora';

  @override
  String reminderTimeChipSemantics(String time) {
    return 'Hora del recordatorio, todos los días a las $time. Cambiar hora.';
  }

  @override
  String get reminderPickerTitle => 'Hora del recordatorio';

  @override
  String get reminderOfferYes => 'Sí, avísame';

  @override
  String get reminderOfferNo => 'No, gracias';

  @override
  String reminderOfferDone(String time) {
    return 'Recordatorio programado para las $time.';
  }

  @override
  String get reminderOfferDeniedTitle =>
      'Las notificaciones de Nesty están desactivadas';

  @override
  String reminderOfferDenied(String time) {
    return 'Actívalas en los ajustes del teléfono y tu aviso llegará a las $time.';
  }

  @override
  String get reminderNotificationTitle => 'Nesty';

  @override
  String get reminderNotificationBody =>
      'El desafío de hoy ya está en el estante.';

  @override
  String get reminderNotificationBody2 =>
      'Hay un desafío diario nuevo, para cuando quieras.';

  @override
  String get reminderNotificationBody3 =>
      'Hay muñecas nuevas esperando a que las encajes. El desafío de hoy está listo.';

  @override
  String get reminderChannelName => 'Desafío diario';

  @override
  String get reminderChannelDescription =>
      'Un aviso al día cuando hay un desafío diario nuevo.';

  @override
  String get settingReminder => 'Recordatorio diario';

  @override
  String get settingReminderTime => 'Hora';

  @override
  String get settingReminderBlocked =>
      'Desactivado en los ajustes del teléfono';

  @override
  String get settingOpenPhoneSettings => 'Abrir ajustes del teléfono';

  @override
  String get settingReminderTurnOff => 'Desactivar';

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

    return 'Capítulo $chapterString, $name. $countString de $totalString estrellas. Abre Capítulos.';
  }

  @override
  String homeBonusCardSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Niveles bonus. $countString de $totalString estrellas. Abre Capítulos.';
  }

  @override
  String get homeVsComputerSemantics =>
      'vs. Computadora. Compite con una computadora en el mismo desafío.';

  @override
  String homeVsComputerLockedSemantics(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'vs. Computadora, bloqueado. Tras el nivel $levelString.';
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

    return 'CAPÍTULO $numberString · NIVELES $firstString–$lastString';
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

    return 'Capítulo $chapterString, $name. $countString de $totalString estrellas.';
  }

  @override
  String chaptersRowLockedSemantics(int chapter, String name) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return 'Capítulo $chapterString, $name. Bloqueado.';
  }

  @override
  String get chaptersLevelChestSemantics => 'Un cofre en este nivel';

  @override
  String get chaptersLevelFinaleSemantics => 'El último nivel del capítulo';

  @override
  String museumNicheCollectedSemantics(String name) {
    return '$name, en casa, en tu Museo';
  }

  @override
  String museumNicheNextSemantics(String name, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, la próxima en llegar a casa. $countString niveles más.',
      one: '$name, la próxima en llegar a casa. $countString nivel más.',
    );
    return '$_temp0';
  }

  @override
  String museumNicheLockedSemantics(String name, int chapter) {
    final intl.NumberFormat chapterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String chapterString = chapterNumberFormat.format(chapter);

    return '$name, aún no está en casa. Capítulo $chapterString.';
  }

  @override
  String museumCountSemantics(int count, int total) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$countString de $totalString familias en casa';
  }

  @override
  String museumFullSub(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Casa llena · las $countString familias';
  }

  @override
  String recordsRaceSemantics(String rival, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$rival, computadora. $countString victorias.',
      one: '$rival, computadora. $countString victoria.',
    );
    return '$_temp0';
  }

  @override
  String recordsRaceLockedSemantics(String rival) {
    return '$rival, computadora. Sin desbloquear.';
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
  String get giftTitle => 'Regalo diario';

  @override
  String giftDay(int day) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return 'Día $dayString';
  }

  @override
  String get giftClaim => 'Recoger';

  @override
  String get giftClaimedLine => 'El regalo de hoy ya es tuyo.';

  @override
  String giftTomorrow(String gift) {
    return 'Mañana: $gift';
  }

  @override
  String giftNext(String gift) {
    return 'Próximo regalo: $gift';
  }

  @override
  String get giftButtonReadySemantics => 'Regalo diario. Hay un regalo listo.';

  @override
  String get giftButtonSemantics => 'Regalo diario';

  @override
  String giftTileSemantics(int day, String gift, String state) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return 'Día $dayString, $gift. $state';
  }

  @override
  String get giftTileDone => 'Recogido';

  @override
  String get giftTileToday => 'Regalo de hoy';

  @override
  String get giftTileLater => 'Más adelante';

  @override
  String get giftChestTitle => 'Regalo del día 7';

  @override
  String get giftChestBody => 'Un cofre para el día 7. Mira lo que hay dentro.';

  @override
  String giftCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString monedas',
      one: '1 moneda',
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
      other: '$countString pistas',
      one: '1 pista',
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
      other: '$countString espacios extra',
      one: '1 espacio extra',
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
      other: '+$countString espacios',
      one: '+1 espacio',
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
      other: '$coinsString monedas',
      one: '1 moneda',
    );
    String _temp1 = intl.Intl.pluralLogic(
      slots,
      locale: localeName,
      other: '$slotsString espacios extra',
      one: '1 espacio extra',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get giftSubtitle => 'Un regalo al día, a tu ritmo.';

  @override
  String get giftTitleShort => 'Regalos';

  @override
  String get giftChestTitleShort => 'Día 7';

  @override
  String giftSlotsShort(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString espacios',
      one: '1 espacio',
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
    return 'Regalo recogido: $gift.';
  }

  @override
  String giftA11yAdded(String gift, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Agregado: $gift. Tienes $countString.';
  }
}
