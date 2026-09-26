/// A level's difficulty tier (spec §5.2, §6.4, §6.6), in increasing order of
/// difficulty.
enum Tier {
  easy('easy', defaultRewardCoins: 10),

  /// Pays like easy: spec §7.3 pays "easy/medium" 10, and §9.4 has no
  /// `reward_medium` key (PROGRESS Q5).
  medium('medium', defaultRewardCoins: 10),

  hard('hard', defaultRewardCoins: 25),

  /// Shows a "SUPER HARD" badge and pays more (spec §6.6, §7.3).
  superhard('superhard', defaultRewardCoins: 50);

  const Tier(this.id, {required this.defaultRewardCoins});

  /// The stable id used in level documents and the bundle (spec §5.2), e.g.
  /// `superhard`. Kept separate from [name] so renaming a Dart identifier can
  /// never change a stored format.
  final String id;

  /// Coins for winning a level of this tier (spec §7.3). The bundle records
  /// it per level (design A27); in the game, Remote Config can override it
  /// (spec §9.4).
  final int defaultRewardCoins;

  // Built once: the bundle decoder looks a tier up for every level.
  static final Map<String, Tier> _byId = {for (final t in values) t.id: t};

  /// The tier whose [id] is exactly [id], or null.
  static Tier? tryFromId(String id) => _byId[id];

  /// The tier whose [id] is exactly [id]. Throws a [FormatException] for
  /// anything else, including different case (a strict parse, like
  /// `DollColor.fromId`).
  static Tier fromId(String id) =>
      _byId[id] ??
      (throw FormatException(
        'Unknown tier id "$id". Expected one of: '
        '${values.map((t) => t.id).join(', ')}.',
        id,
      ));

  /// The tier for a casual-bot result of [wins] out of [runs] (spec §6.4):
  /// easy ≥ 0.65, medium ≥ 0.35, hard ≥ 0.12, else superhard. Each lower
  /// edge is inclusive (design A18).
  ///
  /// Integer arithmetic only, so a rate exactly on an edge can't round
  /// differently on the web (design §3 "no doubles"). At the simulator's 300
  /// runs the edges are 195, 105 and 36 wins.
  static Tier fromCasualWins(int wins, int runs) {
    if (runs <= 0) throw RangeError.value(runs, 'runs', 'must be positive');
    RangeError.checkValueInInterval(wins, 0, runs, 'wins');
    final percent = wins * 100;
    if (percent >= 65 * runs) return easy;
    if (percent >= 35 * runs) return medium;
    if (percent >= 12 * runs) return hard;
    return superhard;
  }

  /// How many tiers apart this and [other] are, for the generator's
  /// closest-tier fallback (spec §6.5 step 4, design A15).
  int distanceTo(Tier other) => (index - other.index).abs();
}
