import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/tap_policy.dart'
    show SlotNudgeKind;
import 'package:nesty_game/features/gameplay/game/timeline/combo_tracker.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_clip.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_command.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_placement.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_segment.dart';
import 'package:nesty_game/features/gameplay/game/timeline/hand_tween.dart';
import 'package:nesty_game/features/gameplay/game/timeline/motion_spec.dart';
import 'package:nesty_game/features/gameplay/game/timeline/slot_reservations.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline_batch.dart';
import 'package:nesty_render/nesty_render.dart';

part 'timeline_plans.dart';

/// Looks a file's spec up: `fxSpecOf` from `fx_spec.gen.dart` in the game.
typedef FxSpecLookup = FxSpec Function(FxId id);

/// How many clips of each board file can be alive at once
/// (docs/plans/m2-lottie-design.md §14). The board builds at least these
/// pools; the timeline skips a clip that would exceed one (its sprite stays
/// at rest; its cues and reservations are unchanged).
abstract final class TimelinePools {
  static const Map<FxId, int> defaults = {
    FxId.dollPick: 2,
    FxId.dollMove: 2,
    FxId.dollNest: 2,
    FxId.dollSwallow: 2,
    FxId.dollComplete: 2,
    FxId.dollInvalid: 2,
    // A source and a destination reveal in one batch.
    FxId.dollReveal: 2,
    // The selection, the hint's target, the drag hover and one fading out.
    FxId.fxSelectGlow: 4,
    FxId.fxDustPuff: 4,
    // A 60 ms cadence of 267 ms sparkles: at most 5 live, plus margin.
    FxId.fxSparkle: 9,
    FxId.uiHintArrow: 1,
    FxId.uiExtraSlot: 2,
  };
}

/// The board's timeline: turns each [BoardEffect] into Lottie clips,
/// hand-coded tweens, sprite syncs, sounds and haptics at exact times, and
/// gates input while they play (docs/plans/m2-lottie-design.md §7–§10, §13;
/// LOTTIE.md "When each one plays").
///
/// Pure Dart: no Flame and no lottie. Every length comes from the files'
/// `FxSpec`s and `FxTiming`, never from hand-typed durations; every
/// distance from `BoardGeometry` in logical px (reference units for the
/// board-space travel). The Flame board executes the [FxCommand]s it emits
/// through an [FxCommandSink] and the cues go to a [FeedbackSink]. It never
/// changes game state (CLAUDE.md rule 10): the board settles on what core
/// said through `SyncSlot`.
///
/// Usage, from the game loop:
/// - [schedule] each effect (from `NestyGame.apply`, run inside `update`:
///   the batch's time-0 commands execute before it returns);
/// - [advance] once per frame, after the live clips were advanced;
/// - drop taps and drags where [acceptsInput] is false.
final class BoardTimeline {
  BoardTimeline({
    required FxCommandSink commands,
    required FeedbackSink feedback,
    required BoardGeometry geometry,
    this.motion = MotionSpec.standard,
    FxSpecLookup specOf = fxSpecOf,
    bool Function(FxId id)? isAvailable,
    Map<FxId, int> poolSizes = TimelinePools.defaults,
    ComboTracker? combo,
  }) : _commands = commands,
       _feedback = feedback,
       _geometry = geometry,
       _specOf = specOf,
       _isAvailable = isAvailable ?? _always,
       _pools = List<int>.generate(
         FxId.values.length,
         (i) => poolSizes[FxId.values[i]] ?? _unpooled,
       ),
       _liveCount = List<int>.filled(FxId.values.length, 0),
       _comboOverride = combo;

  static bool _always(FxId id) => true;

  /// Files the timeline doesn't pool (they aren't board clips).
  static const _unpooled = 1 << 30;

  /// Times closer than this are the same instant (float sums of frame
  /// times).
  static const _epsilon = 1e-6;

