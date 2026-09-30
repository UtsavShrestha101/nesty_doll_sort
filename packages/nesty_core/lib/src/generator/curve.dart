import 'package:nesty_core/src/generator/generator_params.dart';
import 'package:nesty_core/src/simulator/bots.dart';
import 'package:nesty_core/src/simulator/tier.dart';

/// The difficulty curve and seeds for generated levels (spec §6.6, §7.1,
/// §7.5, and the race boards of spec-prop §7.7).
///
/// Levels are numbered by global play order from 1, so Bonus Endless
/// continues the curve where the published levels end (spec §7.1: "following
/// the curve"). Within every block of 10 levels the tier follows
/// [blockPattern]; the board a tier gets depends on the stage the level is
/// in (below).
///
/// ## Stage table (design A16; confirmed by the owner on 2026-09-26, Q34)
///
/// Stages follow the introduction schedule of spec §3.7; §6.6 has chapters
/// raise the baseline with more colors, larger sizes, more towers and fewer
/// empty slots. Every row has one set per color. `towers` is count × depth;
/// the bottom shelf never holds more than 4 slots (owner override D22).
///
/// | Levels | Tier | colors | maxSize | shelves × slots | towers | empty | locked | ice |
/// |---|---|---|---|---|---|---|---|---|
/// | 1 | all | 1 | 3 | 2 × 3 | – | 3 | – | – |
/// | 2 | all | 2 | 3 | 2 × 3 | – | 2 | – | – |
/// | 3–9 | E | 3 | 3 | 2 × 4 | – | 2 | – | – |
/// | | M | 3 | 3 | 3 × 3 | – | 2 | – | – |
/// | | H | 4 | 3 | 3 × 3 | – | 1 | – | – |
/// | | S | 4 | 3 | 3 × 4 | – | 2 | – | – |
/// | 10–15 | E | 3 | 4 | 3 × 3 | – | 2 | – | – |
/// | | M | 4 | 4 | 3 × 3 | – | 1 | – | – |
/// | | H | 4 | 4 | 3 × 4 | – | 2 | – | – |
/// | | S | 5 | 4 | 3 × 4 | – | 1 | – | – |
/// | 16–30 | E | 5 | 4 | 3 × 3 | 4 × 3 | 1 | – | – |
/// | | M | 6 | 4 | 3 × 3 | 5 × 4 | 1 | – | – |
/// | | H | 7 | 4 | 3 × 3 | 6 × 4 | 1 | – | – |
/// | | S | 8 | 4 | 3 × 3 | 7 × 4 | 1 | – | – |
/// | 31–50 | E | 6 | 4 | 3 × 3 | 4 × 3 | 1 | 1 | – |
/// | | M | 5 | 4 | 2 × 4 | 4 × 4 | 1 | 1 | – |
/// | | H | 6 | 4 | 3 × 3 | 5 × 4 | 1 | 1 | – |
/// | | S | 6 | 4 | 2 × 4 | 5 × 4 | 1 | 1 | – |
/// | 51–70 | E | 6 | 4 | 3 × 3 | 4 × 3 | 1 | – | 1 |
/// | | M | 6 | 4 | 3 × 3 | 5 × 3 | 1 | 1 | 1 |
/// | | H | 7 | 4 | 3 × 3 | 5 × 4 | 1 | 1 | 1 |
/// | | S | 7 | 4 | 3 × 3 | 6 × 4 | 1 | – | 1 |
/// | 71–120 | E | 6 | 5 | 3 × 3 | 4 × 3 | 1 | 1 | 1 |
/// | | M | 6 | 5 | 3 × 3 | 4 × 4 | 1 | 1 | – |
/// | | H | 6 | 5 | 3 × 3 | 5 × 4 | 1 | – | 1 |
/// | | S | 6 | 5 | 3 × 3 | 7 × 4 | 1 | – | – |
/// | 121+ | E, M, H | as 71–120 | | | | | | |
/// | | S | 6 | 6 | 3 × 3 | 7 × 4 | 1 | – | – |
///
/// Why these boards: the casual bot (spec §6.4) wins every run on a board
/// with no towers: open slots are interchangeable, so a placement changes
/// nothing, and every merge is progress. Levels 1–15 therefore simulate as
/// easy whatever their target, and the generator returns the closest tier
/// (design A15). From level 16 each row was measured over 100 generator
/// attempts to hit its own tier on at least about a quarter of them, so 50
/// attempts (spec §6.5) practically always match. Gold (level 101) is v1.1
/// and not generated (D22).
///
/// ## Daily puzzle (spec §7.5)
///
/// Tier medium on Monday–Friday and hard on Saturday and Sunday, on the
/// 31–50 boards (towers and one lock, no ice), so a daily needs no mechanic
/// introduced after level 31.
///
/// ## vs Computer (spec-prop §7.7, the rule until the owner pastes it, Q85)
///
/// "rival 1 plays like the casual bot (§6.4) … on an easy board; rival 2
/// like the smart bot … on a medium board; rival 3 like the smart bot … on a
/// medium board. … No other bot policy is used." "Board: made by the
/// generator from the curve's params for the rival's tier, at the stage of
/// the player's highest level, with seed `3_000_000 + rival × 100_000 +
/// raceNo`."
///
/// | Rival | [racePolicy] | [raceTier] | [raceSeed] range |
/// |---|---|---|---|
/// | 1 | casual | easy | 3,100,001–3,199,999 |
/// | 2 | smart | medium | 3,200,001–3,299,999 |
/// | 3 | smart | medium | 3,300,001–3,399,999 |
///
/// The stage is the one of the highest campaign level the player has won,
/// so a race only uses mechanics the player has met (spec §3.7). Reading
/// "the player's highest level" as the highest level won is the default of
/// an owner question (docs/plans/m7-design.md, Phase 2). Race tiers are
/// never superhard, so no race board has `maxSize` 6.
///
/// docs/plans/mode-vs-computer.md (rule 3) says the seed "can't collide with
/// the daily (yyyymmdd) or bonus seeds (1_000_000 + N)". That holds for
/// every seed a player can reach, though not for every integer: bonus seeds
/// reach the race block only from level 2,100,001, and daily seeds only in
/// the years 310–339 (3,101,015 reads as 0310-10-15). Keeping the formula,
/// with `raceNo` at most [maxRaceNo], is the default of an owner question
/// (docs/plans/m7-design.md, Phase 2).
abstract final class DifficultyCurve {
  /// The tier pattern inside every block of 10 levels:
  /// `E E M E M H M E M S` (spec §6.6).
  static const List<Tier> blockPattern = [
    Tier.easy,
    Tier.easy,
    Tier.medium,
    Tier.easy,
    Tier.medium,
    Tier.hard,
    Tier.medium,
    Tier.easy,
    Tier.medium,
    Tier.superhard,
  ];

