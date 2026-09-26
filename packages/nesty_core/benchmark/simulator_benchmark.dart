// Simulator benchmark against the target of docs/plans/m1-core-design.md §5:
// a full simulation (spec §6.4: 2 bots × 300 runs, 250-move cap) within
// 250 ms per level on the VM. The generator simulates every attempt it
// keeps (spec §6.5), so this is also a large part of its budget.
//
//   dart run benchmark/simulator_benchmark.dart                  # VM (JIT)
//   dart compile exe benchmark/simulator_benchmark.dart -o /tmp/simb && /tmp/simb
//   dart compile js -O2 benchmark/simulator_benchmark.dart -o /tmp/simb.js
//   node /tmp/simb.js                                            # dart2js
//
// Stopwatch is allowed here: only lib/ must never read the clock (CLAUDE.md
// rule 7). No dart:io, so the same file compiles to JavaScript. The levels
// are the simulator tests' set plus a stress board: the slowest of about a
// thousand random validator-clean 5/5/5/4 boards with maxSize 6 and five
// towers, larger than any M2 level. Results go to stdout, which is the point
// of a benchmark.
// ignore_for_file: avoid_print
library;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/simulator/bots.dart';

import '../test/simulator/support/sim_levels.dart';

/// Spec §6.4's budget per level, from design §5.
const int budgetMs = 250;

/// The stress board (19 slots, 8 colors, maxSize 6, 5 towers).
const String stress19 =
    '{"schemaVersion":1,"id":"bench_stress_19","maxSize":6,"shelves":['
    '[{"type":"open","nest":["purple1"]},{"type":"open","nest":["brown4"]},'
    '{"type":"open","nest":["green3"]},{"type":"open","nest":["red1"]},'
    '{"type":"open","nest":["purple4"]}],'
    '[{"type":"tower","stack":[["blue1"],["green2"],["green1"],["red5"]]},'
    '{"type":"open","nest":["red3"]},{"type":"open","nest":["orange2"]},'
    '{"type":"open","nest":["brown3"]},{"type":"open","nest":["yellow1"]}],'
    '[{"type":"open","nest":null},{"type":"open","nest":["yellow6"]},'
    '{"type":"open","nest":["brown6","brown5"]},'
    '{"type":"open","nest":["red6"]},'
    '{"type":"tower","stack":[["yellow5","yellow4"],["purple3"],["brown1"],'
    '["orange4","orange3"]]}],'
    '[{"type":"tower","stack":[["blue6","blue5","blue4","blue3","blue2"],'
    '["purple2"],["yellow2"],["yellow3"]]},'
    '{"type":"tower","stack":[["purple6"],["green5","green4"],["red4"],'
    '["brown2"]]},'
    '{"type":"open","nest":["green6"]},'
    '{"type":"tower","stack":[["red2"],["orange1"],["purple5"],'
    '["orange6","orange5"]]}]]}';

void main() {
  final levels = <String, Level>{
    for (final name in simLevelJson.keys) name: simLevel(name),
    'stress19': LevelCodec.decodeString(stress19).level!,
  };

  print('Simulator.run, default params (300 runs per bot, 250-move cap)');
  print('level            slots  tier       casual  smart   ms/level');
  var worstMs = 0.0;
  var worstName = '';
  var totalMs = 0.0;
  for (final MapEntry(key: name, value: level) in levels.entries) {
    final ms = _msPerRun(level);
    final result = Simulator.run(level);
    totalMs += ms;
    if (ms > worstMs) {
      worstMs = ms;
      worstName = name;
    }
    print(
      '${name.padRight(16)} ${'${level.slotCount}'.padLeft(5)}  '
      '${result.tier.id.padRight(9)}  ${'${result.casual.wins}'.padLeft(6)}  '
      '${'${result.smart.wins}'.padLeft(5)}  ${ms.toStringAsFixed(2).padLeft(9)}',
    );
  }
  print(
    'mean ${(totalMs / levels.length).toStringAsFixed(2)} ms, worst '
    '${worstMs.toStringAsFixed(2)} ms ($worstName); budget $budgetMs ms: '
    '${worstMs <= budgetMs ? 'met' : 'MISSED'}',
  );

  print('');
  print('Per move on stress19 (every run of each bot):');
  final stress = levels['stress19']!;
  final player = BotPlayer(BoardLayout.of(stress));
  final seed = Simulator.defaultSeed(stress);
  for (final bot in SimBot.values) {
    for (var warm = 0; warm < 2; warm++) {
      _playAll(player, bot, seed);
    }
    final watch = Stopwatch()..start();
    final moves = _playAll(player, bot, seed);
    watch.stop();
    final perMoveNs = watch.elapsedMicroseconds * 1000 / moves;
    print(
      '  ${bot.name.padRight(6)} ${(moves / 300).toStringAsFixed(1)} moves '
      'per run, ${perMoveNs.toStringAsFixed(0)} ns per move, '
      '${(watch.elapsedMicroseconds / 1000).toStringAsFixed(1)} ms for 300 '
      'runs',
    );
  }
}

/// Mean milliseconds of one `Simulator.run(level)`, after a warm-up.
double _msPerRun(Level level) {
  Simulator.run(level);
  var reps = 0;
  final watch = Stopwatch()..start();
  // At least 3 runs and about 300 ms of work, so fast levels are measured
  // over many repetitions.
  while (reps < 3 || watch.elapsedMilliseconds < 300) {
    Simulator.run(level);
    reps++;
  }
  watch.stop();
  return watch.elapsedMicroseconds / 1000 / reps;
}

/// Plays the 300 default runs of [bot] and returns the moves made.
int _playAll(BotPlayer player, SimBot bot, int seed) {
  var moves = 0;
  for (var run = 0; run < SimulatorParams.defaultRuns; run++) {
    player.play(
      bot,
      Prng(Prng.derive(seed, bot.index, run)),
      SimulatorParams.defaultMoveCap,
      (_, _) => moves++,
    );
  }
  return moves;
}
