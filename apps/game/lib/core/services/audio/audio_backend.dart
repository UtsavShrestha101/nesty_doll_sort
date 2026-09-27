import 'dart:typed_data';

/// A sound an [AudioBackend] loaded, known by the name it was loaded as.
///
/// Each backend subclasses it to carry its own handle (flutter_soloud's
/// `AudioSource` in `SoLoudBackend`) and only ever receives its own.
class BackendSound {
  BackendSound(this.name);

  /// The file's base name, such as `music_home` (for logs and tests).
  final String name;

  @override
  String toString() => 'BackendSound($name)';
}

/// One instance of a [BackendSound], playing or paused (flutter_soloud's
/// `SoundHandle` id).
extension type const BackendVoice(int id) {}

/// The few flutter_soloud calls the game makes, as one seam (CLAUDE.md rule
/// 4, PROGRESS D54): the SFX engine and the music service both run on it
/// through `SoLoudEngineHost`. The real one is `SoLoudBackend`; tests run a
/// fake that keeps time (fades, scheduled pauses) the way SoLoud does, so
/// the engines' rules are tested without the native library.
///
/// SoLoud semantics the callers rely on (audio-analysis plan §2, probe
/// T3–T7): a voice's fade and its scheduled pause only advance while it
/// plays; [setPaused] cancels a pending [schedulePause]; [setVolume] cancels
/// a running [fadeVolume].
///
/// Every call can throw (the engine didn't start, a voice ended): callers
/// catch and stay silent (rule 3).
abstract interface class AudioBackend {
  /// Starts the engine: the low-latency output profile when [lowLatency]
  /// (audio plan Q41). A second call while it runs is a no-op.
  Future<void> init({required bool lowLatency});

  /// Stops the engine and frees every sound it loaded.
  Future<void> deinit();

  /// Loads [bytes], a whole WAV or OGG file, as [name].
  ///
  /// [stream] keeps the compressed bytes and decodes as it plays (the music
  /// loops: a decoded loop is about 23 MB); otherwise the whole file is
  /// decoded into memory up front (the SFX and jingles, no first-play
  /// latency). Throws when the file can't be decoded.
  Future<BackendSound> load(
    String name,
    Uint8List bytes, {
    required bool stream,
  });

  /// Stops every voice of [sound] and frees it.
  Future<void> unload(BackendSound sound);

  /// How long [sound] plays once.
  Duration lengthOf(BackendSound sound);

  /// Starts a voice of [sound] at [volume] (0–1): [paused] (it waits for
  /// [setPaused]) or not, [looping] the whole file or once. Null when no
  /// voice could start (the engine's active-voice limit).
  BackendVoice? play(
    BackendSound sound, {
    required double volume,
    bool paused = false,
    bool looping = false,
  });

  /// The voices of [sound] that haven't ended.
  Iterable<BackendVoice> voicesOf(BackendSound sound);

  bool isPaused(BackendVoice voice);

  /// Pauses or resumes [voice] where it is; also cancels its
  /// [schedulePause].
  void setPaused(BackendVoice voice, bool paused);

  /// Sets [voice]'s volume at once; also cancels its [fadeVolume].
  void setVolume(BackendVoice voice, double volume);

  /// Fades [voice]'s volume to [to] over [time] of playing, or sets it at
  /// once when [time] is zero.
  void fadeVolume(BackendVoice voice, double to, Duration time);

  /// Pauses [voice] after [time] of playing (at once when zero).
  void schedulePause(BackendVoice voice, Duration time);

  /// [voice]'s playback rate relative to the file (1 = as recorded; the
  /// clack pitch).
  void setSpeed(BackendVoice voice, double speed);

  /// Keeps [voice] mixed whatever else plays (the music loops): protected
  /// from the voice limit and ticking while quiet, so a burst of SFX over
  /// ducked music can't drop it (audio-analysis plan §2 "Voice limit").
  void protect(BackendVoice voice);
}