  /// The largest level number the curve accepts.
  static const int maxLevelNumber = 1 << 30;

  /// The tier of level [levelNumber] (1-based) by [blockPattern].
  static Tier tierForLevel(int levelNumber) {
    RangeError.checkValueInInterval(
      levelNumber,
      1,
      maxLevelNumber,
      'levelNumber',
    );
    return blockPattern[(levelNumber - 1) % blockPattern.length];
  }

  /// The generator params for level [levelNumber] of the curve, played as a
  /// Bonus Endless level (spec §7.1): the board of its stage and tier (see
  /// the table above), targeting [tierForLevel], seeded with [bonusSeed],
  /// with id `bonus-<levelNumber>`.
  ///
  /// [levelNumber] is the global play order, not the count of bonus levels,
  /// so a player past the last published level keeps getting harder
  /// boards. Throws a [RangeError] outside 1..[maxLevelNumber].
  static GeneratorParams bonusParams(int levelNumber) {
    final tier = tierForLevel(levelNumber);
    return _stageFor(levelNumber)
        .board(tier)
        .toParams(
          tier: tier,
          seed: bonusSeed(levelNumber),
          id: 'bonus-$levelNumber',
        );
  }

  /// The generator params for the daily puzzle of [yyyymmdd] (spec §7.5),
  /// such as 20260926: [dailyTier] on the daily boards, seeded with the date
  /// itself, with id `daily-<yyyymmdd>`.
  ///
  /// Spec §7.5 pins the generator version for dailies: every device must
  /// run `Generator.version` 1's pipeline for a date, or two players would
  /// get different puzzles (M3). Throws a [RangeError] when [yyyymmdd] is
  /// not a real date of years 1–9999.
  static GeneratorParams dailyParams(int yyyymmdd) {
    final tier = dailyTier(yyyymmdd);
    return _dailyStage
        .board(tier)
        .toParams(tier: tier, seed: yyyymmdd, id: 'daily-$yyyymmdd');
  }

