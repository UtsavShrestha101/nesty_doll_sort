// Spec §6.5 (Generator, deterministic): params colors, setsPerColor (default
// 1), maxSize, shelves, slotsPerShelf, towers, towerDepth, emptySlots,
// locked, iceSlots, targetTier, seed. Step 4: "Validate, solve and simulate.
// Retry with the next sub-seed up to 50 times until the tier matches
// targetTier. If none match, return the closest." Record generatorVersion.
// Design §3: attempt i uses Prng.derive(seed, i); 2·sets ≤ N ≤ maxSize·sets
// else gen.segmentsInfeasible; closest = tier distance → band centre →
// earliest (A15); none solvable → GeneratorFailure (A14); bottom shelf ≤ 4.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'support/generator_checks.dart';

GeneratorParams _params({
  int colors = 4,
  int setsPerColor = 1,
  int maxSize = 4,
  int shelves = 3,
  int slotsPerShelf = 3,
  int towers = 3,
  int towerDepth = 3,
  int emptySlots = 1,
  int locked = 0,
  int iceSlots = 0,
  Tier targetTier = Tier.easy,
  int seed = 1,
  String? id,
}) => GeneratorParams(
  colors: colors,
  setsPerColor: setsPerColor,
  maxSize: maxSize,
  shelves: shelves,
  slotsPerShelf: slotsPerShelf,
  towers: towers,
  towerDepth: towerDepth,
  emptySlots: emptySlots,
  locked: locked,
  iceSlots: iceSlots,
  targetTier: targetTier,
  seed: seed,
  id: id,
);

/// The single issue of [params], which must have exactly one.
LevelIssue _only(GeneratorParams params) {
  final issues = Generator.checkParams(params);
  expect(issues, hasLength(1), reason: '$issues');
  return issues.single;
}

/// The casual-win band of each tier at 300 runs, inclusive, from spec §6.4
/// and design A18 (195, 105 and 36 wins), written out here rather than read
/// from `Tier`.
const _bands = {
  Tier.easy: (195, 300),
  Tier.medium: (105, 194),
  Tier.hard: (36, 104),
  Tier.superhard: (0, 35),
};

/// What `Generator.generate` must return for [params], recomputed from the
/// public API and the rule of spec §6.5 step 4 and design A15: every attempt
/// is built, validated with rules 1–8 and simulated; the first whose tier
/// matches wins; else the closest by tier distance, then twice the distance
/// from the target band's centre, then the earliest attempt.
({int attempt, bool matched})? _oracle(GeneratorParams params) {
  ({int attempt, int tiers, int centre})? best;
  for (var attempt = 0; attempt < Generator.maxAttempts; attempt++) {
    final level = Generator.buildAttempt(params, attempt);
    if (level == null || !Validator.validate(level).isValid) continue;
    final simulation = Simulator.run(level);
    if (simulation.tier == params.targetTier) {
      return (attempt: attempt, matched: true);
    }
    final (lo, hi) = _bands[params.targetTier]!;
    final key = (
      attempt: attempt,
      tiers: (simulation.tier.index - params.targetTier.index).abs(),
      centre: (2 * simulation.casual.wins - (lo + hi)).abs(),
    );
    if (best == null ||
        key.tiers < best.tiers ||
        (key.tiers == best.tiers && key.centre < best.centre)) {
      best = key;
    }
  }
  return best == null ? null : (attempt: best.attempt, matched: false);
}

