// BoardLayout on the 390×844 reference screen must reproduce
// design/prototypes/NestyBoard.dc.html (render design §3, ±0.5 dp). Expected
// values are the design's numbers, not re-derived from the code.
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import 'board_fixtures.dart';

void main() {
  const tol = designTolerance;

  group('reference frame', () {
    test('s = 1 and the frame is y 142…734 at 390×844', () {
      final g = BoardLayout.compute(mainBoard, BoardViewport.reference);
      expect(g.scale, 1);
      expect(g.fit.frame, const Rect.fromLTWH(0, 142, 390, 592));
      expect(g.boardArea, const Rect.fromLTRB(0, 142, 390, 734));
    });

    test('family counter target is (W/2, padding.top + 70)', () {
      final g = BoardLayout.compute(mainBoard, BoardViewport.reference);
      expect(g.familyCounterTarget, const Offset(195, 129));
    });
  });

  group('3 shelves (MAIN, frame 2.2)', () {
    late BoardGeometry g;
    setUp(() => g = BoardLayout.compute(mainBoard, BoardViewport.reference));

    test('planks at 312 / 498 / 684, 40 tall, full width', () {
      expect([for (final s in g.shelves) s.plankTop], [312, 498, 684]);
      for (final s in g.shelves) {
        expect(s.plankRect.left, 0);
        expect(s.plankRect.width, 390);
        expect(s.plankRect.height, 40);
      }
    });

    test('row centres 55.5/148.5/241.5/334.5 and 99/195/291', () {
      expect(
        [for (final s in g.shelves[0].slots) s.centerX],
        [55.5, 148.5, 241.5, 334.5],
      );
      expect([for (final s in g.shelves[2].slots) s.centerX], [99, 195, 291]);
      expect(g.shelves[0].pitch, 93);
      expect(g.shelves[2].pitch, 96);
    });

    test('stand top 287 (tower 282 on the same plank), surface 299.3', () {
      final open = g.slot('r0c0');
      expect(open.standTop, closeTo(287, tol));
      expect(open.surfaceY, closeTo(299.3, tol));
      expect(open.standRect.width, 90);
      expect(open.standRect.height, 34);
      expect(open.standRect.left, closeTo(10.5, tol));

      // The tower stand is 5 dp taller: 498 + 9 − 39 = 468 on its shelf,
      // i.e. 282 had it stood on the first plank.
      final tower = g.slot('r1c0');
      expect(tower.standTop, closeTo(468, tol));
      expect(tower.standTop - (tower.plankTop - 312), closeTo(282, tol));
      expect(tower.standRect.height, 39);
      expect(tower.surfaceY, closeTo(480.3, tol));
    });

    test('pips at cx ± 3.9 / ± 11.7, y 311; left is the biggest', () {
      final s = g.slot('r0c0');
      expect(s.pipCount, 4);
      expect(s.pipCenterY, closeTo(311, tol));
      expect(s.pipDiameter, 6);
      expect(s.pipPitch, 7.8);
      final xs = [for (var k = 0; k < 4; k++) s.pipCenterX(k)];
      expect(xs[0], closeTo(55.5 - 11.7, tol));
      expect(xs[1], closeTo(55.5 - 3.9, tol));
      expect(xs[2], closeTo(55.5 + 3.9, tol));
      expect(xs[3], closeTo(55.5 + 11.7, tol));
      expect(s.pipCenterXForSize(4), xs[0]);
      expect(s.pipCenterXForSize(1), xs[3]);
      // Tower pips: standTop + 31.9 (NestyBoard:164).
      expect(g.slot('r1c0').pipCenterY, closeTo(499.9, tol));
    });

    test('doll heights 63 / 81 / 99 / 117, width h·2/3', () {
      expect(g.dollHeights, [
        closeTo(63, tol),
        closeTo(81, tol),
        closeTo(99, tol),
        closeTo(117, tol),
      ]);
      expect(g.dollHeightScale, 1);
      expect(g.slot('r0c0').dollWidth(4), closeTo(78, tol));
      // NestyBoard:152: rect top = base − h·742/768.
      final rect = g.slot('r0c0').dollRect(4);
      expect(rect.left, closeTo(16.5, tol));
      expect(rect.top, closeTo(186.26, tol));
      expect(
        rect.bottom - g.slot('r0c0').surfaceY,
        closeTo(117 * 26 / 768, tol),
      );
    });

    test('glass case top 351.3 for a surface of 485.3', () {
      final s = g.slot('r1c3');
      expect(s.surfaceY, closeTo(485.3, tol));
      expect(s.glassCaseRect.top, closeTo(351.3, tol));
      expect(s.glassCaseRect.left, closeTo(291.5, tol));
      expect(s.glassCaseRect.size, const Size(86, 143));
      expect(s.lockedDollBaseY, closeTo(474.3, tol));
      expect(s.restingBaseY, s.lockedDollBaseY);
      expect(s.padlockSymbolCenter.dx, closeTo(334.5, tol));
      expect(s.padlockSymbolCenter.dy, closeTo(351.3 + 116.3, tol));
      expect(s.padlockSymbolSize, 12);
    });

    test('ice top 540.5, 96×160, badge 28 at (cx + 22, top + 2)', () {
      final s = g.slot('r2c1');
      expect(s.iceRect.top, closeTo(540.5, tol));
      expect(s.iceRect.left, closeTo(147, tol));
      expect(s.iceRect.size, const Size(96, 160));
      expect(s.iceBadgeRect.topLeft.dx, closeTo(217, tol));
      expect(s.iceBadgeRect.topLeft.dy, closeTo(542.5, tol));
      expect(s.iceBadgeRect.size, const Size(28, 28));
    });

    test('glow ring at (90.5, 457.3), 116×52', () {
      final s = g.slot('r1c1');
      expect(s.glowRingRect.left, closeTo(90.5, tol));
      expect(s.glowRingRect.top, closeTo(457.3, tol));
      expect(s.glowRingRect.size, const Size(116, 52));
    });

    test('"+N" tag at (cx + 21, standTop + 16)', () {
      final s = g.slot('r1c0');
      expect(s.towerTagOrigin.dx, closeTo(76.5, tol));
      expect(s.towerTagOrigin.dy, closeTo(484, tol));
    });

    test('hint arrow 40×50 at (cx − 20, dollTop − 58) (NestyBoard:208)', () {
      // Scene "hint": the source is r0c3 holding a size-3 nest.
      final arrow = g.slot('r0c3').hintArrowRect(3);
      expect(arrow.left, closeTo(314.5, tol));
      expect(arrow.top, closeTo(299.3 - 99 * 742 / 768 - 58, tol));
      expect(arrow.size, const Size(40, 50));
    });

    test('buried tower nests keep their true size, raised one step per depth '
        '(m7-3 layout.towerStack)', () {
      final s = g.slot('r1c0');
      // Middle shelf, a size-1 top (63) with 3 buried: room for the full 18
      // ("Every existing tower keeps its 18 dp step").
      expect(s.buriedBaseY(1, buried: 3, topSize: 1), closeTo(480.3 - 18, tol));
      expect(s.buriedBaseY(3, buried: 3, topSize: 1), closeTo(480.3 - 54, tol));
      final r = s.buriedSilhouetteRect(1, 4, buried: 3, topSize: 1);
      expect(r.height, closeTo(117, tol));
      expect(r.width, closeTo(78, tol));
      expect(r.left, closeTo(16.5, tol));
      expect(r.top, closeTo(462.3 - 117 * 742 / 768, tol));
      // A smaller buried nest is drawn smaller, not stretched (D21).
      expect(
        s.buriedSilhouetteRect(2, 1, buried: 3, topSize: 1).height,
        closeTo(63, tol),
      );
      // A size-4 top on the same shelf leaves 13.7 of room for 3: fewer
      // silhouettes, at the 9 dp step (the design's "below 9" rule).
      expect(s.towerStack(4, 3).drawn, 1);
      expect(s.towerStack(4, 3).step, closeTo(9, tol));
    });

    test('a top-shelf tower keeps its silhouettes under the HUD '
        '(the design\'s three examples)', () {
      // maxSize 4 on 3 shelves: the tower's surface is 294.3 (its stand is
      // 39 tall); hRoom = (294.3 − 150) / 0.9661 = 149.4.
      final top = BoardLayout.compute(
        board(['otoo', 'oooo', 'ooo'], maxSize: 4),
        BoardViewport.reference,
      ).slot('r0c1');
      expect(top.surfaceY, closeTo(294.3, tol));
      // Size-4 top (117), 3 buried: the design's example says 10.8; d21
      // (m7-4 5.3) keeps the 8 dp clearance with true sizes, so the step is
      // worked out in drawn units: 10.8 x 0.9661.
      final a = top.towerStack(4, 3);
      expect(a.step, closeTo(10.8 * 0.9661, 0.05));
      expect(a.drawn, 3);
      expect(
        top.buriedBaseY(1, buried: 3, topSize: 4),
        closeTo(294.3 - a.step, tol),
      );
      // Size-3 top (99): 16.8 x 0.9661.
      expect(top.towerStack(3, 3).step, closeTo(16.8 * 0.9661, 0.05));
      // Fewer nests keep the designed 18.
      expect(top.towerStack(4, 1).step, 18);
      expect(top.towerStack(4, 2).step, closeTo(16.18 * 0.9661, 0.05));
    });

    test('hit rects span the column and the band between plank bottoms', () {
      expect(g.slot('r0c0').hitRect, const Rect.fromLTRB(9, 142, 102, 352));
      expect(g.slot('r1c1').hitRect, const Rect.fromLTRB(102, 352, 195, 538));
      expect(g.slot('r2c2').hitRect, const Rect.fromLTRB(243, 538, 339, 724));
    });
  });

  group('2 shelves (TUT1, frames 1.3/1.4)', () {
    test('planks 430 / 650, heights 89.1 / 114.5 / 140', () {
      final g = BoardLayout.compute(tutorialBoard, BoardViewport.reference);
      expect(g.preset.designed, isTrue);
      expect([for (final s in g.shelves) s.plankTop], [430, 650]);
      expect(g.dollHeights, [
        closeTo(89.1, tol),
        closeTo(114.5, tol),
        closeTo(140, tol),
      ]);
      expect(g.slot('r0c0').standTop, closeTo(405, tol));
      expect(g.slot('r1c1').surfaceY, closeTo(637.3, tol));
      expect(g.slot('r1c1').pipCount, 3);
      expect([for (final s in g.shelves[1].slots) s.centerX], [99, 195, 291]);
    });
  });

  group('maxSize', () {
    test('maxSize 5 at 4 slots: width 89, unclamped (BONUS on L5)', () {
      final g = BoardLayout.compute(bonusBoard, BoardViewport.reference);
      expect(g.dollHeightScale, 1);
      expect(g.maxDollHeight, closeTo(133.5, tol));
      expect(g.slot('r0c0').dollWidth(5), closeTo(89, tol));
      expect(g.slot('r0c0').pipCount, 5);
    });

    test('maxSize 6 on 3 shelves takes the tall preset: 142.1 tall, k 0.947 '
        '(D180)', () {
      final g = BoardLayout.compute(
        board(['oooo', 'oooo', 'ooo'], maxSize: 6),
        BoardViewport.reference,
      );
      expect(g.preset, same(ShelfPresets.threeTall));
      expect([for (final s in g.shelves) s.plankTop], [300, 494, 688]);
      expect(g.dollHeightScale, closeTo(142.1 / 150, 0.001));
      expect(g.maxDollHeight, closeTo(142.1, 0.05));
      // One scale for the board: every size shrinks by the same factor.
      expect(g.dollHeight(1), closeTo(150 * 0.42 * g.dollHeightScale, exact));
    });

    test('maxSize 3 on 3 shelves scales size 3 to 1.00 of the fit (135.9)', () {
      final g = BoardLayout.compute(
        board(['oooo', 'oooo', 'ooo'], maxSize: 3),
        BoardViewport.reference,
      );
      expect(g.maxDollHeight, closeTo(135.9, 0.05));
      expect(g.dollHeight(1) / g.dollHeight(3), closeTo(0.42 / 0.66, exact));
    });
  });

  group('extra slot re-pitch (D22, frame 3.6)', () {
    test('the first extra joins the 3-slot bottom shelf at 334.5', () {
      final before = BoardLayout.compute(fullBoard, BoardViewport.reference);
      final after = BoardLayout.compute(
        fullBoard.withExtraSlot('x0'),
        BoardViewport.reference,
      );
      expect(
        [for (final s in before.shelves[2].slots) s.centerX],
        [99, 195, 291],
      );
      expect(
        [for (final s in after.shelves[2].slots) s.centerX],
        [55.5, 148.5, 241.5, 334.5],
      );
      final extra = after.slot('x0');
      expect(extra.kind, SlotShapeKind.extra);
      expect(extra.row, 2);
      expect(extra.index, after.slots.length - 1);
      // NestyBoard:163: extra-slot.svg in the stand box.
      expect(extra.standRect.left, closeTo(289.5, tol));
      expect(extra.standRect.top, closeTo(659, tol));
      expect(extra.standRect.size, const Size(90, 34));
      // Upper shelves don't move, and nothing needs to shrink yet.
      for (var r = 0; r < 2; r++) {
        for (var i = 0; i < before.shelves[r].slots.length; i++) {
          expect(
            after.shelves[r].slots[i].centerX,
            before.shelves[r].slots[i].centerX,
          );
        }
      }
      expect(after.dollHeights, before.dollHeights);
    });

    test('the second extra makes a row of 5: pitch 74.4, stands at 0.8, pips '
        'unscaled (rowOfFive, D181)', () {
      final g = BoardLayout.compute(
        fullBoard.withExtraSlot('x0').withExtraSlot('x1'),
        BoardViewport.reference,
      );
      final row = g.shelves[2];
      expect(row.pitch, closeTo(74.4, exact));
      expect(
        [for (final s in row.slots) s.centerX],
        [
          closeTo(46.2, exact),
          closeTo(120.6, exact),
          closeTo(195, exact),
          closeTo(269.4, exact),
          closeTo(343.8, exact),
        ],
      );
      const token = BoardPresetTokens.rowOfFive;
      final s = g.slot('x1');
      expect(s.pieceScale, closeTo(token.standScale, exact));
      expect(s.standRect.width, closeTo(token.stand.width, exact));
      expect(s.standRect.height, closeTo(token.stand.height, exact));
      expect(s.standRect.bottom, closeTo(693, exact));
      // The surface sits 9.84 below the scaled stand's top.
      expect(
        s.surfaceY - s.standRect.top,
        closeTo(token.standSurfaceOffset, 0.01),
      );
      // Pips stay 6 dp at a 7.8 pitch on the scaled stand.
      expect(s.pipDiameter, 6);
      expect(s.pipPitch, 7.8);
      // maxSize 4 keeps its sizes (the width limit is 119.6).
      expect(g.dollHeightScale, 1);
      expect(g.dollHeights, [
        closeTo(63, tol),
        closeTo(81, tol),
        closeTo(99, tol),
        closeTo(117, tol),
      ]);
      // The upper shelves keep their pitch and full-size stands.
      expect(g.slot('r0c0').standRect.width, 90);
      expect(g.slot('r1c0').centerX, 99);
    });
  });

  group('iceFrame = min(3, ⌊3(n0 − n)/n0⌋)', () {
    test('three stages, frame 3 only at 0', () {
      int f(int n, int n0) => BoardLayout.iceFrame(remaining: n, initial: n0);
      expect([f(3, 3), f(2, 3), f(1, 3), f(0, 3)], [0, 1, 2, 3]);
      expect([f(2, 2), f(1, 2), f(0, 2)], [0, 1, 3]);
      expect([f(1, 1), f(0, 1)], [0, 3]);
    });

    test('clamps the counter and rejects a slot without ice', () {
      expect(BoardLayout.iceFrame(remaining: 5, initial: 2), 0);
      expect(BoardLayout.iceFrame(remaining: -1, initial: 2), 3);
      expect(
        () => BoardLayout.iceFrame(remaining: 0, initial: 0),
        throwsArgumentError,
      );
    });
  });
}
