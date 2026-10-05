// m7-4 5.1 to 5.3: glass, tall glass and ice scale with the stand (and on
// four shelves with the dolls' k), the tall case is capped at pitch - 2,
// neighbouring ice overlaps by at most 3 dp, and the tower stack keeps the
// 8 dp under the family counter with true silhouette sizes (tokens.json
// `layout.boardPresets.fourShelves.pieces`, `layout.board.overlays`,
// `layout.towerStack.d21`).
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import 'board_fixtures.dart';

void main() {
  group('overlays follow the stand (5.1)', () {
    test('a row of 5: the glass case and the ice are 0.8 of a row of 4', () {
      final g = BoardLayout.compute(
        board(['ooooo', 'oolol', 'ooo'], maxSize: 4, lockedSize: 2),
        BoardViewport.reference,
      );
      final s = g.slot('r1c2');
      final fit = g.scale * 0.8;
      expect(s.pieceScale, closeTo(0.8, 1e-9));
      expect(s.glassCaseRect.width, closeTo(86 * fit, 1e-9));
      expect(s.glassCaseRect.height, closeTo(143 * fit, 1e-9));
      expect(s.iceRect.width, closeTo(96 * fit, 1e-9));
      expect(s.iceRect.height, closeTo(160 * fit, 1e-9));
      expect(s.overlayFurnitureScale, closeTo(s.furnitureScale, 1e-9));
    });

    test('the tall case is capped at pitch - 2', () {
      final g = BoardLayout.compute(
        board(['ooooo', 'ooloo', 'ooooo'], maxSize: 6, lockedSize: 6),
        BoardViewport.reference,
      );
      final s = g.slot('r1c2');
      expect(s.usesTallCase, isTrue);
      expect(
        s.glassCaseRect.width,
        lessThanOrEqualTo(s.pitch - 2 * g.scale + 1e-9),
      );
    });

    test('neighbouring ice overlaps by at most 3 dp on every row length', () {
      for (final rows in [
        ['oooo', 'oooo', 'ooo'],
        ['ooooo', 'ooooo', 'ooooo'],
      ]) {
        final g = BoardLayout.compute(
          board(rows, maxSize: 4),
          BoardViewport.reference,
        );
        for (final shelf in g.shelves) {
          for (var i = 1; i < shelf.slots.length; i++) {
            final overlap =
                shelf.slots[i - 1].iceRect.right - shelf.slots[i].iceRect.left;
            expect(overlap, lessThanOrEqualTo(3 * g.scale + 1e-9));
          }
        }
      }
    });
  });

  group('four shelves: the pieces scale with k (5.2)', () {
    test('the ice and the glass are k times a normal one, about the stand '
        'surface', () {
      final g = BoardLayout.compute(
        board(['oooo', 'oooo', 'oloo', 'oooo'], maxSize: 4, lockedSize: 3),
        BoardViewport.reference,
      );
      expect(g.preset, same(ShelfPresets.four));
      final k = g.dollHeightScale;
      expect(k, lessThan(1));
      final s = g.slot('r2c1');
      expect(s.iceRect.height, closeTo(160 * k * g.scale, 1e-9));
      expect(s.iceRect.width, closeTo(96 * k * g.scale, 1e-9));
      expect(s.glassCaseRect.height, closeTo(143 * k * g.scale, 1e-9));
      expect(s.glassCaseRect.width, closeTo(86 * k * g.scale, 1e-9));
      expect(s.overlayFurnitureScale, closeTo(s.furnitureScale * k, 1e-9));
      // The design's k about the stand surface: the ice's bottom keeps its
      // place relative to the surface, scaled, so it ends lower than a
      // k = 1 ice (160 tall) would.
      final bottom = s.surfaceY + (s.iceRect.bottom - s.surfaceY);
      expect(s.iceRect.top, greaterThan(bottom - 160 * g.scale));
    });
  });

  group('the tower stack keeps its clearance with true sizes (5.3)', () {
    test('every drawn silhouette stays under hudClearY on the top shelf', () {
      // A size-6 top leaves no room at all (one silhouette, 0 apart).
      for (var maxSize = 3; maxSize <= 5; maxSize++) {
        final g = BoardLayout.compute(
          board(['otoo', 'oooo', 'ooo'], maxSize: maxSize),
          BoardViewport.reference,
        );
        final s = g.slot('r0c1');
        for (var buried = 1; buried <= 4; buried++) {
          final drawn = s.buriedDrawn(buried, topSize: maxSize);
          expect(drawn, greaterThanOrEqualTo(1));
          for (var depth = 1; depth <= drawn; depth++) {
            // The tallest nest at every depth is the worst case.
            final top =
                s.buriedBaseY(depth, buried: buried, topSize: maxSize) -
                s.dollHeight(maxSize) * BoardFitTokens.drawnHeight;
            expect(
              top,
              greaterThanOrEqualTo(g.fit.y(BoardFitTokens.hudClearY) - 0.5),
              reason: 'maxSize $maxSize, $buried buried, depth $depth',
            );
          }
        }
      }
    });
  });
}
