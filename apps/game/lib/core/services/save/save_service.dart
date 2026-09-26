/// The boosters kept in the player's inventory (spec §8, §13.3
/// `inventory`). Undo is not one: it is free a few times per level
/// ([SaveService.freeUndosPerLevel]), then costs coins or an ad.
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

/// The player's save document (spec §13.3).
///
/// M2 surface (PROGRESS D13): progress, coins and the booster wallet, held
/// in memory for the session (`InMemorySaveService`; `FakeSaveService` in
/// tests and the fake env). Mutations are synchronous and notify [changes].
///
/// TODO(M3): the full document (inventory persisted, adsRemoved, skins,
/// themes, museum, daily, inProgress + undo, adCounters, stats), schema
/// version + migrations, save-on-every-move and on app pause, and
/// restore-on-resume when `levelVersion` still matches. Whether it lives in a
/// Hive box or the spec's atomic JSON file is an open M3 decision
/// (docs/PROGRESS.md Q3).
abstract interface class SaveService {
  /// Loads the save into memory (spec §10.2 #1). Called once by the splash.
  /// A missing save is not an error: it means a fresh install.
  Future<void> load();

  /// Spec §13.3 `currentLevel`: the 1-based global play order of the level
  /// the Home play button starts. Throws a [RangeError] below 1.
  int get currentLevel;
  set currentLevel(int level);

  /// Spec §13.3 `coins`. A fresh install has 0.
  int get coins;

  /// Adds [amount] (≥ 0) coins: a win reward, the chapter bonus (spec §7.3).
  void addCoins(int amount);

  /// Spends [amount] (≥ 0) coins when the player has that many; returns
  /// false and spends nothing otherwise.
  bool spendCoins(int amount);

  /// A win at play order [levelOrder]: adds [rewardCoins] and moves
  /// [currentLevel] to the next level (never back, so replaying an old level
  /// keeps the progress; spec §7.1).
  void recordWin({required int levelOrder, required int rewardCoins});

  /// How many of [kind] the player holds (spec §13.3 `inventory`).
  int boosterCount(BoosterKind kind);

  /// Uses one [kind]: true, and one fewer held, when the player has one;
  /// false otherwise. With [unlimitedBoosters] it is always true and
  /// nothing is taken.
  bool useBooster(BoosterKind kind);

  /// Adds [count] (≥ 0) of [kind] (a purchase, a gift).
  void addBoosters(BoosterKind kind, int count);

  /// Undos per level before undo costs coins: Remote Config
  /// `free_undos_per_level` (spec §7.3, §9.4).
  int get freeUndosPerLevel;

  /// The dev flavor's testing aid (BACKLOG M2): boosters are never used
  /// up, and callers don't charge undos either. False in stg and prod.
  bool get unlimitedBoosters;

  /// Fires after every change above, so Home and the HUD can refresh.
  Stream<void> get changes;

  /// Closes [changes] (DI reset).
  Future<void> dispose();
}
