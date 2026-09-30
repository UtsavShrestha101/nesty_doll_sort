import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/chapters/pages/chapters_page.dart';
import 'package:nesty_game/features/chapters/widgets/chapter_level_cell.dart';
import 'package:nesty_game/features/chapters/widgets/level_card.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/museum/pages/museum_page.dart';
import 'package:nesty_game/features/records/pages/records_page.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/shop/widgets/shop_buy_button.dart';
import 'package:nesty_game/features/shop/widgets/skin_grid_card.dart';
import 'package:nesty_game/features/shop/widgets/theme_grid_card.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/seeded_save.dart';

/// The meta screens on a device (phase 4 lane M; architecture §7.3, D169):
/// a seeded returning player (60 levels won, three families home, 2,600
/// coins, a bought theme) walks Home (2.1), Chapters (10.4) into the level
/// card (10.4b) and Play, the Museum (6.1), Records (10.6), the Shop's Skins
/// (7.3, Forest Bear) and Themes (7.7, the crops), buys Forest Bear, uses the
/// owned ch07 theme and sees it behind Home and a level.
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
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Home, Chapters and its level card, the Museum, Records, the Shop and '
    'a used theme, on a seeded save',
    (tester) async {
      await seedSave(_returningPlayer());

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
      await shots.take('meta-02-chapters');

      // A finished row opens in place (one open at a time): chapter 1's
      // cell 2 is won, so it opens the level card (10.4b) with its Play.
      // Chapters opens scrolled to the current chapter, so chapter 1's row
      // is above the viewport (built, but offstage to `find`): scroll up
      // to it first (the device run found it, 2026-09-30).
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
      await shots.take('meta-05-museum');

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
      await shots.take('meta-06-records');
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
      expect(save.coins, 2600);
      await tester.tap(
        find.descendant(of: bear, matching: find.byType(ShopBuyButton)),
      );
      await tester.pumpFor(const Duration(milliseconds: 1000));
      expect(save.document.ownedSkins, contains('forest-bear'));
      expect(save.coins, 100, reason: '2,600 - 2,500');
      await shots.take('meta-08-bought');

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
/// current; 2,600 coins, enough for Forest Bear (2,500); Puppet Theater
/// (ch07) bought; rival 1 beaten once. The stars follow a simple pattern so
/// the grid shows 1, 2 and 3 stars.
SaveDocument _returningPlayer() => SaveDocument(
  currentLevel: 61,
  highestLevel: 61,
  coins: 2600,
  // Past level 60, every intro card was seen (levels 16, 31 and 51), so
  // level 61 opens on its board, not on a card.
  tutorialDone: true,
  seenIntros: const ['towers', 'glass', 'ice'],
  ownedThemes: const ['ch01', 'ch07'],
  museum: const ['ch01', 'ch02', 'ch03'],
  levelStars: {
    for (var order = 1; order <= 60; order++)
      'L${order.toString().padLeft(4, '0')}': const [3, 2, 3, 1][order % 4],
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
