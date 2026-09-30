import 'package:nesty_core/nesty_core.dart';

/// `report --stars` (m7-design P3.3; star-rating.md "Keeping a 1★ win a
/// win": "Before release, the levels tool reports what share of the smart
/// and casual bots' wins would get each star count per chapter, so the
/// owner can tune the two keys"). A report, never a gate.
///
/// Every number comes from nesty_core (CLAUDE.md rule 2): the bots are the
/// race's [RivalBot], which plays exactly the simulator's casual and smart
/// policies (spec §6.4), and the stars are [StarRating.starsFor] of the
/// won run's moves against the level's par, unassisted (the bots never use
/// a hint or an extra slot). Run `s` of a level is `RivalBot(level, policy:,
/// raceSeed: s)` stepped to its first `finished` (a win in `moveCount`
/// moves) or `restarted` (a loss), so no simulator change or
/// `Generator.version` bump is involved.
abstract final class StarReport {
  /// The slack defaults, mirroring the game's Remote Config keys
  /// `star3_slack_pct` and `star2_slack_pct` (spec-prop §9.4). The tools
  /// can't import the app, so a change there must be copied here.
  static const int defaultStar3SlackPct = 20;
  static const int defaultStar2SlackPct = 60;

  /// Runs per bot and level, as the simulator's (spec §6.4).
  static const int defaultRuns = SimulatorParams.defaultRuns;

  /// The largest `--runs`: race seeds stay far inside `Prng.maxSeed`.
  static const int maxRuns = 100000;

  /// The shares of [levels] (each with its proven par) per chapter and bot,
  /// chapters in first-appearance order, casual before smart; then, when
  /// there is more than one chapter, `all` for each bot.
  static List<StarShares> of(
    List<({String chapterId, Level level, int par})> levels, {
    int star3SlackPct = defaultStar3SlackPct,
    int star2SlackPct = defaultStar2SlackPct,
    int runs = defaultRuns,
  }) {
    RangeError.checkValueInInterval(runs, 1, maxRuns, 'runs');
    final byChapter = <String, Map<SimBot, StarShares>>{};
    final all = {for (final bot in SimBot.values) bot: StarShares('all', bot)};
    for (final (:chapterId, :level, :par) in levels) {
      final rows = byChapter.putIfAbsent(
        chapterId,
        () => {
          for (final bot in SimBot.values) bot: StarShares(chapterId, bot),
        },
      );
      for (final bot in SimBot.values) {
        final row = rows[bot]!..levels += 1;
        all[bot]!.levels += 1;
        for (var seed = 0; seed < runs; seed++) {
          final moves = _wonMoves(level, bot, seed);
          final stars = moves == null
              ? null
              : StarRating.starsFor(
                  moves: moves,
                  par: par,
                  assisted: false,
                  star3SlackPct: star3SlackPct,
                  star2SlackPct: star2SlackPct,
                );
          row.add(stars);
          all[bot]!.add(stars);
        }
      }
    }
    return [
      for (final rows in byChapter.values) ...rows.values,
      if (byChapter.length > 1) ...all.values,
    ];
  }

  /// The moves of race seed [seed]'s first run, or null when it can't be
  /// won (the rival restarts).
  static int? _wonMoves(Level level, SimBot bot, int seed) {
    final rival = RivalBot(level, policy: bot, raceSeed: seed);
    while (true) {
      switch (rival.step()) {
        case RivalStep.moved:
          continue;
        case RivalStep.finished:
          return rival.moveCount;
        case RivalStep.restarted:
          return null;
      }
    }
  }
}

/// One row of [StarReport.of]: a chapter's (or `all` levels') runs for one
/// bot, and how many of the won runs earn 3, 2 and 1 stars.
final class StarShares {
  StarShares(this.chapterId, this.bot);

  final String chapterId;
  final SimBot bot;

  int levels = 0;
  int runs = 0;
  int wins = 0;

  /// Won runs by stars: `[1★, 2★, 3★]`.
  final List<int> byStars = [0, 0, 0];

  /// Won runs at [stars] (1–3).
  int at(int stars) => byStars[stars - 1];

  void add(int? stars) {
    runs++;
    if (stars == null) return;
    wins++;
    byStars[stars - 1]++;
  }

  /// [count] of [total] as a percentage with one decimal, rounded down
  /// (`65.3%`), like the simulator columns; `-` when [total] is 0.
  static String share(int count, int total) {
    if (total == 0) return '-';
    final tenths = count * 1000 ~/ total;
    return '${tenths ~/ 10}.${tenths % 10}%';
  }

  Map<String, Object?> toJson() => {
    'chapterId': chapterId,
    'bot': bot.name,
    'levels': levels,
    'runs': runs,
    'wins': wins,
    'stars3': at(3),
    'stars2': at(2),
    'stars1': at(1),
  };
}
