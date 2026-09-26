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
    test('designed presets come from tokens.json', () {
      expect(
        ShelfPresets.three.plankTops,
        BoardTokens.plankTopsByShelfCount[3],
      );
      expect(ShelfPresets.two.plankTops, BoardTokens.plankTopsByShelfCount[2]);
      expect(
        ShelfPresets.three.maxDollHeight,
        BoardTokens.slotMaxDollHeightByShelfCount[3],
      );
      expect(
        ShelfPresets.two.maxDollHeight,
        BoardTokens.slotMaxDollHeightByShelfCount[2],
      );
      expect(ShelfPresets.three.designed, isTrue);
      expect(ShelfPresets.two.designed, isTrue);
      expect(ShelfPresets.three.pieceScale, 1);
      expect(ShelfPresets.two.pieceScale, 1);
    });

    test('one preset per shelf count, 1–4', () {
      for (var n = 1; n <= 4; n++) {
        expect(ShelfPresets.forShelfCount(n).shelfCount, n);
      }
      expect(() => ShelfPresets.forShelfCount(0), throwsArgumentError);
      expect(() => ShelfPresets.forShelfCount(5), throwsArgumentError);
    });

    test('plank tops run top to bottom and stay above the booster bar', () {
      for (var n = 1; n <= 4; n++) {
        final tops = ShelfPresets.forShelfCount(n).plankTops;
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
      expect(_K.standShrinkPitch, 93);
      // TUT1's gap: size 3 is 140 tall (93.3 wide) at pitch 96.
      expect(_K.dollMinGap, closeTo(96 - 140 * 2 / 3, exact));
      expect(_K.padlockCenterBelowCaseTop, closeTo(116.3, 0.05));
    });
  });
}
