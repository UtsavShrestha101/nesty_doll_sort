// VM/web parity for the solver (spec §6.2–§6.3, design §5, D11, Q9). The
// admin proves levels in the browser and the phones hint on the device, so
// verdicts, solutions, node counts, canonical-key hashes and the isolate
// snapshot must agree bit for bit on the VM, in dart2js (chrome, node) and
// in wasm. The optimal lengths here are also the hand-worked ones of
// test/solver/fixture_expectations.dart.
@Tags(['parity'])
library;

import 'dart:typed_data';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/solver/canonical.dart';
import 'package:nesty_core/src/solver/search.dart';
import 'package:nesty_core/src/util/hash64.dart';
import 'package:test/test.dart';

import '../solver/support/parity_levels.dart';
import '../solver/support/random_levels.dart';
import 'parity.dart';

GameState start(String name) =>
    GameState.initial(LevelCodec.decode(parityLevels[name]).level!);

GameState after(GameState state, List<String> moves) {
  var current = state;
  for (final move in moves) {
    final [from, to] = move.split('>');
    current = (Rules.tryMove(current, Move(from, to)) as MoveApplied).state;
  }
  return current;
}

String moveText(Move? move) => move == null ? '-' : '${move.from}>${move.to}';

Map<String, Object?> solveSummary(GameState state, {required int budget}) {
  final result = Solver.solve(state, budget: budget);
  return {
    'verdict': result.verdict.name,
    'moves': result.solution == null
        ? null
        : [for (final move in result.solution!) moveText(move)],
    'nodes': result.nodes,
    // Doubles print differently per platform; the ratio in thousandths is
    // an int (IEEE division and rounding agree everywhere).
    'branchingPermille': (result.branching * 1000).round(),
  };
}

Map<String, Object?> hintSummary(HintResult hint) => {
  'move': moveText(hint.move),
  'source': hint.source.name,
  'verdict': hint.verdict.name,
  'nodes': hint.nodes,
};

Map<String, Object?> keySummary(GameState state) {
  final canonical = CanonicalBoard(
    GameStateBoard.peek(state).layout,
    state.extraSlotCount,
  );
  final board = GameStateBoard.thaw(state);
  canonical.canonicalize(board);
  final words = Int32List(canonical.keyWords);
  final length = canonical.writeKey(board, words);
  canonical.hash(words, length);
  return {
    'words': words.sublist(0, length),
    'hex': Hash64.ofU32s(words, 0, length).toHex(),
    'inline': Hash64(canonical.hashHi, canonical.hashLo).toHex(),
  };
}