  /// The rest frame of a paused `fx_ice` composition whose counter started
  /// at [initial] and is now [remaining]: the `rest_n` marker of stage
  /// `BoardLayout.iceFrame` (0, 16, 32 or 48; §8, D51).
  static double iceRestFrame({required int remaining, required int initial}) =>
      FxIceSegments.restFrame(
        fxSpecOf(FxId.fxIce),
        BoardLayout.iceFrame(remaining: remaining, initial: initial),
      );

  /// The rest frame of a paused `fx_glass_unlock` composition (§8).
  static const glassRestFrame = 0.0;

  final FxCommandSink _commands;
  final FeedbackSink _feedback;
  final FxSpecLookup _specOf;
  final bool Function(FxId id) _isAvailable;
  final List<int> _pools;
  final List<int> _liveCount;
  final ComboTracker? _comboOverride;

  /// Completion combos (4 s, max 5). Board time by default; injectable.
  late final ComboTracker combo =
      _comboOverride ?? ComboTracker(clock: () => _now);

  /// The motion new batches are planned with. The page sets it from
  /// `MediaQuery.disableAnimationsOf` (§13); batches already scheduled keep
  /// theirs.
  MotionSpec motion;

  BoardGeometry _geometry;

  /// The layout clips are placed on.
  BoardGeometry get geometry => _geometry;

  /// While true every slot drops input: the pause dialog (§7 "Global
  /// lock"). The Flame engine is paused too, so time stands still.
  bool paused = false;

  /// While true every slot drops input: an overlay or sheet is open (win,
  /// out of moves).
  bool overlayOpen = false;

  double _now = 0;
  double _busyUntil = 0;
  double _repitchUntil = 0;
  bool _won = false;

  int _nextClipId = 1;
  int _nextBatchId = 1;

  final SlotReservations _reservations = SlotReservations();
  final List<_Queued> _queue = [];
  int _head = 0;
  final List<HandTween> _tweens = [];

  _Selection? _selection;

  /// Deselected nests whose settle may still play, by slot: a quick re-tap
  /// stops them so two clips never draw one doll.
  final Map<String, _Selection> _settling = {};
  _Hint? _hint;
  _Hover? _hover;
  final Map<String, _Track> _extraPulses = {};

  /// When each live `ui_extra_slot` loop began, in timeline time: the loop's
  /// phase at a landing (E.16), so it settles from the frame it is on.
  final Map<String, double> _pulseStartMs = {};

  /// Timeline time in ms: the sum of every [advance].
  double get nowMs => _now;

  /// When everything scheduled so far has played, in timeline time.
  double get busyUntilMs => _busyUntil;

  /// The slot whose nest is lifted, if any.
  String? get selectedSlotId => _selection?.slotId;

  /// The lifted nest's `doll_pick` clip: while it is dragged the board
  /// moves this clip with the finger.
  FxClip? get selectionClip => _selection?.pick.clip;

  /// The tweens running now, for tests and debug overlays.
  List<HandTween> get debugActiveTweens => List.unmodifiable(_tweens);

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// True while every slot drops input: won, paused, an overlay, or the
  /// +1 Slot re-pitch.
  bool get inputLocked =>
      paused || overlayOpen || _won || _repitchUntil > _now + _epsilon;

  /// Whether [slotId] is playing a batch and drops taps and drags (§7
  /// "Reservation").
  bool isReserved(String slotId) =>
      _reservations.isReserved(slotId, _now + _epsilon);

  /// Whether a tap or drag on [slotId] goes to the bloc now. A drop on a
  /// slot that doesn't accept input should be sent as a cancel.
  bool acceptsInput(String slotId) => !inputLocked && !isReserved(slotId);

  /// True when nothing is waiting to play (loops may still run).
  bool get isIdle => _head >= _queue.length;

