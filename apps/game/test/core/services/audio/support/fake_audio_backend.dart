import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nesty_game/core/services/audio/audio_backend.dart';

/// A sound [FakeAudioBackend] loaded.
final class FakeSound extends BackendSound {
  FakeSound(super.name, {required this.length, required this.stream});

  final Duration length;

  /// Loaded to stream (`LoadMode.disk`) rather than decoded into memory.
  final bool stream;
  bool unloaded = false;
}

/// One voice of a [FakeSound], as SoLoud would hold it.
final class FakeVoice {
  FakeVoice(
    this.id,
    this.sound, {
    required this.volume,
    required this.paused,
    required this.looping,
  });

  final int id;
  final FakeSound sound;
  double volume;
  bool paused;
  final bool looping;
  bool protected = false;
  double speed = 1;

  /// Where it plays in the file.
  Duration position = Duration.zero;
  bool ended = false;

  _Fade? _fade;
  Duration? _pauseIn;

  bool get fading => _fade != null;
  bool get pauseScheduled => _pauseIn != null;
}

final class _Fade {
  _Fade(this.from, this.to, this.total);

  final double from;
  final double to;
  final Duration total;
  Duration elapsed = Duration.zero;
}

/// An [AudioBackend] that keeps time the way SoLoud does (audio-analysis
/// plan §2, probe T3–T7), advanced by [advance]:
/// - a voice's fade, its scheduled pause and its position only advance
///   while it plays;
/// - `setPaused` cancels a scheduled pause, `setVolume` a fade;
/// - a zero-length fade or scheduled pause applies at once, and a fade to
///   the current volume just sets it;
/// - a voice that isn't looping ends at the end of its sound.
///
/// Every call is logged in [calls], so a test can assert that nothing
/// reached the engine.
final class FakeAudioBackend implements AudioBackend {
  FakeAudioBackend({
    this.failInit = false,
    this.failLoad = const {},
    this.lengths = const {},
  });

  final bool failInit;

  /// Names whose load throws.
  final Set<String> failLoad;

  /// Each sound's length by name; 1 s when missing.
  final Map<String, Duration> lengths;

  final List<String> calls = [];
  int inits = 0;
  int deinits = 0;
  bool? lowLatency;
  bool running = false;

  final List<FakeSound> _sounds = [];
  final Map<int, FakeVoice> _voices = {};
  int _nextVoice = 1;

  /// The sounds loaded and not unloaded.
  List<FakeSound> get sounds => [
    for (final s in _sounds)
      if (!s.unloaded) s,
  ];

  /// The loaded sound named [name].
  FakeSound sound(String name) => sounds.singleWhere((s) => s.name == name);

  /// Every voice of the sound named [name] (ended ones too), oldest first.
  List<FakeVoice> voicesNamed(String name) => [
    for (final v in _voices.values)
      if (v.sound.name == name) v,
  ];

  /// The one voice of [name].
  FakeVoice voiceOf(String name) => voicesNamed(name).single;

  FakeVoice _live(BackendVoice voice) {
    final v = _voices[voice.id];
    if (v == null || v.ended) {
      throw StateError('no voice ${voice.id}');
    }
    return v;
  }

  /// Plays [time] of audio, a millisecond at a time.
  void advance(Duration time) {
    const step = Duration(milliseconds: 1);
    for (var t = Duration.zero; t < time; t += step) {
      for (final v in _voices.values) {
        if (v.paused || v.ended) continue;
        _tick(v, step);
      }
    }
  }

  static void _tick(FakeVoice v, Duration step) {
    v.position += step * v.speed;
    final length = v.sound.length;
    if (v.position >= length) {
      if (v.looping) {
        v.position -= length;
      } else {
        v.ended = true;
        return;
      }
    }
    final fade = v._fade;
    if (fade != null) {
      fade.elapsed += step;
      final done = fade.elapsed >= fade.total;
      final t = done
          ? 1.0
          : fade.elapsed.inMicroseconds / fade.total.inMicroseconds;
      v.volume = fade.from + (fade.to - fade.from) * t;
      if (done) v._fade = null;
    }
    final pauseIn = v._pauseIn;
    if (pauseIn != null) {
      final left = pauseIn - step;
      if (left <= Duration.zero) {
        v
          ..paused = true
          .._pauseIn = null;
      } else {
        v._pauseIn = left;
      }
    }
  }

