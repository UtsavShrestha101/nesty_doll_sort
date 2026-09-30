import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/booster.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/records/badge.dart';

export 'package:nesty_game/core/services/records/badge.dart' show BadgeId;

part 'save_document.freezed.dart';

/// The player's save document, schema 2 (spec §13.3 plus the M3 additions,
/// docs/plans/m3-design.md §3, and the M7 ones, spec-prop §13.3 and
/// docs/plans/m7-design.md §3). It lives as one JSON document under the key
/// `doc` of the Hive box `save` (D63), read and written only by
/// `SaveService` through `SaveDocumentCodec` (lenient, hand-written: no
/// json_serializable).
///
/// The §13.3 `settings` object is not here: device settings stay in the
/// `settings` box behind `DatabaseService`, where Pause and the music
/// already read them (a recorded §13.3 deviation, m3-design §3.1).
@freezed
abstract class SaveDocument with _$SaveDocument {
  const factory SaveDocument({
    /// The schema this app writes ([currentSchema]).
    @Default(SaveDocument.currentSchema) int schema,

    /// The published level Home's PLAY starts, 1-based (§13.3). Past the
    /// last level it stays at `levelCount + 1`, and PLAY starts
    /// `bonus.next` (m3-design §7.4).
    @Default(1) int currentLevel,

    /// The highest [currentLevel] reached (§13.3). The daily unlocks at 3
    /// (Level 2 won, m3-design §8.3).
    @Default(1) int highestLevel,

    /// Spec §7.3. A fresh install has 0 (Q46).
    @Default(0) int coins,

    /// Hints and extra slots held (§8, §13.3), the starter gift first.
    @Default(BoosterInventory()) BoosterInventory inventory,

    /// Spec §9.2; always false until M6.
    @Default(false) bool adsRemoved,

    /// Skin ids owned, `classic` always among them (§7.4).
    @Default(<String>[SaveDocument.defaultSkin]) List<String> ownedSkins,

    /// The skin boards use (§7.4); always one of [ownedSkins].
    @Default(SaveDocument.defaultSkin) String selectedSkin,

    /// Themes bought, and `ch01`. A chapter's own theme is owned once the
    /// chapter is reached, whether or not it is listed (frame 7.7,
    /// m3-design §9.4).
    @Default(<String>[SaveDocument.defaultTheme]) List<String> ownedThemes,

    /// Null: "Match each chapter" (§7.4, frame 7.7).
    String? selectedTheme,

    /// Chapter ids whose figurine the player has (§7.2, §13.3), in the
    /// order collected.
    @Default(<String>[]) List<String> museum,

    /// The local date each figurine was collected (frame 6.2 "Collected ·
    /// Sep 12"; an M3 addition, D22). A [museum] id without a date shows
    /// "Collected".
    @Default(<String, LocalDate>{}) Map<String, LocalDate> museumCollected,

    /// The daily puzzle and its streak (§7.5, m3-design §8).
    @Default(DailyProgress()) DailyProgress daily,

    /// The campaign or bonus level in progress (§13.3; m3-design §3.4).
    /// The daily's board is [DailyProgress.inProgress].
    InProgressLevel? inProgress,

    /// Interstitial pacing (§9.1, §13.3); read and written from M6.
    @Default(AdCounters()) AdCounters adCounters,

    /// Spec §13.3 `stats`.
    @Default(SaveStats()) SaveStats stats,

    /// `IntroMechanic.id`s whose card was dismissed (frames 4.1–4.3; an M3
    /// addition).
    @Default(<String>[]) List<String> seenIntros,

    /// The Level 2 swallow demo was done (frames 1.3–1.6; an M3 addition).
    @Default(false) bool tutorialDone,

    /// Bonus Endless (§7.1; an M3 addition).
    @Default(BonusProgress()) BonusProgress bonus,

    /// A local random id for the Settings footer ("Player ID 7F3A-21C9",
    /// frame 8.1; an M3 addition, Q74). `SaveService.load` makes one when
    /// it is missing, so it is null only in a document not yet loaded.
    String? playerId,

    /// Fewest moves per bundled level, keyed `LevelBests.key` (`L0024@2`):
    /// every win of a campaign level or a replay (spec-prop §7.1, §13.3;
    /// m7-design §11). Generated boards keep none.
    @Default(<String, int>{}) Map<String, int> levelBests,

    /// Best stars per bundled level id (`L0024` → 1–3): the most any win
    /// of a campaign level or a replay has earned (spec-prop §7.10, §13.3;
    /// D125; m7-design P3.4). Kept per level id, so a new level version
    /// keeps them (Q117); never lowered. `SaveService.backfillLevelStars`
    /// fills it at load for levels won before stars existed (Q120).
    /// Generated boards (daily, bonus, race) keep none.
    @Default(<String, int>{}) Map<String, int> levelStars,

    /// The one-time star tip ("Fewer moves earn more stars…") was shown on
    /// the first win below 3 stars (Q119; m7-design P3.6), so no later
    /// win card shows it.
    @Default(false) bool starTipShown,

    /// Lifetime records and badges (spec-prop §7.8, §13.3; m7-design §12).
    @Default(SaveRecords()) SaveRecords records,

    /// Milestone chests already opened (spec-prop §7.3; m7-design §9).
    @Default(ChestProgress()) ChestProgress chests,

    /// vs Computer, per rival (spec-prop §7.7, §13.3; m7-design §3). The
    /// race itself lands in M7 phase 2; the fields are schema 2's.
    @Default(RaceProgress()) RaceProgress race,

    /// Top-level keys this schema doesn't know (a newer app's), kept as they
    /// were and written back (m3-design §3.3).
    @Default(<String, Object?>{}) Map<String, Object?> unknown,
  }) = _SaveDocument;

