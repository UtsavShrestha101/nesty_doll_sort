import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';

/// A stretch of a file, in composition frames (60 fps): a marker's
/// segment, or the whole file (docs/plans/m2-lottie-design.md §2).
final class FxRange {
  const FxRange(this.start, this.end) : assert(end >= start);

  /// Frames 0 to the file's length.
  FxRange.whole(FxSpec spec) : this(0, spec.frames.toDouble());

  /// The segment of [marker].
  FxRange.of(FxMarker marker) : this(marker.start, marker.end);

  /// The segment of the marker called [name] in [spec], or null when the
  /// file has none (a re-export dropped it): callers show the rest pose
  /// (CLAUDE.md rule 3).
  static FxRange? marker(FxSpec spec, String name) {
    final m = spec.marker(name);
    return m == null ? null : FxRange.of(m);
  }

  final double start;

  /// The frame after the last one. A one-shot ends showing this frame
  /// (clamped to lottie's last renderable frame, [FxPlayer.progressOf]).
  final double end;

  double get frames => end - start;

  /// Length in ms at 1×.
  double get durationMs => FxSpec.msOf(frames);

  @override
  bool operator ==(Object other) =>
      other is FxRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'FxRange($start–$end)';
}

/// How a file's motion is treated under reduced motion (PROGRESS D48,
/// m2-lottie-design §13).
enum FxMotionClass {
  /// Plays at `1 / durationScale` = 2× under reduced motion.
  oneShot,

  /// Decorative loops (`doll_idle`, `fx_twinkle`, `doll_win_*`, and
  /// `doll_pick`'s `wobble`): paused under reduced motion.
  ambient,

  /// Loops that carry information (the glow pulse, the hint arrow, the
  /// booster glow, the extra-slot pulse, the spinner, the tutorial hands):
  /// always at 1×.
  informational,

  /// Not played at all under reduced motion (`fx_confetti`).
  decorative,
}

/// The reduced-motion policy of every file (D48). The board timeline's
/// `MotionSpec` owns the batch timing (offsets, staggers, cue times); this
/// only says how fast, or whether, a clip itself plays.
abstract final class FxMotionPolicy {
  /// A one-shot's speed under reduced motion (duration × 0.5).
  static const reducedSpeed = 2.0;

  /// The class of [id], or of its [segment] (a marker name) for files that
  /// mix one-shot and looping segments.
  static FxMotionClass classOf(FxId id, [String? segment]) => switch (id) {
    FxId.dollIdle ||
    FxId.dollWinDance ||
    FxId.dollWinHop ||
    FxId.fxTwinkle => FxMotionClass.ambient,
    // The intro card's loops rest still on frame 0 under reduced motion
    // (LOTTIE.md "Mechanic intro card"; phase 4 architecture §0.1 D).
    FxId.uiIntroTowers ||
    FxId.uiIntroGlass ||
    FxId.uiIntroIce => FxMotionClass.ambient,
    FxId.dollPick when segment == 'wobble' => FxMotionClass.ambient,
    FxId.fxSelectGlow when segment == 'pulse' => FxMotionClass.informational,
    FxId.uiHintArrow ||
    FxId.uiBoosterGlow ||
    FxId.uiExtraSlot ||
    FxId.uiSpinner ||
    FxId.uiTapHand ||
    FxId.uiDragHand => FxMotionClass.informational,
    FxId.fxConfetti => FxMotionClass.decorative,
    _ => FxMotionClass.oneShot,
  };

  /// The playback speed of [id]'s [segment] (before any caller speed).
  static double speedOf(FxId id, {required bool reduced, String? segment}) =>
      reduced && classOf(id, segment) == FxMotionClass.oneShot
      ? reducedSpeed
      : 1;

  /// Whether [id] ([segment]) is paused on its first frame (ambient) or not
  /// drawn (decorative) under reduced motion.
  static bool isStill(FxId id, {required bool reduced, String? segment}) {
    if (!reduced) return false;
    final c = classOf(id, segment);
    return c == FxMotionClass.ambient || c == FxMotionClass.decorative;
  }

  /// Whether [id] is skipped entirely (nothing drawn) under reduced motion.
  static bool isSkipped(FxId id, {required bool reduced}) =>
      reduced && classOf(id) == FxMotionClass.decorative;
}

/// What one clip plays: a segment once, optionally followed by a looping
/// segment, each at its own speed; or a frame to rest on. Built once per
/// event (never per frame) and handed to [FxPlayer.start].
final class FxPlan {
  const FxPlan(
    this.once, {
    this.speed = 1,
    this.then,
    this.thenSpeed = 1,
    this.loop = false,
    this.restFrame,
  }) : assert(speed > 0 && thenSpeed > 0);