  @override
  Future<void> init({required bool lowLatency}) async {
    calls.add('init(lowLatency: $lowLatency)');
    inits++;
    if (failInit) throw StateError('no audio device');
    this.lowLatency = lowLatency;
    running = true;
  }

  @override
  Future<void> deinit() async {
    calls.add('deinit');
    deinits++;
    running = false;
    for (final s in _sounds) {
      s.unloaded = true;
    }
    for (final v in _voices.values) {
      v.ended = true;
    }
  }

  @override
  Future<BackendSound> load(
    String name,
    Uint8List bytes, {
    required bool stream,
  }) async {
    calls.add('load($name, stream: $stream)');
    if (!running) throw StateError('load before init');
    if (failLoad.contains(name)) throw StateError('cannot decode $name');
    final sound = FakeSound(
      name,
      length: lengths[name] ?? const Duration(seconds: 1),
      stream: stream,
    );
    _sounds.add(sound);
    return sound;
  }

  @override
  Future<void> unload(BackendSound sound) async {
    calls.add('unload(${sound.name})');
    final fake = sound as FakeSound;
    fake.unloaded = true;
    for (final v in _voices.values) {
      if (v.sound == fake) v.ended = true;
    }
  }

  @override
  Duration lengthOf(BackendSound sound) => (sound as FakeSound).length;

  @override
  BackendVoice? play(
    BackendSound sound, {
    required double volume,
    bool paused = false,
    bool looping = false,
  }) {
    calls.add(
      'play(${sound.name}, volume: $volume, paused: $paused, '
      'looping: $looping)',
    );
    final fake = sound as FakeSound;
    if (!running || fake.unloaded) throw StateError('cannot play');
    final id = _nextVoice++;
    _voices[id] = FakeVoice(
      id,
      fake,
      volume: volume,
      paused: paused,
      looping: looping,
    );
    return BackendVoice(id);
  }

  @override
  Iterable<BackendVoice> voicesOf(BackendSound sound) => [
    for (final v in _voices.values)
      if (v.sound == sound && !v.ended) BackendVoice(v.id),
  ];

  @override
  bool isPaused(BackendVoice voice) {
    final v = _voices[voice.id];
    return v != null && !v.ended && v.paused;
  }

  @override
  void setPaused(BackendVoice voice, bool paused) {
    calls.add('setPaused(${voice.id}, $paused)');
    _live(voice)
      ..paused = paused
      .._pauseIn = null;
  }

  @override
  void setVolume(BackendVoice voice, double volume) {
    calls.add('setVolume(${voice.id}, $volume)');
    _live(voice)
      ..volume = volume
      .._fade = null;
  }

  @override
  void fadeVolume(BackendVoice voice, double to, Duration time) {
    calls.add('fadeVolume(${voice.id}, $to, ${time.inMilliseconds} ms)');
    final v = _live(voice);
    if (time <= Duration.zero || to == v.volume) {
      v
        ..volume = to
        .._fade = null;
      return;
    }
    v._fade = _Fade(v.volume, to, time);
  }

  @override
  void schedulePause(BackendVoice voice, Duration time) {
    calls.add('schedulePause(${voice.id}, ${time.inMilliseconds} ms)');
    final v = _live(voice);
    if (time <= Duration.zero) {
      v
        ..paused = true
        .._pauseIn = null;
      return;
    }
    v._pauseIn = time;
  }

  @override
  void setSpeed(BackendVoice voice, double speed) {
    calls.add('setSpeed(${voice.id}, $speed)');
    _live(voice).speed = speed;
  }

  @override
  void protect(BackendVoice voice) {
    calls.add('protect(${voice.id})');
    _live(voice).protected = true;
  }
}

/// Serves a few bytes for every asset except [missing], and logs the keys
/// it was asked for.
final class FakeAudioBundle extends CachingAssetBundle {
  FakeAudioBundle({this.missing = const {}});

  final Set<String> missing;
  final List<String> loads = [];

  @override
  Future<ByteData> load(String key) async {
    loads.add(key);
    if (missing.contains(key)) throw FlutterError('Unable to load asset: $key');
    return ByteData.sublistView(Uint8List.fromList([79, 103, 103, 83]));
  }
}
