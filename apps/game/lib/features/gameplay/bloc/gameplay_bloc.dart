import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_bloc.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/solver/solver_service.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/tap_policy.dart';
import 'package:nesty_game/features/gameplay/bloc/win_reward.dart';

part 'gameplay_bloc.freezed.dart';
part 'gameplay_event.dart';
part 'gameplay_state.dart';

/// Owns the level's nesty_core `GameSession` and turns intents into core
/// calls, state and [BoardEffect]s (spec §2.2–§2.4, §8, §13.1;
/// docs/plans/m2-lottie-design.md §11). Events are handled strictly in
/// order (`BaseAsyncBloc`), so a tap can never overtake the drop before it.
///
/// It never re-checks legality, detects completion or edits the board
/// (CLAUDE.md rule 2): the tap policy of frame 2.6 (D22, [TapPolicy]) only
/// decides *which* core call a touch becomes, and won / out of moves come
/// from core. Solver futures are never awaited inside [handleEvent]; their
/// results come back as [HintResultArrived] / [SoftStuckResultArrived]
/// tagged with the `moveSeq` they were asked for, and stale ones are
/// dropped.
///
/// Boosters (spec §8): undos are free [SaveService.freeUndosPerLevel] times
/// per level; hints and extra slots come from the save's wallet; the dev
/// flavor's [SaveService.unlimitedBoosters] never runs out or charges; and
/// debug builds add extra slots for free (spec §18 M2), still at most 2
/// per level (core).
///
/// Every new [BoardEffect] comes with a new `effectSeq`. A tap that also
/// clears the hint emits two states: [HintClearedEffect], then the tap's
/// own effect. A handler that changes nothing emits nothing (bloc drops a
/// state equal to the current one).
@injectable
class GameplayBloc extends BaseAsyncBloc<GameplayEvent, GameplayState> {
  GameplayBloc(
    this._levels,
    this._solver,
    this._remoteConfig,
    this._save,
    this._analytics, {
    @ignoreParam bool freeExtraSlots = kDebugMode,
    @ignoreParam Duration softStuckDebounce = softStuckDelay,
  }) : _freeExtraSlots = freeExtraSlots,
       _softStuckDebounce = softStuckDebounce;

  /// The soft-stuck check runs this long after the last board change, so a
  /// burst of moves asks the solver once (m2-lottie-design §11).
  static const Duration softStuckDelay = Duration(milliseconds: 300);

  final LevelRepository _levels;
  final SolverService _solver;
  final RemoteConfigService _remoteConfig;
  final SaveService _save;
  final AnalyticsService _analytics;

  /// +1 Slot uses no booster (spec §18 M2 "extra slot (free in debug)").
  final bool _freeExtraSlots;
  final Duration _softStuckDebounce;

  GameSession? _session;

  /// Free undos of the level in play, read once at its start (spec §7.3).
  int _freeUndosPerLevel = 0;

  /// The slot a drag is holding, from [SlotDragStarted] to
  /// [SlotDragDropped].
  String? _dragging;

  /// The `moveSeq` of the hint request in flight, if any. Its result is
  /// dropped when the board has changed since.
  int? _pendingHintSeq;

  Timer? _softStuckTimer;

  // Per-level stats for `level_win` (spec §14.4). A restart keeps them,
  // like the undo count (per level, D22).
  final Stopwatch _levelClock = Stopwatch();
  int _attemptNumber = 0;
  int _hintsUsed = 0;
  int _slotsUsed = 0;

  /// The session of the level in play, for tests.
  @visibleForTesting
  GameSession? get session => _session;

  @override
  Future<void> handleEvent(
    GameplayEvent event,
    Emitter<AsyncValue<GameplayState>> emit,
  ) => switch (event) {
    GameplayStarted(:final levelNumber) => runGuarded(
      emit,
      () async => _start(levelNumber),
    ),
    SlotTapped(:final slotId) => _inPlay(
      emit,
      (current, session) => _tap(emit, current, session, slotId),
    ),
    SlotDragStarted(:final slotId) => _inPlay(
      emit,
      (current, session) => _dragStart(emit, current, session, slotId),
    ),
    SlotDragDropped(:final slotId) => _inPlay(
      emit,
      (current, session) => _drop(current, session, slotId),
    ),
    UndoPressed() => _inPlay(emit, _undo),
    RestartPressed() => _inPlay(emit, _restart),
    HintPressed() => _inPlay(emit, (current, _) => _hintPressed(current)),
    ExtraSlotPressed() => _inPlay(emit, _addExtraSlot),
    PauseChanged(:final paused) => _inPlay(
      emit,
      (current, _) => current.copyWith(paused: paused),
    ),
    NextLevelPressed() => _inPlay(emit, (current, _) => _nextLevel(current)),
    SoftStuckCheckDue(:final moveSeq) => _inPlay(
      emit,
      (current, _) => _softStuckDue(current, moveSeq),
    ),
    HintResultArrived(:final result, :final moveSeq) => _inPlay(
      emit,
      (current, session) => _hintArrived(current, session, result, moveSeq),
    ),
    SoftStuckResultArrived(:final verdict, :final moveSeq) => _inPlay(
      emit,
      (current, _) => _softStuckArrived(current, verdict, moveSeq),
    ),
  };