  /// Moves time on by [dtMs] and executes everything now due, then updates
  /// the running tweens.
  void advance(double dtMs) {
    if (dtMs > 0) _now += dtMs;
    _dispatchDue();
    for (var i = 0; i < _tweens.length; i++) {
      _tweens[i].update(_now);
    }
  }

  void _dispatchDue() {
    while (_head < _queue.length && _queue[_head].at <= _now + _epsilon) {
      final item = _queue[_head];
      _head++;
      _dispatch(item);
    }
    if (_head >= _queue.length) {
      if (_head > 0) {
        _queue.length = 0;
        _head = 0;
      }
    } else if (_head > 64 && _head * 2 > _queue.length) {
      _queue.removeRange(0, _head);
      _head = 0;
    }
  }

  void _dispatch(_Queued item) {
    final late = _now - item.at;
    final lateMs = late > 0 ? late : 0.0;
    final cue = item.cue;
    if (cue != null) {
      _feedback.play(cue);
      return;
    }
    final command = item.command!;
    final track = item.track;
    // A later batch re-planned this clip: this plan's rest is void.
    if (track != null && item.epoch != track.epoch) return;
    switch (command) {
      case StartClip():
        if (track == null || !_canStart(track, item.trailOf)) {
          track?.done = true;
          return;
        }
        track.live = true;
        _liveCount[track.clip.fx.index]++;
      case StopClip():
        if (track == null || !track.live) return;
        track.live = false;
        track.done = true;
        _liveCount[track.clip.fx.index]--;
      case PlayClipSegment() || PlaceClip() || ReleaseClipSlots():
        if (track == null || !track.live) return;
      case StartTween(:final tween):
        tween.begin(item.at);
        _tweens.add(tween);
      case EndTween(:final tween):
        tween.finish();
        _tweens.remove(tween);
      default:
        break;
    }
    _commands.execute(command, lateMs);
  }

  bool _canStart(_Track track, _Track? trailOf) {
    if (track.done) return false;
    final fx = track.clip.fx;
    if (!_isAvailable(fx)) return false;
    if (_liveCount[fx.index] >= _pools[fx.index]) return false;
    // A sparkle has no trail to sit on when the flight never started.
    if (trailOf != null && !trailOf.live) return false;
    return true;
  }

  // ── End of hot path. ──

  /// Plans [effect] on [board] (the state after it, `GameplayState.board`)
  /// and queues it after whatever is playing. Returns the plan.
  ///
  /// Pass [geometry] when the layout changed with the effect: always with
  /// an [ExtraSlotAddedEffect] (the re-pitch runs from the current layout to
  /// it) and with a [BoardResetEffect] for a new level. Pass [dragBase], the
  /// dragged doll's base in logical px (already clamped to the board frame),
  /// with any `byDrag` effect that ends a drag: the doll flies from there.
  TimelineBatch schedule(
    BoardEffect effect,
    GameState board, {
    BoardGeometry? geometry,
    Offset? dragBase,
  }) {
    final previousGeometry = _geometry;
    if (geometry != null) _geometry = geometry;
    final batch = _Batch(
      id: _nextBatchId++,
      effect: effect,
      startMs: _now,
      scale: motion.durationScale,
    );
    switch (effect) {
      case SelectionChangedEffect():
        _planSelection(batch, effect, board, dragBase);
      case MoveAppliedEffect():
        _planMove(batch, effect, board, dragBase);
      case MoveRejectedEffect():
        _planRejected(batch, effect, board, dragBase);
      case BoardResetEffect():
        _planReset(batch, effect);
      case HintShownEffect():
        _planHint(batch, effect.move, board);
      case HintClearedEffect():
        _planHintCleared(batch);
      case ExtraSlotAddedEffect():
        _planExtraSlot(batch, effect, board, previousGeometry);
      case SlotNudgeEffect():
        _planNudge(batch, effect);
    }
    return _commit(batch);
  }

