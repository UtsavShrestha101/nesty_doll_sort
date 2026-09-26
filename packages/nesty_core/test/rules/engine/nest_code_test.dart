// The engine's packed nest code (docs/plans/m1-core-design.md §2):
// `gold << 10 | color << 6 | outer << 3 | length`, at least 9 for any nest,
// 0 for "empty", below 2^13. Merges follow spec §2.2 and the gold hook
// spec §3.5.
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/rules/engine/nest_code.dart';
import 'package:test/test.dart';

import '../support/boards.dart';

void main() {
  test('packs color, outer size and length as design §2 says', () {
    final code = NestCode.of(nest('blue4 blue3'));
    expect(code, DollColor.blue.index << 6 | 4 << 3 | 2);
    expect(NestCode.color(code), DollColor.blue.index);
    expect(NestCode.outer(code), 4);
    expect(NestCode.length(code), 2);
    expect(NestCode.inner(code), 3);
    expect(NestCode.gold(code), 0);
  });

  test('every nest is at least 9 and below 2^13; 0 is empty', () {
    expect(NestCode.empty, 0);
    expect(NestCode.of(nest('red1')), 9);
    for (final color in DollColor.values) {
      for (var outer = 1; outer <= 6; outer++) {
        for (var length = 1; length <= outer; length++) {
          final n = Nest.run(color, outer: outer, length: length);
          final code = NestCode.of(n);
          expect(code, greaterThanOrEqualTo(9));
          expect(code, lessThan(1 << 13));
          expect(NestCode.toNest(code), n);
        }
      }
    }
  });

  test('merge: rule 2 is merge(T, M), rule 3 is merge(M, T)', () {
    final t = NestCode.of(nest('red4 red3'));
    final m = NestCode.of(nest('red2'));
    expect(NestCode.toNest(NestCode.merge(t, m)), nest('red4 red3 red2'));
    final big = NestCode.of(nest('red6 red5'));
    final small = NestCode.of(nest('red4 red3 red2 red1'));
    expect(
      NestCode.toNest(NestCode.merge(big, small)),
      nest('red6 red5 red4 red3 red2 red1'),
    );
  });

  test('isFull is maxSize..1 (spec §2.1)', () {
    expect(NestCode.isFull(NestCode.of(nest('red3 red2 red1')), 3), isTrue);
    expect(NestCode.isFull(NestCode.of(nest('red3 red2 red1')), 4), isFalse);
    expect(NestCode.isFull(NestCode.of(nest('red4 red3 red2')), 4), isFalse);
  });

  group('gold hook (spec §3.5, v1.1; the validator rejects gold today)', () {
    final gold3 = NestCode.of(nest('gold3'));
    final red21 = NestCode.of(nest('red2 red1'));

    test('only gold is wild', () {
      for (final color in DollColor.values) {
        expect(NestCode.isWildColor(color.index), color.isWild);
      }
    });

    test('a gold-only nest matches any color; others need equal colors', () {
      expect(NestCode.colorsMatch(gold3, red21), isTrue);
      expect(NestCode.colorsMatch(red21, gold3), isTrue);
      expect(NestCode.colorsMatch(red21, NestCode.of(nest('blue3'))), isFalse);
      expect(NestCode.colorsMatch(red21, NestCode.of(nest('red3'))), isTrue);
    });

    test('a merged nest takes the non-gold color and remembers gold', () {
      final merged = NestCode.merge(gold3, red21);
      expect(NestCode.color(merged), DollColor.red.index);
      expect(NestCode.outer(merged), 3);
      expect(NestCode.length(merged), 3);
      expect(NestCode.gold(merged), 3);
      expect(NestCode.isFull(merged, 3), isTrue);
      expect(NestCode.ownColorDolls(merged), 2);
      // The gold stays with the nest through later merges.
      final red1 = NestCode.of(nest('red1'));
      final withGold2 = NestCode.merge(NestCode.of(nest('gold2')), red1);
      final bigger = NestCode.merge(NestCode.of(nest('red3')), withGold2);
      expect(NestCode.gold(bigger), 2);
      expect(NestCode.color(bigger), DollColor.red.index);
    });

    test('a gold-only nest counts no dolls of any color', () {
      expect(NestCode.ownColorDolls(gold3), 0);
      expect(NestCode.ownColorDolls(red21), 2);
    });
  });
}