  /// Runs [body] on the level in play; before [GameplayStarted] has loaded
  /// one, the event does nothing. [body] returns the next state, or
  /// `current` itself when nothing changes (bloc then emits nothing).
  Future<void> _inPlay(
    Emitter<AsyncValue<GameplayState>> emit,
    GameplayState Function(GameplayState current, GameSession session) body,
  ) async {
    final current = state.data;
    final session = _session;
    if (current == null || session == null) return;
    await runGuarded(emit, () async => body(current, session));
  }

  // --- Level lifecycle ----------------------------------------------------

  GameplayState _start(int levelNumber) {
    final entry = _levels.entryAt(levelNumber);
    if (entry == null) {
      // The page routes past the last level to All Levels Done (frame 4.9)
      // before creating the bloc, so this is missing content.
      throw AppException(
        AppExceptionKind.content,
        message: 'No level at order $levelNumber',
      );
    }
    return _begin(entry, state.data);
  }

  /// Loads [entry] into a new session. `effectSeq` and `moveSeq` keep
  /// counting from [previous], so the page's listener fires and no result
  /// asked for the previous level can pass as current.
  GameplayState _begin(LevelBundleEntry entry, GameplayState? previous) {
    _cancelSolverWork();
    final session = GameSession(entry.level);
    _session = session;
    _dragging = null;
    _freeUndosPerLevel = math.max(0, _save.freeUndosPerLevel);
    _attemptNumber = 1;
    _hintsUsed = 0;
    _slotsUsed = 0;
    _levelClock
      ..reset()
      ..start();
    _logLevelStart(entry);
    return _withBoosters(
      GameplayState(
        entry: entry,
        board: session.state,
        paused: previous?.paused ?? false,
        moveSeq: previous == null ? 0 : previous.moveSeq + 1,
        effectSeq: (previous?.effectSeq ?? 0) + 1,
        effect: BoardResetEffect(
          snapshot: session.state,
          reason: BoardResetReason.start,
        ),
      ),
      session,
    );
  }

  GameplayState _nextLevel(GameplayState current) {
    if (current.status != GameplayStatus.won) return current;
    final next = _levels.entryAt(current.levelNumber + 1);
    if (next == null) {
      // TODO(M3): Bonus Endless instead, past the last published level
      // (spec §7.1).
      return current.copyWith(status: GameplayStatus.allLevelsDone);
    }
    return _begin(next, current);
  }

  // --- Taps and drags (frame 2.6, D22) ----------------------------------

  GameplayState _tap(
    Emitter<AsyncValue<GameplayState>> emit,
    GameplayState current,
    GameSession session,
    String slotId,
  ) {
    if (!current.acceptsInput) return current;
    // A tap during a drag (a second finger) ends the drag: the board sends
    // no drop for it any more.
    _dragging = null;
    final base = _clearHint(emit, current);
    final selected = base.selectedSlotId;
    return switch (TapPolicy.tap(
      session.state,
      selected: selected,
      tapped: slotId,
    )) {
      SelectSlot(:final slotId) => _withEffect(
        base.copyWith(selectedSlotId: slotId),
        SelectionChangedEffect(selected: slotId),
      ),
      CancelSelection(:final slotId) => _withEffect(
        base.copyWith(selectedSlotId: null),
        SelectionChangedEffect(previous: slotId),
      ),
      AttemptMove(:final move) => _tryMove(base, session, move, byDrag: false),
      IgnoreTouch() => base,
    };
  }

  GameplayState _dragStart(
    Emitter<AsyncValue<GameplayState>> emit,
    GameplayState current,
    GameSession session,
    String slotId,
  ) {
    if (!current.acceptsInput) return current;
    final base = _clearHint(emit, current);
    switch (TapPolicy.dragStart(session.state, slotId)) {
      case SelectSlot(:final slotId):
        _dragging = slotId;
        final previous = base.selectedSlotId;
        return _withEffect(
          base.copyWith(selectedSlotId: slotId),
          SelectionChangedEffect(
            // Picking up the nest a tap already lifted settles nothing.
            previous: previous == slotId ? null : previous,
            selected: slotId,
            byDrag: true,
          ),
        );
      case CancelSelection() || AttemptMove() || IgnoreTouch():
        _dragging = null;
        return base;
    }
  }

