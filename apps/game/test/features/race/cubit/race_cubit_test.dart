// The RaceCubit's clock, pace, holds, result and tie (spec-prop §7.7;
// docs/plans/m7-design.md P2.5), built on the contracts stage's frozen
// setup, rematch and new-race (test/contracts/m7_phase2_test.dart already
// pins those). mode-vs-computer.md "Tests -> Bloc" is the source list this
// file works through: same seed -> same moves, pace and jitter, pause
// stops the rival, win and loss with the reward paid once, the tie, unlocks
// surfaced, a kill leaves no reward, Rematch replays the same moves.
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/race/race_rules.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/ticker/fake_frame_ticker.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';

import '../../gameplay/bloc/support/bloc_fixtures.dart';
import 'support/race_fixtures.dart';

/// Casual rival 1's race 1 finishes on [defaultLevel] in exactly 5 steps,
/// none of them a restart (checked once, by construction, below): a good
/// case for pace/jitter/determinism, which want several moves to compare.
const _casualRace = RacePlay(rival: 1, raceNo: 1);

/// Smart rival 2's race 1 finishes on [defaultLevel] in exactly 2 steps
/// (`moved`, `finished`): a good case for the win/loss/tie tests, which
/// want the rival done quickly.
const _fastRace = RacePlay(rival: 2, raceNo: 1);

RaceCubit _cubitFor(
  RacePlay request,
  FakeFrameTicker ticker, {
  FakeSaveService? save,
  FakeRemoteConfigService? config,
}) => RaceCubit(
  request,
  save ?? FakeSaveService(initial: unlockedRaceDocument()),
  config ?? FakeRemoteConfigService(),
  ticker,
);

/// Loads [level] and starts [cubit]'s clock; the ticker's own first tick
/// after `start` always reports zero elapsed (`FakeFrameTicker`), so it is
/// spent here rather than counted by [tickBy].
void _load(
  RaceCubit cubit,
  RacePlay request,
  Level level,
  FakeFrameTicker ticker,
) {
  cubit.playerBoardLoaded(raceEntry(request, level));
  cubit.start();
  ticker.tick();
}

/// Ticks [ticker] by [stepMs] once and returns the ticked time so far
/// (a running total the caller keeps): every call after [_load]'s own
/// first tick advances the fake's elapsed by exactly [stepMs] (unlike the
/// very first tick, which the fake always reports as zero).
int _tickBy(FakeFrameTicker ticker, int running, {int stepMs = 25}) {
  ticker.tick(Duration(milliseconds: stepMs));
  return running + stepMs;
}

/// Ticks [ticker] until [cubit]'s `rivalMoves + rivalRestarts` goes up, the
/// race finishes, or [maxMs] of ticked time passes (then null): the ticked
/// time (a multiple of [stepMs]) the step happened at.
int? _tickToNextStep(
  RaceCubit cubit,
  FakeFrameTicker ticker, {
  required int running,
  int stepMs = 25,
  int maxMs = 20000,
}) {
  final before = cubit.state.data!;
  final beforeSteps = before.rivalMoves + before.rivalRestarts;
  var elapsed = running;
  while (elapsed - running < maxMs) {
    elapsed = _tickBy(ticker, elapsed, stepMs: stepMs);
    final data = cubit.state.data!;
    if (data.rivalMoves + data.rivalRestarts != beforeSteps ||
        data.phase == RacePhase.finished) {
      return elapsed;
    }
  }
  return null;
}

/// The ticked time (a multiple of [stepMs]) of every rival step from a
/// fresh [_load], and the (from, to) of every move (a restart adds no
/// move): stops once the race is decided.
({List<int> times, List<Move> moves}) _timeline(
  RaceCubit cubit,
  RacePlay request,
  Level level,
  FakeFrameTicker ticker, {
  int stepMs = 25,
  int maxSteps = 10,
}) {
  _load(cubit, request, level, ticker);
  final times = <int>[];
  final moves = <Move>[];
  var running = 0;
  for (var i = 0; i < maxSteps; i++) {
    final before = cubit.rivalSession?.state;
    final at = _tickToNextStep(cubit, ticker, running: running, stepMs: stepMs);
    if (at == null) break;
    running = at;
    times.add(at);
    final after = cubit.rivalSession!.state;
    if (after.moveCount != (before?.moveCount ?? 0)) {
      final bot = cubit.bot!;
      moves.add(Move(bot.lastFrom, bot.lastTo));
    }
    if (cubit.state.data!.phase == RacePhase.finished) break;
  }
  return (times: times, moves: moves);
}