  const SaveDocument._();

  /// The schema this app reads and writes. Raising it needs a step in
  /// `SaveMigrations.steps` and a test that migrates a real document of the
  /// schema before (m7-design §3.3: 1 → 2 is M7's one step).
  static const int currentSchema = 2;

  /// The bundled skin every player owns (spec §13.5).
  static const String defaultSkin = 'classic';

  /// Chapter 1's theme, owned from the start (§13.3 `"ownedThemes":
  /// ["ch01"]`).
  static const String defaultTheme = 'ch01';

  /// The in-progress board of [kind]: [inProgress] holds a campaign or a
  /// bonus board (one main line), the daily keeps its own, and a replay or
  /// a race is never saved (m7-design §6, P2.4).
  InProgressLevel? inProgressOf(PlayKind kind) => switch (kind) {
    PlayKind.daily => daily.inProgress,
    PlayKind.campaign ||
    PlayKind.bonus => inProgress?.request.kind == kind ? inProgress : null,
    PlayKind.replay || PlayKind.race => null,
  };
}

/// The save's `inventory` (spec §8, §13.3): `{"hint": 3, "slot": 2}`.
@freezed
abstract class BoosterInventory with _$BoosterInventory {
  const factory BoosterInventory({
    /// Starts at `BoosterKind.hint.starterGift`.
    @Default(3) int hint,

    /// Starts at `BoosterKind.extraSlot.starterGift`.
    @Default(2) int slot,
  }) = _BoosterInventory;

  const BoosterInventory._();

  int of(BoosterKind kind) => switch (kind) {
    BoosterKind.hint => hint,
    BoosterKind.extraSlot => slot,
  };

  BoosterInventory withCount(BoosterKind kind, int count) => switch (kind) {
    BoosterKind.hint => copyWith(hint: count),
    BoosterKind.extraSlot => copyWith(slot: count),
  };
}

