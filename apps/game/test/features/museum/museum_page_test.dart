import 'package:flutter/material.dart';
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
  }) async {
    await precacheFigurines(tester);
    await pumpScreen(
      tester,
      BlocProvider<MuseumCubit>.value(value: cubit, child: const MuseumPage()),
      size: size,
      textScale: textScale,
    );
    await cubit.load();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('frame 6.1: the header, the collection card and the cabinet\'s '
      'earned/next/locked labels and chip', (tester) async {
    final cubit = build(
      document: const SaveDocument(
        coins: 90,
        currentLevel: 36,
        museum: ['ch01'],
      ),
    );
    await pumpMuseum(tester, cubit);

    expect(find.text('Museum'), findsOneWidget);
    expect(find.text('90'), findsOneWidget);
    expect(find.text('Collection'), findsOneWidget);
    expect(find.text('1 / 10'), findsOneWidget);
    expect(
      find.text('Chapter 2: 15 of 20 levels to The Sailor Family'),
      findsOneWidget,
    );
    expect(find.text('Classic Family'), findsOneWidget);
    expect(find.text('Sailor · soon'), findsOneWidget);
    expect(find.text('15/20'), findsOneWidget);
    expect(find.text('Chapter 3'), findsOneWidget);
    expect(find.text('Chapter 10'), findsOneWidget);
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

      await tapAndSettle(tester, find.text('Classic Family'));

      expect(find.text('Chapter 1 · Sunny Toy Shop'), findsOneWidget);
      expect(find.text('The Classic Family'), findsOneWidget);
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

      await tapAndSettle(tester, find.text('Classic Family'));

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

      await tapAndSettle(tester, find.text('Classic Family'));
      expect(
        find.text('“They keep a seashell in the smallest doll, just in case.”'),
        findsNothing,
      );
      await tapAndSettle(tester, find.byIcon(NestyIcons.close));

      await tapAndSettle(tester, find.text('Sailor Family'));
      expect(
        find.text('“They keep a seashell in the smallest doll, just in case.”'),
        findsOneWidget,
      );
    },
  );

  testWidgets('frame 6.3: tapping the next figurine shows the locked text, the '
      'chapter bar and "Play Level N", and Close dismisses it', (tester) async {
    final cubit = build(
      document: const SaveDocument(currentLevel: 36, museum: ['ch01']),
    );
    await pumpMuseum(tester, cubit);

    await tapAndSettle(tester, find.text('Sailor · soon'));

    expect(
      find.text('Finish Chapter 2 to bring this family home.'),
      findsOneWidget,
    );
    // The chapter bar's row and the cabinet's next chip both read
    // "Chapter 2" / "15/20"; the modal adds a second instance of each.
    expect(find.text('Chapter 2'), findsOneWidget);
    expect(find.text('15/20'), findsNWidgets(2));
    expect(find.text('Play Level 36'), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(NestyIcons.close));
    expect(
      find.text('Finish Chapter 2 to bring this family home.'),
      findsNothing,
    );
  });

  testWidgets(
    'frame 6.3: a locked (not-next) figurine shows its own chapter number',
    (tester) async {
      final cubit = build(
        document: const SaveDocument(currentLevel: 36, museum: ['ch01']),
      );
      await pumpMuseum(tester, cubit);

      await tapAndSettle(tester, find.text('Chapter 3'));

      expect(
        find.text('Finish Chapter 3 to bring this family home.'),
        findsOneWidget,
      );
      expect(find.text('Play Level 36'), findsOneWidget);
    },
  );

  testWidgets('every chapter collected reads "Every family is home."', (
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
  });

  for (final size in screenSizes) {
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

        await tapAndSettle(tester, find.text('Classic Family'));
        expectNoLayoutErrors(tester);
        await tapAndSettle(tester, find.byIcon(NestyIcons.close));

        await tapAndSettle(tester, find.text('Sailor · soon'));
        expectNoLayoutErrors(tester);
      });
    }
  }
}
