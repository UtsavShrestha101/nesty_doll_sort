import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_player.dart';

/// Pins every file's playback speed (LOTTIE.md; PROGRESS D48): 1x for every
/// clip at standard motion; under reduced motion one-shots play at 2x,
/// ambient clips rest on frame 0, informational loops stay 1x and confetti
/// is skipped.
void main() {
  const ambient = {
    FxId.dollIdle,
    FxId.dollWinDance,
    FxId.dollWinHop,
    FxId.fxTwinkle,
    FxId.uiIntroTowers,
    FxId.uiIntroGlass,
    FxId.uiIntroIce,
    // m7-4: the rival's portrait and the Museum's figurine rest on frame 0.
    FxId.uiRivalReact,
    FxId.uiMuseumIdle,
    // m7-4 4.17: frame 0 and a slow opacity pulse (`SpinnerPulse`).
    FxId.uiSpinner,
  };
  const informational = {
    FxId.uiHintArrow,
    FxId.uiBoosterGlow,
    FxId.uiExtraSlot,
    FxId.uiTapHand,
    FxId.uiDragHand,
  };

  test('every FxId plays at 1x and nothing is still at standard motion', () {
    for (final id in FxId.values) {
      expect(FxMotionPolicy.speedOf(id, reduced: false), 1, reason: '$id');
      expect(FxMotionPolicy.isStill(id, reduced: false), isFalse);
      expect(FxMotionPolicy.isSkipped(id, reduced: false), isFalse);
      expect(FxMotionPolicy.speedOf(id, reduced: false, segment: 'wobble'), 1);
    }
  });

  test('reduced: one-shots 2x; ambient and informational clips stay at 1x', () {
    for (final id in FxId.values) {
      final speed = FxMotionPolicy.speedOf(id, reduced: true);
      if (id == FxId.fxConfetti || ambient.contains(id)) {
        expect(speed, 1, reason: '$id');
      } else if (informational.contains(id)) {
        expect(speed, 1, reason: '$id');
        expect(FxMotionPolicy.isStill(id, reduced: true), isFalse);
      } else {
        expect(speed, 2, reason: '$id is a one-shot');
        expect(FxMotionPolicy.isStill(id, reduced: true), isFalse);
      }
    }
  });

  test('reduced: ambient clips rest on frame 0, confetti is off', () {
    for (final id in ambient) {
      expect(FxMotionPolicy.isStill(id, reduced: true), isTrue, reason: '$id');
      expect(FxMotionPolicy.isSkipped(id, reduced: true), isFalse);
    }
    expect(FxMotionPolicy.isStill(FxId.fxConfetti, reduced: true), isTrue);
    expect(FxMotionPolicy.isSkipped(FxId.fxConfetti, reduced: true), isTrue);
    for (final id in FxId.values) {
      if (id != FxId.fxConfetti) {
        expect(FxMotionPolicy.isSkipped(id, reduced: true), isFalse);
      }
    }
  });

  test('segments: the pick wobble rests, the glow pulse stays 1x', () {
    expect(
      FxMotionPolicy.isStill(FxId.dollPick, reduced: true, segment: 'wobble'),
      isTrue,
    );
    expect(FxMotionPolicy.speedOf(FxId.dollPick, reduced: true), 2);
    expect(
      FxMotionPolicy.speedOf(
        FxId.fxSelectGlow,
        reduced: true,
        segment: 'pulse',
      ),
      1,
    );
    expect(FxMotionPolicy.speedOf(FxId.fxSelectGlow, reduced: true), 2);
  });
}
