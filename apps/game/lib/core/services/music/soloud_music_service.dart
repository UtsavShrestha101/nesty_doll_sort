import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/audio/audio_backend.dart';
import 'package:nesty_game/core/services/audio/soloud_engine_host.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/music/music_mix.dart';
import 'package:nesty_game/core/services/music/music_service.dart';

/// What holds the music paused where it is (not faded out). Each clears on
/// its own and the music returns once none holds, so an Android ad's own
/// trip to the background and [MusicService.pauseForAd] don't double up.
enum _PauseReason { background, ad }

/// Real [MusicService] on the engine `SoLoudEngineHost` shares with the SFX
/// (AUDIO.md "Music rules", audio-analysis plan §3 "MusicService").
///
/// - **One looping voice per track**, made on first use: the OGG is read
///   from the bundle and streamed from memory (`AudioBackend.load` with
///   `stream`: `loadMem` in `LoadMode.disk`, never `loadAsset`), and the
///   voice is protected so a burst of SFX can't take its slot. Once the
///   first loop has loaded, the other one loads too while that screen is
///   idle, so a crossfade never waits on a load.
/// - **It reconciles from state**, not from a log of commands: it keeps the
///   track on screen, the ducks, the pause reasons, the setting and the
///   volume, and each change moves the voices towards them. Calls made
///   while a loop loads apply when it lands.
/// - **Switching tracks crossfades**: the outgoing loop fades to 0 and
///   pauses, so it resumes later where it stopped; a parked loop comes back
///   as volume 0 → unpause → fade (SoLoud only advances a fade while its
///   voice plays).
/// - **Music off** loads nothing and makes no engine call until it is
///   turned on, and stays silent across routes, ads and the lifecycle.
/// - **Failures are silent** (rule 3): a loop that can't load or play stays
///   quiet, and every engine call is caught and logged.
///
/// Nothing runs per frame: the engine does the fades.
@LazySingleton(as: MusicService, env: [AppEnv.real])
class SoLoudMusicService implements MusicService {
  SoLoudMusicService(
    this._database,
    this._host, {
    @ignoreParam AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle,
       _enabled = _database.musicEnabled {
    _listenToSetting();
    _listenToLifecycle();
  }

  final DatabaseService _database;
  final SoLoudEngineHost _host;
  final AssetBundle _bundle;

  final Map<MusicTrack, _Loop> _loops = {
    for (final track in MusicTrack.values) track: _Loop(track),
  };
  final Map<DuckReason, int> _ducks = {};
  final Set<_PauseReason> _pauses = {};
  StreamSubscription<bool>? _setting;
  AppLifecycleListener? _lifecycle;

  bool _enabled;
  double _volume = MusicMix.defaultVolume;
  MusicTrack? _current;
  bool _chapterStopped = false;

  /// A loop has been brought up: the first one fades in over `start`.
  bool _started = false;
  bool _disposed = false;

  AudioBackend get _backend => _host.backend;

  /// Whether the track on screen should be heard now.
  bool get _audible =>
      !_disposed &&
      _enabled &&
      _pauses.isEmpty &&
      !_chapterStopped &&
      _current != null;

  double get _target =>
      MusicMix.target(volume: _volume, duck: MusicMix.duckFactor(_ducks.keys));

  /// The track on screen, as the last [playHome] or [playGame] said.
  @visibleForTesting
  MusicTrack? get currentTrack => _current;

  /// The volume the track on screen fades towards when heard.
  @visibleForTesting
  double get targetVolume => _target;

  /// The loops whose voice is playing now (not paused): both during a
  /// crossfade, otherwise at most the track on screen. The on-device
  /// playthrough reads it, since it can't listen.
  @visibleForTesting
  Set<MusicTrack> get playingTracks {
    final playing = <MusicTrack>{};
    for (final loop in _loops.values) {
      final voice = loop.voice;
      if (voice == null) continue;
      try {
        if (!_backend.isPaused(voice)) playing.add(loop.track);
      } on Object {
        // A voice the engine no longer knows plays nothing.
      }
    }
    return playing;
  }

  /// The loops that failed to load: silent until the next launch.
  @visibleForTesting
  Set<MusicTrack> get failedTracks => {
    for (final loop in _loops.values)
      if (loop.failed) loop.track,
  };

  /// Completes when every loop that started loading has loaded or failed,
  /// including the one a finished load started.
  @visibleForTesting
  Future<void> get loaded async {
    for (
      var pending = _pendingLoads();
      pending.isNotEmpty;
      pending = _pendingLoads()
    ) {
      await Future.wait(pending);
    }
  }

  List<Future<void>> _pendingLoads() => [
    for (final loop in _loops.values)
      if (!loop.settled) ?loop.loading,
  ];

  @override
  void playHome() => _play(MusicTrack.home);

  @override
  void playGame() => _play(MusicTrack.game);

  void _play(MusicTrack track) {
    if (_disposed) return;
    final previous = _current;
    // The same track keeps playing (Continue loads the next level in the
    // page), unless the chapter stopped it.
    if (previous == track && !_chapterStopped) return;
    final afterChapter = _chapterStopped;
    _current = track;
    _chapterStopped = false;
    if (!_audible) return;
    final fade = !_started
        ? MusicMix.start
        : afterChapter && track == MusicTrack.game
        ? MusicMix.chapterIn
        : MusicMix.crossfade;
    if (previous != null && previous != track) {
      _park(_loops[previous]!, MusicMix.crossfade);
    }
    _bringUp(_loops[track]!, fade);
  }

  @override
  void duck(DuckReason reason) {
    if (_disposed) return;
    final before = MusicMix.duckFactor(_ducks.keys);
    _ducks[reason] = (_ducks[reason] ?? 0) + 1;
    _retarget(before, MusicMix.duckIn);
  }

  @override
  void unduck(DuckReason reason) {
    if (_disposed) return;
    final count = _ducks[reason];
    if (count == null) return;
    final before = MusicMix.duckFactor(_ducks.keys);
    if (count > 1) {
      _ducks[reason] = count - 1;
    } else {
      _ducks.remove(reason);
    }
    _retarget(before, MusicMix.duckOut);
  }

  /// Moves the heard loop to the new target, when the ducks changed it.
  void _retarget(double factorBefore, Duration fade) {
    if (MusicMix.duckFactor(_ducks.keys) == factorBefore || !_audible) return;
    final loop = _loops[_current]!;
    final voice = loop.voice;
    // Still loading: the load applies the target when it lands.
    if (!loop.up || voice == null) return;
    _guard(
      'ducking ${loop.track.file}',
      () => _backend.fadeVolume(voice, _target, fade),
    );
  }

  @override
  void stopForChapter() {
    if (_disposed || _chapterStopped) return;
    _chapterStopped = true;
    final current = _current;
    if (current != null) _park(_loops[current]!, MusicMix.chapterOut);
  }

  @override
  void pauseForAd() => _pause(_PauseReason.ad);

  @override
  void resumeAfterAd() => _resume(_PauseReason.ad);

  void _pause(_PauseReason reason) {
    if (_disposed || !_pauses.add(reason) || _pauses.length > 1) return;
    // At once, where they are: a crossfade's outgoing loop too.
    for (final loop in _loops.values) {
      _pauseNow(loop);
    }
  }

  void _resume(_PauseReason reason) {
    if (_disposed || !_pauses.remove(reason) || _pauses.isNotEmpty) return;
    if (_audible) _bringUp(_loops[_current]!, MusicMix.resume);
  }

  @override
  void setEnabled(bool enabled) {
    if (_disposed || enabled == _enabled) return;
    _enabled = enabled;
    if (enabled) {
      if (_audible) _bringUp(_loops[_current]!, MusicMix.toggleOn);
      return;
    }
    // Silent within toggleOff: every loop still playing, the outgoing one
    // of a crossfade too.
    for (final loop in _loops.values) {
      _park(loop, MusicMix.toggleOff);
    }
  }

  @override
  void setVolume(double volume) {
    if (_disposed) return;
    final clamped = volume.clamp(0.0, 1.0);
    if (clamped == _volume) return;
    _volume = clamped;
    if (!_audible) return;
    final loop = _loops[_current]!;
    final voice = loop.voice;
    if (!loop.up || voice == null) return;
    _guard(
      'setting the music volume',
      () => _backend.setVolume(voice, _target),
    );
  }

  /// Fades [loop] up to the target over [fade], loading it first if needed.
  void _bringUp(_Loop loop, Duration fade) {
    loop.up = true;
    _started = true;
    final voice = loop.voice;
    if (voice == null) {
      loop.pendingFade = fade;
      _ensureLoaded(loop);
      return;
    }
    _unpauseAndFade(loop, voice, fade);
  }

  void _unpauseAndFade(_Loop loop, BackendVoice voice, Duration fade) {
    _guard('playing ${loop.track.file}', () {
      final backend = _backend;
      // A parked loop starts from silence (a pause may have caught it mid
      // fade); a loop still fading out turns around where it is.
      if (backend.isPaused(voice)) backend.setVolume(voice, 0);
      backend
        // Also cancels a pending scheduled pause.
        ..setPaused(voice, false)
        ..fadeVolume(voice, _target, fade);
    });
  }

  /// Fades [loop] out over [fade] and pauses it there, if it plays.
  void _park(_Loop loop, Duration fade) {
    loop.up = false;
    final voice = loop.voice;
    if (voice == null) return;
    _guard('parking ${loop.track.file}', () {
      final backend = _backend;
      if (backend.isPaused(voice)) return;
      backend
        ..fadeVolume(voice, 0, fade)
        ..schedulePause(voice, fade);
    });
  }

  /// Pauses [loop] at once, where it is.
  void _pauseNow(_Loop loop) {
    loop.up = false;
    final voice = loop.voice;
    if (voice == null) return;
    _guard('pausing ${loop.track.file}', () {
      final backend = _backend;
      if (!backend.isPaused(voice)) backend.setPaused(voice, true);
    });
  }

  void _ensureLoaded(_Loop loop) {
    if (_disposed || loop.failed || loop.loading != null) return;
    loop.loading = _load(loop);
  }

  Future<void> _load(_Loop loop) async {
    final file = loop.track.file;
    try {
      await _host.start();
      final data = await _bundle.load(MusicMix.assetPath(loop.track));
      if (_disposed) return;
      final sound = await _backend.load(
        file,
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        stream: true,
      );
      if (_disposed) {
        await _unloadQuietly(sound);
        return;
      }
      loop.sound = sound;
      // Waits paused at 0 until it is brought up; the whole file loops.
      final voice = _backend.play(
        sound,
        volume: 0,
        paused: true,
        looping: true,
      );
      if (voice == null) throw StateError('no voice was free for $file');
      _backend.protect(voice);
      loop.voice = voice;
    } on Object catch (error, stack) {
      loop.failed = true;
      _log('$file did not load; the music stays silent', error, stack);
      return;
    } finally {
      loop.settled = true;
    }
    // What was asked while it loaded.
    if (loop.up && _audible && _current == loop.track) {
      _unpauseAndFade(loop, loop.voice!, loop.pendingFade);
    }
    // The other loop, while this screen is idle.
    if (_enabled) {
      for (final other in _loops.values) {
        _ensureLoaded(other);
      }
    }
  }

  void _listenToSetting() {
    try {
      _setting = _database.musicEnabledChanges.listen(
        setEnabled,
        onError: (Object error, StackTrace stack) =>
            _log('the Music setting stream failed', error, stack),
      );
    } on Object catch (error, stack) {
      _log('the Music setting is not followed', error, stack);
    }
  }

  void _listenToLifecycle() {
    try {
      _lifecycle = AppLifecycleListener(onStateChange: didChangeAppLifecycle);
    } on Object catch (error, stack) {
      // No binding (a bare unit test): the music just keeps playing.
      _log('no lifecycle listener', error, stack);
    }
  }

  /// Pauses the music in the background, fades it back in the foreground.
  /// `inactive` (a system sheet over the app) keeps playing, like the SFX.
  @visibleForTesting
  void didChangeAppLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed || AppLifecycleState.inactive:
        _resume(_PauseReason.background);
      case AppLifecycleState.hidden ||
          AppLifecycleState.paused ||
          AppLifecycleState.detached:
        _pause(_PauseReason.background);
    }
  }

