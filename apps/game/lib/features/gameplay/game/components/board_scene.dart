import 'package:nesty_core/nesty_core.dart' show Move;
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_decor.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_view.dart';
import 'package:nesty_game/features/gameplay/game/timeline/hand_tween.dart';
import 'package:nesty_render/nesty_render.dart';

/// One slot as the board draws it right now: its layout (and the one a
/// re-pitch comes from), what it shows at rest, how many clips and tweens
/// hide its top sprite, and the hand-coded motions acting on it
/// (docs/plans/m2-lottie-design.md §9, §10). Mutated by the board's command
/// sink per event; read by the components every frame.
final class SlotState {
  SlotState(this.id, this.geometry);

  final String id;

  /// The committed layout: the re-pitch's target while one runs.
  SlotGeometry geometry;

  /// The layout a running re-pitch started from; null otherwise, and for
  /// the slot the re-pitch adds.
  SlotGeometry? from;

  /// What the slot shows at rest, as of its last `SyncSlot`.
  SlotView view = SlotView.empty;

  /// The "+N" tag and the ice badge, laid out for [view].
  final SlotDecor decor = SlotDecor();

  int _hides = 0;

  /// Live `ui_extra_slot` clips on this stand: the static stand isn't drawn
  /// while one pulses in its place.
  int pulses = 0;

  /// §9.3: the hand-coded shake of a locked, iced or tower target.
  ShakeTween? shake;

  /// §9.1: the tower's new top dropping onto the stand.
  RevealDropTween? reveal;

  /// Whether a clip or tween draws this slot's top doll now (§10.1).
  bool get spriteHidden => _hides > 0;

  int get hideCount => _hides;

  void hide() => _hides++;

  void show() {
    if (_hides > 0) _hides--;
  }

  void clearHides() => _hides = 0;

  /// Shows [view] from now on and lays its tag and badge out.
  void setView(SlotView view) {
    this.view = view;
    _layoutDecor();
  }

  /// Commits [geometry] (a new layout, or a re-pitch's end).
  void setGeometry(SlotGeometry geometry) {
    this.geometry = geometry;
    from = null;
    _layoutDecor();
  }

  void _layoutDecor() {
    final g = geometry;
    decor
      ..setTag(view.buried.length, g.furnitureScale)
      ..setBadge(view.ice, g.furnitureScale, g.iceBadgeRect.width);
  }

  void dispose() => decor.dispose();

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// The horizontal shake now, in logical px (0 when still).
  double get shakeX => shake?.offsetX ?? 0;

  double _lerp(RepitchTween? r, double? a, double b) =>
      r == null || a == null ? b : r.lerp(a, b);

  double centerX(RepitchTween? r) => _lerp(r, from?.centerX, geometry.centerX);

  double surfaceY(RepitchTween? r) =>
      _lerp(r, from?.surfaceY, geometry.surfaceY);

  double lockedDollBaseY(RepitchTween? r) =>
      _lerp(r, from?.lockedDollBaseY, geometry.lockedDollBaseY);

  /// Where the top doll stands: on the case floor while the view is still
  /// locked, else on the stand (§8).
  double restBaseY(RepitchTween? r) =>
      view.locked ? lockedDollBaseY(r) : surfaceY(r);

  double furnitureScale(RepitchTween? r) =>
      _lerp(r, from?.furnitureScale, geometry.furnitureScale);

  double dollHeight(int size, RepitchTween? r) =>
      _lerp(r, from?.dollHeight(size), geometry.dollHeight(size));

  double standLeft(RepitchTween? r) =>
      _lerp(r, from?.standRect.left, geometry.standRect.left);

  double standTop(RepitchTween? r) =>
      _lerp(r, from?.standRect.top, geometry.standRect.top);

  double standWidth(RepitchTween? r) =>
      _lerp(r, from?.standRect.width, geometry.standRect.width);

  double standHeight(RepitchTween? r) =>
      _lerp(r, from?.standRect.height, geometry.standRect.height);

  double pipCenterY(RepitchTween? r) =>
      _lerp(r, from?.pipCenterY, geometry.pipCenterY);

  /// Centre x of pip [position] (0 = leftmost = the biggest size).
  double pipCenterX(int position, RepitchTween? r) =>
      _lerp(r, from?.pipCenterX(position), geometry.pipCenterX(position));

