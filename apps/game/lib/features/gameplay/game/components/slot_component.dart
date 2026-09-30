import 'dart:ui';

import 'package:flame/components.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_layout.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/fx/lottie_fx_component.dart';
import 'package:nesty_game/features/gameplay/game/components/board_scene.dart';
import 'package:nesty_game/features/gameplay/game/components/board_stand_ins.dart';
import 'package:nesty_game/features/gameplay/game/components/nest_component.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_decor.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_segment.dart';
import 'package:nesty_render/nesty_render.dart';

/// Everything one slot draws above its stand (docs/plans/m2-lottie-design.md
/// §8): its rest sprite ([nest]), its paused `fx_glass_unlock` (or
/// `fx_glass_unlock_tall`) or `fx_ice` composition, and the ice badge on top.
///
/// - A locked slot owns one `fx_glass_unlock` drawable (the tall one for a
///   sealed size-5 or size-6 doll, `SlotGeometry.usesTallCase`) and an iced
///   slot one `fx_ice`, built when the board is (`ResetBoard`) and always
///   drawn: they are the rest look, the doll inside included, so [nest]
///   draws nothing for them. The exception is an iced tower: its stand is
///   taller than the composition's, so the composition hides its doll and
///   [nest] draws it under the ice (m7-3 `iceTower`). While paused each replays a recorded `Picture`
///   (`LottieFxComponent.cacheRest`), re-recorded when its frame, params or
///   rasters change. Glass rests on frame 0 (the unlock symbol shows: v3's
///   `padlock_ping` starts at frame 1), ice on the `rest_n` marker of stage
///   `BoardLayout.iceFrame` (D51), also after a `crack_hit_n`.
/// - Locked and iced together: glass draws the doll and ice hides it, until
///   the unlock releases the glass.
/// - Rule 3 (§8, §10.7): when a file failed to load, the slot draws the
///   static `BoardSprites` pieces instead (the case frame and the padlock
///   symbol, the ice frame), [nest] draws the doll, and the unlock, crack or
///   shatter plays as a frame swap.
///
/// The component sits at x = the §9.3 shake offset, so everything it draws
/// shakes together; a re-pitch (§9.5) moves the compositions every frame.
///
/// **Flame mounts late.** A component added during `update` is mounted, and
/// one removed is dropped, only at the start of the next tick (§10.1 needs
/// the swap in one frame). So:
/// - a slot that isn't mounted yet is drawn by the board itself
///   (`BoardComponent`), its children included;
/// - a composition added to a mounted slot counts as drawing only once it
///   is mounted: until then the slot keeps its static stand-in and sprite;
/// - a slot the board dropped is [retire]d: it draws and updates nothing
///   from that very frame, before Flame removes it.
class SlotComponent extends PositionComponent {
  SlotComponent(this.scene, this.slot, {super.priority}) {
    add(nest);
    add(_SlotOverlay(this, priority: 2));
  }

  final BoardScene scene;
  final SlotState slot;

  /// The rest sprite (priority 0, under the compositions).
  late final NestComponent nest = NestComponent(this);

  bool _retired = false;

  /// Dropped by the board (a new level): draws nothing from now on.
  bool get retired => _retired;

  /// The paused `fx_glass_unlock` (or `_tall`) composition, while the slot is
  /// locked or unlocking.
  LottieFxComponent? get glass => _glass;
  LottieFxComponent? _glass;

  /// The paused `fx_ice` composition, while the slot is iced or shattering.
  LottieFxComponent? get ice => _ice;
  LottieFxComponent? _ice;

  // Released compositions stay mounted, inactive (drawing nothing), for the
  // next undo or restart that locks or ices the slot again: a new component
  // would only draw once Flame mounts it, a frame late, and the doll would
  // vanish for that frame.
  LottieFxComponent? _spareGlass;
  LottieFxComponent? _spareGlassTall;
  LottieFxComponent? _spareIce;

  /// The library the last [buildCompositions] used, for a composition the
  /// re-pitch swaps ([relayout]).
  FxLibrary? _library;

  /// Rule-3 stand-ins: frame bookkeeping for a missing file's frame swap.
  FxPlayer? _glassSwap;
  FxPlayer? _iceSwap;

