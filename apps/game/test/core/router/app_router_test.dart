import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/ui/theme/app_theme.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_page.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import '../../helpers/test_dependencies.dart';

/// Holds the three fixture levels but, like `BundledLevelRepository`,
/// reports none until the splash has loaded it.
final class _UnloadedLevels extends FakeLevelRepository {
  _UnloadedLevels() : super(entries: FixtureLevels.entries()) {
    levelCount = 0;
  }

  @override
  Future<void> load() async => levelCount = FixtureLevels.entries().length;
}

/// The routes and `ContentReadyGuard` (spec §10.1, §13.4; CLAUDE.md rule
/// 3): Home and Gameplay open only once the offline content is loaded, and
/// no board opens for a level the bundle doesn't have.
void main() {
  setUp(() async {
    await configureTestDependencies();
    // Before the router (and its guard) is first built.
    await get.unregister<LevelRepository>();
    get.registerSingleton<LevelRepository>(_UnloadedLevels());
  });
  tearDown(resetDependencies);

  Future<AppRouter> pumpApp(
    WidgetTester tester, {
    List<PageRouteInfo>? deepLink,
  }) async {
    final router = get<AppRouter>();
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router.config(
          deepLinkBuilder: deepLink == null ? null : (_) => DeepLink(deepLink),
        ),
      ),
    );
    await tester.pump();
    return router;
  }

  /// Pumps without settling: once a board is up, Flame asks for a frame
  /// every tick.
  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    const step = Duration(milliseconds: 50);
    for (var t = Duration.zero; t < duration; t += step) {
      await tester.pump(step);
    }
  }

  testWidgets('the app opens on the splash, which opens Home', (tester) async {
    await pumpApp(tester);
    expect(find.byType(SplashPage), findsOneWidget);
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('Home before the levels have loaded goes through the splash', (
    tester,
  ) async {
    await pumpApp(
      tester,
      deepLink: const [
        MainShellRoute(children: [HomeRoute()]),
      ],
    );
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(SplashPage), findsOneWidget);
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SplashPage), findsNothing);
  });

  testWidgets('a level the bundle does not have never opens a board', (
    tester,
  ) async {
    final router = await pumpApp(tester);
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(HomePage), findsOneWidget);

    for (final missing in [0, 99]) {
      // A push the guard rejects completes at once, with null.
      expect(
        await router.push(
          GameplayRoute(request: PlayRequest.campaign(missing)),
        ),
        isNull,
      );
      await pumpFor(tester, const Duration(milliseconds: 500));
      expect(find.byType(GameplayPage), findsNothing, reason: '$missing');
      expect(find.byType(HomePage), findsOneWidget);
    }

    // An accepted push completes only when its route pops: not awaited.
    unawaited(
      router.push(GameplayRoute(request: const PlayRequest.campaign(2))),
    );
    await pumpFor(tester, const Duration(milliseconds: 800));
    expect(find.byType(GameplayPage), findsOneWidget);
    expect(find.byType(GameWidget<NestyGame>), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
  });
}
