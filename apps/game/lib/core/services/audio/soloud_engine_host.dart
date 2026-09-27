import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/services/audio/audio_backend.dart';
import 'package:nesty_game/core/services/audio/soloud_backend.dart';

/// The one owner of the audio engine (audio-analysis plan §3 "Engine
/// sharing"): the SFX engine and the music service play on the same
/// [backend], and only this starts and stops it. Each of them frees just
/// its own sounds, so pausing or disposing the SFX never touches the music.
///
/// [start] runs once, for whoever asks first (the splash's SFX preload, or
/// the first music): the low-latency profile only in prod (audio plan Q41,
/// `Flavor.audioLowLatency`). A failure is kept, so every later [start]
/// rethrows it and its callers stay silent (rule 3).
///
/// get_it disposes in reverse registration order and the services depend
/// on this, so they free their sounds before [dispose] stops the engine.
@LazySingleton(env: [AppEnv.real])
class SoLoudEngineHost {
  SoLoudEngineHost({
    @ignoreParam AudioBackend? backend,
    @ignoreParam bool? lowLatency,
  }) : backend = backend ?? SoLoudBackend(),
       _lowLatency = lowLatency;

  /// The engine both services play on; usable once [start] has completed.
  final AudioBackend backend;

  /// Overrides the flavor's choice (tests).
  final bool? _lowLatency;

  Future<void>? _start;
  bool _disposed = false;

  /// Starts the engine, once. Throws when it can't (no audio device), or
  /// after [dispose].
  Future<void> start() => _start ??= _startOnce();

  Future<void> _startOnce() async {
    if (_disposed) throw StateError('the audio engine host was disposed');
    await backend.init(
      lowLatency: _lowLatency ?? FlavorConfig.flavor.audioLowLatency,
    );
  }

  /// Stops the engine (get_it dispose hook), after the services freed
  /// their sounds. Idempotent; an engine that never started is left alone.
  @disposeMethod
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final start = _start;
    if (start == null) return;
    try {
      await start;
    } on Object {
      return;
    }
    try {
      await backend.deinit();
    } on Object catch (error, stack) {
      developer.log(
        'stopping the audio engine failed',
        name: 'nesty.audio',
        error: error,
        stackTrace: stack,
      );
      if (kDebugMode) debugPrint('[nesty.audio] engine stop failed: $error');
    }
  }
}