  final FxImageRequest _symbolRequest = FxImageRequest();

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// Whether the static glass case is drawn this frame: the file is
  /// missing (a frame swap), or its composition isn't mounted yet.
  bool get drawsGlassFallback =>
      _glassSwap != null || (_glass != null && !_draws(_glass));

  /// Whether the static ice frame is drawn this frame (as the glass).
  bool get drawsIceFallback =>
      _iceSwap != null || (_ice != null && !_draws(_ice));

  /// Whether a composition draws the slot's rest look (its doll included)
  /// this frame: then [nest] draws no sprite (§8). An ice composition that
  /// hides its doll (an iced tower) leaves the doll to [nest].
  bool get compositionDraws =>
      _draws(_glass) || (_draws(_ice) && !_iceHidesDoll);

  bool get _iceHidesDoll => _ice?.drawable.images.request.hideDoll ?? false;

  /// Flame renders [component] this frame: it is mounted, or this slot
  /// isn't yet (the board draws it, and every child added to an unmounted
  /// parent is attached at once). Allocation-free.
  bool _draws(LottieFxComponent? component) =>
      component != null && (component.isMounted || !isMounted);

  // ── End of hot path. ──

  String get slotId => slot.id;

  /// The board dropped this slot (a new level): it stops drawing and
  /// updating now, and frees its compositions' pictures. Flame removes it at
  /// the next tick.
  void retire() {
    _retired = true;
    disposeCompositions();
  }

  /// Builds the slot's compositions for its current view (a new board, a
  /// restart, an undo): glass on frame 0 while locked, ice on its stage while
  /// frozen. A file [library] doesn't hold gets the static stand-in.
  void buildCompositions(FxLibrary library, {required bool reducedMotion}) {
    _library = library;
    final view = slot.view;
    // A composition the slot already has is re-rested, not rebuilt: a new
    // component would only draw once mounted, a frame late (an undo).
    if (view.locked) {
      _glassSwap = null;
      final id = _glassIdOf(slot.geometry);
      // The other file (the row re-pitched into or out of the tall case).
      final held = _glass;
      if (held != null && held.id != id) releaseComposition(held.id);
      final glass = _glass ?? _compose(library, id, reducedMotion);
      if (glass == null) {
        _glassSwap = FxPlayer.forSpec(fxSpecOf(id))..rest(0);
      } else {
        _glass = glass;
        _configure(glass, reducedMotion: reducedMotion);
        glass.rest(0);
      }
    } else {
      releaseComposition(FxId.fxGlassUnlock);
    }
    if (view.frozen) {
      _iceSwap = null;
      final frame = FxIceSegments.restFrame(
        fxSpecOf(FxId.fxIce),
        BoardLayout.iceFrame(remaining: view.ice, initial: view.iceInitial),
      );
      final ice = _ice ?? _compose(library, FxId.fxIce, reducedMotion);
      if (ice == null) {
        _iceSwap = FxPlayer.forSpec(fxSpecOf(FxId.fxIce))..rest(frame);
      } else {
        _ice = ice;
        _configure(ice, reducedMotion: reducedMotion);
        ice.rest(frame);
      }
    } else {
      releaseComposition(FxId.fxIce);
    }
    place();
  }

  /// The glass file of this slot's case: the tall one for a sealed size-5 or
  /// size-6 doll (m7-3 `layout.board.glassCaseTall`).
  static FxId _glassIdOf(SlotGeometry g) =>
      g.usesTallCase ? FxId.fxGlassUnlockTall : FxId.fxGlassUnlock;

  static bool _isGlass(FxId id) =>
      id == FxId.fxGlassUnlock || id == FxId.fxGlassUnlockTall;

  LottieFxComponent? _compose(FxLibrary library, FxId id, bool reducedMotion) {
    final spare = switch (id) {
      FxId.fxGlassUnlock => _spareGlass,
      FxId.fxGlassUnlockTall => _spareGlassTall,
      _ => _spareIce,
    };
    if (spare != null) {
      switch (id) {
        case FxId.fxGlassUnlock:
          _spareGlass = null;
        case FxId.fxGlassUnlockTall:
          _spareGlassTall = null;
        default:
          _spareIce = null;
      }
      return spare;
    }
    final drawable = FxDrawable.of(library, id);
    if (drawable == null) return null;
    final component = LottieFxComponent(drawable, cacheRest: true, priority: 1);
    _configure(component, reducedMotion: reducedMotion);
    add(component);
    return component;
  }

