// Spec §18 M1 acceptance: "Generator is deterministic. 100 generated levels
// pass validation and solve." Design §5: n = 1..100 with bonusParams(n) and
// seed 1,000,000 + n; every result passes rules 1–8 on a fresh admin-budget
// solve and its solution replays through Rules to Won. Tagged `slow`, with a
// 10-level fast twin for the quick loop (`dart test -x slow`).
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'support/generator_checks.dart';

/// One level per stage and tier of the curve: no towers (1, 6, 10), towers
/// (16, 20), locks (36, 40), ice (56), maxSize 5 (76, 100).
const _fastTwin = [1, 6, 10, 16, 20, 36, 40, 56, 76, 100];

/// Levels from 16 on have towers, and every stage row was chosen to hit
/// its own tier, so they must all match; below 16 every board simulates as
/// easy (see `DifficultyCurve`), so they may be the closest tier instead.
void _checkBonusLevel(int n) {
  final params = DifficultyCurve.bonusParams(n);
  expect(params.seed, 1000000 + n);
  final success = expectConsistentSuccess(params, Generator.generate(params));
  if (n >= 16) {
    expect(
      success.tierMatched,
      isTrue,
      reason:
          'level $n targets ${params.targetTier.id}, simulated '
          '${success.simulation.tier.id}',
    );
  }
}

void _checkDaily(int date) {
  final params = DifficultyCurve.dailyParams(date);
  final success = expectConsistentSuccess(params, Generator.generate(params));
  expect(success.tierMatched, isTrue, reason: '$date');
}

void main() {
  group('M1 acceptance: bonus levels 1–100 validate and solve', () {
    for (var n = 1; n <= 100; n++) {
      test('bonus level $n', () => _checkBonusLevel(n));
    }
  }, tags: 'slow');

  group('fast twin: 10 bonus levels validate and solve', () {
    for (final n in _fastTwin) {
      test('bonus level $n', () => _checkBonusLevel(n));
    }
  });

  group('daily puzzles for four weeks validate and solve', () {
    for (var day = 1; day <= 28; day++) {
      final date = DifficultyCurve.dailySeed(2027, 2, day);
      test('daily $date', () => _checkDaily(date));
    }
  }, tags: 'slow');

  group('fast twin: a weekday and a weekend daily', () {
    for (final date in [20260926, 20260928]) {
      test('daily $date', () => _checkDaily(date));
    }
  });
}
