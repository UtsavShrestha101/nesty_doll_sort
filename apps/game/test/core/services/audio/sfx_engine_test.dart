import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/services/audio/sfx_engine.dart';
import 'package:nesty_game/core/services/audio/soloud_engine_host.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/music/soloud_music_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

import '../../../helpers/test_dependencies.dart';
import 'support/fake_audio_backend.dart';

/// The SFX engine and the music share one engine (`SoLoudEngineHost`): each
/// touches only its own sounds, and only the host starts and stops it
/// (audio-analysis plan §3 "Engine sharing").
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => FlavorConfig(flavor: Flavor.dev, values: testFlavorValues));

  final bytes = Uint8List.fromList([82, 73, 70, 70]);

  late FakeDatabaseService database;
  late FakeAudioBackend backend;
  late SoLoudEngineHost host;
  late SoLoudSfxEngine sfx;
  late SoLoudMusicService music;

  setUp(() {
    database = FakeDatabaseService();
    backend = FakeAudioBackend(lengths: {'win': const Duration(seconds: 2)});
    host = SoLoudEngineHost(backend: backend);
    sfx = SoLoudSfxEngine(host);
    music = SoLoudMusicService(database, host, bundle: FakeAudioBundle());
  });

  tearDown(() async {
    await music.dispose();
    await sfx.dispose();
    await host.dispose();
    await database.close();
  });

  /// The SFX loaded and playing over music_home at full volume.
  Future<void> sfxOverMusic() async {
    await sfx.init();
    await sfx.load('win', bytes);
    await sfx.load('pick', bytes);
    music.playHome();
    await music.loaded;
    backend.advance(const Duration(milliseconds: SoundTokens.musicFadeStartMs));
    sfx
      ..play('win', volume: 0.8, speed: 1)
      ..play('pick', volume: 0.8, speed: 1);
  }

  test('low latency in prod only (audio plan Q41)', () {
    expect(Flavor.dev.audioLowLatency, isFalse);
    expect(Flavor.stg.audioLowLatency, isFalse);
    expect(Flavor.prod.audioLowLatency, isTrue);
  });

  test('the engine starts once, for whoever asks first, with the flavor\'s '
      'profile', () async {
    await Future.wait([sfx.init(), host.start(), sfx.init()]);
    music.playHome();
    await music.loaded;
    expect(backend.inits, 1);
    // The tests run as the dev flavor.
    expect(backend.lowLatency, isFalse);
  });

  test('pausing the SFX leaves the music playing', () async {
    await sfxOverMusic();
    final home = backend.voiceOf('music_home');

    sfx.setPaused(true);
    expect(backend.voiceOf('win').paused, isTrue);
    expect(backend.voiceOf('pick').paused, isTrue);
    expect(home.paused, isFalse);
    expect(home.volume, closeTo(SoundTokens.musicVolumeDefault, 1e-9));

    sfx.setPaused(false);
    expect(backend.voiceOf('win').paused, isFalse);
    expect(home.paused, isFalse);
  });

  test('disposing the SFX frees only its sounds; the host stops the engine '
      'last', () async {
    await sfxOverMusic();

    await sfx.dispose();
    expect(
      backend.sounds.map((s) => s.name),
      unorderedEquals(SoundTokens.musicFiles),
    );
    expect(backend.voiceOf('music_home').paused, isFalse);
    expect(backend.deinits, 0);

    await music.dispose();
    expect(backend.sounds, isEmpty);
    expect(backend.deinits, 0);

    await host.dispose();
    await host.dispose();
    expect(backend.deinits, 1);
  });

  test('the SFX decode into memory; the loops stream', () async {
    await sfxOverMusic();
    expect(backend.sound('win').stream, isFalse);
    expect(backend.sound('pick').stream, isFalse);
    expect(backend.sound('music_home').stream, isTrue);
  });

  test('a pitched clack starts paused, so its rate applies from the first '
      'sample', () async {
    await sfx.init();
    await sfx.load('clack_1', bytes);
    sfx.play('clack_1', volume: 0.8, speed: 1.25);
    final id = backend.voiceOf('clack_1').id;
    expect(backend.calls.skip(2), [
      'play(clack_1, volume: 0.8, paused: true, looping: false)',
      'setSpeed($id, 1.25)',
      'setPaused($id, false)',
    ]);
    expect(backend.voiceOf('clack_1').speed, 1.25);
  });

  test('a sound that is not loaded is ignored; lengths are known once '
      'loaded', () async {
    await sfx.init();
    expect(sfx.lengthOf('win'), isNull);
    sfx.play('win', volume: 1, speed: 1);
    expect(backend.voicesNamed('win'), isEmpty);
    await sfx.load('win', bytes);
    expect(sfx.lengthOf('win'), const Duration(seconds: 2));
  });

  test('a load before the engine started is refused', () async {
    await expectLater(sfx.load('pick', bytes), throwsStateError);
  });

  test('an engine that cannot start fails every start, and is never '
      'stopped', () async {
    backend = FakeAudioBackend(failInit: true);
    host = SoLoudEngineHost(backend: backend);
    sfx = SoLoudSfxEngine(host);
    await expectLater(sfx.init(), throwsStateError);
    await expectLater(host.start(), throwsStateError);
    expect(backend.inits, 1);
    await host.dispose();
    expect(backend.deinits, 0);
  });

  test('a host that never started stops nothing, and cannot start after '
      'dispose', () async {
    await host.dispose();
    expect(backend.calls, isEmpty);
    await expectLater(host.start(), throwsStateError);
  });
}
