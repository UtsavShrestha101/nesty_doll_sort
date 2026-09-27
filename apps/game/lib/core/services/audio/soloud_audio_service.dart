import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/audio/sfx_engine.dart';
import 'package:nesty_game/core/services/audio/sfx_mix.dart';
import 'package:nesty_game/core/services/audio/soloud_engine_host.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// Real [AudioService] and [JinglePlayer] on flutter_soloud (spec §11.3,
/// AUDIO.md, PROGRESS D19, D23), on the engine `SoLoudEngineHost` shares
/// with the music.
///
/// - [preload] starts the engine and decodes the 17 bundled SFX once, so
///   the first play has no latency; the 3 jingles decode after them without
///   holding up the splash. Any failure (no audio device, a bad file) is
///   logged and leaves that sound, or all of them, silent: never an error
///   (CLAUDE.md rule 3).
/// - [play] follows [SfxMix]: a random clack variant pitched by doll size,
///   `complete_{comboStep}`, the SFX bus volume. It reads the Sound setting
///   on every call, so the Pause and Settings toggles apply at once.
/// - [playJingle] plays a jingle on the SFX bus, gated by the same Sound
///   setting.
/// - It pauses its own voices while the app is in the background and drops
///   plays until it is back; the music service pauses the music itself.
///
/// Registered as itself; `AudioModule` hands the same instance out as
/// [AudioService] and [JinglePlayer].
@LazySingleton(env: [AppEnv.real])
class SoLoudAudioService implements AudioService, JinglePlayer {
  SoLoudAudioService(
    this._database,
    SoLoudEngineHost host, {
    @ignoreParam SfxEngine? engine,
    @ignoreParam AssetBundle? bundle,
    @ignoreParam math.Random? random,
  }) : _engine = engine ?? SoLoudSfxEngine(host),
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
  final Map<String, Duration> _lengths = {};
  Future<void>? _preload;
  Future<void>? _jingles;
  AppLifecycleListener? _lifecycle;
  bool _backgrounded = false;
  bool _disposed = false;

  /// The files that decoded and can play (for tests and logs).
  @visibleForTesting
  Set<String> get loadedFiles => Set.unmodifiable(_loaded);

  @override
  Future<void> preload() => _preload ??= _preloadOnce();

  /// Completes once [preload] has run and the jingles have loaded or failed.
  @visibleForTesting
  Future<void> get jinglesLoaded async {
    await preload();
    final jingles = _jingles;
    if (jingles != null) await jingles;
  }

  Future<void> _preloadOnce() async {
    try {
      await _engine.init();
    } on Object catch (error, stack) {
      _log('the audio engine did not start; sounds stay off', error, stack);
      return;
    }
    if (_disposed) return;
    _listenToLifecycle();
    // In parallel, each decoded off the UI isolate (loadMem runs in a
    // compute isolate).
    await Future.wait([
      for (final file in SoundTokens.allFiles)
        _load(file, SfxMix.assetPath(file)),
    ]);
    if (_disposed) return;
    // In memory too (AUDIO.md "Jingles"), but nothing plays one at launch
    // (the out-of-moves sheet is the first), so the splash doesn't wait for
    // their 4.6 MB of decoded audio (audio-analysis plan §3 "Jingles").
    // _load never throws.
    _jingles = Future.wait([
      for (final file in SoundTokens.jingleFiles)
        _load(file, SfxMix.jingleAssetPath(file)),
    ]);
  }

  Future<void> _load(String file, String asset) async {
    try {
      final data = await _bundle.load(asset);
      await _engine.load(
        file,
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      if (_disposed) return;
      _loaded.add(file);
    } on Object catch (error, stack) {
      _log('$file did not load; it stays silent', error, stack);
      return;
    }
    // What playJingle reports, so a caller can time the music's return.
    try {
      final length = _engine.lengthOf(file);
      if (length != null) _lengths[file] = length;
    } on Object catch (error, stack) {
      _log('the length of $file is unknown', error, stack);
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

  @override
  Duration? playJingle(Jingle jingle) {
    // The SFX bus: the Sound setting, not the Music one (AUDIO.md).
    if (_disposed || _backgrounded || !_database.soundEnabled) return null;
    final file = SfxMix.jingleFileOf(jingle);
    if (!_loaded.contains(file)) return null;
    try {
      _engine.play(file, volume: SfxMix.jingleVolumeOf(file), speed: 1);
    } on Object catch (error, stack) {
      _log('playing $file failed', error, stack);
      return null;
    }
    return _lengths[file] ?? Duration.zero;
  }

  /// Pauses its voices in the background, resumes them in the foreground.
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

  /// Frees its sounds (get_it dispose hook); the engine host stops the
  /// engine after. Idempotent.
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
      _log('freeing the sounds failed', error, stack);
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
