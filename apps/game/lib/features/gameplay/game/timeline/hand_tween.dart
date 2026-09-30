import 'dart:math' as math;

import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/gameplay/bloc/tap_policy.dart'
    show SlotNudgeKind;
import 'package:nesty_render/nesty_render.dart';

/// A motion no Lottie file covers, computed by the board timeline
/// (docs/plans/m2-lottie-design.md §9). The timeline creates it when it
/// schedules a batch, starts it with a `StartTween` command, updates it
/// every `advance` and ends it with `EndTween`; the board reads its current
/// values while rendering. Durations are real ms at the batch's motion
/// speed.
///
/// [begin], [update] and [finish] belong to the timeline; everyone else
/// only reads.
sealed class HandTween {
  HandTween({required this.durationMs, this.slotId, this.hides = const []})
    : assert(durationMs >= 0);

  final double durationMs;

  /// The slot it moves, if one.
  final String? slotId;

  /// Slots whose top-doll sprite the board hides while the tween runs,
  /// because the tween draws that doll itself (the reveal drop's silhouette).
  final List<String> hides;

  double _startedAtMs = 0;
  double _t = 0;

  /// Linear time, 0 at the start and 1 at the end.
  double get t => _t;

  /// The eased value the board applies (0 → 1).
  double get progress;

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// Timeline only: starts the tween at timeline time [atMs].
  void begin(double atMs) {
    _startedAtMs = atMs;
    _set(0);
  }

  /// Timeline only: moves the tween to timeline time [nowMs].
  void update(double nowMs) {
    if (durationMs <= 0) {
      _set(1);
      return;
    }
    final t = (nowMs - _startedAtMs) / durationMs;
    _set(t < 0 ? 0 : (t > 1 ? 1 : t));
  }

  /// Timeline only: jumps to the end.
  void finish() => _set(1);

  void _set(double t) {
    _t = t;
    _changed();
  }

  /// Recomputes cached values after [t] changed.
  void _changed() {}

  // ── End of hot path. ──
}

/// E.13 (tokens `motion.tapFeedback`, frame 12.13): the acknowledgement of a
/// tap on a slot that can't be picked, with nothing lifted: never the invalid
/// shake. The stand of an empty slot dips 2 dp for 80 ms (with a light
/// haptic), a sealed case's padlock pings 1.15× for 160 ms and an iced slot's
/// counter bumps 1.2× for 160 ms. Each is one out-and-back, [wave] going 0 →
/// 1 → 0 (`sin πt`); the board applies the [kind]'s amount to its own piece.
/// Under reduced motion the durations halve (the batch's speed).
final class NudgeTween extends HandTween {
  NudgeTween({
    required String super.slotId,
    required this.kind,
    required super.durationMs,
  });

  final SlotNudgeKind kind;

  double _wave = 0;

  /// 0 at both ends, 1 in the middle.
  double get wave => _wave;

  @override
  double get progress => _wave;

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  void _changed() => _wave = math.sin(math.pi * t);

  // ── End of hot path. ──
}

/// B.7 (tokens `motion.tagPop`): the "+N" tag of a tower that was under ice
/// pops in when `fx_ice` plays `shatter` (frame 48, 0 ms into the segment):
/// 240 ms from 60 % scale, `easeOutBack`, so it overshoots a little.
final class TagPopTween extends HandTween {
  TagPopTween({required String super.slotId, required super.durationMs});

  double _scale = MotionTokens.tagPopFrom;

  /// The tag's scale now, [MotionTokens.tagPopFrom] → 1.
  double get scale => _scale;

  @override
  double get progress => _scale;

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  void _changed() {
    const from = MotionTokens.tagPopFrom;
    _scale = from + (1 - from) * MotionTokens.tagPopCurve.transform(t);
  }

  // ── End of hot path. ──
}

