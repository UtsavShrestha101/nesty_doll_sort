// The race boards of vs Computer (spec-prop §7.7, the rule until the owner
// pastes it into the spec, Q85).
//
// Spec-prop §7.7:
// - "Rivals: rival 1 plays like the casual bot (§6.4) … on an easy board;
//   rival 2 like the smart bot … on a medium board; rival 3 like the smart
//   bot … on a medium board. … No other bot policy is used."
// - "Board: made by the generator from the curve's params for the rival's
//   tier, at the stage of the player's highest level, with seed
//   `3_000_000 + rival × 100_000 + raceNo`. Both sides start from the same
//   board."
// mode-vs-computer.md rule 3: "a race only uses mechanics the player has met
// (§3.7)"; "It can't collide with the daily (yyyymmdd) or bonus seeds
// (1_000_000 + N)"; "`raceNo` counts that rival's races from 1".
// Spec §3.7: L10 maxSize 4, L16 towers, L31 locked slots, L51 ice, L71
// maxSize 5, L121+ occasional maxSize 6 super hard levels.
// Spec §7.1: bonus seed 1_000_000 + levelNumber. §7.5: daily seed yyyymmdd.
//
// "The stage of the player's highest level" is read as the highest level
// won, the default of an owner question (docs/plans/m7-design.md, Phase 2).
// The expected boards are the curve's documented stage table (curve.dart,
// design A16, confirmed by the owner, Q34), copied here, not read from code.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

/// A board of the stage table: colors, maxSize, shelves × slots, towers ×
/// depth, empty, locked, ice.
typedef _Board = (int, int, int, int, int, int, int, int, int);

_Board _boardOf(GeneratorParams p) => (
  p.colors,
  p.maxSize,
  p.shelves,
  p.slotsPerShelf,
  p.towers,
  p.towers == 0 ? 0 : p.towerDepth,
  p.emptySlots,
  p.locked,
  p.iceSlots,
);

// The stage table of curve.dart, easy and medium rows (race tiers only):
// (colors, maxSize, shelves, slots, towers, depth, empty, locked, ice).
const _stage16Easy = (5, 4, 3, 3, 4, 3, 1, 0, 0);
const _stage16Medium = (6, 4, 3, 3, 5, 4, 1, 0, 0);
const _stage31Easy = (6, 4, 3, 3, 4, 3, 1, 1, 0);
const _stage31Medium = (5, 4, 2, 4, 4, 4, 1, 1, 0);
const _stage51Easy = (6, 4, 3, 3, 4, 3, 1, 0, 1);
const _stage51Medium = (6, 4, 3, 3, 5, 3, 1, 1, 1);
const _stage71Easy = (6, 5, 3, 3, 4, 3, 1, 1, 1);
const _stage71Medium = (6, 5, 3, 3, 4, 4, 1, 1, 0);

/// The board of [rival]'s race when the highest level won is [won]:
/// easy for rival 1, medium for rivals 2 and 3 (spec-prop §7.7).
const _expectedBoards = <int, (_Board, _Board)>{
  20: (_stage16Easy, _stage16Medium),
  30: (_stage16Easy, _stage16Medium),
  31: (_stage31Easy, _stage31Medium),
  50: (_stage31Easy, _stage31Medium),
  51: (_stage51Easy, _stage51Medium),
  70: (_stage51Easy, _stage51Medium),
  71: (_stage71Easy, _stage71Medium),
  120: (_stage71Easy, _stage71Medium),
  // 121+: "E, M, H as 71–120".
  121: (_stage71Easy, _stage71Medium),
  200: (_stage71Easy, _stage71Medium),
};

/// Spec §3.7: the largest doll size a player who has won level [won] has
/// met. maxSize 6 comes only in super hard levels, which races never use.
int _maxSizeMet(int won) => won >= 71 ? 5 : (won >= 10 ? 4 : 3);

