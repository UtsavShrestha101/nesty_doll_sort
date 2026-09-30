import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_placement.dart';

/// Why a clip plays. The board uses it to pick a z-order and, for
/// [selection], to find the lifted doll that follows the finger while it is
/// dragged; tests use it to find clips.
enum FxClipPurpose {
  /// `doll_pick` on the selected slot: lift, then wobble (or hold), then
  /// settle.
  selection,

  /// `fx_select_glow` under the selected slot.
  selectionGlow,

  /// `doll_move`: a flight, a drag cancel or a drag-invalid return.
  move,

  /// `doll_nest` or `doll_swallow` on the target.
  nest,

  /// `doll_complete`: the shine, hops and the fly to the counter.
  complete,

  /// `doll_invalid`.
  invalid,

  /// `doll_reveal` on a tower's new top.
  reveal,

  /// `fx_dust_puff` where a completed set took off.
  dust,

  /// `fx_sparkle` on the completion's trail.
  sparkle,

  /// `ui_hint_arrow` over the hint's source.
  hintArrow,

  /// `fx_select_glow` under the hint's target.
  hintGlow,

  /// `fx_select_glow` at 60 % under the legal stand a dragged doll is over
  /// (E.14, `motion.dragHover`).
  hoverGlow,

  /// `ui_extra_slot`, the pulsing stand of an extra slot.
  extraSlot,
}

/// One pooled board clip: which file, where, with what parameters, and
/// which slots' top-doll sprites it draws while it lives
/// (docs/plans/m2-lottie-design.md §7, §10).
///
/// Immutable. [id] names it in later commands (`PlayClipSegment`,
/// `PlaceClip`, `ReleaseClipSlots`, `StopClip`); the board maps it to a
/// `LottieFxComponent` from the file's pool.
final class FxClip {
  const FxClip({
    required this.id,
    required this.fx,
    required this.purpose,
    required this.placement,
    this.params = FxClipParams.none,
    this.slotId,
    this.anchor,
    this.anchorSize = 1,
    this.hides = const [],
  });

  /// Unique for the timeline's lifetime.
  final int id;

  final FxId fx;

  final FxClipPurpose purpose;

  /// Where it starts. A `PlaceClip` may move it later.
  final FxPlacement placement;

  final FxClipParams params;

  /// The slot it belongs to (the selected, moving, target, completing or
  /// revealed slot), or null for a clip that belongs to none.
  final String? slotId;

  /// For an in-place clip on [slotId]: the slot point its placement came
  /// from, so the board can re-place it on another layout (re-pitch lerp).
  final FxAnchor? anchor;

  /// The doll size [anchor] was resolved for ([FxAnchor.hintArrow]).
  final int anchorSize;

  /// Slots whose top-doll sprite this clip draws: the board hides each of
  /// them (counted, since two clips can draw one slot in the same frame)
  /// from the clip's start until its `ReleaseClipSlots` or `StopClip`
  /// (§10.1 same-frame swap). A clip that never starts (its file failed to
  /// load, or its pool is exhausted) hides nothing.
  final List<String> hides;

  @override
  String toString() =>
      'FxClip#$id(${fx.fileName}, ${purpose.name}'
      '${slotId == null ? '' : ' @$slotId'})';
}
