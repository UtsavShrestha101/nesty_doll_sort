import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/rules/rules.dart';

/// The star rating of a won campaign level (spec-prop §7.10, D125; the
/// plan is docs/plans/star-rating.md).
///
/// Every win earns 1, 2 or 3 stars from its moves against the level's par
/// (the fewest moves that solve it from its start, spec §6.3, written into
/// the bundle by `nesty_levels bundle build`):
///
/// - 3 stars at moves ≤ `threshold(par, star3SlackPct)`,
/// - 2 stars at moves ≤ `threshold(par, star2SlackPct)`,
/// - 1 star for any other win;
///
/// then at most [assistedMaxStars] for an assisted win (a hint used, or an
/// extra slot on the board), so stars can't be bought. Undo and restart
/// reach the rule only through the move count (spec §2.4), so they never
/// lower stars on their own.
///
/// Pure integer arithmetic, so the VM, dart2js and wasm agree (rule 7).
/// The slack percentages are Remote Config's `star3_slack_pct` (20) and
/// `star2_slack_pct` (60); the app clamps them into `0..`[maxSlackPct]
/// before calling. Stars are cosmetic: nothing in core reads them.
abstract final class StarRating {
  /// The most stars a win earns.
  static const int maxStars = 3;

  /// Every win earns at least this many (star-rating.md "Keeping a 1★ win
  /// a win").
  static const int minStars = 1;

  /// The most an assisted win earns (spec-prop §7.10: "a win that used a
  /// hint, or has an extra slot on the board, earns at most 2 stars").
  static const int assistedMaxStars = 2;

  /// The largest slack percentage [threshold] accepts. A technical bound,
  /// not a rule: it keeps `par × slackPct` exact on every platform for any
  /// par a solver can prove. The app clamps Remote Config into it.
  static const int maxSlackPct = 1000;

  /// `par + ⌈par × slackPct ÷ 100⌉`, computed as
  /// `par + (par × slackPct + 99) ~/ 100` (spec-prop §7.10). For par 12 at
  /// 20 %: 15; at 60 %: 20.
  ///
  /// Throws a [RangeError] when [par] is below 1 or [slackPct] is outside
  /// `0..`[maxSlackPct].
  static int threshold(int par, int slackPct) {
    if (par < 1) throw RangeError.range(par, 1, null, 'par');
    RangeError.checkValueInInterval(slackPct, 0, maxSlackPct, 'slackPct');
    return par + (par * slackPct + 99) ~/ 100;
  }

  /// The stars of a win in [moves] on a level of [par]: 3 when [moves] ≤
  /// `threshold(par, star3SlackPct)`, else 2 when [moves] ≤
  /// `threshold(par, star2SlackPct)`, else 1; then at most
  /// [assistedMaxStars] when [assisted].
  ///
  /// The rule is applied literally: a [star2SlackPct] below
  /// [star3SlackPct] only makes 2 stars unreachable.
  ///
  /// Throws a [RangeError] when [moves] is negative, [par] is below 1 or a
  /// slack is outside `0..`[maxSlackPct].
  static int starsFor({
    required int moves,
    required int par,
    required bool assisted,
    required int star3SlackPct,
    required int star2SlackPct,
  }) {
    RangeError.checkNotNegative(moves, 'moves');
    final three = threshold(par, star3SlackPct);
    final two = threshold(par, star2SlackPct);
    final stars = moves <= three
        ? maxStars
        : moves <= two
        ? 2
        : minStars;
    return assisted && stars > assistedMaxStars ? assistedMaxStars : stars;
  }

  /// [starsFor] of the won board [state]: its moves are
  /// `GameState.moveCount`, and it is assisted when [hintUsed] (a hint
  /// shown during the winning attempt, which only the app knows) or when
  /// an extra slot is on the board (`GameState.extraSlotCount > 0`; extra
  /// slots survive undo and restart, D22). Reading the board here means no
  /// caller can forget the extra-slot cap.
  ///
  /// Throws an [ArgumentError] when [state] is not won
  /// (`Rules.isWon`), and [starsFor]'s [RangeError]s.
  static int starsForWin(
    GameState state, {
    required int par,
    required bool hintUsed,
    required int star3SlackPct,
    required int star2SlackPct,
  }) {
    if (!Rules.isWon(state)) {
      throw ArgumentError.value(state, 'state', 'is not a won board');
    }
    return starsFor(
      moves: state.moveCount,
      par: par,
      assisted: hintUsed || state.extraSlotCount > 0,
      star3SlackPct: star3SlackPct,
      star2SlackPct: star2SlackPct,
    );
  }
}