void main() {
  parityTest('optimal solutions (admin budget)', () {
    return {
      for (final name in parityLevels.keys)
        if (name != 'frozen_wide_towers')
          name: solveSummary(start(name), budget: SolverBudgets.admin),
    };
  }, expected: _optimal);

  parityTest('a tiny budget: unknown, and the fallback hint', () {
    final state = start('008_large_open_board');
    return {
      'solve': solveSummary(state, budget: 50),
      'hint': hintSummary(Solver.hint(state, budget: 50)),
      'softStuck': Solver.softStuck(state, budget: 50).name,
    };
  }, expected: _tinyBudget);

  parityTest('a large board at the hint and soft-stuck budgets', () {
    final state = start('frozen_wide_towers');
    Map<String, Object?> search(int budget) {
      final run = AStarSearch(state, budget)..advance(budget);
      while (!run.advance(budget)) {}
      return {
        'verdict': run.result!.verdict.name,
        'nodes': run.nodes,
        'expansions': run.expansions,
        'successors': run.successors,
      };
    }

    return {
      'hint': search(SolverBudgets.hint),
      'softStuck': search(SolverBudgets.softStuck),
      'hintMove': hintSummary(Solver.hint(state)),
    };
  }, expected: _largeBoard);

  parityTest('canonical keys and their Hash64', () {
    final example = start('003_spec_5_1_example');
    final tutorial = start('001_l1_tutorial');
    return {
      'spec example': keySummary(example),
      'spec example after the swallow': keySummary(
        after(example, ['r0c0>r0c2']),
      ),
      'tutorial': keySummary(tutorial),
      'tutorial, a free slot permuted': keySummary(
        after(tutorial, ['r1c1>r0c1']),
      ),
      'no space': keySummary(start('u003_no_space_dead_end')),
    };
  }, expected: _keys);

  parityTest('isolate snapshots and their results', () {
    final example = start('003_spec_5_1_example');
    final states = {
      'spec example': example,
      'spec example after the swallow': after(example, ['r0c0>r0c2']),
      'no space': start('u003_no_space_dead_end'),
    };
    return {
      for (final MapEntry(key: name, value: state) in states.entries)
        name: {
          'length': SolverSnapshot.encode(state).length,
          'digest': parityDigestU32s(SolverSnapshot.encode(state)),
          'hint': SolverSnapshot.run(
            SolverSnapshot.encode(state),
            SolverSnapshot.taskHint,
            SolverBudgets.hint,
            requestId: 9,
          ).toList(),
          'softStuck': SolverSnapshot.run(
            SolverSnapshot.encode(state),
            SolverSnapshot.taskSoftStuck,
            SolverBudgets.softStuck,
            requestId: 10,
          ).toList(),
        },
    };
  }, expected: _snapshots);

  parityTest('random boards: verdict, optimal length, nodes', () {
    return [
      for (var seed = 1; seed <= 40; seed++)
        () {
          final result = Solver.solve(GameState.initial(randomLevel(seed)));
          return [
            seed,
            result.verdict.name,
            result.solution?.length ?? -1,
            result.nodes,
          ];
        }(),
    ];
  }, expected: _random);
}

// Expected values: computed on the VM, then confirmed unchanged on node,
// chrome (dart2js) and chrome (dart2wasm). The optimal lengths match the
// hand-worked fixture expectations and the unsolvable node counts match the
// exhaustive oracle of test/solver/support/solver_oracle.dart.

const Object _optimal = {
  '001_l1_tutorial': {
    'branchingPermille': 1500,
    'moves': ['r0c0>r0c2', 'r0c2>r1c1'],
    'nodes': 3,
    'verdict': 'solved',
  },
  '003_spec_5_1_example': {
    'branchingPermille': 3250,
    'moves': ['r0c0>r0c2', 'r0c2>r1c0', 'r1c1>r0c2', 'r0c2>r1c2'],
    'nodes': 10,
    'verdict': 'solved',
  },
  '004_placement_first': {
    'branchingPermille': 3400,
    'moves': ['r0c1>r1c1', 'r1c0>r0c1', 'r0c0>r0c1', 'r0c2>r0c0', 'r0c0>r1c1'],
    'nodes': 14,
    'verdict': 'solved',
  },
  '007_lock_opens': {
    'branchingPermille': 1000,
    'moves': ['r0c1>r0c2', 'r0c0>r1c0'],
    'nodes': 2,
    'verdict': 'solved',
  },
  '008_large_open_board': {
    'branchingPermille': 6500,
    'moves': [
      'r0c3>r3c1',
      'r2c0>r3c1',
      'r0c4>r1c1',
      'r1c1>r2c4',
      'r1c4>r2c2',
      'r0c2>r2c2',
      'r1c3>r3c0',
      'r0c1>r3c0',
      'r2c1>r3c3',
      'r1c0>r3c3',
      'r0c0>r1c2',
      'r1c2>r2c3',
    ],
    'nodes': 78,
    'verdict': 'solved',
  },
  'u001_lock_deadlock': {
    'branchingPermille': 0,
    'moves': null,
    'nodes': 1,
    'verdict': 'unsolvable',
  },
  'u003_no_space_dead_end': {
    'branchingPermille': 667,
    'moves': null,
    'nodes': 3,
    'verdict': 'unsolvable',
  },
};

const Object _tinyBudget = {
  'hint': {
    'move': 'r0c0>r1c2',
    'nodes': 50,
    'source': 'fallback',
    'verdict': 'unknown',
  },
  'softStuck': 'unknown',
  'solve': {
    'branchingPermille': 10000,
    'moves': null,
    'nodes': 50,
    'verdict': 'unknown',
  },
};

