import 'dart:ui';

import 'package:flame/components.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/game/components/board_scene.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_component.dart';
import 'package:nesty_render/nesty_render.dart';

/// One slot's rest sprite: the top nest's outer doll, drawn by the level's
/// `LevelSkin.restRenderer` (`PartRasterDollRenderer`) from the same part
/// rasters and with the same transform as the Lottie image slots
/// (docs/plans/m2-lottie-design.md §4, §10.2), so a clip's first and last
/// frames equal this sprite and the hand-off never jumps.
///
/// It draws nothing while:
/// - a clip or tween draws the doll ([SlotState.spriteHidden], counted per
///   clip, §10.1: hidden in the same `update` a clip starts and shown in the
///   one it ends, before any render);
/// - the slot's paused glass or ice composition is its rest look (§8)
///   (`SlotComponent.compositionDraws`: only once Flame renders it, so a
///   composition mounting a tick late never leaves the slot empty).
///
/// Rule 3 (§10.7): without `doll_pick` the selected nest is drawn lifted
/// (14 dp, ×1.05, NestyBoard:179), and while dragged at the finger.
///
/// Lives under its `SlotComponent`, whose position carries the §9.3 shake.
class NestComponent extends Component {
  NestComponent(this.owner, {super.priority})
    : scene = owner.scene,
      slot = owner.slot;

  /// The slot this sprite belongs to (its compositions decide whether the
  /// sprite draws).
  final SlotComponent owner;

  final BoardScene scene;
  final SlotState slot;

  final DollPaintParams _params = DollPaintParams();

  /// Whether the sprite draws this frame (for tests).
  bool get isDrawn {
    final view = slot.view;
    return view.hasNest &&
        !slot.spriteHidden &&
        !owner.compositionDraws &&
        view.outerSize <= slot.geometry.pipCount;
  }

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  void render(Canvas canvas) {
    if (!isDrawn) return;
    final view = slot.view;
    final r = scene.repitch;
    final s = scene.geometry?.scale ?? 1;
    var x = slot.centerX(r);
    var baseY = slot.restBaseY(r);
    var scale = 1.0;
    if (scene.selectedSlotId == slot.id && !scene.isAvailable(FxId.dollPick)) {
      scale = MotionTokens.pickScale;
      if (scene.dragSlotId == slot.id) {
        x = scene.dragBaseX;
        baseY = scene.dragBaseY;
      }
      baseY -= MotionTokens.pickLift * s;
    }
    _params
      ..reset()
      ..color = view.color!
      ..height = slot.dollHeight(view.outerSize, r)
      ..baseX = x
      ..baseY = baseY
      ..scaleX = scale
      ..scaleY = scale
      ..symbols = scene.symbols;
    scene.renderer.paint(canvas, _params);
  }

  // ── End of hot path. ──
}