  /// Frees the loops (get_it dispose hook); the engine host stops the engine
  /// after. Idempotent.
  @override
  @disposeMethod
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _lifecycle?.dispose();
    _lifecycle = null;
    await _setting?.cancel();
    _setting = null;
    for (final loop in _loops.values) {
      final sound = loop.sound;
      loop
        ..sound = null
        ..voice = null
        ..up = false;
      if (sound != null) await _unloadQuietly(sound);
    }
  }

  Future<void> _unloadQuietly(BackendSound sound) async {
    try {
      await _backend.unload(sound);
    } on Object catch (error, stack) {
      _log('freeing ${sound.name} failed', error, stack);
    }
  }

  static void _guard(String what, void Function() action) {
    try {
      action();
    } on Object catch (error, stack) {
      _log('$what failed', error, stack);
    }
  }

  static void _log(String message, Object error, StackTrace stack) {
    developer.log(
      message,
      name: 'nesty.music',
      error: error,
      stackTrace: stack,
    );
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) debugPrint('[nesty.music] $message: $error');
  }
}

/// One track's loop: its sound and its one voice, once loaded.
final class _Loop {
  _Loop(this.track);

  final MusicTrack track;
  Future<void>? loading;

  /// The load finished, loaded or failed.
  bool settled = false;
  bool failed = false;
  BackendSound? sound;
  BackendVoice? voice;

  /// The last command brought it up (not parked or paused since).
  bool up = false;

  /// The fade the bring-up asked for while it loaded.
  Duration pendingFade = Duration.zero;
}