  /// The daily puzzle's tier on [yyyymmdd] (spec §7.5 "tier medium/hard"):
  /// hard on Saturday and Sunday, medium on the other days. Throws a
  /// [RangeError] when [yyyymmdd] is not a real date of years 1–9999.
  static Tier dailyTier(int yyyymmdd) {
    RangeError.checkValueInInterval(yyyymmdd, 10101, 99991231, 'yyyymmdd');
    final year = yyyymmdd ~/ 10000;
    final month = yyyymmdd ~/ 100 % 100;
    final day = yyyymmdd % 100;
    _checkDate(year, month, day, 'yyyymmdd');
    final weekday = _weekday(year, month, day);
    return weekday == 0 || weekday == 6 ? Tier.hard : Tier.medium;
  }

  /// Spec §7.1: `seed = 1_000_000 + levelNumber`.
  static int bonusSeed(int levelNumber) => 1000000 + levelNumber;

  /// Spec §7.5: `seed = yyyymmdd`, e.g. 20260926. The date is the caller's
  /// (core never reads the clock, CLAUDE.md rule 7). Throws a [RangeError]
  /// for a date that doesn't exist, such as February 30.
  static int dailySeed(int year, int month, int day) {
    RangeError.checkValueInInterval(year, 1, 9999, 'year');
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    RangeError.checkValueInInterval(day, 1, 31, 'day');
    _checkDate(year, month, day, 'day');
    return year * 10000 + month * 100 + day;
  }

  /// The rivals of vs Computer, numbered 1 to [raceRivals] (spec-prop §7.7:
  /// "Three rivals unlock in turn").
  static const int raceRivals = 3;

  /// The largest `raceNo`: below 100,000, so each rival's seeds stay in its
  /// own block of [raceSeed]. What New race does at the cap is the app's
  /// (the default of an owner question: it replays the last board).
  static const int maxRaceNo = 99999;

  /// Spec-prop §7.7: `seed = 3_000_000 + rival × 100_000 + raceNo`, for
  /// [rival] 1..[raceRivals] and [raceNo] 1..[maxRaceNo] (spec-prop §7.7
  /// "`raceNo` counts that rival's races from 1"). Throws a [RangeError]
  /// for anything else.
  ///
  /// It seeds the race's board ([raceParams]) and the rival's runs
  /// (`RivalBot.runSeed`), so a Rematch, which keeps `raceNo`, replays the
  /// same board and the same rival moves.
  static int raceSeed(int rival, int raceNo) {
    _checkRival(rival);
    RangeError.checkValueInInterval(raceNo, 1, maxRaceNo, 'raceNo');
    return 3000000 + rival * 100000 + raceNo;
  }

  /// How [rival] plays (spec-prop §7.7): rival 1 like the casual bot, rivals
  /// 2 and 3 like the smart bot (spec §6.4). Throws a [RangeError] for a
  /// rival outside 1..[raceRivals].
  static SimBot racePolicy(int rival) {
    _checkRival(rival);
    return rival == 1 ? SimBot.casual : SimBot.smart;
  }

  /// The tier of [rival]'s boards (spec-prop §7.7, default of Q80): easy for
  /// rival 1, medium for rivals 2 and 3. Throws a [RangeError] for a rival
  /// outside 1..[raceRivals].
  static Tier raceTier(int rival) {
    _checkRival(rival);
    return rival == 1 ? Tier.easy : Tier.medium;
  }

