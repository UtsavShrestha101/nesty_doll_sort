import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/audio/sfx_engine.dart';
import 'package:nesty_game/core/services/audio/sfx_mix.dart';
import 'package:nesty_game/core/services/audio/soloud_audio_service.dart';
import 'package:nesty_game/core/services/audio/soloud_engine_host.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

import 'support/fake_audio_backend.dart';

typedef _Play = ({String file, double volume, double speed});

final class _FakeEngine implements SfxEngine {
  _FakeEngine({
    this.failInit = false,
    this.failLoad = const {},
    this.holdJingles,
  });

  final bool failInit;
  final Set<String> failLoad;

  /// Holds each jingle's decode until it completes.
  final Future<void>? holdJingles;
  final List<String> loaded = [];
  final List<_Play> plays = [];
  final List<bool> pauses = [];
  int disposeCalls = 0;

  @override
  Future<void> init() async {
    if (failInit) throw StateError('no audio device');
  }

  @override
  Future<void> load(String name, Uint8List bytes) async {
    if (name.startsWith('jingle_')) await holdJingles;
    if (failLoad.contains(name)) throw StateError('bad file');
    expect(bytes, isNotEmpty);
    loaded.add(name);
  }

  @override
  Duration? lengthOf(String name) =>
      loaded.contains(name) ? Duration(milliseconds: 100 * name.length) : null;

  @override
  void play(String name, {required double volume, required double speed}) =>
      plays.add((file: name, volume: volume, speed: speed));

  @override
  void setPaused(bool paused) => pauses.add(paused);

  @override
  Future<void> dispose() async => disposeCalls++;
}

/// Serves a tiny WAV for every SFX, except the keys in [missing].
final class _AudioBundle extends CachingAssetBundle {
  _AudioBundle({this.missing = const {}});

  final Set<String> missing;
  final Set<String> keys = {};

  @override
  Future<ByteData> load(String key) async {
    keys.add(key);
    if (missing.contains(key)) throw FlutterError('Unable to load asset: $key');
    return ByteData.sublistView(Uint8List.fromList([82, 73, 70, 70]));
  }
}

/// Always picks the last clack variant, so the tests know which one plays.
final class _LastRandom implements Random {
  @override
  int nextInt(int max) => max - 1;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeDatabaseService database;
  late _FakeEngine engine;
  late SoLoudAudioService audio;

  SoLoudAudioService build({_FakeEngine? withEngine, AssetBundle? bundle}) {
    engine = withEngine ?? _FakeEngine();
    return SoLoudAudioService(
      database,
      // Unused: the fake engine stands in for the one on the host.
      SoLoudEngineHost(backend: FakeAudioBackend(), lowLatency: false),
      engine: engine,
      bundle: bundle ?? _AudioBundle(),
      random: _LastRandom(),
    );
  }

  setUp(() {
    database = FakeDatabaseService();
    audio = build();
  });

  tearDown(() async {
    await audio.dispose();
    await database.close();
  });

  final everyFile = {...SoundTokens.allFiles, ...SoundTokens.jingleFiles};

  test('preload decodes the 17 SFX and the 3 jingles once', () async {
    await Future.wait([audio.preload(), audio.preload()]);
    await audio.jinglesLoaded;

    expect(engine.loaded, unorderedEquals(everyFile));
    expect(audio.loadedFiles, everyFile);
  });

  test('preload waits for the SFX only: the jingles decode after them, '
      'without holding up the splash', () async {
    final hold = Completer<void>();
    audio = build(withEngine: _FakeEngine(holdJingles: hold.future));

    await audio.preload();
    expect(audio.loadedFiles, SoundTokens.allFiles.toSet());
    expect(audio.playJingle(Jingle.outOfMoves), isNull, reason: 'not yet');

    hold.complete();
    await audio.jinglesLoaded;
    expect(audio.loadedFiles, everyFile);
    expect(audio.playJingle(Jingle.outOfMoves), isNotNull);
  });

  test(
    'the SFX load from assets/audio/*.wav, the jingles from *.ogg',
    () async {
      final bundle = _AudioBundle();
      audio = build(bundle: bundle);
      await audio.jinglesLoaded;

      expect(bundle.keys, {
        for (final file in SoundTokens.allFiles) 'assets/audio/$file.wav',
        for (final file in SoundTokens.jingleFiles) 'assets/audio/$file.ogg',
      });
    },
  );

  test('the bundled SFX and jingles all ship (rootBundle)', () async {
    audio = build(bundle: rootBundle);
    await audio.jinglesLoaded;

    expect(audio.loadedFiles, everyFile);
  });

  test('plays the clack variant pitched by the merged nest size', () async {
    await audio.preload();

    audio
      ..play(SoundEffect.clack, dollSize: 5)
      ..play(SoundEffect.clack);

    expect(engine.plays, [
      (
        file: 'clack_3',
        volume: SoundTokens.sfxVolumeDefault,
        speed: SfxMix.speedFor(SoundEffect.clack, dollSize: 5),
      ),
      // No size: size 3, one semitone up (the v2 clacks are baked at 3.5).
      (
        file: 'clack_3',
        volume: SoundTokens.sfxVolumeDefault,
        speed: SfxMix.speedFor(SoundEffect.clack),
      ),
    ]);
    expect(engine.plays.first.speed, lessThan(1));
    expect(engine.plays.last.speed, greaterThan(1));
  });

