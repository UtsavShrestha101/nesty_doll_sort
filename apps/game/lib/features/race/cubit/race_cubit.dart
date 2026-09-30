import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/race/race_rules.dart';
import 'package:nesty_game/core/services/records/badge_rules.dart';
import 'package:nesty_game/core/services/records/record_rules.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/ticker/frame_ticker.dart';

part 'race_cubit.freezed.dart';
part 'race_state.dart';

/// The race beside the player's board (vs Computer; spec-prop §7.7;
/// docs/plans/mode-vs-computer.md; docs/plans/m7-design.md P2.5).
///
/// The gameplay page with a `PlayRequest.race` provides it next to the
/// `GameplayBloc`: the bloc plays the player's board, this cubit the rest.
/// It owns the rival (core's [RivalBot], mirrored in a second
/// [GameSession] of the player's very own [Level], so both sides start
/// from identical copies), the rival's clock (an injected [FrameTicker]),
/// the pace and its jitter ([RaceRules]), the holds, and the result, and
/// it writes a win with `SaveService.recordRaceWin` exactly once.
///
/// The page drives it (m7-design P2.5, P2.8):
/// - [playerBoardLoaded] when the bloc's board starts (its
///   `BoardResetEffect.start`): the rival is built from the race's seed,
///   and the race is [RacePhase.ready];
/// - [start] on the Start button: no countdown (vs-computer rule 4);
/// - [playerBoardChanged] with every board the bloc emits: a won one while
///   the race runs is the player's win;
/// - [setHold] for Pause, a sheet or overlay, and the app lifecycle;
/// - [rematch] and [newRace] on the result card, then `GameplayStarted`
///   with the request they return, on the same page.
///
/// The rival moves only inside a frame tick, and at most once per frame,
/// so a player's win that lands before a frame beats a rival move due in
/// it (spec-prop §7.7 "on the same frame the player wins"). A tick that
/// isn't due does integer arithmetic only: no emit, no allocation (rule 8).
///
@injectable
class RaceCubit extends BaseAsyncCubit<RaceState> {
  RaceCubit(
    @factoryParam RacePlay request,
    this._save,
    this._remoteConfig,
    this._ticker,
  ) : _request = request;

  final SaveService _save;
  final RemoteConfigService _remoteConfig;
  final FrameTicker _ticker;

  /// The race in play: the route's, then the one [newRace] began.
  RacePlay _request;

  /// [chooseNextRival]'s pick, consumed by the next [newRace].
  int? _nextRival;

  RivalBot? _bot;
  GameSession? _rival;
  Prng? _pace;
  int _paceMs = 0;
  int _jitterPct = 0;
  int _rewardCoins = 0;

  /// Holds stacked on the race (spec-prop §7.7 "Pause"): the clock runs
  /// only while this is empty; [RaceState.held] mirrors "any hold".
  final Set<RaceHold> _holds = {};

  // The race clock is kept in int microseconds, not `Duration`s: a
  // `Duration` is a heap object and `+`/`-` return a new one, so a field of
  // them would allocate on every frame (rule 8; m7-design P2.5; M7 review
  // R33).

  /// Running time accumulated since [start], in microseconds (the clamped
  /// frame deltas, summed): zero again only at [start], never at a hold
  /// (background time never counts, and the due time doesn't move while
  /// held).
  int _runningUs = 0;

  /// The running time of the rival's next step, in microseconds.
  int _dueUs = 0;

  /// The ticker's own elapsed time at the last tick, in microseconds, so a
  /// delta is taken against it rather than the wall clock: a ticker just
  /// (re)started reports elapsed from zero again (m7-design P2.5).
  int _lastTickUs = 0;

  /// [RaceRules.maxFrameDelta] in microseconds.
  static const int _maxFrameDeltaUs =
      RaceRules.maxFrameDeltaMs * Duration.microsecondsPerMillisecond;

  /// The race in play (the route's until [newRace] begins another).
  RacePlay get request => _request;

  /// The rival of the race in play, for tests.
  @visibleForTesting
  RivalBot? get bot => _bot;

  /// The rival's mirrored board, for tests.
  @visibleForTesting
  GameSession? get rivalSession => _rival;

