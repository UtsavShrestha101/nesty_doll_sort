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
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/chest/milestone_chest.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/records/badge_rules.dart';
import 'package:nesty_game/core/services/records/record_rules.dart';
import 'package:nesty_game/core/services/records/star_rules.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/solver/solver_service.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/tap_policy.dart';
import 'package:nesty_game/features/gameplay/bloc/tutorial_script.dart';

part 'gameplay_bloc.freezed.dart';
part 'gameplay_event.dart';
part 'gameplay_state.dart';

/// Encodes the session for the in-progress save (m3-design §4): the real
/// signature is `GameSessionCodec.encode`.
typedef SessionEncoder = Map<String, Object?> Function(GameSession session);

/// Decodes the session for a restore (m3-design §4): the real signature is
/// `GameSessionCodec.decode`.
typedef SessionDecoder =
    GameSessionDecodeResult Function(Object? json, Level level);

/// Owns the level's nesty_core `GameSession` and turns intents into core
/// calls, state and [BoardEffect]s (spec §2.2–§2.4, §8, §13.1;
/// docs/plans/m2-lottie-design.md §11; docs/plans/m3-design.md §6.4, §7,
/// §10.4). Events are handled strictly in order (`BaseAsyncBloc`), so a tap
/// can never overtake the drop before it.
///
/// It never re-checks legality, detects completion or edits the board
/// (CLAUDE.md rule 2): the tap policy of frame 2.6 (D22, [TapPolicy]) only
/// decides *which* core call a touch becomes, and won / out of moves come
/// from core. Solver futures are never awaited inside [handleEvent]; their
/// results come back as [HintResultArrived] / [SoftStuckResultArrived]
/// tagged with the `moveSeq` they were asked for, and stale ones are
/// dropped.
///
/// Boosters (spec §8, m3-design §7.3): undos are free
/// [SaveService.freeUndosPerLevel] times per level, then cost
/// `price_undo` coins; hints and extra slots come from the save's wallet,
/// then cost `price_hint`/`price_slot`. The dev flavor's
/// [SaveService.unlimitedBoosters] never runs out or charges, and debug
/// builds add extra slots for free (spec §18 M2), still at most 2 per level
/// (core).
///
/// [TutorialScript] gates input to L0001/L0002's scripted move (m3-design
/// §10.4); [IntroMechanic] cards gate it to nothing until dismissed.
///
/// M7 (docs/plans/m7-design.md §6–§13): [DatabaseService] is read for
/// relaxed mode, live ([RelaxedModeChanged]); a replay pays and saves
/// nothing; a win fills the win card's moves, best, chest countdown, chest,
/// new badges and first-win flag from `SaveService.recordLevelWin`'s
/// outcome.
///
/// vs Computer (m7-design P2.6): a race request plays the player's board
/// here, beside the page's `RaceCubit`, which owns the rival, the clock
/// and the result. Input waits for [RaceGateChanged] (open while the race
/// runs). The race-bloc lane adds the rest of race mode: undo free and
/// unlimited, Hint and +1 Slot off, no level record, no level events.
///
/// The tie rule (spec-prop §7.7 "on the same frame the player wins")
/// relies on every in-play handler applying its move within the input's
/// own microtasks, before the next frame's tick: `_inPlay`'s bodies must
/// stay synchronous (no `await` before `session.move`).
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
    this._analytics,
    this._resolver,
    this._daily,
    this._clock,
    this._settings, {
    @ignoreParam bool freeExtraSlots = kDebugMode,
    @ignoreParam Duration softStuckDebounce = softStuckDelay,
    @ignoreParam SessionEncoder encodeSession = GameSessionCodec.encode,
    @ignoreParam SessionDecoder decodeSession = GameSessionCodec.decode,
  }) : _freeExtraSlots = freeExtraSlots,
       _softStuckDebounce = softStuckDebounce,
       _encodeSession = encodeSession,
       _decodeSession = decodeSession {
    _relaxedChanges = _settings.relaxedModeChanges.listen((relaxed) {
      if (!isClosed) add(RelaxedModeChanged(relaxed: relaxed));
    });
  }

  /// The soft-stuck check runs this long after the last board change, so a
  /// burst of moves asks the solver once (m2-lottie-design §11).
  static const Duration softStuckDelay = Duration(milliseconds: 300);

  final LevelRepository _levels;
  final SolverService _solver;
  final RemoteConfigService _remoteConfig;
  final SaveService _save;
  final AnalyticsService _analytics;
  final LevelResolver _resolver;
  final DailyService _daily;
  final AppClock _clock;

  /// The settings store: relaxed mode (m7-design §10).
  final DatabaseService _settings;
  late final StreamSubscription<bool> _relaxedChanges;

  /// +1 Slot uses no booster (spec §18 M2 "extra slot (free in debug)").
  final bool _freeExtraSlots;
  final Duration _softStuckDebounce;

  /// Reads/writes the in-progress save's session (m3-design §4): the real
  /// `GameSessionCodec.encode`/`.decode` by default, so a resume is exactly
  /// what the codec's own round-trip tests cover. A test may still swap in
  /// a stub for a scenario the real codec can't easily be asked to fail.
  final SessionEncoder _encodeSession;
  final SessionDecoder _decodeSession;

  GameSession? _session;

  /// Free undos of the level in play, read once at its start (spec §7.3).
  int _freeUndosPerLevel = 0;

  /// The slot a drag is holding, from [SlotDragStarted] to
  /// [SlotDragDropped].
  String? _dragging;

  /// The `moveSeq` of the hint request in flight, if any. Its result is
  /// dropped when the board has changed since.
  int? _pendingHintSeq;

  /// Whether the hint in flight (if any) charges the inventory/free uses
  /// or coins (m3-design §7.3), read back by [_hintArrived].
  BoosterSource? _pendingHintSource;

  Timer? _softStuckTimer;

  // Per-level stats for `level_win` (spec §14.4). A restart keeps them,
  // like the undo count (per level, D22).
  final Stopwatch _levelClock = Stopwatch();
  int _attemptNumber = 0;
  int _hintsUsed = 0;
  int _slotsUsed = 0;

  /// A hint was shown since the last Restart (Q116; m7-design P3.6): an
  /// assisted win earns at most `StarRating.assistedMaxStars`. Set in
  /// [_hintArrived] when it shows a charged hint move; a proven dead end
  /// (no move, nothing charged) doesn't count. Cleared by [_restart] and by
  /// [_begin] for a fresh session; a restored session takes the save's own
  /// `InProgressLevel.hinted`, so a kill right after a hint still caps the
  /// win. An extra slot on the board is read from core by
  /// `StarRating.starsForWin` itself, so no flag is kept for it here.
  bool _hintSinceRestart = false;

  /// The session of the level in play, for tests.
  @visibleForTesting
  GameSession? get session => _session;

  @override
  Future<void> handleEvent(
    GameplayEvent event,
    Emitter<AsyncValue<GameplayState>> emit,
  ) => switch (event) {
    GameplayStarted(:final request) => _dispatchStart(request, emit),
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
    NextLevelPressed() => _handleNextLevel(emit),
    BoosterPurchaseConfirmed(:final type) => _inPlay(
      emit,
      (current, session) => _confirmPurchase(current, session, type),
    ),
    BoosterPurchaseDismissed() => _inPlay(
      emit,
      (current, _) =>
          current.offer == null ? current : current.copyWith(offer: null),
    ),
    IntroDismissed() => _inPlay(emit, (current, _) => _dismissIntro(current)),
    RelaxedModeChanged(:final relaxed) => _inPlay(
      emit,
      (current, session) => _setRelaxed(current, session, relaxed),
    ),
    RaceGateChanged(:final open) => _inPlay(
      emit,
      (current, _) => current.isRace && current.raceLive != open
          ? current.copyWith(raceLive: open)
          : current,
    ),
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

  // --- Level lifecycle (m3-design §6.4) -----------------------------------

  /// [GameplayStarted] and "Play Bonus Level N" from All Levels Done: a
  /// generated request (bonus, daily) shows loading first (m3-design §6.4
  /// item 1); a bundled one resolves synchronously enough that it never
  /// flickers.
  Future<void> _dispatchStart(
    PlayRequest request,
    Emitter<AsyncValue<GameplayState>> emit,
  ) async {
    if (request.isGenerated && !isClosed && !emit.isDone) {
      emit(AsyncValue.loading(data: state.data));
    }
    await runGuarded(emit, () => _start(request));
  }

  Future<GameplayState> _start(PlayRequest request) async {
    final play = await _resolver.resolve(request);
    if (play == null) {
      // The guard never opens a campaign level past the last one, and a
      // generated level that can't be made after its retries is missing
      // content: the page offers a retry.
      throw AppException(
        AppExceptionKind.content,
        message: 'Nothing to play for $request',
      );
    }
    return _begin(play, state.data);
  }

  /// The M2 widgets' [GameplayState.entry] for [play]: its bundle entry, or
  /// a stand-in for a generated level (m3-design §6.4). Its `order` is
  /// also the analytics `level` (D77).
  LevelBundleEntry _entryOf(PlayEntry play) =>
      play.bundleEntry ??
      LevelBundleEntry(
        order: switch (play.request) {
          CampaignPlay(:final order) || ReplayPlay(:final order) => order,
          BonusPlay(:final number) => _levels.levelCount + number,
          DailyPlay(:final yyyymmdd) ||
          PastDailyPlay(:final yyyymmdd) => yyyymmdd,
          // A race isn't a level: its raceNo only fills the M2 widgets'
          // order (m7-design P2.6), and it logs no level events.
          RacePlay(:final raceNo) => raceNo,
        },
        chapterId: play.chapterId ?? play.themeId,
        tier: play.tier,
        version: play.levelVersion,
        rewardCoins: play.rewardCoins,
        level: play.level,
      );

  /// The saved board of [play]'s kind, only when it matches (m3-design
  /// §3.4): same request, level id and version, and the codec accepts it.
  /// Anything else is the caller's cue to clear that slot and start fresh.
  /// [hinted] is the save's own `InProgressLevel.hinted` (Q116; m7-design
  /// P3.6), so a hint survives a kill and a restore.
  ({GameSession session, bool hinted})? _restoreSession(PlayEntry play) {
    final saved = _save.inProgressFor(play.kind);
    if (saved == null ||
        saved.request != play.request ||
        saved.levelId != play.level.id ||
        saved.levelVersion != play.levelVersion) {
      return null;
    }
    final session = _decodeSession(saved.session, play.level).session;
    if (session == null) return null;
    return (session: session, hinted: saved.hinted);
  }

  /// Loads [play] into a new session, restored when it matches the save.
  /// `effectSeq` and `moveSeq` keep counting from [previous], so the page's
  /// listener fires and no result asked for the previous level can pass as
  /// current.
  ///
  /// The status is core's, as after any board change (review
  /// CORRECTNESS-1): a board saved out of moves (the sheet was up when the
  /// app was left) comes back out of moves, so the page opens its sheet
  /// again; a won one (only a save from before the winning move stopped
  /// being saved) records its win now, since `recordLevelWin` clears the
  /// in-progress board in the same write and so never ran for it; and a
  /// restored board still in play gets the soft-stuck check its last move
  /// scheduled (a fresh one is solvable, spec §5.3 rule 8).
  GameplayState _begin(PlayEntry play, GameplayState? previous) {
    _cancelSolverWork();
    final entry = _entryOf(play);
    final restored = _restoreSession(play);
    final session = restored?.session ?? GameSession(entry.level);
    if (restored == null) _save.clearInProgress(play.kind);
    _session = session;
    _dragging = null;
    _pendingHintSource = null;
    _freeUndosPerLevel = math.max(0, _save.freeUndosPerLevel);
    _attemptNumber = 1;
    _hintsUsed = 0;
    _slotsUsed = 0;
    // Q116 (m7-design P3.6): a fresh session starts unassisted; a restored
    // one takes the save's own flag, so a hint survives a kill.
    _hintSinceRestart = restored?.hinted ?? false;
    _levelClock
      ..reset()
      ..start();
    // vs Computer (m7-design P2.6): a race logs none of spec §14.4's level
    // events (it isn't a level).
    if (!play.request.isRace) _logLevelStart(entry);
    if (play.request case BonusPlay(:final number)) {
      unawaited(
        _analytics.logEvent('bonus_level_start', parameters: {'n': number}),
      );
    }
    final status = _statusOf(session);
    var next = GameplayState(
      play: play,
      entry: entry,
      board: session.state,
      status: status,
      paused: previous?.paused ?? false,
      relaxed: _settings.relaxedMode,
      moveSeq: previous == null ? 0 : previous.moveSeq + 1,
      effectSeq: (previous?.effectSeq ?? 0) + 1,
      effect: BoardResetEffect(
        snapshot: session.state,
        reason: BoardResetReason.start,
      ),
      restored: restored != null,
    );
    next = _withBoosters(next, session);
    next = _withTutorial(next);
    switch (status) {
      case GameplayStatus.won:
        return _win(next, session);
      case GameplayStatus.playing when restored != null:
        _scheduleSoftStuckCheck(next.moveSeq);
      case GameplayStatus.playing ||
          GameplayStatus.outOfMoves ||
          GameplayStatus.allLevelsDone:
        break;
    }
    // The tutorial cue and the first unseen intro card both show at start
    // and restore (m3-design §10.4); the intro card locks input over it. A
    // replay shows neither, whatever `seenIntros` says (m7-design §6), and
    // neither does a race (P2.6: "no tutorial cue, no intro card").
    return next.copyWith(
      intro: play.request.isReplay || play.request.isRace
          ? null
          : _firstUnseenIntro(play.level),
    );
  }

  Future<void> _handleNextLevel(Emitter<AsyncValue<GameplayState>> emit) async {
    final current = state.data;
    if (current == null || current.status != GameplayStatus.won) return;
    final request = current.play.request;
    // The daily has no "next": the page pops back to Daily (frame 5.4).
    if (request is DailyPlay || request is PastDailyPlay) return;
    final nextRequest = current.nextRequest;
    if (request is CampaignPlay && nextRequest is BonusPlay) {
      await runGuarded(
        emit,
        () async => current.copyWith(status: GameplayStatus.allLevelsDone),
      );
      return;
    }
    if (nextRequest == null) return;
    await _dispatchStart(nextRequest, emit);
  }

  /// [InProgressLevel] of [play] and [session] (m3-design §3.4): after
  /// every applied move, undo, restart, +1 Slot, and a charged hint (Q116;
  /// m7-design P3.6), so `hinted` survives a kill.
  void _persistProgress(PlayEntry play, GameSession session) {
    final request = play.request;
    _save.saveInProgress(
      InProgressLevel(
        request: request,
        levelId: play.level.id,
        levelVersion: play.levelVersion,
        session: _encodeSession(session),
        level: request.isGenerated ? LevelCodec.encode(play.level) : null,
        tier: request.isGenerated ? play.tier : null,
        hinted: _hintSinceRestart,
      ),
    );
  }

  // --- Taps and drags (frame 2.6, D22; gated by the tutorial, §10.4) -----

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
    final cue = base.tutorial;
    if (cue != null) {
      final wanted = cue.kind == TutorialCueKind.tapSource ? cue.from : cue.to;
      if (cue.kind == TutorialCueKind.drag || slotId != wanted) return base;
    }
    final selected = base.selectedSlotId;
    switch (TapPolicy.tap(session.state, selected: selected, tapped: slotId)) {
      case SelectSlot(:final slotId):
        final pickedStep1 = cue?.step == 1;
        final next = _withTutorial(
          _withEffect(
            base.copyWith(selectedSlotId: slotId),
            SelectionChangedEffect(selected: slotId),
          ),
        );
        // spec §10.4: "1 on the pick" — steps 2 and 3 log on their move.
        if (pickedStep1) _logTutorialStep(1);
        return next;
      case CancelSelection(:final slotId):
        return _withTutorial(
          _withEffect(
            base.copyWith(selectedSlotId: null),
            SelectionChangedEffect(previous: slotId),
          ),
        );
      case AttemptMove(:final move):
        return _tryMove(base, session, move, byDrag: false);
      case NudgeSlot(:final slotId, :final kind):
        return _withEffect(base, SlotNudgeEffect(slotId, kind));
      case IgnoreTouch():
        return base;
    }
  }

  GameplayState _dragStart(
    Emitter<AsyncValue<GameplayState>> emit,
    GameplayState current,
    GameSession session,
    String slotId,
  ) {
    if (!current.acceptsInput) return current;
    final base = _clearHint(emit, current);
    final cue = base.tutorial;
    if (cue != null &&
        (cue.kind != TutorialCueKind.drag || slotId != cue.from)) {
      _dragging = null;
      return base;
    }
    switch (TapPolicy.dragStart(session.state, slotId)) {
      case SelectSlot(:final slotId):
        _dragging = slotId;
        final previous = base.selectedSlotId;
        return _withTutorial(
          _withEffect(
            base.copyWith(selectedSlotId: slotId),
            SelectionChangedEffect(
              // Picking up the nest a tap already lifted settles nothing.
              previous: previous == slotId ? null : previous,
              selected: slotId,
              byDrag: true,
            ),
          ),
        );
      case CancelSelection() || AttemptMove() || NudgeSlot() || IgnoreTouch():
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
    // A tutorial drag dropped anywhere but the scripted target cancels
    // back to the step's first cue (m3-design §10.4), rather than
    // attempting whatever move core would otherwise see there.
    final cue = current.tutorial;
    final effectiveSlotId =
        cue != null && cue.kind == TutorialCueKind.drag && slotId != cue.to
        ? null
        : slotId;
    switch (TapPolicy.drop(dragged: dragged, dropped: effectiveSlotId)) {
      case CancelSelection(:final slotId):
        return _withTutorial(
          _withEffect(
            current.copyWith(selectedSlotId: null),
            SelectionChangedEffect(previous: slotId, byDrag: true),
          ),
        );
      case AttemptMove(:final move):
        return _tryMove(current, session, move, byDrag: true);
      case SelectSlot() || NudgeSlot() || IgnoreTouch():
        return current;
    }
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
    // The cue active when the move was submitted, if any: gating already
    // guarantees this is the scripted move (m3-design §10.4).
    final tutorialStep = current.tutorial?.step;
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
        if (tutorialStep == 4) _save.markTutorialDone();
        final next = _afterBoardChange(
          cleared,
          session,
          MoveAppliedEffect(result: applied, byDrag: byDrag),
          completedTutorialStep: tutorialStep,
        );
        return switch (next.status) {
          GameplayStatus.won => _win(next, session),
          GameplayStatus.outOfMoves => _outOfMoves(next),
          GameplayStatus.playing || GameplayStatus.allLevelsDone => next,
        };
    }
  }

  // --- Boosters (spec §2.4, §3.6, §8; m3-design §7.3) ---------------------

  GameplayState _undo(GameplayState current, GameSession session) {
    if (!_acceptsBoosters(current) || !current.canUndo) return current;
    // Relaxed mode (E6, m7-design §10) and vs Computer (P2.6, "Undo and
    // restart are free and unlimited"): undo is free and unlimited, so the
    // coin offer never shows. `freeUndosLeft` and `session.undosUsed` still
    // count underneath (nothing shows them), and the use still logs
    // `booster_use` (m7-design P2.6), as in relaxed mode.
    if (current.isRace ||
        current.relaxed ||
        current.unlimitedBoosters ||
        current.freeUndosLeft > 0) {
      return _applyUndo(current, session, source: BoosterSource.free);
    }
    // A past day sells nothing (§7.5c): no coin offer, the row just waits.
    if (current.isPastDaily) return current;
    return current.copyWith(
      offer: BoosterOffer(type: BoosterType.undo, price: current.undoPrice),
    );
  }

  /// [RelaxedModeChanged] (m7-design §10, D104): read live, so a toggle made
  /// from Pause → Settings applies to the level in play. Turning it on also
  /// closes a pending undo offer (opened before the toggle): relaxed mode
  /// never shows one.
  GameplayState _setRelaxed(
    GameplayState current,
    GameSession session,
    bool relaxed,
  ) {
    var next = current.copyWith(relaxed: relaxed);
    if (relaxed && next.offer?.type == BoosterType.undo) {
      next = next.copyWith(offer: null);
    }
    return _withBoosters(next, session);
  }

  GameplayState _applyUndo(
    GameplayState current,
    GameSession session, {
    required BoosterSource source,
  }) {
    final result = session.undo();
    if (result == null) return current;
    // A drag held by another finger ends with the reset: its late drop
    // must not move a doll the reset put back (review CORRECTNESS-2).
    _dragging = null;
    _logBoosterUse(BoosterType.undo, source);
    return _afterBoardChange(
      current.copyWith(selectedSlotId: null, hint: null, offer: null),
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
    _pendingHintSeq = null;
    _pendingHintSource = null;
    _attemptNumber++;
    // Q116 (m7-design P3.6): Restart clears the assisted flag.
    _hintSinceRestart = false;
    // vs Computer (m7-design P2.6): no level events for a race.
    if (!current.isRace) {
      unawaited(
        _analytics.logEvent(
          'level_restart',
          parameters: {'level': current.levelNumber},
        ),
      );
      _logLevelStart(current.entry);
    }
    // The initial board is solvable (spec §5.3 rule 8): no soft-stuck
    // check.
    return _afterBoardChange(
      current.copyWith(selectedSlotId: null, hint: null, offer: null),
      session,
      BoardResetEffect(
        snapshot: session.state,
        reason: BoardResetReason.restart,
      ),
      checkSoftStuck: false,
    );
  }

  GameplayState _addExtraSlot(GameplayState current, GameSession session) {
    // vs Computer (m7-design P2.6): +1 Slot is off. No offer, no spend.
    if (current.isRace) return current;
    if (!_acceptsBoosters(current) || !current.canAddSlot) return current;
    if (_freeExtraSlots) {
      return _placeExtraSlot(current, session, source: BoosterSource.free);
    }
    if (current.unlimitedBoosters || current.extraSlotsLeft > 0) {
      if (!_save.useBooster(BoosterKind.extraSlot)) {
        return _withBoosters(current, session);
      }
      return _placeExtraSlot(current, session, source: BoosterSource.free);
    }
    if (current.isPastDaily) return current;
    return current.copyWith(
      offer: BoosterOffer(type: BoosterType.slot, price: current.slotPrice),
    );
  }

  GameplayState _placeExtraSlot(
    GameplayState current,
    GameSession session, {
    required BoosterSource source,
  }) {
    final added = session.addExtraSlot();
    // canAddSlot already checked core's limit of 2 per level.
    if (added == null) return current;
    _slotsUsed++;
    _logBoosterUse(BoosterType.slot, source);
    // The selection and the hint stay: both are still legal, and the
    // lifted nest re-pitches with its row (m2-lottie-design §9.5).
    return _afterBoardChange(
      current.copyWith(offer: null),
      session,
      ExtraSlotAddedEffect(added),
    );
  }

  GameplayState _hintPressed(GameplayState current) {
    // vs Computer (m7-design P2.6): Hint is off. No offer, no spend.
    if (current.isRace) return current;
    if (current.status != GameplayStatus.playing ||
        current.paused ||
        current.offer != null ||
        current.intro != null ||
        current.tutorial != null) {
      return current;
    }
    // Already showing, already asked, or already proven stuck (the banner
    // says so, and a hint would give no move).
    if (current.hint != null ||
        _pendingHintSeq == current.moveSeq ||
        current.softStuck) {
      return current;
    }
    if (current.unlimitedBoosters || current.hintsLeft > 0) {
      return _requestHint(current, source: BoosterSource.free);
    }
    if (current.isPastDaily) return current;
    return current.copyWith(
      offer: BoosterOffer(type: BoosterType.hint, price: current.hintPrice),
    );
  }

  /// Asks the solver for [current.board], marking the result to be charged
  /// from [source] when it arrives (m3-design §7.3): the hint's search
  /// (30k nodes) also answers the soft-stuck check (20k), so the pending
  /// check is dropped instead of superseding it.
  GameplayState _requestHint(
    GameplayState current, {
    required BoosterSource source,
  }) {
    _softStuckTimer?.cancel();
    final seq = current.moveSeq;
    _pendingHintSeq = seq;
    _pendingHintSource = source;
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
    final source = _pendingHintSource ?? BoosterSource.free;
    _pendingHintSeq = null;
    _pendingHintSource = null;
    if (current.status != GameplayStatus.playing) return current;
    if (result != null && result.move == null) {
      // D22: a proven dead end gets no move and costs nothing, whether it
      // was free or a coin-marked ask.
      return result.verdict == SolveVerdict.unsolvable
          ? _markSoftStuck(current)
          : current;
    }
    // Superseded or failed: core's fallback hint (spec §6.3, design A3).
    final move = result?.move ?? Solver.fallbackHint(session.state);
    if (move == null) return current;
    final charged = source == BoosterSource.coins
        ? _save.spendCoins(current.hintPrice)
        : _save.useBooster(BoosterKind.hint);
    // With unlimited boosters (dev flavor) the save takes nothing; a coin
    // charge only fails if the balance dropped since it was confirmed.
    if (!charged) return _withBoosters(current, session);
    _hintsUsed++;
    // Q116 (m7-design P3.6): the win's stars cap at
    // `StarRating.assistedMaxStars`, even after a kill: persist it now,
    // since showing a hint doesn't otherwise change the board
    // (`_afterBoardChange` never runs for it). A replay's or a race's
    // board is never saved anyway (`SaveService.saveInProgress`).
    _hintSinceRestart = true;
    _persistProgress(current.play, session);
    _logBoosterUse(BoosterType.hint, source);
    return _withEffect(
      _withBoosters(current.copyWith(hint: move), session),
      HintShownEffect(move),
    );
  }

  /// The purchase popup's coin button (m3-design §7.3; the out-of-moves
  /// sheet's rows open the popup first). Only the offer that is up can be
  /// bought (review CORRECTNESS-7): a second confirm that arrives after the
  /// first closed it (a double-fired Buy, a repeated accessibility action),
  /// or one for another booster, does nothing. The coins are only spent
  /// once core can apply the booster, so a spend never goes unmatched.
  GameplayState _confirmPurchase(
    GameplayState current,
    GameSession session,
    BoosterType type,
  ) {
    // vs Computer (m7-design P2.6): no offer is ever up for Hint or +1
    // Slot, and undo never offers either (always free); belt and suspenders
    // against a stale confirm.
    // A past day (§7.5c): nothing is bought with coins (or, from M6, a
    // rewarded ad), so a stale confirm does nothing even if an offer is up.
    if (current.isRace ||
        current.isPastDaily ||
        current.offer?.type != type ||
        current.paused ||
        current.intro != null ||
        current.tutorial != null ||
        (current.status != GameplayStatus.playing &&
            current.status != GameplayStatus.outOfMoves)) {
      return current;
    }
    if (type == BoosterType.undo && current.relaxed) {
      // Belt and suspenders (E6): relaxed mode never charges for undo, so a
      // stale offer (relaxed turned on right as this arrived) just closes
      // instead of spending coins.
      return _withBoosters(current.copyWith(offer: null), session);
    }
    final price = switch (type) {
      BoosterType.undo => current.undoPrice,
      BoosterType.hint => current.hintPrice,
      BoosterType.slot => current.slotPrice,
    };
    // Not enough coins → nothing changes (the button is disabled).
    if (_save.coins < price) return current;
    final applies = switch (type) {
      BoosterType.undo => session.canUndo,
      BoosterType.slot => session.canAddExtraSlot,
      // Charged on arrival, and only for a move (`_hintArrived`).
      BoosterType.hint => true,
    };
    if (!applies) return _withBoosters(current.copyWith(offer: null), session);
    return switch (type) {
      BoosterType.undo =>
        _save.spendCoins(price)
            ? _applyUndo(
                current.copyWith(offer: null),
                session,
                source: BoosterSource.coins,
              )
            : current,
      BoosterType.slot =>
        _save.spendCoins(price)
            ? _placeExtraSlot(
                current.copyWith(offer: null),
                session,
                source: BoosterSource.coins,
              )
            : current,
      // The coins are spent when the move arrives, and a proven dead end
      // charges nothing (D22): see `_hintArrived`.
      BoosterType.hint => _requestHint(
        current.copyWith(offer: null),
        source: BoosterSource.coins,
      ),
    };
  }

  GameplayState _dismissIntro(GameplayState current) {
    final mechanic = current.intro;
    if (mechanic == null) return current;
    _save.markIntroSeen(mechanic);
    return current.copyWith(intro: _firstUnseenIntro(current.play.level));
  }

  /// The first mechanic of [level] not yet in the save's `seenIntros`
  /// (m3-design §10.4), or null.
  IntroMechanic? _firstUnseenIntro(Level level) {
    final seen = _save.document.seenIntros;
    for (final mechanic in IntroMechanic.presentIn(level)) {
      if (!seen.contains(mechanic.id)) return mechanic;
    }
    return null;
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
    // vs Computer (m7-design P2.6): the soft-stuck check and banner stay in
    // a race, but it logs no level event (a race isn't a level).
    if (!current.isRace) {
      unawaited(
        _analytics.logEvent(
          'level_soft_stuck',
          parameters: {'level': current.levelNumber},
        ),
      );
    }
    // A state change only: the banner and the Undo glow are HUD widgets,
    // so no board effect (and no new effectSeq).
    return current.copyWith(softStuck: true);
  }

  // --- Won and out of moves (spec §2.3, §7.1, §7.3; m3-design §7.1, §7.4,
  // §8.5, §9.3) -------------------------------------------------------------

  GameplayState _win(GameplayState next, GameSession session) {
    _cancelSolverWork();
    _levelClock.stop();
    if (next.isRace) {
      // vs Computer (m7-design P2.6): a race isn't a level. Only the board
      // status and the moves it took for the win card; no record, no
      // coins, chest, figurine, currentLevel, best moves, firstWin or
      // nextRequest, no prefetch, no analytics. `RaceCubit` records the win
      // exactly once through `SaveService.recordRaceWin` (P2.5).
      return next.copyWith(
        status: GameplayStatus.won,
        winMoves: next.board.moveCount,
      );
    }
    final play = next.play;
    final request = play.request;
    final level = play.level;
    final chapterId = play.chapterId;
    final completesChapter =
        play.completesChapter &&
        chapterId != null &&
        !_save.document.museum.contains(chapterId);
    final chapterReward = completesChapter
        ? _remoteConfig.value(RemoteConfigKeys.rewardChapter)
        : 0;
    // Read before recording (E9, m7-design §13): the player's very first
    // win ever, and only a campaign win sends Continue to Home.
    final firstWin = request is CampaignPlay && _save.document.stats.wins == 0;
    // A past day (§7.5c) never reaches the streak: no `progressAfterSolve`,
    // no coins, no daily event.
    final pastDay = request is PastDailyPlay;
    final pastDate = request is PastDailyPlay
        ? LocalDate.fromYyyymmdd(request.yyyymmdd)
        : null;
    final pastAgain =
        pastDate != null &&
        _save.document.dailyArchive.played.contains(pastDate);
    DailyProgress? dailyProgress;
    var dailyRelit = false;
    if (request is DailyPlay) {
      final dailyDate = LocalDate.fromYyyymmdd(request.yyyymmdd);
      dailyProgress = _daily.progressAfterSolve(dailyDate);
      dailyRelit = dailyProgress.relitOn(dailyDate);
    }
    final moves = session.state.moveCount;
    // Star rating (spec-prop §7.10; m7-design P3.6): bundled boards only
    // (`PlayEntry.par`); the daily, Bonus Endless and a race (already
    // returned above) compute none. `_hintSinceRestart` and the board's own
    // extra-slot count (read by `starsForWin` itself) cap an assisted win;
    // undo, Restart's move reset and relaxed mode reach the rule only
    // through `moveCount`, so they never lower stars on their own.
    final slack = StarRules.slackOf(_remoteConfig);
    final par = play.par;
    final stars = par == null
        ? null
        : StarRating.starsForWin(
            session.state,
            par: par,
            hintUsed: _hintSinceRestart,
            star3SlackPct: slack.star3,
            star2SlackPct: slack.star2,
          );
    // The helper note (Q145): the same rule, unassisted, would have given
    // more (3) than this assisted win earned.
    final starsCapped =
        stars != null &&
        par != null &&
        StarRating.starsFor(
              moves: moves,
              par: par,
              assisted: false,
              star3SlackPct: slack.star3,
              star2SlackPct: slack.star2,
            ) >
            stars;
    final now = _clock.now();
    final outcome = _save.recordLevelWin(
      LevelWinRecord(
        request: request,
        rewardCoins: pastDay ? 0 : play.rewardCoins,
        moves: moves,
        completedChapterId: completesChapter ? chapterId : null,
        chapterReward: chapterReward,
        date: _clock.today(),
        daily: dailyProgress,
        // Bundled boards only (campaign, replay): m7-design §11.
        bestKey: LevelBests.keyOf(play),
        // Null for a replay, a daily and a bonus level that isn't one of
        // the chest's own (`MilestoneChest.forWin`, m7-design §9).
        chest: MilestoneChest.forWin(request, _remoteConfig),
        families: RecordRules.familiesIn(level),
        dolls: RecordRules.dollsNestedIn(level),
        boardBadges: BadgeRules.forWonLevel(level),
        starsKey: stars == null ? null : StarRules.keyOf(play),
        stars: stars,
        minuteOfDay: now.hour * 60 + now.minute,
        starsCapped: starsCapped,
      ),
    );
    // The replay card's 3-star target (Q118): only below 3 stars, and only
    // when the moves were over it; never on a level's first win.
    final target = StarRules.targetFor(play, slack);
    final starTarget =
        request.isReplay &&
            stars != null &&
            stars < StarRating.maxStars &&
            target != null &&
            moves > target
        ? target
        : null;
    final nextRequest = _resolver.next(request);
    // The win overlay prefetches Bonus Endless's next level (m3-design
    // §7.4); Continue then resolves it at once.
    if (nextRequest is BonusPlay) _resolver.prefetch(nextRequest);
    unawaited(
      _analytics.logEvent(
        'level_win',
        parameters: {
          'level': next.entry.order,
          'tier': play.tier.id,
          'moves': moves,
          'seconds': _levelClock.elapsed.inSeconds,
          'undos': session.undosUsed,
          'hints': _hintsUsed,
          'slots': _slotsUsed,
        },
      ),
    );
    if (completesChapter) {
      unawaited(
        _analytics.logEvent(
          'chapter_complete',
          parameters: {'chapter': _chapterNumber(chapterId)},
        ),
      );
    }
    if (dailyProgress != null) {
      unawaited(
        _analytics.logEvent(
          'daily_complete',
          parameters: {'streak': dailyProgress.streak},
        ),
      );
    }
    if (pastDate != null) _logPastDailyComplete(pastDate, again: pastAgain);
    return _withBoosters(
      next.copyWith(
        winReward: pastDay ? 0 : play.rewardCoins,
        pastDailyAgain: pastAgain,
        completedChapterId: completesChapter ? chapterId : null,
        chapterReward: chapterReward,
        dailyStreak: dailyProgress?.streak,
        dailyRelit: dailyRelit,
        winMoves: moves,
        bestMoves: outcome.bestMoves,
        previousBest: outcome.previousBest,
        chestLevelsLeft: MilestoneChest.levelsToNext(request),
        chest: outcome.chestPaid,
        newBadges: outcome.newBadges,
        firstWin: firstWin,
        stars: stars,
        previousStars: outcome.previousStars,
        starTarget: starTarget,
        starTip: outcome.showStarTip,
        starsCapped: starsCapped,
        nextRequest: nextRequest,
      ),
      session,
    );
  }

  /// The number in `chapter_complete{chapter}` (spec §14.4): parsed from
  /// the `chNN` id convention rather than `CatalogRepository`, which the
  /// bloc doesn't otherwise need (m3-design §6.4 item 5).
  int _chapterNumber(String chapterId) =>
      int.tryParse(chapterId.replaceFirst('ch', '')) ?? 0;

  GameplayState _outOfMoves(GameplayState next) {
    _cancelSolverWork();
    // vs Computer (m7-design P2.6): no level events for a race; the sheet
    // still opens (Undo and Restart only, race-ui) and the soft-stuck
    // banner stays.
    if (!next.isRace) {
      unawaited(
        _analytics.logEvent(
          'level_out_of_moves',
          parameters: {'level': next.levelNumber},
        ),
      );
    }
    return next;
  }

  // --- Helpers -------------------------------------------------------------

  /// The state after core changed the board: a new `moveSeq` (so solver
  /// results in flight are stale), the status from core, the soft-stuck
  /// banner cleared, [effect], the tutorial cue recomputed (logging
  /// [completedTutorialStep] first, m3-design §10.4) and the board saved
  /// (m3-design §3.4). A board still in play gets a soft-stuck check
  /// [softStuckDelay] later.
  GameplayState _afterBoardChange(
    GameplayState current,
    GameSession session,
    BoardEffect effect, {
    bool checkSoftStuck = true,
    int? completedTutorialStep,
  }) {
    _pendingHintSeq = null;
    _pendingHintSource = null;
    final status = _statusOf(session);
    var next = _withEffect(
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
    next = _withTutorial(next, completedStep: completedTutorialStep);
    // A won board is never saved as in progress (review CORRECTNESS-1):
    // `_win` records the win, which clears the slot in the same write, so
    // a kill in between restores the board before the winning move rather
    // than a finished one. A replay is never saved either (m7-design §6),
    // and neither is a race (P2.6 "no restore, no `_persistProgress`"; the
    // save already ignores both, so this only skips the pointless encode).
    if (status != GameplayStatus.won &&
        !current.play.request.isReplay &&
        !current.isRace) {
      _persistProgress(current.play, session);
    }
    _softStuckTimer?.cancel();
    if (checkSoftStuck && status == GameplayStatus.playing) {
      _scheduleSoftStuckCheck(next.moveSeq);
    }
    return next;
  }

  /// Core's verdict on [session]'s board: won, out of moves, or in play
  /// (spec §2.3).
  GameplayStatus _statusOf(GameSession session) => session.isWon
      ? GameplayStatus.won
      : session.isOutOfMoves
      ? GameplayStatus.outOfMoves
      : GameplayStatus.playing;

  /// [current] with the booster fields recomputed from the session and the
  /// save's wallet (m3-design §7.3): `canUndo`/`canHint`/`canAddSlot` now
  /// mean "the press does something" (free, inventory, or an offer).
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
      // A past day (§7.5c) sells nothing: a booster counts only while the
      // player owns one (free undos, relaxed mode, an inventory count, or
      // the dev flavor's unlimited), so the Out of moves sheet lists only
      // those plus Restart.
      canUndo:
          session.canUndo &&
          (!current.isPastDaily ||
              unlimited ||
              current.relaxed ||
              freeUndosLeft > 0),
      // vs Computer (m7-design P2.6): Hint and +1 Slot are off.
      canHint:
          !current.isRace && (!current.isPastDaily || unlimited || hints > 0),
      canAddSlot:
          !current.isRace &&
          session.canAddExtraSlot &&
          (!current.isPastDaily || unlimited || extraSlots > 0),
      undoPrice: _remoteConfig.value(RemoteConfigKeys.priceUndo),
      hintPrice: _remoteConfig.value(RemoteConfigKeys.priceHint),
      slotPrice: _remoteConfig.value(RemoteConfigKeys.priceSlot),
    );
  }

  /// [current] with `tutorial` recomputed from the board and the selection
  /// (m3-design §10.4), logging [completedStep] first (`tutorial_step`). A
  /// replay never shows the cue, whatever `tutorialDone` says (m7-design
  /// §6): it is never scripted input a second time. Neither does a race
  /// (m7-design P2.6: "no tutorial cue").
  GameplayState _withTutorial(GameplayState current, {int? completedStep}) {
    if (completedStep != null) _logTutorialStep(completedStep);
    final cue = current.play.request.isReplay || current.isRace
        ? null
        : TutorialScript.cueFor(
            levelId: current.play.level.id,
            tutorialDone: _save.document.tutorialDone,
            board: current.board,
            selectedSlotId: current.selectedSlotId,
          );
    return current.copyWith(tutorial: cue);
  }

  /// [current] carrying [effect] with the next `effectSeq`.
  /// [current] with [effect] as its new effect. It also keeps
  /// [GameplayState.dropTargets] in step with the selection: core's legal
  /// targets for a nest just lifted, nothing once none is (E.14).
  GameplayState _withEffect(GameplayState current, BoardEffect effect) {
    final selected = current.selectedSlotId;
    final Set<String> targets;
    if (selected == null) {
      targets = const <String>{};
    } else if (effect is SelectionChangedEffect &&
        effect.selected == selected) {
      targets = Rules.legalTargets(current.board, selected).toSet();
    } else {
      targets = current.dropTargets;
    }
    return current.copyWith(
      effect: effect,
      effectSeq: current.effectSeq + 1,
      dropTargets: targets,
    );
  }

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
  /// sheet (frame 3.5), never while paused, on a popup or intro card, or
  /// during the scripted tutorial (m3-design §10.4).
  bool _acceptsBoosters(GameplayState current) =>
      current.acceptsInput && current.tutorial == null;

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
    _pendingHintSource = null;
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

  /// `past_daily_complete {days_ago, again}` (local habits 3): how far back
  /// the day was (1–28) and whether it was already played. Failures are
  /// swallowed by [AnalyticsService] itself, as for every event.
  ///
  /// TODO(M4): the kid path keeps this off for under-13s (D260, Q174): read
  /// the age gate here when it lands, as welcome_back_cubit.dart's
  /// `_logPlay` will.
  void _logPastDailyComplete(LocalDate date, {required bool again}) {
    final daysAgo = _clock.today().epochDay - date.epochDay;
    unawaited(
      _analytics.logEvent(
        'past_daily_complete',
        parameters: {'days_ago': daysAgo.clamp(1, 28), 'again': again},
      ),
    );
  }

  void _logTutorialStep(int step) => unawaited(
    _analytics.logEvent('tutorial_step', parameters: {'step': step}),
  );

  /// Every booster use counts in the save's `stats.boostersUsed` and logs
  /// `booster_use{type, source}` (spec §14.4, m3-design §7.2).
  void _logBoosterUse(BoosterType type, BoosterSource source) {
    _save.recordBoosterUse(type);
    unawaited(
      _analytics.logEvent(
        'booster_use',
        parameters: {'type': type.id, 'source': source.id},
      ),
    );
  }

  @override
  Future<void> close() async {
    _cancelSolverWork();
    await _relaxedChanges.cancel();
    return super.close();
  }
}
