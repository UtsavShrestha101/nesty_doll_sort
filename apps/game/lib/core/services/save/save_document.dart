import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/booster.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';

part 'save_document.freezed.dart';

/// The player's save document, schema 1 (spec §13.3 plus the M3 additions;
/// docs/plans/m3-design.md §3). It lives as one JSON document under the key
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

    /// Top-level keys this schema doesn't know (a newer app's), kept as they
    /// were and written back (m3-design §3.3).
    @Default(<String, Object?>{}) Map<String, Object?> unknown,
  }) = _SaveDocument;

  const SaveDocument._();

  /// The schema this app reads and writes. Raising it needs a step in
  /// `SaveMigrations.steps`.
  static const int currentSchema = 1;

  /// The bundled skin every player owns (spec §13.5).
  static const String defaultSkin = 'classic';

  /// Chapter 1's theme, owned from the start (§13.3 `"ownedThemes":
  /// ["ch01"]`).
  static const String defaultTheme = 'ch01';

  /// The in-progress board of [kind]: [inProgress] holds a campaign or a
  /// bonus board (one main line), the daily keeps its own.
  InProgressLevel? inProgressOf(PlayKind kind) => switch (kind) {
    PlayKind.daily => daily.inProgress,
    PlayKind.campaign ||
    PlayKind.bonus => inProgress?.request.kind == kind ? inProgress : null,
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

/// The save's `daily` (spec §7.5, §13.3; docs/plans/m3-design.md §8.2).
@freezed
abstract class DailyProgress with _$DailyProgress {
  const factory DailyProgress({
    /// Days in a row: a solve adds one, a frozen day keeps it (§7.5).
    @Default(0) int streak,

    /// The last day the streak reached, by a solve or a freeze; null when
    /// there is no streak.
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

    /// Today's daily board in progress (m3-design §3.4).
    InProgressLevel? inProgress,
  }) = _DailyProgress;

  const DailyProgress._();

  /// Freezes held at most (m3-design §8.2).
  static const int maxFreezes = 1;

  /// [done] and [frozen] keep this many dates.
  static const int maxDates = 31;
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
  }) = _LevelWinRecord;
}