/// The save's `daily` (spec §7.5, §13.3; docs/plans/m3-design.md §8.2;
/// the gentle streak of spec-prop §7.5, docs/plans/m7-design.md §8).
@freezed
abstract class DailyProgress with _$DailyProgress {
  const factory DailyProgress({
    /// The days the daily was solved on its own date: a solve adds one and
    /// nothing ever lowers it (spec-prop §7.5, m7-design §8). Schema 1's
    /// "days in a row" carries over as it was (m7-design §3.3).
    @Default(0) int streak,

    /// The flame is lit (spec-prop §7.5): false before the first solve and
    /// after a missed day no freeze covered ("paused"); the next solve
    /// relights it. Always `run > 0` (m7-design §8).
    @Default(false) bool lit,

    /// The current unbroken run: days in a row, a frozen day keeping it
    /// without adding (the old streak's meaning). 0 while not [lit]. The
    /// longest one is `SaveRecords.longestRun`.
    @Default(0) int run,

    /// The last day the run reached, by a solve or a freeze; null when
    /// there is no run (fresh, or paused).
    LocalDate? lastDate,

    /// Freezes held, 0 or 1 ([maxFreezes]).
    @Default(0) int freezes,

    /// `LocalDate.isoWeekKey` of the last weekly freeze grant.
    int? freezeWeek,

    /// Days solved, oldest first, at most [maxDates].
    @Default(<LocalDate>[]) List<LocalDate> done,

    /// Days a freeze covered, oldest first, at most [maxDates].
    @Default(<LocalDate>[]) List<LocalDate> frozen,

    /// The frozen day whose "Streak saved!" banner (frame 5.2) was shown.
    LocalDate? noticeDate,

    /// A 7th streak day was solved and its chest (frame 5.6) not collected.
    @Default(false) bool chestPending,

    /// The latest daily solved for the first time on its date: what the
    /// Daily screen's Share text says (E3, spec-prop §10.2 #11) and the
    /// hour the reminder offer proposes (E4, Q81; m7-design P3.4). Null
    /// before the first solve, and for a day an older build solved.
    DailySolve? lastSolve,

    /// Today's daily board in progress (m3-design §3.4).
    InProgressLevel? inProgress,
  }) = _DailyProgress;

  const DailyProgress._();

  /// The flame is out with days already counted (spec-prop §7.5
  /// "paused"): the Daily tile and the streak card show their resting look
  /// (m7-design §8, §15).
  bool get paused => !lit && streak > 0;

  /// This progress is the moment a solve of [date] relit a paused streak
  /// (m7-design §8): the run restarted at 1 on a streak that already had
  /// days, and the solve counted for [date]. False for the very first
  /// solve (a streak of 1 was started, not relit) and for a solve of
  /// another date (the clock went back).
  bool relitOn(LocalDate date) => run == 1 && streak > 1 && lastDate == date;

  /// Freezes held at most (m3-design §8.2).
  static const int maxFreezes = 1;

  /// [done] and [frozen] keep this many dates.
  static const int maxDates = 31;
}

/// One daily solve, kept as `daily.lastSolve` (m7-design P3.4): the
/// spoiler-free facts the Share text needs (E3) and the local minute of the
/// solve (the reminder offer's default hour, E4, Q81). JSON:
/// `{"date": "2026-09-28", "moves": 18, "families": 5, "minute": 1150}`.
@freezed
abstract class DailySolve with _$DailySolve {
  const factory DailySolve({
    /// The daily's own date (its `PlayRequest.daily` number).
    required LocalDate date,

    /// `GameState.moveCount` at the win.
    @Default(0) int moves,

    /// The families the board completed (`RecordRules.familiesIn`).
    @Default(0) int families,

    /// The local minute of the day the win landed on (0–1439,
    /// `hour × 60 + minute` from `AppClock`); null when unknown.
    int? minuteOfDay,
  }) = _DailySolve;
}

/// A board in progress (spec §13.3 `inProgress`; docs/plans/m3-design.md
/// §3.4). JSON: `{"kind", "number", "levelId", "levelVersion", "tier",
/// "level", "session"}`.
@freezed
abstract class InProgressLevel with _$InProgressLevel {
  const factory InProgressLevel({
    /// What is being played; its kind and number are stored.
    required PlayRequest request,

    /// `Level.id` of the board.
    required String levelId,

    /// Must equal the entry's `PlayEntry.levelVersion` to restore (§13.3).
    required int levelVersion,

    /// `GameSessionCodec.encode` of the session: the board, the undo
    /// history and `undosUsed`. The selection and the hint are not saved.
    required Map<String, Object?> session,

    /// `LevelCodec.encode` of a generated board (bonus, daily), so a resume
    /// never regenerates it. Null for campaign levels.
    Map<String, Object?>? level,

    /// A generated board's tier, so a resume needn't simulate it again.
    Tier? tier,

    /// A hint was shown during this attempt, since the last Restart (Q116;
    /// m7-design P3.6): the win's stars are capped at 2 even after a kill
    /// and a restore. Restart clears it.
    @Default(false) bool hinted,
  }) = _InProgressLevel;
}

