import 'dart:typed_data';

import 'package:nesty_core/src/prng/prng.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/rules/engine/kernel.dart';
import 'package:nesty_core/src/rules/engine/nest_code.dart';

/// The simulator's two players (spec §6.4), which are also the race's rival
/// policies (spec-prop §7.7: "No other bot policy is used").
///
/// [index] is the bot's label in its run seeds: run `i` of bot `b` draws from
/// `Prng(Prng.derive(simSeed, b.index, i))` (design §3), and a rival's run
/// `i` from `RivalBot.runSeed`, which adds [index] to its stream label. The
/// order is therefore part of the pipeline that `Generator.version` covers,
/// and of every rival's moves.
///
/// Exported by the barrel on its own (`show SimBot`), so the app can name a
/// rival's policy (`DifficultyCurve.racePolicy`, `RivalBot`); the players
/// behind it stay internal.
enum SimBot {
  /// Spec §6.4: a random merge 70% of the time when one exists, else a
  /// random legal move. No undo, no extra slots.
  casual,

  /// Spec §6.4: greedy with a 1-ply lookahead (design A17). No undo, no
  /// extra slots.
  smart,
}

/// How the smart bot rates one candidate move (design A17), packed into one
/// int so that a plain `>` compares candidates in the bot's order of
/// preference: first [alive], then [rank], then [mergesAfter].
///
/// Internal to nesty_core (not exported by the barrel).
abstract final class SmartScore {
  /// The move completes a set (spec §6.4 "moves that complete a set").
  static const int rankCompletes = 3;

  /// Any other merge (spec §6.4 "then merges").
  static const int rankMerge = 2;

  /// A placement after which a slot still accepts a placement (spec §6.4
  /// "moves that don't fill the last empty slot").
  static const int rankKeepsSpace = 1;

  /// A placement that fills the last usable empty slot.
  static const int rankFillsLast = 0;

  // Merges after a move are legal moves of one board, fewer than
  // `BoardLayout.maxSlotCount²` = 900 < 2^10.
  static const int _mergesBits = 10;
  static const int _mergesMask = (1 << _mergesBits) - 1;
  static const int _rankShift = _mergesBits;
  static const int _aliveBit = 1 << (_mergesBits + 2);

  /// The score of a move of [rank] whose board is [alive] and has
  /// [mergesAfter] legal merges.
  static int pack({
    required bool alive,
    required int rank,
    required int mergesAfter,
  }) {
    RangeError.checkValueInInterval(rank, rankFillsLast, rankCompletes, 'rank');
    RangeError.checkValueInInterval(mergesAfter, 0, _mergesMask, 'mergesAfter');
    return (alive ? _aliveBit : 0) | (rank << _rankShift) | mergesAfter;
  }

  /// False when the move leads to a board the bot can never win from: not
  /// won, and every legal move is pointless (spec §2.3 "Out of moves" is the
  /// case with no legal move at all). The lookahead drops such moves unless
  /// every candidate is one.
  static bool alive(int score) => (score & _aliveBit) != 0;

  /// [rankCompletes], [rankMerge], [rankKeepsSpace] or [rankFillsLast].
  static int rank(int score) => (score >> _rankShift) & 0x3;

  /// Legal merge moves (ordered source → target pairs) on the board after
  /// the move; 0 when it wins.
  static int mergesAfter(int score) => score & _mergesMask;
}

/// Plays the simulator's bots on one level's boards (spec §6.4), with every
/// move applied by the rules kernel (CLAUDE.md rule 2).
///
/// **The policies** (docs/plans/m1-core-design.md §3, design A17). Legal
/// moves are always `Kernel.collectLegalMoves` entries, in its (source,
/// target) index order, and "choose one of n" means `prng.nextInt(n)`, with
/// no draw at all when n is 1.
/// - *Casual:* count the merges `m`. When `m > 0` and `nextInt(100) < 70`,
///   play the chosen one of the merges, in list order. Otherwise play the
///   chosen one of all legal moves (merges included, and the `nextInt(100)`
///   draw is skipped when `m` is 0).
/// - *Smart:* candidates are the legal moves minus the pointless ones (a
///   lone nest moved from an open-like slot into an empty one, which only
///   swaps interchangeable slots, spec §6.3). Each candidate is scored by
///   [SmartScore] from its board one move ahead, the best score wins, and
///   ties are the chosen one of the tied candidates, in list order.
///
/// **A run** starts from the level's start (no undo, no extra slots) and
/// ends as a win when every set is complete, or as a loss after `moveCap`
/// moves or on a board with no useful move. A board whose legal moves are
/// all pointless can never be won: pointless moves permute nests between
/// interchangeable free slots, so the board stays one with only pointless
/// moves. Scoring it as a loss at once gives the same result as playing on
/// to the cap, only faster.
///
/// Changing any of this changes simulated tiers and therefore generated
/// levels, so it needs a `Generator.version` bump (spec §6.5).
///
/// Allocation-free per move: the boards and move buffers are allocated once
/// per player (CLAUDE.md rule 8). Not re-entrant: one player per isolate
/// thread of work.
///
/// Internal to nesty_core (not exported by the barrel).
final class BotPlayer {
  /// A player for boards of [layout].
  BotPlayer(this.layout)
    : _board = Board(layout),
      _next = Board(layout),
      _moves = Int32List(Kernel.legalMoveCapacity(layout)),
      _lookahead = Int32List(Kernel.legalMoveCapacity(layout)),
      _scores = Int32List(Kernel.legalMoveCapacity(layout)),
      _firstOfSource = Int32List(layout.slotCount),
      _mergeDegree = Int32List(layout.slotCount),
      _tops = Int32List(layout.slotCount);

