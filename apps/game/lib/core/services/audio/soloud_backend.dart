import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:nesty_game/core/services/audio/audio_backend.dart';

/// [AudioBackend] on flutter_soloud 4.1.7 (PROGRESS "Package reasons"): one
/// call each, no rules of its own, so the engines' tests over the fake
/// backend cover the behaviour.
///
/// `SoLoud.instance` is touched only from [init] on, so constructing this
/// (DI, widget tests) never loads the native library (D54).
///
/// Loads go through `loadMem`, never `loadAsset`: `loadAsset` first copies
/// the asset to a temp file on every launch and never cleans it up. With
/// [load]'s `stream` the music streams from the in-memory OGG
/// (`LoadMode.disk`); OGG decoding needs flutter_soloud's bundled
/// Ogg/Vorbis libraries, so `NO_XIPH_LIBS` must never be set.
final class SoLoudBackend implements AudioBackend {
  SoLoud get _soloud => SoLoud.instance;

  static SoundHandle _handle(BackendVoice voice) => SoundHandle(voice.id);

  static AudioSource _source(BackendSound sound) =>
      (sound as _SoLoudSound).source;

  @override
  Future<void> init({required bool lowLatency}) async {
    final soloud = _soloud;
    if (!soloud.isInitialized) await soloud.init(lowLatency: lowLatency);
  }

  @override
  Future<void> deinit() async {
    final soloud = _soloud;
    if (soloud.isInitialized) await soloud.deinitAsync();
  }

  @override
  Future<BackendSound> load(
    String name,
    Uint8List bytes, {
    required bool stream,
  }) async {
    final source = await _soloud.loadMem(
      name,
      bytes,
      mode: stream ? LoadMode.disk : LoadMode.memory,
    );
    return _SoLoudSound(name, source);
  }

  @override
  Future<void> unload(BackendSound sound) =>
      _soloud.disposeSource(_source(sound));

  @override
  Duration lengthOf(BackendSound sound) => _soloud.getLength(_source(sound));

  @override
  BackendVoice? play(
    BackendSound sound, {
    required double volume,
    bool paused = false,
    bool looping = false,
  }) {
    final handle = _soloud.play(
      _source(sound),
      volume: volume,
      paused: paused,
      looping: looping,
    );
    // The voice limit returns a zeroed handle instead of throwing.
    return handle.isError || handle.id == 0 ? null : BackendVoice(handle.id);
  }

  @override
  Iterable<BackendVoice> voicesOf(BackendSound sound) => [
    for (final handle in _source(sound).handles) BackendVoice(handle.id),
  ];

  @override
  bool isPaused(BackendVoice voice) => _soloud.getPause(_handle(voice));

  @override
  void setPaused(BackendVoice voice, bool paused) =>
      _soloud.setPause(_handle(voice), paused);

  @override
  void setVolume(BackendVoice voice, double volume) =>
      _soloud.setVolume(_handle(voice), volume);

  @override
  void fadeVolume(BackendVoice voice, double to, Duration time) =>
      _soloud.fadeVolume(_handle(voice), to, time);

  @override
  void schedulePause(BackendVoice voice, Duration time) =>
      _soloud.schedulePause(_handle(voice), time);

  @override
  void setSpeed(BackendVoice voice, double speed) =>
      _soloud.setRelativePlaySpeed(_handle(voice), speed);

  @override
  void protect(BackendVoice voice) {
    final handle = _handle(voice);
    // Protected from being stopped for a new voice, and always given one
    // of the 16 active slots, even when ducked quiet (soloud.cpp
    // calcActiveVoices: "must tick" voices come first).
    _soloud
      ..setProtectVoice(handle, true)
      ..setInaudibleBehavior(handle, true, false);
  }
}

final class _SoLoudSound extends BackendSound {
  _SoLoudSound(super.name, this.source);

  final AudioSource source;
}