  /// Milliseconds per rival move for this race (`RaceRules.paceMs`), read
  /// when the board loads.
  int get paceMs => _paceMs;

  /// The jitter for this race (`RaceRules.jitterPct`), read when the board
  /// loads.
  int get jitterPct => _jitterPct;

  /// The pace stream of the race in play (`RaceRules.pacePrng`), for the
  /// clock's intervals (`RaceRules.nextIntervalMs`).
  @protected
  Prng? get pace => _pace;

  /// Coins a win of the race in play pays (its `PlayEntry.rewardCoins`).
  @protected
  int get rewardCoins => _rewardCoins;

  /// The page's board for this race has loaded ([play] is the bloc's
  /// `PlayEntry`; the page calls this on the bloc's `BoardResetEffect` of
  /// reason `start`). Builds the rival on [play]'s own [Level]:
  /// `RivalBot(level, policy: DifficultyCurve.racePolicy(rival), raceSeed:
  /// DifficultyCurve.raceSeed(rival, raceNo))`, its mirror `GameSession`,
  /// and the pace stream `RaceRules.pacePrng(raceSeed)`; reads the pace and
  /// jitter; and makes the race [RacePhase.ready], both sides at rest.
  ///
  /// A Rematch loads the same request, so the same seed replays the same
  /// rival moves at the same intervals (spec-prop §7.7). An entry that is
  /// not this race's is ignored; one core can't race (no family) is an
  /// [AppExceptionKind.content] error.
  void playerBoardLoaded(PlayEntry play) {
    if (isClosed || play.request != _request) return;
    final rival = _request.rival;
    final raceSeed = DifficultyCurve.raceSeed(rival, _request.raceNo);
    final RivalBot bot;
    try {
      bot = RivalBot(
        play.level,
        policy: DifficultyCurve.racePolicy(rival),
        raceSeed: raceSeed,
      );
    } on ArgumentError catch (error) {
      emit(
        AsyncValue.error(
          exception: AppException(
            AppExceptionKind.content,
            message: 'No race on ${play.level.id}: $error',
          ),
          data: state.data,
        ),
      );
      return;
    }
    _ticker.stop();
    _bot = bot;
    _rival = GameSession(play.level);
    _pace = RaceRules.pacePrng(raceSeed);
    _paceMs = RaceRules.paceMs(rival, _remoteConfig);
    _jitterPct = RaceRules.jitterPct(_remoteConfig);
    _rewardCoins = play.rewardCoins;
    emit(
      AsyncValue.data(
        data: RaceState(
          request: _request,
          phase: RacePhase.ready,
          // A hold set while the race was waiting (Pause opened during a
          // Rematch's or New race's spinner) is still on: `held` mirrors
          // it, so Start keeps the clock off and releasing it resumes
          // (m7-design P2.5; M7 review R8).
          held: _holds.isNotEmpty,
          totalSets: bot.totalSets,
          rivalBoard: _rival!.state,
        ),
      ),
    );
  }

  /// Start (vs-computer rule 4): [RacePhase.ready] → [RacePhase.running] at
  /// once, no countdown; the rival's first move comes one interval later.
  /// The page then opens the bloc's gate (`RaceGateChanged(open: true)`).
  /// Does nothing in any other phase.
  void start() {
    final current = state.data;
    if (isClosed || current == null || current.phase != RacePhase.ready) {
      return;
    }
    final pace = _pace;
    if (pace == null) return; // playerBoardLoaded always sets it before ready
    _runningUs = 0;
    _lastTickUs = 0;
    _dueUs = _intervalUs(pace);
    emit(
      AsyncValue.data(
        data: current.copyWith(
          phase: RacePhase.running,
          activity: RivalActivity.thinking,
        ),
      ),
    );
    // A hold set before Start (spec-prop §7.7) still counts: the clock
    // starts only once every hold lifts (setHold). Read from the holds
    // themselves, never the state's copy of them (M7 review R8).
    if (_holds.isEmpty) _ticker.start(_onTick);
  }

