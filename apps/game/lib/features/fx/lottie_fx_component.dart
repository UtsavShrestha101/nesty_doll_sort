import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_layout.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_pool.dart';
import 'package:nesty_render/nesty_render.dart' show BoardFit;

/// A board clip: one [FxDrawable] (a `LottieDrawable` with its delegates, set
/// once) as a Flame [PositionComponent] (m2-lottie-design §2 "Board"). Our
/// own component, not flame_lottie (PROGRESS D41): pooled, driven by
/// explicit frames, with segments, speeds and paused rest frames.
///
/// - Its size is the file's canvas and its [anchor] the file's anchor, so
///   [placeAt] puts that point on a game point; [placeBoardSpace] lays a
///   390×844 board-space canvas over the board (§5).
/// - Driven explicitly: the board timeline calls [advance] from its own
///   `advance(dt)` (so a clip starts in the same frame its sprite hides,
///   §10.1). Set [autoAdvance] to let Flame's `update` do it instead.
/// - While [active] is false (idle in its pool) it neither updates nor
///   draws; pooled components can stay mounted.
/// - With [cacheRest] (the paused glass and ice compositions, §8) a still
///   frame is recorded into a `Picture` once and replayed until the frame,
///   the params, or any raster it drew changes.
/// - Every segment, rest or seek starts from a clean lottie seek
///   (`FxDrawable.draw`), so a pooled or reused component never draws two
///   layers across a boundary it jumped to.
class LottieFxComponent extends PositionComponent {
  LottieFxComponent(this.drawable, {super.priority, this.cacheRest = false})
    : super(
        size: Vector2(drawable.spec.width, drawable.spec.height),
        anchor: _anchorOf(drawable),
      );

  /// A pool of [FxPoolSizes.of] components for [id], or null when that
  /// file isn't loaded (rule 3: its clips are skipped).
  static FxPool<LottieFxComponent>? pool(
    FxLibrary library,
    FxId id, {
    int? capacity,
    int priority = 0,
  }) {
    if (library[id] == null) return null;
    return FxPool<LottieFxComponent>(
      capacity: capacity ?? FxPoolSizes.of(id),
      create: (_) =>
          LottieFxComponent(FxDrawable.of(library, id)!, priority: priority),
      onRelease: (component) => component.deactivate(),
      debugLabel: id.fileName,
    );
  }

  final FxDrawable drawable;

  /// Records still frames into a picture (paused glass and ice).
  final bool cacheRest;

  /// Advances the drawable in Flame's [update] instead of from the timeline.
  bool autoAdvance = false;

  /// The whole clip's opacity, 1 unless the host dims it (the drag hover's
  /// glow at 60 %, E.14). Below 1 it draws through one layer, whose paint
  /// and bounds are built once.
  double get opacity => _opacity;
  set opacity(double value) {
    if (value == _opacity) return;
    _opacity = value;
    _layerPaint.color = ui.Color.fromRGBO(0, 0, 0, value);
  }

  double _opacity = 1;
  final ui.Paint _layerPaint = ui.Paint();
  late final ui.Rect _layerBounds = ui.Rect.fromLTWH(
    0,
    0,
    drawable.spec.width,
    drawable.spec.height,
  );

  /// Called on the tick a one-shot reaches its end.
  void Function(LottieFxComponent component)? onFinished;

  bool _active = false;
  ui.Picture? _rest;
  double _restFrame = double.nan;
  int _restRevision = -1;
  FxPlayState _restState = FxPlayState.idle;
  Object? _restSource;

  FxId get id => drawable.id;

  bool get active => _active;

  /// Starts drawing (and updating); set the drawable's params up first.
  void activate() => _active = true;

  /// Stops drawing, resets the drawable and drops the rest picture (a clip
  /// returned to its pool).
  void deactivate() {
    _active = false;
    opacity = 1;
    drawable.reset();
    _dropRest();
  }

