import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/records/record_rules.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart';
import 'package:nesty_game/features/chapters/pages/chapters_page.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../../helpers/level_fixtures.dart';
import '../../support/meta_harness.dart';

/// The Chapters screen (E7; docs/plans/m7-design.md §11, §15.1) over a real
/// [ChaptersCubit] built from fakes, the same pattern `museum_page_test.dart`
/// uses: loading, an error with retry, and the loaded grid.
///
/// No test here calls `cubit.close()`. Like `MuseumCubit`, [ChaptersCubit]
/// only holds a `SaveService.changes` subscription (no timer of its own), so
/// flutter_test's pending-timer check doesn't need it closed, and awaiting
/// `close()` inside `testWidgets` reproducibly hung this sandbox (CLAUDE.md
/// "Widget-test harness facts": `Bloc.close()` never completes in the
/// fake-async zone; use `tester.runAsync`, never await it here).
void main() {
  setUpAll(loadBundledFonts);

  final catalog = FakeCatalogRepository(
    chapters: const [
      ChapterInfo(
        id: 'ch01',
        number: 1,
        themeId: 'ch01',
        figurine: FigurineInfo(
          id: 'classic',
          number: 1,
          artAsset: 'assets/museum/01-classic.png',
          lockedArtAsset: 'assets/museum/01-classic-locked.png',
        ),
        levels: 3,
      ),
    ],
  );

  final level = levelFrom(tutorialLevelJson);
  final levels = FakeLevelRepository(
    entries: [
      for (var order = 1; order <= 3; order++) entryFor(level, order: order),
    ],
  );

  ChaptersCubit build({int currentLevel = 2, int highestLevel = 2}) =>
      ChaptersCubit(
        FakeSaveService(
          initial: SaveDocument(
            currentLevel: currentLevel,
            highestLevel: highestLevel,
            coins: 250,
          ),
        ),
        levels,
        catalog,
      );

  /// The chapter card's emblem draws a real bundled figurine PNG
  /// (`FigurineImage`'s `Image.asset`), whose decode is genuine async work
  /// outside flutter_test's fake time (`museum_page_test.dart`'s own
  /// precache). Precaching every figurine (and its `-locked` silhouette)
  /// under one `runAsync`, over a throwaway tree before the real page ever
  /// mounts, lets that real decode happen once, safely, on its own.
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

  Future<void> pumpChapters(
    WidgetTester tester,
    ChaptersCubit cubit, {
    Size? viewSize,
  }) async {
    await precacheFigurines(tester);
    if (viewSize != null) {
      tester.view
        ..physicalSize = viewSize
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(
      withFakeArt(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<ChaptersCubit>.value(
            value: cubit,
            child: const ChaptersPage(),
          ),
        ),
      ),
    );
    await cubit.load();
    await tester.pump();
    // Lets the post-frame auto-scroll-to-current callback (m7-design's
    // Chapters redesign, D111) run and its `jumpTo` land in the tree.
    await tester.pump();
  }

  testWidgets('the header, the coin pill and the grid once loaded', (
    tester,
  ) async {
    final cubit = build();
    await pumpChapters(tester, cubit);

    expect(find.text('Chapters'), findsOneWidget);
    // Frame 10.4 has no coin pill: back and the title only.
    expect(find.text('250'), findsNothing);
    // The current chapter opens by default: its kicker with the level
    // range, its name and its doll family (not yet earned, 1 of 3 won).
    expect(find.text('CHAPTER 1 · LEVELS 1\u2060–\u20603'), findsOneWidget);
    expect(find.text('Sunny Toy Shop'), findsOneWidget);
    expect(find.text('The Classic Family'), findsOneWidget);
    // The header's overall line (design request I.4): Home's PLAY level
    // (`currentLevel: 2`) over every catalog level (this fake catalog's one
    // chapter, 3 levels), and how many are won.
    expect(find.text('Level 2 of 3'), findsOneWidget);
    expect(find.text('1 won'), findsOneWidget);
  });

  testWidgets('auto-scrolls to the chapter holding the current level on '
      'open (D111)', (tester) async {
    final bigCatalog = FakeCatalogRepository(
      chapters: const [
        ChapterInfo(
          id: 'ch01',
          number: 1,
          themeId: 'ch01',
          figurine: FigurineInfo(
            id: 'classic',
            number: 1,
            artAsset: 'assets/museum/01-classic.png',
            lockedArtAsset: 'assets/museum/01-classic-locked.png',
          ),
        ),
        ChapterInfo(
          id: 'ch02',
          number: 2,
          themeId: 'ch02',
          figurine: FigurineInfo(
            id: 'sailor',
            number: 2,
            artAsset: 'assets/museum/02-sailor.png',
            lockedArtAsset: 'assets/museum/02-sailor-locked.png',
          ),
        ),
      ],
    );
    final bigLevels = FakeLevelRepository(
      entries: [
        for (var order = 1; order <= 40; order++) entryFor(level, order: order),
      ],
    );
    // Chapter 1 (orders 1–20): 19 won, 1 locked (never fully won, so it
    // never folds — every one of its 20 cells stays on screen). Chapter 2
    // (orders 21–40): order 21 is current. On a short viewport, reaching
    // it needs a real scroll.
    final cubit = ChaptersCubit(
      FakeSaveService(
        initial: const SaveDocument(currentLevel: 21, highestLevel: 20),
      ),
      bigLevels,
      bigCatalog,
    );
    await pumpChapters(tester, cubit, viewSize: const Size(390, 500));

    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(
      scrollable.position.pixels,
      greaterThan(0),
      reason:
          'chapter 2, holding the current level, starts well below the '
          'fold on a 390×500 viewport with all of chapter 1\'s 20 cells '
          'expanded above it',
    );
  });

  testWidgets('the auto-scroll target is still mounted with several '
      'earlier chapters folded and carrying a star total each '
      '(m7-design P3.7)', (tester) async {
    // A regression for a real bug this stage found: adding the star total
    // row to every chapter card (won here and elsewhere) pushed chapter 8
    // just past the default 250 dp Sliver cache extent on a small phone,
    // so its `KeyedSubtree` was never mounted and the scroll silently
    // never ran (`_scrollToCurrentOnce` reads a null `currentContext`).
    // `chapters_page.dart`'s `cacheExtent: 5000` fixes it; this pins that
    // the current chapter's own cells are findable without it regressing.
    final manyChapters = FakeCatalogRepository(
      chapters: [
        for (var n = 1; n <= 8; n++)
          ChapterInfo(
            id: 'ch${n.toString().padLeft(2, '0')}',
            number: n,
            themeId: 'ch01',
            figurine: const FigurineInfo(
              id: 'classic',
              number: 1,
              artAsset: 'assets/museum/01-classic.png',
              lockedArtAsset: 'assets/museum/01-classic-locked.png',
            ),
          ),
      ],
    );
    final manyLevels = FakeLevelRepository(
      entries: [
        for (var order = 1; order <= 160; order++)
          entryFor(level, order: order, par: 1),
      ],
    );
    // Chapters 1–7 (orders 1–140) fully won, so every one folds into a
    // compact row; chapter 8 (141–160) holds the current level (157) and
    // stays expanded, its early cells ("Best 188") the ones this checks.
    final cubit = ChaptersCubit(
      FakeSaveService(
        initial: SaveDocument(
          currentLevel: 157,
          highestLevel: 157,
          levelBests: {LevelBests.key(level.id, 1): 188},
          levelStars: {level.id: 3},
        ),
      ),
      manyLevels,
      manyChapters,
    );
    await pumpChapters(tester, cubit, viewSize: const Size(360, 640));

    // ch08 is named since copy.md G.4 (phase 4).
    expect(find.text('CHAPTER 8 · LEVELS 141\u2060–\u2060160'), findsOneWidget);
    expect(find.text('Autumn Bandstand'), findsOneWidget);
    expect(find.textContaining('Best 188'), findsWidgets);
  });

  testWidgets('one chapter is open at a time: a tap on a finished row opens '
      'it in place and folds the current one (frame 10.4)', (tester) async {
    final two = FakeCatalogRepository(
      chapters: [
        for (var n = 1; n <= 2; n++)
          ChapterInfo(
            id: 'ch0$n',
            number: n,
            themeId: 'ch0$n',
            figurine: const FigurineInfo(
              id: 'classic',
              number: 1,
              artAsset: 'assets/museum/01-classic.png',
              lockedArtAsset: 'assets/museum/01-classic-locked.png',
            ),
          ),
      ],
    );
    final fortyLevels = FakeLevelRepository(
      entries: [
        for (var order = 1; order <= 40; order++) entryFor(level, order: order),
      ],
    );
    // Chapter 1 finished (folds to a row), chapter 2's level 21 current.
    final cubit = ChaptersCubit(
      FakeSaveService(
        initial: const SaveDocument(currentLevel: 21, highestLevel: 21),
      ),
      fortyLevels,
      two,
    );
    await pumpChapters(tester, cubit, viewSize: const Size(390, 1400));
    // The current chapter's grid is on screen; chapter 1 is a row.
    expect(find.text('21'), findsOneWidget);
    expect(find.text('5'), findsNothing);

    await tester.tap(find.text('Sunny Toy Shop'));
    await tester.pump();
    expect(find.text('5'), findsOneWidget, reason: 'chapter 1 opened');
    expect(find.text('21'), findsNothing, reason: 'chapter 2 folded');

    await tester.tap(find.text('Sunny Toy Shop'));
    await tester.pump();
    expect(find.text('5'), findsNothing, reason: 'a second tap folds it');
    expect(find.text('21'), findsNothing, reason: 'none is open then');
  });

  testWidgets('follows SaveService.changes: a replay\'s new best lands '
      'live', (tester) async {
    final save = FakeSaveService(
      initial: const SaveDocument(currentLevel: 2, highestLevel: 2),
    );
    final cubit = ChaptersCubit(save, levels, catalog);
    await pumpChapters(tester, cubit);
    expect(find.textContaining('Best'), findsNothing);

    final key = LevelBests.key(level.id, 1);
    save.recordLevelWin(
      LevelWinRecord(
        request: const PlayRequest.replay(1),
        rewardCoins: 0,
        moves: 6,
        date: LocalDate(2026, 9, 26),
        bestKey: key,
      ),
    );
    // The refresh is a stream event -> `runGuarded`'s own async hop -> emit
    // -> rebuild: one plain `pump()` isn't reliably enough frames to land
    // it (unlike before this screen had a stateful auto-scroll body too).
    await tester.pumpAndSettle();
    expect(find.textContaining('Best'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    final cubit = ChaptersCubit(_ThrowingSaveService(), levels, catalog);
    await pumpChapters(tester, cubit);
    expect(find.byType(RetryView), findsOneWidget);
  });
}

/// A [SaveService] whose `document` getter throws, so `ChaptersCubit.load`
/// lands on `AsyncValueError` (`RetryView`).
class _ThrowingSaveService extends FakeSaveService {
  @override
  SaveDocument get document => throw StateError('no document');
}