  GameplayState _drop(
    GameplayState current,
    GameSession session,
    String? slotId,
  ) {
    final dragged = _dragging;
    _dragging = null;
    // A drop with no drag in progress (the drag start was ignored, or a
    // tap or a board reset ended it) does nothing.
    if (dragged == null) return current;
    if (!current.acceptsInput) {
      // Released while paused (a second finger on Pause, or the app hidden
      // mid-drag): no move, but the doll is put down, so after Resume it
      // flies home from the finger instead of staying lifted where the drag
      // left it (review CORRECTNESS-3).
      if (current.selectedSlotId != dragged) return current;
      return _withEffect(
        current.copyWith(selectedSlotId: null),
        SelectionChangedEffect(previous: dragged, byDrag: true),
      );
    }
    return switch (TapPolicy.drop(dragged: dragged, dropped: slotId)) {
      CancelSelection(:final slotId) => _withEffect(
        current.copyWith(selectedSlotId: null),
        SelectionChangedEffect(previous: slotId, byDrag: true),
      ),
      AttemptMove(:final move) => _tryMove(
        current,
        session,
        move,
        byDrag: true,
      ),
      SelectSlot() || IgnoreTouch() => current,
    };
  }

  /// [move] through core: applied, or rejected with core's reason. Either
  /// way the selection clears (D22).
  GameplayState _tryMove(
    GameplayState current,
    GameSession session,
    Move move, {
    required bool byDrag,
  }) {
    final cleared = current.copyWith(selectedSlotId: null);
    switch (session.move(move.from, move.to)) {
      case MoveRejected(:final reason):
        return _withEffect(
          cleared,
          MoveRejectedEffect(
            source: move.from,
            target: move.to,
            reason: reason,
            byDrag: byDrag,
          ),
        );
      case final MoveApplied applied:
        final next = _afterBoardChange(
          cleared,
          session,
          MoveAppliedEffect(result: applied, byDrag: byDrag),
        );
        return switch (next.status) {
          GameplayStatus.won => _win(next, session),
          GameplayStatus.outOfMoves => _outOfMoves(next),
          GameplayStatus.playing || GameplayStatus.allLevelsDone => next,
        };
    }
  }

  // --- Boosters (spec §2.4, §3.6, §8) -----------------------------------

  GameplayState _undo(GameplayState current, GameSession session) {
    if (!_acceptsBoosters(current) || !current.canUndo) return current;
    final result = session.undo();
    if (result == null) return current;
    // A drag held by another finger ends with the reset: its late drop
    // must not move a doll the reset put back (review CORRECTNESS-2).
    _dragging = null;
    _logBoosterUse('undo');
    return _afterBoardChange(
      current.copyWith(selectedSlotId: null, hint: null),
      session,
      BoardResetEffect(
        snapshot: session.state,
        reason: BoardResetReason.undo,
        undo: result,
      ),
    );
  }

  GameplayState _restart(GameplayState current, GameSession session) {
    if (!_acceptsBoosters(current)) return current;
    session.restart();
    // As with undo: the reset ends any drag in progress.
    _dragging = null;
    _attemptNumber++;
    unawaited(
      _analytics.logEvent(
        'level_restart',
        parameters: {'level': current.levelNumber},
      ),
    );
    _logLevelStart(current.entry);
    // The initial board is solvable (spec §5.3 rule 8): no soft-stuck
    // check.
    return _afterBoardChange(
      current.copyWith(selectedSlotId: null, hint: null),
      session,
      BoardResetEffect(
        snapshot: session.state,
        reason: BoardResetReason.restart,
      ),
      checkSoftStuck: false,
    );
  }

  GameplayState _addExtraSlot(GameplayState current, GameSession session) {
    if (!_acceptsBoosters(current) || !current.canAddSlot) return current;
    if (!_freeExtraSlots && !_save.useBooster(BoosterKind.extraSlot)) {
      return _withBoosters(current, session);
    }
    final added = session.addExtraSlot();
    // canAddSlot already checked core's limit of 2 per level.
    if (added == null) return current;
    _slotsUsed++;
    _logBoosterUse('slot');
    // The selection and the hint stay: both are still legal, and the
    // lifted nest re-pitches with its row (m2-lottie-design §9.5).
    return _afterBoardChange(current, session, ExtraSlotAddedEffect(added));
  }