/// The save's `adCounters` (spec §9.1, §13.3), kept for M6.
@freezed
abstract class AdCounters with _$AdCounters {
  const factory AdCounters({
    @Default(0) int winsSinceInterstitial,

    /// Milliseconds since the epoch; 0 for never.
    @Default(0) int lastAdAt,
    @Default(0) int interstitialsShown,
  }) = _AdCounters;
}

/// The save's `stats` (spec §13.3).
@freezed
abstract class SaveStats with _$SaveStats {
  const factory SaveStats({
    /// Levels won: campaign, bonus and daily.
    @Default(0) int wins,

    /// Moves of the won levels (`GameState.moveCount` at the win).
    @Default(0) int moves,

    /// `BoosterType.id` → uses.
    @Default(<String, int>{}) Map<String, int> boostersUsed,
  }) = _SaveStats;
}

/// The save's `bonus` (spec §7.1; an M3 addition).
@freezed
abstract class BonusProgress with _$BonusProgress {
  const factory BonusProgress({
    /// The "Bonus Level N" PLAY starts next, from 1.
    @Default(1) int next,
  }) = _BonusProgress;
}

/// One won level, written in a single document update by
/// `SaveService.recordLevelWin` (docs/plans/m3-design.md §3.5), so a crash
/// can never pay the coins without the progress, or the reverse.
@freezed
abstract class LevelWinRecord with _$LevelWinRecord {
  const factory LevelWinRecord({
    /// What was won. A campaign win moves [SaveDocument.currentLevel] past
    /// its order (never back), a bonus win moves `bonus.next` past its
    /// number, a daily win takes [daily]. Its in-progress board is cleared.
    required PlayRequest request,

    /// The level's coins ([PlayEntry.rewardCoins]).
    required int rewardCoins,

    /// `GameState.moveCount` at the win (`stats.moves`).
    @Default(0) int moves,

    /// A campaign win that completed its chapter: this chapter id joins the
    /// museum with [date], and [chapterReward] is paid, only if it isn't
    /// there yet.
    String? completedChapterId,

    /// `reward_chapter` (m3-design §7.1).
    @Default(0) int chapterReward,

    /// Today (the museum's collected date).
    LocalDate? date,

    /// A daily win: the streak after the solve
    /// (`DailyService.progressAfterSolve`).
    DailyProgress? daily,

    /// A bundled board's `LevelBests.key` (a campaign level or a replay):
    /// [moves] becomes the level's best when fewer (m7-design §11). Null
    /// for generated boards, which keep no best.
    String? bestKey,

    /// The milestone chest this win reaches (`MilestoneChest.forWin`),
    /// paid in the same update unless `chests` already has it (m7-design
    /// §9). Never set for a replay; the save ignores one anyway.
    ChestGrant? chest,

    /// The families the won board completed (`RecordRules.familiesIn`),
    /// added to `records.families` (m7-design §12).
    @Default(0) int families,

    /// The dolls the won board nested (`RecordRules.dollsNestedIn`), added
    /// to `records.dolls` (m7-design §12).
    @Default(0) int dolls,

    /// Badges the won board itself earns (`BadgeRules.forWonBoard`): glass,
    /// ice and tall boards (m7-design §12). The save adds the ones
    /// derivable from the document after the win.
    @Default(<BadgeId>[]) List<BadgeId> boardBadges,

    /// The bundled level's id (`StarRules.keyOf`) whose best stars this win
    /// may raise (spec-prop §7.10; m7-design P3.4). Null for generated
    /// boards and for an entry without a par: no stars.
    String? starsKey,

    /// This win's stars, 1–3 (`StarRating.starsForWin`); null with no
    /// [starsKey]. Stars pay and unlock nothing: only `levelStars` reads
    /// them.
    int? stars,

    /// The local minute of the day of the win (0–1439, from `AppClock`).
    /// The save keeps it only for a daily (`DailySolve.minuteOfDay`).
    int? minuteOfDay,

    /// The win's [stars] were capped by a hint or an extra slot: the
    /// uncapped rule would have given 3 (`GameplayState.starsCapped`; Q145).
    /// The card shows the helper note, so [LevelWinOutcome.showStarTip]
    /// stays false (phase 4 architecture §3.6). Not stored.
    @Default(false) bool starsCapped,
  }) = _LevelWinRecord;
}

