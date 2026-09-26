import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/sfx_engine.dart';
import 'package:nesty_game/core/services/audio/sfx_mix.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// Real [AudioService] on flutter_soloud (spec §11.3, PROGRESS D19, D23).
///
/// - [preload] starts the engine and decodes the 17 bundled SFX once, so
///   the first play has no latency. Any failure (no audio device, a bad
///   file) is logged and leaves that sound, or all of them, silent: never
///   an error (CLAUDE.md rule 3).
/// - [play] follows [SfxMix]: a random clack variant pitched by doll size,
///   `complete_{comboStep}`, the SFX mix volume. It reads the Sound setting
///   on every call, so the Pause and Settings toggles apply at once.
/// - It pauses every voice while the app is in the background and drops
///   plays until it is back.
/// - Music has no files yet: nothing plays.
// TODO(M3): the two music loops on their own volume (spec §11.3, tokens
// `sound.music`, `mix.musicDefault` 0.5), started from Home and Gameplay.
@LazySingleton(as: AudioService, env: [AppEnv.real])
class SoLoudAudioService implements AudioService {
  SoLoudAudioService(
    this._database, {
    @ignoreParam SfxEngine? engine,
    @ignoreParam AssetBundle? bundle,
    @ignoreParam math.Random? random,
  }) : _engine = engine ?? SoLoudSfxEngine(),
       _bundle = bundle ?? rootBundle,
       // Presentation only (which of three clacks): an unseeded Random is
       // fine here; rule 7's seeded PRNG is for core.
       _random = random ?? math.Random();

  final DatabaseService _database;
  final SfxEngine _engine;
  final AssetBundle _bundle;
  final math.Random _random;

  // Cached: a fresh tear-off per play would allocate a closure each move.
  late final int Function(int count) _pickVariant = _random.nextInt;

  final Set<String> _loaded = {};
  Future<void>? _preload;
  AppLifecycleListener? _lifecycle;
  bool _backgrounded = false;
  bool _disposed = false;

  /// The files that decoded and can play (for tests and logs).
  @visibleForTesting
  Set<String> get loadedFiles => Set.unmodifiable(_loaded);

  @override
  Future<void> preload() => _preload ??= _preloadOnce();

  Future<void> _preloadOnce() async {
    try {
      await _engine.init();
    } on Object catch (error, stack) {
      _log('the audio engine did not start; sounds stay off', error, stack);
      return;
    }
    if (_disposed) return;
    _listenToLifecycle();
    await Future.wait([for (final file in SoundTokens.allFiles) _load(file)]);
  }

  Future<void> _load(String file) async {
    try {
      final data = await _bundle.load(SfxMix.assetPath(file));
      await _engine.load(
        file,
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      if (!_disposed) _loaded.add(file);
    } on Object catch (error, stack) {
      _log('$file did not load; it stays silent', error, stack);
    }
  }

  void _listenToLifecycle() {
    try {
      _lifecycle = AppLifecycleListener(onStateChange: didChangeAppLifecycle);
    } on Object catch (error, stack) {
      // No binding (a bare unit test): sounds just keep playing.
      _log('no lifecycle listener', error, stack);
    }
  }

  @override
  void play(SoundEffect effect, {int? dollSize, int? comboStep}) {
    if (_disposed || _backgrounded || !_database.soundEnabled) return;
    final file = SfxMix.fileFor(
      effect,
      randomIndex: _pickVariant,
      comboStep: comboStep,
    );
    if (!_loaded.contains(file)) return;
    try {
      _engine.play(
        file,
        volume: SfxMix.volumeOf(file),
        speed: SfxMix.speedFor(effect, dollSize: dollSize),
      );
    } on Object catch (error, stack) {
      _log('playing $file failed', error, stack);
    }
  }

  /// Pauses the voices in the background, resumes them in the foreground.
  /// `inactive` (a system sheet over the app) keeps playing.
  @visibleForTesting
  void didChangeAppLifecycle(AppLifecycleState state) {
    final background = switch (state) {
      AppLifecycleState.resumed || AppLifecycleState.inactive => false,
      AppLifecycleState.hidden ||
      AppLifecycleState.paused ||
      AppLifecycleState.detached => true,
    };
    if (background == _backgrounded || _disposed) return;
    _backgrounded = background;
    try {
      _engine.setPaused(background);
    } on Object catch (error, stack) {
      _log('pausing the audio failed', error, stack);
    }
  }

  /// Stops the engine (get_it dispose hook). Idempotent.
  @override
  @disposeMethod
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _lifecycle?.dispose();
    _lifecycle = null;
    _loaded.clear();
    try {
      await _engine.dispose();
    } on Object catch (error, stack) {
      _log('stopping the audio engine failed', error, stack);
    }
  }

  static void _log(String message, Object error, StackTrace stack) {
    developer.log(
      message,
      name: 'nesty.audio',
      error: error,
      stackTrace: stack,
    );
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) debugPrint('[nesty.audio] $message: $error');
  }
}
