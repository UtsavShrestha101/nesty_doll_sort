import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// Flushes the save when the app leaves the foreground (m3-design §3.2):
/// `SaveService.flush` awaits the write queue, writes once more if it is
/// still dirty, then makes the box durable. One instance, both environments
/// (flushing `InMemorySaveService`/`FakeSaveService` is a harmless no-op).
///
/// [start] is called once from `bootstrap`, after DI resolves it and before
/// `runApp` — not from the constructor, so a bare unit test that builds this
/// class never touches `WidgetsBinding` (`AppLifecycleListener` needs a
/// binding; see `SoLoudMusicService` for the same shape).
@lazySingleton
class SaveLifecycleFlusher {
  SaveLifecycleFlusher(this._save);

  final SaveService _save;
  AppLifecycleListener? _lifecycle;

  /// Starts listening for `paused`/`detached`. Idempotent.
  void start() {
    if (_lifecycle != null) return;
    try {
      _lifecycle = AppLifecycleListener(onStateChange: didChangeAppLifecycle);
    } on Object catch (error, stack) {
      // No binding (a bare unit test): the save just keeps flushing on
      // `dispose` only.
      _log('no lifecycle listener', error, stack);
    }
  }

  @visibleForTesting
  void didChangeAppLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.detached:
        unawaited(_flush());
      case AppLifecycleState.resumed ||
          AppLifecycleState.inactive ||
          AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _flush() async {
    try {
      await _save.flush();
    } on Object catch (error, stack) {
      // SaveService.flush already never throws (rule 3); this is a last
      // resort so a lifecycle callback can never crash the app.
      _log('flush on a lifecycle change failed', error, stack);
    }
  }

  /// Stops listening (DI reset). Idempotent.
  @disposeMethod
  void dispose() {
    _lifecycle?.dispose();
    _lifecycle = null;
  }

  static void _log(String message, Object error, StackTrace? stack) {
    developer.log(message, name: 'nesty.save', error: error, stackTrace: stack);
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) debugPrint('[nesty.save] $message: $error');
  }
}
