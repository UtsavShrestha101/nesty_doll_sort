import 'package:flame/components.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_pool.dart';
import 'package:nesty_game/features/fx/lottie_fx_component.dart';
import 'package:nesty_game/features/gameplay/game/components/board_scene.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_clip.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_command.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_placement.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_segment.dart';
import 'package:nesty_game/features/gameplay/game/timeline/hand_tween.dart';
import 'package:nesty_render/nesty_render.dart';

/// The board's pooled Lottie clips (docs/plans/m2-lottie-design.md §2, §5,
/// §14): one fixed `FxPool` of `LottieFxComponent`s per board file, built
/// once when the library is loaded, never per event. It executes the
/// timeline's clip commands (`StartClip`, `PlayClipSegment`, `PlaceClip`,
/// `ReleaseClipSlots`, `StopClip`) and hides and shows the slots' sprites
/// they draw (§10.1).
///
/// Placement goes through `BoardFit` (§5): board-space files lay the 390×844
/// reference screen over the board, in-place files put their anchor on the
/// game point at `s` (doll files, sparkles) or `fs` (board pieces), and a
/// sparkle sits on the completing set's captured travel point.
///
/// Z-order: the glow rings and the pulsing extra stand live in [underlay]
/// (under the dolls, over the stands); everything else draws in this layer,
/// above the slots, by file ([priorityOf]).
///
/// The components are driven explicitly: [advance] runs in the board's tick
/// before the timeline dispatches, so a clip starts in the frame its sprite
/// hides and is never advanced twice in its first frame.
class FxLayer extends Component {
  FxLayer(this.scene, {super.priority, int underlayPriority = 0})
    : underlay = Component(priority: underlayPriority);

  final BoardScene scene;

  /// The glow rings and extra-slot stands: the board mounts it under the
  /// slots.
  final Component underlay;

  /// The board files (`FxHost.board`) this layer pools; `fx_glass_unlock`
  /// and `fx_ice` belong to their slots (§8).
  static const pooled = [
    FxId.dollPick,
    FxId.dollMove,
    FxId.dollNest,
    FxId.dollSwallow,
    FxId.dollComplete,
    FxId.dollInvalid,
    FxId.dollReveal,
    FxId.fxSelectGlow,
    FxId.fxDustPuff,
    FxId.fxSparkle,
    FxId.uiHintArrow,
    FxId.uiExtraSlot,
  ];

  /// Whether [id] draws under the dolls ([underlay]).
  static bool isUnder(FxId id) =>
      id == FxId.fxSelectGlow || id == FxId.uiExtraSlot;

  /// A file's z-order inside its container: dolls on their slots, then
  /// dust, then the flights, then the particles and the hint arrow.
  static int priorityOf(FxId id) => switch (id) {
    FxId.uiExtraSlot => 0,
    FxId.fxSelectGlow => 1,
    FxId.dollReveal || FxId.dollNest || FxId.dollSwallow => 10,
    FxId.dollPick => 12,
    FxId.fxDustPuff => 15,
    FxId.dollInvalid => 20,
    FxId.dollMove => 25,
    FxId.dollComplete => 30,
    FxId.fxSparkle => 35,
    FxId.uiHintArrow => 40,
    _ => 50,
  };

  final List<FxPool<LottieFxComponent>?> _pools = List.filled(
    FxId.values.length,
    null,
  );

  final List<_LiveClip> _live = [];
  final Map<int, _LiveClip> _byClip = {};

  /// Whether [id] has a pool: its clips can play (the timeline's
  /// `isAvailable`, so the two agree on what is skipped). Allocation-free.
  bool hasPool(FxId id) => _pools[id.index] != null;

  /// The pool sizes, for the timeline (they equal §14's).
  static Map<FxId, int> get poolSizes => {
    for (final id in pooled) id: FxPoolSizes.of(id),
  };

  /// Builds the pool of every loaded board file that has none yet (at board
  /// build; again when the library finishes loading later). Mounts every
  /// pooled component: an idle one neither updates nor draws.
  void buildPools(FxLibrary library) {
    for (final id in pooled) {
      if (_pools[id.index] != null) continue;
      final pool = LottieFxComponent.pool(
        library,
        id,
        priority: priorityOf(id),
      );
      if (pool == null) continue;
      _pools[id.index] = pool;
      final container = isUnder(id) ? underlay : this;
      for (var i = 0; i < pool.capacity; i++) {
        container.add(pool[i]);
      }
    }
  }