/// What `SaveService.recordLevelWin` did in its one update (m7-design §7):
/// what the win card, the chest modal and the badge toasts show.
@freezed
abstract class LevelWinOutcome with _$LevelWinOutcome {
  const factory LevelWinOutcome({
    /// The level's best moves after this win (so never above its moves);
    /// null when the win had no `LevelWinRecord.bestKey`.
    int? bestMoves,

    /// The best before this win, or null when it had none (a first win, or
    /// no best kept).
    int? previousBest,

    /// The milestone chest this win opened and paid, or null (none reached,
    /// already opened, or a replay).
    ChestGrant? chestPaid,

    /// The badges this win earned, in [BadgeId] order (one toast each).
    @Default(<BadgeId>[]) List<BadgeId> newBadges,

    /// The level's best stars after this win (so never below this win's),
    /// or null when the win had no stars (m7-design P3.4).
    int? stars,

    /// The level's best stars before this win; null when it had none (a
    /// first win, or a level won before stars that the backfill hasn't
    /// reached).
    int? previousStars,

    /// The one-time star tip may show on this win's card (Q119): it was
    /// never shown, the win is below 3 stars and its stars weren't capped.
    /// The card calls `SaveService.markStarTipShown` once it shows it
    /// (phase 4 architecture §3.6); a card with no room leaves it for the
    /// next one.
    @Default(false) bool showStarTip,
  }) = _LevelWinOutcome;
}

/// Where a milestone chest sits (spec-prop §7.3; m7-design §9).
enum ChestSource {
  /// Level 10 of a chapter: campaign orders 10, 30 … 190.
  campaign,

  /// Every 10th Bonus Endless level: bonus numbers 10, 20 …
  bonus,
}

/// A milestone chest and its fixed contents (spec-prop §7.3; m7-design
/// §9): shown before it opens, never random (spec-prop §1.1 rule 2).
@freezed
abstract class ChestGrant with _$ChestGrant {
  const factory ChestGrant({
    required ChestSource source,

    /// The campaign order ([ChestSource.campaign]) or the bonus number
    /// ([ChestSource.bonus]) whose win opens it.
    required int number,

    /// `chest_coins` (Remote Config, default 100).
    required int coins,

    /// `chest_hints` (Remote Config, default 1): hint boosters.
    required int hints,
  }) = _ChestGrant;
}

/// The save's `records` (spec-prop §7.8, §13.3; m7-design §12): lifetime
/// counts over every mode (replays and races included) and the badges.
@freezed
abstract class SaveRecords with _$SaveRecords {
  const factory SaveRecords({
    /// Families completed in won boards.
    @Default(0) int families,

    /// Dolls nested in won boards: the dolls that end inside another.
    @Default(0) int dolls,

    /// Daily puzzles solved, one per date.
    @Default(0) int dailies,

    /// The longest unbroken daily run (`DailyProgress.run`).
    @Default(0) int longestRun,

    /// `BadgeId.id`s earned, in the order earned. Unknown ids (a newer
    /// app's) are kept and written back, never shown.
    @Default(<String>[]) List<String> badges,
  }) = _SaveRecords;

  const SaveRecords._();

  /// Whether [badge] is earned.
  bool has(BadgeId badge) => badges.contains(badge.id);

  /// The known badges earned, in [BadgeId] order (the Records grid).
  List<BadgeId> get earned => [
    for (final badge in BadgeId.values)
      if (badges.contains(badge.id)) badge,
  ];
}

/// The save's `chests` (spec-prop §7.3, §13.3; m7-design §9): each chest
/// opens once per level number.
@freezed
abstract class ChestProgress with _$ChestProgress {
  const factory ChestProgress({
    /// Campaign orders whose chest was opened (10, 30 …), ascending.
    @Default(<int>[]) List<int> opened,

    /// Bonus numbers whose chest was opened (10, 20 …), ascending. Kept
    /// apart from [opened] so a chapter published later (M4) never meets
    /// a bonus number (an M7 addition to spec-prop §13.3, m7-design §3).
    @Default(<int>[]) List<int> bonusOpened,
  }) = _ChestProgress;

  const ChestProgress._();

  /// Whether [chest] was already opened.
  bool hasOpened(ChestGrant chest) => switch (chest.source) {
    ChestSource.campaign => opened.contains(chest.number),
    ChestSource.bonus => bonusOpened.contains(chest.number),
  };

