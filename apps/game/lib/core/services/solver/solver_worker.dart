import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:nesty_core/nesty_core.dart';

/// The solver worker isolate's side of `IsolateSolverService` (CLAUDE.md
/// rule 8, docs/plans/m2-lottie-design.md §11).
///
/// Protocol (everything crosses a `SendPort` inside one isolate group):
/// 1. The worker sends back its own `SendPort`.
/// 2. The service sends [SolverJob]s and [SolverCancel]s. The newest job
///    always wins: a job or a cancel drops the job in progress at its next
///    chunk boundary.
/// 3. The worker answers each job it finishes with the `SolverSnapshot`
///    result (an `Int32List` whose first int is the job id), or a
///    [SolverJobFailed] when the job threw.
/// 4. [SolverStop] closes its port, so the isolate exits.
final class SolverJob {
  const SolverJob({
    required this.id,
    required this.task,
    required this.budget,
    required this.snapshot,
    this.chunkNodes = defaultChunkNodes,
  });

  /// Nodes searched between two yields to the worker's event loop, so a
  /// newer job or a cancel is seen within about a millisecond (solver report:
  /// `advance(2000)` with an await between chunks).
  static const defaultChunkNodes = 2000;

  /// Echoed as the result's first int (`SolverSnapshot.resultRequestId`).
  final int id;

  /// `SolverSnapshot.taskHint` or `SolverSnapshot.taskSoftStuck`.
  final int task;

  /// The node budget (`SolverBudgets.hint` or `.softStuck`).
  final int budget;

  /// `SolverSnapshot.encode(state)`.
  final Int32List snapshot;

  final int chunkNodes;
}

/// Drops the job in progress, if any.
final class SolverCancel {
  const SolverCancel();
}

/// Ends the worker.
final class SolverStop {
  const SolverStop();
}

/// Job [id] threw [error] (a malformed snapshot, a solver bug).
final class SolverJobFailed {
  const SolverJobFailed(this.id, this.error);

  final int id;
  final String error;
}

/// The worker isolate's entry point: `Isolate.spawn(solverWorkerMain, port)`.
void solverWorkerMain(SendPort replies) {
  final worker = _SolverWorker(replies);
  replies.send(worker.port.sendPort);
}

final class _SolverWorker {
  _SolverWorker(this._replies) {
    port.handler = _onMessage;
  }

  final SendPort _replies;
  final RawReceivePort port = RawReceivePort();

  /// The job that may still answer; any other running job stops at its next
  /// chunk.
  int? _current;

  void _onMessage(Object? message) {
    switch (message) {
      case SolverJob():
        _current = message.id;
        unawaited(_run(message));
      case SolverCancel():
        _current = null;
      case SolverStop():
        _current = null;
        port.close();
    }
  }

  Future<void> _run(SolverJob job) async {
    try {
      final task = SolverSnapshot.start(
        job.snapshot,
        job.task,
        job.budget,
        requestId: job.id,
      );
      while (!task.advance(job.chunkNodes)) {
        // Let a newer job or a cancel in.
        await Future<void>.delayed(Duration.zero);
        if (_current != job.id) return;
      }
      if (_current != job.id) return;
      _current = null;
      _replies.send(task.result);
    } on Object catch (error) {
      if (_current == job.id) _current = null;
      _replies.send(SolverJobFailed(job.id, '$error'));
    }
  }
}
