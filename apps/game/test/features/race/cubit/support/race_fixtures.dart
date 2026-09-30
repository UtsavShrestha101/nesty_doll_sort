import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

import '../../../../helpers/level_fixtures.dart';

/// A dead board for the rival (`packages/nesty_core/test/simulator/
/// support/sim_levels.dart` 'lockDeadlock', `test/fixtures/unsolvable/
/// 001_lock_deadlock.json`): every legal move at the start is pointless
/// (`rival_bot_test.dart` "lockDeadlock: no useful move at the start, so
/// every step restarts"), so `RivalBot.step` restarts on every call
/// whatever the policy or seed. Used only to pin the cubit's `restarted` →
/// [RivalActivity.startingOver] mapping (m7-design P2.5); the player's
/// side never has to win it.
const lockDeadlockLevelJson = '''
{
  "schemaVersion": 1,
  "id": "u001_lock_deadlock",
  "maxSize": 3,
  "shelves": [
    [ {"type": "locked", "unlockColor": "red", "nest": ["blue3", "blue2"]},
      {"type": "locked", "unlockColor": "blue", "nest": ["red3", "red2"]},
      {"type": "open", "nest": ["red1"]} ],
    [ {"type": "open", "nest": ["blue1"]},
      {"type": "open", "nest": null} ]
  ]
}
''';

final Level lockDeadlockLevel = levelFrom(lockDeadlockLevelJson);

/// A [PlayEntry] for [request] playing [level], as the resolver's race
/// case would build it (m7-design P2.4): easy tier, [rewardCoins] coins,
/// the current generator version, no chapter.
PlayEntry raceEntry(RacePlay request, Level level, {int rewardCoins = 20}) =>
    PlayEntry(
      request: request,
      level: level,
      tier: Tier.easy,
      levelVersion: Generator.version,
      rewardCoins: rewardCoins,
      themeId: 'ch02',
    );

/// A save past `race_unlock_level` (the default 20), its rivals as given
/// (rival 1 unlocked by default, `RaceProgress()`).
SaveDocument unlockedRaceDocument({RaceProgress race = const RaceProgress()}) =>
    SaveDocument(currentLevel: 21, highestLevel: 21, race: race);
