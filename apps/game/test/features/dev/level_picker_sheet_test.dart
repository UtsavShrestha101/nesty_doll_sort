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
/// as a tile, one tap to jump there.
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

  for (final size in screenSizes) {
    testWidgets('fits ${size.width.toInt()} wide at 1.3× text', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: LevelPickerSheet(levels: bundle(), onPick: (_) {}),
          ),
        ),
        size: size,
        textScale: 1.3,
      );
      expectNoLayoutErrors(tester);
    });
  }
}
