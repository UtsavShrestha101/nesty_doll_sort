import 'package:nesty_core/nesty_core.dart' show StarRating;
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';

/// The star rating's two slack percentages, read from Remote Config
/// (`star3_slack_pct`, `star2_slack_pct`; spec-prop §9.4, §7.10).
typedef StarSlack = ({int star3, int star2});

/// The app's glue around nesty_core's [StarRating] (spec-prop §7.10, D125;
/// docs/plans/m7-design.md P3.5): which boards earn stars, the Remote
/// Config slack clamped into the rule's range, the replay card's target
/// and the load-time backfill's grade. Pure, like `RecordRules`: the rule
/// itself stays in core (CLAUDE.md rule 2).
///
/// Stars are cosmetic: no reward, unlock or gate reads anything here
/// (`test/ethics/stars_gate_nothing_test.dart` pins it).
abstract final class StarRules {
  /// Each key clamped to `0..StarRating.maxSlackPct`, so a tuned value can
  /// never make the rule throw (rule 6: the defaults are 20 and 60).
  static StarSlack slackOf(RemoteConfigService config) => (
    star3: _clamp(config.value(RemoteConfigKeys.star3SlackPct)),
    star2: _clamp(config.value(RemoteConfigKeys.star2SlackPct)),
  );

  /// The `levelStars` key of [play]: its level id for a bundled board (a
  /// campaign level or a replay), else null: the daily, Bonus Endless and
  /// race boards earn no stars (spec-prop §7.10 "show moves only").
  static String? keyOf(PlayEntry play) =>
      play.request.isBundled ? play.level.id : null;

  /// The 3-star threshold of [play] (`StarRating.threshold(par,
  /// slack.star3)`), for the replay card's "3 stars at N moves or fewer"
  /// (Q118); null without a par ([PlayEntry.par]).
  static int? targetFor(PlayEntry play, StarSlack slack) {
    final par = play.par;
    return par == null ? null : StarRating.threshold(par, slack.star3);
  }

  /// The stars the load-time backfill gives a level won before stars
  /// existed (Q120): what its [best] moves earn, as if no hint was used,
  /// or 1 star when it has no best.
  static int backfill({
    required int par,
    required int? best,
    required StarSlack slack,
  }) => best == null
      ? StarRating.minStars
      : StarRating.starsFor(
          moves: best,
          par: par,
          assisted: false,
          star3SlackPct: slack.star3,
          star2SlackPct: slack.star2,
        );

  /// How many bundled levels have a par (each at exactly its own order):
  /// Records' possible stars are [StarRating.maxStars] × this (m7-design
  /// P3.5; 200 at launch, so 600).
  static int levelsWithPar(LevelRepository levels) {
    var count = 0;
    for (var order = 1; order <= levels.levelCount; order++) {
      final entry = levels.entryAt(order);
      if (entry == null) break;
      if (entry.order == order && entry.par != null) count++;
    }
    return count;
  }

  static int _clamp(int value) => value < 0
      ? 0
      : value > StarRating.maxSlackPct
      ? StarRating.maxSlackPct
      : value;
}
