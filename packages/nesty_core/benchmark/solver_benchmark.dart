// Solver benchmarks against the targets of docs/plans/m1-core-design.md §5:
// at least 300k nodes/s on the VM; a 30k hint within 100 ms on the VM and
// 400 ms in dart2js; a 20k soft-stuck check within 70 ms; a 500k admin
// search within 2 s on the VM and 8 s in Chrome, in at most 64 MB.
//
//   dart run benchmark/solver_benchmark.dart                  # VM (JIT)
//   dart compile exe benchmark/solver_benchmark.dart -o /tmp/sb && /tmp/sb
//   dart compile js -O2 benchmark/solver_benchmark.dart -o /tmp/sb.js
//   node /tmp/sb.js                                           # dart2js
//
// Stopwatch is allowed here: only lib/ must never read the clock (CLAUDE.md
// rule 7). No dart:io, so the same file compiles to JavaScript. The worst
// case of every budget is a search that uses all of it, so the levels below
// are ones the search can't finish early: one that no budget solves, and an
// unsolvable one (never-thawing ice) with a large reachable space.
// Results go to stdout, which is the point of a benchmark.
// ignore_for_file: avoid_print
library;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/solver/search.dart';

/// Seven colors, maxSize 4, five depth-3 towers on a 5/5/3 board with two
/// empty slots: the largest shape the design plans for bundled levels
/// (M2 rows ≤ 5, towers depth ≤ 3), with a deep search.
const Map<String, Object?> wideTowers = {
  'schemaVersion': 1,
  'id': 'bench_wide_towers',
  'maxSize': 4,
  'shelves': [
    [
      {
        'type': 'tower',
        'stack': [
          ['red4'],
          ['blue2', 'blue1'],
          ['green3'],
        ],
      },
      {
        'type': 'tower',
        'stack': [
          ['yellow4', 'yellow3'],
          ['red2'],
          ['teal1'],
        ],
      },
      {
        'type': 'tower',
        'stack': [
          ['green2', 'green1'],
          ['teal4'],
          ['blue4'],
        ],
      },
      {
        'type': 'tower',
        'stack': [
          ['orange3', 'orange2'],
          ['purple4'],
          ['yellow2', 'yellow1'],
        ],
      },
      {
        'type': 'tower',
        'stack': [
          ['teal3', 'teal2'],
          ['orange1'],
          ['red3'],
        ],
      },
    ],
    [
      {
        'type': 'open',
        'nest': ['purple3', 'purple2'],
      },
      {
        'type': 'open',
        'nest': ['green4'],
      },
      {
        'type': 'open',
        'nest': ['red1'],
      },
      {
        'type': 'open',
        'nest': ['blue3'],
      },
      {
        'type': 'open',
        'nest': ['orange4'],
      },
    ],
    [
      {
        'type': 'open',
        'nest': ['purple1'],
      },
      {'type': 'open', 'nest': null},
      {'type': 'open', 'nest': null},
    ],
  ],
};

/// [wideTowers] with green4 under ice that outlasts every set: green can
/// never complete, so every search runs until its budget or the end of the
/// reachable space.
final Map<String, Object?> wideTowersFrozen = {
  ...wideTowers,
  'id': 'bench_wide_towers_frozen',
  'shelves': [
    (wideTowers['shelves']! as List<Object?>)[0],
    [
      for (final (i, slot)
          in ((wideTowers['shelves']! as List<Object?>)[1] as List<Object?>)
              .indexed)
        if (i == 1) {...slot! as Map<String, Object?>, 'ice': 9} else slot,
    ],
    (wideTowers['shelves']! as List<Object?>)[2],
  ],
};

/// [wideTowersFrozen] with a third empty slot: its reachable space is
/// larger than the admin budget, so the admin search uses all of it.
final Map<String, Object?> wideTowersFrozenRoomy = {
  ...wideTowersFrozen,
  'id': 'bench_wide_towers_frozen_roomy',
  'shelves': [
    ...(wideTowersFrozen['shelves']! as List<Object?>).take(2),
    [
      ...((wideTowersFrozen['shelves']! as List<Object?>)[2] as List<Object?>),
      {'type': 'open', 'nest': null},
    ],
  ],
};

