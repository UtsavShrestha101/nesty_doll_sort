import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/router/widget_link.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/ui/theme/app_theme.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_page.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import '../../helpers/test_dependencies.dart';

/// Holds the fixture levels but, like `BundledLevelRepository`, reports none
/// until the splash has loaded it.
final class _UnloadedLevels extends FakeLevelRepository {
  _UnloadedLevels() : super(entries: FixtureLevels.entries()) {
    levelCount = 0;
  }

  @override
  Future<void> load() async => levelCount = FixtureLevels.entries().length;
}

class _RecordingAnalytics implements AnalyticsService {
  final List<String> events = [];

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object> parameters = const {},
  }) async => events.add(name);
}

/// The home-screen widget's tap, `<scheme>://daily` (stage 4 contract §4;
/// plan-local-habits §4): a cold link rides through the splash and opens the
/// Daily if it is unlocked, else Home, a first launch's Level 1 wins, and a
/// warm link opens the Daily; `widget_open` is logged once per tap.
void main() {
  late _RecordingAnalytics analytics;
  late FakeDailyService daily;

  Future<void> setUpWith({required int highestLevel}) async {
    await configureTestDependencies();
    await get.unregister<LevelRepository>();
    get.registerSingleton<LevelRepository>(_UnloadedLevels());
    await get.unregister<SaveService>();
    get.registerSingleton<SaveService>(
      FakeSaveService(initial: SaveDocument(highestLevel: highestLevel)),
    );
    await get.unregister<AnalyticsService>();
    analytics = _RecordingAnalytics();
    get.registerSingleton<AnalyticsService>(analytics);
    await get.unregister<DailyService>();
    daily = FakeDailyService(FakeClock())..unlocked = highestLevel >= 3;
    get.registerSingleton<DailyService>(daily);
  }

  tearDown(resetDependencies);

  Future<AppRouter> pumpApp(WidgetTester tester, {String? link}) async {
    if (link != null) {
      tester.platformDispatcher.defaultRouteNameTestValue = link;
      addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
    }
    final router = get<AppRouter>();
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router.config(deepLinkBuilder: router.deepLinkBuilder),
      ),
    );
    await tester.pump();
    return router;
  }

  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    const step = Duration(milliseconds: 50);
    for (var t = Duration.zero; t < duration; t += step) {
      await tester.pump(step);
    }
  }

  /// The OS handing a link to the running app, as the engine does.
  Future<void> pushLink(WidgetTester tester, String link) async {
    final message = const JSONMethodCodec().encodeMethodCall(
      MethodCall('pushRouteInformation', {'location': link}),
    );
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      message,
      (_) {},
    );
  }

  group('WidgetLink.isDailyLink', () {
    test('knows the widget\'s link in every flavor and the bare path', () {
      for (final scheme in ['nesty', 'nesty-dev', 'nesty-stg']) {
        expect(WidgetLink.isDailyLink(Uri.parse('$scheme://daily')), isTrue);
      }
      expect(WidgetLink.isDailyLink(Uri.parse('/daily')), isTrue);
      expect(WidgetLink.isDailyLink(Uri.parse('/')), isFalse);
      expect(WidgetLink.isDailyLink(Uri.parse('nesty://settings')), isFalse);
      expect(WidgetLink.isDailyLink(Uri.parse('/shop')), isFalse);
    });
  });

  group('a cold link', () {
    testWidgets('unlocked: Splash, then the Daily over Home', (tester) async {
      await setUpWith(highestLevel: 5);
      await pumpApp(tester, link: 'nesty-dev://daily');
      expect(find.byType(SplashPage), findsOneWidget);
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(SplashPage), findsNothing);
      expect(find.byType(DailyPage), findsOneWidget);
      expect(get<WidgetLink>().pending, isFalse);
      expect(analytics.events, ['widget_open']);

      // Home is underneath: back reaches it.
      unawaited(get<AppRouter>().maybePop());
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('locked: Home, not the Daily', (tester) async {
      await setUpWith(highestLevel: 2);
      await pumpApp(tester, link: 'nesty-dev://daily');
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(DailyPage), findsNothing);
      expect(get<WidgetLink>().pending, isFalse);
      expect(analytics.events, ['widget_open']);
    });

    testWidgets('a first launch still opens Level 1', (tester) async {
      await setUpWith(highestLevel: 1);
      await pumpApp(tester, link: 'nesty-dev://daily');
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(GameplayPage), findsOneWidget);
      expect(find.byType(DailyPage), findsNothing);
      expect(get<WidgetLink>().pending, isFalse);
    });

    testWidgets('another link on the scheme starts the app as usual', (
      tester,
    ) async {
      await setUpWith(highestLevel: 5);
      await pumpApp(tester, link: 'nesty-dev://shop');
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(HomePage), findsOneWidget);
      expect(get<WidgetLink>().pending, isFalse);
      expect(analytics.events, isEmpty);
    });

    testWidgets('no link: the splash opens Home as before, and logs nothing', (
      tester,
    ) async {
      await setUpWith(highestLevel: 5);
      await pumpApp(tester);
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(HomePage), findsOneWidget);
      expect(analytics.events, isEmpty);
    });
  });

  group('a warm link', () {
    testWidgets('opens the Daily over Home, once per tap', (tester) async {
      await setUpWith(highestLevel: 5);
      await pumpApp(tester);
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(HomePage), findsOneWidget);

      await pushLink(tester, 'nesty-dev://daily');
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(DailyPage), findsOneWidget);
      expect(analytics.events, ['widget_open']);

      // A second tap while there: logged again (a tap each), and no second
      // Daily, so one Back reaches Home.
      await pushLink(tester, 'nesty-dev://daily');
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(DailyPage), findsOneWidget);
      expect(analytics.events, ['widget_open', 'widget_open']);
      unawaited(get<AppRouter>().maybePop());
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(DailyPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets("today's daily board on top: stays on it", (tester) async {
      await setUpWith(highestLevel: 5);
      final router = await pumpApp(tester);
      await pumpFor(tester, const Duration(seconds: 1));
      unawaited(
        router.push(GameplayRoute(request: const PlayRequest.daily(20261008))),
      );
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(GameplayPage), findsOneWidget);

      await pushLink(tester, 'nesty-dev://daily');
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(DailyPage), findsNothing);
      expect(router.topRoute.name, GameplayRoute.name);
      // The board logs its own `level_start`; the tap still logs once.
      expect(analytics.events.where((e) => e == 'widget_open'), hasLength(1));
    });

    testWidgets('another link on the scheme moves nothing and logs nothing', (
      tester,
    ) async {
      await setUpWith(highestLevel: 5);
      await pumpApp(tester);
      await pumpFor(tester, const Duration(seconds: 1));
      await pushLink(tester, 'nesty-dev://shop');
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(SplashPage), findsNothing);
      expect(analytics.events, isEmpty);
    });

    testWidgets('with the Daily locked, stays where the player is', (
      tester,
    ) async {
      await setUpWith(highestLevel: 2);
      await pumpApp(tester);
      await pumpFor(tester, const Duration(seconds: 1));
      await pushLink(tester, 'nesty-dev://daily');
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(DailyPage), findsNothing);
      expect(analytics.events, ['widget_open']);
    });
  });

  test('an analytics that throws never reaches the player', () async {
    final link = WidgetLink(
      _ThrowingAnalytics(),
      FakeDailyService(FakeClock()),
      FakeLevelRepository(entries: FixtureLevels.entries()),
    );
    expect(
      link.resolve(Uri.parse('nesty://daily'), initial: false),
      WidgetLinkAction.openDaily,
    );
    await Future<void>.delayed(Duration.zero);
  });
}

class _ThrowingAnalytics implements AnalyticsService {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object> parameters = const {},
  }) => throw StateError('offline');
}
