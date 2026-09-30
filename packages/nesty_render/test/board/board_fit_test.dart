// The board fit (tokens.json v3 `layout.boardFit`, D180): one factor k per
// level, `min(1, min(V, HUD, H) / heightOf(maxSize))`, checked against the
// design's own results for every preset (`layout.boardPresets`) within
// 0.1 dp.
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import 'board_fixtures.dart';

const _tol = 0.1;

/// A board of [shelves] rows of 4 slots (the presets' own row width).
BoardShape _rowsOf4(int shelves, int maxSize) =>
    board([for (var r = 0; r < shelves; r++) 'oooo'], maxSize: maxSize);

void _expectLimits(BoardFitLimits actual, BoardFitLimits token, String label) {
  expect(actual.vertical, closeTo(token.vertical, _tol), reason: '$label V');
  expect(actual.hud, closeTo(token.hud, _tol), reason: '$label HUD');
  expect(
    actual.horizontal,
    closeTo(token.horizontal, _tol),
    reason: '$label H',
  );
}

void main() {
  group('every preset matches the design (layout.boardPresets)', () {
    for (final (name, preset, token) in [
      ('twoShelves', ShelfPresets.two, BoardPresetTokens.twoShelves),
      ('threeShelves', ShelfPresets.three, BoardPresetTokens.threeShelves),
      (
        'threeShelvesTall',
        ShelfPresets.threeTall,
        BoardPresetTokens.threeShelvesTall,
      ),
      ('fourShelves', ShelfPresets.four, BoardPresetTokens.fourShelves),
    ]) {
      for (final entry in token.dollHeights.entries) {
        test('$name, maxSize ${entry.key}: limits and heights', () {
          final shape = _rowsOf4(preset.shelfCount, entry.key);
          final result = BoardLayout.fitDolls(shape, preset);
          _expectLimits(result.limits, token.limits, name);
          expect(result.heights, hasLength(entry.value.length));
          for (var i = 0; i < entry.value.length; i++) {
            expect(
              result.heights[i],
              closeTo(entry.value[i], _tol),
              reason: '$name maxSize ${entry.key} size ${i + 1}',
            );
          }
          // And the layout on the reference screen gives the same (its
          // scale is 1 there), for the preset the shape actually takes (a
          // size-6 board on 3 shelves takes the tall one).
          if (!identical(ShelfPresets.forShape(shape), preset)) return;
          final g = BoardLayout.compute(shape, BoardViewport.reference);
          expect(g.preset.plankTops, token.plankTops);
          for (var i = 0; i < entry.value.length; i++) {
            expect(g.dollHeight(i + 1), closeTo(entry.value[i], _tol));
          }
        });
      }
    }

    test('rowOfFive: the width limit is 119.6, maxSize 4 keeps its sizes', () {
      const token = BoardPresetTokens.rowOfFive;
      for (final entry in token.dollHeights.entries) {
        final shape = board(['oooo', 'oooo', 'ooooo'], maxSize: entry.key);
        final result = BoardLayout.fitDolls(shape, ShelfPresets.three);
        _expectLimits(result.limits, token.limits, 'rowOfFive');
        for (var i = 0; i < entry.value.length; i++) {
          expect(
            result.heights[i],
            closeTo(entry.value[i], _tol),
            reason: 'maxSize ${entry.key} size ${i + 1}',
          );
        }
      }
      // The stand is 72 × 27.2 (towers 72 × 31.2) at 0.8.
      final g = BoardLayout.compute(
        board(['oooo', 'oooo', 'ooooo'], maxSize: 4),
        BoardViewport.reference,
      );
      final row = g.shelves.last;
      expect(row.pitch, closeTo(token.pitch, 1e-9));
      expect(row.pieceScale, closeTo(token.standScale, 1e-9));
      expect(row.slots.first.standRect.size.width, closeTo(72, 1e-9));
      expect(row.slots.first.standRect.size.height, closeTo(27.2, 1e-9));
      expect(row.slots.first.dollHeight(4), closeTo(117, _tol));
    });
  });

  group('the design\'s worked examples (architecture §2.1)', () {
    test('3 shelves at maxSize 6 would fit at 135.9, so the tall preset '
        'exists; on it size 6 is 142.1', () {
      final shape = _rowsOf4(3, 6);
      final onUsual = BoardLayout.fitDolls(shape, ShelfPresets.three);
      expect(onUsual.heights.last, closeTo(135.9, _tol));
      expect(onUsual.k, closeTo(0.906, 0.001));
      final onTall = BoardLayout.fitDolls(shape, ShelfPresets.threeTall);
      expect(onTall.heights.last, closeTo(142.1, _tol));
      expect(ShelfPresets.forShape(shape), same(ShelfPresets.threeTall));
    });

    test('maxSize 5 on 3 shelves: 133.5, no shrink', () {
      final result = BoardLayout.fitDolls(_rowsOf4(3, 5), ShelfPresets.three);
      expect(result.heights.last, closeTo(133.5, _tol));
      expect(result.k, 1);
    });

    test('four shelves: 93.5; a row of 5 at maxSize 5: 119.6', () {
      expect(
        BoardLayout.fitDolls(_rowsOf4(4, 4), ShelfPresets.four).heights.last,
        closeTo(93.5, _tol),
      );
      expect(
        BoardLayout.fitDolls(
          board(['oooo', 'oooo', 'ooooo'], maxSize: 5),
          ShelfPresets.three,
        ).heights.last,
        closeTo(119.6, _tol),
      );
    });

    test('a row of 6: H = (59.6 − 8) / 0.5353 = 96.4, so maxSize 4 gives '
        '52 / 66.8 / 81.7 / 96.5 (the ui-spec example)', () {
      final result = BoardLayout.fitDolls(
        board(['oooo', 'oooo', 'oooooo'], maxSize: 4),
        ShelfPresets.three,
      );
      expect(result.limits.horizontal, closeTo(96.4, _tol));
      for (final (i, h) in [52.0, 66.8, 81.7, 96.5].indexed) {
        expect(result.heights[i], closeTo(h, 0.2), reason: 'size ${i + 1}');
      }
    });

    test('one shelf has no vertical limit', () {
      final result = BoardLayout.fitDolls(
        board(['oooo'], maxSize: 6),
        ShelfPresets.one,
      );
      expect(result.limits.vertical, double.infinity);
      expect(result.k, lessThanOrEqualTo(1));
    });
  });

  group('the fit is device independent', () {
    test('the same k on every screen; heights scale with the board', () {
      final shape = _rowsOf4(3, 6);
      final reference = BoardLayout.compute(shape, BoardViewport.reference);
      for (final viewport in screens.values) {
        final g = BoardLayout.compute(shape, viewport);
        expect(g.dollHeightScale, closeTo(reference.dollHeightScale, 1e-9));
        expect(
          g.maxDollHeight / g.scale,
          closeTo(reference.maxDollHeight, 1e-6),
        );
      }
    });
  });
}
