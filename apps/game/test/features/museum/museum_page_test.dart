import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart';
import 'package:nesty_game/features/museum/pages/museum_page.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';

import '../../core/ui/support/ui_harness.dart';
import '../../helpers/level_fixtures.dart';
import '../support/screen_harness.dart';

/// The Museum screen (frames 6.1–6.3; docs/plans/m3-design.md §10.6) over a
/// real [MuseumCubit] built from fakes, the same pattern
/// `daily_page_test.dart` uses for `DailyView`: earned/next/locked cabinet
/// slots, the 6.2/6.3 modal (dates, hidden flavor text) and no overflow at
/// 360/390/430 × 1.3×.
///
/// No test here calls `cubit.close()`. [MuseumCubit] has no timer of its
/// own (only a `SaveService.changes` subscription), so flutter_test's
/// pending-timer check doesn't need it closed; closing it after this file's
/// real figurine PNGs have been decoded and painted reproducibly hung this
/// sandbox (its `Stream.cancel()` never returned). See `known_issues` in
/// this lane's report.
void main() {
  setUpAll(loadBundledFonts);

  final catalog = FakeCatalogRepository();

  LevelRepository levelsThrough(int currentLevel) {
    final level = levelFrom(tutorialLevelJson);
    return FakeLevelRepository(
      entries: [
        for (var order = 1; order <= currentLevel; order++)
          entryFor(level, order: order),
      ],
    );
  }

  MuseumCubit build({required SaveDocument document}) {
    final save = FakeSaveService(initial: document);
    final resolver = FakeLevelResolver(
      levelsThrough(document.currentLevel),
      save,
      FakeRemoteConfigService(),
    );
    return MuseumCubit(save, catalog, resolver);
  }

  // The cabinet and the modal spotlight draw real bundled PNGs
  // (`FigurineImage`'s `Image.asset`), whose decode is genuine async work
  // outside flutter_test's fake time (`WidgetTester.runAsync`'s own
  // contract). Precaching every figurine PNG (and its `-locked` silhouette)
  // under one `runAsync`, over a throwaway tree before `MuseumPage` itself
  // ever mounts, lets that real decode happen once, safely, on its own; by
  // the time the page builds, every `Image.asset` it asks for already has a
  // completed image sitting in `PaintingBinding.imageCache` and resolves
  // synchronously, so no further pump needs `runAsync`.
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

  Future<void> pumpMuseum(
    WidgetTester tester,
    MuseumCubit cubit, {
    Size size = const Size(390, 844),
    double textScale = 1,
    // A collected niche bobs forever, which `pumpAndSettle` would wait on:
    // most tests hold it still, the bob's own tests turn it on.
    bool reduceMotion = true,
  }) async {
    await precacheFigurines(tester);
    await pumpScreen(
      tester,
      BlocProvider<MuseumCubit>.value(value: cubit, child: const MuseumPage()),
      size: size,
      textScale: textScale,
      reduceMotion: reduceMotion,
    );
    await cubit.load();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('frame 6.1: the header with its count chip, the intro, the '
      'next-family card and the cabinet\'s collected/next/locked niches', (
    tester,
  ) async {
    final cubit = build(
      document: const SaveDocument(
        coins: 90,
        currentLevel: 36,
        museum: ['ch01'],
      ),
    );
    await pumpMuseum(tester, cubit);

    expect(find.text('Museum'), findsOneWidget);
    // The tab has no coin pill and no back button (frame 6.1); Chapters
    // opens from Home's chapter card only (Q92).
    expect(find.text('90'), findsNothing);
    expect(find.text('Chapters'), findsNothing);
    expect(find.text('1 / 10'), findsOneWidget);
    expect(
      find.text(
        'Every chapter has a doll family. Win all 20 of its levels to '
        'bring that family home.',
      ),
      findsOneWidget,
    );
    // The next family leads: its name, "Chapter 2 · 5 levels to go" and Play.
    expect(find.text('NEXT FAMILY'), findsOneWidget);
    expect(find.text('Chapter 2 · 5 levels to go'), findsOneWidget);
    expect(find.text('Play Level 36'), findsOneWidget);
    // The name is on the card and on its own niche.
    expect(find.text('The Sailor Family'), findsNWidgets(2));
    expect(find.text('5 levels to go'), findsOneWidget);
    // A collected family: a brass plate with its name.
    expect(find.text('The Classic Family'), findsOneWidget);
    // A locked niche: its chapter and its levels on two lines.
    expect(find.text('Chapter 3'), findsOneWidget);
    expect(find.text('Levels 41–60'), findsOneWidget);
    expect(find.text('Chapter 10'), findsOneWidget);
    expect(find.text('Levels 181–200'), findsOneWidget);
  });

  testWidgets('6.1b: nothing collected: the Classic family leads, "Chapter 1 '
      '· 19 levels to go", Play Level 2, count 0 / 10', (tester) async {
    final cubit = build(document: const SaveDocument(currentLevel: 2));
    await pumpMuseum(tester, cubit);
    expect(find.text('0 / 10'), findsOneWidget);
    expect(find.text('Chapter 1 · 19 levels to go'), findsOneWidget);
    expect(find.text('Play Level 2'), findsOneWidget);
    expect(find.text('The Classic Family'), findsNWidgets(2));
  });

  testWidgets('every niche says what it is to a screen reader', (tester) async {
    final handle = tester.ensureSemantics();
    final cubit = build(
      document: const SaveDocument(currentLevel: 36, museum: ['ch01']),
    );
    await pumpMuseum(tester, cubit);
    expect(
      find.bySemanticsLabel('The Classic Family, collected'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'The Sailor Family, next, chapter 2, 5 levels to go',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Chapter 5, levels 81 to 100, locked'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('1 of 10 families home'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a collected niche bobs 3 dp and stands still under reduce '
      'motion', (tester) async {
    final cubit = build(
      document: const SaveDocument(currentLevel: 36, museum: ['ch01']),
    );
    await pumpMuseum(tester, cubit, reduceMotion: false);
    final art = find.byType(FigurineImage).at(1);
    final before = tester.getTopLeft(art).dy;
    await tester.pump(const Duration(milliseconds: 1500));
    final moved = (tester.getTopLeft(art).dy - before).abs();
    expect(moved, lessThanOrEqualTo(MuseumTokens.cabinetCollectedIdleBob));

    final still = build(
      document: const SaveDocument(currentLevel: 36, museum: ['ch01']),
    );
    await precacheFigurines(tester);
    await pumpScreen(
      tester,
      BlocProvider<MuseumCubit>.value(value: still, child: const MuseumPage()),
      reduceMotion: true,
    );
    await still.load();
    await tester.pump();
    final artStill = find.byType(FigurineImage).at(1);
    final y = tester.getTopLeft(artStill).dy;
    await tester.pump(const Duration(milliseconds: 1500));
    expect(tester.getTopLeft(artStill).dy, y);
  });

  testWidgets(
    'frame 6.2: tapping an earned figurine with a known date shows the '
    'chapter chip, the name and "Collected · <date>"',
    (tester) async {
      final cubit = build(
        document: SaveDocument(
          currentLevel: 25,
          museum: const ['ch01'],
          museumCollected: {'ch01': LocalDate(2026, 9, 12)},
        ),
      );
      await pumpMuseum(tester, cubit);

      await tapAndSettle(tester, find.text('The Classic Family'));

      expect(find.text('Chapter 1 · Sunny Toy Shop'), findsOneWidget);
      expect(find.text('The Classic Family'), findsNWidgets(2));
      expect(find.text('Collected · Sep 12'), findsOneWidget);
    },
  );

  testWidgets(
    'frame 6.2: an earned figurine with no recorded date shows "Collected" '
    'with no date',
    (tester) async {
      final cubit = build(
        document: const SaveDocument(currentLevel: 25, museum: ['ch01']),
      );
      await pumpMuseum(tester, cubit);

      await tapAndSettle(tester, find.text('The Classic Family'));

      expect(find.text('Collected'), findsOneWidget);
      expect(find.textContaining('Collected ·'), findsNothing);
    },
  );

  testWidgets(
    'the Classic figurine (no flavor text) hides the italic line, unlike '
    'the Sailor figurine',
    (tester) async {
      final cubit = build(
        document: const SaveDocument(
          currentLevel: 45,
          museum: ['ch01', 'ch02'],
        ),
      );
      await pumpMuseum(tester, cubit);

      await tapAndSettle(tester, find.text('The Classic Family'));
      expect(
        find.text('“They keep a seashell in the smallest doll, just in case.”'),
        findsNothing,
      );
      await tapAndSettle(tester, find.byIcon(NestyIcons.close));

      await tapAndSettle(tester, find.text('The Sailor Family'));
      expect(
        find.text('“They keep a seashell in the smallest doll, just in case.”'),
        findsOneWidget,
      );
    },
  );

  testWidgets('frame 6.3: tapping the next niche shows the locked text, the '
      'chapter bar and "Play Level N", and Close dismisses it', (tester) async {
    final cubit = build(
      document: const SaveDocument(currentLevel: 36, museum: ['ch01']),
    );
    await pumpMuseum(tester, cubit);

    await tapAndSettle(tester, find.text('5 levels to go'));

    expect(
      find.text('Finish Chapter 2 to bring this family home.'),
      findsOneWidget,
    );
    expect(find.text('Chapter 2'), findsOneWidget);
    // The next-family card already shows the same generic "go play your
    // current level" action; the modal adds a second instance of it.
    expect(find.text('Play Level 36'), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(NestyIcons.close));
    expect(
      find.text('Finish Chapter 2 to bring this family home.'),
      findsNothing,
    );
  });

  testWidgets('screen readers: the figurine card is modal, with a named '
      'bar (review R11)', (tester) async {
    final handle = tester.ensureSemantics();
    final cubit = build(
      document: const SaveDocument(currentLevel: 36, museum: ['ch01']),
    );
    await pumpMuseum(tester, cubit);

    await tapAndSettle(tester, find.text('5 levels to go'));
    // The niches behind the card are out of a reader's reach (the live
    // tree: a dropped node stays cached on its render object).
    expect(
      find.semantics.byLabel(
        'The Sailor Family, next, chapter 2, 5 levels to go',
      ),
      findsNothing,
    );
    expect(
      find.semantics.byLabel('The Classic Family, collected'),
      findsNothing,
    );
    // The chapter bar says what its percent counts.
    expect(
      find.semantics.byPredicate((node) {
        final data = node.getSemanticsData();
        return data.label == 'Chapter 2' && data.value == '75%';
      }),
      findsOne,
    );
    handle.dispose();
  });

  testWidgets(
    'frame 6.3: a locked (not-next) niche shows its own chapter number',
    (tester) async {
      final cubit = build(
        document: const SaveDocument(currentLevel: 36, museum: ['ch01']),
      );
      await pumpMuseum(tester, cubit);

      await tapAndSettle(tester, find.text('Levels 41–60'));

      expect(
        find.text('Finish Chapter 3 to bring this family home.'),
        findsOneWidget,
      );
      expect(find.text('Play Level 36'), findsNWidgets(2));
    },
  );

  testWidgets('6.1c: every chapter collected: the brass disc, "Every family '
      'is home." and "Full House · all 10 families", no Play button', (
    tester,
  ) async {
    final allIds = [
      for (var n = 1; n <= 10; n++) 'ch${n.toString().padLeft(2, '0')}',
    ];
    final cubit = build(
      document: SaveDocument(currentLevel: 200, museum: allIds),
    );
    await pumpMuseum(tester, cubit);
    expect(find.text('Every family is home.'), findsOneWidget);
    expect(find.text('Full House · all 10 families'), findsOneWidget);
    expect(find.text('10 / 10'), findsOneWidget);
    expect(find.textContaining('Play Level'), findsNothing);
    expect(find.text('NEXT FAMILY'), findsNothing);
    // All ten niches are plates.
    expect(find.textContaining(' Family'), findsNWidgets(10));
  });

  // The owner asked for each locked niche's chapter and levels (D111); each
  // shows in two lines, or one short line when they wouldn't fit (narrow
  // phones, 1.3× text), whole and inside its niche.
  for (final size in [...screenSizes, const Size(402, 874)]) {
    for (final textScale in textScales) {
      testWidgets('every locked niche shows whole at '
          '${size.width.toInt()}x${size.height.toInt()} ${textScale}x', (
        tester,
      ) async {
        final cubit = build(
          document: const SaveDocument(currentLevel: 36, museum: ['ch01']),
        );
        await pumpMuseum(tester, cubit, size: size, textScale: textScale);
        final short = size.width < 360 || textScale > 1.15;
        for (var chapter = 3; chapter <= 10; chapter++) {
          final first = chapter * 20 - 19;
          final labels = short
              ? ['Ch $chapter · $first–${chapter * 20}']
              : ['Chapter $chapter', 'Levels $first–${chapter * 20}'];
          for (final label in labels) {
            final text = find.text(label);
            await tester.ensureVisible(text);
            await tester.pump();
            final paragraph = tester.renderObject<RenderParagraph>(text);
            expect(paragraph.didExceedMaxLines, isFalse, reason: label);
            final cell = find
                .ancestor(of: text, matching: find.byType(TactileSurface))
                .first;
            final textRect = tester.getRect(text);
            final cellRect = tester.getRect(cell);
            expect(textRect.left, greaterThanOrEqualTo(cellRect.left));
            expect(textRect.right, lessThanOrEqualTo(cellRect.right));
          }
        }
        expectNoLayoutErrors(tester);
      });
    }
  }

  for (final size in overflowScreenSizes) {
    for (final textScale in textScales) {
      testWidgets('no overflow at ${size.width.toInt()}x${size.height.toInt()} '
          '${textScale}x, cabinet and the 6.2/6.3 modals', (tester) async {
        final cubit = build(
          document: const SaveDocument(
            coins: 1234,
            currentLevel: 36,
            museum: ['ch01'],
          ),
        );
        await pumpMuseum(tester, cubit, size: size, textScale: textScale);
        expectNoLayoutErrors(tester);

        await tapAndSettle(tester, find.text('The Classic Family'));
        expectNoLayoutErrors(tester);
        await tapAndSettle(tester, find.byIcon(NestyIcons.close));

        await tapAndSettle(tester, find.text('5 levels to go'));
        expectNoLayoutErrors(tester);
      });
    }
  }
}
