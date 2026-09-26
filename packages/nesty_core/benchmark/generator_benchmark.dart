// Generator benchmark against the targets of docs/plans/m1-core-design.md
// §5: `Generator.generate` median ≤ 1.5 s and p95 ≤ 5 s per level. Bonus
// Endless and the daily puzzle generate on the phone (spec §7.1, §7.5), and
// the admin's Generator screen in the browser (spec §15).
//
//   dart run benchmark/generator_benchmark.dart                    # VM (JIT)
//   dart compile exe benchmark/generator_benchmark.dart -o /tmp/genb && /tmp/genb
//   dart compile js -O2 benchmark/generator_benchmark.dart -o /tmp/genb.js
//   node /tmp/genb.js                                              # dart2js
//
// Stopwatch is allowed here: only lib/ must never read the clock (CLAUDE.md
// rule 7). No dart:io, so the same file compiles to JavaScript. It times
// bonus levels 1–300 of the curve and the daily puzzles of 2027, and
// reports the spread per stage of the curve. Results go to stdout, which is
// the point of a benchmark.
// ignore_for_file: avoid_print
library;

import 'package:nesty_core/nesty_core.dart';

/// Design §5 targets, in milliseconds.
const int medianTargetMs = 1500;
const int p95TargetMs = 5000;

/// One timed generation.
typedef _Run = ({String name, int micros, GeneratorOutcome outcome});

_Run _time(String name, GeneratorParams params) {
  final watch = Stopwatch()..start();
  final outcome = Generator.generate(params);
  watch.stop();
  return (name: name, micros: watch.elapsedMicroseconds, outcome: outcome);
}

String _ms(int micros) => (micros / 1000).toStringAsFixed(1).padLeft(8);

int _percentile(List<int> sorted, int percent) =>
    sorted[((sorted.length - 1) * percent / 100).round()];

/// Prints median, p95 and max of [runs], plus the attempts and fallbacks,
/// and returns whether the design §5 targets hold.
bool _report(String label, List<_Run> runs) {
  final micros = [for (final run in runs) run.micros]..sort();
  var failures = 0;
  var closest = 0;
  var attempts = 0;
  var worst = runs.first;
  for (final run in runs) {
    if (run.micros > worst.micros) worst = run;
    switch (run.outcome) {
      case GeneratorSuccess(:final attempt, :final tierMatched):
        // A closest-tier result tried every attempt first (design A15).
        attempts += tierMatched ? attempt + 1 : Generator.maxAttempts;
        if (!tierMatched) closest++;
      case GeneratorFailure(attempts: final made):
        attempts += made;
        failures++;
    }
  }
  final median = _percentile(micros, 50);
  final p95 = _percentile(micros, 95);
  print(
    '${label.padRight(22)} n ${runs.length.toString().padLeft(4)}  '
    'median ${_ms(median)}  p95 ${_ms(p95)}  max ${_ms(micros.last)} ms  '
    '(${worst.name})  attempts ${(attempts / runs.length).toStringAsFixed(1)}'
    '/level  closest $closest  failures $failures',
  );
  return median <= medianTargetMs * 1000 &&
      p95 <= p95TargetMs * 1000 &&
      failures == 0;
}

void main() {
  // Warm up the JIT so the first stage isn't charged for compilation.
  for (var n = 16; n < 26; n++) {
    Generator.generate(DifficultyCurve.bonusParams(n));
  }

  final bonus = [
    for (var n = 1; n <= 300; n++)
      _time('bonus $n', DifficultyCurve.bonusParams(n)),
  ];
  final daily = <_Run>[];
  for (var month = 1; month <= 12; month++) {
    for (var day = 1; day <= 28; day++) {
      final date = DifficultyCurve.dailySeed(2027, month, day);
      daily.add(_time('daily $date', DifficultyCurve.dailyParams(date)));
    }
  }

  print(
    'Generator.generate (spec §6.5), design §5 targets: median ≤ '
    '$medianTargetMs ms, p95 ≤ $p95TargetMs ms',
  );
  final stages = [
    ('bonus 1–15 (no towers)', 1, 15),
    ('bonus 16–30 (towers)', 16, 30),
    ('bonus 31–50 (locks)', 31, 50),
    ('bonus 51–70 (ice)', 51, 70),
    ('bonus 71–120 (size 5)', 71, 120),
    ('bonus 121–300 (size 6)', 121, 300),
  ];
  for (final (label, from, to) in stages) {
    _report(label, bonus.sublist(from - 1, to));
  }
  final bonusOk = _report('bonus 1–300', bonus);
  final dailyOk = _report('daily 2027 (336 days)', daily);
  print(bonusOk && dailyOk ? 'Within the targets.' : 'OVER THE TARGETS.');
}
