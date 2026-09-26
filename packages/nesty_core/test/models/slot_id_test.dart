// Spec §4: "slots (flattened, stable ids "r{row}c{col}" + "x{n}" for extra
// slots)". Design A7: ids are 0-based; extra slots go on the bottom shelf.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

void main() {
  group('SlotId', () {
    test('grid ids are r{row}c{col}', () {
      expect(SlotId.grid(0, 0), 'r0c0');
      expect(SlotId.grid(0, 1), 'r0c1');
      expect(SlotId.grid(3, 4), 'r3c4');
      expect(SlotId.grid(12, 10), 'r12c10');
    });

    test('extra ids are x{n}, 0-based (design A7)', () {
      expect(SlotId.extra(0), 'x0');
      expect(SlotId.extra(1), 'x1');
    });

    test('isExtra tells the two apart', () {
      expect(SlotId.isExtra(SlotId.extra(0)), isTrue);
      expect(SlotId.isExtra(SlotId.extra(1)), isTrue);
      expect(SlotId.isExtra(SlotId.grid(0, 0)), isFalse);
    });

    test('rejects negative indexes', () {
      expect(() => SlotId.grid(-1, 0), throwsRangeError);
      expect(() => SlotId.grid(0, -1), throwsRangeError);
      expect(() => SlotId.extra(-1), throwsRangeError);
    });
  });

  group('BoardPosition', () {
    test('holds row and column', () {
      const position = BoardPosition(1, 2);
      expect(position.row, 1);
      expect(position.col, 2);
      expect(position.toString(), '(1, 2)');
    });

    test('equality by value', () {
      expect(const BoardPosition(1, 2), BoardPosition(1, int.parse('2')));
      expect(
        const BoardPosition(1, 2).hashCode,
        BoardPosition(1, int.parse('2')).hashCode,
      );
      expect(const BoardPosition(1, 2), isNot(const BoardPosition(2, 1)));
    });
  });
}