  /// Spec §6.4: the casual bot "takes a random merge with 70% chance when
  /// one exists".
  static const int casualMergePercent = 70;

  // [_scores] marks for entries without a score.
  static const int _pointless = -1;
  static const int _unscored = -2;

  // Smart candidate groups, in the order they are scored (highest rank
  // first).
  static const int _groupCompletes = 0;
  static const int _groupMerges = 1;
  static const int _groupPlacements = 2;

  /// The layout of every board this player plays.
  final BoardLayout layout;

  // The run's board.
  final Board _board;

  // The smart bot's one-move lookahead.
  final Board _next;

  // Legal moves of the board a bot is choosing on.
  final Int32List _moves;

  // Legal moves of the lookahead board.
  final Int32List _lookahead;

  // The smart bot's score per entry of [_moves], or [_pointless] or
  // [_unscored].
  final Int32List _scores;

  // Per slot: the index in [_moves] of its first entry as a source (valid
  // for the sources of the current smart choice only).
  final Int32List _firstOfSource;

  // Set by [_prepareScoring] for the board being scored: per slot, the
  // merge moves of [_moves] it is the source or target of, and its top
  // nest; and the merge moves in all.
  final Int32List _mergeDegree;
  final Int32List _tops;
  int _mergesNow = 0;

  /// Wins of [bot] in [runs] runs of at most [moveCap] moves each, run `i`
  /// seeded with `Prng.derive(simSeed, bot.index, i)` (design §3).
  int wins(SimBot bot, int simSeed, int runs, int moveCap) {
    var wins = 0;
    for (var run = 0; run < runs; run++) {
      final prng = Prng(Prng.derive(simSeed, bot.index, run));
      if (play(bot, prng, moveCap)) wins++;
    }
    return wins;
  }

  /// What [stepRun] returns when the run is won: every set is complete.
  static const int runWon = -1;

  /// What [stepRun] returns when the run can't be won: it has made its
  /// `moveCap` moves, or its board has no useful move.
  static const int runLost = -2;

  /// Plays one run of [bot] from the level's start, drawing from [prng], and
  /// returns true on a win. [onMove] sees every move applied, as slot
  /// indexes (tests replay runs with it).
  ///
  /// The run is [stepRun] repeated on this player's own board until it
  /// returns [runWon] or [runLost], so a run has one definition, which the
  /// race's `RivalBot` shares (spec-prop §7.7 "plays like the casual bot
  /// (§6.4)").
  bool play(
    SimBot bot,
    Prng prng,
    int moveCap, [
    void Function(int from, int to)? onMove,
  ]) {
    final board = _board..reset();
    while (true) {
      final entry = stepRun(bot, board, prng, moveCap);
      if (entry == runWon) return true;
      if (entry == runLost) return false;
      onMove?.call(LegalMove.from(entry), LegalMove.to(entry));
    }
  }

