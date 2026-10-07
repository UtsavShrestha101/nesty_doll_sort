import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/chapters/pages/chapters_page.dart';
import 'package:nesty_game/features/chapters/widgets/chapter_level_cell.dart';
import 'package:nesty_game/features/chapters/widgets/level_card.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_spinner.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/museum/pages/museum_page.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';
import 'package:nesty_game/features/museum/widgets/figurine_modal.dart';
import 'package:nesty_game/features/museum/widgets/museum_idle_figurine.dart';
import 'package:nesty_game/features/records/pages/records_page.dart';
import 'package:nesty_game/features/records/widgets/doll_mark.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/shop/pages/skin_detail_page.dart';
import 'package:nesty_game/features/shop/widgets/shop_buy_button.dart';
import 'package:nesty_game/features/shop/widgets/skin_grid_card.dart';
import 'package:nesty_game/features/shop/widgets/theme_grid_card.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/phone_language.dart';
import 'support/seeded_save.dart';

/// The meta screens on a device (phase 4 lane M; architecture §7.3, D169):
/// a seeded returning player (60 levels won, three families home, 3,400
/// coins, a bought theme) walks Home (2.1), Chapters (10.4) into the level
/// card (10.4b) and Play, the Museum (6.1), Records (10.6), the Shop's Skins
/// (7.3, Forest Bear) and Themes (7.7, the crops), buys Forest Bear, uses the
/// owned ch07 theme and sees it behind Home and a level.
///
/// Phase 5 (architecture.md §1.3) adds, in the default `returning` scenario,
/// the figurine modal (F-MUS), Records' end (F-SAFE), Forest Bear's detail
/// (7.4b) and Ocean in play (7.6); and two more seeds, chosen by
/// `--dart-define=NESTY_META_SCENARIO=<name>`: `finale` (12.1, Home with
/// level 60's Super Hard PLAY) and `complete` (12.2, Home past level 200
/// with Bonus Level 7; 6.1c, the Museum with all ten families home).
///
/// After Claude Design's m7-4, `returning` also checks Chapters' opening
/// scroll (at most two finished rows above the current card, 8.4), the
/// Museum's idling figurines (`ui_museum_idle`, 10.3) under the detail's
/// spotlight, Records' "Families completed" with its doll mark (8.5), and a
/// purchase with no card: the price chip turned into its new footer with a
/// pop and three sparkles (4.11).
///
/// ```sh
/// cd apps/game
/// NESTY_SCREENSHOT_DIR=/some/dir flutter drive --flavor dev \
///   --driver test_driver/integration_test.dart \
///   --target integration_test/meta_screens_test.dart -d <device>
/// ```
///
/// Start from a fresh install (uninstall first): `seedSave` writes the save
/// the app then loads. The integrator wires it into `tools/scripts/nesty-test`
/// and `docs/TEST_COVERAGE.md`; screenshots are prefixed `meta-`.
///
/// Not run by lane M (one simulator, a shared `apps/game/build`): the device
/// stage runs it on both platforms and fixes what fails.
const _scenario = String.fromEnvironment(
  'NESTY_META_SCENARIO',
  defaultValue: 'returning',
);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Home, Chapters and its level card, the Museum, Records, the Shop and '
    'a used theme, on a seeded save: $_scenario',
    (tester) async {
      pinEnglishPhone(tester);
      await seedSave(switch (_scenario) {
        'finale' => _finalePlayer(),
        'complete' => _completePlayer(),
        _ => _returningPlayer(),
      });

      app.main();
      final shots = _Shots(binding, tester);
      final board = Board(tester);

      // Splash, then Home (a returning player: never level 1).
      await tester.pumpUntil(
        () =>
            find.byType(SplashPage).evaluate().isEmpty &&
            find.byType(HomePage).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 60),
        reason: 'Home after the splash on a seeded save',
      );
      await tester.pumpFor(const Duration(milliseconds: 1200));

      switch (_scenario) {
        case 'finale':
          // Frame 12.1: a chapter's finale next, PLAY with the Super Hard
          // badge.
          expect(
            find.bySemanticsLabel(RegExp(r'^Play level 60')),
            findsOneWidget,
          );
          await shots.take('meta-12a-home-super-hard');
          return;
        case 'complete':
          // Frame 12.2: every level won, PLAY offers the next bonus level
          // and the Daily tile rests (streak 0).
          expect(find.text('Bonus Level 7'), findsOneWidget);
          await shots.take('meta-12b-home-bonus');
          // Frame 6.1c: all ten families home.
          await tester.tap(_nav('Museum'));
          await tester.pumpUntil(
            () => find.byType(MuseumPage).evaluate().isNotEmpty,
            reason: 'the Museum tab',
          );
          await tester.pumpFor(const Duration(milliseconds: 900));
          expect(find.text('10 / 10'), findsOneWidget);
          // Ten figurines decode at once: wait for every raster (the
          // Android 390 shot caught only the first, phase 5's audit f6-1c)
          // instead of a fixed sleep.
          // An earned niche swaps its still FigurineImage for the idle clip
          // once the raster decodes, so the Images vanish: wait until no still
          // is left under a MuseumIdleFigurine.
          await tester.pumpUntil(
            () =>
                find.byType(MuseumIdleFigurine).evaluate().length == 10 &&
                find
                    .descendant(
                      of: find.byType(MuseumIdleFigurine),
                      matching: find.byType(FigurineImage),
                    )
                    .evaluate()
                    .isEmpty,
            timeout: const Duration(seconds: 30),
            reason: 'every figurine raster decoded',
          );
          await tester.pumpFor(const Duration(milliseconds: 600));
          expect(find.byType(MuseumIdleFigurine), findsNWidgets(10));
          await shots.take('meta-05c-museum-all-home');
          return;
      }

      // --- Home (2.1): the chapter card with its stars, Records, the tiles.
      expect(find.text('CHAPTER 4'), findsOneWidget);
      expect(find.text('Snowy Cabin'), findsWidgets);
      expect(find.text('Records'), findsOneWidget);
      expect(find.text('Daily Puzzle'), findsOneWidget);
      expect(find.text('vs Computer'), findsOneWidget);
      expect(find.text('Remove Ads'), findsOneWidget);
      // vs Computer is unlocked past Level 20: no lock line, the Computer tag.
      expect(find.text('After Level 20'), findsNothing);
      expect(find.text('Computer'), findsOneWidget);
      await shots.take('meta-01-home');

      // --- Chapters (10.4): the chapter card opens it, the current chapter
      // is open and the finished ones are rows.
      await tester.tap(find.text('Snowy Cabin').first);
      await tester.pumpUntil(
        () => find.byType(ChaptersPage).evaluate().isNotEmpty,
        reason: 'Chapters from the chapter card',
      );
      await tester.pumpFor(const Duration(milliseconds: 900));
      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('Level 61 of 200'), findsOneWidget);
      expect(find.text('60 won'), findsOneWidget);
      expect(find.text('CHAPTER 4 · LEVELS 61\u2060–\u206080'), findsOneWidget);
      // m7-5 item 21 (`layout.chapters.scroll.foldedAbove: 3`): up to three
      // finished rows above the current card, fewer on a short phone. On a
      // 844 dp phone chapter 1's row shows above chapter 4's card.
      final view = tester.view;
      if (view.physicalSize.height / view.devicePixelRatio >= 844) {
        expect(find.text('Sunny Toy Shop').hitTestable(), findsOneWidget);
      }
      await shots.take('meta-02-chapters');

      // A finished row opens in place (one open at a time): chapter 1's
      // cell 2 is won, so it opens the level card (10.4b) with its Play.
      // Chapters opens scrolled to the current chapter, so on a short phone
      // chapter 1's row may be above the viewport (built, but offstage to
      // `find`): scroll up to it first (the device run found it, 2026-09-30).
      final chapters = find
          .descendant(
            of: find.byType(ChaptersPage),
            matching: find.byType(Scrollable),
          )
          .first;
      final chapterOne = find.text('Sunny Toy Shop');
      await tester.scrollUntilVisible(chapterOne, -250, scrollable: chapters);
      await tester.pumpFor(const Duration(milliseconds: 400));
      await tester.tap(chapterOne);
      await tester.pumpFor(const Duration(milliseconds: 900));
      final cellTwo = find.descendant(
        of: find.byType(ChapterLevelCell),
        matching: find.text('2'),
      );
      await tester.scrollUntilVisible(cellTwo, 250, scrollable: chapters);
      await tester.pumpFor(const Duration(milliseconds: 400));
      await tester.tap(cellTwo.first);
      await tester.pumpUntil(
        () => find.byType(LevelCard).evaluate().isNotEmpty,
        reason: 'the level card',
      );
      await tester.pumpFor(const Duration(milliseconds: 500));
      expect(find.text('Level 2'), findsOneWidget);
      await shots.take('meta-03-level-card');
      await tester.tap(find.text('Play'));
      await board.waitForLevel(2);
      await shots.take('meta-04-replay');

      // --- Museum (6.1): three families home, the next one leads.
      unawaited(
        get<AppRouter>().replaceAll([
          const MainShellRoute(children: [HomeRoute()]),
        ]),
      );
      await tester.pumpUntil(
        () =>
            find.byType(GameplayView).evaluate().isEmpty &&
            find.byType(HomePage).evaluate().isNotEmpty,
        reason: 'Home after the replay',
      );
      await tester.pumpFor(const Duration(milliseconds: 600));
      await tester.tap(_nav('Museum'));
      await tester.pumpUntil(
        () => find.byType(MuseumPage).evaluate().isNotEmpty,
        reason: 'the Museum tab',
      );
      await tester.pumpFor(const Duration(milliseconds: 900));
      expect(find.text('3 / 10'), findsOneWidget);
      expect(find.text('NEXT FAMILY'), findsOneWidget);
      expect(find.text('The Astronaut Family'), findsWidgets);
      // m7-4 J.2: each figurine home idles in `ui_museum_idle` (a random
      // start frame per niche); a second shot shows them moving.
      expect(find.byType(MuseumIdleFigurine), findsNWidgets(3));
      await shots.take('meta-05-museum');
      await tester.pumpFor(const Duration(milliseconds: 700));
      await shots.take('meta-05a-museum-idle');
      // F-MUS (lane M): the figurine modal on the root navigator, its scrim
      // over the whole screen (the status band and the bottom nav too) and
      // the spotlight cone (m7-4 10.3, `layout.museumDetail.spotlight`).
      await tester.tap(
        find.bySemanticsLabel('The Classic Family, home in your Museum'),
      );
      await tester.pumpUntil(
        () => find.byType(FigurineModal).evaluate().isNotEmpty,
        reason: 'the figurine modal',
      );
      await tester.pumpFor(const Duration(milliseconds: 600));
      // The Collected chip with its date, centred (frame 6.2).
      expect(find.text('Collected · Sep 12'), findsOneWidget);
      await shots.take('meta-05b-museum-modal');
      await tester.tap(
        find.descendant(
          of: find.byType(FigurineModal),
          matching: find.bySemanticsLabel('Close'),
        ),
      );
      await tester.pumpUntil(
        () => find.byType(FigurineModal).evaluate().isEmpty,
        reason: 'the figurine modal closed',
      );
      await tester.pumpFor(const Duration(milliseconds: 400));

      // --- Records (10.6): from Home's Records button.
      await tester.tap(_nav('Home'));
      await tester.pumpUntil(
        () => find.byType(HomePage).evaluate().isNotEmpty,
        reason: 'Home tab',
      );
      await tester.pumpFor(const Duration(milliseconds: 400));
      await tester.tap(find.text('Records'));
      await tester.pumpUntil(
        () => find.byType(RecordsPage).evaluate().isNotEmpty,
        reason: 'Records',
      );
      await tester.pumpFor(const Duration(milliseconds: 700));
      expect(find.text('Races won'), findsOneWidget);
      expect(find.text('Computer'), findsNWidgets(3));
      // m7-4 8.5 (Q159): "Families completed" with the counter's doll mark.
      expect(find.text('Families completed'), findsOneWidget);
      expect(find.byType(DollMark), findsWidgets);
      await shots.take('meta-06-records');
      // F-SAFE (lane M): scrolled to the end, the badge grid clears the
      // home indicator and the cream gradient runs to the bottom edge.
      final records = tester
          .stateList<ScrollableState>(
            find.descendant(
              of: find.byType(RecordsPage),
              matching: find.byType(Scrollable),
            ),
          )
          .map((state) => state.position)
          .firstWhere((position) => position.axis == Axis.vertical);
      records.jumpTo(records.maxScrollExtent);
      await tester.pumpFor(const Duration(milliseconds: 500));
      await shots.take('meta-06b-records-bottom');
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpUntil(
        () => find.byType(HomePage).evaluate().isNotEmpty,
        reason: 'Home after Records',
      );
      // Past the back transition: the shell slides in from the left, and a
      // tab tapped under way misses (the device run found "Shop" at x -33).
      await tester.pumpFor(const Duration(milliseconds: 800));

      // --- Shop: Skins with Forest Bear (7.3), then buys it (7.4b's price).
      await tester.tap(_nav('Shop'));
      await tester.pumpUntil(
        () => find.byType(ShopPage).evaluate().isNotEmpty,
        reason: 'the Shop tab',
      );
      await tester.pumpFor(const Duration(milliseconds: 700));
      await tester.tap(find.text('Skins'));
      await tester.pumpFor(const Duration(milliseconds: 900));
      final bear = find.ancestor(
        of: find.text('Forest Bear'),
        matching: find.byType(SkinGridCard),
      );
      await tester.scrollUntilVisible(
        bear,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpFor(const Duration(milliseconds: 500));
      expect(find.text('2,500'), findsOneWidget);
      await shots.take('meta-07-shop-skins');

      final save = get<SaveService>();
      expect(save.coins, 3400);
      // Frame 7.4b: Forest Bear's detail, affordable (architecture.md §1.3).
      await tester.tap(
        find.descendant(of: bear, matching: find.text('Forest Bear')),
      );
      await tester.pumpUntil(
        () => find.byType(SkinDetailPage).evaluate().isNotEmpty,
        reason: "Forest Bear's detail",
      );
      await tester.pumpUntil(
        () => find.byType(FxSpinner).evaluate().isEmpty,
        timeout: const Duration(seconds: 30),
        reason: "Forest Bear's detail art",
      );
      await tester.pumpFor(const Duration(milliseconds: 600));
      await shots.take('meta-07b-forest-bear-detail');
      await tester.tap(
        find.descendant(
          of: find.byType(SkinDetailPage),
          matching: find.bySemanticsLabel('Back'),
        ),
      );
      await tester.pumpUntil(
        () => find.byType(SkinDetailPage).evaluate().isEmpty,
        reason: 'back to the Shop',
      );
      await tester.pumpFor(const Duration(milliseconds: 500));
      await tester.tap(
        find.descendant(of: bear, matching: find.byType(ShopBuyButton)),
      );
      // m7-4 4.11 (`motion.purchaseItem`): no card; the price chip turns
      // into the card's new footer (buying equips it) with a pop, three
      // `fx_sparkle` round the card, and the header's coins count down.
      await tester.pumpUntil(
        () => save.document.ownedSkins.contains('forest-bear'),
        reason: 'Forest Bear bought',
        step: const Duration(milliseconds: 16),
      );
      // The three sparkles start 0, 90 and 180 ms after the frame that
      // inserts the burst, and the burst lives 900 ms: wait for the first,
      // then for all three inside that window from it (a fixed 250 ms was
      // too tight on the 731 dp emulator, 2026-10-04; a window counted from
      // the save missed a late burst on a busy host, 2026-10-05).
      final sparkles = find.byWidgetPredicate(
        (w) => w is LottieFxView && w.id == FxId.fxSparkle,
      );
      await tester.pumpUntil(
        () => sparkles.evaluate().isNotEmpty,
        reason: 'the purchase burst',
        timeout: const Duration(seconds: 5),
        step: const Duration(milliseconds: 16),
      );
      await tester.pumpUntil(
        () => sparkles.evaluate().length >= 3,
        reason: 'the three purchase sparkles',
        timeout: const Duration(milliseconds: 900),
        step: const Duration(milliseconds: 16),
      );
      expect(find.byType(Dialog), findsNothing, reason: 'no purchase card');
      expect(
        find.descendant(of: bear, matching: find.text('Equipped')),
        findsOneWidget,
      );
      await shots.take('meta-08a-purchase-pop');
      await tester.pumpFor(const Duration(milliseconds: 1000));
      expect(save.coins, 900, reason: '3,400 - 2,500');
      await shots.take('meta-08-bought');

      // Frame 7.6: Ocean bought (buying equips it) and on a board, level
      // 56 (architecture.md §1.3).
      final ocean = find.ancestor(
        of: find.text('Ocean'),
        matching: find.byType(SkinGridCard),
      );
      await tester.scrollUntilVisible(
        ocean,
        -200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpFor(const Duration(milliseconds: 400));
      await tester.tap(
        find.descendant(of: ocean, matching: find.byType(ShopBuyButton)),
      );
      await tester.pumpFor(const Duration(milliseconds: 1000));
      expect(save.document.selectedSkin, 'ocean');
      expect(save.coins, 100, reason: '900 - 800');
      await tester.tap(_nav('Home'));
      await tester.pumpUntil(
        () => find.byType(HomePage).evaluate().isNotEmpty,
        reason: 'Home before the Ocean board',
      );
      await tester.pumpFor(const Duration(milliseconds: 800));
      await board.jumpTo(56, _tierLabel(56));
      await shots.take('meta-08b-skin-in-play');
      await board.openPause();
      await board.pauseToHome(level: 61);
      await tester.tap(_nav('Shop'));
      await tester.pumpUntil(
        () => find.byType(ShopPage).evaluate().isNotEmpty,
        reason: 'back to the Shop',
      );
      await tester.pumpFor(const Duration(milliseconds: 700));

      // --- Themes (7.7): the crops; ch07 was bought in the seed, so it has
      // "Use". Using it turns "Match each chapter" off.
      await tester.tap(find.text('Themes'));
      await tester.pumpFor(const Duration(milliseconds: 1200));
      await shots.take('meta-09-shop-themes');
      final puppet = find.ancestor(
        of: find.text('Puppet Theater'),
        matching: find.byType(ThemeGridCard),
      );
      await tester.scrollUntilVisible(
        puppet,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      // The card's top can be on screen with its Use below the bottom
      // edge (the device run found it at y 946 of 874): centre Use itself.
      final use = find.descendant(of: puppet, matching: find.text('Use'));
      await Scrollable.ensureVisible(tester.element(use), alignment: 0.5);
      await tester.pumpFor(const Duration(milliseconds: 400));
      await tester.tap(use);
      await tester.pumpFor(const Duration(milliseconds: 600));
      expect(save.document.selectedTheme, 'ch07');

      // --- The used theme behind Home and a level.
      await tester.tap(_nav('Home'));
      await tester.pumpUntil(
        () => find.byType(HomePage).evaluate().isNotEmpty,
        reason: 'Home with the used theme',
      );
      await tester.pumpFor(const Duration(milliseconds: 1200));
      await shots.take('meta-10-home-theme');
      // --- Settings' language sheet (frames 8.2/8.2b): a row applies at once
      // and the sheet stays open; Done closes it. English is picked again
      // after, because the steps below find English labels.
      await tester.tap(find.bySemanticsLabel('Settings'));
      await tester.pumpUntil(
        () => find.byType(SettingsPage).evaluate().isNotEmpty,
        reason: 'the Settings page from the Home gear',
      );
      await tester.pumpFor(const Duration(milliseconds: 600));
      // Below the fold on a 731 dp screen (the 2026-10-05 Android gate).
      await tester.ensureVisible(find.text('Language'));
      await tester.pumpFor(const Duration(milliseconds: 300));
      await tester.tap(find.text('Language'));
      await tester.pumpUntil(
        () => find.byType(LanguageSheet).evaluate().isNotEmpty,
        reason: 'the language sheet',
      );
      await tester.pumpFor(const Duration(milliseconds: 600));
      await shots.take('meta-13a-language-sheet');
      await tester.tap(find.text('Español'));
      await tester.pumpFor(const Duration(milliseconds: 600));
      expect(find.byType(LanguageSheet), findsOneWidget, reason: 'stays open');
      expect(find.text('Listo'), findsOneWidget, reason: 'redrawn in Spanish');
      await shots.take('meta-13b-language-sheet-es');
      await tester.tap(find.text('English'));
      await tester.pumpFor(const Duration(milliseconds: 600));
      expect(find.text('Done'), findsOneWidget, reason: 'back in English');
      await tester.tap(find.text('Done'));
      await tester.pumpUntil(
        () => find.byType(LanguageSheet).evaluate().isEmpty,
        reason: 'Done closes the sheet',
      );
      await tester.pumpFor(const Duration(milliseconds: 400));
      await shots.take('meta-13c-settings-english');
      await tester.tap(find.bySemanticsLabel('Close').first);
      await tester.pumpFor(const Duration(milliseconds: 600));

      await tester.tap(find.bySemanticsLabel(RegExp(r'^Play level 61')));
      await board.waitForLevel(61);
      await shots.take('meta-11-theme-in-play');
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

/// A tab of the shell's bottom bar, by its label.
Finder _nav(String label) => find.descendant(
  of: find.byType(NestyBottomNav),
  matching: find.text(label),
);

/// A returning player: levels 1-60 won (chapters 1-3), so the Museum has
/// three families home and Chapters shows three finished rows and chapter 4
/// current; 3,400 coins, enough for Forest Bear (2,500) and Ocean (800);
/// Puppet Theater (ch07) bought; rival 1 beaten once. The stars follow a
/// simple pattern so the grid shows 1, 2 and 3 stars.
SaveDocument _returningPlayer() => SaveDocument(
  currentLevel: 61,
  highestLevel: 61,
  // Forest Bear (2,500) then Ocean (800), 100 left (frames 7.4b, 7.6).
  coins: 3400,
  // Past level 60, every intro card was seen (levels 16, 31 and 51), so
  // level 61 opens on its board, not on a card.
  tutorialDone: true,
  seenIntros: const ['towers', 'glass', 'ice'],
  ownedThemes: const ['ch01', 'ch07'],
  museum: const ['ch01', 'ch02', 'ch03'],
  // Frame 6.2's chip reads "Collected · Sep 12" (meta-05b).
  museumCollected: {'ch01': LocalDate(2026, 9, 12)},
  levelStars: {
    for (var order = 1; order <= 60; order++)
      // Chapter 3 (levels 41-60) is perfect: every level at 3 stars, so its
      // folded row shows the gold-ringed 60/60 chip and "Every level at 3
      // stars" (frame 11.5).
      'L${order.toString().padLeft(4, '0')}': order > 40
          ? 3
          : const [3, 2, 3, 1][order % 4],
  },
  levelBests: {
    for (var order = 1; order <= 60; order++)
      'L${order.toString().padLeft(4, '0')}@1': 8 + order % 9,
  },
  records: const SaveRecords(
    families: 3,
    dolls: 120,
    dailies: 4,
    longestRun: 4,
  ),
  race: const RaceProgress(
    rivals: [
      RivalProgress(unlocked: true, wins: 1, raceNo: 1),
      RivalProgress(unlocked: true),
      RivalProgress(),
    ],
  ),
);

/// Frame 12.1's player: level 60 (chapter 3's finale, Super Hard) next.
SaveDocument _finalePlayer() => SaveDocument(
  currentLevel: 60,
  highestLevel: 60,
  coins: 905,
  tutorialDone: true,
  seenIntros: const ['towers', 'glass', 'ice'],
  museum: const ['ch01', 'ch02'],
  levelStars: {
    for (var order = 1; order <= 59; order++)
      'L${order.toString().padLeft(4, '0')}': const [3, 2, 3, 1][order % 4],
  },
  records: const SaveRecords(families: 2, dolls: 90),
);

/// Frames 12.2 and 6.1c's player: all 200 levels won, all ten families home,
/// bonus level 7 next and a daily streak of 0.
SaveDocument _completePlayer() {
  const chapters = [
    'ch01',
    'ch02',
    'ch03',
    'ch04',
    'ch05',
    'ch06',
    'ch07',
    'ch08',
    'ch09',
    'ch10',
  ];
  return SaveDocument(
    currentLevel: 201,
    highestLevel: 201,
    coins: 6420,
    tutorialDone: true,
    seenIntros: const ['towers', 'glass', 'ice'],
    museum: chapters,
    museumCollected: {
      for (var i = 0; i < chapters.length; i++)
        chapters[i]: LocalDate(2026, 9, 1 + i),
    },
    levelStars: {
      for (var order = 1; order <= 200; order++)
        'L${order.toString().padLeft(4, '0')}': const [3, 2, 3, 3][order % 4],
    },
    bonus: const BonusProgress(next: 7),
    records: const SaveRecords(families: 10, dolls: 600),
  );
}

/// A level's tier as its dev picker tile labels it ("Level 56 · Hard").
String _tierLabel(int level) {
  final entry = get<LevelRepository>().entryAt(level)!;
  return switch (entry.tier) {
    Tier.easy => 'Easy',
    Tier.medium => 'Medium',
    Tier.hard => 'Hard',
    Tier.superhard => 'Super Hard',
  };
}

/// `binding.takeScreenshot`, with Android's surface conversion first (the
/// playthrough's own helper, kept local: that file's is private).
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
    final bytes = await _binding.takeScreenshot(name);
    expect(bytes, isNotEmpty, reason: name);
  }
}
