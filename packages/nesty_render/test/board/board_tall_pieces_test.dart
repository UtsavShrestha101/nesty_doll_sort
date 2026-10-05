// The m7-3 pieces of the board (phase 4 lane B): the tall glass case, the
// tall ice, the tower stack and the iced tower. Every number is the design's
// (tokens.json `layout.board.glassCaseTall`, `iceOverlayTall`, `layout.
// towerStack`, `layout.icedTower`), checked against its worked examples.
import 'dart:ui' show Size;

import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import 'board_fixtures.dart';

const _tol = 0.1;

void main() {
  group('the tall glass case (B.4)', () {
    BoardGeometry sealed(int size, {int maxSize = 6, String rows = 'oooo'}) =>
        BoardLayout.compute(
          board([rows, 'oooo', 'oloo'], maxSize: maxSize, lockedSize: size),
          BoardViewport.reference,
        );

    test('a size-6 doll on the tall preset: 88 × 144, bottom at surface + '
        '0.02667 h, the doll on the stand', () {
      final g = sealed(6);
      final s = g.slot('r2c1');
      final h = g.dollHeight(6);
      expect(h, closeTo(142.1, _tol));
      expect(s.usesTallCase, isTrue);
      expect(s.glassCaseRect.width, closeTo(0.62 * h, 1e-9));
      expect(s.glassCaseRect.height, closeTo(1.0133 * h, 1e-9));
      expect(s.glassCaseRect.size, isNot(const Size(86, 143)));
      expect(s.glassCaseRect.width, closeTo(88, 0.2));
      expect(s.glassCaseRect.height, closeTo(144, 0.2));
      expect(s.glassCaseRect.center.dx, closeTo(s.centerX, 1e-9));
      expect(s.glassCaseRect.bottom, closeTo(s.surfaceY + 0.02667 * h, 1e-9));
      // Not raised: the doll stands on the stand, so the unlock has no
      // settle to add.
      expect(s.lockedDollBaseY, s.surfaceY);
      expect(s.restingBaseY, s.surfaceY);
      expect(s.unlockedDollBaseY, s.surfaceY);
      expect(s.unlockSettle, 0);
      // The padlock symbol: 12 dp at caseTop + 0.898 × caseHeight.
      expect(s.padlockSymbolSize, 12);
      expect(
        s.padlockSymbolCenter.dy,
        closeTo(s.glassCaseRect.top + 0.898 * s.glassCaseRect.height, 1e-9),
      );
      expect(s.padlockSymbolCenter.dx, s.centerX);
    });

    test('a size-5 doll on three shelves: 83 × 135 (the design\'s sizes)', () {
      final g = sealed(5, maxSize: 5);
      final s = g.slot('r2c1');
      expect(g.preset, same(ShelfPresets.three));
      expect(s.usesTallCase, isTrue);
      expect(s.glassCaseRect.width, closeTo(83, 0.5));
      expect(s.glassCaseRect.height, closeTo(135, 0.5));
    });

    test('sizes 1 to 4 keep the normal 86 × 143 case (117 dp is not above '
        '117.5)', () {
      for (var size = 1; size <= 4; size++) {
        final g = sealed(size, maxSize: 5);
        final s = g.slot('r2c1');
        expect(s.usesTallCase, isFalse, reason: 'size $size');
        expect(s.glassCaseRect.size, const Size(86, 143));
        expect(s.lockedDollBaseY, isNot(s.surfaceY));
        expect(s.unlockSettle, closeTo(11, 1e-9));
      }
    });

    test('an unknown sealed size, an open slot or a slot outside the board '
        'keep the normal case', () {
      final g = BoardLayout.compute(
        board(['oooo', 'oooo', 'oloo'], maxSize: 6),
        BoardViewport.reference,
      );
      expect(g.slot('r2c1').usesTallCase, isFalse);
      expect(g.slot('r2c0').usesTallCase, isFalse);
      // A sealed size beyond the board's sizes reads as unknown.
      final beyond = BoardLayout.compute(
        board(['oooo', 'oooo', 'oloo'], maxSize: 4, lockedSize: 6),
        BoardViewport.reference,
      );
      expect(beyond.slot('r2c1').usesTallCase, isFalse);
    });

    test('a doll taller than its case was drawn for switches with the row: '
        'a size-4 doll on a row of 5 (117 > 117.5 × 0.8)', () {
      final g = BoardLayout.compute(
        board(['oooo', 'oooo', 'olooo'], maxSize: 4, lockedSize: 4),
        BoardViewport.reference,
      );
      final s = g.slot('r2c1');
      expect(s.pieceScale, closeTo(0.8, 1e-9));
      expect(s.usesTallCase, isTrue);
      // The case still fits its column.
      expect(s.glassCaseRect.width, lessThan(s.pitch));
    });

    test('the composition: fx_glass_unlock_tall\'s stand surface (100, 212) on '
        '(cx, surface), the case at (53.5, 64) at 100 %', () {
      for (final viewport in [
        BoardViewport.reference,
        const BoardViewport(size: Size(360, 640)),
        const BoardViewport(size: Size(768, 1024)),
      ]) {
        final g = BoardLayout.compute(
          board(['oooo', 'oooo', 'oloo'], maxSize: 6, lockedSize: 6),
          viewport,
        );
        final s = g.slot('r2c1');
        final fs = s.furnitureScale;
        final o = s.glassCompositionOrigin;
        expect(o.dx + 100 * fs, closeTo(s.centerX, 1e-9));
        expect(o.dy + 212 * fs, closeTo(s.surfaceY, 1e-9));
        // With case_size = h / (150 · fs) the composition's 93×152 case
        // becomes 0.62 h × 1.0133 h, exactly the static case.
        final caseScale = s.dollHeight(6) / (150 * fs);
        expect(
          s.centerX - (100 - 53.5) * fs * caseScale,
          closeTo(s.glassCaseRect.left, 1e-9),
          reason: '$viewport',
        );
        expect(
          s.surfaceY + (216 - 212) * fs * caseScale,
          closeTo(s.glassCaseRect.bottom, 0.01), // 4/150 is 0.02667 rounded
        );
      }
    });
  });

  group('the tall ice (B.3, B.7)', () {
    test('threeShelvesTall: 96 × 168, top = plankTop + 16.5 − 168, played '
        'stretched by 1.05 from its bottom', () {
      final g = BoardLayout.compute(
        board(['oooo', 'oooo', 'oooo'], maxSize: 6),
        BoardViewport.reference,
      );
      final s = g.slot('r1c1');
      expect(s.iceRect.size, const Size(96, 168));
      expect(s.iceRect.top, closeTo(494 + 16.5 - 168, 1e-9));
      expect(s.iceRect.bottom, closeTo(494 + 16.5, 1e-9));
      expect(s.iceFxScaleY, 1.05);
      final o = s.iceCompositionOrigin;
      final fs = s.furnitureScale;
      // Canvas (90, 200) on the overlay's bottom centre.
      expect(o.dx + 90 * fs, closeTo(s.centerX, 1e-9));
      expect(o.dy + 200 * fs * 1.05, closeTo(s.iceRect.bottom, 1e-9));
      // The ice inside the canvas (42, 40)…(138, 200) fills the overlay.
      expect(o.dy + 40 * fs * 1.05, closeTo(s.iceRect.top, 1e-9));
      // The doll's base (90, 170.8), stretched, lands 1.46·fs above the
      // surface ("its base lands 1.5 dp high; the test allows 2").
      final base = o.dy + 170.8 * fs * 1.05;
      expect(s.surfaceY - base, closeTo(1.46 * fs, 0.01));
      expect(s.surfaceY - base, lessThan(2));
    });

    test('the other presets keep the 160 tall ice, unstretched', () {
      final g = BoardLayout.compute(
        board(['oooo', 'oooo', 'oooo'], maxSize: 5),
        BoardViewport.reference,
      );
      final s = g.slot('r1c1');
      expect(s.iceRect.size, const Size(96, 160));
      expect(s.iceFxScaleY, 1);
      expect(s.iceRect.top, closeTo(498 + 16.5 - 160, 1e-6));
    });

    test('the ice on a tower stand keeps the design\'s place (iceTower)', () {
      final g = BoardLayout.compute(
        board(['oooo', 'otoo', 'ooo'], maxSize: 4),
        BoardViewport.reference,
      );
      final s = g.slot('r1c1');
      expect(s.iceRect.bottom, closeTo(498 + 16.5, 1e-9));
      expect(s.iceRect.top, closeTo(498 + 16.5 - 160, 1e-9));
    });
  });

  group('the tower stack (B.5)', () {
    late BoardGeometry g;
    setUp(() {
      g = BoardLayout.compute(
        board(['otoo', 'otoo', 'ooo'], maxSize: 5),
        BoardViewport.reference,
      );
    });

    test(
      'top shelf, size-4 top, 3 buried: step 10.8 x 0.9661 (d21), the deepest ends at '
      'y 150',
      () {
        final s = g.slot('r0c1');
        final stack = s.towerStack(4, 3);
        expect(stack.step, closeTo(10.8 * 0.9661, 0.05));
        expect(stack.drawn, 3);
        expect(s.surfaceY, closeTo(312 - 17.7, 1e-9));
        // hRoom − topHeight = 3 steps, and hRoom is what reaches y 150.
        final hRoom = (s.surfaceY - 150) / 0.9661;
        expect(hRoom, closeTo(149.4, 0.05));
        // d21: the deepest visible top, N steps + the top's drawn height up,
        // lands exactly on the limit.
        expect(3 * stack.step + 117 * 0.9661, closeTo(s.surfaceY - 150, 1e-6));
        expect(hRoom, closeTo(149.4, 0.05));
      },
    );

    test('top shelf, size-3 top: 16.8; middle shelf, size-1 top: 18', () {
      expect(
        g.slot('r0c1').towerStack(3, 3).step,
        closeTo(16.8 * 0.9661, 0.05),
      );
      expect(g.slot('r1c1').towerStack(1, 3).step, 18);
    });

    test('fewer nests keep the full 18 where they fit', () {
      final s = g.slot('r0c1');
      expect(s.towerStack(4, 1).step, 18);
      expect(s.towerStack(4, 1).drawn, 1);
    });

    test('below a 9 dp step fewer silhouettes are drawn, at up to 9', () {
      // A size-5 top (133.5) on the top shelf leaves 15.9 of room: 3 nests
      // would step 5.3, so one silhouette is drawn, 9 apart.
      final s = g.slot('r0c1');
      final stack = s.towerStack(5, 3);
      expect(stack.drawn, 1);
      expect(stack.step, closeTo(9, 1e-9));
      // Room for two at 9: 2 × 9 + top.
      final wide = g.slot('r1c1');
      final middle = wide.towerStack(4, 3);
      expect(middle.drawn, 1);
      expect(middle.step, closeTo(9, 1e-9));
      expect(wide.buriedDrawn(3, topSize: 4), 1);
      expect(wide.buriedDrawn(3, topSize: 1), 3);
      // Never more than the tower buries.
      expect(wide.buriedDrawn(1, topSize: 1), 1);
    });

    test('the step never goes negative and the count stays at least one', () {
      final s = g.slot('r0c1');
      for (var top = 1; top <= 5; top++) {
        for (var n = 1; n <= 3; n++) {
          final stack = s.towerStack(top, n);
          expect(stack.step, greaterThanOrEqualTo(0));
          expect(stack.drawn, greaterThanOrEqualTo(1));
          expect(
            s.buriedBaseY(1, buried: n, topSize: top),
            lessThan(s.surfaceY + 1e-9),
          );
        }
      }
    });

    test('the silhouettes of a size-1 top stay under the HUD', () {
      final s = g.slot('r0c1');
      final rect = s.buriedSilhouetteRect(3, 1, buried: 3, topSize: 1);
      expect(rect.top, greaterThanOrEqualTo(g.fit.y(150) - 1e-9));
    });

    test('an iced tower keeps its silhouettes inside the ice: limit = ice '
        'top + 8', () {
      final s = g.slot('r0c1');
      // Ice top on the top shelf: 312 + 16.5 − 160 = 168.5, so the limit
      // rises from 150 to 176.5.
      const iceTop = 312 + 16.5 - 160;
      final hRoom = (312 - 17.7 - (iceTop + 8)) / 0.9661;
      final open = s.towerStack(1, 3);
      final iced = s.towerStack(1, 3, iced: true);
      expect(open.step, 18);
      expect(hRoom, closeTo(121.9, 0.1));
      expect(iced.step, closeTo(18, 1e-9));
      // A size-4 top under the same ice is squeezed to one silhouette.
      final tight = s.towerStack(4, 3, iced: true);
      expect(tight.drawn, 1);
      expect(tight.step, closeTo((hRoom - 117) * 0.9661, 1e-6));
      expect(tight.step, lessThan(open.step));
    });
  });

  group('the family counter and the hint arrow (E.20)', () {
    test('only a top-shelf column right under the counter needs it', () {
      final g = BoardLayout.compute(
        board(['ooo', 'ooo', 'ooo'], maxSize: 3),
        const BoardViewport(
          size: Size(393, 852),
          padding: EdgeInsets.only(top: 59, bottom: 34),
        ),
      );
      expect(g.slot('r0c1').hintNeedsCounter(3), isTrue);
      expect(g.slot('r0c0').hintNeedsCounter(3), isFalse);
      expect(g.slot('r1c1').hintNeedsCounter(3), isFalse);
    });
  });
}
