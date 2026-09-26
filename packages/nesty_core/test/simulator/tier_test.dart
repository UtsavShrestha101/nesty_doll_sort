// Spec §6.4: "Tier from casual win rate: easy ≥ 0.65, medium 0.35–0.65,
// hard 0.12–0.35, superhard < 0.12." Design A18: lower edges are inclusive;
// at 300 runs they are 195, 105 and 36 wins. Spec §5.2: tier ids
// "easy | medium | hard | superhard". Spec §7.3: win easy/medium 10, hard 25,
// superhard 50.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

void main() {
  test('tiers are ordered easy → superhard with the spec §5.2 ids', () {
    expect(Tier.values, [Tier.easy, Tier.medium, Tier.hard, Tier.superhard]);
    expect(Tier.values.map((t) => t.id), [
      'easy',
      'medium',
      'hard',
      'superhard',
    ]);
  });

  group('fromId / tryFromId', () {
    test('round-trip every id', () {
      for (final tier in Tier.values) {
        expect(Tier.fromId(tier.id), same(tier));
        expect(Tier.tryFromId(tier.id), same(tier));
      }
    });

    for (final bad in ['', 'Easy', 'EASY', ' easy', 'super_hard', 'expert']) {
      test('rejects "$bad"', () {
        expect(Tier.tryFromId(bad), isNull);
        expect(
          () => Tier.fromId(bad),
          throwsA(
            isA<FormatException>()
                .having((e) => e.message, 'message', contains('"$bad"'))
                .having((e) => e.source, 'source', bad),
          ),
        );
      });
    }
  });

  group('fromCasualWins at 300 runs (spec §6.4, design A18)', () {
    for (final (wins, tier) in [
      (300, Tier.easy),
      (195, Tier.easy),
      (194, Tier.medium),
      (105, Tier.medium),
      (104, Tier.hard),
      (36, Tier.hard),
      (35, Tier.superhard),
      (0, Tier.superhard),
    ]) {
      test('$wins wins → ${tier.id}', () {
        expect(Tier.fromCasualWins(wins, 300), tier);
      });
    }
  });

  test('fromCasualWins uses exact rate edges for any run count', () {
    expect(Tier.fromCasualWins(65, 100), Tier.easy);
    expect(Tier.fromCasualWins(64, 100), Tier.medium);
    expect(Tier.fromCasualWins(35, 100), Tier.medium);
    expect(Tier.fromCasualWins(34, 100), Tier.hard);
    expect(Tier.fromCasualWins(12, 100), Tier.hard);
    expect(Tier.fromCasualWins(11, 100), Tier.superhard);
    // 0.65 × 20 = 13 exactly.
    expect(Tier.fromCasualWins(13, 20), Tier.easy);
    expect(Tier.fromCasualWins(12, 20), Tier.medium);
  });

  test('fromCasualWins rejects impossible counts', () {
    expect(() => Tier.fromCasualWins(1, 0), throwsRangeError);
    expect(() => Tier.fromCasualWins(-1, 300), throwsRangeError);
    expect(() => Tier.fromCasualWins(301, 300), throwsRangeError);
  });

  test('default reward coins follow spec §7.3 (medium pays like easy, Q5)', () {
    expect(Tier.easy.defaultRewardCoins, 10);
    expect(Tier.medium.defaultRewardCoins, 10);
    expect(Tier.hard.defaultRewardCoins, 25);
    expect(Tier.superhard.defaultRewardCoins, 50);
  });

  test('distanceTo counts the tiers between (design A15)', () {
    expect(Tier.easy.distanceTo(Tier.easy), 0);
    expect(Tier.easy.distanceTo(Tier.hard), 2);
    expect(Tier.superhard.distanceTo(Tier.medium), 2);
    expect(Tier.hard.distanceTo(Tier.superhard), 1);
  });
}
