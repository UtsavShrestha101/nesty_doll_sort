import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/features/dev/level_picker_sheet.dart';

import '../../core/ui/support/ui_harness.dart';
import '../../helpers/level_fixtures.dart';
import '../../helpers/test_dependencies.dart';
import '../support/screen_harness.dart';

/// The dev flavor's level picker (BACKLOG M2, plan P4): every bundled level
/// as a tile, one tap to jump there. Grouped by chapter since the owner's
/// 2026-09-28 simulator review found the 200-level bundle's single long
/// grid drawing outside the sheet and hiding the title.
void main() {
  setUpAll(loadBundledFonts);

  final level = levelFrom(tutorialLevelJson);

  /// M2's 30 levels, with the §6.6 tiers of a few.
  FakeLevelRepository bundle() => FakeLevelRepository(
    entries: [
      for (var order = 1; order <= 30; order++)
        entryFor(
          level,
          order: order,
          tier: switch (order) {
            6 || 16 => Tier.hard,
            10 || 20 => Tier.superhard,
            _ => Tier.easy,
          },
        ),
    ],
  );

  /// The M7 200-level bundle: 10 chapters of 20 (spec §7.1), `chNN`.
  FakeLevelRepository bundle200() => FakeLevelRepository(
    entries: [
      for (var order = 1; order <= 200; order++)
        entryFor(
          level,
          order: order,
          tier: order % 20 == 0 ? Tier.superhard : Tier.easy,
          chapterId:
              'ch${(((order - 1) ~/ 20) + 1).toString().padLeft(2, '0')}',
        ),
    ],
  );

  // Runs first: nothing has set the flavor in this isolate yet.
  test('only the dev flavor has the picker', () {
    expect(LevelPickerSheet.isAvailable, isFalse, reason: 'no flavor set');
    FlavorConfig(flavor: Flavor.dev, values: testFlavorValues);
    expect(LevelPickerSheet.isAvailable, isTrue);
  });

  testWidgets('one tile per bundled level, 1 to 30; a tap picks it', (
    tester,
  ) async {
    final picked = <int>[];
    await pumpScreen(
      tester,
      Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: LevelPickerSheet(levels: bundle(), onPick: picked.add),
        ),
      ),
    );
    expect(find.text('Jump to a level'), findsOneWidget);
    for (final n in [1, 10, 30]) {
      expect(find.text('$n'), findsOneWidget, reason: '$n');
    }
    expect(find.text('31'), findsNothing);
    expect(find.bySemanticsLabel('Level 10 · Super Hard'), findsOneWidget);
    await tester.ensureVisible(find.text('17'));
    await tester.tap(find.text('17'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(picked, [17]);
  });

  testWidgets('show() closes the sheet, then reports the pick', (tester) async {
    final picked = <int>[];
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => LevelPickerSheet.show(
                context,
                levels: bundle(),
                onPick: picked.add,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(LevelPickerSheet), findsOneWidget);
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();
    expect(find.byType(LevelPickerSheet), findsNothing);
    expect(picked, [3]);

    // Dismissed without a pick: nothing is reported.
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.byType(LevelPickerSheet), findsNothing);
    expect(picked, [3]);
  });

  testWidgets('the close button dismisses without a pick', (tester) async {
    final picked = <int>[];
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => LevelPickerSheet.show(
                context,
                levels: bundle(),
                onPick: picked.add,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(LevelPickerSheet), findsNothing);
    expect(picked, isEmpty);
  });

  group('the 200-level bundle (owner 2026-09-28 simulator review)', () {
    testWidgets('groups into chapter sections; the title and close stay '
        'visible; a tap on a grouped tile still picks it', (tester) async {
      final picked = <int>[];
      await pumpScreen(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: LevelPickerSheet(levels: bundle200(), onPick: picked.add),
          ),
        ),
      );
      expect(find.text('Jump to a level'), findsOneWidget);
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      expect(find.text('Chapter 1 · Levels 1–20'), findsOneWidget);
      expect(find.text('Chapter 2 · Levels 21–40'), findsOneWidget);
      expect(find.text('Chapter 10 · Levels 181–200'), findsOneWidget);
      expect(find.text('201'), findsNothing);
      expectNoLayoutErrors(tester);

      await tester.ensureVisible(find.text('185'));
      await tester.tap(find.text('185'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(picked, [185]);
    });

    testWidgets('opening near the current level scrolls its tile into '
        'view without the player scrolling first', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: LevelPickerSheet(
              levels: bundle200(),
              currentOrder: 155,
              onPick: (_) {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      final tile = tester.getRect(find.text('155'));
      expect(
        tile.top,
        inInclusiveRange(0, screen.height),
        reason:
            'level 155 should already be on screen, not still scrolled '
            'up near level 1',
      );
      expectNoLayoutErrors(tester);
    });

    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        testWidgets(
          'the title stays visible and the grid stays inside the sheet at '
          '${size.width.toInt()}×${size.height.toInt()} @$scale×',
          (tester) async {
            await pumpScreen(
              tester,
              Scaffold(
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: LevelPickerSheet(levels: bundle200(), onPick: (_) {}),
                ),
              ),
              size: size,
              textScale: scale,
            );
            await tester.pump(const Duration(milliseconds: 50));

            expect(find.text('Jump to a level'), findsOneWidget);
            final title = tester.getRect(find.text('Jump to a level'));
            final sheet = tester.getRect(find.byType(LevelPickerSheet));
            // Bounded height: the sheet never grows past the screen, and
            // the title sits inside it, never covered by a tile drawn over
            // it (it would still be found above, but a real overflow bug
            // also throws, which expectNoLayoutErrors below would catch).
            expect(sheet.top, greaterThanOrEqualTo(0));
            expect(sheet.bottom, lessThanOrEqualTo(size.height));
            expect(title.top, greaterThanOrEqualTo(sheet.top));
            expect(title.bottom, lessThanOrEqualTo(sheet.bottom));
            expectNoLayoutErrors(tester);
          },
        );
      }
    }
  });
}
