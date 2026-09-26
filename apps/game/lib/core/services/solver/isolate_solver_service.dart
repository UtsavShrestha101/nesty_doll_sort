import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/solver/solver_service.dart';
import 'package:nesty_game/core/services/solver/solver_worker.dart';

/// Real [SolverService]: nesty_core's solver on one long-lived worker
/// isolate, so a hint or soft-stuck search never costs the UI a frame
/// (CLAUDE.md rule 8, spec §2.3, §6.3).
///
/// - The worker is spawned on the first request and kept for the app's
///   lifetime. States cross as `SolverSnapshot`s (about 100 ints) and
///   answers as its fixed result layout, mapped back here with the state
///   that was asked about.
/// - **Latest wins:** a new request or [cancel] completes the one in flight
///   with null at once, and the worker drops it at its next 2000-node chunk.
///   A late answer for a superseded request is ignored (it carries its id).
/// - **Silent failure** (rule 3): a state that can't be encoded, a job that
///   throws, a worker that dies or can't be spawned all complete with null;
///   the bloc then uses `Solver.fallbackHint`. A dead worker is respawned on
///   the next request; after [maxWorkerFailures] failed spawns or crashes
///   with no answer in between, the service stops trying.
@LazySingleton(as: SolverService, env: [AppEnv.real])
class IsolateSolverService implements SolverService {
  IsolateSolverService({
    @ignoreParam void Function(SendPort replies) entryPoint = solverWorkerMain,
    @ignoreParam int chunkNodes = SolverJob.defaultChunkNodes,
  }) : _entryPoint = entryPoint,
       _chunkNodes = chunkNodes;

  /// Failed spawns or worker crashes, with no answer delivered in between,
  /// before the service gives up and answers every request with null.
  static const maxWorkerFailures = 3;

  final void Function(SendPort replies) _entryPoint;
  final int _chunkNodes;

  _Worker? _worker;
  Future<_Worker?>? _spawning;
  int _workerFailures = 0;
  _Pending? _pending;
  int _lastId = 0;
  bool _disposed = false;

  /// True while a worker isolate is alive (for tests).
  @visibleForTesting
  bool get hasWorker => _worker != null;

  @override
  Future<HintResult?> hint(GameState state) async {
    final result = await _request(
      state,
      SolverSnapshot.taskHint,
      SolverBudgets.hint,
    );
    if (result == null) return null;
    try {
      return SolverSnapshot.readHint(result, state);
    } on Object catch (error, stack) {
      _log('an unreadable hint result', error, stack);
      return null;
    }
  }

  @override
  Future<SolveVerdict?> softStuck(GameState state) async {
    final result = await _request(
      state,
      SolverSnapshot.taskSoftStuck,
      SolverBudgets.softStuck,
    );
    if (result == null) return null;
    try {
      return SolverSnapshot.readVerdict(result);
    } on Object catch (error, stack) {
      _log('an unreadable soft-stuck result', error, stack);
      return null;
    }
  }

  @override
  void cancel() {
    _supersede();
    _worker?.send(const SolverCancel());
  }