void main() {
  group('Generator constants', () {
    test('version 1, 50 attempts (spec §6.5)', () {
      expect(Generator.version, 1);
      expect(Generator.maxAttempts, 50);
    });

    test('at most 40 sets per color: 20 slots × 4 nests ÷ 2 segments', () {
      expect(Generator.maxSetsPerColor, 40);
    });

    test('default id is gen-<seed>', () {
      expect(Generator.defaultId(1000042), 'gen-1000042');
    });
  });

  group('checkParams', () {
    test('accepts usable params', () {
      expect(Generator.checkParams(_params()), isEmpty);
      expect(
        Generator.checkParams(
          _params(colors: 6, towers: 4, locked: 1, iceSlots: 2),
        ),
        isEmpty,
      );
    });

    test('reports a param out of range with its bounds', () {
      final issue = _only(_params(colors: 0));
      expect(issue.code, IssueCodes.genParamOutOfRange);
      expect(issue.isError, isTrue);
      expect(issue.path, '/colors');
      expect(issue.args, {'param': 'colors', 'value': 0, 'min': 1, 'max': 10});
    });

    for (final (param, value, params, min, max) in [
      ('colors', 11, _params(colors: 11), 1, 10),
      ('setsPerColor', 0, _params(setsPerColor: 0), 1, 40),
      ('setsPerColor', 41, _params(setsPerColor: 41), 1, 40),
      ('maxSize', 2, _params(maxSize: 2), 3, 6),
      ('maxSize', 7, _params(maxSize: 7), 3, 6),
      ('shelves', 0, _params(shelves: 0), 1, 4),
      ('shelves', 5, _params(shelves: 5), 1, 4),
      ('slotsPerShelf', 1, _params(slotsPerShelf: 1), 2, 5),
      ('slotsPerShelf', 6, _params(slotsPerShelf: 6), 2, 5),
      ('towerDepth', 0, _params(towerDepth: 0), 1, 4),
      ('towerDepth', 5, _params(towerDepth: 5), 1, 4),
      ('seed', -1, _params(seed: -1), 0, Prng.maxSeed),
      (
        'seed',
        Prng.maxSeed + 1,
        _params(seed: Prng.maxSeed + 1),
        0,
        Prng.maxSeed,
      ),
      ('towers', -1, _params(towers: -1), 0, 9),
      ('towers', 10, _params(towers: 10), 0, 9),
      ('emptySlots', -1, _params(emptySlots: -1), 0, 9),
      ('locked', -1, _params(locked: -1), 0, 9),
      ('iceSlots', -1, _params(iceSlots: -1), 0, 9),
    ]) {
      test('$param $value is outside $min–$max', () {
        expect(_only(params).args, {
          'param': param,
          'value': value,
          'min': min,
          'max': max,
        });
        expect(_only(params).code, IssueCodes.genParamOutOfRange);
      });
    }

    test('ignores towerDepth when there are no towers', () {
      expect(
        Generator.checkParams(
          _params(colors: 4, towers: 0, towerDepth: 99, emptySlots: 1),
        ),
        isEmpty,
      );
    });

    test('the bottom shelf keeps room for both extra slots (D22)', () {
      // 2 × 5 has 5 + 4 slots: 9 empty fit, 10 don't.
      final issue = _only(
        _params(shelves: 2, slotsPerShelf: 5, towers: 0, emptySlots: 10),
      );
      expect(issue.code, IssueCodes.genParamOutOfRange);
      expect(issue.args, {
        'param': 'emptySlots',
        'value': 10,
        'min': 0,
        'max': 9,
      });
    });

    test('reports a bad id as level.badId', () {
      for (final id in ['', 'x' * 65]) {
        final issue = _only(_params(id: id));
        expect(issue.code, IssueCodes.badId);
        expect(issue.args, {'id': id, 'maxLength': 64});
      }
      expect(Generator.checkParams(_params(id: 'x' * 64)), isEmpty);
    });

    test('collects every range issue of the first group', () {
      final issues = Generator.checkParams(
        _params(colors: 0, maxSize: 9, seed: -3),
      );
      expect(issues.map((i) => i.args['param']), ['colors', 'maxSize', 'seed']);
    });

    test('towers and empty slots must fit the board', () {
      final issue = _only(
        _params(shelves: 2, slotsPerShelf: 3, towers: 4, emptySlots: 3),
      );
      expect(issue.code, IssueCodes.genSlotsInfeasible);
      expect(issue.args, {'needed': 7, 'available': 6});
    });

    test('segments must fill the occupied slots: too few nests', () {
      // 3 × 3 − 1 empty = 8 open nests; 5 sets need at least 10 segments.
      final issue = _only(_params(colors: 5, towers: 0));
      expect(issue.code, IssueCodes.genSegmentsInfeasible);
      expect(issue.args, {'capacity': 8, 'min': 10, 'max': 20});
    });

    test('segments must fill the occupied slots: too many nests', () {
      // 2 open + 7 towers × 4 = 30 nests; 4 sets of 4 dolls hold 16.
      final issue = _only(_params(towers: 7, towerDepth: 4, emptySlots: 0));
      expect(issue.code, IssueCodes.genSegmentsInfeasible);
      expect(issue.args, {'capacity': 30, 'min': 8, 'max': 16});
    });

    test('an infeasible board stops before the lock and ice checks', () {
      final issues = Generator.checkParams(
        _params(colors: 5, towers: 0, locked: 8, iceSlots: 8),
      );
      expect(issues.map((i) => i.code), [IssueCodes.genSegmentsInfeasible]);
    });

    test('locks go on occupied open slots (A12)', () {
      // 9 slots − 3 towers − 1 empty = 5 occupied open slots.
      final issue = _only(_params(locked: 6));
      expect(issue.args, {'param': 'locked', 'value': 6, 'min': 0, 'max': 5});
      expect(Generator.checkParams(_params(locked: 5)), isEmpty);
    });

    test('with one set per color a lock needs a second color (rule 6)', () {
      final issue = _only(
        _params(colors: 1, maxSize: 3, towers: 0, emptySlots: 7, locked: 1),
      );
      expect(issue.args, {'param': 'colors', 'value': 1, 'min': 2, 'max': 10});
      // Another set of the same color can break the case.
      expect(
        Generator.checkParams(
          _params(
            colors: 1,
            setsPerColor: 2,
            maxSize: 3,
            towers: 0,
            emptySlots: 5,
            locked: 1,
          ),
        ),
        isEmpty,
      );
    });

    test('ice goes on occupied slots that are not locked (A12)', () {
      // 5 occupied open + 3 towers − 2 locks = 6.
      final issue = _only(_params(locked: 2, iceSlots: 7));
      expect(issue.args, {'param': 'iceSlots', 'value': 7, 'min': 0, 'max': 6});
      expect(Generator.checkParams(_params(locked: 2, iceSlots: 6)), isEmpty);
    });

    test('ice needs at least 2 sets: n is 1..min(3, sets − 1) (A12)', () {
      final issue = _only(
        _params(colors: 1, maxSize: 3, towers: 0, emptySlots: 7, iceSlots: 1),
      );
      expect(issue.args, {'param': 'iceSlots', 'value': 1, 'min': 0, 'max': 0});
    });
  });

  group('generate: failures', () {
    test('rejected params make no attempt', () {
      final params = _params(colors: 0, maxSize: 9);
      final outcome = Generator.generate(params);
      expect(outcome, isA<GeneratorFailure>());
      final failure = outcome as GeneratorFailure;
      expect(failure.attempts, 0);
      expect(failure.issues, Generator.checkParams(params));
    });

    test('no valid attempt: every board is frozen solid (A14)', () {
      // 4 open slots, no empty one, every slot iced: no first move (rule 7).
      final outcome = Generator.generate(
        _params(
          colors: 2,
          maxSize: 3,
          shelves: 1,
          slotsPerShelf: 4,
          towers: 0,
          emptySlots: 0,
          iceSlots: 4,
        ),
      );
      expect(outcome, isA<GeneratorFailure>());
      final failure = outcome as GeneratorFailure;
      expect(failure.attempts, Generator.maxAttempts);
      expect(failure.issues, hasLength(1));
      expect(failure.issues.single.code, IssueCodes.genNoSolvableLevel);
      expect(failure.issues.single.args, {'attempts': 50});
    });

    test('no valid attempt: every lock arrangement would deadlock', () {
      // Two colors, every open slot locked: a case sealing red and one
      // sealing blue would each wait on the other.
      final params = _params(
        colors: 2,
        maxSize: 3,
        shelves: 1,
        slotsPerShelf: 4,
        towers: 0,
        emptySlots: 0,
        locked: 4,
      );
      for (var attempt = 0; attempt < Generator.maxAttempts; attempt++) {
        expect(Generator.buildAttempt(params, attempt), isNull);
      }
      final outcome = Generator.generate(params);
      expect(outcome, isA<GeneratorFailure>());
      expect(
        (outcome as GeneratorFailure).issues.single.code,
        IssueCodes.genNoSolvableLevel,
      );
    });
  });

  group('generate: success', () {
    test('a valid, solvable level with its metrics and metadata', () {
      final params = _params(seed: 1000016, targetTier: Tier.medium);
      final success = expectConsistentSuccess(
        params,
        Generator.generate(params),
      );
      expect(success.level.id, 'gen-1000016');
    });

    test('uses the requested id', () {
      final params = _params(id: 'bonus-7', seed: 7);
      final success = expectConsistentSuccess(
        params,
        Generator.generate(params),
      );
      expect(success.level.id, 'bonus-7');
    });

    test('an expert-only match is returned with its flag (spec §6.4)', () {
      // §6.5 step 4 matches on tier only; the §6.4 flag travels on the
      // simulation for the app to act on (owner question, PROGRESS).
      final success =
          Generator.generate(DifficultyCurve.bonusParams(40))
              as GeneratorSuccess;
      expect(success.tierMatched, isTrue);
      expect(success.simulation.tier, Tier.superhard);
      expect(success.simulation.smart.wins, 0);
      expect(success.simulation.expertOnly, isTrue);
    });

    test('the first attempt whose tier matches wins (spec §6.5 step 4)', () {
      for (final tier in Tier.values) {
        final params = _params(
          colors: 6,
          towers: 5,
          towerDepth: 4,
          targetTier: tier,
          seed: 11,
        );
        final success = expectConsistentSuccess(
          params,
          Generator.generate(params),
        );
        expect(
          (attempt: success.attempt, matched: success.tierMatched),
          _oracle(params),
          reason: tier.id,
        );
      }
    });

    test('closest tier when none matches: fewer tiers away first (A15)', () {
      // Towers of depth 3 are mostly easy: no attempt is superhard, and the
      // medium with the fewest casual wins is the closest.
      final params = _params(
        colors: 6,
        towers: 5,
        targetTier: Tier.superhard,
        seed: 3,
      );
      final success = expectConsistentSuccess(
        params,
        Generator.generate(params),
      );
      expect(success.tierMatched, isFalse);
      expect(success.simulation.tier, Tier.medium);
      expect(success.attempt, 40);
      expect((attempt: success.attempt, matched: false), _oracle(params));
    });

    test('closest tier: then nearer the band centre, not the earlier', () {
      // Two hard attempts: 104 casual wins at attempt 18 and 103 at 27; the
      // superhard band's centre is 17.5 wins, so the later one is closer.
      final params = _params(
        colors: 6,
        towers: 5,
        targetTier: Tier.superhard,
        seed: 7,
      );
      final success = expectConsistentSuccess(
        params,
        Generator.generate(params),
      );
      expect(success.tierMatched, isFalse);
      expect(success.simulation.tier, Tier.hard);
      expect(success.simulation.casual.wins, 103);
      expect(success.attempt, 27);
      expect((attempt: 27, matched: false), _oracle(params));
    });

    test('closest tier: the earliest of equally close attempts', () {
      // Open slots only: every board is easy with 300 casual wins (spec
      // §6.4), so every valid attempt ties and the first one is returned.
      final params = _params(
        colors: 3,
        towers: 0,
        emptySlots: 2,
        targetTier: Tier.hard,
        seed: 5,
      );
      final success = expectConsistentSuccess(
        params,
        Generator.generate(params),
      );
      expect(success.tierMatched, isFalse);
      expect(success.simulation.tier, Tier.easy);
      expect(success.attempt, 0);
    });
  });

  group('determinism (CLAUDE.md rule 7)', () {
    test('the same params give the same level, byte for byte', () {
      final params = _params(locked: 1, iceSlots: 1, seed: 424242);
      final a = Generator.generate(params);
      final b = Generator.generate(params);
      expect(a, b);
      expect(
        LevelCodec.encodeString((a as GeneratorSuccess).level),
        LevelCodec.encodeString((b as GeneratorSuccess).level),
      );
    });

    test('an attempt depends only on the params and its index', () {
      final params = _params(seed: 99);
      final forward = [
        for (var i = 0; i < 8; i++) Generator.buildAttempt(params, i),
      ];
      final backward = [
        for (var i = 7; i >= 0; i--) Generator.buildAttempt(params, i),
      ].reversed.toList();
      expect(forward, backward);
    });

    test('buildAttempt rejects bad params and attempt indexes', () {
      expect(
        () => Generator.buildAttempt(_params(colors: 0), 0),
        throwsArgumentError,
      );
      expect(() => Generator.buildAttempt(_params(), -1), throwsRangeError);
      expect(
        () => Generator.buildAttempt(_params(), Generator.maxAttempts),
        throwsRangeError,
      );
      expect(
        Generator.buildAttempt(_params(), Generator.maxAttempts - 1),
        isNotNull,
      );
    });

    test('different seeds give different boards', () {
      final digests = {
        for (var seed = 0; seed < 20; seed++)
          levelDigest(Generator.buildAttempt(_params(seed: seed), 0)!),
      };
      expect(digests, hasLength(20));
    });

    test('the id is recorded but does not change the board', () {
      final a = Generator.buildAttempt(_params(id: 'a'), 0)!;
      final b = Generator.buildAttempt(_params(id: 'b'), 0)!;
      expect(a.shelves, b.shelves);
    });
  });

  group('generated boards follow the params', () {
    for (final params in [
      _params(),
      _params(colors: 6, towers: 5, towerDepth: 4, locked: 1, iceSlots: 1),
      _params(
        colors: 5,
        setsPerColor: 2,
        maxSize: 5,
        shelves: 4,
        slotsPerShelf: 5,
        towers: 6,
        towerDepth: 2,
        emptySlots: 2,
        locked: 3,
        iceSlots: 3,
      ),
      _params(colors: 2, maxSize: 6, shelves: 1, slotsPerShelf: 5, towers: 1),
    ]) {
      test('$params', () {
        final sets = params.colors * params.setsPerColor;
        for (var attempt = 0; attempt < 10; attempt++) {
          final level = Generator.buildAttempt(params, attempt);
          if (level == null) continue;
          expect(level.maxSize, params.maxSize);
          expect(level.shelves, hasLength(params.shelves));
          for (var row = 0; row < params.shelves - 1; row++) {
            expect(level.shelves[row], hasLength(params.slotsPerShelf));
          }
          expect(
            level.shelves.last.length,
            params.slotsPerShelf > 4 ? 4 : params.slotsPerShelf,
          );
          final slots = [for (final shelf in level.shelves) ...shelf];
          final towers = slots.whereType<TowerSlot>().toList();
          expect(towers, hasLength(params.towers));
          expect(
            towers.every((t) => t.stack.length == params.towerDepth),
            isTrue,
          );
          expect(slots.whereType<LockedSlot>(), hasLength(params.locked));
          expect(
            slots.whereType<LockedSlot>().every((s) => s.nest != null),
            isTrue,
          );
          expect(
            slots.where((s) => s is OpenSlot && s.nest == null),
            hasLength(params.emptySlots),
          );
          final iced = slots.where((s) => s.ice > 0).toList();
          expect(iced, hasLength(params.iceSlots));
          final maxIce = sets - 1 < 3 ? sets - 1 : 3;
          expect(iced.every((s) => s.ice <= maxIce && !s.isEmpty), isTrue);
          expect(level.setsByColor, hasLength(params.colors));
          expect(
            level.setsByColor.values.every((n) => n == params.setsPerColor),
            isTrue,
          );
          expect(level.setsByColor.keys, isNot(contains(DollColor.gold)));
          // Rules 1–6 hold by construction (rule 7 and 8 are the attempt's
          // test), and every nest is at most maxSize.
          final report = Validator.validate(
            level,
            options: ValidationOptions.loader,
          );
          expect(
            report.issues.where((i) => i.code != IssueCodes.noLegalFirstMove),
            isEmpty,
          );
        }
      });
    }
  });
}