/// §9.1: while `doll_reveal`'s `drop` null lowers a tower's new top from
/// its buried step onto the stand (frames 0–7, `FxTiming.revealDropEndFrame`),
/// the nests still buried shift one step down with it, each keeping its
/// true size (D21).
///
/// The file draws the new top, silhouette then colour, from its own frame
/// 0 (the clip hides the slot's top sprite); the board draws the buried
/// silhouettes at depth `d` (new depths, 1 = right under the top) at
/// [buriedBaseY]. At progress 0 they match the rest pose before the
/// reveal, at 1 the rest pose after it.
final class RevealDropTween extends HandTween {
  RevealDropTween({
    required this.slot,
    required this.buried,
    required super.durationMs,
    this.topSize,
    this.iced = false,
  }) : super(slotId: slot.id) {
    final stack = slot.towerStack(topSize ?? slot.pipCount, buried, iced: iced);
    _step = stack.step;
  }

  final SlotGeometry slot;

  /// The nests the tower buried at the start of the level, for
  /// `SlotGeometry.towerStack`'s spacing.
  final int buried;

  /// The tallest size the tower held at the start of the level (null: the
  /// level's biggest), and whether it started iced: the rest of the stack's
  /// inputs.
  final int? topSize;
  final bool iced;

  double _step = 0;
  double _progress = 0;

  /// easeOut, the `drop` null's own curve (tokens `motion.easing.easeOut`),
  /// so the silhouettes behind move with the top.
  @override
  double get progress => _progress;

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  void _changed() => _progress = MotionTokens.curveEaseOut.transform(t);

  /// The base of the buried nest at new [depth] (≥ 1): from its old depth
  /// `depth + 1` to [depth].
  double buriedBaseY(int depth) =>
      slot.surfaceY - (depth + 1 - _progress) * _step;

  // ── End of hot path. ──
}

/// §9.3: a locked, iced or tower target shakes by hand on an invalid move,
/// with `doll_invalid`'s own `target` keyframes (`FxTiming.invalidShake*`:
/// 0, −6, 6, −6, 6, −6, 0, piecewise linear), times the board scale.
///
/// The board adds [offsetX] to everything the slot draws above its stand:
/// its glass or ice composition, its top-doll sprite, its buried
/// silhouettes and its ice badge. Not scheduled under reduced motion.
final class ShakeTween extends HandTween {
  ShakeTween({
    required String super.slotId,
    required this.amplitudeScale,
    required super.durationMs,
  });

  /// Logical px per composition unit: the board scale `s`.
  final double amplitudeScale;

  double _offsetX = 0;

  /// The horizontal offset now, in logical px.
  double get offsetX => _offsetX;

  @override
  double get progress => t;

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  void _changed() {
    const keys = FxTiming.invalidShakeKeyframes;
    final last = keys.length - 1;
    final position = t * last;
    var i = position.floor();
    if (i >= last) i = last - 1;
    if (i < 0) i = 0;
    final f = position - i;
    _offsetX = (keys[i] + (keys[i + 1] - keys[i]) * f) * amplitudeScale;
  }

  // ── End of hot path. ──
}

/// §9.5: +1 Slot re-pitches the bottom row from [from] to [to], easeInOut.
/// The board lerps the bottom row's stands, pips and dolls (and every
/// doll's height when `dollHeightScale` changed) with [lerp], and live
/// anchored clips with their `FxClip.anchor` on both layouts; it commits
/// [to] at `EndTween`.
final class RepitchTween extends HandTween {
  RepitchTween({
    required this.from,
    required this.to,
    required super.durationMs,
  });

  final BoardGeometry from;
  final BoardGeometry to;

  double _progress = 0;

  /// easeInOut (tokens `motion.easing.easeInOut`).
  @override
  double get progress => _progress;

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  void _changed() => _progress = MotionTokens.curveEaseInOut.transform(t);

  /// [a] on the old layout, [b] on the new one, at the current progress.
  double lerp(double a, double b) => a + (b - a) * _progress;

  // ── End of hot path. ──
}
