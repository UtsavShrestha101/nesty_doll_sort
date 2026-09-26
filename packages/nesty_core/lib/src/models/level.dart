import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/models/equality.dart';
import 'package:nesty_core/src/models/slot.dart';
import 'package:nesty_core/src/models/slot_id.dart';

/// A level as authored or generated: the level JSON of spec §5.1 as a model.
///
/// A `Level` is plain data. It can hold a level that breaks the §5.3 rules
/// (too many shelves, counts that don't form full sets, …) so the validator
/// can report every problem at once. What it can't hold is an invalid nest or
/// an empty tower: those models reject them, and the codec reports them
/// (docs/plans/m1-core-design.md §2).
///
/// Shelves are listed top to bottom; `shelves.last` is the bottom shelf, the
/// one extra slots join (spec §3.6, D22).
final class Level {
  /// Copies [shelves] into unmodifiable lists.
  Level({
    required this.id,
    required this.maxSize,
    required List<List<Slot>> shelves,
    this.schemaVersion = currentSchemaVersion,
    this.generatorVersion,
    this.seed,
  }) : shelves = List.unmodifiable([
         for (final shelf in shelves) List<Slot>.unmodifiable(shelf),
       ]);

  /// The level-JSON schema version this package reads and writes (§5.1).
  static const int currentSchemaVersion = 1;

  /// The level's id, such as `L0042` (spec §5.1).
  final String id;

  /// The level-JSON schema version (spec §5.1, §5.3 rule 1).
  final int schemaVersion;

  /// The largest doll size in this level, 3–6 (spec §2.1, §5.3 rule 1).
  final int maxSize;

  /// The shelves, top to bottom, each a row of slots left to right.
  final List<List<Slot>> shelves;

  /// The generator version that produced this level, or null for an authored
  /// one (spec §6.5, design A20).
  final int? generatorVersion;

  /// The generator seed, in [0, 2^53), or null for an authored level
  /// (spec §6.5, design A20).
  final int? seed;

  /// Grid slot ids in row-major order (`r0c0`, `r0c1`, …, then the next
  /// shelf). Extra slots are not part of a level; a `GameState` appends them.
  List<String> get slotIds => _layout.ids;

  /// Number of slots the level defines (extra slots excluded).
  int get slotCount => _layout.ids.length;

  /// The slot with grid id [id]. Throws an [ArgumentError] for an unknown id.
  Slot slot(String id) {
    final position = positionOf(id);
    return shelves[position.row][position.col];
  }

  /// Where the slot with grid id [id] sits. Throws an [ArgumentError] for an
  /// unknown id.
  BoardPosition positionOf(String id) =>
      _layout.positions[id] ??
      (throw ArgumentError.value(id, 'id', 'No such slot in level ${this.id}'));

  /// Full sets per color, in `DollColor` order, gold excluded; only colors
  /// with dolls appear.
  ///
  /// Meaningful for a level that passes validation rule 4, where each color
  /// holds k full sets (spec §5.3); it is computed as ⌈dolls ÷ maxSize⌉.
  /// How a gold doll counts toward "the set it ends up in" is settled with
  /// the v1.1 gold rules (§3.5); until then the validator rejects gold.
  Map<DollColor, int> get setsByColor => _sets;

  /// Total full sets the level contains: the number of completions that win
  /// it (spec §2.3).
  int get totalSets => _totalSets;

  late final _SlotLayout _layout = _SlotLayout.of(shelves);

  late final Map<DollColor, int> _sets = _countSets();

  late final int _totalSets = _sets.values.fold(0, (sum, n) => sum + n);

  Map<DollColor, int> _countSets() {
    final dolls = List.filled(DollColor.values.length, 0);
    for (final shelf in shelves) {
      for (final slot in shelf) {
        for (final nest in slot.nests) {
          dolls[nest.color.index] += nest.length;
        }
      }
    }
    return Map.unmodifiable({
      for (final color in DollColor.values)
        if (!color.isWild && dolls[color.index] > 0 && maxSize > 0)
          color: (dolls[color.index] + maxSize - 1) ~/ maxSize,
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Level &&
          other.hashCode == hashCode &&
          other.id == id &&
          other.schemaVersion == schemaVersion &&
          other.maxSize == maxSize &&
          other.generatorVersion == generatorVersion &&
          other.seed == seed &&
          nestedListEquals(other.shelves, shelves);

  // Cached: a level is immutable, and every GameState compares and hashes
  // its level, so a deep hash per call would add up in undo histories.
  @override
  late final int hashCode = Object.hash(
    id,
    schemaVersion,
    maxSize,
    generatorVersion,
    seed,
    Object.hashAll(shelves.map(Object.hashAll)),
  );

  @override
  String toString() =>
      'Level($id, maxSize $maxSize, '
      '${shelves.map((s) => s.length).join('/')} slots)';
}

/// Slot ids and positions of a level, built once on first use.
final class _SlotLayout {
  _SlotLayout(this.ids, this.positions);

  factory _SlotLayout.of(List<List<Slot>> shelves) {
    final ids = <String>[];
    final positions = <String, BoardPosition>{};
    for (var row = 0; row < shelves.length; row++) {
      for (var col = 0; col < shelves[row].length; col++) {
        final id = SlotId.grid(row, col);
        ids.add(id);
        positions[id] = BoardPosition(row, col);
      }
    }
    return _SlotLayout(List.unmodifiable(ids), Map.unmodifiable(positions));
  }

  final List<String> ids;
  final Map<String, BoardPosition> positions;
}