  void _configure(LottieFxComponent component, {required bool reducedMotion}) {
    final drawable = component.drawable;
    final view = slot.view;
    final g = slot.geometry;
    drawable.images
      ..source = scene.skin?.images
      ..request.doll = view.color
      ..request.unlockColor = view.unlockColor
      ..request.furnitureScale = g.furnitureScale
      // Locked and iced: the glass composition draws the doll (§8). An iced
      // tower's stand is taller than the composition's, so the slot's own
      // sprite draws the doll under the ice.
      ..request.hideDoll =
          component.id == FxId.fxIce &&
          (_glass != null || g.kind == SlotShapeKind.tower);
    drawable.params.reducedMotion = reducedMotion;
    FxLayout.applyDollHeights(
      drawable.params,
      drawable.spec,
      compositionScale: g.furnitureScale,
      doll: view.hasNest ? g.dollHeight(view.outerSize) : null,
      // The tall preset plays fx_ice stretched: the doll is compensated.
      stretchY: component.id == FxId.fxIce ? g.iceFxScaleY : 1,
      // A tall case in a narrow column is the case of a smaller doll.
      caseHeight: g.tallCaseHeight,
    );
  }

  /// Plays [segment] on the [fx] composition, [lateMs] into it (a hold
  /// rests on its frame: the next ice stage). [shake] false holds the ice
  /// null still (reduced motion, §13).
  void playComposition(
    FxId fx,
    FxSegment segment,
    double lateMs, {
    required bool shake,
  }) {
    final component = _isGlass(fx) ? _glass : _ice;
    if (component == null) {
      final swap = _isGlass(fx) ? _glassSwap : _iceSwap;
      swap?.start(_planOf(segment), startMs: lateMs);
      return;
    }
    component.drawable.params.reducedMotion = !shake;
    if (segment.isHold || segment.speed == 0) {
      component.rest(segment.from);
    } else {
      component.play(_planOf(segment), startMs: lateMs);
    }
  }

  static FxPlan _planOf(FxSegment segment) =>
      segment.isHold || segment.speed == 0
      ? FxPlan.rest(segment.from)
      : FxPlan(
          FxRange(segment.from, segment.to),
          speed: segment.speed,
          loop: segment.loop,
        );

  /// The [fx] composition is done (unlocked or shattered): from now on the
  /// sprite draws the doll.
  void releaseComposition(FxId fx) {
    if (_isGlass(fx)) {
      _glassSwap = null;
      final glass = _glass;
      _glass = null;
      if (glass != null) {
        // Inactive: draws nothing from this frame on; its picture is freed.
        glass.deactivate();
        if (glass.id == FxId.fxGlassUnlockTall) {
          _spareGlassTall = glass;
        } else {
          _spareGlass = glass;
        }
        // Locked and iced: the ice composition draws the doll now (§8).
        final ice = _ice;
        if (ice != null) {
          ice.drawable.images.request.hideDoll = false;
          ice.drawable.params.markChanged();
        }
      }
    } else {
      _iceSwap = null;
      final ice = _ice;
      _ice = null;
      if (ice != null) {
        ice.deactivate();
        _spareIce = ice;
      }
    }
  }

  /// Frees every composition's recorded rest picture (the game is going
  /// away). The slot draws its static stand-ins afterwards, if at all.
  void disposeCompositions() {
    _glass?.deactivate();
    _ice?.deactivate();
    _spareGlass?.deactivate();
    _spareGlassTall?.deactivate();
    _spareIce?.deactivate();
  }

  /// Points the compositions at the level's new art (a new `LevelSkin`).
  void setImageSource(FxImageSource? source) {
    _glass?.drawable.images.source = source;
    _ice?.drawable.images.source = source;
  }

