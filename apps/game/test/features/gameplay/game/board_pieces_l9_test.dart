import 'dart:math' as math;
// The hint arrow, the hint arc, the glow ring and the +1 Slot stand on
// Level 9's layout (3 shelves of 4/4/3, then two extra slots), drawn by the
// real board with the shipped Lottie files through the game's own
// `LevelSkinImages`, pinned to `BoardLayout`'s rects (frames 3.1 and 3.6,
// LOTTIE.md v3 `ui_hint_arrow`, `fx_select_glow`, `ui_extra_slot`).
//
// The owner's device showed these at a third of their size and off their
// slots: v3 declares the board pieces at 3× with 33.33 % layers, and the
// compensation took the skin's per-box raster scale for a per-asset-px one.
// The sprites here are solid rectangles inset in their design boxes, so a
// piece's drawn pixels have exact bounds and the crop origin is exercised.
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/level_skin_images.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/components/hint_layer.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_render/nesty_render.dart';

import 'board_render_test.dart' show RecordingRenderer;
import 'support/board_fixtures.dart';

/// Level 9 of the bundle (`assets/levels/bundle.json`, L0009).
final Level level9 = levelFrom('''
{
  "schemaVersion": 1,
  "id": "L0009",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["pink1"]},
      {"type": "open", "nest": ["brown3"]},
      {"type": "open", "nest": ["teal2", "teal1"]},
      {"type": "open", "nest": ["red1"]} ],
    [ {"type": "open", "nest": ["brown2"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": ["pink3"]},
      {"type": "open", "nest": ["teal3"]} ],
    [ {"type": "open", "nest": ["red3", "red2"]},
      {"type": "open", "nest": ["pink2"]},
      {"type": "open", "nest": ["brown1"]} ]
  ]
}
''');

// Pure colours no doll, plank or background uses.
const _magenta = 'FF00FF';
const _cyan = '00FFFF';
const _green = '00FF00';

/// A solid [color] rectangle inset by ([dx], [dy]) in a [w]×[h] box.
String _solid(double w, double h, double dx, double dy, String color) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $w $h" '
    'width="$w" height="$h"><rect x="$dx" y="$dy" width="${w - 2 * dx}" '
    'height="${h - 2 * dy}" fill="#$color"/></svg>';

// The insets, in design (reference) units of each piece's box.
const _arrowInset = Offset(4, 5); // hint-arrow 40×50
const _glowInset = Offset(6, 5); // glow-ring 116×52
const _padInset = Offset(5, 4); // extra-slot 90×34

bool _isMagenta(int r, int g, int b, int a) =>
    a > 250 && r > 250 && g < 6 && b > 250;
bool _isCyan(int r, int g, int b, int a) =>
    a > 250 && r < 6 && g > 250 && b > 250;
bool _isGreen(int r, int g, int b, int a) =>
    a > 250 && r < 6 && g > 250 && b < 6;

/// The pad while it pulses: its opacity dips to 80 % at frame 72.
bool _isPulsingGreen(int r, int g, int b, int a) =>
    a > 150 && g > r + 100 && g > b + 100;

/// The level's art as the skin service serves it: the real
/// `LevelSkinImages` over blob doll parts and solid board sprites. The rest
/// sprites are only recorded (the pieces under them stay measurable).
final class _L9Skin implements LevelSkin {
  _L9Skin(this.parts, this.sprites)
    : images = LevelSkinImages(parts: parts, sprites: sprites);

  final DollPartSet parts;

  @override
  final BoardSprites sprites;

  @override
  final LevelSkinImages images;

  final RecordingRenderer renderer = RecordingRenderer();

  @override
  DollRenderer get restRenderer => renderer;

  @override
  void dispose() {
    images.dispose();
    sprites.dispose();
    parts.dispose();
  }
}

const _dpr = 2.0;

