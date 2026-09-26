import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/solver/isolate_solver_service.dart';
import 'package:nesty_game/core/services/solver/solver_worker.dart';

import '../../../helpers/level_fixtures.dart';

/// nesty_core's `test/fixtures/unsolvable/003_no_space_dead_end.json`.
const _deadEndJson = '''
{
  "schemaVersion": 1,
  "id": "u003_no_space_dead_end",
  "maxSize": 3,
  "shelves": [
    [ {"type": "tower", "stack": [["green2", "green1"], ["red3"], ["blue3"]]},
      {"type": "tower", "stack": [["blue2", "blue1"], ["red2", "red1"], ["green3"]]},
      {"type": "open", "nest": null} ]
  ]
}
''';

/// nesty_core's `test/fixtures/solvable/008_large_open_board.json`: big
/// enough that a 1-node chunk size keeps the worker busy for many chunks.
const _largeJson = '''
{
  "schemaVersion": 1,
  "id": "008_large_open_board",
  "maxSize": 5,
  "shelves": [
    [ {"type": "open", "nest": ["red5", "red4"]},
      {"type": "open", "nest": ["yellow1"]},
      {"type": "open", "nest": ["green3", "green2", "green1"]},
      {"type": "open", "nest": ["blue5"]},
      {"type": "open", "nest": ["teal3", "teal2"]} ],
    [ {"type": "open", "nest": ["orange2", "orange1"]},
      {"type": "open", "nest": ["teal5", "teal4"]},
      {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["yellow5", "yellow4", "yellow3"]},
      {"type": "open", "nest": ["green5"]} ],
    [ {"type": "open", "nest": ["blue1"]},
      {"type": "open", "nest": ["orange5"]},
      {"type": "open", "nest": ["green4"]},
      {"type": "open", "nest": ["red2", "red1"]},
      {"type": "open", "nest": ["teal1"]} ],
    [ {"type": "open", "nest": ["yellow2"]},
      {"type": "open", "nest": ["blue4", "blue3", "blue2"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": ["orange4", "orange3"]} ]
  ]
}
''';

/// A worker whose every job fails.
void _failingWorker(SendPort replies) {
  final port = RawReceivePort();
  port.handler = (Object? message) {
    if (message is SolverJob) {
      replies.send(SolverJobFailed(message.id, 'boom'));
    } else if (message is SolverStop) {
      port.close();
    }
  };
  replies.send(port.sendPort);
}

/// A worker that crashes on its first job.
void _crashingWorker(SendPort replies) {
  final port = RawReceivePort();
  port.handler = (Object? message) {
    if (message is SolverJob) throw StateError('crash');
    if (message is SolverStop) port.close();
  };
  replies.send(port.sendPort);
}

/// A worker that dies before the handshake.
void _deadOnArrival(SendPort replies) => throw StateError('no start');

void main() {
  final tutorial = GameState.initial(levelFrom(tutorialLevelJson));
  final deadEnd = GameState.initial(levelFrom(_deadEndJson));
  final large = GameState.initial(levelFrom(_largeJson));

  late IsolateSolverService solver;

  setUp(() => solver = IsolateSolverService());
  tearDown(() => solver.dispose());

  test('hints what Solver.hint would, on a long-lived worker', () async {
    expect(solver.hasWorker, isFalse);

    expect(await solver.hint(tutorial), Solver.hint(tutorial));
    expect(solver.hasWorker, isTrue);
    expect(await solver.hint(large), Solver.hint(large));
    expect(solver.hasWorker, isTrue);
  });

  test('the soft-stuck check proves a dead end unsolvable', () async {
    expect(await solver.softStuck(deadEnd), SolveVerdict.unsolvable);
    expect(await solver.softStuck(tutorial), SolveVerdict.solved);
    expect(await solver.softStuck(deadEnd), Solver.softStuck(deadEnd));
  });

  test(
    'a hint on a stuck board has no move and says unsolvable (D22)',
    () async {
      final hint = await solver.hint(deadEnd);
      expect(hint, Solver.hint(deadEnd));
      expect(hint!.move, isNull);
      expect(hint.verdict, SolveVerdict.unsolvable);
    },
  );

  test('latest wins: a newer request supersedes one still starting', () async {
    final first = solver.hint(large);
    final second = solver.softStuck(tutorial);

    expect(await first, isNull);
    expect(await second, SolveVerdict.solved);
  });

  test('latest wins on a running search: the older one completes null and '
      'its late answer is dropped', () async {
    solver = IsolateSolverService(chunkNodes: 1);
    await solver.hint(tutorial); // warm the worker up

    // With a warm worker the older job is on its way before the newer one.
    final older = solver.hint(large);
    final newer = solver.hint(tutorial);

    expect(await older, isNull);
    expect(await newer, Solver.hint(tutorial));
    // The worker still answers the next request.
    expect(await solver.softStuck(deadEnd), SolveVerdict.unsolvable);
  });

  test('cancel completes the request in flight with null', () async {
    solver = IsolateSolverService(chunkNodes: 1);
    await solver.hint(tutorial);

    final cancelled = solver.hint(large);
    solver.cancel();

    expect(await cancelled, isNull);
    expect(await solver.hint(tutorial), Solver.hint(tutorial));
  });

  test('a failing job completes with null', () async {
    solver = IsolateSolverService(entryPoint: _failingWorker);

    expect(await solver.hint(tutorial), isNull);
    expect(await solver.softStuck(tutorial), isNull);
    expect(solver.hasWorker, isTrue);
  });

  test('a crashed worker completes with null and is respawned, until it '
      'has failed ${IsolateSolverService.maxWorkerFailures} times', () async {
    solver = IsolateSolverService(entryPoint: _crashingWorker);

    for (var i = 0; i < IsolateSolverService.maxWorkerFailures; i++) {
      expect(await solver.hint(tutorial), isNull, reason: 'request $i');
      expect(solver.hasWorker, isFalse);
    }
    // Given up: no new worker.
    expect(await solver.hint(tutorial), isNull);
    expect(solver.hasWorker, isFalse);
  });

  test('a worker that cannot start completes with null, and the service '
      'stops trying after ${IsolateSolverService.maxWorkerFailures} '
      'failures', () async {
    solver = IsolateSolverService(entryPoint: _deadOnArrival);

    for (var i = 0; i < IsolateSolverService.maxWorkerFailures + 2; i++) {
      expect(await solver.hint(tutorial), isNull);
    }
    expect(solver.hasWorker, isFalse);
  });

  test('dispose completes the request in flight with null and ends the '
      'worker; later requests answer null', () async {
    solver = IsolateSolverService(chunkNodes: 1);
    await solver.hint(tutorial);

    final pending = solver.hint(large);
    await solver.dispose();

    expect(await pending, isNull);
    expect(solver.hasWorker, isFalse);
    expect(await solver.hint(tutorial), isNull);
    await solver.dispose();
  });
}