  /// Re-reads the committed layout (a re-pitch's end, a resize): places the
  /// compositions and resizes their dolls.
  void relayout() {
    final reduced =
        _glass?.drawable.params.reducedMotion ??
        _ice?.drawable.params.reducedMotion ??
        false;
    final library = _library;
    var glass = _glass;
    // A re-pitch can change the case a sealed doll needs (a row of 5's
    // smaller stands make a size-4 doll tall for its case): swap the file,
    // resting on frame 0 as it is (a locked slot rests there between events).
    if (glass != null &&
        library != null &&
        glass.id != _glassIdOf(slot.geometry) &&
        slot.view.locked) {
      buildCompositions(library, reducedMotion: reduced);
      glass = _glass;
    }
    if (glass != null) _configure(glass, reducedMotion: reduced);
    final ice = _ice;
    if (ice != null) _configure(ice, reducedMotion: reduced);
    place();
  }

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// Advances playing compositions (the timeline's tick, before it
  /// dispatches: `FxCommandSink`'s protocol).
  void advance(double dtMs) {
    _glass?.advance(dtMs);
    _ice?.advance(dtMs);
    _glassSwap?.advance(dtMs);
    _iceSwap?.advance(dtMs);
  }

  /// Puts the compositions on the slot's (re-pitching) layout: glass's doll
  /// base (90, 163) on the case floor (the tall glass's stand surface
  /// (100, 212) on the stand surface), ice's ice bottom (90, 200) on the
  /// overlay's bottom, stretched on the tall preset, at the furniture scale
  /// (§8).
  void place() {
    final r = scene.repitch;
    final x = slot.centerX(r);
    final fs = slot.furnitureScale(r);
    _glass?.placeAt(x, slot.lockedDollBaseY(r), fs);
    _ice?.placeAt(
      x,
      slot.iceDollBaseY(r),
      fs,
      stretchY: slot.geometry.iceFxScaleY,
    );
  }

  @override
  void updateTree(double dt) {
    if (!_retired) super.updateTree(dt);
  }

  @override
  void update(double dt) {
    position.x = slot.shakeX;
    if (scene.repitch != null) place();
    // E.13: a tap on the sealed case pings its padlock (the composition's
    // `padlock_ping` null is scaled while it plays).
    _glass?.drawable.params.padlockPing = slot.padlockPing;
  }

  @override
  void renderTree(Canvas canvas) {
    if (!_retired) super.renderTree(canvas);
  }

  /// The glass case frame the stand-in shows: intact, cracked from 200 ms,
  /// shattered from 400 ms (tokens `motion.unlock`). Intact for a
  /// composition not mounted yet (it rests on frame 0).
  int get _glassFrame {
    final frame = _glassSwap?.frame ?? 0;
    if (frame < MotionTokens.unlockCrackedAtMs * _framesPerMs) return 0;
    if (frame < MotionTokens.unlockShatteredAtMs * _framesPerMs) return 1;
    return 2;
  }

  /// The `fx_ice` frame the stand-in shows: the frame swap's, or the rest
  /// frame of a composition not mounted yet.
  double get _iceFrame => _iceSwap?.frame ?? _ice?.drawable.player.frame ?? 0;

  // ── End of hot path. ──

  static const _framesPerMs = FxPlayer.framesPerMs;

  @override
  void onRemove() {
    disposeCompositions();
    super.onRemove();
  }
}

/// Which ice sprite the rule-3 stand-in of a missing `fx_ice` shows at a
/// frame of its frame swap (§10.7): the stage of a `crack_hit_n` segment,
/// 4 (the burst) through the shatter's frames after its first, else the
/// stage `frame ~/ 16` (a `crack_n` segment shows the stage it leaves
/// until its end). The segments are read from the spec once.
abstract final class IceStandIn {
  static final FxSpec _ice = fxSpecOf(FxId.fxIce);

  static final List<FxMarker?> _hits = List.unmodifiable([
    for (var n = 0; n < 4; n++) _ice.marker(FxIceSegments.crackHit(n)),
  ]);

  static final FxMarker? _shatter = _ice.marker(FxIceSegments.shatter);

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// The stage shown at [frame]: 0–3, or 4 for the shatter's burst.
  static int stageAt(double frame) {
    for (var n = 0; n < _hits.length; n++) {
      final hit = _hits[n];
      if (hit != null && frame >= hit.start && frame <= hit.end) return n;
    }
    final shatter = _shatter;
    if (shatter != null && frame > shatter.start && frame <= shatter.end) {
      return 4;
    }
    final stage = frame ~/ FxTiming.iceStageFrames;
    return stage < 0 ? 0 : (stage > 3 ? 3 : stage);
  }

  // ── End of hot path. ──
}

