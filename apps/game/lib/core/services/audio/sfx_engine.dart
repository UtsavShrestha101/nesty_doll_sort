import 'dart:typed_data';

import 'package:nesty_game/core/services/audio/audio_backend.dart';
import 'package:nesty_game/core/services/audio/soloud_engine_host.dart';

/// The few audio-engine calls `SoLoudAudioService` needs, keyed by file base
/// name: the SFX and the jingles, which share the SFX bus (AUDIO.md
/// "Jingles"). A seam so the service's rules (settings gate, variant,
/// pitch, mix, lifecycle, silent failure) are unit-tested with a fake
/// engine.
abstract interface class SfxEngine {
  /// Starts the engine. Throws when the audio device can't start; the
  /// service then stays silent.
  Future<void> init();

  /// Decodes [bytes] (a whole WAV or OGG file) into memory as [name].
  /// Throws when the file can't be decoded.
  Future<void> load(String name, Uint8List bytes);

  /// How long [name] plays, or null when it isn't loaded.
  Duration? lengthOf(String name);

  /// Plays [name] once at [volume] (0–1) and relative [speed] (1 = as
  /// recorded; the clacks' pitch). A name that isn't loaded is ignored.
  /// Runs on every move, so it stays cheap and synchronous.
  void play(String name, {required double volume, required double speed});

  /// Pauses (or resumes) the voices of this engine's sounds: the app went
  /// to the background (or came back). The music is not one of them.
  void setPaused(bool paused);

  /// Frees this engine's sounds. The engine itself keeps running for the
  /// music; `SoLoudEngineHost` stops it.
  Future<void> dispose();
}

/// [SfxEngine] on the shared engine (`SoLoudEngineHost`, flutter_soloud
/// 4.1.7: per-play playback speed for the clack pitch).
///
/// It only ever touches the sounds it loaded: `setPaused` and `dispose`
/// used to pause or free every sound in the engine, which would have
/// stopped the music too (audio-analysis plan §3).
final class SoLoudSfxEngine implements SfxEngine {
  SoLoudSfxEngine(this._host);

  final SoLoudEngineHost _host;
  final Map<String, BackendSound> _sounds = {};
  bool _started = false;

  AudioBackend get _backend => _host.backend;

  @override
  Future<void> init() async {
    await _host.start();
    _started = true;
  }

  @override
  Future<void> load(String name, Uint8List bytes) async {
    if (!_started) throw StateError('SoLoudSfxEngine.load before init');
    // Decoded into memory: no latency on the first play.
    _sounds[name] = await _backend.load(name, bytes, stream: false);
  }

  @override
  Duration? lengthOf(String name) {
    final sound = _sounds[name];
    return sound == null ? null : _backend.lengthOf(sound);
  }

  @override
  void play(String name, {required double volume, required double speed}) {
    final sound = _sounds[name];
    if (sound == null) return;
    if (speed == 1) {
      _backend.play(sound, volume: volume);
      return;
    }
    // Start paused so the rate applies from the first sample.
    final voice = _backend.play(sound, volume: volume, paused: true);
    if (voice == null) return;
    _backend
      ..setSpeed(voice, speed)
      ..setPaused(voice, false);
  }

  @override
  void setPaused(bool paused) {
    for (final sound in _sounds.values) {
      for (final voice in _backend.voicesOf(sound)) {
        _backend.setPaused(voice, paused);
      }
    }
  }

  /// Frees every sound it loaded, even when one fails, then throws the
  /// first failure.
  @override
  Future<void> dispose() async {
    final sounds = _sounds.values.toList();
    _sounds.clear();
    _started = false;
    (Object, StackTrace)? failure;
    for (final sound in sounds) {
      try {
        await _backend.unload(sound);
      } on Object catch (error, stack) {
        failure ??= (error, stack);
      }
    }
    if (failure case (final error, final stack)) {
      Error.throwWithStackTrace(error, stack);
    }
  }
}
