import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/soloud_engine_host.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/music/soloud_music_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

import '../audio/support/fake_audio_backend.dart';

/// `SoLoudMusicService` on a fake engine that keeps SoLoud's time (fades
/// and scheduled pauses only advance while a voice plays): AUDIO.md "Music
/// rules" with the tokens' fades and ducks, step A6.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const homeLength = Duration(milliseconds: 66667);
  const gameLength = Duration(milliseconds: 68571);
  const full = SoundTokens.musicVolumeDefault;

  late FakeDatabaseService database;
  late FakeAudioBackend backend;
  late FakeAudioBundle bundle;
  late SoLoudEngineHost host;
  late SoLoudMusicService music;

  SoLoudMusicService build({
    FakeAudioBackend? withBackend,
    FakeAudioBundle? withBundle,
  }) {
    backend =
        withBackend ??
        FakeAudioBackend(
          lengths: {'music_home': homeLength, 'music_game': gameLength},
        );
    bundle = withBundle ?? FakeAudioBundle();
    host = SoLoudEngineHost(backend: backend, lowLatency: false);
    return SoLoudMusicService(database, host, bundle: bundle);
  }

  setUp(() {
    database = FakeDatabaseService();
    music = build();
  });

  tearDown(() async {
    await music.dispose();
    await host.dispose();
    await database.close();
  });

  FakeVoice home() => backend.voiceOf('music_home');
  FakeVoice game() => backend.voiceOf('music_game');
  void play(int ms) => backend.advance(Duration(milliseconds: ms));
  Matcher near(double volume) => closeTo(volume, 0.002);

  /// Home up at full volume, the game loop parked behind it.
  Future<void> homeAtFull() async {
    music.playHome();
    await music.loaded;
    play(SoundTokens.musicFadeStartMs);
    expect(home().volume, near(full));
  }

  /// Home → a level, crossfaded.
  Future<void> gameAtFull() async {
    await homeAtFull();
    music.playGame();
    play(SoundTokens.musicFadeCrossfadeMs);
    expect(game().volume, near(full));
  }

  group('loading', () {
    test('nothing loads until a track is asked for', () async {
      music
        ..duck(DuckReason.pause)
        ..unduck(DuckReason.pause)
        ..setVolume(0.7)
        ..didChangeAppLifecycle(AppLifecycleState.hidden)
        ..didChangeAppLifecycle(AppLifecycleState.resumed);
      await music.loaded;
      expect(backend.calls, isEmpty);
      expect(bundle.loads, isEmpty);
    });

    test('each loop is one protected, looping voice streamed from the '
        'bundled OGG; the second loads once the first has', () async {
      music.playHome();
      await music.loaded;

      expect(bundle.loads, [
        'assets/audio/music_home.ogg',
        'assets/audio/music_game.ogg',
      ]);
      expect(backend.inits, 1);
      expect(backend.lowLatency, isFalse);
      for (final name in SoundTokens.musicFiles) {
        expect(backend.sound(name).stream, isTrue, reason: name);
        final voice = backend.voiceOf(name);
        expect(voice.looping, isTrue, reason: name);
        expect(voice.protected, isTrue, reason: name);
      }
      // The game loop waits, parked at 0.
      expect(game().paused, isTrue);
      expect(game().volume, 0);
    });

    test('calls made while a loop loads apply when it lands', () async {
      music
        ..playHome()
        ..duck(DuckReason.win);
      expect(backend.sounds, isEmpty, reason: 'still loading');
      await music.loaded;
      play(SoundTokens.musicFadeStartMs);
      expect(home().volume, near(full * SoundTokens.musicDuckWin));
    });

    test('a level asked for while Home loads: only the level plays', () async {
      music
        ..playHome()
        ..playGame();
      await music.loaded;
      play(SoundTokens.musicFadeCrossfadeMs);
      expect(game().volume, near(full));
      expect(home().paused, isTrue);
      expect(home().volume, 0);
    });

    test(
      'a loop that cannot load stays silent; the other still plays',
      () async {
        music = build(
          withBundle: FakeAudioBundle(missing: {'assets/audio/music_home.ogg'}),
        );
        music.playHome();
        await expectLater(music.loaded, completes);
        expect(backend.voicesNamed('music_home'), isEmpty);

        music.playGame();
        await music.loaded;
        play(SoundTokens.musicFadeCrossfadeMs);
        expect(game().volume, near(full));
      },
    );

    test('an undecodable loop is silent too', () async {
      music = build(withBackend: FakeAudioBackend(failLoad: {'music_game'}));
      await homeAtFull();
      music.playGame();
      play(SoundTokens.musicFadeCrossfadeMs);
      expect(backend.voicesNamed('music_game'), isEmpty);
      expect(home().paused, isTrue);
    });

    test('an engine that cannot start leaves the music silent', () async {
      music = build(withBackend: FakeAudioBackend(failInit: true));
      music.playHome();
      await expectLater(music.loaded, completes);
      music
        ..duck(DuckReason.win)
        ..playGame();
      await music.loaded;
      expect(backend.sounds, isEmpty);
    });
  });

  group('tracks', () {
    test(
      'Splash ready: music_home starts at 0 and fades in over 1200 ms',
      () async {
        music.playHome();
        await music.loaded;
        expect(home().paused, isFalse);
        expect(home().volume, 0);
        play(SoundTokens.musicFadeStartMs ~/ 2);
        expect(home().volume, near(full / 2));
        play(SoundTokens.musicFadeStartMs ~/ 2);
        expect(home().volume, near(full));
        expect(home().fading, isFalse);
      },
    );

    test('Home ↔ a level crossfades over 800 ms; the outgoing loop pauses at '
        '0 and resumes where it stopped', () async {
      await homeAtFull();
      play(3000);
      music.playGame();
      play(SoundTokens.musicFadeCrossfadeMs ~/ 2);
      expect(home().volume, near(full / 2));
      expect(game().volume, near(full / 2));
      play(SoundTokens.musicFadeCrossfadeMs ~/ 2);
      expect(home().paused, isTrue);
      expect(home().volume, near(0));
      expect(game().volume, near(full));
      final parkedAt = home().position;
      expect(
        parkedAt,
        const Duration(
          milliseconds:
              SoundTokens.musicFadeStartMs +
              3000 +
              SoundTokens.musicFadeCrossfadeMs,
        ),
      );

      play(10000);
      expect(home().position, parkedAt, reason: 'paused, it keeps its place');

      music.playHome();
      expect(home().volume, 0, reason: 'a parked loop starts from silence');
      play(SoundTokens.musicFadeCrossfadeMs);
      expect(home().volume, near(full));
      expect(
        home().position,
        parkedAt +
            const Duration(milliseconds: SoundTokens.musicFadeCrossfadeMs),
      );
      expect(game().paused, isTrue);
    });

    test('playingTracks: both during a crossfade, then only the one on '
        'screen; failedTracks lists a loop that did not load', () async {
      expect(music.playingTracks, isEmpty);
      await homeAtFull();
      expect(music.playingTracks, {MusicTrack.home});
      music.playGame();
      play(SoundTokens.musicFadeCrossfadeMs ~/ 2);
      expect(music.playingTracks, {MusicTrack.home, MusicTrack.game});
      play(SoundTokens.musicFadeCrossfadeMs ~/ 2);
      expect(music.playingTracks, {MusicTrack.game});
      expect(music.failedTracks, isEmpty);

      await music.dispose();
      await host.dispose();
      music = build(withBackend: FakeAudioBackend(failLoad: {'music_game'}));
      await homeAtFull();
      expect(music.failedTracks, {MusicTrack.game});
      expect(music.playingTracks, {MusicTrack.home});
    });

    test('a quick way back turns the fading loop around where it is', () async {
      await homeAtFull();
      music.playGame();
      play(300);
      final turnedAt = home().volume;
      music.playHome();
      expect(home().pauseScheduled, isFalse, reason: 'the park is cancelled');
      expect(home().volume, near(turnedAt), reason: 'no jump to 0');
      play(SoundTokens.musicFadeCrossfadeMs);
      expect(home().paused, isFalse);
      expect(home().volume, near(full));
      expect(game().paused, isTrue);
    });

    test(
      'the same track again is a no-op (Continue stays on the page)',
      () async {
        await gameAtFull();
        final calls = backend.calls.length;
        music
          ..playGame()
          ..playGame();
        expect(backend.calls, hasLength(calls));
      },
    );
  });

  group('ducks', () {
    test('in over 200 ms, out over 800 ms', () async {
      await gameAtFull();
      music.duck(DuckReason.win);
      play(SoundTokens.musicFadeDuckInMs ~/ 2);
      expect(game().volume, near((full + full * 0.3) / 2));
      play(SoundTokens.musicFadeDuckInMs ~/ 2);
      expect(game().volume, near(full * SoundTokens.musicDuckWin));

      music.unduck(DuckReason.win);
      play(SoundTokens.musicFadeDuckOutMs - 1);
      expect(game().volume, lessThan(full));
      play(1);
      expect(game().volume, near(full));
    });

    test("they don't stack: the lowest factor wins", () async {
      await gameAtFull();
      music.duck(DuckReason.pause);
      play(SoundTokens.musicFadeDuckInMs);
      expect(game().volume, near(full * 0.5));

      music.duck(DuckReason.outOfMoves);
      play(SoundTokens.musicFadeDuckInMs);
      expect(game().volume, near(full * 0.4), reason: 'not 0.5 × 0.4');

      final calls = backend.calls.length;
      music.duck(DuckReason.reward);
      expect(backend.calls, hasLength(calls), reason: '0.4 already holds');

      music
        ..unduck(DuckReason.outOfMoves)
        ..unduck(DuckReason.reward);
      play(SoundTokens.musicFadeDuckOutMs);
      expect(game().volume, near(full * 0.5));

      music.unduck(DuckReason.pause);
      play(SoundTokens.musicFadeDuckOutMs);
      expect(game().volume, near(full));
    });

    test(
      'each duck needs its own unduck; a stray unduck does nothing',
      () async {
        await gameAtFull();
        music
          ..unduck(DuckReason.win)
          ..duck(DuckReason.win)
          ..duck(DuckReason.win)
          ..unduck(DuckReason.win);
        play(SoundTokens.musicFadeDuckOutMs);
        expect(game().volume, near(full * 0.3));
        music.unduck(DuckReason.win);
        play(SoundTokens.musicFadeDuckOutMs);
        expect(game().volume, near(full));
      },
    );

    test('the volume scales the ducked target', () async {
      await gameAtFull();
      music.setVolume(0.8);
      expect(game().volume, near(0.8));
      music.duck(DuckReason.pause);
      play(SoundTokens.musicFadeDuckInMs);
      expect(game().volume, near(0.4));
      music.setVolume(2);
      expect(game().volume, near(0.5), reason: 'clamped to 1');
    });
  });

  group('the Music setting', () {
    test('off is silent within 300 ms and stays silent across routes, ads '
        'and the lifecycle; on fades in over 600 ms', () async {
      await gameAtFull();
      await database.setMusicEnabled(false);
      await pumpEventQueue();
      play(SoundTokens.musicFadeToggleOffMs);
      expect(game().paused, isTrue);
      expect(game().volume, near(0));

      final calls = backend.calls.length;
      music
        ..playHome()
        ..duck(DuckReason.win)
        ..unduck(DuckReason.win)
        ..pauseForAd()
        ..resumeAfterAd()
        ..didChangeAppLifecycle(AppLifecycleState.hidden)
        ..didChangeAppLifecycle(AppLifecycleState.resumed);
      play(2000);
      expect(home().paused, isTrue);
      expect(game().paused, isTrue);
      expect(backend.calls.skip(calls), isEmpty);

      await database.setMusicEnabled(true);
      await pumpEventQueue();
      expect(home().volume, 0);
      play(SoundTokens.musicFadeToggleOnMs ~/ 2);
      expect(home().volume, near(full / 2));
      play(SoundTokens.musicFadeToggleOnMs ~/ 2);
      expect(home().volume, near(full));
      expect(game().paused, isTrue);
    });

    test(
      'off mid-crossfade silences the outgoing loop within 300 ms too',
      () async {
        await homeAtFull();
        music.playGame();
        play(100);
        music.setEnabled(false);
        play(SoundTokens.musicFadeToggleOffMs);
        expect(home().paused, isTrue);
        expect(game().paused, isTrue);
        expect(home().volume, near(0));
        expect(game().volume, near(0));
      },
    );

    test(
      'off at launch: nothing loads and the engine is never touched',
      () async {
        await database.setMusicEnabled(false);
        await music.dispose();
        await host.dispose();
        music = build();

        music
          ..playHome()
          ..duck(DuckReason.pause)
          ..pauseForAd()
          ..resumeAfterAd()
          ..didChangeAppLifecycle(AppLifecycleState.hidden)
          ..didChangeAppLifecycle(AppLifecycleState.resumed)
          ..unduck(DuckReason.pause)
          ..playGame()
          ..stopForChapter()
          ..playGame();
        await music.loaded;
        expect(backend.calls, isEmpty);
        expect(bundle.loads, isEmpty);

        // Turned on at a level: that loop loads and fades in.
        await database.setMusicEnabled(true);
        await pumpEventQueue();
        await music.loaded;
        play(SoundTokens.musicFadeToggleOnMs);
        expect(game().volume, near(full));
        expect(home().paused, isTrue);
      },
    );
  });

  group('pauses', () {
    test('the background pauses both loops at once, where they are; back, '
        'the music fades in over 600 ms', () async {
      await homeAtFull();
      music.playGame();
      play(200);
      final homeVolume = home().volume;
      final gamePosition = game().position;

      music.didChangeAppLifecycle(AppLifecycleState.inactive);
      expect(game().paused, isFalse, reason: 'a system sheet keeps it');
      music
        ..didChangeAppLifecycle(AppLifecycleState.hidden)
        ..didChangeAppLifecycle(AppLifecycleState.paused);
      expect(home().paused, isTrue);
      expect(game().paused, isTrue);
      play(5000);
      expect(home().volume, homeVolume, reason: 'at once, not faded');
      expect(game().position, gamePosition);

      music
        ..didChangeAppLifecycle(AppLifecycleState.hidden)
        ..didChangeAppLifecycle(AppLifecycleState.inactive);
      expect(game().paused, isFalse);
      expect(game().volume, 0);
      play(SoundTokens.musicFadeResumeMs);
      expect(game().volume, near(full));
      expect(home().paused, isTrue, reason: 'the outgoing loop stays parked');
      music.didChangeAppLifecycle(AppLifecycleState.resumed);
      expect(game().volume, near(full));
    });

    test(
      'an ad pauses; the ad and the background are separate reasons',
      () async {
        await gameAtFull();
        music.pauseForAd();
        expect(game().paused, isTrue);
        // Android: the ad's activity sends the app to the background.
        music
          ..didChangeAppLifecycle(AppLifecycleState.hidden)
          ..didChangeAppLifecycle(AppLifecycleState.resumed);
        expect(game().paused, isTrue, reason: 'the ad still shows');
        music.resumeAfterAd();
        expect(game().paused, isFalse);
        play(SoundTokens.musicFadeResumeMs);
        expect(game().volume, near(full));

        music
          ..didChangeAppLifecycle(AppLifecycleState.hidden)
          ..pauseForAd()
          ..resumeAfterAd();
        expect(game().paused, isTrue, reason: 'still in the background');
        music.didChangeAppLifecycle(AppLifecycleState.resumed);
        play(SoundTokens.musicFadeResumeMs);
        expect(game().volume, near(full));
      },
    );

    test('the ducks hold across a pause', () async {
      await gameAtFull();
      music
        ..didChangeAppLifecycle(AppLifecycleState.hidden)
        // The gameplay page opens Pause as the app hides.
        ..duck(DuckReason.pause)
        ..didChangeAppLifecycle(AppLifecycleState.resumed);
      play(SoundTokens.musicFadeResumeMs);
      expect(game().volume, near(full * SoundTokens.musicDuckPause));
    });
  });

  group('chapter complete', () {
    test('out over 400 ms and paused; the next level fades music_game in '
        'over 2000 ms', () async {
      await gameAtFull();
      music
        ..duck(DuckReason.win)
        ..stopForChapter();
      play(SoundTokens.musicFadeChapterOutMs);
      expect(game().paused, isTrue);
      expect(game().volume, near(0));
      music.unduck(DuckReason.win);
      play(1000);
      expect(game().paused, isTrue);

      music.playGame();
      play(SoundTokens.musicFadeChapterInMs ~/ 2);
      expect(game().volume, near(full / 2));
      play(SoundTokens.musicFadeChapterInMs ~/ 2);
      expect(game().volume, near(full));
    });

    test('Home after chapter complete crossfades in as usual', () async {
      await gameAtFull();
      music.stopForChapter();
      play(SoundTokens.musicFadeChapterOutMs);
      music.playHome();
      play(SoundTokens.musicFadeCrossfadeMs);
      expect(home().volume, near(full));
      expect(game().paused, isTrue);
    });
  });

  test('dispose frees the loops and leaves the engine to the host', () async {
    await gameAtFull();
    await music.dispose();
    await music.dispose();
    expect(backend.sounds, isEmpty);
    expect(backend.deinits, 0);

    final calls = backend.calls.length;
    music
      ..playHome()
      ..duck(DuckReason.win)
      ..setEnabled(false);
    await database.setMusicEnabled(true);
    await pumpEventQueue();
    expect(backend.calls, hasLength(calls));

    await host.dispose();
    expect(backend.deinits, 1);
  });
}
