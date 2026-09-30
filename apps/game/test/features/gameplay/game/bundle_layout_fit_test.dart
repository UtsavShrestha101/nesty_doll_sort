// Every bundled level fits its board (phase 4 architecture §2.8, D180–D183):
// the 200 levels of `assets/levels/bundle.json`, decoded with nesty_core's
// codec, laid out with `BoardLayout` on six screens with 0, 1 and 2 +1 Slots,
// and checked against the design's board fit: the preset, the doll tops
// under the family counter and the planks above, neighbours apart, cases and
// ice under the plank above, the tower stack under its limit and the hint
// over the middle stand either clear of the counter or yielding it.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Rect, Size;

import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/gameplay/game/board_shape_of.dart';
import 'package:nesty_render/nesty_render.dart';

typedef _K = BoardLayoutConstants;

/// The six screens of §2.8: the design's 390×844 with its 59/34 safe areas,
/// and five more sizes with the notch and home-bar insets each has.
const _viewports = <String, BoardViewport>{
  '390×844': BoardViewport(
    size: Size(390, 844),
    padding: EdgeInsets.only(top: 59, bottom: 34),
  ),
  '360×640': BoardViewport(
    size: Size(360, 640),
    padding: EdgeInsets.only(top: 24),
  ),
  '375×667': BoardViewport(
    size: Size(375, 667),
    padding: EdgeInsets.only(top: 20),
  ),
  '411×731': BoardViewport(
    size: Size(411, 731),
    padding: EdgeInsets.only(top: 24, bottom: 16),
  ),
  '430×932': BoardViewport(
    size: Size(430, 932),
    padding: EdgeInsets.only(top: 59, bottom: 34),
  ),
  '768×1024': BoardViewport(
    size: Size(768, 1024),
    padding: EdgeInsets.only(top: 24, bottom: 20),
  ),
};

/// A doll's top in the reference sizes is 742/768 of its box above its base;
/// the token's 0.9661 is that rounded to four places.
const _rounding = 0.02;

void main() {
  late final List<LevelBundleEntry> entries;
  setUpAll(() {
    final decoded = LevelBundleCodec.decodeString(
      File('assets/levels/bundle.json').readAsStringSync(),
    );
    expect(decoded.bundle, isNotNull, reason: '${decoded.issues}');
    entries = decoded.bundle!.levels;
  });

  test('the bundle is the 200 levels', () {
    expect(entries, hasLength(200));
  });

  test('no bundled level has 4 shelves or an authored row of 5 (so '
      'fourShelves and rowOfFive serve only the +1 Slot)', () {
    final offending = <String>[];
    for (final entry in entries) {
      final level = entry.level;
      if (level.shelves.length > 3) offending.add('${level.id}: shelves');
      for (final row in level.shelves) {
        if (row.length > 4) offending.add('${level.id}: row of ${row.length}');
      }
    }
    expect(offending, isEmpty);
  });

  test('the preset follows §2.1: maxSize 6 on 3 shelves takes '
      'threeShelvesTall (L130, L140 … L200), everything else the usual', () {
    final tall = <String>[];
    for (final entry in entries) {
      final level = entry.level;
      final shape = boardShapeOf(GameState.initial(level));
      final preset = ShelfPresets.forShape(shape);
      final expectTall = level.maxSize == 6 && level.shelves.length == 3;
      expect(
        identical(preset, ShelfPresets.threeTall),
        expectTall,
        reason: level.id,
      );
      if (expectTall) tall.add(level.id);
      expect(
        [
          for (final n in [2, 3])
            if (level.shelves.length == n) n,
        ].length,
        1,
        reason: '${level.id}: 2 or 3 shelves',
      );
    }
    expect(tall, isNotEmpty);
    expect(tall.first, 'L0130');
    expect(tall.last, 'L0200');
  });

  for (final MapEntry(key: name, value: viewport) in _viewports.entries) {
    for (var extras = 0; extras <= 2; extras++) {
      test('all 200 levels fit on $name with $extras +1 Slot(s)', () {
        final problems = <String>[];
        final notes = <String>[];
        for (final entry in entries) {
          _check(entry.level, viewport, extras, problems, notes);
        }
        expect(problems, isEmpty, reason: problems.join('\n'));
      });
    }
  }
}