  /// The stand a dragged doll hovers over (E.14): it gets the dimmed glow;
  /// null (or a stand that isn't a legal target) removes it. The board calls
  /// it when the stand under the finger changes.
  void hover(String? slotId) {
    if (slotId == _hover?.slotId) return;
    final batch = _Batch(
      id: _nextBatchId++,
      effect: const HintClearedEffect(),
      startMs: _now,
      scale: motion.durationScale,
    );
    _planHover(batch, slotId);
    for (final item in batch.items) {
      _enqueue(item);
    }
    _dispatchDue();
  }

  /// The slot whose stand carries the drag hover's glow, if any.
  String? get hoverSlotId => _hover?.slotId;

  /// Swaps the layout without a re-pitch (the viewport changed) and moves
  /// the lasting clips (selection, hint, extra-slot stands) onto it now.
  void relayout(BoardGeometry geometry) {
    _geometry = geometry;
    final batch = _Batch(
      id: _nextBatchId++,
      effect: const HintClearedEffect(),
      startMs: _now,
      scale: motion.durationScale,
    );
    _placeLasting(batch, 0);
    for (final item in batch.items) {
      _enqueue(item);
    }
    _dispatchDue();
  }

  TimelineBatch _commit(_Batch batch) {
    for (final item in batch.items) {
      _enqueue(item);
    }
    for (final entry in batch.reservations.entries) {
      _reservations.reserve(entry.key, batch.startMs + entry.value);
    }
    if (batch.globalLock > 0) {
      _repitchUntil = math.max(_repitchUntil, batch.startMs + batch.globalLock);
    }
    _busyUntil = math.max(_busyUntil, batch.startMs + batch.end);
    final result = batch.build();
    _dispatchDue();
    for (var i = 0; i < _tweens.length; i++) {
      _tweens[i].update(_now);
    }
    return result;
  }

  void _enqueue(_Queued item) {
    var lo = _head;
    var hi = _queue.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_queue[mid].before(item)) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    _queue.insert(lo, item);
  }

  /// Cancels everything (a board reset): nothing queued, no clip alive, no
  /// tween, no reservation, no lock but pause and overlays.
  void _cancelAll() {
    _queue.length = 0;
    _head = 0;
    for (var i = 0; i < _liveCount.length; i++) {
      _liveCount[i] = 0;
    }
    for (final tween in _tweens) {
      tween.finish();
    }
    _tweens.clear();
    _selection = null;
    _settling.clear();
    _hint = null;
    _hover = null;
    _extraPulses.clear();
    _pulseStartMs.clear();
    _reservations.clear();
    _won = false;
    _repitchUntil = _now;
    _busyUntil = _now;
  }

  FxSpec _spec(FxId id) => _specOf(id);

  _Track _newClip(
    _Batch batch,
    FxId fx,
    FxClipPurpose purpose,
    FxPlacement placement, {
    FxClipParams params = FxClipParams.none,
    String? slotId,
    FxAnchor? anchor,
    int anchorSize = 1,
    List<String> hides = const [],
  }) => _Track(
    FxClip(
      id: _nextClipId++,
      fx: fx,
      purpose: purpose,
      placement: placement,
      params: params,
      slotId: slotId,
      anchor: anchor,
      anchorSize: anchorSize,
      hides: hides,
    ),
    batch.id,
  );
}

/// A clip as the timeline tracks it: started (live), or finished or
/// skipped (done). Commands for a clip that isn't live are dropped.
///
/// [epoch] counts the plans made for the clip: when a later batch plans it
/// again (a glow that goes out before its `pulse` was due, a settle, a drag
/// that stops a wobble), the earlier plan's pending commands are dropped.
final class _Track {
  _Track(this.clip, this.owner);

  final FxClip clip;
  bool live = false;
  bool done = false;
  int epoch = 0;

  /// The batch that planned it last.
  int owner;
}

