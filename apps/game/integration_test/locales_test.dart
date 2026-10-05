import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/chapters/pages/chapters_page.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/fx/fx_spinner.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';
import 'package:nesty_game/features/gameplay/widgets/chapter_ribbon.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/museum/pages/museum_page.dart';
import 'package:nesty_game/features/race/pages/rival_select_page.dart';
import 'package:nesty_game/features/records/pages/records_page.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';
import 'package:nesty_game/l10n/app_localizations.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/seeded_save.dart';
import 'support/solve_with_hints.dart';

/// The translations on a device, one run per script family (spec §16;
/// build/m7-p5/p5/l10n.md §7.2; PROGRESS D169): German (Latin, the
/// longest), Hindi (Devanagari, Baloo 2) and Japanese (kana and kanji,
/// M PLUS Rounded 1c), chosen by `--dart-define=NESTY_TEST_LOCALE=<code>`.
///
/// - **de goes through the real picker:** a seeded English player opens
///   Settings → Language and taps "Deutsch"; the app re-renders in German
///   with no restart, and `DatabaseService.languageCode` is `de`.
/// - **hi and ja are seeded** (`SeededSettings.locale`), so the app opens
///   in them.
///
/// Each run then walks a returning player past Level 60 (the daily and vs
/// Computer unlocked, its own seed so `meta_screens_test` is untouched):
/// Home, Settings and the language sheet, Chapters, Records, the Museum,
/// the Shop's Skins, the Daily, rival select (every card's Computer tag in
/// the locale), level 61 (chapter 4's first: its ribbon, the HUD and the
/// booster bar) and Pause, a win on a hinted replay of level 1 (the win
/// card), and a race started, then Pause → Leave race's confirm. Every
/// assertion reads the locale's own catalog (`lookupAppLocalizations`),
/// never English text, and every screen is shot as `l10n-<code>-NN_<screen>`
/// for the visual review (5B-6 V: cut text, colliding matras, system-font
/// glyphs, tracking).
///
/// Until 5B-5 a locale whose ARB isn't in yet is skipped. Written in 5B-1
/// (I-tests), run by 5B-6; the integrator wires `--only locales` into
/// `tools/scripts/nesty-test` and its `docs/TEST_COVERAGE.md` row:
///
/// ```sh
/// cd apps/game
/// NESTY_SCREENSHOT_DIR=/some/dir flutter drive --flavor dev \
///   --driver test_driver/integration_test.dart \
///   --target integration_test/locales_test.dart \
///   --dart-define=NESTY_TEST_LOCALE=de -d <device>
/// ```
///
/// Start from a fresh install (uninstall first): `seedSave` writes the
/// save and the language the app then loads.
const _code = String.fromEnvironment('NESTY_TEST_LOCALE', defaultValue: 'de');

/// The run that switches language through the sheet rather than the seed.
const _pickerCode = 'de';

final Locale _locale = () {
  final parts = _code.split('_');
  return Locale(parts.first, parts.length > 1 ? parts[1] : null);
}();

/// The language sheet's autonym for [_code] (its row's own words).
String get _autonym =>
    launchLanguages.firstWhere((language) => language.code == _code).autonym;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  final hasCatalog = AppLocalizations.delegate.isSupported(_locale);

  testWidgets(
    'the game in $_code: Home, Settings and the language sheet, the meta '
    'screens, a level, the win card and a race',
    (tester) async {
      final viaPicker = _code == _pickerCode;
      await seedSave(
        _returningPlayer(),
        settings: SeededSettings(locale: viaPicker ? 'en' : _code),
      );
      app.main();
      final shots = _Shots(binding, tester);
      final board = Board(tester);
      final l10n = lookupAppLocalizations(_locale);
      final english = lookupAppLocalizations(const Locale('en'));

      await tester.pumpUntil(
        () =>
            find.byType(SplashPage).evaluate().isEmpty &&
            find.byType(HomePage).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 90),
        reason: 'Home after the splash',
      );
      await tester.pumpFor(const Duration(milliseconds: 1200));

      if (viaPicker) {
        await _pickThroughSheet(tester, shots, english, l10n);
      }

      await _home(tester, shots, l10n, english);
      await _settings(tester, shots, l10n);
      await _metaScreens(tester, shots, l10n);
      await _level(tester, board, shots, l10n);
      await _win(tester, board, shots, l10n);
      await _race(tester, board, shots, l10n);
    },
    skip: !hasCatalog,
    timeout: const Timeout(Duration(minutes: 14)),
  );
}

