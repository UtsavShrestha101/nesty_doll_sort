// The placement terms the board Lottie files need from the layout
// (docs/plans/m2-lottie-design.md §5, §8, §9): BoardFit's inverse and the
// board-space origin, the family counter in reference units, the paused
// glass/ice composition origins and the in-place anchors. At 390×844 they
// must equal LOTTIE.md's numbers.
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import 'board_fixtures.dart';

typedef _K = BoardLayoutConstants;

void main() {
  const tol = designTolerance;

  group('BoardFit', () {
    test('toReference round-trips on every screen', () {
      for (final MapEntry(key: name, value: viewport) in screens.entries) {
        final fit = BoardLayout.fitFor(viewport);
        for (final (x, y) in [(0.0, 142.0), (195.0, 500.0), (390.0, 734.0)]) {
          final device = Offset(fit.x(x), fit.y(y));
          final back = fit.toReference(device.dx, device.dy);
          expect(back.dx, closeTo(x, 1e-9), reason: name);
          expect(back.dy, closeTo(y, 1e-9), reason: name);
          expect(fit.referenceX(fit.x(x)), closeTo(x, 1e-9), reason: name);
          expect(fit.referenceY(fit.y(y)), closeTo(y, 1e-9), reason: name);
        }
        expect(fit.referenceLength(fit.length(37)), closeTo(37, 1e-9));
      }
    });

    test('the board-space canvas is the reference screen', () {
      expect(
        BoardLayout.fitFor(BoardViewport.reference).boardSpaceOrigin,
        Offset.zero,
      );
      for (final MapEntry(key: name, value: viewport) in screens.entries) {
        final fit = BoardLayout.fitFor(viewport);
        // Reference (0, 0) lands on the origin; (X, Y) at origin + (X, Y)·s.
        expect(fit.boardSpaceOrigin.dx, closeTo(fit.x(0), exact), reason: name);
        expect(fit.boardSpaceOrigin.dy, closeTo(fit.y(0), exact), reason: name);
        final o = fit.boardSpaceOrigin;
        expect(o.dx + 300 * fit.scale, closeTo(fit.x(300), 1e-9));
        expect(o.dy + 500 * fit.scale, closeTo(fit.y(500), 1e-9));
      }
    });
  });

  group('family counter in reference units', () {
    test('is (195, 129) on the reference screen', () {
      final g = BoardLayout.compute(mainBoard, BoardViewport.reference);
      expect(g.familyCounterTargetReference, const Offset(195, 129));
      expect(g.familyCounterInBoardSpace, isTrue);
    });

    test('moves up by slack / (2s) and stays in the canvas on phones', () {
      for (final MapEntry(key: name, value: viewport) in screens.entries) {
        final g = BoardLayout.compute(mainBoard, viewport);
        final s = g.scale;
        final slack = g.boardArea.height - 592 * s;
        expect(
          g.familyCounterTargetReference.dy,
          closeTo(142 - (13 + slack / 2) / s, 1e-9),
          reason: name,
        );
        expect(g.familyCounterInBoardSpace, isTrue, reason: name);
      }
    });

    test('leaves the canvas past 2·(142·s − 13) of slack', () {
      // 320 wide (s = 0.82) and 1200 tall: slack ≈ 500 dp.
      final g = BoardLayout.compute(
        mainBoard,
        const BoardViewport(size: Size(320, 1200)),
      );
      final slack = g.boardArea.height - 592 * g.scale;
      expect(slack, greaterThan(2 * (142 * g.scale - 13)));
      expect(g.familyCounterInBoardSpace, isFalse);
    });
  });

  group('paused compositions (§8)', () {
    test('glass: doll base on the case floor, case at (47, 40)', () {
      final g = BoardLayout.compute(mainBoard, BoardViewport.reference);
      final s = g.slot('r1c3');
      // Case top 351.3 (board_layout_reference_test), cx 334.5.
      expect(s.glassCompositionOrigin.dx, closeTo(334.5 - 90, tol));
      expect(s.glassCompositionOrigin.dy, closeTo(351.3 + 123 - 163, tol));
      for (final MapEntry(key: name, value: viewport) in screens.entries) {
        for (final slot in BoardLayout.compute(mainBoard, viewport).slots) {
          final fs = slot.furnitureScale;
          final o = slot.glassCompositionOrigin;
          expect(o.dx + 47 * fs, closeTo(slot.glassCaseRect.left, 1e-9));
          expect(o.dy + 40 * fs, closeTo(slot.glassCaseRect.top, 1e-9));
          expect(o.dy + 163 * fs, closeTo(slot.lockedDollBaseY, 1e-9));
          expect(o.dx + 90 * fs, closeTo(slot.centerX, 1e-9), reason: name);
        }
      }
    });

    test('ice: ice bottom (90, 200) on the overlay, ice at (42, 40)', () {
      for (final MapEntry(key: name, value: viewport) in screens.entries) {
        for (final slot in BoardLayout.compute(mainBoard, viewport).slots) {
          final fs = slot.furnitureScale;
          final o = slot.iceCompositionOrigin;
          expect(o.dx + 90 * fs, closeTo(slot.centerX, 1e-9));
          expect(o.dx + 42 * fs, closeTo(slot.iceRect.left, 1e-9));
          expect(o.dy + 40 * fs, closeTo(slot.iceRect.top, 1e-6));
          expect(o.dy + 200 * fs, closeTo(slot.iceRect.bottom, 1e-6));
          expect(slot.iceFxScaleY, 1);
          if (slot.kind == SlotShapeKind.tower) {
            // The design's iceTower scene: the ice bottom stays 16.5 under
            // the plank's top on a tower stand (5·fs above its doll's base
            // + 29.2·fs), so the composition's own doll is hidden there.
            expect(
              slot.iceRect.bottom - slot.plankTop,
              closeTo(16.5 * fs, 1e-6),
              reason: '$name ${slot.id}',
            );
          } else {
            // On an open stand the composition's doll base is the surface.
            expect(o.dy + 170.8 * fs, closeTo(slot.surfaceY, 1e-9));
          }
        }
      }
    });

    test('the freed doll settles 11·fs onto the stand', () {
      for (final viewport in screens.values) {
        for (final slot in BoardLayout.compute(mainBoard, viewport).slots) {
          expect(slot.unlockedDollBaseY, slot.surfaceY);
          expect(slot.unlockSettle, closeTo(11 * slot.furnitureScale, 1e-9));
        }
      }
      final locked = BoardLayout.compute(
        mainBoard,
        BoardViewport.reference,
      ).slot('r1c3');
      expect(locked.restingBaseY, locked.lockedDollBaseY);
      expect(locked.unlockedDollBaseY - locked.restingBaseY, closeTo(11, tol));
    });
  });

  group('in-place anchors', () {
    test('glow, extra-slot stand and hint arrow centres', () {
      for (final viewport in screens.values) {
        final g = BoardLayout.compute(mainBoard, viewport);
        for (final slot in g.slots) {
          final fs = slot.furnitureScale;
          expect(slot.glowCenterY, closeTo(slot.surfaceY - 2 * fs, 1e-9));
          expect(slot.glowCenterY, closeTo(slot.glowRingRect.center.dy, 1e-9));
          expect(slot.standCenterY, closeTo(slot.standRect.center.dy, 1e-9));
          for (var size = 1; size <= 4; size++) {
            // `dollTop − 33·fs`, or at most 16·fs lower under the HUD.
            final designed = slot.dollTopY(size) - 33 * fs;
            expect(
              slot.hintArrowCenterY(size),
              inInclusiveRange(designed - 1e-9, designed + 16 * fs + 1e-9),
            );
            final rect = slot.hintArrowRect(size);
            expect(rect.center.dx, closeTo(slot.hintArrowCenterX(size), 1e-9));
            expect(rect.center.dy, closeTo(slot.hintArrowCenterY(size), 1e-9));
            expect(rect.width, closeTo(40 * fs, 1e-9));
            expect(rect.height, closeTo(50 * fs, 1e-9));
          }
        }
      }
    });

    test("frame 3.1's arrow keeps the design's place", () {
      // MAIN's hint source r0c3 on 390×844 clears the HUD: NestyBoard:208.
      final slot = BoardLayout.compute(
        mainBoard,
        BoardViewport.reference,
      ).slot('r0c3');
      expect(slot.hintArrowCenterX(3), slot.centerX);
      expect(slot.hintArrowCenterY(3), closeTo(slot.dollTopY(3) - 33, 1e-9));
    });
  });

  group('the hint arrow clears the HUD', () {
    const iPhone16 = BoardViewport(
      size: Size(393, 852),
      padding: EdgeInsets.only(top: 59, bottom: 34),
    );
    // Level 9: maxSize 3 on three shelves, so its top-row dolls are taller
    // than any in the frames (the owner's report).
    final level9 = board(['oooo', 'oooo', 'ooo'], maxSize: 3);

    /// The arrow's box at the top of its bob.
    Rect peakOf(SlotGeometry slot, int size) => slot
        .hintArrowRect(size)
        .translate(0, -_K.hintArrowBob * slot.furnitureScale);

    test('Level 9: inner columns step off the counter pill, all clear '
        'the button row', () {
      final g = BoardLayout.compute(level9, iPhone16);
      const safeTop = 59.0;
      final counterLeft = 393 / 2 - 35;
      final counterRight = 393 / 2 + 35;
      for (final slot in g.shelves.first.slots) {
        final fs = slot.furnitureScale;
        final peak = peakOf(slot, 3);
        // Below the pause button, the lowest piece of the row (51), by 4.
        expect(peak.top, closeTo(safeTop + 51 + 4, 1e-9), reason: slot.id);
        expect(
          slot.hintArrowCenterY(3) - (slot.dollTopY(3) - 33 * fs),
          lessThanOrEqualTo(16 * fs),
          reason: slot.id,
        );
        final clearsCounter =
            peak.right <= counterLeft - 4 + 1e-9 ||
            peak.left >= counterRight + 4 - 1e-9;
        expect(clearsCounter, isTrue, reason: slot.id);
      }
      final inner = g.slot('r0c1');
      expect(inner.hintArrowCenterX(3), lessThan(inner.centerX));
      expect(
        inner.centerX - inner.hintArrowCenterX(3),
        lessThanOrEqualTo(inner.pitch / 4),
      );
      expect(g.slot('r0c0').hintArrowCenterX(3), g.slot('r0c0').centerX);
      expect(
        g.slot('r0c2').hintArrowCenterX(3),
        greaterThan(g.slot('r0c2').centerX),
      );
    });

    test('the middle of an odd row keeps its rest pose and the counter '
        'yields (frame 3.1b, E.20)', () {
      final g = BoardLayout.compute(
        board(['ooo', 'ooo', 'ooo'], maxSize: 3),
        iPhone16,
      );
      final middle = g.slot('r0c1');
      final fs = middle.furnitureScale;
      expect(middle.hintArrowCenterX(3), middle.centerX);
      // D62's 16 dp cap is gone for this case, but `hintMiddle.clampTop`
      // (m7-4 5.4) holds: the arrow's highest bob point stays at 112 (4 dp
      // under the level pill), moved down over the doll's head.
      expect(peakOf(middle, 3).top, closeTo(59 + 49 + 4, 1e-9));
      expect(
        middle.hintArrowCenterY(3),
        greaterThan(middle.dollTopY(3) - 33 * fs),
      );
      expect(middle.hintNeedsCounter(3), isTrue);
      // Its top reaches the counter's pill, which fades.
      expect(peakOf(middle, 3).top, lessThan(59 + 83));
      // Its neighbours slide off the pill instead and need nothing.
      expect(g.slot('r0c0').hintNeedsCounter(3), isFalse);
      expect(g.slot('r0c2').hintNeedsCounter(3), isFalse);
      // Only the top shelf sits under the counter.
      for (final id in ['r1c1', 'r2c1']) {
        expect(g.slot(id).hintNeedsCounter(3), isFalse, reason: id);
      }
    });

    test('an arrow that clears the HUD is left where the design puts it', () {
      for (final viewport in screens.values) {
        for (final shape in [mainBoard, level9]) {
          final g = BoardLayout.compute(shape, viewport);
          final safeTop = viewport.padding.top;
          for (final slot in g.slots) {
            for (var size = 1; size <= shape.maxSize; size++) {
              final fs = slot.furnitureScale;
              final designedTop =
                  slot.dollTopY(size) + (-58 - _K.hintArrowBob) * fs;
              if (designedTop < safeTop + 83 + 4) continue;
              expect(slot.hintArrowCenterX(size), slot.centerX);
              expect(
                slot.hintArrowCenterY(size),
                closeTo(slot.dollTopY(size) - 33 * fs, 1e-9),
              );
            }
          }
        }
      }
    });
  });
}
