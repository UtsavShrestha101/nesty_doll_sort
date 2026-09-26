import 'package:nesty_core/src/simulator/tier.dart';

/// The generator's inputs (spec §6.5 "Params").
///
/// Plain data: `Generator.checkParams` reports values that can't make a
/// valid level, as issues rather than exceptions, so the admin can show them.
final class GeneratorParams {
  const GeneratorParams({
    required this.colors,
    required this.maxSize,
    required this.shelves,
    required this.slotsPerShelf,
    required this.emptySlots,
    required this.targetTier,
    required this.seed,
    this.setsPerColor = 1,
    this.towers = 0,
    this.towerDepth = 2,
    this.locked = 0,
    this.iceSlots = 0,
    this.id,
  });

  /// Number of doll colors, chosen by the PRNG from the 10 non-gold colors
  /// (design A11).
  final int colors;

  /// Full sets per color (spec §6.5: default 1).
  final int setsPerColor;

  /// The level's `maxSize`, 3–6.
  final int maxSize;

  /// Number of shelves, 1–4.
  final int shelves;

  /// Slots on every shelf, 2–5, except the bottom shelf, which gets
  /// `min(slotsPerShelf, 4)` so both extra slots still fit in its row
  /// (owner override D22).
  final int slotsPerShelf;

  /// Tower slots.
  final int towers;

  /// Nests per tower at the start, 1–4 (§5.3 rule 5). Ignored when [towers]
  /// is 0.
  final int towerDepth;

  /// Open slots left empty at the start. Every other open slot holds one
  /// nest, and each tower [towerDepth] nests.
  final int emptySlots;

  /// Locked slots, placed on occupied open slots (spec §6.5 step 3,
  /// design A12).
  final int locked;

  /// Iced slots, placed on occupied slots that are not locked (spec §6.5
  /// step 3, design A12).
  final int iceSlots;

  /// The tier the generator retries for (spec §6.5 step 4).
  final Tier targetTier;

  /// The seed, in [0, 2^53): `1000000 + n` for Bonus Endless (§7.1),
  /// `yyyymmdd` for the daily puzzle (§7.5).
  final int seed;

  /// The generated level's id, or null for `Generator.defaultId`
  /// (`gen-<seed>`). It is recorded in the level but never changes the
  /// board.
  final String? id;

  @override
  bool operator ==(Object other) =>
      other is GeneratorParams &&
      other.colors == colors &&
      other.setsPerColor == setsPerColor &&
      other.maxSize == maxSize &&
      other.shelves == shelves &&
      other.slotsPerShelf == slotsPerShelf &&
      other.towers == towers &&
      other.towerDepth == towerDepth &&
      other.emptySlots == emptySlots &&
      other.locked == locked &&
      other.iceSlots == iceSlots &&
      other.targetTier == targetTier &&
      other.seed == seed &&
      other.id == id;

  @override
  int get hashCode => Object.hash(
    colors,
    setsPerColor,
    maxSize,
    shelves,
    slotsPerShelf,
    towers,
    towerDepth,
    emptySlots,
    locked,
    iceSlots,
    targetTier,
    seed,
    id,
  );

  @override
  String toString() =>
      'GeneratorParams(colors: $colors, setsPerColor: $setsPerColor, '
      'maxSize: $maxSize, shelves: $shelves, slotsPerShelf: $slotsPerShelf, '
      'towers: $towers, towerDepth: $towerDepth, emptySlots: $emptySlots, '
      'locked: $locked, iceSlots: $iceSlots, targetTier: ${targetTier.id}, '
      'seed: $seed, id: $id)';
}
