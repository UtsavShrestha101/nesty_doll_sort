// Boards the design draws only in part: rows of 5 (D172's +1 Slot) and 6,
// four shelves, one shelf, maxSize 6. BoardLayout applies the design's board
// fit (tokens.json `layout.boardFit`) to all of them; nothing on the board
// may collide.
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import 'board_fixtures.dart';

const _eps = 1e-6;

void _expectNoCollisions(BoardGeometry g, String label) {
  final maxSize = g.shape.maxSize;
  final s0 = g.scale;
  for (final shelf in g.shelves) {
    final slots = shelf.slots;
    for (var i = 1; i < slots.length; i++) {
      final a = slots[i - 1];
      final b = slots[i];
      final reason = '$label: ${a.id} vs ${b.id}';
      expect(
        a.standRect.right,
        lessThanOrEqualTo(b.standRect.left + _eps),
        reason: reason,
      );
      // Neighbouring dolls keep at least the design's 8 dp between their
      // widest painted parts (0.5353 h wide).
      final gap =
          b.centerX -
          a.centerX -
          (a.dollHeight(maxSize) + b.dollHeight(maxSize)) *
              BoardFitTokens.bodyWidth /
              2;
      expect(
        gap,
        greaterThanOrEqualTo(BoardFitTokens.neighbourGap * s0 - _eps),
        reason: reason,
      );
      // Below a 48 dp pitch the 48 dp minimum makes columns overlap and the
      // nearest centre wins (board_layout_screens_test).
      if (shelf.pitch >= BoardLayoutConstants.minHitExtent) {
        expect(
          a.hitRect.right,
          lessThanOrEqualTo(b.hitRect.left + _eps),
          reason: reason,
        );
      }
    }
    for (final s in slots) {
      expect(s.standRect.width, lessThanOrEqualTo(s.pitch - 2.4 * s0 + _eps));
      // Pips stay 6 dp on a scaled stand, on its face.
      expect(s.pipDiameter, closeTo(6 * s0, _eps));
      expect(
        s.pipCenterX(0) - s.pipDiameter / 2,
        greaterThan(s.standRect.left),
      );
      expect(
        s.pipCenterX(s.pipCount - 1) + s.pipDiameter / 2,
        lessThan(s.standRect.right),
      );
      expect(s.pipCenterY, lessThan(s.standRect.bottom));
      expect(s.pipCenterY, greaterThan(s.standRect.top));
      expect(s.iceRect.bottom, lessThanOrEqualTo(g.boardArea.bottom + _eps));
    }
  }
  for (var r = 0; r < g.shelves.length; r++) {
    for (final s in g.shelves[r].slots) {
      // The board fit: the largest resting doll of an open stand stays under
      // the family counter's clearance on the top shelf and 2 dp under the
      // plank above on the others.
      final limit = r == 0
          ? g.fit.y(BoardFitTokens.hudClearY)
          : g.fit.y(
              g.preset.plankTops[r - 1] +
                  BoardLayoutConstants.plankHeight +
                  BoardFitTokens.headroom,
            );
      if (s.kind != SlotShapeKind.tower && s.kind != SlotShapeKind.locked) {
        expect(
          s.dollTopY(maxSize, s.surfaceY),
          // 0.9661 in the token is 742/768 rounded to four places.
          greaterThanOrEqualTo(limit - 0.02 * s0),
          reason: '$label: ${s.id}',
        );
      }
      // Frozen stands: the ice stays under the plank above. On four shelves
      // the ice follows k (m7-4 5.2) and still reaches into the plank above
      // by what the design's 160-tall ice cannot lose: board_overlays_m74.
      if (r > 0 && !identical(g.preset, ShelfPresets.four)) {
        expect(
          s.iceRect.top,
          greaterThanOrEqualTo(
            g.fit.y(
                  g.preset.plankTops[r - 1] + BoardLayoutConstants.plankHeight,
                ) -
                _eps,
          ),
          reason: '$label: ${s.id} ice',
        );
      }
    }
  }
}