Future<BoardSpriteLibrary> _library() => BoardSpriteLibrary.fromSvgs({
  BoardSprite.slotStand: _solid(90, 34, 0, 0, '8B5A2B'),
  BoardSprite.hintArrow: _solid(
    40,
    50,
    _arrowInset.dx,
    _arrowInset.dy,
    _magenta,
  ),
  BoardSprite.glowRing: _solid(116, 52, _glowInset.dx, _glowInset.dy, _cyan),
  BoardSprite.extraSlot: _solid(90, 34, _padInset.dx, _padInset.dy, _green),
});

/// Level 9 mounted with the board files, its art prepared for the layout.
Future<(GameHarness, _L9Skin)> _mount({bool extraSlotFile = true}) async {
  final h = await GameHarness.mount(
    level9,
    fx: await libraryWith([
      for (final id in boardFiles)
        if (extraSlotFile || id != FxId.uiExtraSlot) id,
    ]),
  );
  await h.start();
  final library = await _library();
  addTearDown(library.dispose);
  final sprites = BoardSprites(library);
  await sprites.prepare(
    h.game.geometry!,
    devicePixelRatio: _dpr,
    also: const [BoardSprite.extraSlot],
  );
  final skin = _L9Skin(
    blobParts(const [
      DollColor.pink,
      DollColor.brown,
      DollColor.teal,
      DollColor.red,
    ]),
    sprites,
  );
  h.game.skin = skin;
  await h.tick();
  return (h, skin);
}

/// [rect] deflated by [inset] × [fs] and scaled by [scale] about its
/// centre: where a solid sprite inset in its box draws at a pulse's scale.
Rect _expected(Rect rect, Offset inset, double fs, {double scale = 1}) {
  final inner = Rect.fromLTRB(
    rect.left + inset.dx * fs,
    rect.top + inset.dy * fs,
    rect.right - inset.dx * fs,
    rect.bottom - inset.dy * fs,
  );
  return Rect.fromCenter(
    center: inner.center,
    width: inner.width * scale,
    height: inner.height * scale,
  );
}

/// The bounds of [test]'s pixels in [snap] (at [_dpr]), in logical px.
Rect? _bounds(
  Snapshot snap,
  bool Function(int r, int g, int b, int a) test, {
  Rect? within,
}) {
  final box = snap.boundsWhere((x, y) {
    if (within != null &&
        !within.contains(Offset((x + 0.5) / _dpr, (y + 0.5) / _dpr))) {
      return false;
    }
    final (r, g, b, a) = snap.at(x, y);
    return test(r, g, b, a);
  });
  if (box == null) return null;
  return Rect.fromLTRB(
    box.left / _dpr,
    box.top / _dpr,
    box.right / _dpr,
    box.bottom / _dpr,
  );
}

void _expectRect(Rect? actual, Rect expected, String what) {
  expect(actual, isNotNull, reason: '$what is drawn');
  // One device pixel of filtering at each edge.
  const tolerance = 1.0;
  expect(actual!.left, closeTo(expected.left, tolerance), reason: '$what L');
  expect(actual.top, closeTo(expected.top, tolerance), reason: '$what T');
  expect(actual.right, closeTo(expected.right, tolerance), reason: '$what R');
  expect(actual.bottom, closeTo(expected.bottom, tolerance), reason: '$what B');
}

