import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';

/// Turns a [PlayRequest] into a playable [PlayEntry]
/// (docs/plans/m3-design.md §6.2).
///
/// - `campaign(order)`: the bundle's entry at `order`
///   (`LevelRepository.entryAt`, so a skipped invalid level gives the next
///   one), graded by its tier, paid `winRewardFor(tier)`, in its chapter.
/// - `bonus(n)`: `DifficultyCurve.bonusParams(levelCount + n)`, generated
///   by `LevelGeneratorService`, graded by its simulated tier, outside the
///   chapters (the last chapter's theme).
/// - `daily(yyyymmdd)`: `DifficultyCurve.dailyParams(yyyymmdd)`, generated
///   the same way, graded `dailyTier`, paid `daily_reward`, on the player's
///   current chapter's theme.
///
/// A generated board whose in-progress save matches the request is rebuilt
/// from the level JSON it embeds, never regenerated (m3-design §3.4).
/// Generated entries are kept for the last few requests, so a prefetched
/// bonus level or today's daily resolves at once.
///
/// `DefaultLevelResolver` (the services lane) serves both environments: it
/// composes `LevelRepository`, `LevelGeneratorService`,
/// `RemoteConfigService`, `SaveService` and `CatalogRepository`, which the
/// fake env fakes. `FakeLevelResolver` is for unit tests.
abstract interface class LevelResolver {
  /// The entry for [request], or null when it can't be played: a campaign
  /// order past `levelCount`, a daily date that doesn't exist, or a
  /// generated level whose every retry failed (the page then offers a
  /// retry). Never throws.
  Future<PlayEntry?> resolve(PlayRequest request);

  /// Starts resolving [request] without waiting: the win overlay prefetches
  /// the next bonus level, the Daily screen today's puzzle. A later
  /// [resolve] of the same request joins it.
  void prefetch(PlayRequest request);

  /// What follows [request] on Continue: the next campaign order, or past
  /// the last published level `bonus(SaveService.nextBonus)` (All Levels
  /// Done shows first, frame 4.9); the next bonus number; nothing after a
  /// daily (the player goes back to Daily, frame 5.4).
  PlayRequest? next(PlayRequest request);

  /// What Home's PLAY starts: `campaign(currentLevel)` while that level
  /// exists, else `bonus(nextBonus)` (m3-design §7.4).
  PlayRequest get homeRequest;
}