  /// One step of a run of [bot] on [board], drawing from [prng]: the body of
  /// [play]'s loop. In this order:
  /// 1. [runWon] when [board] is won (spec §2.3), so a run that wins on its
  ///    [moveCap]th move is a win;
  /// 2. [runLost] when [board] has made [moveCap] moves (spec §6.4's cap);
  /// 3. [runLost] when [board] has no useful move: no legal move at all, or
  ///    only pointless ones (see the class doc);
  /// 4. otherwise the `LegalMove` entry [bot] chose, which is applied to
  ///    [board] before this returns.
  ///
  /// [moveCap] counts `board.moveCount`, the moves since the board's last
  /// reset. Allocation-free (CLAUDE.md rule 8). Throws an [ArgumentError]
  /// for a board of another layout.
  int stepRun(SimBot bot, Board board, Prng prng, int moveCap) {
    _checkLayout(board);
    if (Kernel.isWon(board)) return runWon;
    if (board.moveCount >= moveCap) return runLost;
    final count = Kernel.collectLegalMoves(board, _moves);
    if (!_hasUsefulMove(board, count)) return runLost;
    final entry = _pick(bot, board, count, prng);
    // Both policies always move when a useful move exists; failing loudly
    // beats a run that loops without its move count ever growing.
    if (entry < 0) throw StateError('${bot.name} bot found no move');
    Kernel.tryApply(board, LegalMove.from(entry), LegalMove.to(entry));
    return entry;
  }

  /// The `LegalMove` entry [bot] would play on [board], drawing from
  /// [prng], or -1 when it has no move: no legal move at all, or, for the
  /// smart bot, only pointless ones. [board] must be of [layout]; it isn't
  /// changed.
  int choose(SimBot bot, Board board, Prng prng) {
    _checkLayout(board);
    final count = Kernel.collectLegalMoves(board, _moves);
    if (count == 0) return -1;
    if (bot == SimBot.smart && !_hasUsefulMove(board, count)) return -1;
    return _pick(bot, board, count, prng);
  }

  /// The [SmartScore] of the legal move [from] → [to] on [board], which
  /// isn't changed. Throws an [ArgumentError] for an illegal move.
  int smartScore(Board board, int from, int to) {
    _checkLayout(board);
    _prepareScoring(board, Kernel.collectLegalMoves(board, _moves));
    return _score(board, from, to);
  }

  /// True when the legal-move [entry] of [board] is pointless: it moves a
  /// lone nest from an open-like slot into an empty one. Open-like slots
  /// hold at most one nest and are interchangeable, so the board is the
  /// same up to slot order (the solver prunes these too, spec §6.3).
  static bool isPointless(Board board, int entry) => _isPointless(board, entry);

  static bool _isPointless(Board board, int entry) =>
      MoveOutcome.kindOf(LegalMove.outcome(entry)) == MoveOutcome.placed &&
      Kernel.isOpenLike(board, LegalMove.from(entry));

  // Records what [_score] needs about [board], whose [count] legal moves
  // are in [_moves]: its merge count, each slot's merges and each slot's
  // top.
  void _prepareScoring(Board board, int count) {
    final moves = _moves;
    final degree = _mergeDegree;
    final tops = _tops;
    for (var slot = 0; slot < board.activeSlotCount; slot++) {
      degree[slot] = 0;
      tops[slot] = Kernel.top(board, slot);
    }
    var merges = 0;
    for (var i = 0; i < count; i++) {
      final entry = moves[i];
      if (!MoveOutcome.isMerge(LegalMove.outcome(entry))) continue;
      merges++;
      degree[LegalMove.from(entry)]++;
      degree[LegalMove.to(entry)]++;
    }
    _mergesNow = merges;
  }

  // The [SmartScore] of from → to on [board], prepared by
  // [_prepareScoring]. It uses the board one move ahead:
  // - rank: from the move's outcome; a placement keeps space when a slot
  //   still takes a placement after it.
  // - merges after: legal merge moves of the next board. A move that
  //   completes nothing changes only the tops of its two slots (spec §4:
  //   ice and locks change only on a completion), so every other pair
  //   merges exactly as it does now. The count is then today's, minus the
  //   merges that touch the two slots, plus theirs on the next board, each
  //   decided by `Kernel.check`. A completion recounts every move.
  // - alive: the next board is won, or has a merge, or a legal move from a
  //   slot that isn't open-like (every other move is pointless).
  int _score(Board board, int from, int to) {
    final next = _next..copyFrom(board);
    final outcome = Kernel.tryApply(next, from, to);
    if (!MoveOutcome.isLegal(outcome)) {
      throw ArgumentError.value('$from → $to', 'move', 'Not a legal move');
    }
    final int rank;
    if (MoveOutcome.completes(outcome)) {
      rank = SmartScore.rankCompletes;
    } else if (MoveOutcome.isMerge(outcome)) {
      rank = SmartScore.rankMerge;
    } else {
      rank = _hasPlacementTarget(next)
          ? SmartScore.rankKeepsSpace
          : SmartScore.rankFillsLast;
    }
    if (Kernel.isWon(next)) {
      return SmartScore.pack(alive: true, rank: rank, mergesAfter: 0);
    }
    final int merges;
    if (MoveOutcome.completes(outcome)) {
      merges = _countMerges(next);
    } else {
      final touchingNow =
          _mergeDegree[from] +
          _mergeDegree[to] -
          (MoveOutcome.isMerge(outcome) ? 1 : 0) -
          (_isLegalMerge(Kernel.check(board, to, from)) ? 1 : 0);
      merges = _mergesNow - touchingNow + _mergesTouching(next, from, to);
    }
    final alive = merges > 0 || _hasMoveFromFixedSlot(next);
    return SmartScore.pack(alive: alive, rank: rank, mergesAfter: merges);
  }