  @override
  @disposeMethod
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _supersede();
    _worker?.stop();
    _worker = null;
  }

  Future<Int32List?> _request(GameState state, int task, int budget) {
    _supersede();
    if (_disposed || _workerFailures >= maxWorkerFailures) {
      return Future.value();
    }
    final Int32List snapshot;
    try {
      snapshot = SolverSnapshot.encode(state);
    } on Object catch (error, stack) {
      _log('a state the snapshot format cannot carry', error, stack);
      return Future.value();
    }
    // Ids stay positive Int32s, as the snapshot's requestId requires.
    _lastId = _lastId >= 0x7FFFFFFF ? 1 : _lastId + 1;
    final pending = _Pending(_lastId);
    _pending = pending;
    final job = SolverJob(
      id: pending.id,
      task: task,
      budget: budget,
      snapshot: snapshot,
      chunkNodes: _chunkNodes,
    );
    unawaited(_send(pending, job));
    return pending.completer.future;
  }

  Future<void> _send(_Pending pending, SolverJob job) async {
    final worker = _worker ?? await (_spawning ??= _spawn());
    // Superseded while the worker was starting: the newer request sends
    // its own job.
    if (!identical(_pending, pending)) return;
    if (worker == null) {
      _complete(pending.id, null);
      return;
    }
    worker.send(job);
  }

  /// Completes the request in flight with null (latest wins).
  void _supersede() {
    final pending = _pending;
    if (pending == null) return;
    _pending = null;
    pending.completer.complete();
  }

  void _complete(int id, Int32List? result) {
    final pending = _pending;
    if (pending == null || pending.id != id) return; // stale: dropped
    _pending = null;
    if (result != null) _workerFailures = 0;
    pending.completer.complete(result);
  }

  Future<_Worker?> _spawn() async {
    try {
      final worker = await _Worker.spawn(
        _entryPoint,
        onReply: _onReply,
        onExit: _onWorkerExit,
      );
      if (_disposed) {
        worker.stop();
        return null;
      }
      _worker = worker;
      return worker;
    } on Object catch (error, stack) {
      _workerFailures++;
      _log('the solver worker did not start', error, stack);
      return null;
    } finally {
      _spawning = null;
    }
  }

  void _onReply(Object? message) {
    switch (message) {
      case final Int32List result
          when result.length == SolverSnapshot.resultLength:
        _complete(result[SolverSnapshot.resultRequestId], result);
      case SolverJobFailed(:final id, :final error):
        _log('solver job $id failed', error, StackTrace.empty);
        _complete(id, null);
      default:
        _log('an unexpected worker message', message ?? 'null', null);
    }
  }

  /// The worker exited (a crash, or [dispose]): whatever it was running is
  /// lost, and the next request spawns a new one.
  void _onWorkerExit(_Worker worker) {
    if (!identical(_worker, worker)) return;
    _worker = null;
    if (!_disposed) {
      _workerFailures++;
      _log('the solver worker exited', 'exit', null);
    }
    _supersede();
  }

  static void _log(String message, Object error, StackTrace? stack) {
    developer.log(
      message,
      name: 'nesty.solver',
      error: error,
      stackTrace: stack,
    );
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) debugPrint('[nesty.solver] $message: $error');
  }
}

final class _Pending {
  _Pending(this.id);

  final int id;
  final Completer<Int32List?> completer = Completer();
}

/// One worker isolate and its ports.
final class _Worker {
  _Worker._(this._isolate, this._requests, this._replies, this._exits);

  static Future<_Worker> spawn(
    void Function(SendPort replies) entryPoint, {
    required void Function(Object? message) onReply,
    required void Function(_Worker worker) onExit,
  }) async {
    final handshake = Completer<SendPort>();
    final replies = RawReceivePort();
    final exits = RawReceivePort();
    _Worker? worker;
    replies.handler = (Object? message) {
      if (!handshake.isCompleted && message is SendPort) {
        handshake.complete(message);
        return;
      }
      onReply(message);
    };
    exits.handler = (Object? _) {
      if (!handshake.isCompleted) {
        handshake.completeError(StateError('the worker exited at start'));
      }
      final alive = worker;
      if (alive != null) {
        alive._close();
        onExit(alive);
      } else {
        replies.close();
        exits.close();
      }
    };
    try {
      final isolate = await Isolate.spawn(
        entryPoint,
        replies.sendPort,
        onExit: exits.sendPort,
        // An uncaught error ends the worker; onExit then reports it.
        errorsAreFatal: true,
        debugName: 'nesty-solver',
      );
      final requests = await handshake.future;
      return worker = _Worker._(isolate, requests, replies, exits);
    } on Object {
      replies.close();
      exits.close();
      rethrow;
    }
  }

  final Isolate _isolate;
  final SendPort _requests;
  final RawReceivePort _replies;
  final RawReceivePort _exits;
  bool _closed = false;

  void send(Object message) {
    if (!_closed) _requests.send(message);
  }

  /// Asks the worker to finish, then kills it in case it is mid-chunk.
  void stop() {
    if (_closed) return;
    _requests.send(const SolverStop());
    _isolate.kill(priority: Isolate.beforeNextEvent);
    _close();
  }

  void _close() {
    if (_closed) return;
    _closed = true;
    _replies.close();
    _exits.close();
  }
}
