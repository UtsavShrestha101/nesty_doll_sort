// Hand-worked expectations for the level fixtures in test/fixtures/ (design
// §5, Q19). The fixture files stay pure spec §5.1 JSON; what a search must
// find in them lives here, keyed by file name without `.json`. The folder a
// file sits in is its verdict (test/fixtures/README.md), and
// test/validator/fixtures_test.dart checks that these tables name exactly the
// files on disk.
//
// Every number below was worked out by hand from the rules of spec §4 (the
// reasoning is next to each entry) and cross-checked with an independent
// exhaustive search written from the spec, not from this package. The lower
// bound used throughout is the solver's heuristic (spec §6.3): a merge lowers
// `nests − setsRemaining` by exactly 1 (a completing merge removes two nests
// and one remaining set) and a placement leaves it unchanged, so a level
// needs at least `nests − sets` moves, and exactly that many when merges
// alone can win it.
library;

/// Optimal move counts (spec §5.2 `metrics.solverMoves`) for
/// test/fixtures/solvable/. With A* each count is the length of
/// `SolveResult.solution` at the admin budget.
const Map<String, int> solvableFixtureMoves = {
  // Tutorial level 1 (design TUT1): red3, red2 and red1 apart, one color,
  // maxSize 3. 3 nests − 1 set = 2 merges: red1 into red2, then [red2, red1]
  // into red3 (or red2 into red3 first).
  '001_l1_tutorial': 2,
  // Tutorial level 2 (design TUT2): red3 swallows [red2, red1] in one move
  // (spec §2.2 rule 3: T.outer 2 == M.inner 3 − 1); blue3, blue2 and blue1
  // need two merges. 5 nests − 2 sets = 3.
  '002_l2_swallow': 3,
  // The spec §5.1 example. [red4, red3] swallows the tower's top [red2, red1]
  // and completes red in the tower: the tower reveals green4, the red lock
  // on r1c0 opens and the ice on r1c1 drops to 1. [green3, green2, green1]
  // into green4 completes green (the ice shatters, the tower reveals blue2).
  // blue1 into blue2, then [blue2, blue1] into [blue4, blue3]. 7 nests − 3
  // sets = 4.
  '003_spec_5_1_example': 4,
  // Two towers hide red2 under blue1 and blue2 under red1; red3 and blue3
  // sit in open slots, and one slot is empty. No top can merge (blue1 and
  // blue3 differ by 2, as do red1 and red3), so the first move must be a
  // placement into the empty slot: 6 nests − 2 sets = 4 merges + 1 = 5.
  // For example blue1 into the empty slot, red2 into red3, red1 into
  // [red3, red2] (completes), blue2 into blue3, blue1 into [blue3, blue2].
  '004_placement_first': 5,
  // Two full red sets (k = 2, spec §5.3 rule 4): red3, red3, [red2, red1],
  // red2 and red1. 5 nests − 2 sets = 3 merges.
  '005_two_sets_one_color': 3,
  // blue3 is under ice 1 (spec §3.4). red1 into [red3, red2] completes red,
  // which thaws blue3; then [blue2, blue1] into blue3. 4 nests − 2 sets = 2.
  '006_ice_thaws': 2,
  // blue3 is in a glass case that opens on red (spec §3.3). [red2, red1] into
  // red3 completes red and breaks the case; then [blue2, blue1] into blue3.
  // 4 nests − 2 sets = 2.
  '007_lock_opens': 2,
  // A full-size board (rows of 5, 5, 5 and 4, maxSize 5): six colors, each
  // set cut into three consecutive segments, all in open slots, one slot
  // empty. Any three consecutive segments of a run merge in two moves (the
  // middle one joins a neighbour, then the third joins), so merges alone win:
  // 18 nests − 6 sets = 12. Too big for a tiny budget; see
  // [budgetLimitedFixture].
  '008_large_open_board': 12,
};

/// The fixtures in test/fixtures/unsolvable/. Each passes validation rules
/// 1–7 (spec §5.3) and is small enough to search exhaustively, so the solver
/// must answer `unsolvable` (never `unknown`) and the validator must report
/// `solver.unsolvable`.
const List<String> unsolvableFixtures = [
  // Lock deadlock: the case that opens on red seals [blue3, blue2], and the
  // case that opens on blue seals [red3, red2]. Rule 6 holds for each lock on
  // its own (its color is in the level, and not all of it is in that lock),
  // but red can't complete before blue and blue can't complete before red.
  // Only red1 and blue1 can move, into the one empty slot and back.
  '001_lock_deadlock',
  // Never-thawing ice: red3 is under ice 2, but the level has only 2 sets,
  // so at most one completion (blue) can happen before red3 is needed, and
  // the ice stops at 1 (spec §3.4).
  '002_never_thawing_ice',
  // No-space dead end: one shelf, two towers and one empty slot. The tops
  // blue3 and green3 hide red3 and [red2, red1], and red must complete first
  // because it buries the other colors' pieces. Moving either top into the
  // empty slot fills the board with no merge left (after blue3: red3, green3
  // and blue3 are all size 3; after green3: blue3, [red2, red1] and green3),
  // so the whole reachable space is three states and none is won.
  '003_no_space_dead_end',
];

/// A solvable fixture that a tiny node budget can't finish, so the search
/// must answer `unknown`, never `unsolvable` (spec §6.3).
const String budgetLimitedFixture = '008_large_open_board';

/// The budget for [budgetLimitedFixture] (design §5: "unknown: large level
/// with budget 50"). Its optimal line alone is 12 moves deep, and the first
/// expansion already generates about two dozen merges.
const int budgetLimitedBudget = 50;