/// Seeks the live clip of [fx] on [slotId] to [frame].
void _seek(GameHarness h, FxId fx, String slotId, double frame) {
  final clip = h.board.fx.liveClips.singleWhere(
    (c) => c.fx == fx && c.slotId == slotId,
  );
  h.board.fx.componentOf(clip.id)!.drawable.player.seek(frame);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the layout: 3 shelves of 4/4/3 slots', () async {
    final (h, _) = await _mount();
    final g = h.game.geometry!;
    expect(g.shelves.map((s) => s.slots.length), [4, 4, 3]);
  });

  group('Hint brown3 r0c1 → brown2 r1c0 (frame 3.1)', () {
    late GameHarness h;
    late BoardGeometry g;
    late SlotGeometry source;
    late SlotGeometry target;

    setUp(() async {
      (h, _) = await _mount();
      g = h.game.geometry!;
      source = g.slot('r0c1');
      target = g.slot('r1c0');
      await h.apply(const HintShownEffect(Move('r0c1', 'r1c0')));
    });

    test('ui_hint_arrow: the 40×50 arrow over the source, bobbing 10 up at '
        'frame 27, clear of the HUD', () async {
      final fs = source.furnitureScale;
      _seek(h, FxId.uiHintArrow, 'r0c1', 0);
      final rest = _bounds(await h.render(pixelRatio: _dpr), _isMagenta);
      final box = source.hintArrowRect(3);
      expect(box.center.dx, source.hintArrowCenterX(3));
      expect(box.center.dy, closeTo(source.hintArrowCenterY(3), 1e-9));
      expect(box.width, closeTo(40 * fs, 1e-9));
      _expectRect(rest, _expected(box, _arrowInset, fs), 'arrow');

      _seek(h, FxId.uiHintArrow, 'r0c1', 27);
      final bob = _bounds(await h.render(pixelRatio: _dpr), _isMagenta);
      _expectRect(
        bob,
        _expected(box, _arrowInset, fs).translate(0, -10 * fs),
        'arrow at the top of its bob',
      );

      // brown3 is taller than any top-row doll in the frames: at the top of
      // its bob the designed arrow (source cx, doll top − 33) would reach
      // the pause row and the counter pill (the owner's report). It steps
      // left off the pill, within a quarter pitch, and down under the row.
      const safeTop = 59.0;
      final top = box.top - 10 * fs;
      expect(top, greaterThanOrEqualTo(safeTop + 51 + 4 - 1e-9));
      expect(box.right, lessThanOrEqualTo(390 / 2 - 35 - 4 + 1e-9));
      expect(
        source.centerX - box.center.dx,
        inInclusiveRange(1, source.pitch / 4),
      );
      expect(
        box.center.dy - (source.dollTopY(3) - 33 * fs),
        inInclusiveRange(1, 16 * fs),
      );
    });

    test('fx_select_glow on the target: the 116×52 ring centred at (target '
        'cx, surface − 2), at its pulse scale', () async {
      final fs = target.furnitureScale;
      final ring = target.glowRingRect;
      expect(ring.center.dx, target.centerX);
      expect(ring.center.dy, closeTo(target.surfaceY - 2 * fs, 1e-9));
      expect(ring.width, closeTo(116 * fs, 1e-9));
      // Frame 55: glow_pulse at 104 %, the ring fully opaque.
      _seek(h, FxId.fxSelectGlow, 'r1c0', 55);
      final drawn = _bounds(await h.render(pixelRatio: _dpr), _isCyan);
      _expectRect(drawn, _expected(ring, _glowInset, fs, scale: 1.04), 'ring');
      // Nowhere near the source or the empty r1c1.
      expect(drawn!.center.dx, closeTo(target.centerX, 1));
    });

    test('the arc: the design cubic from 8 dp above the source doll to 8 dp '
        'above the target\'s head, the arrowhead dropping into it', () async {
      final hint = h.board.hint;
      final s = g.scale;
      expect(hint.start!.dx, closeTo(source.centerX, 1e-9));
      expect(hint.start!.dy, closeTo(source.dollTopY(3) - 8 * s, 1e-9));
      expect(hint.end!.dx, closeTo(target.centerX, 1e-9));
      expect(hint.end!.dy, closeTo(target.dollTopY(2) - 8 * s, 1e-9));
      // Both handles rise 56 dp above the higher end (the shelves differ).
      final top = math.min(hint.start!.dy, hint.end!.dy) - 56 * s;
      expect(hint.control1!.dy, closeTo(top, 1e-9));
      expect(hint.control2!.dy, closeTo(top, 1e-9));
      expect(hint.control1!.dx, closeTo(hint.start!.dx, 1e-9));
      expect(hint.control2!.dx, closeTo(hint.end!.dx, 1e-9));
      // Its last tangent is straight down, into the head.
      final tangent = hint.end! - hint.control2!;
      expect(tangent.dx, closeTo(0, 1e-9));
      expect(tangent.dy, greaterThan(0));
      // Drawn: orange dashes near the start, the end and the middle.
      final snap = await h.render(pixelRatio: _dpr);
      bool orange(int r, int g, int b, int a) =>
          a > 200 && r > 220 && g > 110 && g < 160 && b < 90;
      // (The very start hides behind the hint arrow, which sits on the arc's
      // first stretch.)
      for (final (t, what) in const [(0.3, 'start'), (0.5, 'middle')]) {
        final a = hint.start!, c1 = hint.control1!;
        final c2 = hint.control2!, e = hint.end!;
        final u = 1 - t;
        final p =
            a * (u * u * u) +
            c1 * (3 * u * u * t) +
            c2 * (3 * u * t * t) +
            e * (t * t * t);
        final near = _bounds(
          snap,
          orange,
          within: Rect.fromCircle(center: p, radius: 12 * s),
        );
        expect(near, isNotNull, reason: 'dashes near the $what');
      }
    });
  });

  group('+1 Slot twice on Level 9 (frame 3.6)', () {
    late GameHarness h;
    late _L9Skin skin;
    late BoardGeometry g;

    Future<void> addTwo() async {
      await h.apply(ExtraSlotAddedEffect(h.session.addExtraSlot()!));
      await h.apply(ExtraSlotAddedEffect(h.session.addExtraSlot()!));
      await h.run(2 * BoardLayoutConstants.extraSlotRepitchMs + 50);
      g = h.layouts.last;
      expect(h.game.geometry, same(g));
      // The page prepares the art again for the new layout (§4).
      await skin.sprites.prepare(
        g,
        devicePixelRatio: _dpr,
        also: const [BoardSprite.extraSlot],
      );
    }

    test(
      'both new stands are the 90×34 pad on the bottom shelf, pulsing '
      '100 % → 104 % → 96 % → 100 % about the stand centre, no pips',
      () async {
        (h, skin) = await _mount();
        await addTwo();
        expect(g.shelves.last.slots.map((s) => s.id).toList().sublist(3), [
          'x0',
          'x1',
        ]);
        for (final id in const ['x0', 'x1']) {
          final slot = g.slot(id);
          expect(slot.kind, SlotShapeKind.extra);
          expect(slot.standRect.width, closeTo(90 * slot.furnitureScale, 1e-9));
          _seek(h, FxId.uiExtraSlot, id, 24);
        }
        final peak = await h.render(pixelRatio: _dpr);
        for (final id in const ['x0', 'x1']) {
          final slot = g.slot(id);
          _expectRect(
            _bounds(peak, _isPulsingGreen, within: slot.standRect.inflate(1)),
            _expected(
              slot.standRect,
              _padInset,
              slot.furnitureScale,
              scale: 1.04,
            ),
            '$id pad at its peak',
          );
        }

        // The trough (frame 72): 96 %.
        for (final id in const ['x0', 'x1']) {
          _seek(h, FxId.uiExtraSlot, id, 72);
        }
        final trough = await h.render(pixelRatio: _dpr);
        for (final id in const ['x0', 'x1']) {
          final slot = g.slot(id);
          _expectRect(
            _bounds(trough, _isPulsingGreen, within: slot.standRect.inflate(1)),
            _expected(
              slot.standRect,
              _padInset,
              slot.furnitureScale,
              scale: 0.96,
            ),
            '$id pad at its trough',
          );
        }

        // The loop's rest pose (frames 0 and 96, the file's `rest` marker):
        // the static pad's own 100 % scale, opaque.
        for (final id in const ['x0', 'x1']) {
          _seek(h, FxId.uiExtraSlot, id, 0);
        }
        final rest = await h.render(pixelRatio: _dpr);
        for (final id in const ['x0', 'x1']) {
          final slot = g.slot(id);
          _expectRect(
            _bounds(
              rest,
              (r, g, b, a) => a > 250 && g > r + 100 && g > b + 100,
              within: slot.standRect.inflate(1),
            ),
            _expected(slot.standRect, _padInset, slot.furnitureScale),
            '$id pad at rest',
          );
        }
      },
    );

    test('the loop opens on its rest frame 0, the static pad\'s own pose: '
        'the hand-off has no pop (E.21, D184)', () async {
      (h, skin) = await _mount();
      await h.apply(ExtraSlotAddedEffect(h.session.addExtraSlot()!));
      await h.run(BoardLayoutConstants.extraSlotRepitchMs * 1.0);
      g = h.layouts.last;
      await skin.sprites.prepare(
        g,
        devicePixelRatio: _dpr,
        also: const [BoardSprite.extraSlot],
      );

      final clip = h.board.fx.liveClips.singleWhere(
        (c) => c.fx == FxId.uiExtraSlot && c.slotId == 'x0',
      );
      final frame = h.board.fx.componentOf(clip.id)!.drawable.player.frame;
      expect(FxTiming.extraSlotRestFrame, 0);
      expect(frame, lessThan(2), reason: 'a frame or so into the loop');
      expect(h.board.scene.slot('x0')!.pulses, 1);

      final slot = g.slot('x0');
      final snap = await h.render(pixelRatio: _dpr);
      _expectRect(
        _bounds(
          snap,
          (r, g, b, a) => a > 250 && g > r + 100 && g > b + 100,
          within: slot.standRect.inflate(1),
        ),
        _expected(slot.standRect, _padInset, slot.furnitureScale),
        'x0 pad at the hand-off, the static pad\'s 100 % scale and opacity',
      );
    });

    test('a doll placed on an extra slot stops the pulse (a 150 ms settle '
        'onto the rest frame), and the pulse restarts from frame 0 once the '
        'pad is empty again (E.16)', () async {
      (h, skin) = await _mount();
      await addTwo();
      // Let the loop run a while, so it isn't on its rest frame.
      await h.run(700);
      await h.select('r2c2');
      await h.move('r2c2', 'x0'); // brown1 onto the first extra stand
      final slot = g.slot('x0');
      expect(h.board.scene.slot('x0')!.pulses, 1, reason: 'still flying');
      await h.run(1200);
      // The pad under the doll is the static one, in the same pose.
      expect(h.board.scene.slot('x0')!.pulses, 0);
      expect(
        h.board.fx.liveClips.where(
          (c) => c.fx == FxId.uiExtraSlot && c.slotId == 'x0',
        ),
        isEmpty,
      );
      // The other pad keeps pulsing.
      expect(h.board.scene.slot('x1')!.pulses, 1);
      skin.renderer.painted.clear();
      final snap = await h.render(pixelRatio: _dpr);
      final doll = skin.renderer.painted.singleWhere(
        (p) => p.baseX == slot.centerX,
      );
      expect(doll.color, DollColor.brown);
      expect(doll.baseY, closeTo(slot.surfaceY, 1e-9));
      expect(doll.height, closeTo(g.dollHeight(1), 1e-9));
      _expectRect(
        _bounds(snap, _isGreen, within: slot.standRect.inflate(1)),
        _expected(slot.standRect, _padInset, slot.furnitureScale),
        'x0 pad under the doll, at rest',
      );
      // The doll's base sits on the stand's top face, inside the pad.
      expect(
        slot.surfaceY,
        inInclusiveRange(slot.standRect.top, slot.standRect.bottom),
      );

      // The doll leaves: the pad is empty, its pulse starts again at frame 0.
      await h.select('x0');
      await h.move('x0', 'r2c2');
      expect(h.board.scene.slot('x0')!.pulses, 1);
      final clip = h.board.fx.liveClips.singleWhere(
        (c) => c.fx == FxId.uiExtraSlot && c.slotId == 'x0',
      );
      final frame = h.board.fx.componentOf(clip.id)!.drawable.player.frame;
      expect(frame, lessThan(4));
    });

    test('without ui_extra_slot (rule 3) the stand is the static pad, '
        'exactly in its box', () async {
      (h, skin) = await _mount(extraSlotFile: false);
      await addTwo();
      final snap = await h.render(pixelRatio: _dpr);

      for (final id in const ['x0', 'x1']) {
        final slot = g.slot(id);
        expect(h.board.scene.slot(id)!.pulses, 0);
        _expectRect(
          _bounds(snap, _isGreen, within: slot.standRect.inflate(1)),
          _expected(slot.standRect, _padInset, slot.furnitureScale),
          '$id static pad',
        );
      }
    });
  });

  test('HintLayer.arrivalSide: from the source\'s side; within a column, '
      'from the board\'s middle', () {
    expect(HintLayer.arrivalSide(sourceX: 300, targetX: 100, middleX: 195), 1);
    expect(HintLayer.arrivalSide(sourceX: 100, targetX: 300, middleX: 195), -1);
    expect(HintLayer.arrivalSide(sourceX: 144, targetX: 144, middleX: 195), 1);
    expect(HintLayer.arrivalSide(sourceX: 246, targetX: 246, middleX: 195), -1);
  });

  test('a hint within one column on Level 9 (r0c1 → r1c1, the empty '
      'stand): the arc bows to the side it arrives from and ends over the '
      'head of the doll that will stand there', () async {
    final (h, _) = await _mount();
    await h.apply(const HintShownEffect(Move('r0c1', 'r1c1')));
    final g = h.game.geometry!;
    final target = g.slot('r1c1');
    final hint = h.board.hint;
    expect(target.centerX, closeTo(g.slot('r0c1').centerX, 1e-9));
    // brown3 will stand there: its head, not the empty stand's top.
    expect(hint.end!.dy, closeTo(target.dollTopY(3) - 8 * g.scale, 1e-9));
    expect(hint.end!.dx, closeTo(target.centerX, 1e-9));
    // One column: the handles bow sideways (24 dp), so the arch doesn't fold
    // onto itself.
    expect(
      hint.control1!.dx - hint.start!.dx,
      closeTo(hint.control2!.dx - hint.end!.dx, 1e-9),
    );
    expect(
      (hint.control1!.dx - hint.start!.dx).abs(),
      closeTo(24 * g.scale, 1e-9),
    );
    expect(
      h.board.fx.liveClips
          .where((c) => c.fx == FxId.fxSelectGlow)
          .single
          .slotId,
      'r1c1',
    );
  });

  test('a small source doll: the arc starts 8 dp above it (pink1 r0c0 → '
      'pink2 r2c1)', () async {
    final (h, _) = await _mount();
    await h.apply(const HintShownEffect(Move('r0c0', 'r2c1')));
    final g = h.game.geometry!;
    final source = g.slot('r0c0');
    final target = g.slot('r2c1');
    final hint = h.board.hint;
    expect(hint.start!.dy, closeTo(source.dollTopY(1) - 8 * g.scale, 1e-9));
    expect(hint.start!.dx, closeTo(source.centerX, 1e-9));
    expect(hint.end!.dx, closeTo(target.centerX, 1e-9));
    expect(hint.end!.dy, closeTo(target.dollTopY(2) - 8 * g.scale, 1e-9));
  });

  test('FxClipPurpose of the hint clips', () async {
    final (h, _) = await _mount();
    await h.apply(const HintShownEffect(Move('r0c1', 'r1c0')));
    expect(
      {for (final c in h.board.fx.liveClips) c.fx: c.purpose},
      {
        FxId.uiHintArrow: FxClipPurpose.hintArrow,
        FxId.fxSelectGlow: FxClipPurpose.hintGlow,
      },
    );
    expect(FxImageSlot.hintArrow.declaredWidth, 40);
  });
}
