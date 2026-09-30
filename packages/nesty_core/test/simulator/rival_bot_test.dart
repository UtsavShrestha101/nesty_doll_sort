// The vs Computer rival (spec-prop §7.7, the rule until the owner pastes
// it into the spec, Q85).
//
// Spec-prop §7.7:
// - "rival 1 plays like the casual bot (§6.4) … rival 2 like the smart bot …
//   rival 3 like the smart bot … No other bot policy is used."
// - "Rival: makes one move per interval. When its run can't be won (no
//   useful move, or the 250-move cap of §6.4), it restarts from the start
//   with its next run seed."
// - "Result: the first side to complete every family wins … Rematch replays
//   the same board and the same rival moves."
// Spec §6.4: "Run two bots, each for 300 seeded playthroughs with a
// 250-move cap … No undo."
// mode-vs-computer.md "Tests", core: the same seed gives the same rival
// moves; the rival never plays an illegal move; the restart rule fires on a
// dead board and at the cap.
//
// Expected values come from the rules (`Rules`, `GameSession`) and from the
// simulator's own runs (`BotPlayer.play`, which the rival must equal: "plays
// like the casual bot"), never from RivalBot. The step digests pinned on
// every platform are in test/parity/rival_parity_test.dart, computed by the
// independent Python reference.
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/simulator/bots.dart';
import 'package:test/test.dart';

import 'support/sim_levels.dart';

// Race seeds of each rival's block (DifficultyCurve.raceSeed).
const _seeds = [3100001, 3250000, 3399999];

/// One run of a rival: the moves it played, and how the run ended
/// ([RivalStep.finished] or [RivalStep.restarted]), or null for the run
/// still going when the steps ran out.
typedef _Run = ({List<Move> moves, RivalStep? end});

/// The rival's first [maxSteps] steps (fewer if it finishes), split into
/// runs.
List<_Run> _runs(RivalBot rival, int maxSteps) {
  final runs = <_Run>[];
  var moves = <Move>[];
  for (var i = 0; i < maxSteps && !rival.isFinished; i++) {
    final step = rival.step();
    if (step == RivalStep.restarted) {
      runs.add((moves: moves, end: step));
      moves = <Move>[];
      continue;
    }
    moves.add(Move(rival.lastFrom, rival.lastTo));
    if (step == RivalStep.finished) runs.add((moves: moves, end: step));
  }
  if (!rival.isFinished) runs.add((moves: moves, end: null));
  return runs;
}

/// Run [run] of [bot] as the simulator plays it: `BotPlayer.play` from the
/// level's start with the run's seed.
({List<Move> moves, bool won}) _simulatorRun(
  Level level,
  SimBot bot,
  int raceSeed,
  int run, {
  int moveCap = SimulatorParams.defaultMoveCap,
}) {
  final player = BotPlayer(BoardLayout.of(level));
  final ids = player.layout.ids;
  final moves = <Move>[];
  final won = player.play(
    bot,
    Prng(RivalBot.runSeed(raceSeed, bot, run)),
    moveCap,
    (from, to) => moves.add(Move(ids[from], ids[to])),
  );
  return (moves: moves, won: won);
}

/// Spec §6.3 "pointless": a lone nest moved from a slot that reads back as
/// open into an empty one.
bool _isPointless(GameState state, Move move) =>
    state.slot(move.from) is OpenSlot &&
    switch (state.slot(move.to)) {
      OpenSlot(nest: null) => true,
      _ => false,
    };

/// The rules' "no useful move": no legal move, or only pointless ones.
bool _hasNoUsefulMove(GameState state) =>
    Rules.legalMoves(state).every((move) => _isPointless(state, move));

/// The step kinds of [rival]'s first [count] steps.
List<RivalStep> _steps(RivalBot rival, int count) => [
  for (var i = 0; i < count && !rival.isFinished; i++) rival.step(),
];

