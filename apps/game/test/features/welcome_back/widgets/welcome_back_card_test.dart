import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/welcome_back/welcome_back_tracker.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';
import 'package:nesty_game/features/welcome_back/cubit/welcome_back_cubit.dart';
import 'package:nesty_game/features/welcome_back/welcome_back_navigation.dart';
import 'package:nesty_game/features/welcome_back/widgets/welcome_back_card.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

class _MockAnalytics extends Mock implements AnalyticsService {}

/// The respect rules' banned words and any countdown (D92).
final _banned = RegExp(
  r'expire|last chance|missed|lost|broken|hurry|today only|countdown|'
  r'\d+\s?h\s\d+\s?m|\bleft\b',
  caseSensitive: false,
);

/// A stand-in router: the routes the card's Play pushes, named as the
/// app's, with empty pages.
class _TestRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: const PageInfo('HomeRoute', builder: _homePage),
      initial: true,
    ),
    AutoRoute(page: const PageInfo('DailyRoute', builder: _page)),
    AutoRoute(page: const PageInfo('GameplayRoute', builder: _page)),
  ];
}

Widget _page(RouteData<dynamic> data) => const SizedBox();

/// Home's stand-in: one button that runs the real Play navigation.
Widget _homePage(RouteData<dynamic> data) => Builder(
  builder: (context) => TextButton(
    key: const Key('play'),
    onPressed: () => playWelcomeBack(context),
    child: const Text('go'),
  ),
);

