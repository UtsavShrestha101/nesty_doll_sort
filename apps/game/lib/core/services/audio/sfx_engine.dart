import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';

/// The few audio-engine calls `SoLoudAudioService` needs, keyed by SFX file
/// base name. A seam so the service's rules (settings gate, variant,
/// pitch, mix, lifecycle, silent failure) are unit-tested with a fake
/// engine: flutter_soloud needs its native library.
abstract interface class SfxEngine {
  /// Starts the engine. Throws when the audio device can't start; the
  /// service then stays silent.
  Future<void> init();

  /// Decodes [bytes] (a whole audio file) into memory as [name]. Throws when
  /// the file can't be decoded.
  Future<void> load(String name, Uint8List bytes);

  /// Plays [name] once at [volume] (0–1) and relative [speed] (1 = as
  /// recorded; the clacks' pitch). A name that isn't loaded is ignored.
  /// Runs on every move, so it stays cheap and synchronous.
  void play(String name, {required double volume, required double speed});

  /// Pauses (or resumes) every voice that is playing: the app went to the
  /// background (or came back).
  void setPaused(bool paused);

  /// Frees the loaded sounds and stops the engine.
  Future<void> dispose();
}

/// [SfxEngine] on flutter_soloud 4.1.7 (PROGRESS rule-9 row: per-play
/// playback speed for the clack pitch, low latency).
///
/// `SoLoud.instance` is touched only from [init] on, so constructing this
/// (DI, widget tests) never loads the native library.
final class SoLoudSfxEngine implements SfxEngine {
  final Map<String, AudioSource> _sources = {};
  SoLoud? _soloud;

  @override
  Future<void> init() async {
    final soloud = SoLoud.instance;
    if (!soloud.isInitialized) await soloud.init();
    _soloud = soloud;
  }

  @override
  Future<void> load(String name, Uint8List bytes) async {
    final soloud = _soloud;
    if (soloud == null) throw StateError('SoLoudSfxEngine.load before init');
    // loadMem, not loadAsset: loadAsset copies every asset to a temporary
    // file first, which needs a writable temp folder for no benefit.
    _sources[name] = await soloud.loadMem(name, bytes);
  }

  @override
  void play(String name, {required double volume, required double speed}) {
    final soloud = _soloud;
    final source = _sources[name];
    if (soloud == null || source == null) return;
    if (speed == 1) {
      soloud.play(source, volume: volume);
      return;
    }
    // Start paused so the rate applies from the first sample.
    final handle = soloud.play(source, volume: volume, paused: true);
    soloud
      ..setRelativePlaySpeed(handle, speed)
      ..setPause(handle, false);
  }

  @override
  void setPaused(bool paused) {
    final soloud = _soloud;
    if (soloud == null) return;
    for (final source in soloud.activeSounds) {
      for (final handle in source.handles) {
        soloud.setPause(handle, paused);
      }
    }
  }

  @override
  Future<void> dispose() async {
    final soloud = _soloud;
    _soloud = null;
    _sources.clear();
    if (soloud == null || !soloud.isInitialized) return;
    await soloud.disposeAllSources();
    soloud.deinit();
  }
}
