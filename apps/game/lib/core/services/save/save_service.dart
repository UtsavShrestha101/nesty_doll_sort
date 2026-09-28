import 'package:nesty_game/core/models/booster.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

export 'package:nesty_game/core/models/booster.dart'
    show BoosterKind, BoosterSource, BoosterType;

/// The player's save document (spec §13.3; docs/plans/m3-design.md §3).
///
/// The real implementation, `HiveSaveService`, keeps one JSON document under
/// `doc` in the Hive box `save`, through `DatabaseService` (D63): read once
/// in [load] (migrated forward, leniently, never throwing), then written by
/// a serial, coalescing queue after every change and flushed on
/// `AppLifecycleState.paused`/`detached`. `InMemorySaveService` holds the
/// same document for the session only and backs `FakeSaveService` (tests
/// and the fake env).
///
/// Every mutation below is synchronous on the in-memory document, is one
/// document update (so a crash never keeps half of it), and fires
/// [changes] only when the document actually changed.
abstract interface class SaveService {
  /// Loads the save into memory (spec §10.2 #1). The splash calls it; later
  /// calls return the same future. A missing save is not an error: it is a
  /// fresh install. Never throws: an unreadable document is backed up and
  /// replaced by the defaults (m3-design §3.2).
  Future<void> load();

  /// The whole document as it is now. Mutate it only through the methods
  /// below.
  SaveDocument get document;

  /// Fires after every change, so Home, the HUD, the Shop and the Daily
  /// screen can refresh.
  Stream<void> get changes;

  // --- Progress (spec §7.1) ---------------------------------------------

  /// Spec §13.3 `currentLevel`: the 1-based global play order of the level
  /// Home's PLAY starts. Throws a [RangeError] below 1. Setting it (the dev
  /// level picker) never lowers [highestLevel].
  int get currentLevel;
  set currentLevel(int level);

  /// Spec §13.3 `highestLevel`: the highest [currentLevel] reached.
  int get highestLevel;

  /// The "Bonus Level N" PLAY starts past the last published level (spec
  /// §7.1; `bonus.next`, from 1).
  int get nextBonus;

  // --- Wallet (spec §7.3, §8) --------------------------------------------

  /// Spec §13.3 `coins`. A fresh install has 0 (Q46).
  int get coins;

  /// Adds [amount] (≥ 0) coins.
  void addCoins(int amount);

  /// Spends [amount] (≥ 0) coins when the player has that many; returns
  /// false and spends nothing otherwise.
  bool spendCoins(int amount);

  /// How many of [kind] the player holds (spec §13.3 `inventory`).
  int boosterCount(BoosterKind kind);

  /// Uses one [kind]: true, and one fewer held, when the player has one;
  /// false otherwise. With [unlimitedBoosters] it is always true and
  /// nothing is taken.
  bool useBooster(BoosterKind kind);

  /// Adds [count] (≥ 0) of [kind] (a purchase, a gift).
  void addBoosters(BoosterKind kind, int count);

  /// Undos per level before undo costs coins: Remote Config
  /// `free_undos_per_level` (spec §7.3, §9.4), never below 0.
  int get freeUndosPerLevel;

  /// The dev flavor's testing aid (BACKLOG M2): boosters are never used
  /// up, and callers don't charge undos either. False in stg and prod.
  bool get unlimitedBoosters;

  /// Counts one use of [type] in `stats.boostersUsed` (spec §13.3).
  void recordBoosterUse(BoosterType type);

  // --- Wins (m3-design §3.5) ---------------------------------------------

  /// A campaign win at play order [levelOrder]: the same as
  /// [recordLevelWin] with `PlayRequest.campaign(levelOrder)` and
  /// [rewardCoins] (the M2 call, kept).
  void recordWin({required int levelOrder, required int rewardCoins});

  /// One won level in one document update: the coins, the progress
  /// (`currentLevel` past a campaign order, never back; `bonus.next` past a
  /// bonus number; the daily's streak), `stats.wins` and `stats.moves`, a
  /// completed chapter's figurine and reward (only the first time), and
  /// the level's in-progress board cleared.
  void recordLevelWin(LevelWinRecord win);

  // --- The board in progress (spec §13.3, m3-design §3.4) -----------------

  /// The saved board of [kind], or null. Campaign and bonus share one slot
  /// (only the kind that is stored answers); the daily has its own.
  InProgressLevel? inProgressFor(PlayKind kind);

  /// Saves [level] in its kind's slot, replacing what was there. The bloc
  /// calls it after every applied move, undo, restart and +1 Slot.
  void saveInProgress(InProgressLevel level);

  /// Clears [kind]'s slot (a campaign clear leaves a bonus board alone,
  /// and the reverse).
  void clearInProgress(PlayKind kind);

  // --- Cosmetics (spec §7.4, frames 7.3–7.7) -------------------------------

  /// Buys skin [skinId] for [price] (≥ 0) coins: false, with nothing spent,
  /// when it is already owned or the coins are short. It doesn't equip it.
  bool purchaseSkin(String skinId, int price);

  /// Equips owned skin [skinId]: false when it isn't owned.
  bool selectSkin(String skinId);

  /// Buys theme [themeId] early for [price] (≥ 0) coins (frame 7.7): false,
  /// with nothing spent, when it is already listed or the coins are short.
  bool purchaseTheme(String themeId, int price);

  /// Uses theme [themeId] everywhere, or null for "Match each chapter".
  /// Ownership (bought, or its chapter reached) is the caller's check.
  void selectTheme(String? themeId);

  // --- Onboarding (spec §7.6) ---------------------------------------------

  /// The intro card of [mechanic] was dismissed (frames 4.1–4.3).
  void markIntroSeen(IntroMechanic mechanic);

  /// Frames 1.3–1.6: the tutorial's last scripted move was made.
  void markTutorialDone();

  // --- Daily (spec §7.5, m3-design §8) -------------------------------------

  /// Replaces `daily` with [daily] and adds [addCoins] (≥ 0), in one update
  /// (the streak reconcile, the chest). A daily win goes through
  /// [recordLevelWin] instead.
  void writeDaily(DailyProgress daily, {int addCoins = 0});

  // --- Identity -------------------------------------------------------------

  /// The Settings footer's Player ID (frame 8.1): a local random id made on
  /// the first [load], `7F3A-21C9` (m3-design §3.1). '' before [load].
  String get playerId;

  // --- Persistence ------------------------------------------------------------

  /// Writes what the queue still holds and flushes the box. Called on
  /// `AppLifecycleState.paused`/`detached` and on dispose; a no-op in
  /// memory. Never throws.
  Future<void> flush();

  /// Flushes, then closes [changes] (DI reset).
  Future<void> dispose();
}
