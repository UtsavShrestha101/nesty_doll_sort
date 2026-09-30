import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesty_core/nesty_core.dart' show StarRating;
import 'package:nesty_game/core/services/records/record_rules.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

part 'records_summary.freezed.dart';

/// What the Records screen shows (spec-prop §7.8, §10.2 #19; docs/plans/
/// m7-design.md §12, §15.2): read from the save, nothing stored twice.
@freezed
abstract class RecordsSummary with _$RecordsSummary {
  const factory RecordsSummary({
    /// `RecordRules.levelsWon`: campaign levels behind `highestLevel` plus
    /// the Bonus Endless levels won.
    @Default(0) int levelsWon,

    /// `records.families`.
    @Default(0) int families,

    /// `records.dolls`.
    @Default(0) int dolls,

    /// `records.dailies`.
    @Default(0) int dailies,

    /// `records.longestRun`: the longest unbroken daily run.
    @Default(0) int longestRun,

    /// Races won per rival, rivals 1–3 (`race.rivals[i].wins`; 0 until the
    /// race lands in phase 2).
    @Default(<int>[0, 0, 0]) List<int> raceWins,

    /// The badges earned, in `BadgeId` order.
    @Default(<BadgeId>[]) List<BadgeId> badges,

    /// Best stars earned over every level (`levelStars` summed; spec-prop
    /// §7.10, m7-design P3.5): Records' "Stars" row.
    @Default(0) int stars,

    /// `StarRating.maxStars` × the bundled levels with a par (600 at
    /// launch): the "Stars" row's total.
    @Default(0) int starsPossible,

    /// Levels at 3 stars: Records' "Levels with 3 stars" row.
    @Default(0) int threeStarLevels,
  }) = _RecordsSummary;

  /// The summary of [doc], with [levelCount] bundled levels
  /// (`LevelRepository.levelCount`), [starLevels] of them with a par
  /// (`StarRules.levelsWithPar`).
  factory RecordsSummary.of(
    SaveDocument doc, {
    required int levelCount,
    required int starLevels,
  }) => RecordsSummary(
    levelsWon: RecordRules.levelsWon(doc, levelCount: levelCount),
    families: doc.records.families,
    dolls: doc.records.dolls,
    dailies: doc.records.dailies,
    longestRun: doc.records.longestRun,
    raceWins: [for (final rival in doc.race.rivals) rival.wins],
    badges: doc.records.earned,
    stars: doc.levelStars.values.fold(0, (sum, stars) => sum + stars),
    starsPossible: StarRating.maxStars * starLevels,
    threeStarLevels: doc.levelStars.values
        .where((stars) => stars >= StarRating.maxStars)
        .length,
  );
}
