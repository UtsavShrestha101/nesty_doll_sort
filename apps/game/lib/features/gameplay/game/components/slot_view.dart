import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:nesty_core/nesty_core.dart';

/// What one slot shows at rest, read from nesty_core's state at a
/// `SyncSlot` or `ResetBoard` (docs/plans/m2-lottie-design.md §7, §10): the
/// top nest, the tower's buried nests, the lock and the ice. The Flame board
/// renders it and never decides it (CLAUDE.md rules 2 and 10).
///
/// Built per event, never per frame.
@immutable
final class SlotView {
  const SlotView({
    this.color,
    this.outerSize = 0,
    this.innerSize = 0,
    this.buried = const [],
    this.buriedAtStart = 0,
    this.towerSizeAtStart = 0,
    this.unlockColor,
    this.ice = 0,
    this.iceInitial = 0,
  });

  /// [slotId] of [state]; [empty] for a slot the state doesn't have.
  factory SlotView.of(GameState state, String slotId) {
    if (!state.slotIds.contains(slotId)) return empty;
    final slot = state.slot(slotId);
    final initial = SlotId.isExtra(slotId) ? null : state.level.slot(slotId);
    final top = switch (slot) {
      OpenSlot(:final nest) => nest,
      TowerSlot(:final top) => top,
      LockedSlot(:final nest) => nest,
    };
    final buried = <int>[
      if (slot is TowerSlot)
        // Depth 1 is right under the top (spec §3.2, D21).
        for (var i = slot.stack.length - 2; i >= 0; i--)
          slot.stack[i].outerSize,
    ];
    final initialIce = initial?.ice ?? 0;
    return SlotView(
      color: top?.color,
      outerSize: top?.outerSize ?? 0,
      innerSize: top?.innerSize ?? 0,
      buried: List.unmodifiable(buried),
      buriedAtStart: initial is TowerSlot ? initial.hiddenCount : 0,
      towerSizeAtStart: initial is TowerSlot ? _tallest(initial) : 0,
      unlockColor: slot is LockedSlot ? slot.unlockColor : null,
      ice: slot.ice,
      iceInitial: initialIce < slot.ice ? slot.ice : initialIce,
    );
  }

  static const empty = SlotView();

  /// The biggest outer size among a tower's nests at the start of the level.
  static int _tallest(TowerSlot tower) {
    var size = 0;
    for (final nest in tower.stack) {
      if (nest.outerSize > size) size = nest.outerSize;
    }
    return size;
  }

  /// The top nest's colour; null for an empty slot.
  final DollColor? color;

  /// The top nest's outer (drawn) doll size and its innermost size: the pip
  /// bar fills `innerSize…outerSize` (spec §10.3).
  final int outerSize;
  final int innerSize;

  /// A tower's buried nests, the outer size of each, depth 1 (right under
  /// the top) first. Drawn as true-size wood silhouettes (D21).
  final List<int> buried;

  /// The nests the tower buried when the level started: the silhouette
  /// spacing (`SlotGeometry.buriedBaseY(depth, buried:)`) stays put as it
  /// empties (review RENDER-4).
  final int buriedAtStart;

  /// The tallest outer size among the nests the tower held when the level
  /// started (0 for a slot that isn't a tower): the tower stack's `topSize`
  /// (`SlotGeometry.towerStack`), so the silhouette step stays put as the
  /// tower empties and never lets a revealed taller nest reach the limit.
  final int towerSizeAtStart;

  /// Set while the slot is still a `LockedSlot`: its doll stands on the
  /// case floor and the padlock shows this colour's symbol.
  final DollColor? unlockColor;

  /// Remaining ice (spec §3.4); 0 for none.
  final int ice;

  /// The ice the slot started the level with (`BoardLayout.iceFrame`).
  final int iceInitial;

  bool get hasNest => color != null && outerSize > 0;

  bool get locked => unlockColor != null;

  bool get frozen => ice > 0;

  /// Whether the pip for doll [size] is filled.
  bool fills(int size) => hasNest && size >= innerSize && size <= outerSize;

  @override
  bool operator ==(Object other) =>
      other is SlotView &&
      other.color == color &&
      other.outerSize == outerSize &&
      other.innerSize == innerSize &&
      listEquals(other.buried, buried) &&
      other.buriedAtStart == buriedAtStart &&
      other.towerSizeAtStart == towerSizeAtStart &&
      other.unlockColor == unlockColor &&
      other.ice == ice &&
      other.iceInitial == iceInitial;

  @override
  int get hashCode => Object.hash(
    color,
    outerSize,
    innerSize,
    Object.hashAll(buried),
    buriedAtStart,
    towerSizeAtStart,
    unlockColor,
    ice,
    iceInitial,
  );

  @override
  String toString() =>
      'SlotView(${color?.id ?? 'empty'} $innerSize–$outerSize'
      '${buried.isEmpty ? '' : ', buried $buried'}'
      '${locked ? ', locked ${unlockColor!.id}' : ''}'
      '${frozen ? ', ice $ice/$iceInitial' : ''})';
}
