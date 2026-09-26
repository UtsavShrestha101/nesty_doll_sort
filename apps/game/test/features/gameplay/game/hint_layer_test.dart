// The hint's dashed arc (frame 3.1, NestyBoard:206–208;
// docs/plans/m2-lottie-design.md §7): built once per hint from the layout,
// placed like the design's, and drawn from cached paths every frame.
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';

import 'support/board_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the design\'s hint frame: r0c3 to r2c0 on the MAIN board', () async {
    final h = await GameHarness.mount(mainLevel);
    await h.start();
    await h.apply(const HintShownEffect(Move('r0c3', 'r2c0')));
    final hint = h.board.hint;
    final g = h.game.geometry!;
    final s = g.slot('r0c3');
    final t = g.slot('r2c0');
    // NestyBoard:208: curve([s.cx − 16, s.dt + 66], [352, 480],
    // [t.cx + 48, t.dt + 6]) for purple3 (99 dp) over purple4.
    expect(hint.start!.dx, closeTo(s.centerX - 16, 1e-9));
    expect(hint.start!.dy, closeTo(s.dollTopY(3) + 66, 0.5));
    expect(hint.end!.dx, closeTo(t.centerX + 48, 1e-9));
    expect(hint.end!.dy, closeTo(t.dollTopY(4) + 6, 1e-9));
    expect(hint.control!.dx, closeTo(352, 6));
    expect(hint.control!.dy, closeTo(480, 6));
    expect(hint.dashes, isNotNull);
  });

  test('a same-shelf hint bulges up, over the dolls', () async {
    final h = await GameHarness.mount(tutorial);
    await h.start();
    await h.apply(const HintShownEffect(Move('r0c2', 'r0c0')));
    final hint = h.board.hint;
    expect(hint.control!.dy, lessThan(hint.start!.dy));
    expect(hint.control!.dy, lessThan(hint.end!.dy));
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
    // The curve's middle, B(½) = (a + 2c + e) / 4: orange dashes there.
    final mid = (hint.start! + hint.control! * 2 + hint.end!) / 4;
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
