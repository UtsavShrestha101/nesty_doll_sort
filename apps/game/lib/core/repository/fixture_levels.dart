import 'package:nesty_core/nesty_core.dart';

/// The first three authored levels (`tools/levels/authored/L0001–L0003`,
/// as `bundle.json` ships them) for the fake env's `FakeLevelRepository`:
/// playable offline with no asset read, deterministic in widget tests.
///
/// Copies, not the bundle: widget tests must not depend on the bundle's
/// content, which is re-authored over time. `fake_level_repository_test`
/// checks each passes the loader's validation.
abstract final class FixtureLevels {
  static const _l0001 = '''
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

  static const _l0002 = '''
{
  "schemaVersion": 1,
  "id": "L0002",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["blue2"]},
      {"type": "open", "nest": null} ],
    [ {"type": "open", "nest": ["red2", "red1"]},
      {"type": "open", "nest": ["blue3"]},
      {"type": "open", "nest": ["blue1"]} ]
  ]
}
''';

  static const _l0003 = '''
{
  "schemaVersion": 1,
  "id": "L0003",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["yellow1"]},
      {"type": "open", "nest": ["blue1"]} ],
    [ {"type": "open", "nest": ["yellow2"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": ["red1"]} ],
    [ {"type": "open", "nest": ["blue3", "blue2"]},
      {"type": "open", "nest": ["red2"]},
      {"type": "open", "nest": ["yellow3"]} ]
  ]
}
''';

  /// (level JSON, tier, par) in play order, as the bundle lists them. Par is
  /// the solver's optimal solution length from the level's start
  /// (spec-prop §7.10, D125; m7-design P3.6): `fixture_levels_test` checks
  /// each against `Solver.solve`, so the JSON and its par never drift apart
  /// unnoticed.
  static const _levels = [
    (_l0001, Tier.easy, 2),
    (_l0002, Tier.easy, 3),
    (_l0003, Tier.medium, 5),
  ];

  /// The three entries at orders 1–3 of chapter `ch01`, paying their tier's
  /// default reward and carrying their solver par, so the fake env's wins
  /// earn stars like the real bundle's.
  static List<LevelBundleEntry> entries() => [
    for (var i = 0; i < _levels.length; i++)
      LevelBundleEntry(
        order: i + 1,
        chapterId: 'ch01',
        tier: _levels[i].$2,
        version: 1,
        rewardCoins: _levels[i].$2.defaultRewardCoins,
        level: _decode(_levels[i].$1),
        par: _levels[i].$3,
      ),
  ];

  static Level _decode(String json) {
    final result = LevelCodec.decodeString(json);
    return result.level ??
        (throw StateError('fixture level has issues: ${result.issues}'));
  }
}