BoardShape _shapeWithExtras(Level level, int extras) {
  var shape = boardShapeOf(GameState.initial(level));
  for (var i = 0; i < extras; i++) {
    shape = shape.withExtraSlot('x$i');
  }
  return shape;
}

/// The largest nest size a slot holds at the start (or 0).
int _tallest(Slot slot) {
  var size = 0;
  for (final nest in slot.nests) {
    size = math.max(size, nest.outerSize);
  }
  return size;
}

void _check(
  Level level,
  BoardViewport viewport,
  int extras,
  List<String> problems,
  List<String> notes,
) {
  final shape = _shapeWithExtras(level, extras);
  final g = BoardLayout.compute(shape, viewport);
  final s = g.scale;
  final where = '${level.id} ${viewport.size.width.toInt()}w +$extras';
  void fail(String what) => problems.add('$where: $what');

  final hudClear = g.fit.y(BoardFitTokens.hudClearY);
  final counterBottom = viewport.padding.top + _K.hudBottomInset;
  final plankTops = g.preset.plankTops;
  double plankAboveBottom(int row) =>
      g.fit.y(plankTops[row - 1] + _K.plankHeight);

  // 2 and 3: doll tops, neighbours.
  for (final shelf in g.shelves) {
    for (var c = 0; c < shelf.slots.length; c++) {
      final slot = shelf.slots[c];
      final initial = slot.id.startsWith('x') ? null : level.slot(slot.id);
      final size = initial == null ? level.maxSize : _tallest(initial);
      final largest = slot.kind == SlotShapeKind.locked && size > 0
          ? size
          : level.maxSize;
      final isTower = slot.kind == SlotShapeKind.tower;
      final base = slot.kind == SlotShapeKind.locked && !slot.usesTallCase
          ? slot.lockedDollBaseY
          : slot.surfaceY;
      final top = slot.dollTopY(largest, base);
      if (slot.row == 0) {
        // The design's clearance is 8 dp under the family counter (its
        // bottom + 8). A tower's stand sits 5 higher, so its top doll comes
        // within 3 of the counter (never into it): the design's own tall
        // preset leaves it there.
        final limit = isTower ? g.fit.y(_K.frameTop) : hudClear;
        if (top < limit - _rounding * s) {
          fail(
            '${slot.id} doll top ${top.toStringAsFixed(1)} above '
            '${limit.toStringAsFixed(1)} (counter bottom '
            '${counterBottom.toStringAsFixed(1)})',
          );
        }
        if (isTower && top < hudClear - _rounding * s) {
          notes.add('$where: tower ${slot.id} within 8 of the counter');
        }
      } else if (!isTower) {
        final limit = g.fit.y(
          plankTops[slot.row - 1] + _K.plankHeight + BoardFitTokens.headroom,
        );
        if (top < limit - _rounding * s) {
          fail(
            '${slot.id} doll top ${top.toStringAsFixed(1)} above the plank '
            'above (${limit.toStringAsFixed(1)})',
          );
        }
      }
      if (c > 0) {
        final left = shelf.slots[c - 1];
        final gap =
            slot.centerX -
            left.centerX -
            (slot.dollHeight(level.maxSize) + left.dollHeight(level.maxSize)) *
                BoardFitTokens.bodyWidth /
                2;
        if (gap < BoardFitTokens.neighbourGap * s - _rounding * s) {
          fail(
            '${left.id} and ${slot.id} dolls ${gap.toStringAsFixed(1)} apart',
          );
        }
        if (slot.kind == SlotShapeKind.locked ||
            left.kind == SlotShapeKind.locked) {
          final overlap = left.glassCaseRect.right - slot.glassCaseRect.left;
          if ((slot.kind == SlotShapeKind.locked &&
                  left.kind == SlotShapeKind.locked) &&
              overlap > 1e-6) {
            fail('cases of ${left.id} and ${slot.id} overlap by $overlap');
          }
        }
      }

      // 4: cases and ice stay under the plank above (the top shelf: the
      // frame top).
      final ceiling = slot.row == 0
          ? g.fit.y(_K.frameTop)
          : plankAboveBottom(slot.row);
      if (slot.kind == SlotShapeKind.locked) {
        final rect = slot.glassCaseRect;
        // The design's own 86×143 case on the usual planks reaches 0.7 dp
        // into the plank above (NestyBoard:169: top = surface − 134 = 351.3
        // under a plank ending at 352): that is the design, not a defect.
        if (rect.top < ceiling - 1 * s) {
          fail(
            '${slot.id} ${slot.usesTallCase ? 'tall ' : ''}case top '
            '${rect.top.toStringAsFixed(1)} above ${ceiling.toStringAsFixed(1)}',
          );
        }
        // Tall exactly when §2.3 says.
        final sealed = slot.shape.lockedSize;
        if (sealed != null) {
          final expectTall =
              slot.dollHeight(sealed) / s >
              GlassCaseTallTokens.minDollHeight * slot.pieceScale;
          if (slot.usesTallCase != expectTall) {
            fail('${slot.id} case tall=${slot.usesTallCase}, want $expectTall');
          }
        }
        if (rect.width > slot.pitch - 2 * s + _rounding) {
          fail(
            '${slot.id} case ${rect.width.toStringAsFixed(1)} wide on a pitch '
            'of ${slot.pitch.toStringAsFixed(1)}',
          );
        }
      }
      final frozen = initial != null && initial.ice > 0;
      if (frozen) {
        final Rect rect = slot.iceRect;
        if (rect.top < ceiling - _rounding * s) {
          fail(
            '${slot.id} ice top ${rect.top.toStringAsFixed(1)} above '
            '${ceiling.toStringAsFixed(1)}',
          );
        }
      }

      // 5: a tower's drawn silhouettes stay under their limit.
      if (initial is TowerSlot) {
        final buried = initial.hiddenCount;
        final tallest = _tallest(initial);
        final iced = initial.ice > 0;
        final drawn = slot.buriedDrawn(buried, topSize: tallest, iced: iced);
        var limitRef = slot.row == 0
            ? BoardFitTokens.hudClearY
            : plankTops[slot.row - 1] +
                  _K.plankHeight +
                  BoardFitTokens.headroom;
        if (iced) {
          limitRef = math.max(
            limitRef,
            g.fit.referenceY(slot.iceRect.top) + IcedTowerTokens.iceTopGap,
          );
        }
        final limit = g.fit.y(limitRef);
        // Buried nests, depth 1 right under the top.
        final stackStep = slot.towerStack(tallest, buried, iced: iced).step;
        // A stack squeezed to no step hides behind its own top doll: the
        // tower's tallest doll on its 5 dp taller stand, under a limit it
        // can't meet (the ice's top + 8 on an iced tower).
        for (var depth = 1; depth <= (stackStep < 0.01 ? 0 : drawn); depth++) {
          final nest = initial.stack[initial.stack.length - 1 - depth];
          final rect = slot.buriedSilhouetteRect(
            depth,
            nest.outerSize,
            buried: buried,
            topSize: tallest,
            iced: iced,
          );
          // D21's true-size silhouettes are raised by the design's step,
          // which sizes the design's own (taller) silhouettes: up to 3.4 %
          // of the room above the limit.
          if (rect.top < limit - (2 + 0.04 * (slot.surfaceY - limit)) * 1) {
            fail(
              '${slot.id} silhouette $depth top ${rect.top.toStringAsFixed(1)}'
              ' above its limit ${limit.toStringAsFixed(1)}',
            );
          }
        }
      }
    }
  }

  // 6: the hint over the top row either clears the counter or yields it.
  final pill = Rect.fromLTRB(
    viewport.size.width / 2 - _K.familyCounterPillWidth / 2,
    viewport.padding.top + _K.hudRowBottomInset,
    viewport.size.width / 2 + _K.familyCounterPillWidth / 2,
    counterBottom,
  );
  for (final slot in g.shelves.first.slots) {
    for (var size = 1; size <= level.maxSize; size++) {
      final arrow = slot
          .hintArrowRect(size)
          .translate(0, -_K.hintArrowBob * slot.furnitureScale);
      if (arrow.overlaps(pill) &&
          arrow.top < counterBottom &&
          !slot.hintNeedsCounter(size)) {
        fail(
          '${slot.id} size $size: a hint arrow reaches the counter and it '
          'does not yield',
        );
      }
    }
  }
}
