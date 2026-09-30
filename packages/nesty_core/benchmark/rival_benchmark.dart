// Rival step benchmark (spec-prop §7.7; m7-design Phase 2, the race-core
// lane's report-only sweep): how long one `RivalBot.step` takes on the race
// boards of every stage. The game steps the rival on the UI isolate, at most
// once per frame (CLAUDE.md rule 8), so the worst smart step is the number
// that matters on a low-end phone.
//
//   dart run benchmark/rival_benchmark.dart [boards]              # VM (JIT)
//   dart compile exe benchmark/rival_benchmark.dart -o /tmp/rivb && /tmp/rivb
//   dart compile js -O2 benchmark/rival_benchmark.dart -o /tmp/rivb.js
//   node /tmp/rivb.js                                            # dart2js
//
// For each stage and rival it generates race boards 1..[boards] (default 20)
// as the app does, plays each race to the rival's finish (at most 2,000
// steps), and times every step on its own. Each race is played [_reps]
// times; a step's time is the fastest of its repetitions, which removes GC
// pauses and other noise, and the worst of those is the "worst step". The
// slowest single sample (noise included) is reported too.
//
// Stopwatch is allowed here: only lib/ must never read the clock (CLAUDE.md
// rule 7). No dart:io, so the same file compiles to JavaScript. Results go to
// stdout, which is the point of a benchmark.
// ignore_for_file: avoid_print
library;

import 'package:nesty_core/nesty_core.dart';

/// Stages by a highest level won inside them (curve.dart's stage table).
const _stages = {16: 20, 31: 50, 51: 70, 71: 120, 121: 121};

/// Repetitions of each race.
const int _reps = 5;

/// Steps after which a race is cut off (the rival may restart for long on
/// an unlucky board; the steps still count).
const int _maxSteps = 2000;

void main(List<String> args) {
  final boards = args.isEmpty ? 20 : int.parse(args.first);
  final watch = Stopwatch();
  final nsPerTick = 1e9 / watch.frequency;
  print(
    'RivalBot.step on race boards 1..$boards per stage and rival, '
    '$_reps repetitions per race',
  );
  print(
    'stage  rival  policy  boards  steps  restarts   mean µs  p99 µs  '
    'worst µs  noisy max µs  worst at',
  );
  var worstSmart = 0.0;
  var worstSmartAt = '';
  for (final MapEntry(key: stage, value: won) in _stages.entries) {
    for (var rival = 1; rival <= DifficultyCurve.raceRivals; rival++) {
      final policy = DifficultyCurve.racePolicy(rival);
      final best = <double>[];
      var noisyMax = 0.0;
      var worst = 0.0;
      var worstAt = '';
      var restarts = 0;
      var built = 0;
      for (var raceNo = 1; raceNo <= boards; raceNo++) {
        final outcome = Generator.generateWithRetries(
          DifficultyCurve.raceParams(
            rival: rival,
            raceNo: raceNo,
            highestWonLevel: won,
          ),
        );
        if (outcome is! GeneratorSuccess) continue;
        built++;
        final level = outcome.level;
        final seed = DifficultyCurve.raceSeed(rival, raceNo);
        List<double>? fastest;
        for (var rep = 0; rep < _reps; rep++) {
          final bot = RivalBot(level, policy: policy, raceSeed: seed);
          final times = <double>[];
          while (!bot.isFinished && times.length < _maxSteps) {
            watch
              ..reset()
              ..start();
            bot.step();
            watch.stop();
            times.add(watch.elapsedTicks * nsPerTick / 1000);
          }
          if (rep == 0) restarts += bot.run;
          for (final t in times) {
            if (t > noisyMax) noisyMax = t;
          }
          if (fastest == null) {
            fastest = times;
          } else {
            for (var i = 0; i < times.length; i++) {
              if (times[i] < fastest[i]) fastest[i] = times[i];
            }
          }
        }
        for (var i = 0; i < fastest!.length; i++) {
          best.add(fastest[i]);
          if (fastest[i] > worst) {
            worst = fastest[i];
            worstAt = 'race-$rival-$raceNo step $i';
          }
        }
      }
      if (best.isEmpty) continue;
      final sorted = [...best]..sort();
      final mean = best.reduce((a, b) => a + b) / best.length;
      final p99 = sorted[((sorted.length - 1) * 99) ~/ 100];
      if (policy == SimBot.smart && worst > worstSmart) {
        worstSmart = worst;
        worstSmartAt = 'stage $stage, $worstAt';
      }
      print(
        '${'$stage'.padLeft(5)}  ${'$rival'.padLeft(5)}  '
        '${policy.name.padRight(6)}  ${'$built'.padLeft(6)}  '
        '${'${best.length}'.padLeft(5)}  ${'$restarts'.padLeft(8)}  '
        '${mean.toStringAsFixed(1).padLeft(8)}  '
        '${p99.toStringAsFixed(1).padLeft(6)}  '
        '${worst.toStringAsFixed(1).padLeft(8)}  '
        '${noisyMax.toStringAsFixed(1).padLeft(12)}  $worstAt',
      );
    }
  }
  print(
    'worst smart step: ${worstSmart.toStringAsFixed(1)} µs ($worstSmartAt); '
    'a 60 fps frame is 16,667 µs',
  );
}