  test('plays complete_{comboStep} at rate 1', () async {
    await audio.preload();

    audio
      ..play(SoundEffect.complete, comboStep: 4)
      ..play(SoundEffect.complete)
      ..play(SoundEffect.whoosh, dollSize: 1);

    expect(engine.plays.map((p) => p.file), [
      'complete_4',
      'complete_1',
      'whoosh',
    ]);
    expect(engine.plays.map((p) => p.speed), everyElement(1.0));
  });

  test('respects the Sound setting on every call', () async {
    await audio.preload();

    await database.setSoundEnabled(false);
    audio.play(SoundEffect.pick);
    expect(engine.plays, isEmpty);

    await database.setSoundEnabled(true);
    audio.play(SoundEffect.pick);
    expect(engine.plays.single.file, 'pick');
  });

  test('is silent before preload', () {
    audio.play(SoundEffect.pick);
    expect(engine.plays, isEmpty);
  });

  test('an engine that fails to start leaves every sound silent', () async {
    audio = build(withEngine: _FakeEngine(failInit: true));

    await expectLater(audio.preload(), completes);
    audio.play(SoundEffect.win);

    expect(engine.loaded, isEmpty);
    expect(engine.plays, isEmpty);
  });

  test(
    'a missing or undecodable file is silent; the rest still play',
    () async {
      audio = build(
        withEngine: _FakeEngine(failLoad: {'bonk'}),
        bundle: _AudioBundle(missing: {SfxMix.assetPath('win')}),
      );
      await audio.preload();

      audio
        ..play(SoundEffect.bonk)
        ..play(SoundEffect.win)
        ..play(SoundEffect.coins);

      expect(audio.loadedFiles, isNot(contains('bonk')));
      expect(audio.loadedFiles, isNot(contains('win')));
      expect(engine.plays.single.file, 'coins');
    },
  );

  test('pauses in the background and drops plays until resumed', () async {
    await audio.preload();

    audio
      ..didChangeAppLifecycle(AppLifecycleState.inactive)
      ..play(SoundEffect.pick)
      ..didChangeAppLifecycle(AppLifecycleState.hidden)
      ..didChangeAppLifecycle(AppLifecycleState.paused)
      ..play(SoundEffect.whoosh)
      ..didChangeAppLifecycle(AppLifecycleState.resumed)
      ..play(SoundEffect.bonk);

    expect(engine.pauses, [true, false]);
    expect(engine.plays.map((p) => p.file), ['pick', 'bonk']);
  });

  test(
    'dispose frees the sounds, once, and silences play and jingles',
    () async {
      await audio.jinglesLoaded;
      await audio.dispose();
      await audio.dispose();
      audio.play(SoundEffect.pick);

      expect(engine.disposeCalls, 1);
      expect(engine.plays, isEmpty);
      expect(audio.playJingle(Jingle.reward), isNull);
    },
  );

  group('jingles', () {
    test(
      'play once on the SFX bus at rate 1, and report their length',
      () async {
        await audio.jinglesLoaded;

        final length = audio.playJingle(Jingle.outOfMoves);

        expect(engine.plays, [
          (
            file: 'jingle_oom',
            volume: SoundTokens.sfxVolumeDefault,
            speed: 1.0,
          ),
        ]);
        expect(length, engine.lengthOf('jingle_oom'));
        expect(
          [Jingle.chapter, Jingle.reward].map(audio.playJingle),
          everyElement(isNotNull),
        );
        expect(engine.plays.map((p) => p.file).skip(1), [
          'jingle_chapter',
          'jingle_reward',
        ]);
      },
    );

    test('follow the Sound setting, not the Music one', () async {
      await audio.jinglesLoaded;

      await database.setMusicEnabled(false);
      expect(audio.playJingle(Jingle.reward), isNotNull);

      await database.setSoundEnabled(false);
      expect(audio.playJingle(Jingle.reward), isNull);
      expect(engine.plays, hasLength(1));
    });

    test('are silent before preload, in the background and when their file '
        'did not load', () async {
      expect(audio.playJingle(Jingle.chapter), isNull);

      audio = build(
        bundle: _AudioBundle(missing: {'assets/audio/jingle_chapter.ogg'}),
      );
      await audio.jinglesLoaded;
      expect(audio.playJingle(Jingle.chapter), isNull);

      audio.didChangeAppLifecycle(AppLifecycleState.hidden);
      expect(audio.playJingle(Jingle.reward), isNull);
      audio.didChangeAppLifecycle(AppLifecycleState.resumed);
      expect(audio.playJingle(Jingle.reward), isNotNull);
      expect(engine.plays.map((p) => p.file), ['jingle_reward']);
    });
  });

  test('the fake records every play and jingle for tests', () async {
    final fake = FakeAudioService();
    await fake.preload();
    fake
      ..play(SoundEffect.clack, dollSize: 4)
      ..play(SoundEffect.complete, comboStep: 2);

    expect(fake.preloaded, isTrue);
    expect(fake.played, [
      (effect: SoundEffect.clack, dollSize: 4, comboStep: null),
      (effect: SoundEffect.complete, dollSize: null, comboStep: 2),
    ]);
    expect(
      fake.playJingle(Jingle.reward),
      FakeAudioService.shippedJingleLengths[Jingle.reward],
    );
    fake.jingleLengths = const {};
    expect(fake.playJingle(Jingle.chapter), isNull);
    expect(fake.jingles, [Jingle.reward, Jingle.chapter]);
    fake.clear();
    expect(fake.played, isEmpty);
    expect(fake.jingles, isEmpty);
  });
}
