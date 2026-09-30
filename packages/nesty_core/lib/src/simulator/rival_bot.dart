import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/prng/prng.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/rules/engine/kernel.dart';
import 'package:nesty_core/src/simulator/bots.dart';
import 'package:nesty_core/src/simulator/simulator.dart';

/// What one [RivalBot.step] did (spec-prop §7.7).
enum RivalStep {
  /// The rival played [RivalBot.lastFrom] → [RivalBot.lastTo], and it still
  /// has a family to complete.
  moved,

  /// The rival played [RivalBot.lastFrom] → [RivalBot.lastTo], and that
  /// move completed its last family. It never steps again: the next
  /// [RivalBot.step] throws.
  finished,

  /// The rival's run can't be won, so it started over: no move was played,
  /// its board is back at the level's start and [RivalBot.run] went up by 1.
  restarted,
}

/// The computer rival of vs Computer, one step at a time (spec-prop §7.7,
/// the rule until the owner pastes it into the spec, Q85).
///
/// Spec-prop §7.7: "rival 1 plays like the casual bot (§6.4) …; rival 2 like
/// the smart bot …; rival 3 like the smart bot … No other bot policy is
/// used." "Rival: makes one move per interval. When its run can't be won (no
/// useful move, or the 250-move cap of §6.4), it restarts from the start
/// with its next run seed." "Rematch replays the same board and the same
/// rival moves."
///
/// **A step** is one pass of the simulator's run loop (`BotPlayer.stepRun`,
/// which `BotPlayer.play` repeats), so the rival plays exactly the
/// simulator's [policy] and can't drift from it. It returns:
/// - [RivalStep.moved]: the bot's move, [lastFrom] → [lastTo], was played;
/// - [RivalStep.finished]: that move completed the last family, and the
///   rival is done;
/// - [RivalStep.restarted]: the run can't be won, because it has made
///   [moveCap] moves or its board has no useful move (no legal move, or
///   only pointless ones: spec §6.3's moves of a lone nest into an empty
///   free slot, which only swap interchangeable slots, so the board can
///   never be won). The board went back to the level's start, [run] went up
///   by 1, and the next run draws from its own seed. No move is played: a
///   restart is a step of its own, so the app can show it ("Starting
///   over"; how long it takes is the app's).
///
/// The win check comes first, so a run that wins on its [moveCap]th move
/// finishes. The rival never undoes (spec §6.4 "No undo") and, like the
/// simulator's bots, never adds an extra slot.
///
/// **Determinism** (CLAUDE.md rule 7): run `i` draws only from
/// `Prng(runSeed(raceSeed, policy, i))`, so every move is a pure function of
/// the level, the policy and the race seed, the same on the VM and the web
/// (test/parity/rival_parity_test.dart). The race seed is
/// `DifficultyCurve.raceSeed(rival, raceNo)`, never `level.seed`, which is
/// a retry seed when the params' own seed failed to generate.
///
/// **The app's copy:** the rival's board is this object's own. The app
/// mirrors it in a `GameSession` of the same [level]: on `moved` and
/// `finished` it plays `session.move(lastFrom, lastTo)`, which is always a
/// `MoveApplied`; on `restarted` it calls `session.restart()`. After every
/// step, [snapshot] equals the session's state.
///
/// **Allocation** (CLAUDE.md rule 8): the board, the bot and its move
/// buffers are allocated once, in the constructor, so a step that plays a
/// move allocates nothing; a restart allocates the next run's [Prng].
/// [snapshot] allocates a copy, for tests and a mini board only. One rival
/// per race: like the simulator, it is not re-entrant.
final class RivalBot {
  /// The rival for a race on [level], playing like [policy] (usually
  /// `DifficultyCurve.racePolicy(rival)`), its runs seeded from [raceSeed]
  /// (`DifficultyCurve.raceSeed(rival, raceNo)`), each run allowed [moveCap]
  /// moves (spec §6.4's cap).
  ///
  /// Throws a [RangeError] for a [raceSeed] outside [0, `Prng.maxSeed`] or a
  /// [moveCap] below 1 (a rival that could never move), and an
  /// [ArgumentError] for a level the engine can't lay out (see
  /// `GameState.initial`) or one with no family to complete.
  factory RivalBot(
    Level level, {
    required SimBot policy,
    required int raceSeed,
    int moveCap = SimulatorParams.defaultMoveCap,
  }) {
    RangeError.checkValueInInterval(raceSeed, 0, Prng.maxSeed, 'raceSeed');
    if (moveCap < 1) {
      throw RangeError.range(moveCap, 1, null, 'moveCap');
    }
    final layout = BoardLayout.of(level);
    if (layout.totalSets == 0) {
      throw ArgumentError.value(
        level,
        'level',
        'A level with no family to complete has nothing to race',
      );
    }
    return RivalBot._(level, layout, policy, raceSeed, moveCap);
  }