  /// Rests on [frame] (a paused composition's rest look).
  const FxPlan.rest(double frame)
    : once = const FxRange(0, 0),
      speed = 1,
      then = null,
      thenSpeed = 1,
      loop = false,
      restFrame = frame;

  /// [segment] of [spec] (a marker name), then optionally [thenMarker]
  /// looping, with the reduced-motion policy of §13 applied:
  /// - a one-shot plays at 2×, an informational loop at 1×;
  /// - an ambient follow-up loop is dropped: the clip holds the first
  ///   segment's last frame (`doll_pick` holds `lift`'s end, D48);
  /// - an ambient segment rests on its first frame.
  ///
  /// [speed] multiplies both (M7 feel tuning). Null when [spec] has no such
  /// marker (rule 3: the caller shows the rest pose).
  static FxPlan? marker(
    FxSpec spec,
    String segment, {
    String? thenMarker,
    bool loop = false,
    bool reduced = false,
    double speed = 1,
  }) {
    final once = FxRange.marker(spec, segment);
    if (once == null) return null;
    final id = spec.id;
    if (FxMotionPolicy.isStill(id, reduced: reduced, segment: segment)) {
      return FxPlan.rest(once.start);
    }
    FxRange? then;
    if (thenMarker != null &&
        !FxMotionPolicy.isStill(id, reduced: reduced, segment: thenMarker)) {
      then = FxRange.marker(spec, thenMarker);
    }
    return FxPlan(
      once,
      speed:
          speed *
          FxMotionPolicy.speedOf(id, reduced: reduced, segment: segment),
      then: then,
      thenSpeed:
          speed *
          FxMotionPolicy.speedOf(id, reduced: reduced, segment: thenMarker),
      loop: loop,
    );
  }

  /// The whole file, looping when the file loops ([FxSpec.loops]), with
  /// the reduced-motion policy applied: ambient loops rest on frame 0.
  factory FxPlan.whole(
    FxSpec spec, {
    bool reduced = false,
    double speed = 1,
    bool? loop,
  }) {
    if (FxMotionPolicy.isStill(spec.id, reduced: reduced)) {
      return const FxPlan.rest(0);
    }
    return FxPlan(
      FxRange.whole(spec),
      speed: speed * FxMotionPolicy.speedOf(spec.id, reduced: reduced),
      loop: loop ?? spec.loops,
    );
  }

  final FxRange once;
  final double speed;

  /// Looped after [once] (the `wobble` after `lift`, the `pulse` after
  /// `in`). Ignored when [loop] is set.
  final FxRange? then;
  final double thenSpeed;

  /// Loops [once] itself.
  final bool loop;

  /// Non-null for a rest plan.
  final double? restFrame;

  /// True when the clip never finishes on its own.
  bool get isEndless => restFrame != null || loop || then != null;

  /// Length in ms of a finite plan (what the timeline reserves), or null
  /// for an endless one.
  double? get durationMs => isEndless ? null : once.durationMs / speed;
}

/// Where a clip is.
enum FxPlayState {
  /// Not started: shows frame 0.
  idle,

  /// Paused on a rest frame ([FxPlayer.rest]): the paused glass and ice
  /// compositions, the toggle's on/off look, an ambient loop under reduced
  /// motion.
  resting,

  /// Showing an arbitrary frame set from outside ([FxPlayer.seek]): the
  /// splash loader's progress, tests.
  seeking,

  /// Advancing.
  playing,

  /// A one-shot that reached its end and holds its last frame.
  finished,
}

/// Pure frame bookkeeping for one clip: segment, loop, speed and pause
/// maths, with no lottie or Flame (m2-lottie-design §2). The clip reads
/// [frame] and [progress]; the owner calls [advance] once per tick (the
/// board timeline's `advance(dt)`, or a widget's ticker).
final class FxPlayer {
  FxPlayer({required this.durationFrames}) : assert(durationFrames > 0);

  /// A player for [spec] without its composition: lottie's
  /// `durationFrames` is `op − 0.01` for every file (they all start at 0).
  FxPlayer.forSpec(FxSpec spec) : this(durationFrames: durationFramesOf(spec));

  /// lottie's `LottieComposition.durationFrames` for [spec]: the parser
  /// stores `op − 0.01` as the end frame.
  static double durationFramesOf(FxSpec spec) => spec.frames - 0.01;

  /// Composition frames per ms at 1× (60 fps).
  static const framesPerMs = FxSpec.frameRate / 1000;

  /// `LottieComposition.durationFrames`: progress 1.0 is this frame.
  final double durationFrames;

  FxPlayState _state = FxPlayState.idle;
  double _frame = 0;
  double _elapsedMs = 0;
  int _epoch = 0;

