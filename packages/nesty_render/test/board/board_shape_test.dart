import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import 'board_fixtures.dart';

typedef _K = BoardLayoutConstants;

void main() {
  group('BoardShape', () {
    test('rejects boards the layout cannot place', () {
      expect(() => board([], maxSize: 4), throwsArgumentError);
      expect(
        () => board(['oo', 'oo', 'oo', 'oo', 'oo'], maxSize: 4),
        throwsArgumentError,
      );
      expect(() => board(['oo', ''], maxSize: 4), throwsArgumentError);
      expect(() => board(['ooooooo'], maxSize: 4), throwsArgumentError);
      expect(() => board(['oo'], maxSize: 2), throwsArgumentError);
      expect(() => board(['oo'], maxSize: 7), throwsArgumentError);
      expect(
        () => BoardShape(
          rows: const [
            [
              SlotShape('a', SlotShapeKind.open),
              SlotShape('a', SlotShapeKind.open),
            ],
          ],
          maxSize: 3,
        ),
        throwsArgumentError,
      );
      expect(
        () => BoardShape(
          rows: const [
            [SlotShape('', SlotShapeKind.open)],
          ],
          maxSize: 3,
        ),
        throwsArgumentError,
      );
    });

    test('accepts 1–4 shelves of 1–6 slots', () {
      expect(board(['o'], maxSize: 3).slotCount, 1);
      expect(board(List.filled(4, 'oooooo'), maxSize: 6).slotCount, 24);
    });

    test('withExtraSlot appends to the bottom shelf, up to 6 (D22)', () {
      final one = fullBoard.withExtraSlot('x0');
      expect(one.rows.last.last, const SlotShape('x0', SlotShapeKind.extra));
      expect(one.rows.last, hasLength(4));
      expect(one.rows.first, fullBoard.rows.first);
      expect(one.maxSize, fullBoard.maxSize);
      final six = board([
        'oo',
        'oooo',
      ], maxSize: 4).withExtraSlot('x0').withExtraSlot('x1');
      expect(six.rows.last, hasLength(6));
      expect(() => six.withExtraSlot('x2'), throwsArgumentError);
      expect(() => one.withExtraSlot('x0'), throwsArgumentError);
    });

    test('is an immutable value', () {
      expect(
        board(['oto', 'lo'], maxSize: 4),
        board(['oto', 'lo'], maxSize: 4),
      );
      expect(
        board(['oto', 'lo'], maxSize: 4).hashCode,
        board(['oto', 'lo'], maxSize: 4).hashCode,
      );
      expect(board(['oto'], maxSize: 4), isNot(board(['ooo'], maxSize: 4)));
      expect(board(['oto'], maxSize: 4), isNot(board(['oto'], maxSize: 5)));
      final shape = board(['oo'], maxSize: 3);
      expect(() => shape.rows.add(const []), throwsUnsupportedError);
      expect(
        () => shape.rows.first.add(const SlotShape('z', SlotShapeKind.open)),
        throwsUnsupportedError,
      );
    });
  });

  group('ShelfPresets', () {
    test('every preset is the design\'s (tokens.json layout.boardPresets)', () {
      for (final (preset, token) in [
        (ShelfPresets.two, BoardPresetTokens.twoShelves),
        (ShelfPresets.three, BoardPresetTokens.threeShelves),
        (ShelfPresets.threeTall, BoardPresetTokens.threeShelvesTall),
        (ShelfPresets.four, BoardPresetTokens.fourShelves),
      ]) {
        expect(preset.plankTops, token.plankTops);
        expect(preset.maxDollHeight, token.slotMaxDollHeight);
        expect(preset.designed, isTrue);
      }
      expect(
        ShelfPresets.three.plankTops,
        BoardTokens.plankTopsByShelfCount[3],
      );
      expect(ShelfPresets.two.plankTops, BoardTokens.plankTopsByShelfCount[2]);
      expect(ShelfPresets.four.plankTops, BoardTokens.plankTopsByShelfCount[4]);
      expect(
        ShelfPresets.threeTall.plankTops,
        BoardTokens.plankTopsThreeShelvesTall,
      );
      expect(ShelfPresets.three.iceHeight, BoardTokens.iceOverlaySize.height);
      expect(
        ShelfPresets.threeTall.iceHeight,
        BoardTokens.iceOverlayTallSize.height,
      );
      expect(ShelfPresets.threeTall.tall, isTrue);
      expect(ShelfPresets.three.tall, isFalse);
    });

    test('the preset follows the shelf count and, on 3 shelves, maxSize 6', () {
      ShelfPreset of(int shelves, int maxSize) => ShelfPresets.forShape(
        board([for (var r = 0; r < shelves; r++) 'ooo'], maxSize: maxSize),
      );
      expect(of(1, 4), same(ShelfPresets.one));
      expect(of(2, 3), same(ShelfPresets.two));
      expect(of(2, 6), same(ShelfPresets.two));
      expect(of(3, 3), same(ShelfPresets.three));
      expect(of(3, 5), same(ShelfPresets.three));
      expect(of(3, 6), same(ShelfPresets.threeTall));
      expect(of(4, 4), same(ShelfPresets.four));
      for (var n = 1; n <= 4; n++) {
        expect(of(n, 4).shelfCount, n);
      }
    });

    test('plank tops run top to bottom and stay above the booster bar', () {
      for (final preset in [
        ShelfPresets.one,
        ShelfPresets.two,
        ShelfPresets.three,
        ShelfPresets.threeTall,
        ShelfPresets.four,
      ]) {
        final tops = preset.plankTops;
        for (var i = 1; i < tops.length; i++) {
          expect(tops[i], greaterThan(tops[i - 1]));
        }
        expect(
          tops.last + BoardLayoutConstants.plankHeight,
          lessThanOrEqualTo(BoardLayoutConstants.frameBottom),
        );
      }
    });
  });

  group('BoardLayoutConstants', () {
    test('match tokens.json where both carry a value', () {
      expect(_K.referenceWidth, BoardTokens.referenceScreen.width);
      expect(_K.referenceHeight, BoardTokens.referenceScreen.height);
      expect(_K.standWidth, BoardTokens.standSize.width);
      expect(_K.standHeight, BoardTokens.standSize.height);
      expect(_K.towerStandHeight, BoardTokens.towerStandSize.height);
      expect(BoardTokens.towerStandSize.width, _K.standWidth);
      expect(_K.glassCaseWidth, BoardTokens.glassCaseSize.width);
      expect(_K.glassCaseHeight, BoardTokens.glassCaseSize.height);
      expect(_K.iceWidth, BoardTokens.iceOverlaySize.width);
      expect(_K.iceHeight, BoardTokens.iceOverlaySize.height);
      expect(_K.hudPauseButtonHeight, BoardTokens.hudPauseButtonSize.height);
      expect(_K.hudRowBottomInset, 51);
      expect(
        _K.barTopInset,
        BoardTokens.referenceScreen.height -
            BoardTokens.referenceSafeBottom -
            BoardTokens.boosterBarTop,
      );
    });

    test('the reference frame is 390 × 592 at y 142…734 (render §1)', () {
      expect(_K.hudBottomInset, 83);
      expect(_K.barTopInset, 76);
      expect(_K.frameTop, 142);
      expect(_K.frameBottom, 734);
      expect(_K.frameHeight, 592);
      expect(_K.familyCounterCenterInset, 70);
      expect(_K.centerX, 195);
      expect(_K.standPitchInset, 2.4);
      expect(_K.standSurfaceAbovePlank, closeTo(12.7, exact));
      expect(_K.towerSurfaceAbovePlank, closeTo(17.7, exact));
      expect(_K.iceBottomBelowStandBottom, 7.5);
      expect(_K.extraSlotRepitchMs, MotionTokens.rowOfFiveMs);
      expect(_K.padlockCenterBelowCaseTop, closeTo(116.3, 0.05));
    });
  });
}