  /// The player's board after a change (the page forwards every board the
  /// bloc emits). A won board while the race runs and has no result is the
  /// player's win (spec-prop §7.7): the clock stops,
  /// `SaveService.recordRaceWin` runs exactly once, and the state carries
  /// [RaceResult.playerWon] and the outcome. Anything else does nothing.
  void playerBoardChanged(GameState board) {
    final current = state.data;
    if (isClosed ||
        current == null ||
        current.phase != RacePhase.running ||
        current.result != null ||
        !board.isWon) {
      return; // not running, already decided (the tie, m7-design P2.5), or not a win
    }
    _ticker.stop();
    // `start` never runs until `playerBoardLoaded` set the rival, so this
    // is always the race's own level.
    final level = _bot!.level;
    final outcome = _save.recordRaceWin(
      RaceWinRecord(
        rival: current.rival,
        raceNo: _request.raceNo,
        rewardCoins: _rewardCoins,
        moves: board.moveCount,
        families: RecordRules.familiesIn(level),
        dolls: RecordRules.dollsNestedIn(level),
        boardBadges: BadgeRules.forWonLevel(level),
      ),
    );
    emit(
      AsyncValue.data(
        data: current.copyWith(
          phase: RacePhase.finished,
          result: RaceResult.playerWon,
          outcome: outcome,
        ),
      ),
    );
  }

  /// [hold] went on or off (spec-prop §7.7 "Pause: pausing, a sheet or the
  /// app going to the background stops the rival too"). Holds stack: the
  /// clock runs only with none, and resuming continues exactly where the
  /// race was (no due time moves while held; the ticker restarts from
  /// zero, so background time never counts).
  void setHold(RaceHold hold, {required bool held}) {
    final current = state.data;
    if (isClosed || current == null) return;
    final changed = held ? _holds.add(hold) : _holds.remove(hold);
    if (!changed) return; // already on, or already off: nothing to do
    final anyHeld = _holds.isNotEmpty;
    if (anyHeld == current.held) return; // another hold still stacked
    if (anyHeld) {
      _ticker.stop();
    } else if (current.phase == RacePhase.running) {
      // The ticker restarts from elapsed zero (`FrameTicker.start`), so the
      // next delta is taken against zero too: background time never counts
      // and the due time doesn't move (m7-design P2.5).
      _lastTickUs = 0;
      _ticker.start(_onTick);
    }
    emit(AsyncValue.data(data: current.copyWith(held: anyHeld)));
  }

  /// One frame of the rival's clock, while [RaceState.clockRunning]
  /// (m7-design P2.5): the elapsed delta since the last tick, clamped to
  /// [RaceRules.maxFrameDelta] so a stalled frame or a frame right after a
  /// hold lifts never bursts moves, added to the running time. At most one
  /// rival [_step] per tick; a tick that isn't due yet does this integer
  /// arithmetic only (rule 8).
  void _onTick(Duration elapsed) {
    final elapsedUs = elapsed.inMicroseconds;
    var delta = elapsedUs - _lastTickUs;
    _lastTickUs = elapsedUs;
    if (delta < 0) delta = 0;
    if (delta > _maxFrameDeltaUs) delta = _maxFrameDeltaUs;
    _runningUs += delta;
    if (_runningUs < _dueUs) return;
    _step();
  }

  /// The next rival interval (`RaceRules.nextIntervalMs`), in microseconds.
  int _intervalUs(Prng pace) =>
      RaceRules.nextIntervalMs(pace, _paceMs, _jitterPct) *
      Duration.microsecondsPerMillisecond;

