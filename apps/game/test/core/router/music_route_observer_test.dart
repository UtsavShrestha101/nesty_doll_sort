import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/app.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/router/music_route_observer.dart';
import 'package:nesty_game/core/services/audio/soloud_engine_host.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/music/soloud_music_service.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_page.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';

import '../../helpers/test_dependencies.dart';
import '../services/audio/support/fake_audio_backend.dart';
import '../ui/support/ui_harness.dart';

/// A page route named like auto_route names its pages.
Route<void> _page(String name) => MaterialPageRoute<void>(
  settings: RouteSettings(name: name),
  builder: (_) => const SizedBox(),
);

/// A dialog: not a page, so never a track.
Route<void> _dialog() =>
    RawDialogRoute<void>(pageBuilder: (_, _, _) => const SizedBox());

/// The route observer picks the loop of the page on top (AUDIO.md "Music
/// loops", step A5).
void main() {
  // The music service listens to the app's lifecycle.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the page on top', () {
    late FakeMusicService music;
    late MusicRouteObserver observer;

    setUp(() {
      music = FakeMusicService();
      observer = MusicRouteObserver(music);
    });

    test('maps to its loop: none under the splash, music_game under a '
        'level, music_home under everything else', () {
      expect(MusicRouteObserver.trackFor(SplashRoute.name), isNull);
      expect(MusicRouteObserver.trackFor(HomeRoute.name), MusicTrack.home);
      expect(MusicRouteObserver.trackFor(GameplayRoute.name), MusicTrack.game);
      expect(MusicRouteObserver.trackFor(null), MusicTrack.home);
      // M3's screens (AUDIO.md: Daily, Museum, Shop, Skin detail and
      // Settings play music_home; every board, daily and bonus included, is
      // a GameplayRoute and plays music_game).
      for (final name in [
        MainShellRoute.name,
        SettingsRoute.name,
        DailyRoute.name,
        SkinDetailRoute.name,
        ShopRoute.name,
        MuseumRoute.name,
      ]) {
        expect(
          MusicRouteObserver.trackFor(name),
          MusicTrack.home,
          reason: name,
        );
      }
    });

    test('Splash → Home → a level → Home', () {
      final splash = _page(SplashRoute.name);
      final home = _page(HomeRoute.name);
      final level = _page(GameplayRoute.name);

      observer.didPush(splash, null);
      expect(music.calls, isEmpty);

      // replaceAll([HomeRoute()]): Home is added, then the splash removed.
      observer
        ..didPush(home, splash)
        ..didRemove(splash, null);
      expect(music.calls, [const MusicCall.playHome()]);

      observer.didPush(level, home);
      expect(music.calls.last, const MusicCall.playGame());

      observer.didPop(level, home);
      expect(music.calls, [
        const MusicCall.playHome(),
        const MusicCall.playGame(),
        const MusicCall.playHome(),
      ]);
    });

    test('dialogs and sheets never change the track', () {
      final home = _page(HomeRoute.name);
      final sheet = _dialog();
      observer
        ..didPush(home, null)
        ..didPush(sheet, home)
        ..didPop(sheet, home);
      expect(music.calls, [const MusicCall.playHome()]);
    });

    test('pages added together (reported top first) end with the top one', () {
      final home = _page(HomeRoute.name);
      final level = _page(GameplayRoute.name);
      observer
        ..didPush(level, home)
        ..didPush(home, null);
      expect(music.calls, [const MusicCall.playGame()]);
      observer.didPop(level, home);
      expect(music.calls.last, const MusicCall.playHome());
    });

    test('a replaced page plays its own loop', () {
      final home = _page(HomeRoute.name);
      final level = _page(GameplayRoute.name);
      observer
        ..didPush(home, null)
        ..didReplace(newRoute: level, oldRoute: home);
      expect(music.calls.last, const MusicCall.playGame());
      observer.didRemove(level, null);
      expect(music.calls, hasLength(2), reason: 'no page: nothing to say');
    });
  });

  group('over the real music service', () {
    late FakeDatabaseService database;
    late FakeAudioBackend backend;
    late FakeAudioBundle bundle;
    late SoLoudEngineHost host;
    late SoLoudMusicService music;
    late MusicRouteObserver observer;

    setUp(() {
      database = FakeDatabaseService();
      backend = FakeAudioBackend();
      bundle = FakeAudioBundle();
      host = SoLoudEngineHost(backend: backend, lowLatency: false);
    });

    tearDown(() async {
      await music.dispose();
      await host.dispose();
      await database.close();
    });

    test('with Music off, Splash → Home → a level (paused) → Home never '
        'loads a loop or touches the engine; turned on at Home, only then '
        'does music_home load and play', () async {
      await database.setMusicEnabled(false);
      music = SoLoudMusicService(database, host, bundle: bundle);
      observer = MusicRouteObserver(music);
      final splash = _page(SplashRoute.name);
      final home = _page(HomeRoute.name);
      final level = _page(GameplayRoute.name);

      observer
        ..didPush(splash, null)
        ..didPush(home, splash)
        ..didRemove(splash, null)
        ..didPush(level, home);
      music
        ..duck(DuckReason.pause)
        ..unduck(DuckReason.pause);
      observer.didPop(level, home);
      await music.loaded;
      expect(backend.calls, isEmpty);
      expect(bundle.loads, isEmpty);

      await database.setMusicEnabled(true);
      await pumpEventQueue();
      await music.loaded;
      expect(bundle.loads.first, 'assets/audio/music_home.ogg');
      expect(backend.voiceOf('music_home').paused, isFalse);
      expect(music.currentTrack, MusicTrack.home);
    });
  });

  group('in the app (fake DI)', () {
    setUpAll(loadBundledFonts);
    setUp(configureTestDependencies);
    tearDown(resetDependencies);

    Future<void> pumpFor(WidgetTester tester, Duration duration) async {
      const step = Duration(milliseconds: 50);
      for (var t = Duration.zero; t < duration; t += step) {
        await tester.pump(step);
      }
    }

    testWidgets('home music after the splash, game music in a level, Pause '
        'ducks it, and Home brings home music back', (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final music = get<MusicService>() as FakeMusicService;

      await tester.pumpWidget(App(router: get<AppRouter>()));
      await tester.pump();
      expect(music.calls, isEmpty, reason: 'the splash is silent');

      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(HomePage), findsOneWidget);
      expect(music.calls, [const MusicCall.playHome()]);

      await tester.tap(find.bySemanticsLabel('Play level 1'));
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(GameplayPage), findsOneWidget);
      expect(music.calls.last, const MusicCall.playGame());

      await tester.tap(find.bySemanticsLabel('Pause'));
      await pumpFor(tester, const Duration(milliseconds: 400));
      expect(music.ducking, {DuckReason.pause});

      await tester.tap(
        find.descendant(
          of: find.byType(PauseDialog),
          matching: find.text('Home'),
        ),
      );
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(HomePage), findsOneWidget);
      expect(music.track, MusicTrack.home);
      expect(music.ducking, isEmpty, reason: 'the dialog went with the level');
      expect(music.calls, [
        const MusicCall.playHome(),
        const MusicCall.playGame(),
        const MusicCall.duck(DuckReason.pause),
        const MusicCall.playHome(),
        const MusicCall.unduck(DuckReason.pause),
      ]);
      expect(tester.takeException(), isNull);
    });
  });
}