/// The screenshots of this file, taken as `playthrough_test.dart` takes its,
/// each named `l10n-<code>-NN_<screen>`.
final class _Shots {
  _Shots(this._binding, this._tester);

  final IntegrationTestWidgetsFlutterBinding _binding;
  final WidgetTester _tester;
  bool _converted = false;

  Future<void> take(String name) async {
    if (Platform.isAndroid && !_converted) {
      await _binding.convertFlutterSurfaceToImage();
      _converted = true;
    }
    await _tester.pump();
    final bytes = await _binding.takeScreenshot('l10n-$_code-$name');
    expect(bytes, isNotEmpty, reason: name);
  }
}

/// [route] pushed, with [page] on screen and settled.
Future<void> _open(
  WidgetTester tester,
  PageRouteInfo<Object?> route,
  Type page, {
  Duration settle = const Duration(milliseconds: 900),
}) async {
  unawaited(get<AppRouter>().push(route));
  await tester.pumpUntil(
    () => find.byType(page).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 30),
    reason: '$page',
  );
  await tester.pumpFor(settle);
}

/// Back to Home's tab from wherever a step ended.
Future<void> _backHome(WidgetTester tester) async {
  unawaited(
    get<AppRouter>().replaceAll([
      const MainShellRoute(children: [HomeRoute()]),
    ]),
  );
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(SettingsPage).evaluate().isEmpty &&
        find.byType(HomePage).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 30),
    reason: 'Home',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
}

