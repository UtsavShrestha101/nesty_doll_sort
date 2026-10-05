import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/ui/art/theme_thumbnail_loader.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/home/stars_chip.dart';
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart';
import 'package:nesty_game/features/chapters/widgets/chapter_level_cell.dart';
import 'package:nesty_game/features/chapters/widgets/chapter_section_card.dart';
import 'package:nesty_game/features/chapters/widgets/level_card.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

import '../../../core/ui/support/ui_harness.dart';
import '../../support/meta_harness.dart';
import '../../support/screen_harness.dart';

/// One chapter's card and level grid (docs/plans/m7-design.md §11, §15.1):
/// won/current/locked cells, their taps and their captions; the chapter's
/// own character (its theme colour and doll family, owner's simulator
/// review, 2026-09-28, D111) and, once fully won, its fold.
void main() {
  setUpAll(loadBundledFonts);

  Widget card(
    ChapterSection section, {
    ValueChanged<PlayRequest>? onPlay,
    bool expanded = true,
    VoidCallback? onToggle,
  }) => withFakeArt(
    Material(
      child: SingleChildScrollView(
        child: ChapterSectionCard(
          section: section,
          expanded: expanded,
          onToggle: onToggle ?? () {},
          onPlay: onPlay ?? (_) {},
        ),
      ),
    ),
  );

  /// The emblem draws a real bundled figurine PNG (`FigurineImage`'s
  /// `Image.asset`), whose decode is genuine async work outside
  /// flutter_test's fake time (`museum_page_test.dart`'s own precache).
  /// Precaching every figurine (and its `-locked` silhouette) under one
  /// `runAsync`, over a throwaway tree before the card itself ever mounts,
  /// lets that real decode happen once, safely, on its own.
  Future<void> precacheFigurines(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));
    await tester.runAsync(() async {
      for (var n = 1; n <= BundledCatalogRepository.figurineIds.length; n++) {
        final id = BundledCatalogRepository.figurineIds[n - 1];
        await precacheImage(
          AssetImage(BundledCatalogRepository.figurineArt(n, id)),
          context,
        );
        await precacheImage(
          AssetImage(BundledCatalogRepository.figurineArt(n, id, locked: true)),
          context,
        );
      }
    });
  }

  const section = ChapterSection(
    chapterId: 'ch02',
    number: 2,
    levels: [
      ChapterLevel(order: 21, status: ChapterLevelStatus.won, bestMoves: 9),
      ChapterLevel(order: 22, status: ChapterLevelStatus.won),
      ChapterLevel(order: 23, status: ChapterLevelStatus.current),
      ChapterLevel(order: 24),
    ],
  );

  testWidgets('the open card\'s header reads the kicker with the level range '
      'and the chapter\'s name (frame 10.4)', (tester) async {
    await pumpScreen(tester, card(section));
    expect(find.text('CHAPTER 2 · LEVELS 21\u2060–\u206024'), findsOneWidget);
    expect(find.text('Rainy Café Corner'), findsOneWidget);
    // The header is one node that folds the card and says it is expanded.
    expect(
      find.bySemanticsLabel('Chapter 2, Rainy Café Corner. 0 of 0 stars.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping the open header folds the card (the page owns which '
      'is open)', (tester) async {
    var toggled = 0;
    await pumpScreen(tester, card(section, onToggle: () => toggled++));
    await tester.tap(find.text('Rainy Café Corner'));
    expect(toggled, 1);
  });

  testWidgets('a won cell opens the level card; its Play replays the level', (
    tester,
  ) async {
    final played = <PlayRequest>[];
    await pumpScreen(tester, card(section, onPlay: played.add));
    expect(find.text('Best 9'), findsOneWidget);
    // A best with no stars (a level without a par) still says its best.
    expect(
      find.bySemanticsLabel('Level 21, won. Best 9 moves.'),
      findsOneWidget,
    );

    await tester.tap(find.text('21'));
    await tester.pumpAndSettle();
    // Nothing plays until Play is tapped: the card comes first (10.4b).
    expect(played, isEmpty);
    expect(find.byType(LevelCard), findsOneWidget);
    // "Best 9" is on the cell and on the card's chip.
    expect(find.text('Best 9'), findsNWidgets(2));

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(played, [const PlayRequest.replay(21)]);
    expect(find.byType(LevelCard), findsNothing);
  });

  testWidgets('a won cell without a best has no "Best" caption and its card '
      'has only Play (a level won before M7)', (tester) async {
    final played = <PlayRequest>[];
    await pumpScreen(tester, card(section, onPlay: played.add));
    expect(find.bySemanticsLabel('Level 22, won.'), findsOneWidget);

    await tester.tap(find.text('22'));
    await tester.pumpAndSettle();
    expect(find.text('Best 9'), findsOneWidget); // only level 21's cell
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(played, [const PlayRequest.replay(22)]);
  });

  testWidgets('the current cell plays the campaign at once, with a play '
      'arrow', (tester) async {
    final played = <PlayRequest>[];
    await pumpScreen(tester, card(section, onPlay: played.add));
    expect(find.bySemanticsLabel('Level 23, next to play.'), findsOneWidget);
    expect(find.byIcon(NestyIcons.playArrow), findsOneWidget);

    await tester.tap(find.text('23'));
    expect(played, [const PlayRequest.campaign(23)]);
    expect(find.byType(LevelCard), findsNothing);
  });

  testWidgets('a locked cell keeps its number, shows a lock and never taps', (
    tester,
  ) async {
    final played = <PlayRequest>[];
    await pumpScreen(tester, card(section, onPlay: played.add));
    expect(find.bySemanticsLabel('Level 24, locked.'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.byIcon(NestyIcons.lock), findsOneWidget);

    await tester.tap(find.text('24'));
    await tester.pumpAndSettle();
    expect(played, isEmpty);
    expect(find.byType(LevelCard), findsNothing);
  });

  group('the family row and the open header (frame 10.4)', () {
    testWidgets('an earned family shows in colour; a not-yet-earned one is '
        'its silhouette, with the family\'s name', (tester) async {
      await precacheFigurines(tester);
      await pumpScreen(
        tester,
        card(
          section.copyWith(
            themeId: 'ch02',
            figurineId: 'sailor',
            figurineEarned: true,
          ),
        ),
      );
      expect(find.text('The Sailor Family'), findsOneWidget);
      expect(
        tester.widget<FigurineImage>(find.byType(FigurineImage)).locked,
        isFalse,
      );

      await pumpScreen(
        tester,
        card(
          section.copyWith(
            themeId: 'ch02',
            figurineId: 'sailor',
            figurineEarned: false,
          ),
        ),
      );
      expect(
        tester.widget<FigurineImage>(find.byType(FigurineImage)).locked,
        isTrue,
      );
    });

    testWidgets('the header crops the chapter\'s own theme at its full '
        'width, 92 tall', (tester) async {
      final loader = FakeThemeThumbnailLoader();
      await pumpScreen(
        tester,
        withFakeArt(
          Material(
            child: SingleChildScrollView(
              child: ChapterSectionCard(
                section: section.copyWith(themeId: 'ch02'),
                expanded: true,
                onToggle: () {},
                onPlay: (_) {},
              ),
            ),
          ),
          loader: loader,
        ),
      );
      await tester.pump();
      final header = loader.requests.firstWhere((r) => r.box.height == 92);
      expect(header.theme, ChapterTheme.ch02);
      expect(header.locked, isFalse);
      expect(header.box.width, greaterThan(300));
    });

    testWidgets('the levels-to-go line and the progress bar say how far the '
        'family is', (tester) async {
      await pumpScreen(tester, card(section)); // 2 of 4 won
      expect(find.text('2 levels to go'), findsOneWidget);

      // The bar is drawn: a 10 dp track across its column and a fill half
      // way along it (the device run found both 0 in size, 2026-09-30).
      final bar = find.bySemanticsLabel('2 / 4');
      expect(bar, findsOneWidget);
      final barRect = tester.getRect(bar);
      expect(barRect.width, greaterThan(150));
      expect(barRect.height, 10);
      final track = tester.getRect(
        find.descendant(of: bar, matching: find.byType(ColoredBox)),
      );
      expect(track, barRect);
      final fill = tester.getRect(
        find.descendant(of: bar, matching: find.byType(DecoratedBox)),
      );
      expect(fill.left, barRect.left);
      expect(fill.height, 10);
      expect(fill.width, closeTo(barRect.width / 2, 0.5));
    });
  });

  group('folded rows (frame 10.4)', () {
    ChapterSection wonSection({int stars = 60, int possible = 60}) =>
        ChapterSection(
          chapterId: 'ch01',
          number: 1,
          stars: stars,
          starsPossible: possible,
          levels: [
            for (var order = 1; order <= 20; order++)
              ChapterLevel(order: order, status: ChapterLevelStatus.won),
          ],
        );

    testWidgets('a finished chapter is a row: kicker, name, family, stars '
        'chip; no grid', (tester) async {
      await pumpScreen(tester, card(wonSection(), expanded: false));
      expect(find.text('CHAPTER 1 · LEVELS 1\u2060–\u206020'), findsOneWidget);
      expect(find.text('Sunny Toy Shop'), findsOneWidget);
      expect(find.text('60/60'), findsOneWidget);
      expect(find.byType(ChapterLevelCell), findsNothing);
      expect(
        find.bySemanticsLabel('Chapter 1, Sunny Toy Shop. 60 of 60 stars.'),
        findsOneWidget,
      );
    });

    testWidgets('every level at 3 stars: the sub line and the gold chip', (
      tester,
    ) async {
      await pumpScreen(tester, card(wonSection(), expanded: false));
      expect(find.text('Every level at 3 stars'), findsOneWidget);
      expect(tester.widget<StarsChip>(find.byType(StarsChip)).perfect, isTrue);

      await pumpScreen(tester, card(wonSection(stars: 52), expanded: false));
      expect(find.text('Every level at 3 stars'), findsNothing);
      expect(tester.widget<StarsChip>(find.byType(StarsChip)).perfect, isFalse);
    });

    testWidgets('a tap on a finished row asks the page to open it', (
      tester,
    ) async {
      var toggled = 0;
      await pumpScreen(
        tester,
        card(wonSection(), expanded: false, onToggle: () => toggled++),
      );
      await tester.tap(find.text('Sunny Toy Shop'));
      expect(toggled, 1);
    });

    testWidgets('a locked row is dimmed, has a lock, no stars chip and no '
        'tap', (tester) async {
      var toggled = 0;
      final locked = ChapterSection(
        chapterId: 'ch05',
        number: 5,
        levels: [for (var o = 81; o <= 100; o++) ChapterLevel(order: o)],
      );
      await pumpScreen(
        tester,
        card(locked, expanded: false, onToggle: () => toggled++),
      );
      expect(
        find.text('CHAPTER 5 · LEVELS 81\u2060–\u2060100'),
        findsOneWidget,
      );
      expect(find.byType(StarsChip), findsNothing);
      expect(find.byIcon(NestyIcons.lock), findsOneWidget);
      expect(
        find.bySemanticsLabel('Chapter 5, Night Carnival. Locked.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Night Carnival'));
      expect(toggled, 0);
    });

    for (final size in const [Size(402, 874), Size(390, 844), Size(360, 640)]) {
      testWidgets('a wrapped kicker keeps "181–200" on one line at '
          '${size.width.toInt()} wide', (tester) async {
        // The device run (2026-09-30) found "LEVELS 181–" over "200" on an
        // iPhone 16 Pro (402 wide); frame 10.4 wraps before the range.
        final ten = ChapterSection(
          chapterId: 'ch10',
          number: 10,
          levels: [for (var o = 181; o <= 200; o++) ChapterLevel(order: o)],
        );
        // Inside the Chapters list's own 16 dp side padding, as on the page.
        await pumpScreen(
          tester,
          withFakeArt(
            Material(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: ChapterSectionCard(
                    section: ten,
                    expanded: false,
                    onToggle: () {},
                    onPlay: (_) {},
                  ),
                ),
              ),
            ),
          ),
          size: size,
        );
        final kicker = find.textContaining('CHAPTER 10');
        expect(kicker, findsOneWidget);
        final paragraph = tester.renderObject<RenderParagraph>(kicker);
        final text = paragraph.text.toPlainText();
        expect(text, 'CHAPTER 10 · LEVELS 181${kickerRangeDash}200');
        final start = text.indexOf('181');
        final boxes = paragraph.getBoxesForSelection(
          TextSelection(baseOffset: start, extentOffset: text.length),
        );
        expect(boxes, isNotEmpty);
        expect(
          boxes.map((box) => box.top).toSet(),
          hasLength(1),
          reason: 'the range starts and ends on one line',
        );
      });
    }

    testWidgets('a locked row\'s crop is asked for in the locked look', (
      tester,
    ) async {
      final loader = FakeThemeThumbnailLoader();
      await pumpScreen(
        tester,
        withFakeArt(
          Material(
            child: ChapterSectionCard(
              section: ChapterSection(
                chapterId: 'ch05',
                number: 5,
                levels: [
                  for (var o = 81; o <= 100; o++) ChapterLevel(order: o),
                ],
              ),
              expanded: false,
              onToggle: () {},
              onPlay: (_) {},
            ),
          ),
          loader: loader,
        ),
      );
      await tester.pump();
      expect(loader.requests.single.locked, isTrue);
      expect(loader.requests.single.box, const Size(84, 42));
      expect(loader.requests.single.theme, ChapterTheme.ch05);
    });
  });

  /// A 20-level chapter with [statusAt10] on position 10 (the milestone
  /// chest), everything else won except the last level, which stays
  /// current (the finale flag still draws on a cell that isn't dimmed).
  ChapterSection chapterWithChestAt10(ChapterLevelStatus statusAt10) =>
      ChapterSection(
        chapterId: 'ch01',
        number: 1,
        levels: [
          for (var order = 1; order <= 20; order++)
            ChapterLevel(
              order: order,
              isChest: order == 10,
              isFinale: order == 20,
              status: order == 10
                  ? statusAt10
                  : order == 20
                  ? ChapterLevelStatus.current
                  : ChapterLevelStatus.won,
            ),
        ],
      );

  group('the milestone chest and finale marks (frame 10.4)', () {
    bool isChestArt(Widget w) => w is UiArtImage && w.art == UiArt.chestClosed;

    testWidgets('level 10 carries the chest (18×15) and its label says so', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        card(chapterWithChestAt10(ChapterLevelStatus.current)),
      );
      final chest = tester.widget<UiArtImage>(
        find.byWidgetPredicate(isChestArt),
      );
      expect(chest.size.width, 18);
      expect(chest.size.height, closeTo(15, 0.1));
      expect(
        find.bySemanticsLabel('Level 10, next to play. A chest at this level.'),
        findsOneWidget,
      );
    });

    testWidgets('only the chapter\'s last level carries the flag', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        card(chapterWithChestAt10(ChapterLevelStatus.won)),
      );
      expect(find.byIcon(IconUses.chapterFinale), findsOneWidget);
      expect(find.byWidgetPredicate(isChestArt), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'Level 20, next to play. The last level of the chapter.',
        ),
        findsOneWidget,
      );
    });
  });

  group('star totals and cells (m7-design P3.7)', () {
    testWidgets('a won cell with stars shows them and appends them to its '
        'semantics', (tester) async {
      const withStars = ChapterSection(
        chapterId: 'ch02',
        number: 2,
        stars: 5,
        starsPossible: 9,
        levels: [
          ChapterLevel(
            order: 21,
            status: ChapterLevelStatus.won,
            bestMoves: 9,
            stars: 3,
          ),
          ChapterLevel(order: 22, status: ChapterLevelStatus.won),
          ChapterLevel(order: 23, status: ChapterLevelStatus.current),
        ],
      );
      await pumpScreen(tester, card(withStars));
      expect(
        find.byWidgetPredicate(
          (w) => w is StarRow && w.count == 3 && w.size == StarRow.sizeCell,
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Level 21, 3 stars. Best 9 moves.'),
        findsOneWidget,
      );
      // A won cell without stars (won before M7, or without a par) draws
      // none, and its semantics stay exactly as before.
      expect(find.bySemanticsLabel('Level 22, won.'), findsOneWidget);
    });

    testWidgets('the card and the folded row always show the star total, '
        'even at 0', (tester) async {
      await pumpScreen(tester, card(section)); // no stars set: 0/0
      expect(find.text('0/0'), findsOneWidget);
      expect(find.bySemanticsLabel('1 of 0 stars'), findsNothing);
      expect(find.bySemanticsLabel('0 of 0 stars'), findsOneWidget);

      final withStars = section.copyWith(
        chapterId: 'ch01',
        number: 1,
        stars: 4,
        starsPossible: 12,
        levels: [
          for (var order = 1; order <= 20; order++)
            ChapterLevel(order: order, status: ChapterLevelStatus.won),
        ],
      );
      await pumpScreen(tester, card(withStars));
      expect(find.text('4/12'), findsOneWidget);
      await pumpScreen(tester, card(withStars, expanded: false));
      // The folded row shows the total too.
      expect(find.text('4/12'), findsOneWidget);
    });
  });

  group('the HARD/SUPER HARD tier edge (D111)', () {
    ChapterSection tieredSection() => const ChapterSection(
      chapterId: 'ch01',
      number: 1,
      levels: [
        ChapterLevel(order: 1, status: ChapterLevelStatus.won, tier: Tier.hard),
        ChapterLevel(
          order: 2,
          status: ChapterLevelStatus.won,
          tier: Tier.superhard,
        ),
        ChapterLevel(order: 3, status: ChapterLevelStatus.won, tier: Tier.easy),
        ChapterLevel(
          order: 4,
          status: ChapterLevelStatus.locked,
          tier: Tier.hard,
        ),
      ],
    );

    bool edgeOf(WidgetTester tester, Color color) =>
        tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).any((box) {
          final decoration = box.decoration;
          return decoration is BoxDecoration &&
              decoration.border is Border &&
              (decoration.border! as Border).top.color == color;
        });

    testWidgets('a won hard level draws a thin red edge', (tester) async {
      await pumpScreen(tester, card(tieredSection()));
      expect(edgeOf(tester, AppColorTokens.tierEdgeHard), isTrue);
    });

    testWidgets('a won super hard level draws a thin purple edge', (
      tester,
    ) async {
      await pumpScreen(tester, card(tieredSection()));
      expect(edgeOf(tester, AppColorTokens.tierEdgeSuperHard), isTrue);
    });

    testWidgets('a won easy level draws no tier edge at all', (tester) async {
      const easyOnly = ChapterSection(
        chapterId: 'ch01',
        number: 1,
        levels: [
          ChapterLevel(
            order: 1,
            status: ChapterLevelStatus.won,
            tier: Tier.easy,
          ),
        ],
      );
      await pumpScreen(tester, card(easyOnly));
      expect(edgeOf(tester, AppColorTokens.tierEdgeHard), isFalse);
      expect(edgeOf(tester, AppColorTokens.tierEdgeSuperHard), isFalse);
    });

    testWidgets('a locked hard level draws no tier edge (never previews a '
        'level not reached yet)', (tester) async {
      await pumpScreen(tester, card(tieredSection()));
      // Only the two won cells (order 1 hard, order 2 super hard) edge;
      // the locked order-4 hard cell contributes no third hard edge.
      final hardEdges = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where((box) {
            final decoration = box.decoration;
            return decoration is BoxDecoration &&
                decoration.border is Border &&
                (decoration.border! as Border).top.color ==
                    AppColorTokens.tierEdgeHard;
          });
      expect(hardEdges.length, 1);
    });
  });

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets('a full 20-level chapter fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        final full = ChapterSection(
          chapterId: 'ch01',
          number: 1,
          levels: [
            for (var order = 1; order <= 20; order++)
              ChapterLevel(
                order: order,
                status: order < 15
                    ? ChapterLevelStatus.won
                    : order == 15
                    ? ChapterLevelStatus.current
                    : ChapterLevelStatus.locked,
                bestMoves: order < 15 && order.isEven ? order : null,
              ),
          ],
        );
        await pumpScreen(tester, card(full), size: size, textScale: scale);
        expectNoLayoutErrors(tester);
      });
    }
  }
}
