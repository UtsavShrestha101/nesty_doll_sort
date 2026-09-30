import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/records/record_rules.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart';
import 'package:nesty_game/features/chapters/pages/chapters_page.dart';
import 'package:nesty_game/features/records/cubit/records_cubit.dart';
import 'package:nesty_game/features/records/pages/records_page.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/meta_harness.dart';
import '../features/support/screen_harness.dart';
import '../helpers/level_fixtures.dart';

/// M7 overflow suite (m7-design §18 "overflow", §11, §12): Chapters and
/// Records at the five acceptance sizes and both text scales, over a
/// worst-case save (every badge earned, a long best-moves count, a mixed
/// won/current/locked chapter). Both screens are the menus lane's real UI
/// (§15.1, §15.2: the level grid and the badge grid), so this sweep covers
/// them at 4 columns (phones) and 6 columns (the 768×1024 tablet size) at
/// both text scales.
///
/// No test here calls `cubit.close()`: like `museum_page_test.dart`
/// documents, [ChaptersCubit] and [RecordsCubit] only hold a
/// `SaveService.changes` subscription (no timer of their own), and awaiting
/// `close()` inside `testWidgets` reproducibly hung this sandbox (CLAUDE.md
/// "Widget-test harness facts": `Bloc.close()` never completes in the
/// fake-async zone).
void main() {
  setUpAll(loadBundledFonts);

  final catalog = FakeCatalogRepository();
  final level = levelFrom(tutorialLevelJson);

  FakeLevelRepository levels() => FakeLevelRepository(
    entries: [
      for (var order = 1; order <= 25; order++)
        entryFor(level, order: order, par: 1),
    ],
  );

  // Chapter 1 (orders 1–20) is fully won: it folds into a compact row
  // (D111). Chapter 2 (orders 21–40, only 21–25 bundled here) mixes won,
  // current (25) and locked; chapters past that are entirely locked, now
  // labelled with their level range (D111) instead of a bare "Chapter N".
  ChaptersCubit buildChapters() => ChaptersCubit(
    FakeSaveService(
      initial: const SaveDocument(
        coins: 1234567,
        currentLevel: 25,
        highestLevel: 25,
      ),
    ),
    levels(),
    catalog,
  );

  /// The spec §6.6 tier pattern of each 10-level block.
  const pattern = [
    Tier.easy,
    Tier.easy,
    Tier.medium,
    Tier.easy,
    Tier.medium,
    Tier.hard,
    Tier.medium,
    Tier.easy,
    Tier.medium,
    Tier.superhard,
  ];

  // The late-game worst case: 200 levels in ten chapters on the tier
  // pattern, chapters 1-7 won (folded), chapter 8 current at L157 so its
  // won cells carry the hard and super hard edges (owner-home), every won
  // cell a 3-digit "Best 188" at 1.3x and a 3-star row (m7-design P3.7),
  // and chapters 9-10 locked.
  ChaptersCubit buildChaptersLate() => ChaptersCubit(
    FakeSaveService(
      initial: SaveDocument(
        coins: 1234567,
        currentLevel: 157,
        highestLevel: 157,
        levelBests: {LevelBests.key(level.id, 1): 188},
        levelStars: {level.id: 3},
      ),
    ),
    FakeLevelRepository(
      entries: [
        for (var order = 1; order <= 200; order++)
          entryFor(
            level,
            order: order,
            tier: pattern[(order - 1) % 10],
            chapterId:
                'ch${((order - 1) ~/ 20 + 1).toString().padLeft(2, '0')}',
            par: 1,
          ),
      ],
    ),
    catalog,
  );

  // Everything won at 3 stars, PLAY in Bonus Endless: every chapter is a
  // folded row with the gold "Every level at 3 stars" chip and no chapter
  // is open (frame 10.4's finished rows).
  ChaptersCubit buildChaptersFinished() => ChaptersCubit(
    FakeSaveService(
      initial: SaveDocument(
        currentLevel: 201,
        highestLevel: 201,
        levelBests: {LevelBests.key(level.id, 1): 188},
        levelStars: {level.id: 3},
      ),
    ),
    FakeLevelRepository(
      entries: [
        for (var order = 1; order <= 200; order++)
          entryFor(
            level,
            order: order,
            chapterId:
                'ch${((order - 1) ~/ 20 + 1).toString().padLeft(2, '0')}',
            par: 1,
          ),
      ],
    ),
    catalog,
  );

  /// The chapter card's emblem draws a real bundled figurine PNG
  /// (`FigurineImage`'s `Image.asset`), whose decode is genuine async work
  /// outside flutter_test's fake time (`museum_page_test.dart`'s own
  /// precache). Precaching every figurine (and its `-locked` silhouette)
  /// under one `runAsync`, over a throwaway tree before the real page ever
  /// mounts, lets that real decode happen once, safely, on its own.
  Future<void> precacheFigurines(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
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

  RecordsCubit buildRecords() => RecordsCubit(
    FakeSaveService(
      initial: SaveDocument(
        coins: 1234567,
        currentLevel: 188,
        highestLevel: 188,
        // m7-design P3.7: a 3-star level and its total, "N/75" (25 fake
        // levels, each with a par).
        levelStars: {level.id: 3},
        race: const RaceProgress(
          rivals: [
            RivalProgress(unlocked: true, wins: 1234),
            RivalProgress(unlocked: true, wins: 12),
            RivalProgress(),
          ],
        ),
        records: SaveRecords(
          families: 212,
          dolls: 1234567,
          dailies: 42,
          longestRun: 132,
          badges: [for (final badge in BadgeId.values) badge.id],
        ),
      ),
    ),
    levels(),
  );

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'Chapters fits ${size.width.toInt()}×${size.height.toInt()} at '
        '$scale× text',
        (tester) async {
          await precacheFigurines(tester);
          final cubit = buildChapters();
          await pumpScreen(
            tester,
            withFakeArt(
              BlocProvider<ChaptersCubit>.value(
                value: cubit,
                child: const ChaptersView(),
              ),
            ),
            size: size,
            textScale: scale,
          );
          await cubit.load();
          await tester.pump();
          // Lets the post-frame auto-scroll-to-current callback (D111)
          // run and its `jumpTo` land, so this checks the layout the
          // player actually lands on, not the pre-scroll one.
          await tester.pump();
          await expectAccessibleLayout(tester);
        },
      );

      testWidgets(
        'Chapters late in the game (best moves on every won cell, tier '
        'edges) fits ${size.width.toInt()}×${size.height.toInt()} at '
        '$scale× text',
        (tester) async {
          await precacheFigurines(tester);
          final cubit = buildChaptersLate();
          await pumpScreen(
            tester,
            withFakeArt(
              BlocProvider<ChaptersCubit>.value(
                value: cubit,
                child: const ChaptersView(),
              ),
            ),
            size: size,
            textScale: scale,
          );
          await cubit.load();
          await tester.pump();
          await tester.pump();
          expect(find.text('Best 188'), findsWidgets);
          await expectAccessibleLayout(tester);
        },
      );

      testWidgets(
        'Chapters with every chapter finished (gold chips, all folded) '
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
        (tester) async {
          await precacheFigurines(tester);
          final cubit = buildChaptersFinished();
          await pumpScreen(
            tester,
            withFakeArt(
              BlocProvider<ChaptersCubit>.value(
                value: cubit,
                child: const ChaptersView(),
              ),
            ),
            size: size,
            textScale: scale,
          );
          await cubit.load();
          await tester.pump();
          await tester.pump();
          expect(find.text('Every level at 3 stars'), findsWidgets);
          await expectAccessibleLayout(tester);
        },
      );

      testWidgets(
        'Records fits ${size.width.toInt()}×${size.height.toInt()} at '
        '$scale× text',
        (tester) async {
          final cubit = buildRecords();
          await pumpScreen(
            tester,
            BlocProvider<RecordsCubit>.value(
              value: cubit,
              child: const RecordsView(),
            ),
            size: size,
            textScale: scale,
          );
          await cubit.load();
          await tester.pump();
          await expectAccessibleLayout(tester);
        },
      );
    }
  }
}