/// Above the slot's compositions: the rule-3 stand-ins of a missing glass or
/// ice file, and the ice badge (§8 z-order: composition → badge).
class _SlotOverlay extends Component {
  _SlotOverlay(this.owner, {super.priority});

  final SlotComponent owner;

  static final Paint _symbolPaint = Paint()
    ..filterQuality = FilterQuality.medium;
  static final Paint _inkDot = Paint();

  /// Flat stand-ins when even the board art is missing (the fake env).
  static final Paint _glassFallback = Paint()..color = BoardStandIns.glass;
  static final Paint _iceFallback = Paint()..color = BoardStandIns.ice;
  static final RRect _unit = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, 1, 1),
    const Radius.circular(0.1),
  );

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  void render(Canvas canvas) {
    final slot = owner.slot;
    final scene = owner.scene;
    final r = scene.repitch;
    final g = slot.geometry;
    // Pieces are drawn at the committed layout, moved by the re-pitch.
    final dx = slot.centerX(r) - g.centerX;
    final sprites = scene.sprites;
    if (owner.drawsGlassFallback) {
      final sprite = sprites?.forSlot(
        g.usesTallCase
            ? BoardSprite.glassCaseTall(owner._glassFrame)
            : BoardSprite.glassCase(owner._glassFrame),
        g,
      );
      final rect = g.glassCaseRect;
      if (sprite != null) {
        SpriteDraw.box(
          canvas,
          sprite,
          rect.left + dx,
          rect.top,
          rect.width,
          rect.height,
        );
      } else {
        _flat(canvas, rect, dx, _glassFallback);
      }
      if (owner._glassFrame < 2) _padlock(canvas, g, dx);
    }
    if (owner.drawsIceFallback) {
      // Stage n rests on 16n and a crack_hit_n keeps it; the shatter's
      // first frame (48) flashes stage 3, then the burst.
      final stage = IceStandIn.stageAt(owner._iceFrame);
      final sprite = sprites?.forSlot(
        stage == 4 ? BoardSprite.iceShatter : BoardSprite.ice(stage),
        g,
      );
      final rect = g.iceRect;
      if (sprite != null) {
        SpriteDraw.box(
          canvas,
          sprite,
          rect.left + dx,
          rect.top,
          rect.width,
          rect.height,
        );
      } else {
        _flat(canvas, rect, dx, _iceFallback);
      }
    }
    if (slot.decor.hasBadge) {
      slot.decor.paintBadge(
        canvas,
        slot.badgeX(r),
        slot.badgeY(r),
        slot.badgeBump,
      );
    }
  }

  void _flat(Canvas canvas, Rect rect, double dx, Paint paint) {
    canvas
      ..save()
      ..translate(rect.left + dx, rect.top)
      ..scale(rect.width, rect.height)
      ..drawRRect(_unit, paint)
      ..restore();
  }

  /// The unlock colour's symbol on the padlock (NestyBoard:169), from the
  /// skin's unlock-symbol raster, or an ink dot without one.
  void _padlock(Canvas canvas, SlotGeometry g, double dx) {
    final color = owner.slot.view.unlockColor;
    if (color == null) return;
    final center = g.padlockSymbolCenter;
    final side = g.padlockSymbolSize;
    final request = owner._symbolRequest
      ..unlockColor = color
      ..furnitureScale = g.furnitureScale;
    final raster = owner.scene.skin?.images.rasterFor(
      FxImageSlot.unlockSymbol,
      request,
    );
    // E.13: the padlock's ping scales the symbol about its centre.
    final ping = owner.slot.padlockPing;
    canvas
      ..save()
      ..translate(center.dx + dx, center.dy)
      ..scale(ping)
      ..translate(-side / 2, -side / 2);
    if (raster == null) {
      _inkDot.color = DollPalette.of(color).ink;
      canvas
        ..translate(side / 2, side / 2)
        ..drawCircle(Offset.zero, side * 0.3, _inkDot);
    } else {
      // The raster's scale and origin count in the symbol's 12-unit box,
      // whatever its own pixel size.
      final box = FxImageSlot.unlockSymbol.declaredWidth;
      canvas
        ..scale(side / box)
        ..translate(raster.origin.dx, raster.origin.dy)
        ..scale(1 / raster.scale)
        ..drawImage(raster.image, Offset.zero, _symbolPaint);
    }
    canvas.restore();
  }

  // ── End of hot path. ──
}