  /// The generator params of race [raceNo] against [rival] (spec-prop
  /// §7.7): the board of [raceTier] at the stage of [highestWonLevel] (see
  /// the table above), targeting that tier, seeded with [raceSeed], with id
  /// `race-<rival>-<raceNo>`.
  ///
  /// [highestWonLevel] is the highest campaign level (global play order)
  /// the player has won, so the board only uses mechanics they have met
  /// (spec §3.7; see the class doc). The app works it out from its save;
  /// core takes it as given. Throws a [RangeError] for a rival outside
  /// 1..[raceRivals], a [raceNo] outside 1..[maxRaceNo] or a
  /// [highestWonLevel] outside 1..[maxLevelNumber].
  static GeneratorParams raceParams({
    required int rival,
    required int raceNo,
    required int highestWonLevel,
  }) {
    final seed = raceSeed(rival, raceNo);
    RangeError.checkValueInInterval(
      highestWonLevel,
      1,
      maxLevelNumber,
      'highestWonLevel',
    );
    final tier = raceTier(rival);
    final board = _stageFor(highestWonLevel).board(tier);
    return board.toParams(tier: tier, seed: seed, id: 'race-$rival-$raceNo');
  }

  static void _checkRival(int rival) =>
      RangeError.checkValueInInterval(rival, 1, raceRivals, 'rival');

  static void _checkDate(int year, int month, int day, String name) {
    if (year < 1 || month < 1 || month > 12 || day < 1) {
      throw RangeError('$year-$month-$day is not a date ($name)');
    }
    final leap = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
    final days = month == 2
        ? (leap ? 29 : 28)
        : const [31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1];
    if (day > days) {
      throw RangeError.range(day, 1, days, name, 'Day of $year-$month');
    }
  }