  GameplayState _hintPressed(GameplayState current) {
    if (current.status != GameplayStatus.playing || current.paused) {
      return current;
    }
    // Already showing, already asked, or already proven stuck (the banner
    // says so, and a hint would give no move).
    if (current.hint != null ||
        _pendingHintSeq == current.moveSeq ||
        current.softStuck ||
        !current.canHint) {
      return current;
    }
    // The hint's search (30k nodes) also answers the soft-stuck check
    // (20k), so the pending check is dropped instead of superseding it.
    _softStuckTimer?.cancel();
    final seq = current.moveSeq;
    _pendingHintSeq = seq;
    unawaited(_askHint(current.board, seq));
    return current;
  }

  GameplayState _hintArrived(
    GameplayState current,
    GameSession session,
    HintResult? result,
    int moveSeq,
  ) {
    if (moveSeq != current.moveSeq || _pendingHintSeq != moveSeq) {
      return current; // stale: the board changed since it was asked
    }
    _pendingHintSeq = null;
    if (current.status != GameplayStatus.playing) return current;
    if (result != null && result.move == null) {
      // D22: a proven dead end gets no move and costs nothing.
      return result.verdict == SolveVerdict.unsolvable
          ? _markSoftStuck(current)
          : current;
    }
    // Superseded or failed: core's fallback hint (spec §6.3, design A3).
    final move = result?.move ?? Solver.fallbackHint(session.state);
    if (move == null) return current;
    // With unlimited boosters (dev flavor) the save takes nothing.
    if (!_save.useBooster(BoosterKind.hint)) {
      return _withBoosters(current, session);
    }
    _hintsUsed++;
    _logBoosterUse('hint');
    return _withEffect(
      _withBoosters(current.copyWith(hint: move), session),
      HintShownEffect(move),
    );
  }

  // --- Soft stuck (spec §2.3) --------------------------------------------

  GameplayState _softStuckDue(GameplayState current, int moveSeq) {
    if (moveSeq != current.moveSeq ||
        current.status != GameplayStatus.playing ||
        current.softStuck ||
        _pendingHintSeq == moveSeq) {
      return current;
    }
    unawaited(_askSoftStuck(current.board, moveSeq));
    return current;
  }

  GameplayState _softStuckArrived(
    GameplayState current,
    SolveVerdict? verdict,
    int moveSeq,
  ) {
    if (moveSeq != current.moveSeq ||
        current.status != GameplayStatus.playing ||
        verdict != SolveVerdict.unsolvable) {
      return current;
    }
    return _markSoftStuck(current);
  }

  GameplayState _markSoftStuck(GameplayState current) {
    if (current.softStuck) return current;
    unawaited(
      _analytics.logEvent(
        'level_soft_stuck',
        parameters: {'level': current.levelNumber},
      ),
    );
    // A state change only: the banner and the Undo glow are HUD widgets,
    // so no board effect (and no new effectSeq).
    return current.copyWith(softStuck: true);
  }

  // --- Won and out of moves (spec §2.3, §7.1, §7.3) ----------------------

  GameplayState _win(GameplayState next, GameSession session) {
    _cancelSolverWork();
    _levelClock.stop();
    final entry = next.entry;
    final reward = winRewardFor(entry.tier, _remoteConfig);
    _save.recordWin(levelOrder: entry.order, rewardCoins: reward);
    unawaited(
      _analytics.logEvent(
        'level_win',
        parameters: {
          'level': entry.order,
          'tier': entry.tier.id,
          'moves': session.state.moveCount,
          'seconds': _levelClock.elapsed.inSeconds,
          'undos': session.undosUsed,
          'hints': _hintsUsed,
          'slots': _slotsUsed,
        },
      ),
    );
    return _withBoosters(next.copyWith(winReward: reward), session);
  }

  GameplayState _outOfMoves(GameplayState next) {
    _cancelSolverWork();
    unawaited(
      _analytics.logEvent(
        'level_out_of_moves',
        parameters: {'level': next.levelNumber},
      ),
    );
    return next;
  }

  // --- Helpers -------------------------------------------------------------

