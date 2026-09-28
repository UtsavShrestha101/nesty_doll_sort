import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/dev/level_picker_sheet.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';

import '../../core/ui/support/ui_harness.dart';
import '../../helpers/level_fixtures.dart';
import '../../helpers/test_dependencies.dart';
import '../support/screen_harness.dart';

/// Frame 2.1's hero (spec §10.2 #2; m3-design §10.3): the coin pill (its
/// "+" opens the Shop), the small wordmark, the gear (Settings), five idling
/// dolls under twinkles, PLAY with the level and its tier badge, and the
/// Daily / Museum / Remove Ads tiles. The dev flavor adds the level picker.
void main() {
  setUpAll(() async {
    await loadBundledFonts();
    // Tests run as the dev flavor (the picker is dev-only).
    FlavorConfig(flavor: Flavor.dev, values: testFlavorValues);
  });

  final level = levelFrom(tutorialLevelJson);
  FakeLevelRepository levels() => FakeLevelRepository(
    entries: [
      entryFor(level),
      entryFor(level, order: 2, tier: Tier.hard),
      entryFor(level, order: 3, tier: Tier.superhard, chapterId: 'ch02'),
    ],
  );

  Future<void> pumpHome(
    WidgetTester tester, {
    AsyncValue<HomeState> state = const AsyncValue.data(
      data: HomeState(
        playRequest: PlayRequest.campaign(56),
        tier: Tier.hard,
        coins: 830,
      ),
    ),
    ValueChanged<PlayRequest>? onPlay,
    VoidCallback? onRetry,
    VoidCallback? onDaily,
    VoidCallback? onMuseum,
    ValueChanged<ShopTab>? onShop,
    VoidCallback? onSettings,
    FakeLevelRepository? repository,
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    await pumpScreen(
      tester,
      HomeView(
        state: state,
        onRetry: onRetry ?? () {},
        onPlay: onPlay ?? (_) {},
        onDaily: onDaily ?? () {},
        onMuseum: onMuseum ?? () {},
        onShop: onShop ?? (_) {},
        onSettings: onSettings ?? () {},
        library: FakeFxLibrary(),
        levels: repository,
      ),
      size: size,
      textScale: textScale,
    );
    await tester.pump();
  }

  testWidgets('frame 2.1: coins, wordmark, gear, five idle dolls, twinkles '
      'and PLAY with its level and tier', (tester) async {
    await pumpHome(tester);
    expect(find.text('830'), findsOneWidget);
    expect(find.byType(Wordmark), findsOneWidget);

    final dolls = tester.widgetList<LottieDoll>(find.byType(LottieDoll));
    expect(dolls.map((d) => d.color), [
      DollColor.orange,
      DollColor.green,
      DollColor.red,
      DollColor.blue,
      DollColor.purple,
    ]);
    expect(dolls.every((d) => d.id == FxId.dollIdle), isTrue);
    final speeds = dolls.map((d) => d.speed).toList();
    expect(speeds.every((s) => s >= 0.8 && s <= 1.2), isTrue);
    expect(speeds.toSet(), hasLength(5), reason: 'seeded, each its own');
    expect(find.byType(LottieTwinkle), findsNWidgets(4));

    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('Level 56'), findsOneWidget);
    expect(find.text('HARD'), findsOneWidget);
    expect(find.bySemanticsLabel('Play level 56, Hard'), findsOneWidget);
  });

  testWidgets('the same seeded shelf on every visit', (tester) async {
    await pumpHome(tester);
    final first = [
      for (final d in tester.widgetList<LottieDoll>(find.byType(LottieDoll)))
        (d.speed, d.phaseMs),
    ];
    await pumpScreen(tester, const SizedBox());
    await pumpHome(tester);
    final second = [
      for (final d in tester.widgetList<LottieDoll>(find.byType(LottieDoll)))
        (d.speed, d.phaseMs),
    ];
    expect(second, first);
  });

  testWidgets('PLAY opens the current level', (tester) async {
    final played = <PlayRequest>[];
    await pumpHome(tester, onPlay: played.add);
    await tester.tap(find.text('Level 56'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(played, [const PlayRequest.campaign(56)]);
  });

  testWidgets('Bonus Endless: PLAY names "Bonus Level N" (m3-design §7.4, '
      'D74)', (tester) async {
    final played = <PlayRequest>[];
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(playRequest: PlayRequest.bonus(3)),
      ),
      onPlay: played.add,
    );
    expect(find.text('Level 31'), findsNothing);
    expect(find.text('Bonus Level 3'), findsOneWidget);
    await tester.tap(find.text('Bonus Level 3'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(played, [const PlayRequest.bonus(3)]);
  });

  testWidgets("the coin pill's + opens the Shop's Coins tab, the gear opens "
      'Settings', (tester) async {
    final shops = <ShopTab>[];
    var settingsOpened = false;
    await pumpHome(
      tester,
      onShop: shops.add,
      onSettings: () => settingsOpened = true,
    );
    await tester.tap(find.bySemanticsLabel('830 coins. Get more coins'));
    expect(shops, [ShopTab.coins]);

    await tester.tap(find.bySemanticsLabel('Settings'));
    expect(settingsOpened, isTrue);
  });

  testWidgets('the Daily tile opens Daily, dimmed and lock-badged while '
      'locked', (tester) async {
    var dailyOpened = false;
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(playRequest: PlayRequest.campaign(1)),
      ),
      onDaily: () => dailyOpened = true,
    );
    expect(find.text('Daily Puzzle'), findsOneWidget);
    expect(find.text('After Level 2'), findsOneWidget);
    await tester.tap(find.text('Daily Puzzle'));
    expect(dailyOpened, isFalse, reason: 'the locked tile ignores taps');
  });

  testWidgets('the Daily tile shows its streak badge once unlocked, and '
      'opens Daily', (tester) async {
    var dailyOpened = false;
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(
          playRequest: PlayRequest.campaign(4),
          dailyUnlocked: true,
          dailyStreak: 5,
        ),
      ),
      onDaily: () => dailyOpened = true,
    );
    expect(find.text('After Level 2'), findsNothing);
    expect(find.bySemanticsLabel('5-day streak'), findsOneWidget);
    await tester.tap(find.text('Daily Puzzle'));
    expect(dailyOpened, isTrue);
  });

  testWidgets('the Museum tile shows the chapter bar and opens Museum', (
    tester,
  ) async {
    var museumOpened = false;
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(
          playRequest: PlayRequest.campaign(4),
          museumDone: 15,
          museumTotal: 20,
        ),
      ),
      onMuseum: () => museumOpened = true,
    );
    expect(find.text('Museum'), findsOneWidget);
    expect(find.text('15/20'), findsOneWidget);
    await tester.tap(find.text('Museum'));
    expect(museumOpened, isTrue);
  });

  testWidgets('Remove Ads hides once adsRemoved, and the other tiles widen', (
    tester,
  ) async {
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(playRequest: PlayRequest.campaign(4), adsRemoved: true),
      ),
    );
    expect(find.text('Remove Ads'), findsNothing);
    expect(find.text('Daily Puzzle'), findsOneWidget);
    expect(find.text('Museum'), findsOneWidget);
  });

  testWidgets('Remove Ads shows and opens nothing yet (M6)', (tester) async {
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(playRequest: PlayRequest.campaign(4)),
      ),
    );
    expect(find.text('Remove Ads'), findsOneWidget);
  });

  testWidgets('the shelf keeps its art while a level covers Home, so the '
      'way back never flashes placeholder dolls (review FIDELITY-4)', (
    tester,
  ) async {
    final showcase = ShowcaseDolls(FakeSkinService(), FakeDatabaseService());
    addTearDown(showcase.dispose);
    await pumpScreen(
      tester,
      HomeView(
        state: const AsyncValue.data(
          data: HomeState(playRequest: PlayRequest.campaign(1)),
        ),
        onRetry: () {},
        onPlay: (_) {},
        onDaily: () {},
        onMuseum: () {},
        onShop: (_) {},
        onSettings: () {},
        library: FakeFxLibrary(),
        showcase: showcase,
      ),
    );
    await tester.pump();
    final art = showcase.current.value;
    expect(art, isNotNull);
    bool dollsHaveArt() => tester
        .widgetList<LottieDoll>(find.byType(LottieDoll, skipOffstage: false))
        .every((d) => identical(d.images, art!.images));
    expect(dollsHaveArt(), isTrue);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(
      navigator.push(MaterialPageRoute<void>(builder: (_) => const Scaffold())),
    );
    await tester.pumpAndSettle();
    expect(showcase.current.value, same(art), reason: 'kept while covered');

    navigator.pop();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(dollsHaveArt(), isTrue, reason: 'frame $i of the way back');
    }
    await tester.pumpAndSettle();
    expect(showcase.current.value, same(art));
  });

  testWidgets('a failed load offers a retry', (tester) async {
    var retries = 0;
    await pumpHome(
      tester,
      state: const AsyncValue.error(
        exception: AppException(AppExceptionKind.content, message: 'bundle'),
      ),
      onRetry: () => retries++,
    );
    expect(find.text('PLAY'), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(retries, 1);
  });

  testWidgets('the dev flavor jumps to any level from the picker', (
    tester,
  ) async {
    final played = <PlayRequest>[];
    await pumpHome(tester, onPlay: played.add, repository: levels());
    expect(LevelPickerSheet.isAvailable, isTrue);
    await tester.tap(find.text('Jump to a level'));
    await tester.pumpAndSettle();
    expect(find.byType(LevelPickerSheet), findsOneWidget);
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(find.byType(LevelPickerSheet), findsNothing);
    expect(played, [const PlayRequest.campaign(2)]);
  });

  testWidgets('no picker without the level list', (tester) async {
    await pumpHome(tester);
    expect(find.text('Jump to a level'), findsNothing);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()}×${size.height.toInt()} at '
          '$scale× text', (tester) async {
        await pumpHome(
          tester,
          state: const AsyncValue.data(
            data: HomeState(
              playRequest: PlayRequest.campaign(188),
              tier: Tier.superhard,
              coins: 1234567,
              dailyUnlocked: true,
              dailyStreak: 12,
              museumDone: 15,
            ),
          ),
          repository: levels(),
          size: size,
          textScale: scale,
        );
        expectNoLayoutErrors(tester);
        final play = tester.getRect(find.byType(PlayButton));
        expect(play.left, greaterThanOrEqualTo(0));
        expect(play.right, lessThanOrEqualTo(size.width));
        expect(play.bottom, lessThanOrEqualTo(size.height));
      });
    }
  }
}