  /// The component playing [clipId], or null (never started, or stopped).
  LottieFxComponent? componentOf(int clipId) => _byClip[clipId]?.component;

  /// The live clips, in start order (for tests).
  @visibleForTesting
  List<FxClip> get liveClips => [for (final live in _live) live.clip];

  /// The pool of [id], for tests.
  @visibleForTesting
  FxPool<LottieFxComponent>? poolOf(FxId id) => _pools[id.index];

  // ── Commands (per event). ──

  /// `StartClip`: takes a component from the file's pool (skipped when the
  /// file has none or the pool is exhausted, §14), configures and places
  /// it, plays [StartClip.segment] [lateMs] in and hides `clip.hides`.
  void start(StartClip command, double lateMs, BoardGeometry geometry) {
    final clip = command.clip;
    final pool = _pools[clip.fx.index];
    if (pool == null || _byClip.containsKey(clip.id)) return;
    final component = pool.acquire();
    if (component == null) return;
    _configure(component, clip.fx, clip.params, clip.slotId, geometry);
    // A flight that takes over from a wobbling doll starts at its tilt
    // (m7-5 item 14): the pick clip is still live in this frame.
    final unwindOf = clip.params.unwindOf;
    if (unwindOf != null) {
      final tilt = _byClip[unwindOf]?.component.drawable.params.pickRotation;
      component.drawable.params.unwindFrom = tilt == null || tilt == 0
          ? null
          : tilt;
    }
    _place(component, clip.placement, geometry);
    _play(component, command.segment, lateMs + command.phaseMs);
    final live = _LiveClip(clip, component, pool);
    _live.add(live);
    _byClip[clip.id] = live;
    for (final slotId in clip.hides) {
      scene.slot(slotId)?.hide();
    }
    live.hiding = clip.hides.isNotEmpty;
    if (clip.purpose == FxClipPurpose.extraSlot) {
      scene.slot(clip.slotId ?? '')?.pulses++;
    }
  }

  /// `PlayClipSegment`: the live clip switches segment.
  void play(PlayClipSegment command, double lateMs) {
    final live = _byClip[command.clip.id];
    if (live == null) return;
    _play(live.component, command.segment, lateMs);
  }

  /// `PlaceClip`: the layout changed under the live clip.
  void place(PlaceClip command, BoardGeometry geometry) {
    final live = _byClip[command.clip.id];
    if (live == null) return;
    final clip = live.clip;
    _configure(live.component, clip.fx, command.params, clip.slotId, geometry);
    _place(live.component, command.placement, geometry);
  }

  /// `ReleaseClipSlots`: the clip no longer draws its slots' dolls.
  void releaseSlots(ReleaseClipSlots command) {
    final live = _byClip[command.clip.id];
    if (live == null || !live.hiding) return;
    live.hiding = false;
    for (final slotId in live.clip.hides) {
      scene.slot(slotId)?.show();
    }
  }

  /// `StopClip`: back to its pool; its slots show their sprites again.
  void stop(StopClip command) {
    final live = _byClip.remove(command.clip.id);
    if (live == null) return;
    _live.remove(live);
    if (live.hiding) {
      for (final slotId in live.clip.hides) {
        scene.slot(slotId)?.show();
      }
    }
    if (live.clip.purpose == FxClipPurpose.extraSlot) {
      final slot = scene.slot(live.clip.slotId ?? '');
      if (slot != null && slot.pulses > 0) slot.pulses--;
    }
    live.pool.release(live.component);
  }

  /// Every clip back to its pool (a board reset); the caller clears the
  /// slots' hides and pulses.
  void stopAll() {
    for (final live in _live) {
      live.pool.release(live.component);
    }
    _live.clear();
    _byClip.clear();
  }

  /// Points every pooled component at the level's new art.
  void setImageSource(FxImageSource? source) {
    for (final pool in _pools) {
      if (pool == null) continue;
      for (var i = 0; i < pool.capacity; i++) {
        pool[i].drawable.images.source = source;
      }
    }
  }