/// Opens the language sheet from Settings' Language row.
Future<void> _openSheet(WidgetTester tester, AppLocalizations l10n) async {
  final row = find.text(l10n.settingLanguage);
  await tester.scrollUntilVisible(
    row,
    200,
    scrollable: find
        .descendant(
          of: find.byType(SettingsPage),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  await tester.tap(row);
  await tester.pumpUntil(
    () => find.byType(LanguageSheet).evaluate().isNotEmpty,
    reason: 'the language sheet',
  );
  await tester.pumpFor(const Duration(milliseconds: 700));
}

/// Closes the sheet with its Done (frame 8.2: the orange action on the
/// title's row).
Future<void> _closeSheet(WidgetTester tester, AppLocalizations l10n) async {
  await tester.tap(
    find.descendant(
      of: find.byType(LanguageSheet),
      matching: find.text(l10n.languageSheetDone),
    ),
  );
  await tester.pumpUntil(
    () => find.byType(LanguageSheet).evaluate().isEmpty,
    reason: 'the language sheet closed',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
}

// ── 00: German through the picker (frames 8.2, 8.2b) ─────────────────────

/// Settings → Language → the locale's row: the app re-renders in it at
/// once, with no restart, and stores it. m7-4 (`layout.languageSheet`)
/// keeps the sheet open, redrawn in the new language, until Done.
Future<void> _pickThroughSheet(
  WidgetTester tester,
  _Shots shots,
  AppLocalizations english,
  AppLocalizations l10n,
) async {
  await _open(tester, const SettingsRoute(), SettingsPage);
  await _openSheet(tester, english);
  await shots.take('00a_sheet_before');
  await tester.tap(
    find.descendant(
      of: find.byType(LanguageSheet),
      matching: find.text(_autonym),
    ),
  );
  await tester.pumpUntil(
    () =>
        get<DatabaseService>().languageCode == _code &&
        find.text(l10n.settingLanguage).evaluate().isNotEmpty,
    reason: 'Settings re-rendered in $_code and the choice stored',
  );
  await tester.pumpFor(const Duration(milliseconds: 700));
  expect(get<DatabaseService>().languageCode, _code);
  if (find.byType(LanguageSheet).evaluate().isEmpty) {
    await _openSheet(tester, l10n);
  }
  expect(
    find.descendant(
      of: find.byType(LanguageSheet),
      matching: find.text(l10n.languageSheetTitle),
    ),
    findsOneWidget,
  );
  await shots.take('00b_sheet_after');
  await _closeSheet(tester, l10n);
  await _backHome(tester);
}

// ── 01: Home ─────────────────────────────────────────────────────────────

Future<void> _home(
  WidgetTester tester,
  _Shots shots,
  AppLocalizations l10n,
  AppLocalizations english,
) async {
  // vs Computer is unlocked past Level 20: the locale's word for Computer
  // (spec-prop §1.1 rule 5), in the tile's label ("vs Computer") and in its
  // tag unless the tag fell to its glyph (D271).
  expect(find.textContaining(l10n.raceComputerTag), findsWidgets);
  expect(find.text(l10n.homeRecordsButton), findsOneWidget);
  // The language took: Home's English labels are gone (where the locale's
  // word differs).
  for (final (local, en) in [
    (l10n.homeRecordsButton, english.homeRecordsButton),
    (l10n.raceComputerTag, english.raceComputerTag),
  ]) {
    if (local != en) expect(find.text(en), findsNothing, reason: en);
  }
  await shots.take('01_home');
}

// ── 02: Settings and the language sheet ──────────────────────────────────

Future<void> _settings(
  WidgetTester tester,
  _Shots shots,
  AppLocalizations l10n,
) async {
  await _open(tester, const SettingsRoute(), SettingsPage);
  expect(find.text(l10n.settingLanguage), findsOneWidget);
  await shots.take('02a_settings');
  await _openSheet(tester, l10n);
  expect(
    find.descendant(
      of: find.byType(LanguageSheet),
      matching: find.text(l10n.languageSheetTitle),
    ),
    findsOneWidget,
  );
  // Every autonym reads the same in every locale, in its own script.
  for (final language in launchLanguages) {
    expect(
      find.descendant(
        of: find.byType(LanguageSheet),
        matching: find.text(language.autonym),
      ),
      findsOneWidget,
      reason: language.autonym,
    );
  }
  await shots.take('02b_language_sheet');
  await _closeSheet(tester, l10n);
  await _backHome(tester);
}

// ── 03–08: Chapters, Records, the Museum, Shop Skins, the Daily, rivals ──

Future<void> _metaScreens(
  WidgetTester tester,
  _Shots shots,
  AppLocalizations l10n,
) async {
  await _open(tester, const ChaptersRoute(), ChaptersPage);
  expect(find.text(l10n.chaptersTitle), findsOneWidget);
  await shots.take('03_chapters');
  await _backHome(tester);

  await _open(tester, const RecordsRoute(), RecordsPage);
  expect(find.text(l10n.recordsTitle), findsOneWidget);
  await shots.take('04_records');
  await _backHome(tester);

  unawaited(
    get<AppRouter>().navigate(const MainShellRoute(children: [MuseumRoute()])),
  );
  await tester.pumpUntil(
    () => find.byType(MuseumPage).evaluate().isNotEmpty,
    reason: 'the Museum tab',
  );
  await tester.pumpFor(const Duration(milliseconds: 900));
  await shots.take('05_museum');

  unawaited(
    get<AppRouter>().navigate(
      MainShellRoute(children: [ShopRoute(initialTab: ShopTab.skins)]),
    ),
  );
  await tester.pumpUntil(
    () => find.byType(ShopPage).evaluate().isNotEmpty,
    reason: 'the Shop tab',
  );
  await tester.pumpFor(const Duration(milliseconds: 1200));
  // The skins' thumbnails load after the tab opens: up to 10 s more so the
  // shot shows them (it is for the text, so a slow one never fails it; the
  // 2026-10-05 Android gate shot three spinners).
  final thumbnails = DateTime.now().add(const Duration(seconds: 10));
  while (find.byType(FxSpinner).evaluate().isNotEmpty &&
      DateTime.now().isBefore(thumbnails)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await shots.take('06_shop_skins');
  await _backHome(tester);

  await _open(tester, const DailyRoute(), DailyPage);
  await shots.take('07_daily');
  await _backHome(tester);

  await _open(tester, const RivalSelectRoute(), RivalSelectView);
  expect(find.text(l10n.raceComputerTag), findsWidgets);
  expect(find.text(l10n.raceStart), findsOneWidget);
  await shots.take('08_rival_select');
  await _backHome(tester);
}

// ── 09–11: level 61, its ribbon, the HUD, the booster bar and Pause ──────

Future<void> _level(
  WidgetTester tester,
  Board board,
  _Shots shots,
  AppLocalizations l10n,
) async {
  unawaited(
    get<AppRouter>().push(
      GameplayRoute(request: const PlayRequest.campaign(61)),
    ),
  );
  // Chapter 4's first level opens with its ribbon (frame 4.7, 2.6 s).
  await board.waitForLevel(61, settle: const Duration(milliseconds: 300));
  expect(find.byType(ChapterRibbon), findsOneWidget);
  await shots.take('09_chapter_ribbon');
  await tester.pumpFor(const Duration(milliseconds: 2600));
  // The bar's labels may be their short forms (tokens.json `textFit`), so
  // the buttons are found by kind.
  expect(find.byType(BoosterBar), findsOneWidget);
  expect(hintButton, findsOneWidget);
  await shots.take('10_level_hud_boosters');

  await tester.tap(find.bySemanticsLabel(l10n.pause));
  await tester.pumpUntil(
    () => find.byType(PauseDialog).evaluate().isNotEmpty,
    reason: 'the pause dialog',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(find.text(l10n.resume), findsOneWidget);
  await shots.take('11_pause');
  await _backHome(tester);
}

// ── 12: the win card, on a hinted replay of level 1 ──────────────────────

Future<void> _win(
  WidgetTester tester,
  Board board,
  _Shots shots,
  AppLocalizations l10n,
) async {
  unawaited(
    get<AppRouter>().push(GameplayRoute(request: const PlayRequest.replay(1))),
  );
  await board.waitForLevel(1);
  await solveWithHints(tester, board);
  await board.waitForWinOverlay();
  // The stars, the helper note and the buttons are in by about 3.3 s.
  await tester.pumpFor(const Duration(milliseconds: 4000));
  expect(find.text(l10n.winBackToChapters), findsOneWidget);
  await shots.take('12_win_card');
  await _backHome(tester);
}

// ── 13–14: a race, then Pause → Leave race's confirm (9.3, 9.7b) ─────────

Future<void> _race(
  WidgetTester tester,
  Board board,
  _Shots shots,
  AppLocalizations l10n,
) async {
  await _open(tester, const RivalSelectRoute(), RivalSelectView);
  await tester.tap(find.text(l10n.raceStart));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.bloc.state.data?.isRace == true &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: 'the race board with its skin',
  );
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 800));
  // The race's own Start (9.3) opens the input gate.
  await tester.tap(find.text(l10n.raceStart));
  await tester.pumpUntil(() => board.state.raceLive, reason: 'the race on');
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('13_race');

  await tester.tap(find.bySemanticsLabel(l10n.pause));
  await tester.pumpUntil(
    () => find.byType(PauseDialog).evaluate().isNotEmpty,
    reason: 'the race pause dialog',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  await tester.tap(find.text(l10n.raceQuit));
  await tester.pumpFor(const Duration(milliseconds: 600));
  final confirm = find.byKey(const ValueKey('raceLeaveConfirm'));
  expect(confirm, findsOneWidget);
  expect(find.text(l10n.raceLeaveBody), findsOneWidget);
  expect(
    find.descendant(of: confirm, matching: find.text(l10n.raceLeaveKeep)),
    findsOneWidget,
  );
  await shots.take('14_leave_race_confirm');
  await tester.tap(
    find.descendant(of: confirm, matching: find.text(l10n.raceQuit)),
  );
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(RivalSelectView).evaluate().isNotEmpty,
    reason: 'Leave race back to rival select',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
}

/// A returning player past Level 60 (the meta screens' kind, its own copy):
/// levels 1–60 won with mixed stars, chapters 1–3's families home, rival 1
/// beaten once and rival 2 open, every intro seen, so level 61 (chapter
/// 4's first) opens on its board with its ribbon. The daily and vs
/// Computer are unlocked.
SaveDocument _returningPlayer() => SaveDocument(
  currentLevel: 61,
  highestLevel: 61,
  coins: 1240,
  tutorialDone: true,
  seenIntros: const ['towers', 'glass', 'ice'],
  museum: const ['ch01', 'ch02', 'ch03'],
  levelStars: {
    for (var order = 1; order <= 60; order++)
      'L${order.toString().padLeft(4, '0')}': const [3, 2, 3, 1][order % 4],
  },
  levelBests: {
    for (var order = 1; order <= 60; order++)
      'L${order.toString().padLeft(4, '0')}@1': 8 + order % 9,
  },
  stats: const SaveStats(wins: 60),
  records: const SaveRecords(
    families: 3,
    dolls: 120,
    dailies: 4,
    longestRun: 4,
    badges: ['first_family'],
  ),
  race: const RaceProgress(
    rivals: [
      RivalProgress(unlocked: true, wins: 1, raceNo: 1),
      RivalProgress(unlocked: true),
      RivalProgress(),
    ],
  ),
);
