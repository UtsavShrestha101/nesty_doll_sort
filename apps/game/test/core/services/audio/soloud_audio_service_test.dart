import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/sfx_engine.dart';
import 'package:nesty_game/core/services/audio/sfx_mix.dart';
import 'package:nesty_game/core/services/audio/soloud_audio_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

typedef _Play = ({String file, double volume, double speed});

final class _FakeEngine implements SfxEngine {
  _FakeEngine({this.failInit = false, this.failLoad = const {}});

  final bool failInit;
  final Set<String> failLoad;
  final List<String> loaded = [];
  final List<_Play> plays = [];
  final List<bool> pauses = [];
  bool disposed = false;

  @override
  Future<void> init() async {
    if (failInit) throw StateError('no audio device');
  }

  @override
  Future<void> load(String name, Uint8List bytes) async {
    if (failLoad.contains(name)) throw StateError('bad file');
    expect(bytes, isNotEmpty);
    loaded.add(name);
  }

  @override
  void play(String name, {required double volume, required double speed}) =>
      plays.add((file: name, volume: volume, speed: speed));

  @override
  void setPaused(bool paused) => pauses.add(paused);

  @override
  Future<void> dispose() async => disposed = true;
}

/// Serves a tiny WAV for every SFX, except the keys in [missing].
final class _AudioBundle extends CachingAssetBundle {
  _AudioBundle({this.missing = const {}});

  final Set<String> missing;

  @override
  Future<ByteData> load(String key) async {
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

  test('preload decodes the 17 SFX once', () async {
    await Future.wait([audio.preload(), audio.preload()]);

    expect(engine.loaded, unorderedEquals(SoundTokens.allFiles));
    expect(audio.loadedFiles, SoundTokens.allFiles.toSet());
  });

  test('the bundled SFX all ship (rootBundle)', () async {
    audio = build(bundle: rootBundle);
    await audio.preload();

    expect(audio.loadedFiles, SoundTokens.allFiles.toSet());
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
      (file: 'clack_3', volume: SoundTokens.sfxVolumeDefault, speed: 1.0),
    ]);
    expect(engine.plays.first.speed, lessThan(1));
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

  test('dispose stops the engine, once, and silences play', () async {
    await audio.preload();
    await audio.dispose();
    await audio.dispose();
    audio.play(SoundEffect.pick);

    expect(engine.disposed, isTrue);
    expect(engine.plays, isEmpty);
  });

  test('the fake records every play for tests', () async {
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
    fake.clear();
    expect(fake.played, isEmpty);
  });
}