  /// Puts the file's anchor on ([x], [y]) (logical px, the board's
  /// coordinates) at [scale]: the board scale for doll files and
  /// `fx_sparkle`, the slot's furniture scale for board pieces (§5).
  /// [stretchY] stretches it vertically about the anchor (`fx_ice` on the
  /// tall preset plays at (1, 1.05) from the ice bottom).
  void placeAt(double x, double y, double scale, {double stretchY = 1}) {
    position.setValues(x, y);
    this.scale.setValues(scale, scale * stretchY);
  }

  /// Lays a board-space file's reference screen over the board: top-left
  /// at `fit.boardSpaceOrigin`, scaled by `fit.scale` (§5).
  void placeBoardSpace(BoardFit fit) {
    final origin = fit.boardSpaceOrigin;
    position.setValues(origin.dx, origin.dy);
    scale.setValues(fit.scale, fit.scale);
  }

  /// Plays [plan] [startMs] into it and activates.
  void play(FxPlan plan, {double startMs = 0}) {
    drawable.player.start(plan, startMs: startMs);
    _active = true;
  }

  /// Rests on [frame] and activates (a paused composition's rest look, §8:
  /// glass on frame 0, ice on its stage's `rest_n`).
  void rest(double frame) {
    drawable.player.rest(frame);
    _active = true;
  }

  /// Shows [frame] as authored and activates: a frame the host computes
  /// itself (not a rest look).
  void seek(double frame) {
    drawable.player.seek(frame);
    _active = true;
  }

  /// Drops the recorded rest picture; the next render records again. The
  /// frame, params and rasters are checked automatically; this is for
  /// anything else (the host moved the composition to a new layout).
  void invalidateRest() => _dropRest();

  // ── Hot path: every tick and frame. No allocation except recording a
  // rest picture when it goes stale (§8). ──

  /// Advances the drawable by [dtMs] (the board timeline's tick).
  void advance(double dtMs) {
    if (!_active) return;
    if (drawable.advance(dtMs)) onFinished?.call(this);
  }

  @override
  void update(double dt) {
    if (autoAdvance) advance(dt * 1000);
  }

  @override
  void render(ui.Canvas canvas) {
    if (!_active) return;
    final dimmed = _opacity < 1;
    if (dimmed) canvas.saveLayer(_layerBounds, _layerPaint);
    if (cacheRest && drawable.player.isStill) {
      if (!_restIsCurrent) _recordRest();
      canvas.drawPicture(_rest!);
    } else {
      drawable.draw(canvas);
    }
    if (dimmed) canvas.restore();
  }

  bool get _restIsCurrent =>
      _rest != null &&
      _restFrame == drawable.player.frame &&
      _restState == drawable.player.state &&
      _restRevision == drawable.params.revision &&
      identical(_restSource, drawable.images.source) &&
      drawable.images.servedStillCurrent;

  // ── End of hot path. ──

  void _recordRest() {
    _restRecordings++;
    _dropRest();
    drawable.images.clearServed();
    final recorder = ui.PictureRecorder();
    drawable.draw(ui.Canvas(recorder));
    _rest = recorder.endRecording();
    _restFrame = drawable.player.frame;
    _restState = drawable.player.state;
    _restRevision = drawable.params.revision;
    _restSource = drawable.images.source;
  }

  void _dropRest() {
    _rest?.dispose();
    _rest = null;
  }

  /// Whether a rest picture is recorded now.
  @visibleForTesting
  bool get hasRestPicture => _rest != null;

  /// How many times a rest picture was recorded.
  @visibleForTesting
  int get restRecordings => _restRecordings;
  int _restRecordings = 0;

  @override
  void onRemove() {
    _dropRest();
    super.onRemove();
  }

  static Anchor _anchorOf(FxDrawable drawable) {
    final (x, y) = FxLayout.anchorFraction(drawable.spec);
    return Anchor(x, y);
  }
}