void main() {
  group('the rival is the simulator bot, run by run (spec-prop §7.7)', () {
    for (final name in simLevelJson.keys) {
      test(name, () {
        final level = simLevel(name);
        for (final bot in SimBot.values) {
          for (final seed in _seeds) {
            final rival = RivalBot(level, policy: bot, raceSeed: seed);
            final runs = _runs(rival, 400);
            for (var run = 0; run < runs.length; run++) {
              final reason = '$name ${bot.name} seed $seed run $run';
              final (:moves, :end) = runs[run];
              final simulated = _simulatorRun(level, bot, seed, run);
              if (end == null) {
                // The run the steps stopped in: a prefix of the simulator's.
                expect(
                  simulated.moves.take(moves.length),
                  moves,
                  reason: reason,
                );
              } else {
                expect(moves, simulated.moves, reason: reason);
                expect(
                  end == RivalStep.finished,
                  simulated.won,
                  reason: reason,
                );
              }
            }
            // A finished rival ends in its winning run, the last one.
            expect(rival.run, runs.length - 1);
          }
        }
      });
    }
  });

  group('a mirrored GameSession (the app\'s copy)', () {
    for (final name in simLevelJson.keys) {
      test('$name: every move is MoveApplied and the snapshot matches', () {
        final level = simLevel(name);
        for (final bot in SimBot.values) {
          for (final seed in _seeds.take(2)) {
            final rival = RivalBot(level, policy: bot, raceSeed: seed);
            final session = GameSession(level);
            expect(rival.snapshot(), session.state);
            for (var i = 0; i < 300 && !rival.isFinished; i++) {
              final reason = '$name ${bot.name} seed $seed step $i';
              final step = rival.step();
              if (step == RivalStep.restarted) {
                session.restart();
              } else {
                final result = session.move(rival.lastFrom, rival.lastTo);
                expect(result, isA<MoveApplied>(), reason: reason);
                expect(
                  (result as MoveApplied).events.last is Won,
                  step == RivalStep.finished,
                  reason: reason,
                );
              }
              expect(rival.snapshot(), session.state, reason: reason);
              expect(rival.moveCount, session.state.moveCount, reason: reason);
              expect(rival.setsCompleted, session.setsCompleted);
              expect(rival.totalSets, session.totalSets);
              expect(rival.isFinished, session.isWon, reason: reason);
              // Like the simulator's bots, the rival adds no extra slot.
              expect(session.state.extraSlotCount, 0, reason: reason);
            }
          }
        }
      });
    }
  });

  group('restarts (spec-prop §7.7 "When its run can\'t be won")', () {
    test('lockDeadlock: no useful move at the start, so every step restarts '
        'and the board stays at its start', () {
      final level = simLevel('lockDeadlock');
      final start = GameState.initial(level);
      // By the rules: every legal move at the start is pointless.
      expect(Rules.legalMoves(start), isNotEmpty);
      expect(_hasNoUsefulMove(start), isTrue);
      for (final bot in SimBot.values) {
        final rival = RivalBot(level, policy: bot, raceSeed: _seeds.first);
        for (var i = 1; i <= 50; i++) {
          expect(rival.step(), RivalStep.restarted);
          expect(rival.run, i);
          expect(rival.moveCount, 0);
          expect(rival.snapshot(), start);
        }
        expect(() => rival.lastFrom, throwsStateError);
      }
    });

    test('noSpace: every move dead-ends the board, so the rival alternates '
        'a move and a restart and never finishes', () {
      final level = simLevel('noSpace');
      for (final bot in SimBot.values) {
        final rival = RivalBot(level, policy: bot, raceSeed: _seeds.first);
        final session = GameSession(level);
        for (var i = 0; i < 100; i++) {
          final step = rival.step();
          if (i.isEven) {
            expect(step, RivalStep.moved, reason: 'step $i');
            session.move(rival.lastFrom, rival.lastTo);
            // By the rules: out of moves (spec §2.3), so the run is dead.
            expect(Rules.isOutOfMoves(session.state), isTrue);
          } else {
            expect(step, RivalStep.restarted, reason: 'step $i');
            session.restart();
            expect(rival.run, (i + 1) ~/ 2);
          }
          expect(rival.snapshot(), session.state);
        }
        expect(rival.isFinished, isFalse);
      }
    });

    test('a cap of 5: a run that has not won makes 5 moves at most, and one '
        'that ends early had no useful move', () {
      // expertOnly holds 15 nests in 4 sets, so a win takes at least 11
      // merges: no run can win within 5 moves.
      final level = simLevel('expertOnly');
      for (final bot in SimBot.values) {
        final rival = RivalBot(
          level,
          policy: bot,
          raceSeed: _seeds.last,
          moveCap: 5,
        );
        final session = GameSession(level);
        var runsAtTheCap = 0;
        for (var i = 0; i < 600; i++) {
          final step = rival.step();
          expect(step, isNot(RivalStep.finished));
          if (step == RivalStep.restarted) {
            final moves = session.state.moveCount;
            expect(moves, lessThanOrEqualTo(5));
            if (moves == 5) {
              runsAtTheCap++;
            } else {
              expect(_hasNoUsefulMove(session.state), isTrue);
            }
            session.restart();
          } else {
            session.move(rival.lastFrom, rival.lastTo);
            expect(session.state.moveCount, lessThanOrEqualTo(5));
          }
        }
        expect(runsAtTheCap, greaterThan(0), reason: bot.name);
      }
    });

    test('the win check comes first: a win on the cap-th move finishes', () {
      // The tutorial needs exactly two merges, and the smart bot plays only
      // merges on it (every placement is pointless, spec §6.3).
      final level = simLevel('tutorial');
      final atCap = RivalBot(
        level,
        policy: SimBot.smart,
        raceSeed: 1,
        moveCap: 2,
      );
      expect(_steps(atCap, 10), [RivalStep.moved, RivalStep.finished]);
      expect(atCap.run, 0);
      expect(atCap.snapshot().isWon, isTrue);

      final belowCap = RivalBot(
        level,
        policy: SimBot.smart,
        raceSeed: 1,
        moveCap: 1,
      );
      expect(_steps(belowCap, 6), [
        RivalStep.moved,
        RivalStep.restarted,
        RivalStep.moved,
        RivalStep.restarted,
        RivalStep.moved,
        RivalStep.restarted,
      ]);
      expect(belowCap.run, 3);
    });

    test('the default cap is spec §6.4\'s 250 moves', () {
      final rival = RivalBot(
        simLevel('hard2'),
        policy: SimBot.casual,
        raceSeed: 3,
      );
      expect(rival.moveCap, 250);
      expect(SimulatorParams.defaultMoveCap, 250);
    });

    test('a restart draws the next run from its own seed', () {
      final level = simLevel('hard2');
      final rival = RivalBot(level, policy: SimBot.casual, raceSeed: 3200001);
      final runs = _runs(rival, 400);
      // Casual wins 47 of 300 simulator runs here: this seed restarts.
      expect(runs.length, greaterThan(1));
      for (var run = 1; run < runs.length; run++) {
        final ownSeed = _simulatorRun(level, SimBot.casual, 3200001, run);
        expect(ownSeed.moves.take(runs[run].moves.length), runs[run].moves);
      }
    });
  });

  group('finishing', () {
    test('finished once, then a StateError on the next step', () {
      final level = simLevel('spec');
      for (final bot in SimBot.values) {
        final rival = RivalBot(level, policy: bot, raceSeed: _seeds.first);
        final session = GameSession(level);
        RivalStep? step;
        while (step != RivalStep.finished) {
          step = rival.step();
          expect(rival.isFinished, step == RivalStep.finished);
          if (step == RivalStep.restarted) {
            session.restart();
          } else {
            session.move(rival.lastFrom, rival.lastTo);
          }
        }
        expect(session.isWon, isTrue);
        expect(rival.setsCompleted, level.totalSets);
        final (lastFrom, lastTo) = (rival.lastFrom, rival.lastTo);
        expect(rival.step, throwsStateError);
        expect(rival.step, throwsStateError);
        // Nothing changed: the winning move and the won board stay.
        expect((rival.lastFrom, rival.lastTo), (lastFrom, lastTo));
        expect(rival.snapshot(), session.state);
        expect(rival.isFinished, isTrue);
      }
    });
  });

  group('the last move', () {
    test('lastFrom and lastTo throw before the first move', () {
      final rival = RivalBot(
        simLevel('spec'),
        policy: SimBot.smart,
        raceSeed: 1,
      );
      expect(() => rival.lastFrom, throwsStateError);
      expect(() => rival.lastTo, throwsStateError);
    });

    test('they are the move just played, as the level\'s slot ids, read '
        'without building a new string', () {
      final level = simLevel('towersEasy');
      final rival = RivalBot(level, policy: SimBot.casual, raceSeed: 7);
      final before = rival.snapshot();
      expect(rival.step(), RivalStep.moved);
      expect(level.slotIds, contains(rival.lastFrom));
      expect(level.slotIds, contains(rival.lastTo));
      final applied =
          Rules.tryMove(before, Move(rival.lastFrom, rival.lastTo))
              as MoveApplied;
      expect(applied.state, rival.snapshot());
      expect(identical(rival.lastFrom, rival.lastFrom), isTrue);
      expect(identical(rival.lastTo, rival.lastTo), isTrue);
    });

    test('a restart keeps the last move of the run before it', () {
      final rival = RivalBot(
        simLevel('noSpace'),
        policy: SimBot.smart,
        raceSeed: 1,
      );
      expect(rival.step(), RivalStep.moved);
      final move = Move(rival.lastFrom, rival.lastTo);
      expect(rival.step(), RivalStep.restarted);
      expect(Move(rival.lastFrom, rival.lastTo), move);
    });
  });

  group('determinism (CLAUDE.md rule 7; spec-prop §7.7 Rematch)', () {
    test('the same level, policy and race seed give the same steps', () {
      for (final name in ['spec', 'hard2', 'expertOnly', 'largeOpen']) {
        final level = simLevel(name);
        for (final bot in SimBot.values) {
          List<String> play(Level level) {
            final rival = RivalBot(level, policy: bot, raceSeed: 3300001);
            return [
              for (var i = 0; i < 300 && !rival.isFinished; i++)
                switch (rival.step()) {
                  RivalStep.restarted => 'restart',
                  final step =>
                    '${step.name} ${rival.lastFrom}>${rival.lastTo}',
                },
            ];
          }

          // A Rematch builds a new rival on a new decode of the same board.
          expect(play(simLevel(name)), play(level), reason: '$name $bot');
        }
      }
    });

    test('the race seed, not level.seed, seeds the runs', () {
      final level = simLevel('hard2');
      final reseeded = Level(
        id: 'another-id',
        maxSize: level.maxSize,
        shelves: level.shelves,
        seed: 123456,
        generatorVersion: 1,
      );
      for (final bot in SimBot.values) {
        final a = RivalBot(level, policy: bot, raceSeed: 3200001);
        final b = RivalBot(reseeded, policy: bot, raceSeed: 3200001);
        for (var i = 0; i < 200 && !a.isFinished; i++) {
          final step = a.step();
          expect(b.step(), step);
          if (step != RivalStep.restarted) {
            expect((b.lastFrom, b.lastTo), (a.lastFrom, a.lastTo));
          }
        }
      }
    });

    test('different race seeds give different rivals', () {
      final level = simLevel('hard2');
      final games = {
        for (var seed = 3100001; seed <= 3100010; seed++)
          [
            for (final (:moves, :end) in _runs(
              RivalBot(level, policy: SimBot.casual, raceSeed: seed),
              300,
            ))
              '$moves $end',
          ].join(';'),
      };
      expect(games.length, greaterThan(1));
    });

    test('two rivals on one Level instance play as each would alone', () {
      // The app's two sessions and the rival share the level's compiled
      // layout and its scratch buffers.
      final level = simLevel('superhard1');
      List<RivalStep> alone(SimBot bot, int seed) =>
          _steps(RivalBot(level, policy: bot, raceSeed: seed), 200);
      final expectedCasual = alone(SimBot.casual, 5);
      final expectedSmart = alone(SimBot.smart, 6);
      final casual = RivalBot(level, policy: SimBot.casual, raceSeed: 5);
      final smart = RivalBot(level, policy: SimBot.smart, raceSeed: 6);
      final session = GameSession(level);
      final casualSteps = <RivalStep>[];
      final smartSteps = <RivalStep>[];
      for (var i = 0; i < 200; i++) {
        if (!casual.isFinished) casualSteps.add(casual.step());
        session.legalMoves();
        if (!smart.isFinished) smartSteps.add(smart.step());
      }
      expect(casualSteps, expectedCasual);
      expect(smartSteps, expectedSmart);
    });
  });

  group('run seeds', () {
    test('run i draws from Prng.derive(raceSeed, runStream + bot, i)', () {
      for (final seed in [0, 1, 3100001, 3399999, Prng.maxSeed]) {
        for (final bot in SimBot.values) {
          for (final run in [0, 1, 2, 250, 0xFFFFFFFF]) {
            expect(
              RivalBot.runSeed(seed, bot, run),
              Prng.derive(seed, RivalBot.runStream + bot.index, run),
            );
          }
        }
      }
    });

    test('the labels are RVL0 and RVL1, apart from every other stream', () {
      int ascii(String label) =>
          label.codeUnits.fold(0, (word, unit) => word * 256 + unit);
      expect(RivalBot.runStream, ascii('RVL0'));
      expect(RivalBot.runStream + SimBot.smart.index, ascii('RVL1'));
      final rivalLabels = {
        for (final bot in SimBot.values) RivalBot.runStream + bot.index,
      };
      final otherLabels = {
        // The generator's attempts: Prng.derive(seed, attempt).
        for (var attempt = 0; attempt < Generator.maxAttempts; attempt++)
          attempt,
        // The simulator's runs: Prng.derive(simSeed, bot.index, run).
        for (final bot in SimBot.values) bot.index,
        // The generator's retry seeds, 'RETR'.
        Generator.retryStream,
        // The app's pace jitter, 'PACE' (RaceRules.paceStream, m7-design
        // Phase 2): a label of the race seed too.
        ascii('PACE'),
      };
      expect(rivalLabels, hasLength(2));
      expect(rivalLabels.intersection(otherLabels), isEmpty);
    });

    test('no run seed of a race is one of its generator or retry seeds', () {
      // The motivating case: with the bot's index alone as the label, the
      // casual rival's run 0 would be attempt 0 of the race seed.
      for (final seed in [3100001, 3200001, 3300001]) {
        expect(
          RivalBot.runSeed(seed, SimBot.casual, 0),
          isNot(Prng.derive(seed, 0)),
        );
        final others = {
          for (var attempt = 0; attempt < Generator.maxAttempts; attempt++)
            Prng.derive(seed, attempt),
          for (var retry = 1; retry <= Generator.maxRetries; retry++)
            Generator.retrySeed(seed, retry),
          for (final bot in SimBot.values)
            for (var run = 0; run < 10; run++)
              Prng.derive(seed, bot.index, run),
        };
        for (final bot in SimBot.values) {
          for (var run = 0; run < 10; run++) {
            expect(others, isNot(contains(RivalBot.runSeed(seed, bot, run))));
          }
        }
      }
    });
  });

  group('construction', () {
    test('starts at the level start, run 0, nothing done', () {
      final level = simLevel('spec');
      final rival = RivalBot(level, policy: SimBot.smart, raceSeed: 3200001);
      expect(rival.level, same(level));
      expect(rival.policy, SimBot.smart);
      expect(rival.raceSeed, 3200001);
      expect(rival.run, 0);
      expect(rival.moveCount, 0);
      expect(rival.setsCompleted, 0);
      expect(rival.totalSets, level.totalSets);
      expect(rival.isFinished, isFalse);
      expect(rival.snapshot(), GameState.initial(level));
      expect(rival.toString(), contains('smart'));
    });

    test('snapshot is a copy: stepping on leaves it alone', () {
      final level = simLevel('spec');
      final rival = RivalBot(level, policy: SimBot.casual, raceSeed: 9);
      final first = rival.snapshot();
      rival.step();
      expect(first, GameState.initial(level));
      expect(rival.snapshot(), isNot(first));
    });

    test('rejects a race seed outside [0, Prng.maxSeed]', () {
      final level = simLevel('spec');
      for (final seed in [-1, Prng.maxSeed + 1]) {
        expect(
          () => RivalBot(level, policy: SimBot.casual, raceSeed: seed),
          throwsRangeError,
        );
      }
      expect(
        RivalBot(level, policy: SimBot.casual, raceSeed: Prng.maxSeed).run,
        0,
      );
    });

    test('rejects a cap below 1: such a rival could never move', () {
      final level = simLevel('spec');
      for (final cap in [0, -1]) {
        expect(
          () =>
              RivalBot(level, policy: SimBot.smart, raceSeed: 1, moveCap: cap),
          throwsRangeError,
        );
      }
    });

    test('rejects a level with no family to complete', () {
      final empty = Level(
        id: 'empty',
        maxSize: 3,
        shelves: [
          [OpenSlot(), OpenSlot()],
        ],
      );
      expect(empty.totalSets, 0);
      expect(
        () => RivalBot(empty, policy: SimBot.casual, raceSeed: 1),
        throwsArgumentError,
      );
    });

    test('rejects a level the engine can\'t lay out', () {
      final noShelf = Level(id: 'none', maxSize: 3, shelves: const []);
      expect(
        () => RivalBot(noShelf, policy: SimBot.casual, raceSeed: 1),
        throwsArgumentError,
      );
    });
  });
}