  void _configure(
    LottieFxComponent component,
    FxId fx,
    FxClipParams p,
    String? slotId,
    BoardGeometry geometry,
  ) {
    final drawable = component.drawable;
    final slot = slotId == null ? null : geometry.slotOrNull(slotId);
    drawable.images
      ..source = scene.skin?.images
      ..request.doll = p.doll
      ..request.mover = p.mover
      ..request.target = p.target
      ..request.hideMover = p.hideMover
      ..request.hideTarget = p.hideTarget
      ..request.furnitureScale = slot?.furnitureScale ?? 1;
    final params = drawable.params;
    for (final role in drawable.spec.roles) {
      params.setSize(role, switch (role) {
        FxRole.doll => p.dollScale,
        FxRole.mover => p.moverScale,
        FxRole.target => p.targetScale,
        // The intro loops' roles author their own sizes (their FxSpec lists
        // no roles), and never play on the board.
        FxRole.revealed ||
        FxRole.family ||
        FxRole.family2 ||
        FxRole.freed => null,
      });
    }
    if (drawable.spec.travel != null) {
      params.setTravel(p.travelFrom, p.travelTo);
    }
    final rim = p.rim;
    final tint = p.tint;
    params
      ..targetPos = p.targetPos
      ..rimColor = rim == null ? null : DollPalette.of(rim).rimColor
      ..tintColor = tint == null ? null : DollPalette.of(tint).base
      // doll_reveal's drop starts on the tower's own step (§9.1).
      ..revealDropUnits = p.revealDrop
      // Reduced motion holds doll_invalid's target shake (§13).
      ..reducedMotion = !p.shake;
    // The drag hover's glow is dimmed (E.14).
    component.opacity = p.opacity;
  }

  void _place(
    LottieFxComponent component,
    FxPlacement placement,
    BoardGeometry geometry,
  ) {
    switch (placement.space) {
      case FxSpace.inPlace || FxSpace.boardSpace:
        // A board-space file's anchor is its top-left (§5).
        component.placeAt(placement.x, placement.y, placement.scale);
      case FxSpace.trail:
        // §6 "Sparkle trail": the completing set's remapped travel point,
        // captured in reference units by its last draw.
        final source = _byClip[placement.trailOf ?? -1]?.component;
        final params = source?.drawable.params;
        final point = params?.trailPoint ?? params?.travelSrc;
        final fit = geometry.fit;
        if (point == null) {
          component.placeAt(fit.frame.center.dx, fit.frame.top, 0);
        } else {
          component.placeAt(fit.x(point.dx), fit.y(point.dy), placement.scale);
        }
    }
  }

  static void _play(
    LottieFxComponent component,
    FxSegment segment,
    double lateMs,
  ) {
    if (segment.isHold || segment.speed == 0) {
      component.rest(segment.from);
      return;
    }
    component.play(
      FxPlan(
        FxRange(segment.from, segment.to),
        speed: segment.speed,
        loop: segment.loop,
      ),
      startMs: lateMs,
    );
  }

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// Advances every live clip by [dtMs].
  void advance(double dtMs) {
    for (var i = 0; i < _live.length; i++) {
      _live[i].component.advance(dtMs);
    }
  }

  /// §9.5: while the bottom row re-pitches, every live clip anchored on a
  /// slot moves with it (the lerp of its anchor on both layouts).
  void followRepitch(RepitchTween repitch) {
    for (var i = 0; i < _live.length; i++) {
      final live = _live[i];
      final clip = live.clip;
      final anchor = clip.anchor;
      final slotId = clip.slotId;
      if (anchor == null || slotId == null) continue;
      if (clip.placement.space != FxSpace.inPlace) continue;
      final from = repitch.from.slotOrNull(slotId);
      final to = repitch.to.slotOrNull(slotId);
      if (from == null || to == null) continue;
      final size = clip.anchorSize;
      live.component.placeAt(
        repitch.lerp(anchor.xIn(from, size: size), anchor.xIn(to, size: size)),
        repitch.lerp(anchor.yIn(from, size: size), anchor.yIn(to, size: size)),
        repitch.lerp(
          anchor.scaleIn(repitch.from, from),
          anchor.scaleIn(repitch.to, to),
        ),
      );
    }
  }

  // ── End of hot path. ──
}

final class _LiveClip {
  _LiveClip(this.clip, this.component, this.pool);

  final FxClip clip;
  final LottieFxComponent component;
  final FxPool<LottieFxComponent> pool;

  /// Still hiding `clip.hides` (until `ReleaseClipSlots` or `StopClip`).
  bool hiding = false;
}
