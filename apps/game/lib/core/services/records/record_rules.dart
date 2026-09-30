import 'dart:math' as math;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// What a won board adds to the lifetime records, and the records derived
/// from the rest of the save (spec-prop §7.8; docs/plans/m7-design.md §12).
/// Pure: the bloc hands [familiesIn] and [dollsNestedIn] to
/// `LevelWinRecord`, the Records screen reads [levelsWon].
///
/// Counted per won board, from the level itself, so undo, restart and the
/// route the player took never change them. Every mode counts: campaign,
/// replay, bonus, daily, and the race in phase 2.
abstract final class RecordRules {
  /// The families a won [level] completed: all of them (spec §2.3).
  static int familiesIn(Level level) => level.totalSets;

  /// The dolls a won [level] nested: every doll that ends inside another,
  /// which is all but each family's outer doll. A valid level holds
  /// `maxSize` dolls per family (spec §5.3 rule 4), so it is `totalSets ×
  /// (maxSize − 1)`. (The v1.1 golden doll would need its own count,
  /// spec §3.5.)
  static int dollsNestedIn(Level level) =>
      math.max(0, level.totalSets * (level.maxSize - 1));

  /// Levels won (the Records screen, m7-design §12): the campaign levels
  /// behind `highestLevel` that the bundle has ([levelCount]), plus the
  /// Bonus Endless levels behind `bonus.next`. Replays and dailies don't
  /// add (a replay wins a level already counted; dailies have their own
  /// record).
  static int levelsWon(SaveDocument doc, {required int levelCount}) {
    final campaign = math.max(
      0,
      math.min(doc.highestLevel - 1, math.max(0, levelCount)),
    );
    return campaign + math.max(0, doc.bonus.next - 1);
  }
}

/// The key of a bundled level's best moves (spec-prop §7.1 "for that level
/// id and version", §13.3 `"levelBests": {"L0024@2": 16}`; m7-design §11).
abstract final class LevelBests {
  /// `<levelId>@<version>`, such as `L0024@2`.
  static String key(String levelId, int version) => '$levelId@$version';

  /// [play]'s key when its board keeps a best (a campaign level or a
  /// replay, the bundle entry's id and version); null for generated boards
  /// (bonus, daily, race), whose win cards show the moves only.
  static String? keyOf(PlayEntry play) =>
      play.request.isBundled ? key(play.level.id, play.levelVersion) : null;
}
