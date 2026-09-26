// Spec §6.6: "Inside every block of 10 levels, the tier pattern is
// E E M E M H M E M S. Chapters raise the baseline by adding colors, size,
// towers and fewer empty slots." §3.7 introduction schedule: L1 one color,
// maxSize 3; L2 two colors; L3–9 up to 3–4 colors, maxSize 3; L10 maxSize 4;
// L16 towers; L31 locked; L51 ice; L71 maxSize 5; L101 gold (v1.1, not
// generated, D22); L121+ occasional maxSize 6 super hard.
// §7.1: bonus seed 1_000_000 + levelNumber. §7.5: daily seed yyyymmdd, tier
// medium/hard. Design A16: the stage table is the default until the owner's.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

const _pattern = 'EEMEMHMEMS';

/// Every param of [p] except the seed and id, for comparing boards.
List<Object> _board(GeneratorParams p) => [
  p.colors,
  p.setsPerColor,
  p.maxSize,
  p.shelves,
  p.slotsPerShelf,
  p.towers,
  p.towerDepth,
  p.emptySlots,
  p.locked,
  p.iceSlots,
  p.targetTier,
];

void main() {
  group('tierForLevel (spec §6.6)', () {
    test('follows E E M E M H M E M S in every block of 10', () {
      for (var n = 1; n <= 200; n++) {
        final expected = _pattern[(n - 1) % 10];
        expect(
          DifficultyCurve.tierForLevel(n).id[0].toUpperCase(),
          expected,
          reason: 'level $n',
        );
      }
    });

    test('accepts 1..maxLevelNumber only', () {
      expect(DifficultyCurve.maxLevelNumber, 1 << 30);
      expect(
        DifficultyCurve.tierForLevel(DifficultyCurve.maxLevelNumber),
        isA<Tier>(),
      );
      expect(() => DifficultyCurve.tierForLevel(0), throwsRangeError);
      expect(
        () => DifficultyCurve.tierForLevel(DifficultyCurve.maxLevelNumber + 1),
        throwsRangeError,
      );
    });
  });

  group('bonusParams (spec §7.1)', () {
    final levels = [
      for (var n = 1; n <= 300; n++) (n, DifficultyCurve.bonusParams(n)),
    ];

    test('seeded 1_000_000 + n, targeting tierForLevel(n), id bonus-n', () {
      for (final (n, p) in levels) {
        expect(p.seed, 1000000 + n);
        expect(p.seed, DifficultyCurve.bonusSeed(n));
        expect(p.targetTier, DifficultyCurve.tierForLevel(n));
        expect(p.id, 'bonus-$n');
      }
    });

    test('every level has usable params with one set per color', () {
      for (final (n, p) in [
        ...levels,
        (
          DifficultyCurve.maxLevelNumber,
          DifficultyCurve.bonusParams(DifficultyCurve.maxLevelNumber),
        ),
      ]) {
        expect(Generator.checkParams(p), isEmpty, reason: 'level $n: $p');
        expect(p.setsPerColor, 1);
      }
    });

    test('rejects level numbers outside the curve', () {
      expect(() => DifficultyCurve.bonusParams(0), throwsRangeError);
      expect(() => DifficultyCurve.bonusParams(-5), throwsRangeError);
    });

    test('levels 1 and 2 are the one- and two-color boards (§3.7)', () {
      final l1 = DifficultyCurve.bonusParams(1);
      expect((l1.colors, l1.maxSize, l1.towers), (1, 3, 0));
      final l2 = DifficultyCurve.bonusParams(2);
      expect((l2.colors, l2.maxSize, l2.towers), (2, 3, 0));
    });

    test('levels 3–9 use 3–4 colors and maxSize 3 (§3.7)', () {
      for (var n = 3; n <= 9; n++) {
        final p = DifficultyCurve.bonusParams(n);
        expect(p.colors, inInclusiveRange(3, 4), reason: 'level $n');
        expect(p.maxSize, 3, reason: 'level $n');
      }
    });

    test('mechanics start at their §3.7 level and not before', () {
      for (final (n, p) in levels) {
        final reason = 'level $n: $p';
        if (n < 10) expect(p.maxSize, 3, reason: reason);
        if (n >= 10 && n < 71) expect(p.maxSize, 4, reason: reason);
        if (n >= 71) expect(p.maxSize, greaterThanOrEqualTo(5), reason: reason);
        if (n < 16) expect(p.towers, 0, reason: reason);
        if (n >= 16) expect(p.towers, greaterThan(0), reason: reason);
        if (n < 31) expect(p.locked, 0, reason: reason);
        if (n < 51) expect(p.iceSlots, 0, reason: reason);
        // Occasional maxSize 6: exactly the super hard levels from 121.
        expect(
          p.maxSize == 6,
          n >= 121 && p.targetTier == Tier.superhard,
          reason: reason,
        );
      }
      expect(DifficultyCurve.bonusParams(10).maxSize, 4);
      expect(DifficultyCurve.bonusParams(31).locked, greaterThan(0));
      expect(DifficultyCurve.bonusParams(51).iceSlots, greaterThan(0));
      expect(DifficultyCurve.bonusParams(71).maxSize, 5);
    });

    test('doll sizes never shrink from one block to the next', () {
      // Per tier, against the same tier ten levels earlier. Towers may drop
      // where a lock or ice takes over the difficulty (the stage table).
      for (var n = 11; n <= 300; n++) {
        final now = DifficultyCurve.bonusParams(n);
        final before = DifficultyCurve.bonusParams(n - 10);
        expect(
          now.maxSize,
          greaterThanOrEqualTo(before.maxSize),
          reason: 'level $n',
        );
      }
    });

    test('from level 121 the curve repeats every 10 levels', () {
      for (var n = 121; n <= 300; n++) {
        expect(
          _board(DifficultyCurve.bonusParams(n)),
          _board(DifficultyCurve.bonusParams(121 + (n - 121) % 10)),
        );
      }
    });
  });

  group('dailyParams (spec §7.5)', () {
    test('seeded with the date, id daily-yyyymmdd, usable', () {
      for (final date in [20260926, 20260928, 20270101, 20280229]) {
        final p = DifficultyCurve.dailyParams(date);
        expect(p.seed, date);
        expect(p.id, 'daily-$date');
        expect(p.targetTier, DifficultyCurve.dailyTier(date));
        expect(Generator.checkParams(p), isEmpty);
      }
    });

    test('hard on Saturday and Sunday, medium on weekdays', () {
      expect(DifficultyCurve.dailyTier(20260926), Tier.hard); // Saturday
      expect(DifficultyCurve.dailyTier(20260927), Tier.hard); // Sunday
      expect(DifficultyCurve.dailyTier(20260928), Tier.medium); // Monday
      expect(DifficultyCurve.dailyTier(20260925), Tier.medium); // Friday
      expect(DifficultyCurve.dailyTier(20000101), Tier.hard); // Saturday
      expect(DifficultyCurve.dailyTier(10101), Tier.medium); // Monday
      expect(DifficultyCurve.dailyTier(99991231), Tier.medium); // Friday
    });

    test('the weekday matches the calendar for every day of 2020–2031', () {
      for (
        var day = DateTime.utc(2020);
        day.year < 2032;
        day = day.add(const Duration(days: 1))
      ) {
        final date = day.year * 10000 + day.month * 100 + day.day;
        final weekend =
            day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
        expect(
          DifficultyCurve.dailyTier(date),
          weekend ? Tier.hard : Tier.medium,
          reason: '$date',
        );
      }
    });

    test('the medium and hard boards differ only in difficulty', () {
      final medium = DifficultyCurve.dailyParams(20260928);
      final hard = DifficultyCurve.dailyParams(20260926);
      expect(medium.maxSize, hard.maxSize);
      expect(medium.targetTier, Tier.medium);
      expect(hard.targetTier, Tier.hard);
    });

    test('rejects dates that do not exist', () {
      for (final date in [
        20260230,
        20250229,
        19000229,
        20261301,
        20260001,
        20260100,
        20260431,
        0,
        -20260926,
        100000101,
      ]) {
        expect(
          () => DifficultyCurve.dailyParams(date),
          throwsRangeError,
          reason: '$date',
        );
      }
      expect(DifficultyCurve.dailyParams(20000229).seed, 20000229);
      expect(DifficultyCurve.dailyParams(20240229).seed, 20240229);
    });
  });

  group('seeds', () {
    test('bonusSeed is 1_000_000 + n (§7.1)', () {
      expect(DifficultyCurve.bonusSeed(1), 1000001);
      expect(DifficultyCurve.bonusSeed(250), 1000250);
    });

    test('dailySeed is yyyymmdd for real dates only (§7.5)', () {
      expect(DifficultyCurve.dailySeed(2026, 9, 26), 20260926);
      expect(DifficultyCurve.dailySeed(2024, 2, 29), 20240229);
      expect(() => DifficultyCurve.dailySeed(2026, 2, 30), throwsRangeError);
      expect(() => DifficultyCurve.dailySeed(2026, 4, 31), throwsRangeError);
      expect(() => DifficultyCurve.dailySeed(2026, 13, 1), throwsRangeError);
      expect(() => DifficultyCurve.dailySeed(0, 1, 1), throwsRangeError);
    });
  });
}