  RivalBot._(this.level, this._layout, this.policy, this.raceSeed, this.moveCap)
    : _player = BotPlayer(_layout),
      _board = Board(_layout),
      _prng = Prng(runSeed(raceSeed, policy, 0));

  /// The stream label of the rivals' run seeds: `'RVL0'` as a big-endian
  /// u32, plus [SimBot.index] (`'RVL1'` for the smart bot).
  ///
  /// It keeps a rival's runs apart from every other stream drawn from the
  /// same seed: the generator's attempts (`Prng.derive(seed, attempt)`, 0 to
  /// 49), its retry seeds (`Generator.retryStream`, `'RETR'`) and the app's
  /// pace jitter (`'PACE'`). With the bot's index alone as the label, the
  /// casual rival's run 0 would be attempt 0 of the race seed, often the
  /// stream that built the board.
  static const int runStream = 0x52564C30;

  /// The seed of run [run] of [policy] in the race seeded [raceSeed]:
  /// `Prng.derive(raceSeed, runStream + policy.index, run)`. Throws a
  /// [RangeError] for a [raceSeed] outside [0, `Prng.maxSeed`] or a [run]
  /// outside [0, 2^32).
  static int runSeed(int raceSeed, SimBot policy, int run) =>
      Prng.derive(raceSeed, runStream + policy.index, run);

  /// The race's board: both sides start from it (spec-prop §7.7).
  final Level level;

  /// How the rival plays (spec §6.4's casual or smart bot).
  final SimBot policy;

  /// The seed of every run ([runSeed]).
  final int raceSeed;

  /// The most moves a run makes before it counts as one that can't be won.
  final int moveCap;

  final BoardLayout _layout;
  final BotPlayer _player;

  // The current run's board, from the level's start.
  final Board _board;

  // The current run's draws.
  Prng _prng;

  int _run = 0;
  bool _finished = false;

  // Slot indexes of the last move played, or -1 before the first.
  int _lastFrom = -1;
  int _lastTo = -1;

  /// The current run, from 0: each restart adds 1.
  int get run => _run;

  /// Moves in the current run; a restart sets it back to 0.
  int get moveCount => _board.moveCount;

  /// Families (full sets) completed in the current run.
  int get setsCompleted => _board.completedSets;

  /// Families in the level: completing them all finishes the race.
  int get totalSets => _layout.totalSets;

  /// True once a [step] returned [RivalStep.finished].
  bool get isFinished => _finished;

  /// The id of the slot the last move came from, one of the level's slot
  /// ids, such as `r0c1`. It is the layout's own string, so reading it
  /// allocates nothing. Read it after a `moved` or `finished` step; a
  /// restart plays no move, so it still names the last move of the run
  /// before. Throws a [StateError] before the first move.
  String get lastFrom => _idOf(_lastFrom);

  /// The id of the slot the last move went to (see [lastFrom]). Throws a
  /// [StateError] before the first move.
  String get lastTo => _idOf(_lastTo);

  /// Plays the rival's next step (see the class doc). Throws a [StateError]
  /// once the rival has finished.
  RivalStep step() {
    if (_finished) {
      throw StateError('The rival finished the race: it has no next step');
    }
    final entry = _player.stepRun(policy, _board, _prng, moveCap);
    if (entry >= 0) {
      _lastFrom = LegalMove.from(entry);
      _lastTo = LegalMove.to(entry);
      if (!Kernel.isWon(_board)) return RivalStep.moved;
      _finished = true;
      return RivalStep.finished;
    }
    if (entry == BotPlayer.runWon) {
      // Only a board that is won before its first move gets here, and the
      // constructor refuses such a level.
      throw StateError('unreachable: a run won without a move');
    }
    // BotPlayer.runLost. Spec-prop §7.7: "it restarts from the start with
    // its next run seed".
    _board.reset();
    _run++;
    _prng = Prng(runSeed(raceSeed, policy, _run));
    return RivalStep.restarted;
  }

  /// The rival's board as a [GameState]. After every step it equals the
  /// state of the app's mirrored `GameSession` (see the class doc).
  /// Allocates a copy.
  GameState snapshot() => GameStateBoard.freeze(_board);

  String _idOf(int slot) {
    if (slot < 0) throw StateError('The rival has not moved yet');
    return _layout.ids[slot];
  }

  @override
  String toString() =>
      'RivalBot(${policy.name}, seed $raceSeed, run $_run, '
      'moves $moveCount, sets $setsCompleted/$totalSets'
      '${_finished ? ', finished' : ''})';
}