  // The current plan, unpacked so advancing reads fields only.
  FxRange _once = const FxRange(0, 0);
  double _speed = 1;
  FxRange? _then;
  double _thenSpeed = 1;
  bool _loop = false;

  FxPlayState get state => _state;

  /// Bumped by every jump to a frame playback didn't lead to: a new plan
  /// ([start]), a rest, a seek, a reset. `FxDrawable` re-seeks lottie from
  /// a clean frame on the next draw, because lottie 3.6.1's keyframe cache
  /// can keep a layer that ends on the new frame (`fx_ice`'s `ice_0_hit`
  /// at 99, where `ice_1_hit` starts) when the last draw was inside it
  /// (the v3 check's issue 1).
  int get epoch => _epoch;

  /// The composition frame shown now.
  double get frame => _frame;

  /// Ms since the plan started, at the clip's own speed.
  double get elapsedMs => _elapsedMs;

  bool get isPlaying => _state == FxPlayState.playing;
  bool get isResting => _state == FxPlayState.resting;
  bool get isFinished => _state == FxPlayState.finished;

  /// True while nothing changes frame to frame (rest, seek, finished,
  /// idle): a paused composition can replay a recorded picture.
  bool get isStill => _state != FxPlayState.playing;

  /// The drawable's progress for [frame].
  double get progress => progressOf(_frame);

  /// `frame / durationFrames`, clamped to 0–1: a marker's end can be past
  /// lottie's last frame (`settle` ends at 41 of 40.99), and lottie asserts
  /// progress ≤ 1 (analysis "packages" §1).
  double progressOf(double frame) {
    final p = frame / durationFrames;
    return p < 0 ? 0 : (p > 1 ? 1 : p);
  }

  /// Pauses on [frame]: a rest look.
  void rest(double frame) {
    _state = FxPlayState.resting;
    _frame = frame;
    _elapsedMs = 0;
    _epoch++;
  }

  /// Shows [frame] without playing (the splash loader, scrubbing).
  void seek(double frame) {
    _state = FxPlayState.seeking;
    _frame = frame;
    _epoch++;
  }

  /// Starts [plan], [startMs] into it (a random phase for idle dolls, or a
  /// clip scheduled mid-tick).
  void start(FxPlan plan, {double startMs = 0}) {
    final restFrame = plan.restFrame;
    if (restFrame != null) {
      rest(restFrame);
      return;
    }
    _once = plan.once;
    _speed = plan.speed;
    _then = plan.loop ? null : plan.then;
    _thenSpeed = plan.thenSpeed;
    _loop = plan.loop;
    _state = FxPlayState.playing;
    _elapsedMs = startMs < 0 ? 0 : startMs;
    _frame = frameAt(_elapsedMs);
    _epoch++;
    if (_isDoneAt(_elapsedMs)) _state = FxPlayState.finished;
  }

  /// Back to [FxPlayState.idle] on frame 0 (a clip returned to its pool).
  void reset() {
    _state = FxPlayState.idle;
    _frame = 0;
    _elapsedMs = 0;
    _once = const FxRange(0, 0);
    _speed = 1;
    _then = null;
    _thenSpeed = 1;
    _loop = false;
    _epoch++;
  }

  // ── Hot path: advanced every tick of every live clip. No allocation. ──

  /// Advances a playing clip by [dtMs] of wall time. Returns true on the
  /// tick a one-shot reaches its end (it then holds its last frame).
  bool advance(double dtMs) {
    if (_state != FxPlayState.playing) return false;
    _elapsedMs += dtMs;
    _frame = frameAt(_elapsedMs);
    if (_isDoneAt(_elapsedMs)) {
      _state = FxPlayState.finished;
      return true;
    }
    return false;
  }

  /// The frame the current plan shows [elapsedMs] after its start. Pure.
  double frameAt(double elapsedMs) {
    final once = _once;
    final onceFrames = once.end - once.start;
    final played = elapsedMs * _speed * framesPerMs;
    if (_loop) {
      if (onceFrames <= 0) return once.start;
      return once.start + played % onceFrames;
    }
    if (played < onceFrames) return once.start + played;
    final then = _then;
    if (then == null) return once.end;
    final thenFrames = then.end - then.start;
    if (thenFrames <= 0) return then.start;
    final onceMs = onceFrames / (_speed * framesPerMs);
    final looped = (elapsedMs - onceMs) * _thenSpeed * framesPerMs;
    return then.start + looped % thenFrames;
  }

  bool _isDoneAt(double elapsedMs) =>
      !_loop &&
      _then == null &&
      elapsedMs * _speed * framesPerMs >= _once.end - _once.start;

  // ── End of hot path. ──
}
