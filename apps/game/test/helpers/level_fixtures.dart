import 'package:nesty_core/nesty_core.dart';

/// `tools/levels/authored/L0001.json`, the Level 1 tutorial board (one
/// colour, maxSize 3, 2 shelves): 3 → 2 → 1 nests and a win.
const tutorialLevelJson = '''
{
  "schemaVersion": 1,
  "id": "L0001",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": ["red2"]} ],
    [ {"type": "open", "nest": null},
      {"type": "open", "nest": ["red1"]},
      {"type": "open", "nest": null} ]
  ]
}
''';

/// A decoded level; throws if [json] has issues.
Level levelFrom(String json) {
  final result = LevelCodec.decodeString(json);
  final level = result.level;
  if (level == null) throw StateError('fixture level: ${result.issues}');
  return level;
}

/// A bundle entry for [level] at play [order] (chapter 1, easy, 10 coins).
/// [par] is null (no stars) unless a test names the solver's optimal
/// length (spec-prop §7.10; m7-design P3.6).
LevelBundleEntry entryFor(
  Level level, {
  int order = 1,
  Tier tier = Tier.easy,
  String chapterId = 'ch01',
  int? par,
}) => LevelBundleEntry(
  order: order,
  chapterId: chapterId,
  tier: tier,
  version: 1,
  rewardCoins: tier.defaultRewardCoins,
  level: level,
  par: par,
);
