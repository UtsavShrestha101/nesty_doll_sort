import 'package:nesty_core/nesty_core.dart' show StarRating;
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/records/star_rules.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// A star total and what it is out of: "39/60" (frame 2.1's chapter card,
/// frame 12.2's "552/600").
typedef StarTotal = ({int stars, int possible});

/// The star totals Home's chapter card shows (frames 2.1, 12.2; menus spec
/// 1.1): the PLAY level's chapter over its levels' par, and the whole
/// campaign's.
///
/// This is display only: stars gate, pay and unlock nothing (spec-prop
/// §7.10, D125). It lives with Chapters, whose totals these are, so the
/// Home feature itself never names the rule (`stars_gate_nothing_test`
/// scans `features/home` for exactly that).
abstract final class ChapterStarTally {
  /// [chapter]'s best stars over its levels, out of `StarRating.maxStars` ×
  /// the levels the bundle has with a par (60 for a full chapter).
  static StarTotal ofChapter(
    ChapterInfo chapter, {
    required SaveDocument document,
    required LevelRepository levels,
  }) {
    final first = chapter.firstOrder;
    var stars = 0;
    var withPar = 0;
    for (var order = first; order < first + chapter.levels; order++) {
      final entry = levels.entryAt(order);
      if (entry == null || entry.order != order) continue;
      if (entry.par != null) withPar++;
      stars += document.levelStars[entry.level.id] ?? 0;
    }
    return (stars: stars, possible: StarRating.maxStars * withPar);
  }

  /// Every level's best stars, out of `StarRating.maxStars` × the bundled
  /// levels with a par (600 at launch): Bonus Endless's chip.
  static StarTotal ofCampaign({
    required SaveDocument document,
    required LevelRepository levels,
  }) => (
    stars: document.levelStars.values.fold(0, (sum, stars) => sum + stars),
    possible: StarRating.maxStars * StarRules.levelsWithPar(levels),
  );
}
