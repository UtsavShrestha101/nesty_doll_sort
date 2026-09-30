import 'package:nesty_core/nesty_core.dart';

/// What a board looks like before a single doll is read: the shelves and
/// their slots, the towers and their depths, the glass cases, the iced
/// slots, how many colors and how tall the dolls are (brainstorm §3 E12).
///
/// Two consecutive levels with the same signature read as a reskin of one
/// another, so `bundle check` rejects them outside the tutorial
/// (`BundlePolicy.checkVariety`). Which colors are used, where the towers
/// stand and how the sets are cut are left out on purpose: changing only
/// those is exactly the reskin the gate is there to catch.
final class LayoutSignature {
  LayoutSignature({
    required List<int> rows,
    required List<int> towerDepths,
    required this.locked,
    required this.iced,
    required this.colors,
    required this.maxSize,
  }) : rows = List.unmodifiable(rows),
       towerDepths = List.unmodifiable(List.of(towerDepths)..sort());

  /// The signature of [level].
  factory LayoutSignature.of(Level level) {
    final towerDepths = <int>[];
    final colors = <DollColor>{};
    var locked = 0;
    var iced = 0;
    for (final shelf in level.shelves) {
      for (final slot in shelf) {
        if (slot is TowerSlot) towerDepths.add(slot.stack.length);
        if (slot is LockedSlot) locked++;
        if (slot.ice > 0) iced++;
        for (final nest in slot.nests) {
          for (final doll in nest.dolls) {
            if (!doll.color.isWild) colors.add(doll.color);
          }
        }
      }
    }
    return LayoutSignature(
      rows: [for (final shelf in level.shelves) shelf.length],
      towerDepths: towerDepths,
      locked: locked,
      iced: iced,
      colors: colors.length,
      maxSize: level.maxSize,
    );
  }

  /// Slots per shelf, top to bottom (the shelves are its length).
  final List<int> rows;

  /// Each tower's starting depth, smallest first (the towers are its
  /// length).
  final List<int> towerDepths;

  /// Glass cases (spec §3.3).
  final int locked;

  /// Slots with ice (spec §3.4), whatever their counters.
  final int iced;

  /// Distinct doll colors, gold excluded.
  final int colors;

  final int maxSize;

  @override
  bool operator ==(Object other) =>
      other is LayoutSignature &&
      _sameInts(other.rows, rows) &&
      _sameInts(other.towerDepths, towerDepths) &&
      other.locked == locked &&
      other.iced == iced &&
      other.colors == colors &&
      other.maxSize == maxSize;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(rows),
    Object.hashAll(towerDepths),
    locked,
    iced,
    colors,
    maxSize,
  );

  /// `shelves 3,4,3 · towers 3,3,4 · glass 1 · ice 0 · 5 colors · maxSize 4`.
  @override
  String toString() =>
      'shelves ${rows.join(',')} · towers '
      '${towerDepths.isEmpty ? 'none' : towerDepths.join(',')} · glass '
      '$locked · ice $iced · $colors colors · maxSize $maxSize';

  static bool _sameInts(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
