import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';
import '../helpers/level_fixtures.dart';

/// M7 overflow suite (m7-design §18 "overflow"): the booster bar (frame
/// 3.1) at the five acceptance sizes and both text scales. Behaviour is
/// covered by `test/features/gameplay/widgets/booster_bar_test.dart`, which
/// sweeps `screenSizes`; this file extends the same soft-stuck (every
/// badge and label showing) bar to the wider M7 grid.
void main() {
  setUpAll(loadBundledFonts);

  GameplayState state() {
    final level = levelFrom(tutorialLevelJson);
    final entry = entryFor(level);
    return GameplayState(
      play: FakeLevelResolver.campaignEntry(entry, entry.rewardCoins),
      entry: entry,
      board: GameState.initial(level),
      softStuck: true,
      freeUndosLeft: 2,
      hintsLeft: 3,
      extraSlotsLeft: 2,
    );
  }

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
        (tester) async {
          await pumpScreen(
            tester,
            Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: BoosterBar(
                  model: BoosterBarModel.of(state()),
                  library: FakeFxLibrary(),
                  onUndo: () {},
                  onHint: () {},
                  onExtraSlot: () {},
                  onRestart: () {},
                ),
              ),
            ),
            size: size,
            textScale: scale,
          );
          await expectAccessibleLayout(tester);
          for (final label in ['Undo', 'Hint', '+Slot', 'Restart']) {
            expect(find.text(label), findsOneWidget, reason: label);
          }
        },
      );
    }
  }
}