  /// One pass of the rival ([RivalStep], m7-design P2.5): `moved` mirrors
  /// the move onto [_rival] and schedules the next interval; `finished`
  /// mirrors the move too, then ends the race as [RaceResult.rivalWon];
  /// `restarted` resets the mirror and schedules the next interval, with
  /// [RivalActivity.startingOver] for it. One emit, never more than one
  /// rival move, per call.
  void _step() {
    final current = state.data;
    final bot = _bot;
    final rival = _rival;
    final pace = _pace;
    if (current == null || bot == null || rival == null || pace == null) {
      return;
    }
    switch (bot.step()) {
      case RivalStep.moved:
        _applyRivalMove(bot, rival);
        _dueUs += _intervalUs(pace);
        emit(
          AsyncValue.data(
            data: current.copyWith(
              activity: RivalActivity.thinking,
              rivalSets: rival.state.completedSets,
              rivalMoves: current.rivalMoves + 1,
              rivalBoard: rival.state,
            ),
          ),
        );
      case RivalStep.finished:
        _applyRivalMove(bot, rival);
        _ticker.stop();
        emit(
          AsyncValue.data(
            data: current.copyWith(
              phase: RacePhase.finished,
              result: RaceResult.rivalWon,
              activity: RivalActivity.finished,
              rivalSets: rival.state.completedSets,
              rivalMoves: current.rivalMoves + 1,
              rivalBoard: rival.state,
            ),
          ),
        );
      case RivalStep.restarted:
        rival.restart();
        _dueUs += _intervalUs(pace);
        emit(
          AsyncValue.data(
            data: current.copyWith(
              activity: RivalActivity.startingOver,
              rivalSets: 0,
              rivalRestarts: current.rivalRestarts + 1,
              rivalBoard: rival.state,
            ),
          ),
        );
    }
  }

  /// Plays the rival's [bot] move (`lastFrom` → `lastTo`) on its mirrored
  /// [rival] session: always legal, since both sides start from identical
  /// copies of the same board and [rival] only ever replays the bot's own
  /// moves and restarts (m7-design P2.5).
  void _applyRivalMove(RivalBot bot, GameSession rival) {
    final applied = rival.move(bot.lastFrom, bot.lastTo);
    assert(
      applied is MoveApplied,
      'RivalBot proposed an illegal move: ${bot.lastFrom} -> ${bot.lastTo}',
    );
  }

  /// The rival the next [newRace] races: frame 9.6's "New race" against the
  /// rival a win just unlocked. Set before the page's own New race runs, so
  /// the page's callback needs no rival argument. It applies to one
  /// [newRace] only, and only for a rival the save has unlocked; any other
  /// is ignored.
  void chooseNextRival(int rival) {
    if (isClosed) return;
    final rivals = _save.document.race.rivals;
    if (rival < 1 || rival > rivals.length || !rivals[rival - 1].unlocked) {
      return;
    }
    _nextRival = rival;
  }

  /// Rematch (spec-prop §7.7 "Rematch replays the same board and the same
  /// rival moves"): from [RacePhase.finished] back to [RacePhase.waiting]
  /// with the same request, which it returns; the page sends
  /// `GameplayStarted` with it and the next [playerBoardLoaded] rebuilds
  /// the rival from run 0. Writes nothing (the raceNo stays). In any other
  /// phase it changes nothing and returns the race in play.
  RacePlay rematch() {
    final current = state.data;
    if (isClosed || current == null || current.phase != RacePhase.finished) {
      return _request;
    }
    _resetRival();
    emit(AsyncValue.data(data: RaceState(request: _request)));
    return _request;
  }

  /// New race (spec-prop §7.7 "New race uses the next `raceNo`"): from
  /// [RacePhase.finished], `SaveService.beginRace(rival)` stores the next
  /// raceNo, and the race goes back to [RacePhase.waiting] with that
  /// request, which it returns for `GameplayStarted`. Null, with nothing
  /// changed, in any other phase or when the save refuses the rival.
  RacePlay? newRace() {
    final current = state.data;
    if (isClosed || current == null || current.phase != RacePhase.finished) {
      return null;
    }
    final rival = _nextRival ?? _request.rival;
    _nextRival = null;
    final raceNo = _save.beginRace(rival);
    if (raceNo == null) return null;
    _request = RacePlay(rival: rival, raceNo: raceNo);
    _resetRival();
    emit(AsyncValue.data(data: RaceState(request: _request)));
    return _request;
  }

  void _resetRival() {
    _ticker.stop();
    _bot = null;
    _rival = null;
    _pace = null;
    // Rematch/New race goes back to a fresh RaceState (held: false), so no
    // hold carries over into the next race (spec-prop §7.7).
    _holds.clear();
  }

  /// Leaving the race (Quit race, back, a kill) ends it with no reward and
  /// no penalty (spec-prop §7.7 "Save"): nothing is written here.
  @override
  Future<void> close() {
    _ticker.dispose();
    return super.close();
  }
}
