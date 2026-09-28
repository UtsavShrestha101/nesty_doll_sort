/// The boosters kept in the player's inventory (spec §8, §13.3
/// `inventory`). Undo is not one: it is free a few times per level
/// (`SaveService.freeUndosPerLevel`), then costs coins or an ad.
enum BoosterKind {
  /// Spec §8 Hint: the solver's next move with a pulsing arrow (frame 3.1).
  hint('hint', starterGift: 3),

  /// Spec §8 Extra slot: a stand appended to the bottom shelf (D22, at most
  /// 2 per level, a core rule).
  extraSlot('slot', starterGift: 2);

  const BoosterKind(this.storageKey, {required this.starterGift});

  /// The key in the save's `inventory` (spec §13.3).
  final String storageKey;

  /// What a new player starts with (spec §8: "New players get 3 hints and 2
  /// extra slots as starting gifts").
  final int starterGift;
}

/// The three boosters of the booster bar that can be used or bought (spec
/// §8, docs/plans/m3-design.md §7): the `type` of the §14.4
/// `booster_use{type, source}` event and the key of the save's
/// `stats.boostersUsed`.
enum BoosterType {
  /// Free `free_undos_per_level` times per level, then `price_undo` coins.
  undo('undo'),

  /// From the inventory, then `price_hint` coins.
  hint('hint', inventory: BoosterKind.hint),

  /// From the inventory, then `price_slot` coins.
  slot('slot', inventory: BoosterKind.extraSlot);

  const BoosterType(this.id, {this.inventory});

  /// `booster_use{type}` (spec §14.4) and the `stats.boostersUsed` key.
  final String id;

  /// The inventory it is taken from, or null for undo (free undos, then
  /// coins).
  final BoosterKind? inventory;
}

/// Where a used booster came from: `booster_use{source}` (spec §14.4).
/// An inventory use and a free undo are both `free` (Q42's default).
enum BoosterSource {
  free('free'),
  coins('coins'),

  /// A rewarded video (M6).
  ad('ad');

  const BoosterSource(this.id);

  final String id;
}