  /// This progress with [chest] opened (unchanged when it already was).
  ChestProgress withOpened(ChestGrant chest) {
    if (hasOpened(chest)) return this;
    return switch (chest.source) {
      ChestSource.campaign => copyWith(
        opened: [...opened, chest.number]..sort(),
      ),
      ChestSource.bonus => copyWith(
        bonusOpened: [...bonusOpened, chest.number]..sort(),
      ),
    };
  }
}

/// The save's `race` (spec-prop §7.7, §13.3; m7-design §3): exactly
/// [rivalCount] rivals, in order.
@freezed
abstract class RaceProgress with _$RaceProgress {
  const factory RaceProgress({
    @Default(RaceProgress.defaultRivals) List<RivalProgress> rivals,
  }) = _RaceProgress;

  const RaceProgress._();

  /// Rivals 1–3 (vs-computer rule 2).
  static const int rivalCount = 3;

  /// A fresh save: rival 1 open (the mode itself unlocks after
  /// `race_unlock_level`), rivals 2 and 3 locked, no races yet.
  static const List<RivalProgress> defaultRivals = [
    RivalProgress(unlocked: true),
    RivalProgress(),
    RivalProgress(),
  ];

  /// Races won against every rival.
  int get totalWins => rivals.fold(0, (sum, rival) => sum + rival.wins);
}

/// One rival's progress (spec-prop §7.7 "Save"; m7-design §3).
@freezed
abstract class RivalProgress with _$RivalProgress {
  const factory RivalProgress({
    /// Selectable: rival 1 always, the next after the first win against
    /// the one before (vs-computer rule 2).
    @Default(false) bool unlocked,

    /// Races won against this rival.
    @Default(0) int wins,

    /// The number of this rival's latest race (from 1; 0 = none yet).
    /// Selecting the rival or New race starts `raceNo + 1`; Rematch keeps
    /// it (plan-m7 decision 14; `SaveService.beginRace`, m7-design P2.7).
    @Default(0) int raceNo,
  }) = _RivalProgress;
}

/// One won race, written in a single document update by
/// `SaveService.recordRaceWin` (spec-prop §7.7 "A win pays the rival's
/// `race_reward_n`"; m7-design P2.7), so a kill never pays without the win
/// or the unlock.
@freezed
abstract class RaceWinRecord with _$RaceWinRecord {
  const factory RaceWinRecord({
    /// The rival beaten, 1–3.
    required int rival,

    /// The race's number (`PlayRequest.race`'s raceNo, ≥ 1), already
    /// stored by `SaveService.beginRace` when the race was chosen.
    required int raceNo,

    /// `race_reward_n` (`RaceRules.rewardCoins`, the resolver's
    /// `PlayEntry.rewardCoins`). A Rematch win pays again (default, an
    /// owner question, m7-design P2.14).
    required int rewardCoins,

    /// The player's `GameState.moveCount` at the win (`stats.moves`).
    @Default(0) int moves,

    /// The families the won board completed (`RecordRules.familiesIn`),
    /// added to `records.families`: races count in the records (m7-design
    /// §12, Q91).
    @Default(0) int families,

    /// The dolls the won board nested (`RecordRules.dollsNestedIn`), added
    /// to `records.dolls`.
    @Default(0) int dolls,

    /// Badges the won board itself earns (`BadgeRules.forWonLevel`).
    @Default(<BadgeId>[]) List<BadgeId> boardBadges,
  }) = _RaceWinRecord;
}

/// What `SaveService.recordRaceWin` did in its one update (m7-design
/// P2.7): what the race's result card (frame 9.4), the rival-unlocked
/// moment (9.6) and the badge toasts show.
@freezed
abstract class RaceWinOutcome with _$RaceWinOutcome {
  const factory RaceWinOutcome({
    /// The coins the win paid (`max(0, rewardCoins)`).
    @Default(0) int coins,

    /// The rival this win unlocked (2 or 3), or null: rival 3 unlocks
    /// nothing, and a rival already open isn't unlocked again.
    int? unlockedRival,

    /// The races won against this rival after this win.
    @Default(0) int wins,

    /// The badges this win earned, in [BadgeId] order (`first_race`,
    /// `all_rivals` and the board's own; one toast each).
    @Default(<BadgeId>[]) List<BadgeId> newBadges,
  }) = _RaceWinOutcome;
}