void main() {
  group('Start (m7-design P2.5, vs-computer rule 4)', () {
    test('ready -> running at once, no countdown, thinking; does nothing '
        'in any other phase', () {
      final ticker = FakeFrameTicker();
      final cubit = _cubitFor(_casualRace, ticker)
        ..playerBoardLoaded(raceEntry(_casualRace, defaultLevel));
      addTearDown(cubit.close);
      cubit.start(); // no board loaded yet is covered by the contracts test;
      // this is the ordinary path: ready -> running.
      expect(cubit.state.data!.phase, RacePhase.running);
      expect(cubit.state.data!.activity, RivalActivity.thinking);
      expect(ticker.isTicking, isTrue);

      // Start again while running changes nothing (no re-arm, no reset).
      final running = cubit.state.data;
      cubit.start();
      expect(cubit.state.data, same(running));
    });

    test('a hold set before Start still counts: the clock stays off until '
        'it lifts', () {
      final ticker = FakeFrameTicker();
      final cubit = _cubitFor(_casualRace, ticker)
        ..playerBoardLoaded(raceEntry(_casualRace, defaultLevel));
      addTearDown(cubit.close);
      cubit.setHold(RaceHold.pause, held: true);
      expect(cubit.state.data!.held, isTrue);
      cubit.start();
      expect(cubit.state.data!.phase, RacePhase.running);
      expect(ticker.isTicking, isFalse);

      cubit.setHold(RaceHold.pause, held: false);
      expect(ticker.isTicking, isTrue);
    });
  });

  group('The clock, pace and jitter (m7-design P2.5)', () {
    test('the first rival move is due within paceMs +/- its jitter span', () {
      final ticker = FakeFrameTicker();
      final cubit = _cubitFor(_casualRace, ticker);
      addTearDown(cubit.close);
      _load(cubit, _casualRace, defaultLevel, ticker);

      final at = _tickToNextStep(cubit, ticker, running: 0);
      expect(at, isNotNull);
      final span = cubit.paceMs * cubit.jitterPct ~/ 100;
      expect(at, greaterThanOrEqualTo(cubit.paceMs - span));
      // +25 for the fake's step quantization (it can only report a step at
      // a multiple of the step it was ticked by).
      expect(at, lessThanOrEqualTo(cubit.paceMs + span + 25));
      expect(cubit.state.data!.rivalMoves, 1);
      expect(cubit.state.data!.activity, RivalActivity.thinking);
    });

    test('two cubits on the same request tick to the same move times and '
        'moves', () {
      final tickerA = FakeFrameTicker();
      final tickerB = FakeFrameTicker();
      final cubitA = _cubitFor(_casualRace, tickerA);
      final cubitB = _cubitFor(_casualRace, tickerB);
      addTearDown(cubitA.close);
      addTearDown(cubitB.close);

      final a = _timeline(cubitA, _casualRace, defaultLevel, tickerA);
      final b = _timeline(cubitB, _casualRace, defaultLevel, tickerB);
      expect(a.times, isNotEmpty);
      expect(a.times, b.times);
      expect(a.moves, b.moves);
      expect(cubitA.rivalSession!.state, cubitB.rivalSession!.state);
    });

    test('Rematch replays the same move times and moves', () {
      final ticker = FakeFrameTicker();
      final cubit = _cubitFor(_casualRace, ticker);
      addTearDown(cubit.close);

      final first = _timeline(cubit, _casualRace, defaultLevel, ticker);
      expect(cubit.rematch(), _casualRace);
      final again = _timeline(cubit, _casualRace, defaultLevel, ticker);
      expect(again.times, first.times);
      expect(again.moves, first.moves);
    });

    test('every rival move is mirrored (MoveApplied) onto the rival '
        'session: it tracks the bot exactly', () {
      final ticker = FakeFrameTicker();
      final cubit = _cubitFor(_casualRace, ticker);
      addTearDown(cubit.close);
      final timeline = _timeline(cubit, _casualRace, defaultLevel, ticker);
      expect(timeline.moves, hasLength(5)); // measured: rival 1 race 1, 5 steps
      expect(cubit.rivalSession!.state, cubit.bot!.snapshot());
      expect(cubit.state.data!.phase, RacePhase.finished);
      expect(cubit.state.data!.result, RaceResult.rivalWon);
    });

    test('a stalled or backgrounded frame counts at most maxFrameDelta of '
        'running time, never the raw gap', () {
      final ticker = FakeFrameTicker();
      final cubit = _cubitFor(_fastRace, ticker)
        ..playerBoardLoaded(raceEntry(_fastRace, lockDeadlockLevel));
      addTearDown(cubit.close);
      cubit.start();
      ticker.tick();
      // One 10 s gap must not itself cross paceMs (>= 1600 ms): if the raw
      // gap counted, one tick would already restart the rival.
      ticker.tick(const Duration(seconds: 10));
      expect(cubit.state.data!.rivalRestarts, 0);

      // Enough further 10 s gaps (each worth only maxFrameDelta) eventually
      // reach even the largest possible due time.
      final worstDueMs = cubit.paceMs + cubit.paceMs * cubit.jitterPct ~/ 100;
      final gapsNeeded =
          (worstDueMs / RaceRules.maxFrameDelta.inMilliseconds).ceil() + 1;
      for (var i = 1; i < gapsNeeded; i++) {
        ticker.tick(const Duration(seconds: 10));
      }
      expect(cubit.state.data!.rivalRestarts, 1);
    });
  });

  group('Restarts on a dead board (m7-design P2.5)', () {
    test('every due crossing restarts: startingOver, rivalSets back to 0, '
        'rivalRestarts up by one, one emit per step', () {
      final ticker = FakeFrameTicker();
      final cubit = _cubitFor(_fastRace, ticker)
        ..playerBoardLoaded(raceEntry(_fastRace, lockDeadlockLevel));
      addTearDown(cubit.close);
      cubit.start();
      ticker.tick();

      var running = 0;
      for (var i = 1; i <= 3; i++) {
        final at = _tickToNextStep(cubit, ticker, running: running);
        expect(at, isNotNull, reason: 'restart $i');
        running = at!;
        final data = cubit.state.data!;
        expect(data.activity, RivalActivity.startingOver, reason: 'restart $i');
        expect(data.rivalSets, 0, reason: 'restart $i');
        expect(data.rivalRestarts, i, reason: 'restart $i');
        expect(data.rivalMoves, 0, reason: 'restart $i: no move is played');
        expect(data.phase, RacePhase.running);
      }
    });
  });

  group('Holds (m7-design P2.5, spec-prop §7.7 "Pause")', () {
    test('pause, overlay and app each stop the clock; held mirrors any '
        'hold', () {
      for (final hold in RaceHold.values) {
        final ticker = FakeFrameTicker();
        final cubit = _cubitFor(_casualRace, ticker);
        addTearDown(cubit.close);
        _load(cubit, _casualRace, defaultLevel, ticker);
        expect(ticker.isTicking, isTrue, reason: hold.name);

        cubit.setHold(hold, held: true);
        expect(cubit.state.data!.held, isTrue, reason: hold.name);
        expect(ticker.isTicking, isFalse, reason: hold.name);

        cubit.setHold(hold, held: false);
        expect(cubit.state.data!.held, isFalse, reason: hold.name);
        expect(ticker.isTicking, isTrue, reason: hold.name);
      }
    });

    test('holds stack: only the last one off resumes the clock', () {
      final ticker = FakeFrameTicker();
      final cubit = _cubitFor(_casualRace, ticker);
      addTearDown(cubit.close);
      _load(cubit, _casualRace, defaultLevel, ticker);

      cubit.setHold(RaceHold.pause, held: true);
      cubit.setHold(RaceHold.overlay, held: true);
      expect(ticker.isTicking, isFalse);

      cubit.setHold(RaceHold.pause, held: false);
      expect(cubit.state.data!.held, isTrue, reason: 'overlay still on');
      expect(ticker.isTicking, isFalse);

      cubit.setHold(RaceHold.overlay, held: false);
      expect(cubit.state.data!.held, isFalse);
      expect(ticker.isTicking, isTrue);

      // Setting the same hold on twice, or off twice, is a no-op.
      cubit.setHold(RaceHold.app, held: true);
      final held = cubit.state.data;
      cubit.setHold(RaceHold.app, held: true);
      expect(cubit.state.data, same(held));
    });

    // M7 review R8: Pause opened during a Rematch's or New race's spinner
    // (the old board still playing) must survive the next board's load.
    for (final again in ['Rematch', 'New race']) {
      test('a hold set while waiting ($again) still holds once the board '
          'loads: Start keeps the clock off until it lifts', () {
        final ticker = FakeFrameTicker();
        final save = FakeSaveService(
          initial: unlockedRaceDocument(
            race: const RaceProgress(
              rivals: [
                RivalProgress(unlocked: true, wins: 1, raceNo: 1),
                RivalProgress(unlocked: true, raceNo: 1),
                RivalProgress(),
              ],
            ),
          ),
        );
        final cubit = _cubitFor(_fastRace, ticker, save: save);
        addTearDown(cubit.close);
        _load(cubit, _fastRace, defaultLevel, ticker);
        ticker.advance(const Duration(seconds: 30));
        expect(cubit.state.data!.result, RaceResult.rivalWon);

        final request = again == 'Rematch' ? cubit.rematch() : cubit.newRace()!;
        expect(cubit.state.data!.phase, RacePhase.waiting);
        cubit.setHold(RaceHold.pause, held: true);
        expect(cubit.state.data!.held, isTrue);

        cubit.playerBoardLoaded(raceEntry(request, defaultLevel));
        expect(cubit.state.data!.phase, RacePhase.ready);
        expect(cubit.state.data!.held, isTrue, reason: 'held mirrors holds');

        cubit.start();
        expect(cubit.state.data!.phase, RacePhase.running);
        expect(cubit.state.data!.clockRunning, isFalse);
        expect(ticker.isTicking, isFalse, reason: 'Pause is still up');
        ticker.advance(const Duration(seconds: 10));
        expect(cubit.state.data!.rivalMoves, 0);

        cubit.setHold(RaceHold.pause, held: false);
        expect(cubit.state.data!.held, isFalse);
        expect(cubit.state.data!.clockRunning, isTrue);
        expect(ticker.isTicking, isTrue);
      });
    }

    test('no due time moves while held: resuming continues exactly where '
        'the race was', () {
      final ticker = FakeFrameTicker();
      final cubit = _cubitFor(_casualRace, ticker);
      addTearDown(cubit.close);
      _load(cubit, _casualRace, defaultLevel, ticker);

      // Most of the way to the first move, then hold well past when it
      // would have been due.
      var running = 0;
      for (var i = 0; i < 20; i++) {
        running = _tickBy(ticker, running);
      }
      expect(cubit.state.data!.rivalMoves, 0, reason: '500 ms < any paceMs');
      cubit.setHold(RaceHold.pause, held: true);
      for (var i = 0; i < 400; i++) {
        ticker.tick(const Duration(milliseconds: 25)); // ignored while held
      }
      expect(cubit.state.data!.rivalMoves, 0);

      cubit.setHold(RaceHold.pause, held: false);
      final at = _tickToNextStep(cubit, ticker, running: running);
      expect(at, isNotNull);
      // The due time picked up from 500 ms, not from the 10 s spent held.
      expect(at! - running, lessThan(cubit.paceMs + 1000));
    });
  });

  group('The player wins (m7-design P2.5)', () {
    test('a won board while running pays and records the win exactly once; '
        'a second won board is ignored', () async {
      final ticker = FakeFrameTicker();
      final save = FakeSaveService(initial: unlockedRaceDocument());
      var changes = 0;
      final sub = save.changes.listen((_) => changes++);
      addTearDown(sub.cancel);
      final cubit = _cubitFor(_fastRace, ticker, save: save);
      addTearDown(cubit.close);
      _load(cubit, _fastRace, defaultLevel, ticker);

      final won = GameSession(defaultLevel)
        ..move(red1, red2)
        ..move(red2, red3);
      expect(won.isWon, isTrue);

      cubit.playerBoardChanged(won.state);
      final data = cubit.state.data!;
      expect(data.phase, RacePhase.finished);
      expect(data.result, RaceResult.playerWon);
      expect(data.outcome, isNotNull);
      expect(data.outcome!.coins, 20);
      expect(save.document.coins, 20);
      expect(save.document.race.rivals[1].wins, 1);
      expect(ticker.isTicking, isFalse);

      cubit.playerBoardChanged(won.state);
      expect(cubit.state.data, same(data));
      expect(save.document.coins, 20, reason: 'never paid twice');

      // The clock is stopped: further ticks never restart or move the
      // rival, and never emit again.
      final beforeTicks = cubit.state.data;
      for (var i = 0; i < 200; i++) {
        ticker.tick(const Duration(milliseconds: 25));
      }
      expect(cubit.state.data, same(beforeTicks));
      await pumpEventQueue();
      expect(changes, greaterThanOrEqualTo(1));
    });

    test(
      'a board that has not won, or a win outside running, does nothing',
      () {
        final ticker = FakeFrameTicker();
        final cubit = _cubitFor(_fastRace, ticker);
        addTearDown(cubit.close);
        cubit.playerBoardLoaded(raceEntry(_fastRace, defaultLevel));
        final ready = cubit.state.data;
        // Ready, not running yet: ignored.
        final wonState =
            (GameSession(defaultLevel)
                  ..move(red1, red2)
                  ..move(red2, red3))
                .state;
        cubit.playerBoardChanged(wonState);
        expect(cubit.state.data, same(ready));

        cubit.start();
        ticker.tick();
        final running = cubit.state.data;
        // A board still in play: no win.
        cubit.playerBoardChanged(GameState.initial(defaultLevel));
        expect(cubit.state.data, same(running));
      },
    );
  });

  group('The rival wins (m7-design P2.5)', () {
    test('a loss writes nothing to the save', () async {
      final ticker = FakeFrameTicker();
      final save = FakeSaveService(initial: unlockedRaceDocument());
      var changes = 0;
      final sub = save.changes.listen((_) => changes++);
      addTearDown(sub.cancel);
      final cubit = _cubitFor(_fastRace, ticker, save: save);
      addTearDown(cubit.close);
      final before = save.document;
      _timeline(cubit, _fastRace, defaultLevel, ticker);

      expect(cubit.state.data!.phase, RacePhase.finished);
      expect(cubit.state.data!.result, RaceResult.rivalWon);
      expect(cubit.state.data!.outcome, isNull);
      await pumpEventQueue();
      expect(changes, 0);
      expect(save.document, before);
    });
  });

  group('The tie (m7-design P2.5, spec-prop §7.7 "on the same frame the '
      'player wins")', () {
    test('board-then-tick: the player\'s win, delivered first, decides it', () {
      final ticker = FakeFrameTicker();
      final cubit = _cubitFor(_fastRace, ticker);
      addTearDown(cubit.close);
      _load(cubit, _fastRace, defaultLevel, ticker);

      final won = GameSession(defaultLevel)
        ..move(red1, red2)
        ..move(red2, red3);
      // Deliver the player's win before the rival's due tick (2 steps at
      // most 3600 ms away).
      cubit.playerBoardChanged(won.state);
      expect(cubit.state.data!.result, RaceResult.playerWon);

      // The rival's due tick, whenever it would have landed, changes
      // nothing: the ticker is already stopped, and the result stands.
      for (var i = 0; i < 400; i++) {
        ticker.tick(const Duration(milliseconds: 25));
      }
      expect(cubit.state.data!.result, RaceResult.playerWon);
    });

    test('tick-then-board: the rival\'s due tick, processed first, decides '
        'it', () {
      final ticker = FakeFrameTicker();
      final cubit = _cubitFor(_fastRace, ticker);
      addTearDown(cubit.close);
      _timeline(cubit, _fastRace, defaultLevel, ticker); // ticks to a finish
      expect(cubit.state.data!.result, RaceResult.rivalWon);

      // The player's win, arriving after, is ignored (a rival finish in
      // that frame's tick "comes first").
      final won = GameSession(defaultLevel)
        ..move(red1, red2)
        ..move(red2, red3);
      cubit.playerBoardChanged(won.state);
      expect(cubit.state.data!.result, RaceResult.rivalWon);
    });
  });

  group('Rival unlocked (m7-design P2.5, P2.7)', () {
    test('a first win against rival 1 surfaces outcome.unlockedRival', () {
      final ticker = FakeFrameTicker();
      final save = FakeSaveService(initial: unlockedRaceDocument());
      final cubit = _cubitFor(_casualRace, ticker, save: save);
      addTearDown(cubit.close);
      _load(cubit, _casualRace, defaultLevel, ticker);

      final won = GameSession(defaultLevel)
        ..move(red1, red2)
        ..move(red2, red3);
      cubit.playerBoardChanged(won.state);
      expect(cubit.state.data!.outcome!.unlockedRival, 2);
    });
  });

  group('New race against the unlocked rival (frame 9.6)', () {
    RaceCubit won(FakeSaveService save, FakeFrameTicker ticker) {
      final cubit = _cubitFor(_casualRace, ticker, save: save);
      addTearDown(cubit.close);
      _load(cubit, _casualRace, defaultLevel, ticker);
      final session = GameSession(defaultLevel)
        ..move(red1, red2)
        ..move(red2, red3);
      cubit.playerBoardChanged(session.state);
      return cubit;
    }

    test('chooseNextRival makes the next newRace the unlocked rival\'s, '
        'once', () {
      final ticker = FakeFrameTicker();
      final save = FakeSaveService(initial: unlockedRaceDocument());
      final cubit = won(save, ticker);
      expect(cubit.state.data!.outcome!.unlockedRival, 2);

      cubit.chooseNextRival(2);
      final request = cubit.newRace();
      expect(request, const RacePlay(rival: 2, raceNo: 1));
      expect(cubit.request, request);
      expect(save.document.race.rivals[1].raceNo, 1);
      expect(save.document.race.rivals[0].raceNo, 0, reason: 'rival 1 kept');
      expect(cubit.state.data!.phase, RacePhase.waiting);
    });

    test('a locked or unknown rival is ignored: newRace stays on the '
        'current rival', () {
      final ticker = FakeFrameTicker();
      final save = FakeSaveService(initial: unlockedRaceDocument());
      final cubit = won(save, ticker);
      cubit
        ..chooseNextRival(3)
        ..chooseNextRival(0)
        ..chooseNextRival(9);
      expect(cubit.newRace(), const RacePlay(rival: 1, raceNo: 1));
      expect(save.document.race.rivals[2].raceNo, 0);
    });

    test('the pick applies to one newRace only', () {
      final ticker = FakeFrameTicker();
      final save = FakeSaveService(initial: unlockedRaceDocument());
      final cubit = won(save, ticker);
      cubit.chooseNextRival(2);
      expect(cubit.newRace(), const RacePlay(rival: 2, raceNo: 1));
      // Its board loads, and that race is won as well.
      _load(cubit, cubit.request, defaultLevel, ticker);
      final again = GameSession(defaultLevel)
        ..move(red1, red2)
        ..move(red2, red3);
      cubit.playerBoardChanged(again.state);
      expect(cubit.newRace(), const RacePlay(rival: 2, raceNo: 2));
    });
  });

  group('Leaving (m7-design P2.5, spec-prop §7.7 "Save")', () {
    test('close() mid-race disposes the clock and writes nothing', () async {
      final ticker = FakeFrameTicker();
      final save = FakeSaveService(initial: unlockedRaceDocument());
      final cubit = _cubitFor(_casualRace, ticker, save: save);
      _load(cubit, _casualRace, defaultLevel, ticker);
      var running = 0;
      for (var i = 0; i < 10; i++) {
        running = _tickBy(ticker, running);
      }
      final before = save.document;
      await cubit.close();
      expect(ticker.isDisposed, isTrue);
      expect(save.document, before);
    });
  });

  group('Rematch and New race outside finished (m7-design P2.5)', () {
    test('do nothing while running', () {
      final ticker = FakeFrameTicker();
      final save = FakeSaveService(initial: unlockedRaceDocument());
      final cubit = _cubitFor(_casualRace, ticker, save: save);
      addTearDown(cubit.close);
      _load(cubit, _casualRace, defaultLevel, ticker);
      final running = cubit.state.data;

      expect(cubit.rematch(), _casualRace);
      expect(cubit.state.data, same(running));
      expect(cubit.newRace(), isNull);
      expect(cubit.state.data, same(running));
      expect(save.document.race.rivals[0].raceNo, 0);
    });
  });
}
