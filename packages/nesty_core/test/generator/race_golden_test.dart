// Race goldens (spec-prop §7.7, the rule until the owner pastes it into the
// spec, Q85): three race boards and the rival's whole race on each.
//
// Spec-prop §7.7: "Board: made by the generator from the curve's params for
// the rival's tier, at the stage of the player's highest level, with seed
// `3_000_000 + rival × 100_000 + raceNo`. Both sides start from the same
// board." "Rematch replays the same board and the same rival moves."
// mode-vs-computer.md rule 3: "a race only uses mechanics the player has met
// (§3.7)". Spec §3.7: L16 towers, L31 locked slots, L51 ice, L71 maxSize 5.
//
// The table lives in test/parity/vectors/race_vectors.dart, so
// rival_parity_test.dart checks the same values on node, chrome and wasm.
// This file adds what the parity run leaves out: every golden board is a
// valid, solvable level with the id, version and seed the app expects, uses
// only the mechanics met by its highest level won, and the rival's race on
// it replays through a mirrored GameSession to a win.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../parity/rival_race.dart';
import '../parity/vectors/race_vectors.dart';
import 'support/generator_checks.dart';

void main() {
  test('Generator.version is 1: these goldens belong to it', () {
    expect(Generator.version, 1);
  });

  test('the table: one golden per case, in order, one per rival', () {
    expect(raceGoldens.keys, [
      for (final (rival, raceNo, won) in raceGoldenCases)
        raceGoldenKey(rival, raceNo, won),
    ]);
    expect([for (final (rival, _, _) in raceGoldenCases) rival], [1, 2, 3]);
  });

  for (final (rival, raceNo, won) in raceGoldenCases) {
    final key = raceGoldenKey(rival, raceNo, won);
    final golden = raceGoldens[key]!;

    test('$key: the board, its JSON and the rival\'s race', () {
      final board = generateRaceBoard(rival, raceNo, won);
      expect(raceGoldenOf(board, rival, raceNo), golden);
    });

    test('$key: a level the app can race on', () {
      final params = DifficultyCurve.raceParams(
        rival: rival,
        raceNo: raceNo,
        highestWonLevel: won,
      );
      final seed = DifficultyCurve.raceSeed(rival, raceNo);
      expect(params.seed, seed);
      final success = generateRaceBoard(rival, raceNo, won);
      final level = success.level;
      expect(level.id, 'race-$rival-$raceNo');
      expect(level.generatorVersion, Generator.version);
      expect(
        level.seed,
        anyOf([
          for (var retry = 0; retry <= Generator.maxRetries; retry++)
            Generator.retrySeed(seed, retry),
        ]),
      );
      expect(success.tierMatched, success.simulation.tier == params.targetTier);
      expectPlayable(level);

      // Spec §3.7 through the level's own slots, not only its params.
      final slots = [for (final shelf in level.shelves) ...shelf];
      final reason = '$key: ${LevelCodec.encodeString(level)}';
      if (won < 16) {
        expect(slots.whereType<TowerSlot>(), isEmpty, reason: reason);
      }
      if (won < 31) {
        expect(slots.whereType<LockedSlot>(), isEmpty, reason: reason);
      }
      if (won < 51) {
        expect(slots.where((s) => s.ice > 0), isEmpty, reason: reason);
      }
      expect(level.maxSize, lessThanOrEqualTo(won >= 71 ? 5 : 4));
    });

    test('$key: the rival wins it through a mirrored session', () {
      final level = generateRaceBoard(rival, raceNo, won).level;
      final bot = RivalBot(
        level,
        policy: DifficultyCurve.racePolicy(rival),
        raceSeed: DifficultyCurve.raceSeed(rival, raceNo),
      );
      final session = GameSession(level);
      var steps = 0;
      while (!bot.isFinished) {
        steps++;
        if (bot.step() == RivalStep.restarted) {
          session.restart();
        } else {
          expect(session.move(bot.lastFrom, bot.lastTo), isA<MoveApplied>());
        }
        expect(bot.snapshot(), session.state);
        expect(steps, lessThanOrEqualTo(raceGoldenMaxSteps));
      }
      expect(session.isWon, isTrue);
      final race = golden['race']! as Map<String, Object>;
      expect(steps, race['steps']);
      expect(bot.run, race['restarts']);
      expect(bot.moveCount, race['runMoves']);
    });
  }
}