  double tagX(RepitchTween? r) =>
      _lerp(r, from?.towerTagOrigin.dx, geometry.towerTagOrigin.dx);

  double tagY(RepitchTween? r) =>
      _lerp(r, from?.towerTagOrigin.dy, geometry.towerTagOrigin.dy);

  /// The ice badge's centre.
  double badgeX(RepitchTween? r) => _lerp(
    r,
    from == null
        ? null
        : from!.iceBadgeRect.left + from!.iceBadgeRect.width / 2,
    geometry.iceBadgeRect.left + geometry.iceBadgeRect.width / 2,
  );

  double badgeY(RepitchTween? r) => _lerp(
    r,
    from == null
        ? null
        : from!.iceBadgeRect.top + from!.iceBadgeRect.height / 2,
    geometry.iceBadgeRect.top + geometry.iceBadgeRect.height / 2,
  );

  /// Base y of the buried nest at [depth] at rest (D21, the spacing of the
  /// tower's starting depth).
  double buriedBaseY(int depth, RepitchTween? r) => _lerp(
    r,
    from?.buriedBaseY(depth, buried: view.buriedAtStart),
    geometry.buriedBaseY(depth, buried: view.buriedAtStart),
  );

  // ── End of hot path. ──

  @override
  String toString() => 'SlotState($id, $view)';
}

/// Everything the board's components draw from, shared by all of them: the
/// layout, the slots, the level's art and the rule-3 fallbacks for files
/// that failed to load (docs/plans/m2-lottie-design.md §10.7). The board's
/// command sink writes it per event; the components read it every frame.
final class BoardScene {
  BoardScene({required this.isAvailable});

  /// Whether a Lottie file is loaded (`FxLibrary[id] != null`): a missing
  /// file draws its static fallback instead (rule 3).
  final bool Function(FxId id) isAvailable;

  /// The committed layout (the re-pitch's target while one runs); null
  /// before the first level.
  BoardGeometry? geometry;

  /// §9.5: the +1 Slot re-pitch running now.
  RepitchTween? repitch;

  /// The level's art; null until the page hands one over.
  LevelSkin? skin;

  /// Belly symbols for the placeholder painter (part rasters bake theirs).
  DollSymbols symbols = DollSymbols.subtle;

  PlaceholderDollPainter? _placeholder;

  /// Draws rest sprites: the skin's part rasters, or the procedural
  /// placeholder (spec §12.5) until a skin arrives (rule 3).
  DollRenderer get renderer =>
      skin?.restRenderer ?? (_placeholder ??= PlaceholderDollPainter());

  BoardSprites? get sprites => skin?.sprites;

  /// Slots in layout order (row-major, extras last).
  final List<SlotState> slots = [];
  final Map<String, SlotState> _byId = {};

  /// The slot with [id], or null.
  SlotState? slot(String id) => _byId[id];

  /// Adds (or replaces) [state].
  void addSlot(SlotState state) {
    final old = _byId[state.id];
    if (old != null) {
      slots.remove(old);
      old.dispose();
    }
    _byId[state.id] = state;
    slots.add(state);
  }

  /// Drops every slot.
  void clearSlots() {
    for (final slot in slots) {
      slot.dispose();
    }
    slots.clear();
    _byId.clear();
  }

  /// Sorts [slots] by [geometry]'s order.
  void sortSlots() {
    final g = geometry;
    if (g == null) return;
    slots.sort(
      (a, b) => (g.slotOrNull(a.id)?.index ?? 1 << 20).compareTo(
        g.slotOrNull(b.id)?.index ?? 1 << 20,
      ),
    );
  }

  // Updated by the board every tick from the timeline (no allocation).

  /// The slot whose nest is lifted (the timeline's selection).
  String? selectedSlotId;

  /// The hint on screen, for the static fallbacks of its arrow and glow.
  Move? hint;

  /// The slot a drag is holding, and where the dragged doll's base is now
  /// (clamped to the board frame).
  String? dragSlotId;
  double dragBaseX = 0;
  double dragBaseY = 0;

  void dispose() {
    clearSlots();
    _placeholder?.dispose();
    _placeholder = null;
  }
}