  /// The proleptic Gregorian weekday, 0 = Sunday … 6 = Saturday, by
  /// Sakamoto's method. Integer arithmetic only, so it can't depend on a
  /// platform's calendar or time zone (CLAUDE.md rule 7).
  static int _weekday(int year, int month, int day) {
    const offsets = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4];
    final y = month < 3 ? year - 1 : year;
    return (y + y ~/ 4 - y ~/ 100 + y ~/ 400 + offsets[month - 1] + day) % 7;
  }

  static _Stage _stageFor(int levelNumber) {
    for (var i = _stages.length - 1; i > 0; i--) {
      if (levelNumber >= _stages[i].firstLevel) return _stages[i];
    }
    return _stages.first;
  }

  // The stage table documented on the class, in level order: the owner's
  // curve (design A16, confirmed 2026-09-26, Q34). Any change to it changes
  // generated levels, so it bumps Generator.version and needs new goldens
  // and parity values (test/generator/, test/parity/).
  static const _stages = [
    _Stage.all(
      1,
      _Board(colors: 1, maxSize: 3, shelves: 2, slots: 3, empty: 3),
    ),
    _Stage.all(
      2,
      _Board(colors: 2, maxSize: 3, shelves: 2, slots: 3, empty: 2),
    ),
    _Stage(
      3,
      easy: _Board(colors: 3, maxSize: 3, shelves: 2, slots: 4, empty: 2),
      medium: _Board(colors: 3, maxSize: 3, shelves: 3, slots: 3, empty: 2),
      hard: _Board(colors: 4, maxSize: 3, shelves: 3, slots: 3, empty: 1),
      superhard: _Board(colors: 4, maxSize: 3, shelves: 3, slots: 4, empty: 2),
    ),
    _Stage(
      10,
      easy: _Board(colors: 3, maxSize: 4, shelves: 3, slots: 3, empty: 2),
      medium: _Board(colors: 4, maxSize: 4, shelves: 3, slots: 3, empty: 1),
      hard: _Board(colors: 4, maxSize: 4, shelves: 3, slots: 4, empty: 2),
      superhard: _Board(colors: 5, maxSize: 4, shelves: 3, slots: 4, empty: 1),
    ),
    _Stage(
      16,
      easy: _Board(colors: 5, maxSize: 4, towers: 4, depth: 3),
      medium: _Board(colors: 6, maxSize: 4, towers: 5, depth: 4),
      hard: _Board(colors: 7, maxSize: 4, towers: 6, depth: 4),
      superhard: _Board(colors: 8, maxSize: 4, towers: 7, depth: 4),
    ),
    _Stage(
      31,
      easy: _Board(colors: 6, maxSize: 4, towers: 4, depth: 3, locked: 1),
      medium: _Board(
        colors: 5,
        maxSize: 4,
        shelves: 2,
        slots: 4,
        towers: 4,
        depth: 4,
        locked: 1,
      ),
      hard: _Board(colors: 6, maxSize: 4, towers: 5, depth: 4, locked: 1),
      superhard: _Board(
        colors: 6,
        maxSize: 4,
        shelves: 2,
        slots: 4,
        towers: 5,
        depth: 4,
        locked: 1,
      ),
    ),
    _Stage(
      51,
      easy: _Board(colors: 6, maxSize: 4, towers: 4, depth: 3, ice: 1),
      medium: _Board(
        colors: 6,
        maxSize: 4,
        towers: 5,
        depth: 3,
        locked: 1,
        ice: 1,
      ),
      hard: _Board(
        colors: 7,
        maxSize: 4,
        towers: 5,
        depth: 4,
        locked: 1,
        ice: 1,
      ),
      superhard: _Board(colors: 7, maxSize: 4, towers: 6, depth: 4, ice: 1),
    ),
    _Stage(
      71,
      easy: _size5Easy,
      medium: _size5Medium,
      hard: _size5Hard,
      superhard: _Board(colors: 6, maxSize: 5, towers: 7, depth: 4),
    ),
    _Stage(
      121,
      easy: _size5Easy,
      medium: _size5Medium,
      hard: _size5Hard,
      superhard: _Board(colors: 6, maxSize: 6, towers: 7, depth: 4),
    ),
  ];

  static const _size5Easy = _Board(
    colors: 6,
    maxSize: 5,
    towers: 4,
    depth: 3,
    locked: 1,
    ice: 1,
  );
  static const _size5Medium = _Board(
    colors: 6,
    maxSize: 5,
    towers: 4,
    depth: 4,
    locked: 1,
  );
  static const _size5Hard = _Board(
    colors: 6,
    maxSize: 5,
    towers: 5,
    depth: 4,
    ice: 1,
  );

  // The 31–50 medium and hard boards (see the class doc).
  static final _Stage _dailyStage = _stageFor(31);
}

/// The four boards of one stage of the curve, one per tier.
final class _Stage {
  const _Stage(
    this.firstLevel, {
    required this.easy,
    required this.medium,
    required this.hard,
    required this.superhard,
  });

  const _Stage.all(this.firstLevel, _Board board)
    : easy = board,
      medium = board,
      hard = board,
      superhard = board;

  final int firstLevel;
  final _Board easy;
  final _Board medium;
  final _Board hard;
  final _Board superhard;

  _Board board(Tier tier) => switch (tier) {
    Tier.easy => easy,
    Tier.medium => medium,
    Tier.hard => hard,
    Tier.superhard => superhard,
  };
}

/// A row of the stage table: every generator param except the tier, seed
/// and id. The defaults are the most common board, 3 × 3 with one empty
/// slot.
final class _Board {
  const _Board({
    required this.colors,
    required this.maxSize,
    this.shelves = 3,
    this.slots = 3,
    this.towers = 0,
    this.depth = 2,
    this.empty = 1,
    this.locked = 0,
    this.ice = 0,
  });

  final int colors;
  final int maxSize;
  final int shelves;
  final int slots;
  final int towers;
  final int depth;
  final int empty;
  final int locked;
  final int ice;

  GeneratorParams toParams({
    required Tier tier,
    required int seed,
    required String id,
  }) => GeneratorParams(
    colors: colors,
    maxSize: maxSize,
    shelves: shelves,
    slotsPerShelf: slots,
    towers: towers,
    towerDepth: depth,
    emptySlots: empty,
    locked: locked,
    iceSlots: ice,
    targetTier: tier,
    seed: seed,
    id: id,
  );
}
