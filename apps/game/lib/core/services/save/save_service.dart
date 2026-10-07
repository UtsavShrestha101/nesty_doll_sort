import 'package:nesty_game/core/models/booster.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_reward.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

export 'package:nesty_game/core/models/booster.dart'
    show BoosterKind, BoosterSource, BoosterType;

/// The player's save document (spec §13.3; docs/plans/m3-design.md §3;
/// schema 3: M7's fields, docs/plans/m7-design.md §3, and the daily
/// gift's, docs/plans/plan-login-gift.md §7.5b).
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
  /// replaced by the defaults (m3-design §3.2). The badges the document
  /// already implies (`BadgeRules.derivable`) are granted here, silently:
  /// no toast (m7-design §12).
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

  /// One won level in one document update (m3-design §3.5, m7-design §7):
  /// the coins, the progress (`currentLevel` past a campaign order, never
  /// back; `bonus.next` past a bonus number; the daily's streak, with
  /// `records.dailies` and `records.longestRun`), `stats.wins` and
  /// `stats.moves`, a completed chapter's figurine and reward (only the
  /// first time), the level's in-progress board cleared, and M7's parts:
  /// the milestone chest ([LevelWinRecord.chest], once per level number),
  /// the best moves ([LevelWinRecord.bestKey]), `records.families` and
  /// `records.dolls`, and the badges earned.
  ///
  /// A replay (`PlayRequest.replay`) pays nothing, moves no progress and
  /// opens no chest or figurine, whatever the record says; it still counts
  /// in `stats`, the best moves, the best stars and the records (spec-prop
  /// §7.1, §7.10).
  ///
  /// The star rating (spec-prop §7.10; m7-design P3.4), bundled boards
  /// only: with a [LevelWinRecord.starsKey] and [LevelWinRecord.stars] of
  /// 1–3, `levelStars[starsKey]` becomes the higher of the old and the new
  /// (never lowered), reported as [LevelWinOutcome.stars] and
  /// [LevelWinOutcome.previousStars]. [LevelWinOutcome.showStarTip] is set
  /// while the tip was never shown, the win is below 3 stars and its stars
  /// weren't capped by a hint or an extra slot
  /// ([LevelWinRecord.starsCapped]): the win card shows it only when it has
  /// room, then calls [markStarTipShown] (phase 4 architecture §3.6), so
  /// `starTipShown` is no longer written here.
  /// Stars change no coins, chest, progress or badge. A daily solved for
  /// the first time on its date keeps `daily.lastSolve` (the Share text
  /// and the reminder offer's hour, m7-design P3.4).
  ///
  /// A race (`PlayRequest.race`) records nothing here and returns an empty
  /// outcome: its win goes through [recordRaceWin] (m7-design P2.7).
  ///
  /// Returns what the update did, for the win card, the chest modal and
  /// the badge toasts.
  LevelWinOutcome recordLevelWin(LevelWinRecord win);

  // --- vs Computer (spec-prop §7.7; m7-design P2.7) -----------------------

  /// Rival [rival] (1–3) was chosen, from rival select or New race: its
  /// `race.rivals` `raceNo` goes up by 1 (at most
  /// `DifficultyCurve.maxRaceNo`, where it stays: New race then replays the
  /// last board, an owner question's default) in one update, and the new
  /// raceNo is returned for `PlayRequest.race`. Null, with nothing written,
  /// for a rival outside 1–3 or one still locked (spec-prop §7.7 "Three
  /// rivals unlock in turn").
  ///
  /// It is written when the race is chosen, not at its result, so a quit
  /// or a kill never hands the same board back as a new race (spec-prop
  /// §7.7 "leaving it ends it with no reward"). Rematch doesn't call it.
  int? beginRace(int rival);

  /// One won race in one document update (spec-prop §7.7, §7.8; m7-design
  /// P2.7): coins += `max(0, rewardCoins)`; the rival's `wins` += 1; the
  /// next rival unlocks if it was locked (1 → 2 → 3, reported as
  /// [RaceWinOutcome.unlockedRival]); `stats.wins` += 1 and `stats.moves`
  /// += moves; `records.families` and `records.dolls`; and the badges
  /// earned (the board's, plus `first_race` and `all_rivals`, derivable from
  /// `race.rivals`). Nothing is in progress to clear: a race is never saved.
  /// Throws a [RangeError] for a rival outside 1–3, a raceNo outside
  /// 1–`DifficultyCurve.maxRaceNo` or a negative reward. A loss writes
  /// nothing, so it has no call.
  RaceWinOutcome recordRaceWin(RaceWinRecord win);

  /// The star rating's load-time backfill (Q120; m7-design P3.4), silent
  /// and idempotent: every won campaign order (order < [highestLevel])
  /// that [levels] has at exactly that order, with a par and no
  /// `levelStars` entry for its level id, gets `StarRules.backfill` (the
  /// stars the best moves of its current version earn, as if no hint was
  /// used; 1 star without a best), all in one update. It never lowers or
  /// replaces an entry and never shows anything (no toast, no tip). The
  /// splash calls it once the save and the bundle are loaded. Returns how
  /// many levels it gave stars. Never throws (rule 3): a failure gives 0.
  int backfillLevelStars(LevelRepository levels);

  /// The one-time star tip was shown (Q119; phase 4 architecture §3.6,
  /// §6.5): sets `starTipShown` in one update. Idempotent (a second call
  /// writes nothing) and never throws (rule 3).
  void markStarTipShown();

  /// The fewest moves of the bundled level with key [levelKey]
  /// (`LevelBests.key`, `L0024@2`), or null when it has never been won
  /// (spec-prop §7.1, m7-design §11).
  int? bestMovesFor(String levelKey);

  // --- The board in progress (spec §13.3, m3-design §3.4) -----------------

  /// The saved board of [kind], or null. Campaign and bonus share one slot
  /// (only the kind that is stored answers); the daily has its own.
  InProgressLevel? inProgressFor(PlayKind kind);

  /// Saves [level] in its kind's slot, replacing what was there. The bloc
  /// calls it after every applied move, undo, restart and +1 Slot. A
  /// replay's or a race's board is never saved (m7-design §6, P2.4): the
  /// call does nothing.
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

  // --- Daily gift (plan-login-gift §7.5b; D268) ---------------------------

  /// Claims the daily gift for the local date [today], in one document
  /// update: the day `LoginGiftRules.grantFor` gives (the track from
  /// Remote Config `login_gift_track`, `LoginGiftRules.trackOf`) pays its
  /// coins, hints and extra slots (added even with [unlimitedBoosters]:
  /// they are a stored count), and `loginGift` becomes
  /// `LoginGiftRules.claimed` (one more claim, [today] its date and seen).
  /// Fires [changes] once and returns the grant.
  ///
  /// Null, with nothing written, when the gift is still locked (it unlocks
  /// with the Daily, after Level 2), when [today] already claimed, or when
  /// [today] is earlier than `loginGift.latestSeen` (the clock went back).
  /// A missed day never moves the track back. Never throws for a valid
  /// date (rule 3).
  LoginGiftGrant? claimLoginGift(LocalDate today);

  /// The gift's status was read on [today]: raises `loginGift.latestSeen`
  /// to [today] in one update, so a date earlier than one already seen
  /// can't claim. Writes nothing, and fires no [changes], when [today] is
  /// not later than it. Never lowers it and never throws.
  void noteLoginGiftDate(LocalDate today);

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
