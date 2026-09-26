// BoardLayout off the reference screen: the fit (render §1) and the
// spec §10.3 hit areas on the five acceptance screens.
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import 'board_fixtures.dart';

void main() {
  group('fit: s = min(W/390, (barTop − hudBottom)/592, 1.5), centred', () {
    test('360×640 is height-limited and centred horizontally', () {
      final fit = BoardLayout.fitFor(screens['360×640']!);
      // hudBottom 24 + 83 = 107, barTop 640 − 76 = 564.
      expect(fit.scale, closeTo(457 / 592, exact));
      expect(fit.originY, closeTo(107, exact));
      expect(fit.originX, closeTo((360 - 390 * 457 / 592) / 2, exact));
    });

    test('430×932 is width-limited and centred vertically', () {
      final fit = BoardLayout.fitFor(screens['430×932']!);
      const s = 430 / 390;
      expect(fit.scale, closeTo(s, exact));
      expect(fit.originX, closeTo(0, exact));
      expect(fit.originY, closeTo(142 + (680 - 592 * s) / 2, exact));
    });

    test('a large tablet stops at 1.5', () {
      const viewport = BoardViewport(
        size: Size(1024, 1366),
        padding: EdgeInsets.only(top: 24, bottom: 20),
      );
      final fit = BoardLayout.fitFor(viewport);
      expect(fit.scale, 1.5);
      expect(fit.frame.center.dx, closeTo(512, exact));
      expect(fit.frame.center.dy, closeTo(viewport.boardArea.center.dy, exact));
    });

    test('side insets narrow the area', () {
      const viewport = BoardViewport(
        size: Size(390, 844),
        padding: EdgeInsets.fromLTRB(20, 59, 20, 34),
      );
      final fit = BoardLayout.fitFor(viewport);
      expect(fit.scale, closeTo(350 / 390, exact));
      expect(fit.frame.center.dx, closeTo(195, exact));
    });

    test('a viewport with no area still lays out without NaN', () {
      final g = BoardLayout.compute(
        mainBoard,
        const BoardViewport(size: Size.zero),
      );
      expect(g.scale, BoardLayoutConstants.minScale);
      for (final s in g.slots) {
        expect(s.centerX.isFinite, isTrue);
        expect(s.surfaceY.isFinite, isTrue);
        expect(s.hitRect.width, greaterThanOrEqualTo(48));
      }
    });

    test('every length scales by s', () {
      final ref = BoardLayout.compute(mainBoard, BoardViewport.reference);
      final big = BoardLayout.compute(mainBoard, screens['430×932']!);
      final s = big.scale;
      for (var i = 0; i < ref.slots.length; i++) {
        final a = ref.slots[i];
        final b = big.slots[i];
        expect(b.centerX, closeTo(big.fit.x(a.centerX), 1e-6));
        expect(b.surfaceY, closeTo(big.fit.y(a.surfaceY), 1e-6));
        expect(b.standRect.width, closeTo(a.standRect.width * s, 1e-6));
        expect(
          b.glassCaseRect.height,
          closeTo(a.glassCaseRect.height * s, 1e-6),
        );
        expect(b.furnitureScale, closeTo(s, 1e-9));
      }
      for (var size = 1; size <= 4; size++) {
        expect(big.dollHeight(size), closeTo(ref.dollHeight(size) * s, 1e-6));
      }
    });
  });

  group('hit areas on 5 screens (spec §10.3)', () {
    final boards = <String, BoardShape>{
      'MAIN 4/4/3': mainBoard,
      'TUT1 3/3': tutorialBoard,
      'BONUS 4/4/3 maxSize 5': bonusBoard,
      'FULL + 2 extras 4/3/5': fullBoard
          .withExtraSlot('x0')
          .withExtraSlot('x1'),
      '4 shelves 5/5/5/4': board([
        'ooooo',
        'toooo',
        'ooloo',
        'oooo',
      ], maxSize: 6),
      '1 shelf 5': board(['otolo'], maxSize: 4),
    };

    for (final screen in screens.entries) {
      for (final entry in boards.entries) {
        test('${entry.key} on ${screen.key}', () {
          final g = BoardLayout.compute(entry.value, screen.value);
          final w = screen.value.size.width;
          for (final s in g.slots) {
            final reason = '${s.id} on ${screen.key}';
            expect(s.hitRect.width, greaterThanOrEqualTo(48), reason: reason);
            expect(s.hitRect.height, greaterThanOrEqualTo(48), reason: reason);
            // Up to 5 slots a row, the natural column is already ≥ 48.
            expect(s.pitch, greaterThanOrEqualTo(48), reason: reason);
            expect(g.slotAt(s.hitRect.center), same(s), reason: reason);
            expect(g.slotAt(s.standRect.center), same(s), reason: reason);
            final doll = s.dollRect(g.shape.maxSize);
            expect(g.slotAt(doll.center), same(s), reason: reason);
            expect(
              g.slotIndexAt(s.centerX, s.surfaceY),
              s.index,
              reason: reason,
            );
            expect(s.standRect.left, greaterThanOrEqualTo(0), reason: reason);
            expect(s.standRect.right, lessThanOrEqualTo(w), reason: reason);
          }
          // Columns of a shelf don't overlap, and shelves share no band.
          for (final shelf in g.shelves) {
            for (var i = 1; i < shelf.slots.length; i++) {
              expect(
                shelf.slots[i - 1].hitRect.right,
                lessThanOrEqualTo(shelf.slots[i].hitRect.left + 1e-9),
              );
            }
          }
          for (var r = 1; r < g.shelves.length; r++) {
            expect(
              g.shelves[r - 1].hitBottom,
              closeTo(g.shelves[r].hitTop, 1e-9),
            );
          }
          expect(g.fit.frame.top, greaterThanOrEqualTo(g.boardArea.top - 1e-9));
          expect(
            g.fit.frame.bottom,
            lessThanOrEqualTo(g.boardArea.bottom + 1e-9),
          );
        });
      }
    }

    test('6 slots at 360×640: columns widen to 48 and the nearest wins', () {
      final g = BoardLayout.compute(
        board(['oooo', 'oooo', 'ooooxx'], maxSize: 4),
        screens['360×640']!,
      );
      final row = g.shelves[2];
      expect(row.pitch, lessThan(48));
      for (final s in row.slots) {
        expect(s.hitRect.width, closeTo(48, 1e-9));
        expect(g.slotAt(Offset(s.centerX, s.surfaceY)), same(s));
        expect(
          g.slotAt(Offset(s.centerX + row.pitch * 0.45, s.surfaceY)),
          same(s),
        );
        expect(
          g.slotAt(Offset(s.centerX - row.pitch * 0.45, s.surfaceY)),
          same(s),
        );
      }
    });
  });

  group('slotAt misses', () {
    final g = BoardLayout.compute(mainBoard, BoardViewport.reference);

    test('outside the columns of a 3-slot shelf', () {
      // Row 2 columns span 51…339.
      expect(g.slotAt(const Offset(40, 650)), isNull);
      expect(g.slotAt(const Offset(350, 650)), isNull);
      expect(g.slotAt(const Offset(52, 650))?.id, 'r2c0');
    });

    test('above the frame and on the booster bar', () {
      expect(g.slotAt(const Offset(195, 120)), isNull);
      expect(g.slotAt(const Offset(195, 730)), isNull);
      expect(g.slotIndexAt(195, 730), -1);
    });

    test('a doll head above its plank still belongs to its shelf', () {
      expect(g.slotAt(const Offset(148.5, 360))?.id, 'r1c1');
      expect(g.slotAt(const Offset(148.5, 351))?.id, 'r0c1');
    });

    test('lookups by id', () {
      expect(g.slot('r2c1').column, 1);
      expect(g.slotOrNull('x0'), isNull);
      expect(() => g.slot('nope'), throwsArgumentError);
    });
  });
}
