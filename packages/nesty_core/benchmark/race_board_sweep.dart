// Race board sweep (spec-prop §7.7; m7-design Phase 2, the race-core lane's
// report-only sweep): does every race board generate? The app generates
// `DifficultyCurve.raceParams` with `Generator.generateWithRetries`, and a
// board that fails every seed sends the player back to rival select, so the
// expected count is 0.
//
//   dart run benchmark/race_board_sweep.dart [raceNos] [shard/shards]
//   dart compile exe benchmark/race_board_sweep.dart -o /tmp/rsweep
//   /tmp/rsweep 100 0/4 & /tmp/rsweep 100 1/4 & …   # four processes
//
// It covers raceNo 1..[raceNos] (default 100) for every rival at the
// highest levels won 20, 30, 50, 70 and 120 (stages 16, 16, 31, 51 and 71;
// from 121 the race tiers' boards are the 71–120 ones). With a shard, only
// the raceNos with `(raceNo − 1) % shards == shard` run, so shards together
// cover the range once. Each board prints one `board …` line (for adding
// shards up), then a summary per level and rival.
//
// Stopwatch is allowed here: only lib/ must never read the clock (CLAUDE.md
// rule 7). No dart:io, so the same file compiles to JavaScript. Results go to
// stdout, which is the point of a benchmark.
// ignore_for_file: avoid_print
library;

import 'package:nesty_core/nesty_core.dart';

/// The highest levels won the sweep covers.
const _levels = [20, 30, 50, 70, 120];

void main(List<String> args) {
  final raceNos = args.isEmpty ? 100 : int.parse(args[0]);
  var shard = 0;
  var shards = 1;
  if (args.length > 1) {
    final parts = args[1].split('/');
    shard = int.parse(parts[0]);
    shards = int.parse(parts[1]);
  }
  var failures = 0;
  var boards = 0;
  final all = Stopwatch()..start();
  for (final won in _levels) {
    for (var rival = 1; rival <= DifficultyCurve.raceRivals; rival++) {
      var made = 0;
      var failed = 0;
      var closest = 0;
      var retried = 0;
      var slowestMs = 0;
      final watch = Stopwatch()..start();
      for (var raceNo = 1; raceNo <= raceNos; raceNo++) {
        if ((raceNo - 1) % shards != shard) continue;
        final params = DifficultyCurve.raceParams(
          rival: rival,
          raceNo: raceNo,
          highestWonLevel: won,
        );
        final start = watch.elapsedMilliseconds;
        final outcome = Generator.generateWithRetries(params);
        final ms = watch.elapsedMilliseconds - start;
        if (ms > slowestMs) slowestMs = ms;
        boards++;
        switch (outcome) {
          case GeneratorSuccess(
            :final level,
            :final attempt,
            :final tierMatched,
          ):
            made++;
            if (!tierMatched) closest++;
            final retry = level.seed == params.seed ? 0 : 1;
            retried += retry;
            print(
              'board won=$won rival=$rival raceNo=$raceNo ok attempt=$attempt '
              'tier=${outcome.simulation.tier.id} matched=$tierMatched '
              'retried=$retry ms=$ms',
            );
          case GeneratorFailure(:final issues):
            failed++;
            print(
              'board won=$won rival=$rival raceNo=$raceNo FAILED ms=$ms '
              '${issues.map((i) => i.code).join(',')}',
            );
        }
      }
      failures += failed;
      print(
        'summary won=$won rival=$rival boards=${made + failed} made=$made '
        'failed=$failed closest=$closest retried=$retried '
        'slowestMs=$slowestMs totalMs=${watch.elapsedMilliseconds}',
      );
    }
  }
  print(
    'total boards=$boards failures=$failures '
    'seconds=${(all.elapsedMilliseconds / 1000).toStringAsFixed(1)} '
    '(shard $shard/$shards)',
  );
}
