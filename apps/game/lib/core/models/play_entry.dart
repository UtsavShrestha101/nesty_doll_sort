import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_request.dart';

part 'play_entry.freezed.dart';

/// A [PlayRequest] made playable by `LevelResolver.resolve`
/// (docs/plans/m3-design.md §6.2): the level, how it is graded and paid,
/// and where it sits (chapter, theme).
@freezed
abstract class PlayEntry with _$PlayEntry {
  const factory PlayEntry({
    /// What was asked for.
    required PlayRequest request,

    /// The board (a bundled level, or one generated on the device).
    required Level level,

    /// Its tier: the bundle's for a campaign level; the simulated tier of a
    /// bonus level (it plays as its tier, Q31); `DifficultyCurve.dailyTier`
    /// for the daily (spec §7.5 "tier medium/hard").
    required Tier tier,

    /// What the in-progress save must match to restore (spec §13.3): the
    /// bundle entry's `version`, or the generated level's
    /// `generatorVersion`.
    required int levelVersion,

    /// Coins a win pays: `winRewardFor(tier)` for campaign and bonus levels,
    /// `daily_reward` for the daily (spec §7.3, §9.4). The chapter bonus is
    /// separate (m3-design §7.1).
    required int rewardCoins,

    /// The chapter theme behind the board when the player keeps "Match each
    /// chapter" (`selectedTheme` null, spec §7.4): the level's chapter's
    /// theme, the last chapter's for a bonus level, the player's current
    /// chapter's for the daily (m3-design §9.1).
    required String themeId,

    /// A campaign level's chapter, such as `ch03`; null for bonus and
    /// daily boards (they sit outside the chapters, m3-design §7.4).
    String? chapterId,

    /// A campaign level that is its chapter's last: its win completes the
    /// chapter (m3-design §9.3).
    @Default(false) bool completesChapter,

    /// A generated level the simulator flags "expert only" (spec §6.4). It
    /// plays as its tier and nothing is shown (Q31, m3-design §7.4).
    @Default(false) bool expertOnly,

    /// A campaign level's bundle entry (the M2 widgets read it).
    LevelBundleEntry? bundleEntry,
  }) = _PlayEntry;

  const PlayEntry._();

  PlayKind get kind => request.kind;

  /// The star rating's par (spec-prop §7.10; m7-design P3.5): the bundle
  /// entry's `LevelBundleEntry.par` for a bundled board (a campaign level
  /// or a replay), else null, so the daily, Bonus Endless and race boards
  /// compute no stars. Null too for an entry the bundle has no par for.
  int? get par => request.isBundled ? bundleEntry?.par : null;
}
