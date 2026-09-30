import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart'
    show TutorialCue, TutorialCueKind;
import 'package:nesty_game/features/gameplay/overlays/tutorial_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_board.dart';
import 'package:nesty_render/nesty_render.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/gameplay/bloc/support/bloc_fixtures.dart'
    show defaultLevel, red2, red3;
import '../features/support/screen_harness.dart';

const _tapSource = TutorialCue(
  step: 1,
  kind: TutorialCueKind.tapSource,
  from: red2,
  to: red3,
);

const _finishFamily = TutorialCue(
  step: 3,
  kind: TutorialCueKind.tapTarget,
  from: red2,
  to: red3,
);

const _drag = TutorialCue(
  step: 4,
  kind: TutorialCueKind.drag,
  from: red2,
  to: red3,
);

/// M7 overflow suite (m7-design §18 "overflow"): the tutorial overlay
/// (frames 1.3, 1.4) at the five acceptance sizes and both text scales, for
/// a tap step and a drag step. Behaviour is covered by
/// `test/features/gameplay/overlays/tutorial_overlay_test.dart`, which
/// sweeps `screenSizes`.
void main() {
  setUpAll(loadBundledFonts);

  BoardGeometry geometryFor(GameState board, Size size) {
    final callbacks = GameplayBoardCallbacks(
      onIntent: (_) {},
      onLayout: (_) {},
      onFamilyLanded: (_, _, _) {},
      onWon: () {},
      onOutOfMoves: () {},
    );
    final fake = FakeGameplayBoard(
      callbacks,
      fx: FakeFxLibrary(),
      feedback: RecordingCues(),
    )..screen = size;
    return fake.layoutFor(board)!;
  }

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      for (final MapEntry(key: name, value: cue) in {
        'a tap step': _tapSource,
        'step 3, Finish the family (STEP 3 OF 3)': _finishFamily,
        'a drag step': _drag,
      }.entries) {
        testWidgets(
          '$name fits ${size.width.toInt()}×${size.height.toInt()} at '
          '$scale× text',
          (tester) async {
            final board = GameState.initial(defaultLevel);
            await pumpScreen(
              tester,
              TutorialOverlay(
                cue: cue,
                board: board,
                geometry: geometryFor(board, size),
              ),
              size: size,
              textScale: scale,
            );
            await tester.pump(const Duration(milliseconds: 300));
            await expectAccessibleLayout(tester);
          },
        );
      }
    }
  }
}