void main() {
  group('raceSeed (spec-prop §7.7)', () {
    test('is 3_000_000 + rival × 100_000 + raceNo', () {
      expect(DifficultyCurve.raceSeed(1, 1), 3100001);
      expect(DifficultyCurve.raceSeed(1, 5), 3100005);
      expect(DifficultyCurve.raceSeed(2, 1), 3200001);
      expect(DifficultyCurve.raceSeed(2, 12345), 3212345);
      expect(DifficultyCurve.raceSeed(3, 1), 3300001);
      expect(DifficultyCurve.raceSeed(3, 99999), 3399999);
      for (var rival = 1; rival <= 3; rival++) {
        for (final raceNo in [1, 2, 99, 100, 1000, 54321, 99998, 99999]) {
          expect(
            DifficultyCurve.raceSeed(rival, raceNo),
            3000000 + rival * 100000 + raceNo,
          );
        }
      }
    });

    test('takes rivals 1..3 and raceNo 1..99,999 only', () {
      expect(DifficultyCurve.raceRivals, 3);
      expect(DifficultyCurve.maxRaceNo, 99999);
      for (final (rival, raceNo) in [
        (0, 1),
        (4, 1),
        (-1, 1),
        (1, 0),
        (1, -1),
        (1, 100000),
        (3, 100000),
      ]) {
        expect(
          () => DifficultyCurve.raceSeed(rival, raceNo),
          throwsRangeError,
          reason: '($rival, $raceNo)',
        );
      }
    });

    test('each rival has its own block: 3,100,001–3,399,999, disjoint', () {
      // raceNo < 100,000 keeps rival r in r × 100,000 + 1..99,999.
      for (var rival = 1; rival <= 3; rival++) {
        final low = DifficultyCurve.raceSeed(rival, 1);
        final high = DifficultyCurve.raceSeed(rival, DifficultyCurve.maxRaceNo);
        expect(low, 3000000 + rival * 100000 + 1);
        expect(high, 3000000 + rival * 100000 + 99999);
        if (rival < 3) {
          expect(high, lessThan(DifficultyCurve.raceSeed(rival + 1, 1)));
        }
      }
    });
  });

  // mode-vs-computer.md rule 3: "It can't collide with the daily (yyyymmdd)
  // or bonus seeds (1_000_000 + N)". That holds for every seed a player can
  // reach; these tests pin where the formal overlaps start.
  group('race seeds and the bonus and daily seeds', () {
    const lowest = 3100001;
    const highest = 3399999;

    test('bonus seeds meet them only from level 2,100,001', () {
      // Spec §7.1: seed = 1_000_000 + levelNumber, increasing.
      expect(DifficultyCurve.bonusSeed(2100000), lowest - 1);
      expect(DifficultyCurve.bonusSeed(2100001), lowest);
      expect(DifficultyCurve.bonusSeed(2399999), highest);
      expect(DifficultyCurve.bonusSeed(2400000), highest + 1);
      // Every level a player can reach is far below: the bundle has 200
      // and Bonus Endless adds one a win.
      for (final n in [1, 200, 10000, 1000000, 2100000]) {
        expect(DifficultyCurve.bonusSeed(n), lessThan(lowest));
      }
    });

    test('daily seeds meet them only in the years 310–339', () {
      // Spec §7.5: seed = yyyymmdd. Year 309's last day and year 340's
      // first are the nearest dates outside the block.
      expect(DifficultyCurve.dailySeed(309, 12, 31), 3091231);
      expect(DifficultyCurve.dailySeed(309, 12, 31), lessThan(lowest));
      expect(DifficultyCurve.dailySeed(340, 1, 1), 3400101);
      expect(DifficultyCurve.dailySeed(340, 1, 1), greaterThan(highest));
      // The formal overlap: 3,101,015 is rival 1's race 1,015 and
      // 0310-10-15.
      expect(DifficultyCurve.dailySeed(310, 10, 15), 3101015);
      expect(DifficultyCurve.raceSeed(1, 1015), 3101015);
      // Every date from 2026 on is far above.
      expect(DifficultyCurve.dailySeed(2026, 1, 1), greaterThan(highest));
    });

    test('no race seed is a reachable bonus or daily seed', () {
      final race = <int>{
        for (var rival = 1; rival <= 3; rival++)
          for (var raceNo = 1; raceNo <= DifficultyCurve.maxRaceNo; raceNo++)
            DifficultyCurve.raceSeed(rival, raceNo),
      };
      expect(race, hasLength(3 * 99999));
      expect(race.reduce((a, b) => a < b ? a : b), lowest);
      expect(race.reduce((a, b) => a > b ? a : b), highest);
      // Bonus levels 1..2,100,000 and the dailies of 1970–9999 (the app's
      // clock can't go back further) are all outside [lowest, highest].
      expect(DifficultyCurve.bonusSeed(2100000), lessThan(lowest));
      expect(DifficultyCurve.dailySeed(1970, 1, 1), greaterThan(highest));
    });
  });

  group('racePolicy and raceTier (spec-prop §7.7; Q80)', () {
    test('rival 1 casual on easy, rivals 2 and 3 smart on medium', () {
      expect(DifficultyCurve.racePolicy(1), SimBot.casual);
      expect(DifficultyCurve.racePolicy(2), SimBot.smart);
      expect(DifficultyCurve.racePolicy(3), SimBot.smart);
      expect(DifficultyCurve.raceTier(1), Tier.easy);
      expect(DifficultyCurve.raceTier(2), Tier.medium);
      expect(DifficultyCurve.raceTier(3), Tier.medium);
    });

    test('no rival plays another policy or a hard board', () {
      for (var rival = 1; rival <= DifficultyCurve.raceRivals; rival++) {
        expect(SimBot.values, contains(DifficultyCurve.racePolicy(rival)));
        expect(DifficultyCurve.raceTier(rival), isNot(Tier.hard));
        expect(DifficultyCurve.raceTier(rival), isNot(Tier.superhard));
      }
    });

    test('rivals outside 1..3 are a RangeError', () {
      for (final rival in [0, 4, -1]) {
        expect(() => DifficultyCurve.racePolicy(rival), throwsRangeError);
        expect(() => DifficultyCurve.raceTier(rival), throwsRangeError);
      }
    });
  });

  group('raceParams (spec-prop §7.7)', () {
    test('the stage table at every boundary of the highest level won', () {
      for (final MapEntry(key: won, value: (easy, medium))
          in _expectedBoards.entries) {
        for (var rival = 1; rival <= 3; rival++) {
          final p = DifficultyCurve.raceParams(
            rival: rival,
            raceNo: 7,
            highestWonLevel: won,
          );
          expect(
            _boardOf(p),
            rival == 1 ? easy : medium,
            reason: 'rival $rival, highest won $won',
          );
        }
      }
    });

    test('its seed, tier and id', () {
      for (var rival = 1; rival <= 3; rival++) {
        for (final raceNo in [1, 2, 99999]) {
          final p = DifficultyCurve.raceParams(
            rival: rival,
            raceNo: raceNo,
            highestWonLevel: 20,
          );
          expect(p.seed, DifficultyCurve.raceSeed(rival, raceNo));
          expect(p.targetTier, DifficultyCurve.raceTier(rival));
          expect(p.id, 'race-$rival-$raceNo');
          expect(p.setsPerColor, 1);
        }
      }
    });

    test('only the mechanics met by the highest level won (§3.7)', () {
      for (final won in [20, 30, 31, 50, 51, 70, 71, 120, 121, 200]) {
        for (var rival = 1; rival <= 3; rival++) {
          final p = DifficultyCurve.raceParams(
            rival: rival,
            raceNo: 1,
            highestWonLevel: won,
          );
          final reason = 'rival $rival, highest won $won: $p';
          if (p.towers > 0) {
            expect(won, greaterThanOrEqualTo(16), reason: reason);
          }
          if (p.locked > 0) {
            expect(won, greaterThanOrEqualTo(31), reason: reason);
          }
          if (p.iceSlots > 0) {
            expect(won, greaterThanOrEqualTo(51), reason: reason);
          }
          expect(
            p.maxSize,
            lessThanOrEqualTo(_maxSizeMet(won)),
            reason: reason,
          );
          expect(p.maxSize, lessThan(6), reason: reason);
        }
      }
    });

    test('a mechanic arrives with its stage: 31 locks, 51 ice, 71 size 5', () {
      GeneratorParams at(int won, int rival) => DifficultyCurve.raceParams(
        rival: rival,
        raceNo: 1,
        highestWonLevel: won,
      );
      for (var rival = 1; rival <= 3; rival++) {
        expect(at(30, rival).locked, 0);
        expect(at(31, rival).locked, 1);
        expect(at(50, rival).iceSlots, 0);
        expect(at(51, rival).iceSlots, 1);
        expect(at(70, rival).maxSize, 4);
        expect(at(71, rival).maxSize, 5);
      }
    });

    test('rivals 2 and 3 get the same board shape, not the same seed', () {
      for (final won in [20, 31, 51, 71, 121]) {
        final two = DifficultyCurve.raceParams(
          rival: 2,
          raceNo: 3,
          highestWonLevel: won,
        );
        final three = DifficultyCurve.raceParams(
          rival: 3,
          raceNo: 3,
          highestWonLevel: won,
        );
        expect(_boardOf(two), _boardOf(three));
        expect(two.seed, isNot(three.seed));
      }
    });

    test('every rival, raceNo and highest level gives usable params', () {
      for (var rival = 1; rival <= 3; rival++) {
        for (final raceNo in [1, 2, 500, 99999]) {
          for (var won = 1; won <= 250; won++) {
            final p = DifficultyCurve.raceParams(
              rival: rival,
              raceNo: raceNo,
              highestWonLevel: won,
            );
            expect(Generator.checkParams(p), isEmpty, reason: '$p');
          }
        }
      }
      expect(
        Generator.checkParams(
          DifficultyCurve.raceParams(
            rival: 3,
            raceNo: 1,
            highestWonLevel: DifficultyCurve.maxLevelNumber,
          ),
        ),
        isEmpty,
      );
    });

    test('out-of-range inputs are a RangeError', () {
      for (final (rival, raceNo, won) in [
        (0, 1, 20),
        (4, 1, 20),
        (1, 0, 20),
        (1, 100000, 20),
        (1, 1, 0),
        (1, 1, -3),
        (1, 1, DifficultyCurve.maxLevelNumber + 1),
      ]) {
        expect(
          () => DifficultyCurve.raceParams(
            rival: rival,
            raceNo: raceNo,
            highestWonLevel: won,
          ),
          throwsRangeError,
          reason: '($rival, $raceNo, $won)',
        );
      }
    });
  });
}