const Object _largeBoard = {
  'hint': {
    'expansions': 10758,
    'nodes': 30000,
    'successors': 91073,
    'verdict': 'unknown',
  },
  'hintMove': {
    'move': 'r0c2>r1c3',
    'nodes': 30000,
    'source': 'fallback',
    'verdict': 'unknown',
  },
  'softStuck': {
    'expansions': 6316,
    'nodes': 20000,
    'successors': 52950,
    'verdict': 'unknown',
  },
};

const Object _keys = {
  'no space': {
    'hex': '6a7c7ea96fb2cf58',
    'inline': '6a7c7ea96fb2cf58',
    'words': [0, 0, 361784530, 227559762, 0],
  },
  'spec example': {
    'hex': 'e72a00438dd668cd',
    'inline': 'e72a00438dd668cd',
    'words': [0, 0, 353404928, 229656801, 337250, 0],
  },
  'spec example after the swallow': {
    'hex': 'b24484b20482664c',
    'inline': 'b24484b20482664c',
    'words': [1, 8, 353370112, 229638369, 337250, 0],
  },
  'tutorial': {
    'hex': '252d9da6cf15d3a5',
    'inline': '252d9da6cf15d3a5',
    'words': [0, 0, 0, 26231817, 0],
  },
  'tutorial, a free slot permuted': {
    'hex': '252d9da6cf15d3a5',
    'inline': '252d9da6cf15d3a5',
    'words': [0, 0, 0, 26231817, 0],
  },
};

const Object _snapshots = {
  'no space': {
    'digest': '7ebc3a9bc48829f2',
    'hint': [9, 1, 2, -1, -1, 3, -1],
    'length': 67,
    'softStuck': [10, 1, 2, -1, -1, 3, -1],
  },
  'spec example': {
    'digest': '297eb689cf6e4d06',
    'hint': [9, 0, 0, 0, 2, 10, 4],
    'length': 65,
    'softStuck': [10, 0, 2, -1, -1, 10, 4],
  },
  'spec example after the swallow': {
    'digest': '539d5f089da2f0a7',
    'hint': [9, 0, 0, 2, 3, 8, 3],
    'length': 65,
    'softStuck': [10, 0, 2, -1, -1, 8, 3],
  },
};

const Object _random = [
  [1, 'solved', 4, 10],
  [2, 'unsolvable', -1, 3],
  [3, 'solved', 4, 7],
  [4, 'unsolvable', -1, 8],
  [5, 'solved', 2, 4],
  [6, 'unsolvable', -1, 4],
  [7, 'unsolvable', -1, 4],
  [8, 'solved', 3, 4],
  [9, 'unsolvable', -1, 2],
  [10, 'unsolvable', -1, 4],
  [11, 'solved', 3, 3],
  [12, 'unsolvable', -1, 4],
  [13, 'solved', 5, 17],
  [14, 'solved', 3, 5],
  [15, 'unsolvable', -1, 8],
  [16, 'unsolvable', -1, 1],
  [17, 'unsolvable', -1, 5],
  [18, 'solved', 3, 8],
  [19, 'unsolvable', -1, 1],
  [20, 'unsolvable', -1, 1],
  [21, 'unsolvable', -1, 4],
  [22, 'unsolvable', -1, 4],
  [23, 'solved', 4, 8],
  [24, 'unsolvable', -1, 13],
  [25, 'unsolvable', -1, 4],
  [26, 'unsolvable', -1, 3],
  [27, 'solved', 3, 7],
  [28, 'solved', 2, 4],
  [29, 'unsolvable', -1, 2],
  [30, 'unsolvable', -1, 10],
  [31, 'unsolvable', -1, 2],
  [32, 'solved', 3, 4],
  [33, 'unsolvable', -1, 11],
  [34, 'solved', 3, 4],
  [35, 'solved', 2, 2],
  [36, 'unsolvable', -1, 2],
  [37, 'solved', 4, 7],
  [38, 'solved', 2, 4],
  [39, 'solved', 4, 10],
  [40, 'solved', 5, 15],
];