  // Legal merge moves on [next] with [a] or [b] as source or target. Every
  // other slot still has the top [_tops] recorded. Spec §4: a merge needs
  // `colorsMatch`, so pairs that fail it are skipped; the kernel decides
  // every other pair.
  int _mergesTouching(Board next, int a, int b) {
    final tops = _tops;
    final topA = Kernel.top(next, a);
    final topB = Kernel.top(next, b);
    var merges = 0;
    for (var slot = 0; slot < next.activeSlotCount; slot++) {
      if (slot == a || slot == b) continue;
      final top = tops[slot];
      if (top == NestCode.empty) continue;
      if (topA != NestCode.empty && NestCode.colorsMatch(topA, top)) {
        if (_isLegalMerge(Kernel.check(next, a, slot))) merges++;
        if (_isLegalMerge(Kernel.check(next, slot, a))) merges++;
      }
      if (topB != NestCode.empty && NestCode.colorsMatch(topB, top)) {
        if (_isLegalMerge(Kernel.check(next, b, slot))) merges++;
        if (_isLegalMerge(Kernel.check(next, slot, b))) merges++;
      }
    }
    if (topA != NestCode.empty &&
        topB != NestCode.empty &&
        NestCode.colorsMatch(topA, topB)) {
      if (_isLegalMerge(Kernel.check(next, a, b))) merges++;
      if (_isLegalMerge(Kernel.check(next, b, a))) merges++;
    }
    return merges;
  }

  // Legal merge moves on [board], counted from all its legal moves.
  int _countMerges(Board board) {
    final moves = _lookahead;
    final count = Kernel.collectLegalMoves(board, moves);
    var merges = 0;
    for (var i = 0; i < count; i++) {
      if (MoveOutcome.isMerge(LegalMove.outcome(moves[i]))) merges++;
    }
    return merges;
  }

  // True when some legal move of [board] starts from a slot that isn't
  // open-like (a tower; a still-locked case can't be picked). With no merge
  // on the board, that is exactly a move that isn't pointless.
  static bool _hasMoveFromFixedSlot(Board board) {
    final active = board.activeSlotCount;
    for (var from = 0; from < active; from++) {
      if (Kernel.isOpenLike(board, from) || !Kernel.canPick(board, from)) {
        continue;
      }
      for (var to = 0; to < active; to++) {
        if (MoveOutcome.isLegal(Kernel.check(board, from, to))) return true;
      }
    }
    return false;
  }

  static bool _isLegalMerge(int outcome) =>
      MoveOutcome.isLegal(outcome) && MoveOutcome.isMerge(outcome);

  void _checkLayout(Board board) {
    if (!identical(board.layout, layout)) {
      throw ArgumentError.value(board, 'board', 'Board of another layout');
    }
  }

  int _pick(SimBot bot, Board board, int count, Prng prng) => switch (bot) {
    SimBot.casual => _casual(count, prng),
    SimBot.smart => _smart(board, count, prng),
  };

  int _casual(int count, Prng prng) {
    final moves = _moves;
    var merges = 0;
    for (var i = 0; i < count; i++) {
      if (MoveOutcome.isMerge(LegalMove.outcome(moves[i]))) merges++;
    }
    if (merges > 0 && prng.nextInt(100) < casualMergePercent) {
      var nth = _choose(prng, merges);
      for (var i = 0; i < count; i++) {
        if (!MoveOutcome.isMerge(LegalMove.outcome(moves[i]))) continue;
        if (nth == 0) return moves[i];
        nth--;
      }
    }
    return moves[_choose(prng, count)];
  }