/// One queued command or cue at timeline time [at]. Items due at the same
/// instant run in batch order, then in the order they were planned.
final class _Queued {
  _Queued(
    this.at,
    this.batch,
    this.seq, {
    this.command,
    this.cue,
    this.track,
    this.trailOf,
    this.epoch = 0,
  });

  final double at;
  final int batch;
  final int seq;

  /// The [track]'s plan this command belongs to.
  final int epoch;
  final FxCommand? command;
  final FxCue? cue;
  final _Track? track;
  final _Track? trailOf;

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  bool before(_Queued other) {
    if (at < other.at - BoardTimeline._epsilon) return true;
    if (at > other.at + BoardTimeline._epsilon) return false;
    if (batch != other.batch) return batch < other.batch;
    return seq < other.seq;
  }

  // ── End of hot path. ──
}

/// The lifted nest: its `doll_pick` clip and its glow.
final class _Selection {
  _Selection({
    required this.slotId,
    required this.nest,
    required this.pick,
    required this.glow,
  });

  final String slotId;
  final Nest nest;
  final _Track pick;
  final _Track glow;
}

/// The hint on screen: its arrow and its target glow.
final class _Hint {
  _Hint({
    required this.move,
    required this.size,
    required this.arrow,
    required this.glow,
  });

  final Move move;
  final int size;
  final _Track arrow;
  final _Track glow;
}

/// The drag hover on screen: its slot and its dimmed glow.
final class _Hover {
  _Hover({required this.slotId, required this.glow, required this.params});

  final String slotId;
  final _Track glow;
  final FxClipParams params;
}

/// A batch being planned: times are real ms from its start.
final class _Batch {
  _Batch({
    required this.id,
    required this.effect,
    required this.startMs,
    required this.scale,
  });

  final int id;
  final BoardEffect effect;
  final double startMs;

  /// `MotionSpec.durationScale` of the batch.
  final double scale;

  final List<_Queued> items = [];
  final Map<String, double> reservations = {};
  double end = 0;
  double globalLock = 0;
  bool locksInput = false;
  int _seq = 0;

  /// [ms] at 1×, at the batch's motion speed.
  double at(double ms) => ms * scale;

  /// Queues [command]. [holdsBatch] false: it may run after [end] (the
  /// sparkle trail's last particles fade out after the counter bump; they
  /// don't hold `onWon`, §7).
  ///
  /// The first command for a [track] an earlier batch planned supersedes
  /// that plan's pending commands, unless [supersedes] is false (a
  /// `PlaceClip` moves a clip without changing what it plays).
  void command(
    FxCommand command, {
    _Track? track,
    _Track? trailOf,
    bool holdsBatch = true,
    bool supersedes = true,
  }) {
    if (track != null && supersedes && track.owner != id) {
      track
        ..owner = id
        ..epoch += 1;
    }
    items.add(
      _Queued(
        startMs + command.atMs,
        id,
        _seq++,
        command: command,
        track: track,
        trailOf: trailOf,
        epoch: track?.epoch ?? 0,
      ),
    );
    if (holdsBatch) extend(command.atMs);
  }

  void cue(FxCue cue) {
    items.add(_Queued(startMs + cue.atMs, id, _seq++, cue: cue));
    extend(cue.atMs);
  }

  void reserve(String slotId, double untilMs) {
    final current = reservations[slotId];
    if (current == null || untilMs > current) reservations[slotId] = untilMs;
  }

  void extend(double ms) {
    if (ms > end) end = ms;
  }

  TimelineBatch build() {
    final ordered = [...items]
      ..sort((a, b) => a.before(b) ? -1 : (b.before(a) ? 1 : 0));
    return TimelineBatch(
      id: id,
      effect: effect,
      startMs: startMs,
      commands: [for (final item in ordered) ?item.command],
      cues: [for (final item in ordered) ?item.cue],
      reservations: reservations,
      endMs: end,
      globalLockMs: globalLock,
      locksInput: locksInput,
    );
  }
}