/// [wideTowersFrozenRoomy] with a fourth empty slot: the reachable space
/// far exceeds the admin budget, so the admin search stops as `unknown`
/// after storing exactly 500k states, the worst case of design §5.
final Map<String, Object?> wideTowersFrozenRoomier = {
  ...wideTowersFrozenRoomy,
  'id': 'bench_wide_towers_frozen_roomier',
  'shelves': [
    ...(wideTowersFrozenRoomy['shelves']! as List<Object?>).take(2),
    [
      ...((wideTowersFrozenRoomy['shelves']! as List<Object?>)[2]
          as List<Object?>),
      {'type': 'open', 'nest': null},
    ],
  ],
};

void main() {
  final levels = {
    'wide towers': _level(wideTowers),
    'wide towers, frozen green': _level(wideTowersFrozen),
    'wide towers, frozen green, 3 empty': _level(wideTowersFrozenRoomy),
    'wide towers, frozen green, 4 empty': _level(wideTowersFrozenRoomier),
  };
  print('Solver benchmark (${identical(1, 1.0) ? 'dart2js' : 'VM'})');
  final states = {
    for (final MapEntry(key: name, value: level) in levels.entries)
      name: GameState.initial(level),
    // Two extra slots (spec §3.6) make the reachable space larger than the
    // admin budget, so this search stops as `unknown` at exactly 500k.
    'wide towers, frozen green, 4 empty + 2 extra slots':
        (GameSession(levels['wide towers, frozen green, 4 empty']!)
              ..addExtraSlot()
              ..addExtraSlot())
            .state,
    // The widest rows (key words) the admin's Generator screen can reach
    // with params `Generator.checkParams` accepts: 4×5 (bottom 4) with 17
    // depth-4 towers, 72 cells. Attempt 1's admin search stops as unknown
    // at the full budget, so it is the memory worst case of design §5.
    'generator 4×5, 17 depth-4 towers (memory worst case)': GameState.initial(
      Generator.buildAttempt(_widestParams, 1)!,
    ),
  };
  for (final MapEntry(key: name, value: state) in states.entries) {
    // Warm up the JIT (and the layout cache) before timing.
    for (var i = 0; i < 3; i++) {
      Solver.solve(state, budget: SolverBudgets.hint);
    }
    print('\n$name:');
    _time('  soft-stuck 20k', () {
      Solver.softStuck(state);
    }, reps: 5);
    _time('  hint 30k', () {
      Solver.hint(state);
    }, reps: 5);
    _admin(state);
  }
}

const GeneratorParams _widestParams = GeneratorParams(
  colors: 10,
  setsPerColor: 2,
  maxSize: 6,
  shelves: 4,
  slotsPerShelf: 5,
  towers: 17,
  towerDepth: 4,
  emptySlots: 2,
  targetTier: Tier.hard,
  seed: 7,
);

void _admin(GameState state) {
  final watch = Stopwatch()..start();
  final search = AStarSearch(state, SolverBudgets.admin);
  search.advance(SolverBudgets.admin * 2);
  watch.stop();
  final result = search.result!;
  final ms = watch.elapsedMicroseconds / 1000;
  final rate = search.nodes / watch.elapsedMicroseconds * 1e6;
  print(
    '  admin 500k: ${result.verdict.name} '
    '${result.solution?.length ?? '-'} moves, ${search.nodes} nodes, '
    '${search.expansions} expansions, branching '
    '${result.branching.toStringAsFixed(2)}',
  );
  print(
    '    ${ms.toStringAsFixed(1)} ms, ${(rate / 1000).toStringAsFixed(0)}k '
    'nodes/s, ${(search.bytes / (1 << 20)).toStringAsFixed(1)} MB in typed '
    'lists (${(search.bytes / search.nodes).toStringAsFixed(0)} B/node), '
    'peak at most ${(search.peakBytes / (1 << 20)).toStringAsFixed(1)} MB',
  );
}

void _time(String label, void Function() body, {required int reps}) {
  final times = <int>[];
  for (var i = 0; i < reps; i++) {
    final watch = Stopwatch()..start();
    body();
    times.add(watch.elapsedMicroseconds);
  }
  times.sort();
  final median = times[times.length ~/ 2] / 1000;
  print('$label: median ${median.toStringAsFixed(1)} ms of $reps');
}

Level _level(Map<String, Object?> json) =>
    LevelCodec.decode(json).level ??
    (throw StateError('Benchmark level ${json['id']} does not decode'));