  // The smart policy: the best [smartScore] among the non-pointless moves,
  // ties chosen in list order. Scoring every candidate one move ahead is
  // the cost of the simulator, so this skips the lookahead wherever the
  // result is known to be the same:
  // - Candidates are scored a group at a time, from the highest rank down
  //   (completions, other merges, placements). Once a group holds a move
  //   that is alive, no move of a lower group can beat it (alive first,
  //   then rank), so the lower groups are never scored.
  // - A merge between two open-like slots scores like its reverse, which
  //   makes the same merged nest with the two slots swapped.
  // - Every placement from one source scores alike: its targets are empty
  //   free slots, which are interchangeable.
  // The chosen move and the PRNG draws are exactly those of scoring every
  // candidate; a test compares the two over thousands of positions.
  int _smart(Board board, int count, Prng prng) {
    final moves = _moves;
    final scores = _scores;
    final firstOfSource = _firstOfSource;
    var groups = 0;
    var previousFrom = -1;
    for (var i = 0; i < count; i++) {
      final entry = moves[i];
      final from = LegalMove.from(entry);
      if (from != previousFrom) {
        firstOfSource[from] = i;
        previousFrom = from;
      }
      if (_isPointless(board, entry)) {
        scores[i] = _pointless;
      } else {
        scores[i] = _unscored;
        groups |= 1 << _groupOf(LegalMove.outcome(entry));
      }
    }
    _prepareScoring(board, count);
    var best = _pointless;
    for (var group = _groupCompletes; group <= _groupPlacements; group++) {
      if ((groups >> group) & 1 == 0) continue;
      final groupBest = _scoreGroup(board, count, group);
      if (groupBest > best) best = groupBest;
      if (SmartScore.alive(best)) break;
    }
    if (best < 0) return -1;
    var ties = 0;
    for (var i = 0; i < count; i++) {
      if (scores[i] == best) ties++;
    }
    var nth = _choose(prng, ties);
    for (var i = 0; i < count; i++) {
      if (scores[i] != best) continue;
      if (nth == 0) return moves[i];
      nth--;
    }
    throw StateError('unreachable: $ties tied candidates');
  }

  // Scores the candidates of [group] into [_scores] and returns the best.
  int _scoreGroup(Board board, int count, int group) {
    final moves = _moves;
    final scores = _scores;
    var best = _pointless;
    var placementSource = -1;
    var placementScore = _pointless;
    for (var i = 0; i < count; i++) {
      if (scores[i] != _unscored) continue;
      final entry = moves[i];
      if (_groupOf(LegalMove.outcome(entry)) != group) continue;
      final from = LegalMove.from(entry);
      final to = LegalMove.to(entry);
      final int score;
      if (group == _groupPlacements) {
        if (from != placementSource) {
          placementSource = from;
          placementScore = _score(board, from, to);
        }
        score = placementScore;
      } else if (to < from &&
          Kernel.isOpenLike(board, from) &&
          Kernel.isOpenLike(board, to)) {
        // The reverse move to → from is legal too (spec §2.2: `M` inside
        // `T` is the same size test as `T` swallowing `M`), sorts earlier
        // and is in this group, so it is scored already.
        score = scores[_entryIndex(to, from, count)];
      } else {
        score = _score(board, from, to);
      }
      scores[i] = score;
      if (score > best) best = score;
    }
    return best;
  }

  // The index in [_moves] of the entry from → to, which must exist.
  int _entryIndex(int from, int to, int count) {
    final moves = _moves;
    for (var i = _firstOfSource[from]; i < count; i++) {
      final entry = moves[i];
      if (LegalMove.from(entry) != from) break;
      if (LegalMove.to(entry) == to) return i;
    }
    throw StateError('unreachable: no legal move $from → $to');
  }

  static int _groupOf(int outcome) {
    if (MoveOutcome.completes(outcome)) return _groupCompletes;
    return MoveOutcome.isMerge(outcome) ? _groupMerges : _groupPlacements;
  }

  // True when one of the first [count] entries of [_moves] isn't pointless.
  bool _hasUsefulMove(Board board, int count) {
    final moves = _moves;
    for (var i = 0; i < count; i++) {
      if (!_isPointless(board, moves[i])) return true;
    }
    return false;
  }

  // True when some slot in play takes a placement right now: empty,
  // open-like and interactable (spec §4 rule 1's target).
  static bool _hasPlacementTarget(Board board) {
    for (var slot = 0; slot < board.activeSlotCount; slot++) {
      if (Kernel.isOpenLike(board, slot) &&
          Kernel.isInteractable(board, slot) &&
          Kernel.top(board, slot) == NestCode.empty) {
        return true;
      }
    }
    return false;
  }

  // One of [n] options: `prng.nextInt(n)`, or no draw when there is only
  // one.
  static int _choose(Prng prng, int n) => n == 1 ? 0 : prng.nextInt(n);
}
