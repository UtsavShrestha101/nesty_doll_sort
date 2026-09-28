// The barrel exports every public type of the M1 design (§1), and the
// plain-data contracts shared between the M1 steps keep their spec values.
// Behaviour behind the API (codec, validator, rules, session, solver,
// simulator, generator, PRNG) is tested by each step's own suite.
import 'dart:typed_data';

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../models/spec_example_level.dart';

void main() {
  test('the barrel exports every public type of the design', () {
    // A compile-time check: this file only builds if each name is exported.
    const types = <Type>[
      // Models.
      DollColor, Doll, Nest, Slot, OpenSlot, TowerSlot, LockedSlot, SlotId,
      BoardPosition, Level, GameState, Move, MoveEvent, NestDirection, Picked,
      Placed, NestedInto, Revealed, Completed, Unlocked, IceCracked,
      IceShattered, Won, OutOfMoves, MoveResult, MoveApplied, MoveRejected,
      InvalidMoveReason, UndoEntry, UndoResult, ExtraSlotAdded,
      // Codec, bundle and issues.
      LevelCodec, LevelDecodeResult, LevelBundleCodec, LevelBundle,
      LevelBundleEntry, LevelBundleDecodeResult, LevelIssue, IssueSeverity,
      IssueCodes, GameSessionCodec, GameSessionDecodeResult,
      // Validator.
      Validator, ValidationOptions, ValidationReport, LayoutLimits,
      // Rules and session.
      Rules, GameSession,
      // Solver.
      Solver, SolverRun, SolverBudgets, SolveVerdict, SolveResult, HintResult,
      HintSource, SolverSnapshot, SolverTask, LevelSolver,
      // Simulator.
      Simulator, SimulatorParams, SimulationResult, BotStats, Tier,
      // Generator.
      Generator, GeneratorParams, GeneratorOutcome, GeneratorSuccess,
      GeneratorFailure, DifficultyCurve,
      // PRNG.
      Prng,
    ];
    expect(types.toSet(), hasLength(types.length));
  });

  group('limits and budgets keep their spec values', () {
    test('LayoutLimits (spec §2.1, §3.2, §3.6, §5.3; D22; A21)', () {
      expect(LayoutLimits.minMaxSize, 3);
      expect(LayoutLimits.maxMaxSize, 6);
      expect(LayoutLimits.minShelves, 1);
      expect(LayoutLimits.maxShelves, 4);
      expect(LayoutLimits.minSlotsPerShelf, 2);
      expect(LayoutLimits.maxSlotsPerShelf, 5);
      expect(LayoutLimits.maxExtraSlots, 2);
      expect(LayoutLimits.maxRowSlots, 6);
      expect(LayoutLimits.maxBottomShelfSlots, 4);
      expect(LayoutLimits.maxTowerDepth, 4);
      expect(LayoutLimits.maxSlots, 22);
      expect(LayoutLimits.maxSlots, lessThanOrEqualTo(32));
      expect(LayoutLimits.maxLevelIdLength, 64);
      // 2^31 − 1: the engine's 32-bit ice lists (review SPEC-02).
      expect(LayoutLimits.maxIce, 0x7FFFFFFF);
    });

    test('SolverBudgets (spec §6.3)', () {
      expect(SolverBudgets.admin, 500000);
      expect(SolverBudgets.hint, 30000);
      expect(SolverBudgets.softStuck, 20000);
    });

    test('GameSession.maxExtraSlots (spec §3.6)', () {
      expect(GameSession.maxExtraSlots, 2);
    });

    test('Generator constants (spec §6.5)', () {
      expect(Generator.version, 1);
      expect(Generator.maxAttempts, 50);
      expect(Generator.maxSetsPerColor, 40);
      expect(Generator.defaultId(7), 'gen-7');
      // m3-design §5: deterministic retries on a GeneratorFailure.
      expect(Generator.maxRetries, 3);
      expect(Generator.retryStream, 0x52455452);
      expect(GameSessionCodec.format, 1);
      expect(DifficultyCurve.maxLevelNumber, 1 << 30);
    });

    test('SimulatorParams defaults (spec §6.4)', () {
      const params = SimulatorParams();
      expect(params.runs, 300);
      expect(params.moveCap, 250);
      expect(params.seed, isNull);
    });

    test('Prng.maxSeed is 2^53 − 1 (design A20)', () {
      expect(Prng.maxSeed, 9007199254740991);
    });

    test('schema and bundle versions', () {
      expect(Level.currentSchemaVersion, 1);
      expect(LevelBundle.format, 'nesty.levels');
      expect(LevelBundle.currentBundleVersion, 1);
    });
  });

  group('DifficultyCurve formulas', () {
    test('blockPattern is E E M E M H M E M S (spec §6.6)', () {
      expect(DifficultyCurve.blockPattern.map((t) => t.id), [
        'easy',
        'easy',
        'medium',
        'easy',
        'medium',
        'hard',
        'medium',
        'easy',
        'medium',
        'superhard',
      ]);
    });

    test('tierForLevel repeats the pattern every 10 levels', () {
      expect(DifficultyCurve.tierForLevel(1), Tier.easy);
      expect(DifficultyCurve.tierForLevel(6), Tier.hard);
      expect(DifficultyCurve.tierForLevel(10), Tier.superhard);
      expect(DifficultyCurve.tierForLevel(11), Tier.easy);
      expect(DifficultyCurve.tierForLevel(16), Tier.hard);
      expect(DifficultyCurve.tierForLevel(20), Tier.superhard);
      expect(() => DifficultyCurve.tierForLevel(0), throwsRangeError);
    });

    test('bonusSeed is 1,000,000 + level (spec §7.1)', () {
      expect(DifficultyCurve.bonusSeed(1), 1000001);
      expect(DifficultyCurve.bonusSeed(201), 1000201);
    });

    test('dailySeed is yyyymmdd (spec §7.5)', () {
      expect(DifficultyCurve.dailySeed(2026, 9, 26), 20260926);
      expect(DifficultyCurve.dailySeed(2027, 1, 5), 20270105);
      expect(() => DifficultyCurve.dailySeed(2026, 13, 1), throwsRangeError);
      expect(() => DifficultyCurve.dailySeed(2026, 1, 0), throwsRangeError);
    });
  });

  group('SolverSnapshot result layout (design §6)', () {
    final state = GameState.initial(specExampleLevel());

    Int32List result({
      int from = 0,
      int to = 1,
      SolveVerdict verdict = SolveVerdict.solved,
      HintSource source = HintSource.solver,
    }) => Int32List.fromList([
      42, // requestId
      verdict.index,
      source.index,
      from,
      to,
      1234, // nodes
      4, // solutionLength
    ]);

    test('has seven ints in the documented order', () {
      expect(SolverSnapshot.resultLength, 7);
      expect(
        [
          SolverSnapshot.resultRequestId,
          SolverSnapshot.resultVerdict,
          SolverSnapshot.resultSource,
          SolverSnapshot.resultFromIndex,
          SolverSnapshot.resultToIndex,
          SolverSnapshot.resultNodes,
          SolverSnapshot.resultSolutionLength,
        ],
        [0, 1, 2, 3, 4, 5, 6],
      );
    });

    test('readHint maps slot indexes to ids through state.slotIds', () {
      final hint = SolverSnapshot.readHint(result(from: 5, to: 1), state);
      expect(hint.move, const Move('r1c2', 'r0c1'));
      expect(hint.source, HintSource.solver);
      expect(hint.verdict, SolveVerdict.solved);
      expect(hint.nodes, 1234);
    });

    test('readHint gives no move for noSlot', () {
      final hint = SolverSnapshot.readHint(
        result(
          from: SolverSnapshot.noSlot,
          to: SolverSnapshot.noSlot,
          verdict: SolveVerdict.unsolvable,
          source: HintSource.none,
        ),
        state,
      );
      expect(hint.move, isNull);
      expect(hint.source, HintSource.none);
      expect(hint.verdict, SolveVerdict.unsolvable);
    });

    test('readVerdict reads the verdict', () {
      for (final verdict in SolveVerdict.values) {
        expect(SolverSnapshot.readVerdict(result(verdict: verdict)), verdict);
      }
    });

    test('a result of the wrong length is a FormatException', () {
      expect(
        () => SolverSnapshot.readVerdict(Int32List(3)),
        throwsFormatException,
      );
      expect(
        () => SolverSnapshot.readHint(Int32List(8), state),
        throwsFormatException,
      );
    });
  });

  group('plain-data contracts', () {
    test('SolveVerdict has exactly solved, unsolvable and unknown', () {
      expect(SolveVerdict.values.map((v) => v.name), [
        'solved',
        'unsolvable',
        'unknown',
      ]);
    });

    test('SolveResult copies its solution and compares by value', () {
      final moves = [const Move('r0c2', 'r0c0')];
      final result = SolveResult(
        verdict: SolveVerdict.solved,
        nodes: 10,
        branching: 2.5,
        solution: moves,
      );
      moves.clear();
      expect(result.solution, [const Move('r0c2', 'r0c0')]);
      expect(() => result.solution!.clear(), throwsUnsupportedError);
      expect(
        result,
        SolveResult(
          verdict: SolveVerdict.solved,
          nodes: 10,
          branching: 2.5,
          solution: const [Move('r0c2', 'r0c0')],
        ),
      );
      final unknown = SolveResult(
        verdict: SolveVerdict.unknown,
        nodes: 10,
        branching: 2.5,
      );
      expect(unknown.solution, isNull);
      expect(unknown, isNot(result));
      expect(
        unknown,
        SolveResult(verdict: SolveVerdict.unknown, nodes: 10, branching: 2.5),
      );
    });

    test('HintResult compares by value', () {
      const a = HintResult(
        move: Move('r0c0', 'r0c1'),
        source: HintSource.fallback,
        verdict: SolveVerdict.unknown,
        nodes: 30000,
      );
      expect(
        a,
        const HintResult(
          move: Move('r0c0', 'r0c1'),
          source: HintSource.fallback,
          verdict: SolveVerdict.unknown,
          nodes: 30000,
        ),
      );
      expect(
        a,
        isNot(
          const HintResult(
            source: HintSource.none,
            verdict: SolveVerdict.unsolvable,
            nodes: 30000,
          ),
        ),
      );
    });

    test('ValidationOptions presets: admin checks rule 8, loader does not', () {
      expect(ValidationOptions.admin.checkSolvable, isTrue);
      expect(ValidationOptions.admin.solverBudget, SolverBudgets.admin);
      expect(ValidationOptions.loader.checkSolvable, isFalse);
      expect(const ValidationOptions(), ValidationOptions.admin);
    });

    test('ValidationReport is valid exactly when there is no error', () {
      final warning = LevelIssue(
        code: IssueCodes.unproven,
        message: 'Not proven',
        severity: IssueSeverity.warning,
      );
      final error = LevelIssue(code: IssueCodes.shelfCount, message: 'Bad');
      expect(ValidationReport().isValid, isTrue);
      expect(ValidationReport(issues: [warning]).isValid, isTrue);
      final invalid = ValidationReport(issues: [warning, error]);
      expect(invalid.isValid, isFalse);
      expect(invalid.errors, [error]);
    });

    test('LevelDecodeResult.isOk means a level was decoded', () {
      expect(LevelDecodeResult(level: specExampleLevel()).isOk, isTrue);
      expect(
        LevelDecodeResult(
          issues: [LevelIssue(code: IssueCodes.invalidJson, message: 'Bad')],
        ).isOk,
        isFalse,
      );
    });

    test('LevelBundle keeps its entries in order and compares by value', () {
      LevelBundle make() => LevelBundle(
        levelsVersion: 0,
        levels: [
          LevelBundleEntry(
            order: 1,
            chapterId: 'ch01',
            tier: Tier.easy,
            version: 1,
            rewardCoins: Tier.easy.defaultRewardCoins,
            level: specExampleLevel(),
          ),
        ],
      );
      expect(make().bundleVersion, LevelBundle.currentBundleVersion);
      expect(make(), make());
      expect(make().hashCode, make().hashCode);
      expect(() => make().levels.clear(), throwsUnsupportedError);
    });

    test('BotStats win rate', () {
      expect(const BotStats(runs: 300, wins: 195).winRate, 0.65);
      expect(const BotStats(runs: 0, wins: 0).winRate, 0);
    });

    test('GeneratorParams defaults (spec §6.5: setsPerColor 1)', () {
      const params = GeneratorParams(
        colors: 3,
        maxSize: 3,
        shelves: 2,
        slotsPerShelf: 3,
        emptySlots: 1,
        targetTier: Tier.easy,
        seed: 1000001,
      );
      expect(params.setsPerColor, 1);
      expect(params.towers, 0);
      expect(params.locked, 0);
      expect(params.iceSlots, 0);
      expect(params.id, isNull);
      expect(
        params,
        const GeneratorParams(
          colors: 3,
          maxSize: 3,
          shelves: 2,
          slotsPerShelf: 3,
          emptySlots: 1,
          targetTier: Tier.easy,
          seed: 1000001,
        ),
      );
    });

    test('SolverRun keeps the state and budget it was started with', () {
      final state = GameState.initial(specExampleLevel());
      final run = SolverRun(state, budget: SolverBudgets.hint);
      expect(run.state, state);
      expect(run.budget, SolverBudgets.hint);
      expect(SolverRun(state).budget, SolverBudgets.admin);
    });
  });
}
