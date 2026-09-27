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

    test('the arc: from over the source doll to beside the target\'s head, '
        'the arrowhead pointing into it', () async {
      final hint = h.board.hint;
      final s = g.scale;
      // The source is right of the target: the design's case, `curve([s.cx
      // − 16, s.dt + 66], c, [t.cx + 48, t.dt + 6])` with brown3 (size 3)
      // and brown2 (size 2).
      expect(source.centerX, greaterThan(target.centerX));
      expect(hint.start!.dx, closeTo(source.centerX - 16 * s, 1e-9));
      // 66 below brown3's top: its upper body, not its belly (a 150-unit
      // doll here; the design's was 99, where 66 is two thirds).
      expect(source.dollHeight(3) * 2 / 3, greaterThan(66 * s));
      expect(hint.start!.dy, closeTo(source.dollTopY(3) + 66 * s, 1e-9));
      expect(hint.end!.dx, closeTo(target.centerX + 48 * s, 1e-9));
      expect(hint.end!.dy, closeTo(target.dollTopY(2) + 6 * s, 1e-9));
      // It bulges toward the side it arrives from, so its last tangent
      // heads left, into the target's head, not toward the empty r1c1.
      final tangent = hint.end! - hint.control!;
      expect(tangent.dx, lessThan(0));
      expect(tangent.dy, greaterThan(0));
      expect(
        hint.control!.dx,
        greaterThan((hint.start!.dx + hint.end!.dx) / 2),
      );
      // Drawn: orange dashes near the start, the end and the middle.
      final snap = await h.render(pixelRatio: _dpr);
      bool orange(int r, int g, int b, int a) =>
          a > 200 && r > 220 && g > 110 && g < 160 && b < 90;
      for (final (t, what) in const [(0.1, 'start'), (0.5, 'middle')]) {
        final a = hint.start!, c = hint.control!, e = hint.end!;
        final p = a * ((1 - t) * (1 - t)) + c * (2 * t * (1 - t)) + e * (t * t);
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

    test('both new stands are the 90×34 pad on the bottom shelf, pulsing '
        '96 % ↔ 104 % about the stand centre, no pips', () async {
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
        _seek(h, FxId.uiExtraSlot, id, 48);
      }
      final peak = await h.render(pixelRatio: _dpr);
      for (final id in const ['x0', 'x1']) {
        final slot = g.slot(id);
        _expectRect(
          _bounds(peak, _isGreen, within: slot.standRect.inflate(1)),
          _expected(
            slot.standRect,
            _padInset,
            slot.furnitureScale,
            scale: 1.04,
          ),
          '$id pad at its peak',
        );
      }

      // The loop's rest pose (frames 0 and 96): 96 %, at 75 % opacity.
      for (final id in const ['x0', 'x1']) {
        _seek(h, FxId.uiExtraSlot, id, 0);
      }
      final rest = await h.render(pixelRatio: _dpr);
      for (final id in const ['x0', 'x1']) {
        final slot = g.slot(id);
        _expectRect(
          _bounds(
            rest,
            (r, g, b, a) => a > 150 && g > r + 100 && g > b + 100,
            within: slot.standRect.inflate(1),
          ),
          _expected(
            slot.standRect,
            _padInset,
            slot.furnitureScale,
            scale: 0.96,
          ),
          '$id pad at rest',
        );
      }
    });

    test('a doll placed on an extra slot stands on its surface, the pad '
        'still pulsing under it', () async {
      (h, skin) = await _mount();
      await addTwo();
      await h.select('r2c2');
      await h.move('r2c2', 'x0'); // brown1 onto the first extra stand
      await h.run(600);
      final slot = g.slot('x0');
      skin.renderer.painted.clear();
      _seek(h, FxId.uiExtraSlot, 'x0', 48);
      final snap = await h.render(pixelRatio: _dpr);
      final doll = skin.renderer.painted.singleWhere(
        (p) => p.baseX == slot.centerX,
      );
      expect(doll.color, DollColor.brown);
      expect(doll.baseY, closeTo(slot.surfaceY, 1e-9));
      expect(doll.height, closeTo(g.dollHeight(1), 1e-9));
      expect(h.board.scene.slot('x0')!.pulses, 1);
      _expectRect(
        _bounds(snap, _isGreen, within: slot.standRect.inflate(1)),
        _expected(slot.standRect, _padInset, slot.furnitureScale, scale: 1.04),
        'x0 pad under the doll',
      );
      // The doll's base sits on the stand's top face, inside the pad.
      expect(
        slot.surfaceY,
        inInclusiveRange(slot.standRect.top, slot.standRect.bottom),
      );
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
      'stand): the arc arrives from the middle and ends beside the head '
      'of the doll that will stand there', () async {
    final (h, _) = await _mount();
    await h.apply(const HintShownEffect(Move('r0c1', 'r1c1')));
    final g = h.game.geometry!;
    final target = g.slot('r1c1');
    final hint = h.board.hint;
    expect(target.centerX, closeTo(g.slot('r0c1').centerX, 1e-9));
    // brown3 will stand there: its head, not the empty stand's top.
    expect(hint.end!.dy, closeTo(target.dollTopY(3) + 6 * g.scale, 1e-9));
    expect(hint.end!.dx, closeTo(target.centerX + 48 * g.scale, 1e-9));
    final tangent = hint.end! - hint.control!;
    expect(tangent.dx, lessThan(0), reason: 'into the head, from the right');
    expect(tangent.dy, greaterThan(0));
    expect(
      h.board.fx.liveClips
          .where((c) => c.fx == FxId.fxSelectGlow)
          .single
          .slotId,
      'r1c1',
    );
  });

  test('a small source doll: the arc starts two thirds down it, never '
      'below it (pink1 r0c0 → pink2 r2c1)', () async {
    final (h, _) = await _mount();
    await h.apply(const HintShownEffect(Move('r0c0', 'r2c1')));
    final g = h.game.geometry!;
    final source = g.slot('r0c0');
    final target = g.slot('r2c1');
    final hint = h.board.hint;
    expect(source.dollHeight(1) * 2 / 3, lessThan(66 * g.scale));
    expect(
      hint.start!.dy,
      closeTo(source.dollTopY(1) + source.dollHeight(1) * 2 / 3, 1e-9),
    );
    // The source is left of the target: the arc arrives from its left.
    expect(source.centerX, lessThan(target.centerX));
    expect(hint.start!.dx, closeTo(source.centerX + 16 * g.scale, 1e-9));
    expect(hint.end!.dx, closeTo(target.centerX - 48 * g.scale, 1e-9));
    expect(hint.end!.dy, closeTo(target.dollTopY(2) + 6 * g.scale, 1e-9));
    expect((hint.end! - hint.control!).dx, greaterThan(0));
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