void main() {
  setUpAll(loadBundledFonts);

  Future<void> pumpCard(
    WidgetTester tester, {
    WelcomeBackVariant variant = WelcomeBackVariant.paused,
    int streak = 6,
    VoidCallback? onPlay,
    VoidCallback? onClose,
    bool reduceMotion = false,
    double width = 358,
    double textScale = 1,
  }) => pumpScreen(
    tester,
    Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: width,
          child: WelcomeBackCard(
            variant: variant,
            streak: streak,
            onPlay: onPlay ?? () {},
            onClose: onClose ?? () {},
          ),
        ),
      ),
    ),
    reduceMotion: reduceMotion,
    textScale: textScale,
  );

  Finder face() => find
      .descendant(
        of: find.byType(WelcomeBackCard),
        matching: find.byType(TactileSurface),
      )
      .first;

  Finder close() => find.bySemanticsLabel('Hide this card');

  testWidgets('parts: headline, the paused line with its number, Play and '
      'Close', (tester) async {
    await pumpCard(tester);
    await tester.pumpAndSettle();
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(
      find.text('Your 6-day streak is resting. Today’s puzzle is ready.'),
      findsOneWidget,
    );
    expect(find.text('Play'), findsOneWidget);
    expect(close(), findsOneWidget);
  });

  testWidgets('each variant has its own line (copy.md), plain the new one', (
    tester,
  ) async {
    const lines = {
      WelcomeBackVariant.newStreak: 'Today’s puzzle is ready when you are.',
      WelcomeBackVariant.freezeKept:
          'A freeze kept your flame lit. Today’s puzzle is ready.',
      WelcomeBackVariant.plain: 'Today’s puzzle is ready when you are.',
    };
    for (final entry in lines.entries) {
      await pumpCard(tester, variant: entry.key, streak: 4);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget, reason: '${entry.key}');
    }
  });

  testWidgets('each variant draws its disc: the freeze badge only for a '
      'freeze', (tester) async {
    for (final variant in WelcomeBackVariant.values) {
      await pumpCard(tester, variant: variant);
      await tester.pumpAndSettle();
      expect(
        find.byIcon(NestyIcons.acUnit),
        variant == WelcomeBackVariant.freezeKept
            ? findsOneWidget
            : findsNothing,
        reason: '$variant',
      );
      expect(
        find.byIcon(NestyIcons.extension),
        variant == WelcomeBackVariant.newStreak ||
                variant == WelcomeBackVariant.plain
            ? findsOneWidget
            : findsNothing,
      );
    }
  });

  testWidgets('the whole card is the Play button, with its own label', (
    tester,
  ) async {
    var played = 0;
    var closed = 0;
    await pumpCard(tester, onPlay: () => played++, onClose: () => closed++);
    await tester.pumpAndSettle();
    final handle = tester.ensureSemantics();
    expect(
      find.bySemanticsLabel(
        RegExp(
          r'Welcome back!.*Today’s puzzle is ready\..*Play today’s puzzle',
        ),
      ),
      findsOneWidget,
    );
    handle.dispose();
    // A tap on the headline plays: the card, not a small pill, is the button.
    await tester.tap(find.text('Welcome back!'));
    expect(played, 1);
    // Play's pill is a look: the card takes the tap (its lower half is clear
    // of the close's target).
    await tester.tapAt(tester.getRect(find.text('Play')).bottomCenter);
    expect(played, 2);
    expect(closed, 0);
  });

  testWidgets('the close: a 28 dp disc in a 48 dp target, fading the card '
      'out before it reports', (tester) async {
    var played = 0;
    var closed = 0;
    await pumpCard(tester, onPlay: () => played++, onClose: () => closed++);
    await tester.pumpAndSettle();
    final target = tester.getSize(
      find.ancestor(
        of: find.byIcon(NestyIcons.close),
        matching: find.byType(TactileSurface),
      ),
    );
    expect(target.width, greaterThanOrEqualTo(48));
    expect(target.height, greaterThanOrEqualTo(48));
    final disc = tester.getSize(find.byIcon(NestyIcons.close));
    expect(disc.width, HabitsWelcomeTokens.dismissGlyphSize);
    // Its target is inside the widget's box (a hit test never leaves it).
    final box = tester.getRect(find.byType(WelcomeBackCard));
    final targetRect = tester.getRect(
      find.ancestor(
        of: find.byIcon(NestyIcons.close),
        matching: find.byType(TactileSurface),
      ),
    );
    expect(box.contains(targetRect.topRight - const Offset(1, -1)), isTrue);
    await tester.tapAt(targetRect.topRight - const Offset(2, -2));
    await tester.pump(const Duration(milliseconds: 90));
    expect(closed, 0);
    await tester.pumpAndSettle();
    expect(closed, 1);
    expect(played, 0);
  });

  testWidgets('the card is at least 84 dp tall and 16 dp from each edge '
      'of its width', (tester) async {
    await pumpCard(tester, variant: WelcomeBackVariant.freezeKept);
    await tester.pumpAndSettle();
    expect(
      tester.getSize(face()).height,
      greaterThanOrEqualTo(HabitsWelcomeTokens.cardMinHeight),
    );
  });

  testWidgets('a two-line line sits beside Play; past two lines it takes '
      'its short form and Play moves under it', (tester) async {
    await pumpCard(tester, variant: WelcomeBackVariant.freezeKept);
    await tester.pumpAndSettle();
    final side = tester.getRect(find.text('Play'));
    final text = tester.getRect(find.textContaining('A freeze kept'));
    expect(side.left, greaterThan(text.right - 1));

    // 360 dp phone at 1.3x text: Play under the text, right-aligned.
    await pumpCard(
      tester,
      variant: WelcomeBackVariant.paused,
      width: 328,
      textScale: 1.3,
    );
    await tester.pumpAndSettle();
    expectNoLayoutErrors(tester);
    final under = tester.getRect(find.text('Play'));
    final body = tester.getRect(find.textContaining('Your 6-day'));
    expect(under.top, greaterThanOrEqualTo(body.bottom));
    final card = tester.getRect(face());
    expect(card.right - under.right, lessThan(40));
    expect(find.text('Your 6-day streak is resting.'), findsOneWidget);
  });

  testWidgets('stays inside its box at 360 dp, 1.3x text, in every variant', (
    tester,
  ) async {
    for (final variant in WelcomeBackVariant.values) {
      await pumpCard(tester, variant: variant, width: 328, textScale: 1.3);
      await tester.pumpAndSettle();
      expectNoLayoutErrors(tester);
    }
  });

  double rise(WidgetTester tester) {
    final transform = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(WelcomeBackCard),
            matching: find.byType(Transform),
          )
          .first,
    );
    return transform.transform.getTranslation().y;
  }

  testWidgets('the entrance fades and rises', (tester) async {
    await pumpCard(tester);
    await tester.pump(const Duration(milliseconds: 40));
    expect(rise(tester), greaterThan(0));
    await tester.pumpAndSettle();
    expect(rise(tester), 0);
  });

  testWidgets('reduce motion: a fade only, no rise', (tester) async {
    await pumpCard(tester, reduceMotion: true);
    await tester.pump(const Duration(milliseconds: 40));
    expect(rise(tester), 0);
    await tester.pumpAndSettle();
  });

  testWidgets('reduce motion: the close fades only, no shrink', (tester) async {
    await pumpCard(tester, reduceMotion: true);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Hide this card'));
    await tester.pump(const Duration(milliseconds: 60));
    final scale = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(WelcomeBackCard),
            matching: find.byType(Transform),
          )
          .last,
    );
    expect(scale.transform.getMaxScaleOnAxis(), 1);
    await tester.pumpAndSettle();
  });

  testWidgets('no countdown or loss word in any variant', (tester) async {
    for (final variant in WelcomeBackVariant.values) {
      await pumpCard(tester, variant: variant);
      await tester.pumpAndSettle();
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
          .join(' | ');
      expect(texts, isNotEmpty);
      expect(_banned.hasMatch(texts), isFalse, reason: '$variant: $texts');
    }
  });

  testWidgets('Play leaves Home, Daily, Gameplay on the stack, and logs', (
    tester,
  ) async {
    final clock = FakeClock();
    final settings = FakeDatabaseService();
    final tracker = WelcomeBackTracker(
      settings,
      clock,
      FakeRemoteConfigService(),
    );
    final analytics = _MockAnalytics();
    when(
      () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async {});
    final daily = FakeDailyService(clock);
    final cubit = WelcomeBackCubit(tracker, daily, analytics);
    final router = _TestRouter();
    addTearDown(() async {
      await cubit.close();
      await tracker.dispose();
    });

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp.router(routerConfig: router.config()),
      ),
    );
    await tester.pumpAndSettle();
    expect(router.stack.map((r) => r.name), ['HomeRoute']);

    await tester.tap(find.byKey(const Key('play')));
    await tester.pumpAndSettle();
    expect(router.stack.map((r) => r.name), [
      'HomeRoute',
      'DailyRoute',
      'GameplayRoute',
    ]);
    final top = router.stack.last.routeData.args as GameplayRouteArgs;
    expect(top.request, daily.todayRequest);
    verify(() => analytics.logEvent('welcome_back_play')).called(1);
    expect(daily.todayRequest, isA<DailyPlay>());
  });
}