void main() {
  final crowded = <String, BoardShape>{
    '3 shelves 5/5/4, maxSize 5': board(['ooooo', 'toolo', 'oooo'], maxSize: 5),
    '3 shelves 4/4/6 (2 extras), maxSize 6': board([
      'oooo',
      'tool',
      'olooxx',
    ], maxSize: 6),
    '3 shelves 5/5/6, maxSize 4': board([
      'ooooo',
      'ooloo',
      'otooxx',
    ], maxSize: 4),
    '3 shelves 4/4/5 (1 extra), maxSize 5': board([
      'oooo',
      'oooo',
      'oooox',
    ], maxSize: 5),
    '4 shelves 5/5/5/4, maxSize 6': board([
      'ooooo',
      'toloo',
      'ooooo',
      'oolo',
    ], maxSize: 6),
    '4 shelves 4/4/4/6, maxSize 4': board([
      'oooo',
      'tool',
      'oooo',
      'oootxx',
    ], maxSize: 4),
    '4 shelves 2/3/4/5, maxSize 3': board([
      'oo',
      'ool',
      'otoo',
      'ooooo',
    ], maxSize: 3),
    '2 shelves 5/6, maxSize 6': board(['ooloo', 'ootoxx'], maxSize: 6),
    '1 shelf 6, maxSize 6': board(['oloxox'], maxSize: 6),
    '1 shelf 2, maxSize 6': board(['ol'], maxSize: 6),
  };

  for (final entry in crowded.entries) {
    for (final screen in screens.entries) {
      test('${entry.key} on ${screen.key}: nothing collides', () {
        final g = BoardLayout.compute(entry.value, screen.value);
        _expectNoCollisions(g, '${entry.key} on ${screen.key}');
      });
    }
  }

  test('the designed boards pass the same checks', () {
    for (final shape in [mainBoard, fullBoard, tutorialBoard, bonusBoard]) {
      _expectNoCollisions(
        BoardLayout.compute(shape, BoardViewport.reference),
        '$shape',
      );
    }
  });

  group('stands follow min(90, pitch − 2.4) (layout.boardFit)', () {
    test('full size to a pitch of 92.4, 0.8 on a row of 5, 0.662 on 6', () {
      expect(BoardLayout.standScaleForPitch(96), 1);
      expect(BoardLayout.standScaleForPitch(93), 1);
      expect(BoardLayout.standScaleForPitch(92.4), 1);
      expect(
        BoardLayout.standScaleForPitch(74.4),
        closeTo(BoardPresetTokens.rowOfFive.standScale, exact),
      );
      expect(BoardLayout.standScaleForPitch(62), closeTo(59.6 / 90, exact));
      expect(
        [for (var n = 1; n <= 6; n++) BoardLayout.rowPitch(n)],
        [96, 96, 96, 93, 74.4, 62],
      );
    });

    test('a row of 6: stands 59.6 wide, glass, ice, glow and pips as '
        'rowOfFive\'s formulas say (D181, confirmed m7-6 Choices 19)', () {
      final g = BoardLayout.compute(
        board(['oooo', 'oooo', 'ootoxx'], maxSize: 4),
        BoardViewport.reference,
      );
      final k = 59.6 / 90;
      final tower = g.slot('r2c2');
      expect(tower.pieceScale, closeTo(k, exact));
      expect(tower.standRect.width, closeTo(59.6, exact));
      expect(tower.standRect.height, closeTo(39 * k, exact));
      expect(tower.pipCenterY, closeTo(tower.standTop + 31.9 * k, exact));
      // Pips stay unscaled (rowOfFive.pips).
      expect(tower.pipPitch, closeTo(7.8, exact));
      expect(tower.pipDiameter, closeTo(6, exact));
      expect(tower.iceRect.width, closeTo(63.6, 0.05)); // 96 k, 1.6 overlap
      expect(tower.iceRect.width, closeTo(96 * k, exact));
      expect(tower.glowRingRect.width, closeTo(116 * k, exact));
      expect(tower.hintArrowRect(4).width, closeTo(40 * k, exact));
      // The design's worked example: k from H = (59.6 − 8) / 0.5353 = 96.4,
      // so maxSize 4 (117 tall) shrinks to 96.5.
      expect(g.maxDollHeight, closeTo(96.4, 0.1));
      expect(g.dollHeightScale, closeTo(96.4 / 117, 0.001));
      expect(g.slot('r0c0').pieceScale, 1);
    });
  });

  group('the other presets', () {
    test('1 shelf: plank 540, Hs 150', () {
      final g = BoardLayout.compute(
        board(['oooo'], maxSize: 4),
        BoardViewport.reference,
      );
      expect(g.preset.designed, isTrue); // m7-6 Choices 18
      expect(g.shelves.single.plankTop, 540);
      expect(g.maxDollHeight, closeTo(117, exact));
    });

    test(
      '4 shelves: 253 / 398 / 543 / 688, dolls fit to 93.5 (fourShelves)',
      () {
        final g = BoardLayout.compute(
          board(['oooo', 'oooo', 'oooo', 'oooo'], maxSize: 4),
          BoardViewport.reference,
        );
        expect(g.preset, same(ShelfPresets.four));
        expect([for (final s in g.shelves) s.plankTop], [253, 398, 543, 688]);
        expect(g.maxDollHeight, closeTo(93.5, 0.05));
        final s = g.slot('r1c0');
        // Pieces don't shrink with the dolls: only the pitch scales a stand.
        expect(s.pieceScale, 1);
        expect(s.standRect.width, closeTo(90, exact));
        expect(s.standRect.bottom, closeTo(407, exact));
      },
    );

    test('the fit never enlarges a doll and never goes below its limits', () {
      for (final entry in crowded.entries) {
        final g = BoardLayout.compute(entry.value, BoardViewport.reference);
        expect(g.dollHeightScale, lessThanOrEqualTo(1), reason: entry.key);
        expect(g.dollHeightScale, greaterThan(0.3), reason: entry.key);
        final result = BoardLayout.fitDolls(entry.value, g.preset);
        expect(
          result.heights.last,
          lessThanOrEqualTo(
            math.min(
                  result.limits.vertical,
                  math.min(result.limits.hud, result.limits.horizontal),
                ) +
                _eps,
          ),
          reason: entry.key,
        );
      }
    });
  });
}