  /// The state after core changed the board: a new `moveSeq` (so solver
  /// results in flight are stale), the status from core, the soft-stuck
  /// banner cleared, and [effect]. A board still in play gets a soft-stuck
  /// check [softStuckDelay] later.
  GameplayState _afterBoardChange(
    GameplayState current,
    GameSession session,
    BoardEffect effect, {
    bool checkSoftStuck = true,
  }) {
    _pendingHintSeq = null;
    final status = session.isWon
        ? GameplayStatus.won
        : session.isOutOfMoves
        ? GameplayStatus.outOfMoves
        : GameplayStatus.playing;
    final next = _withEffect(
      _withBoosters(
        current.copyWith(
          board: session.state,
          status: status,
          softStuck: false,
          moveSeq: current.moveSeq + 1,
        ),
        session,
      ),
      effect,
    );
    _softStuckTimer?.cancel();
    if (checkSoftStuck && status == GameplayStatus.playing) {
      _scheduleSoftStuckCheck(next.moveSeq);
    }
    return next;
  }

  /// [current] with the booster fields recomputed from the session and the
  /// save's wallet.
  GameplayState _withBoosters(GameplayState current, GameSession session) {
    final unlimited = _save.unlimitedBoosters;
    final freeUndosLeft = math.max(0, _freeUndosPerLevel - session.undosUsed);
    final hints = _save.boosterCount(BoosterKind.hint);
    final extraSlots = _save.boosterCount(BoosterKind.extraSlot);
    return current.copyWith(
      board: session.state,
      coins: _save.coins,
      freeUndosLeft: freeUndosLeft,
      hintsLeft: hints,
      extraSlotsLeft: extraSlots,
      unlimitedBoosters: unlimited,
      // TODO(M3): the coin path once the free undos and the inventory run
      // out (frames 3.2 and 3.3, spec §7.3 prices); M6 adds the rewarded
      // ad (spec §8).
      canUndo: session.canUndo && (unlimited || freeUndosLeft > 0),
      canHint: unlimited || hints > 0,
      canAddSlot:
          session.canAddExtraSlot &&
          (unlimited || _freeExtraSlots || extraSlots > 0),
    );
  }

  /// [current] carrying [effect] with the next `effectSeq`.
  GameplayState _withEffect(GameplayState current, BoardEffect effect) =>
      current.copyWith(effect: effect, effectSeq: current.effectSeq + 1);

  /// Any tap or drag clears the hint (frame 3.1): emits the cleared state
  /// with [HintClearedEffect] first, so the tap's own effect follows it.
  GameplayState _clearHint(
    Emitter<AsyncValue<GameplayState>> emit,
    GameplayState current,
  ) {
    if (current.hint == null) return current;
    final cleared = _withEffect(
      current.copyWith(hint: null),
      const HintClearedEffect(),
    );
    if (!isClosed && !emit.isDone) emit(AsyncValue.data(data: cleared));
    return cleared;
  }

  /// Undo, Restart and +1 Slot work while playing and on the Out-of-Moves
  /// sheet (frame 3.5), never while paused or after the win.
  bool _acceptsBoosters(GameplayState current) => current.acceptsInput;

  void _scheduleSoftStuckCheck(int moveSeq) {
    _softStuckTimer = Timer(_softStuckDebounce, () {
      if (!isClosed) add(SoftStuckCheckDue(moveSeq));
    });
  }

  Future<void> _askHint(GameState board, int moveSeq) async {
    HintResult? result;
    try {
      result = await _solver.hint(board);
    } on Object {
      // The service never throws (its contract); a broken one still only
      // costs the search, and the fallback hint answers (rule 3).
      result = null;
    }
    if (!isClosed) add(HintResultArrived(result: result, moveSeq: moveSeq));
  }

  Future<void> _askSoftStuck(GameState board, int moveSeq) async {
    SolveVerdict? verdict;
    try {
      verdict = await _solver.softStuck(board);
    } on Object {
      verdict = null;
    }
    if (!isClosed) {
      add(SoftStuckResultArrived(verdict: verdict, moveSeq: moveSeq));
    }
  }

  void _cancelSolverWork() {
    _softStuckTimer?.cancel();
    _softStuckTimer = null;
    _pendingHintSeq = null;
    _solver.cancel();
  }

  void _logLevelStart(LevelBundleEntry entry) => unawaited(
    _analytics.logEvent(
      'level_start',
      parameters: {
        'level': entry.order,
        'tier': entry.tier.id,
        'attempt': _attemptNumber,
      },
    ),
  );

  // TODO(M3): `coins` once boosters can be bought (frames 3.2, 3.3), and
  // `ad` in M6 (spec §14.4). M2 has no paid path, so every use is `free`.
  void _logBoosterUse(String type) => unawaited(
    _analytics.logEvent(
      'booster_use',
      parameters: {'type': type, 'source': 'free'},
    ),
  );

  @override
  Future<void> close() {
    _cancelSolverWork();
    return super.close();
  }
}
