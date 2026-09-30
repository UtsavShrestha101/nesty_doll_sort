// The hint's dashed arc (tokens v3 `layout.hintArc`, E.15;
// docs/plans/m2-lottie-design.md §7): built once per hint from the layout,
// a cubic over the dolls, and drawn from cached paths every frame.
import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/components/hint_layer.dart';
import 'package:nesty_render/nesty_render.dart' show HintArcTokens;

import 'support/board_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'the design\'s hint arc (E.15): r0c3 to r2c0 on the MAIN board',
    () async {
      final h = await GameHarness.mount(mainLevel);
      await h.start();
      await h.apply(const HintShownEffect(Move('r0c3', 'r2c0')));
      final hint = h.board.hint;
      final g = h.game.geometry!;
      final s = g.slot('r0c3');
      final t = g.slot('r2c0');
      final k = g.scale;
      // A cubic from 8 dp above the source doll (the arrow's tip) to 8 dp
      // above the target doll, both handles 56 dp above the higher end (the
      // rows differ), on the ends' own x.
      expect(hint.start!.dx, closeTo(s.centerX, 1e-9));
      expect(hint.start!.dy, closeTo(s.dollTopY(3) - 8 * k, 1e-9));
      expect(hint.end!.dx, closeTo(t.centerX, 1e-9));
      expect(hint.end!.dy, closeTo(t.dollTopY(4) - 8 * k, 1e-9));
      final top = math.min(hint.start!.dy, hint.end!.dy) - 56 * k;
      expect(hint.control1!.dx, closeTo(hint.start!.dx, 1e-9));
      expect(hint.control1!.dy, closeTo(top, 1e-9));
      expect(hint.control2!.dx, closeTo(hint.end!.dx, 1e-9));
      expect(hint.control2!.dy, closeTo(top, 1e-9));
      expect(hint.dashes, isNotNull);
    },
  );

  test(
    'a same-shelf hint rises 42 dp above the ends, over the dolls',
    () async {
      final h = await GameHarness.mount(tutorial);
      await h.start();
      await h.apply(const HintShownEffect(Move('r0c2', 'r0c0')));
      final hint = h.board.hint;
      final k = h.game.geometry!.scale;
      final top = math.min(hint.start!.dy, hint.end!.dy) - 42 * k;
      expect(hint.control1!.dy, closeTo(top, 1e-9));
      expect(hint.control2!.dy, closeTo(top, 1e-9));
      expect(hint.control1!.dy, lessThan(hint.start!.dy));
      expect(hint.control2!.dy, lessThan(hint.end!.dy));
    },
  );

  test('the look: 3 dp #F2893B dashes, 6 on and 6 off (HintArcTokens)', () {
    expect(HintLayer.arcWidth, 3);
    expect(HintLayer.arcColor, const Color(0xFFF2893B));
    // Round caps add half a width at each end: the path's dash and gap are
    // adjusted so the pattern reads 6 on, 6 off.
    expect(HintLayer.dash + HintLayer.arcWidth, HintArcTokens.dashOn);
    expect(HintLayer.gap - HintLayer.arcWidth, HintArcTokens.dashOff);
  });

  test('built once per hint; renders reuse it; cleared by null', () async {
    final h = await GameHarness.mount(tutorial);
    await h.start();
    await h.apply(const HintShownEffect(Move('r1c1', 'r0c2')));
    final hint = h.board.hint;
    final dashes = hint.dashes;
    expect(hint.builds, 1);
    await h.render();
    await h.render();
    await h.tick(16);
    expect(hint.builds, 1);
    expect(hint.dashes, same(dashes));
    final snap = await h.render();
    // The curve's middle, B(½) = (a + 3c₁ + 3c₂ + e) / 8: orange dashes there.
    final mid =
        (hint.start! + hint.control1! * 3 + hint.control2! * 3 + hint.end!) / 8;
    var orange = 0;
    for (var dx = -16; dx <= 16; dx++) {
      for (var dy = -16; dy <= 16; dy++) {
        final (r, g, b, a) = snap.at(
          (mid.dx + dx).round().clamp(0, snap.width - 1),
          (mid.dy + dy).round().clamp(0, snap.height - 1),
        );
        if (a > 200 && r > 220 && g > 110 && g < 160 && b < 90) orange++;
      }
    }
    expect(orange, greaterThan(0));
    await h.apply(const HintClearedEffect());
    expect(hint.dashes, isNull);
    expect(hint.move, isNull);
  });
}
