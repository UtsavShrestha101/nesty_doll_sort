import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/analytics/fake_analytics_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/home/stars_chip.dart';
import 'package:nesty_game/core/ui/widgets/home/streak_look.dart';
import 'package:nesty_game/features/dev/level_picker_sheet.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_game/features/home/widgets/home_chapter_card.dart';
import 'package:nesty_game/features/login_gift/cubit/login_gift_cubit.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_button.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_sheet.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_tally.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';

import '../../core/ui/support/ui_harness.dart';
import '../../helpers/level_fixtures.dart';
import '../../helpers/test_dependencies.dart';
import '../support/screen_harness.dart';

/// Frame 2.1's hero (spec §10.2 #2; m3-design §10.3): the coin pill (its
/// "+" opens the Shop), the small wordmark, the gear (Settings), five idling
/// dolls under twinkles, PLAY with the level and its tier badge, and the
/// Daily / Museum / Remove Ads tiles. The dev flavor adds the level picker.
/// A tactile button's face (its 46 dp surface inside the 48 dp target).
Rect faceOf(WidgetTester tester, Finder button) => tester.getRect(
  find.descendant(of: button, matching: find.byType(GestureDetector)).first,
);

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
    VoidCallback? onChapters,
    VoidCallback? onRecords,
    VoidCallback? onVsComputer,
    ValueChanged<ShopTab>? onShop,
    VoidCallback? onSettings,
    FakeLevelRepository? repository,
    Size size = const Size(390, 844),
    double textScale = 1,
    LoginGiftCubit? gift,
    EdgeInsets? padding,
  }) async {
    Widget view(Widget child) =>
        gift == null ? child : BlocProvider.value(value: gift, child: child);
    await pumpScreen(
      tester,
      view(
        HomeView(
          state: state,
          onRetry: onRetry ?? () {},
          onPlay: onPlay ?? (_) {},
          onDaily: onDaily ?? () {},
          onMuseum: onMuseum ?? () {},
          onChapters: onChapters ?? () {},
          onRecords: onRecords ?? () {},
          onVsComputer: onVsComputer ?? () {},
          onShop: onShop ?? (_) {},
          onSettings: onSettings ?? () {},
          library: FakeFxLibrary(),
          levels: repository,
        ),
      ),
      size: size,
      textScale: textScale,
      padding: padding,
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
    // NestyHub:290: a label of 9 characters or fewer is set at 36.
    expect(tester.widget<Text>(find.text('Level 56')).style!.fontSize, 36);
    expect(find.text('HARD'), findsOneWidget);
    expect(find.bySemanticsLabel('Play level 56, Hard'), findsOneWidget);
  });

  group('the daily gift button (frame 13.1)', () {
    Future<LoginGiftCubit> giftCubit(int highestLevel) async {
      final cubit = LoginGiftCubit(
        FakeSaveService(initial: SaveDocument(highestLevel: highestLevel)),
        FakeClock(),
        FakeRemoteConfigService(),
        FakeAnalyticsService(),
      );
      await cubit.load();
      return cubit;
    }

    testWidgets('hidden while locked: the gear is alone', (tester) async {
      final cubit = await giftCubit(1);
      await pumpHome(tester, gift: cubit);
      expect(find.byType(GiftButton), findsOneWidget);
      expect(find.byKey(GiftButton.faceKey), findsNothing);
      expect(find.byIcon(NestyIcons.settings), findsOneWidget);
      await tester.runAsync(cubit.close);
    });

    testWidgets('shown with its dot when ready, between the wordmark and the '
        'gear; the wordmark stays centred', (tester) async {
      final cubit = await giftCubit(5);
      await pumpHome(tester, gift: cubit);
      expect(find.byKey(GiftButton.faceKey), findsOneWidget);
      expect(find.byKey(GiftButton.dotKey), findsOneWidget);
      final gift = tester.getRect(find.byKey(GiftButton.faceKey));
      final gear = tester.getRect(find.byIcon(NestyIcons.settings));
      expect(gift.right, lessThanOrEqualTo(gear.left + 24));
      final wordmark = tester.getCenter(find.byType(Wordmark));
      expect(wordmark.dx, closeTo(195, 1));
      await tester.runAsync(cubit.close);
    });

    testWidgets('on the smallest phone at 1.3x text both header buttons keep '
        'their full size (a 48 dp target), apart, and the wordmark centred', (
      tester,
    ) async {
      final cubit = await giftCubit(5);
      await pumpHome(
        tester,
        gift: cubit,
        size: const Size(360, 640),
        textScale: 1.3,
      );
      final buttons = find.byType(IconTactileButton);
      final gift = tester.getRect(find.byKey(GiftButton.faceKey));
      final gear = tester.getRect(
        find.ancestor(of: find.byIcon(NestyIcons.settings), matching: buttons),
      );
      for (final rect in [gift, gear]) {
        expect(rect.width, greaterThanOrEqualTo(48));
        expect(rect.height, greaterThanOrEqualTo(48));
      }
      // `gift.button.narrow`: both faces stay 46, 6 apart.
      final giftFace = faceOf(tester, find.byKey(GiftButton.faceKey));
      final gearFace = faceOf(
        tester,
        find.ancestor(of: find.byIcon(NestyIcons.settings), matching: buttons),
      );
      expect(giftFace.size, const Size.square(46));
      expect(gearFace.size, const Size.square(46));
      expect(gearFace.left - giftFace.right, closeTo(6, 0.01));
      expect(tester.getCenter(find.byType(Wordmark)).dx, closeTo(180, 1));
      await tester.runAsync(cubit.close);
    });

    testWidgets('the pill shows min(balance, cap) while a claim\'s coins fly', (
      tester,
    ) async {
      final save = FakeSaveService(
        initial: const SaveDocument(highestLevel: 5, coins: 100),
      );
      final cubit = LoginGiftCubit(
        save,
        FakeClock(),
        FakeRemoteConfigService(),
        FakeAnalyticsService(),
      );
      await cubit.load();
      AsyncValue<HomeState> home(int coins) => AsyncValue.data(
        data: HomeState(
          playRequest: const PlayRequest.campaign(56),
          tier: Tier.hard,
          coins: coins,
        ),
      );
      cubit.claim();
      // The balance is already 120; the pill waits at 100.
      await pumpHome(tester, gift: cubit, state: home(save.coins));
      expect(find.text('100'), findsOneWidget);
      cubit.coinsLanded(10);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('110'), findsOneWidget);
      cubit.releaseCoins();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('120'), findsOneWidget);
      await tester.runAsync(cubit.close);
    });

    testWidgets('13.1 / 13.1b: the gift\'s face sits left of the gear, '
        'right 68 and top 64 on 844, top 26 on 16:9', (tester) async {
      final cubit = await giftCubit(5);
      await pumpHome(tester, gift: cubit);
      var face = faceOf(tester, find.byKey(GiftButton.faceKey));
      expect(face, const Rect.fromLTWH(390 - 68 - 46, 64, 46, 46));
      var gear = faceOf(
        tester,
        find.ancestor(
          of: find.byIcon(NestyIcons.settings),
          matching: find.byType(IconTactileButton),
        ),
      );
      expect(gear, const Rect.fromLTWH(390 - 16 - 46, 64, 46, 46));

      // A 16:9 phone's Home, its body above the tab bar (2.1b's nav at
      // 587) as the shell lays it out.
      await pumpHome(
        tester,
        gift: cubit,
        size: const Size(390, 587),
        padding: const EdgeInsets.only(top: 20),
      );
      face = faceOf(tester, find.byKey(GiftButton.faceKey));
      expect(face.top, closeTo(26, 0.01));
      expect(face.right, closeTo(390 - 68, 0.01));
      gear = faceOf(
        tester,
        find.ancestor(
          of: find.byIcon(NestyIcons.settings),
          matching: find.byType(IconTactileButton),
        ),
      );
      expect(gear.top, closeTo(26, 0.01));
      await tester.runAsync(cubit.close);
    });

    for (final (name, size, padding, tallyTop) in [
      ('844', const Size(390, 844), null, 120.0),
      // 16:9: Home's body above the tab bar (2.1b's nav at 587).
      ('16:9', const Size(390, 587), const EdgeInsets.only(top: 20), 82.0),
    ]) {
      testWidgets('13.5c on $name: a hint day\'s tally hangs under the pill '
          '(left 16, top $tallyTop) and its +1 never covers "CHAPTER n"', (
        tester,
      ) async {
        final yesterday = LocalDate.fromDateTime(
          FakeClock.defaultNow,
        ).addDays(-1);
        final save = FakeSaveService(
          initial: SaveDocument(
            highestLevel: 5,
            coins: 930,
            loginGift: LoginGiftProgress(
              claims: 2,
              lastClaim: yesterday,
              latestSeen: yesterday,
            ),
          ),
        );
        final cubit = LoginGiftCubit(
          save,
          FakeClock(),
          FakeRemoteConfigService(),
          FakeAnalyticsService(),
        );
        await cubit.load();
        final hintsBefore = save.boosterCount(BoosterKind.hint);
        await pumpHome(
          tester,
          gift: cubit,
          size: size,
          padding: padding,
          state: const AsyncValue.data(
            data: HomeState(
              playRequest: PlayRequest.campaign(56),
              tier: Tier.hard,
              coins: 930,
              chapterNumber: 3,
              chapterId: 'ch03',
              dailyUnlocked: true,
            ),
          ),
        );
        final pill = tester.getRect(find.byType(CoinPill));
        await tester.tap(find.byType(GiftButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.byKey(GiftSheet.claimKey));
        await tester.pump();
        // The hint is in the air: the tally has slid out with the old count.
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byKey(GiftTally.boxKey), findsOneWidget);
        expect(find.text('$hintsBefore'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 500));
        final box = tester.getRect(find.byKey(GiftTally.boxKey));
        expect(box.left, closeTo(16, 0.01));
        expect(box.top, closeTo(pill.top + 54, 0.01));
        expect(box.top, closeTo(tallyTop, 1.01));
        expect(box.height, 36);
        // Landed: the new total and the +1 tag.
        expect(find.text('${hintsBefore + 1}'), findsOneWidget);
        final tag = tester.getRect(find.byKey(GiftTally.tagKey));
        final kicker = tester.getRect(
          find
              .descendant(
                of: find.byType(HomeChapterCard),
                matching: find.byType(Text),
              )
              .first,
        );
        expect(
          tag.overlaps(kicker),
          isFalse,
          reason: 'the tag $tag covers the kicker $kicker',
        );
        // It holds 1.2 s, slides back and is gone.
        await tester.pump(const Duration(milliseconds: 1300));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byKey(GiftTally.boxKey), findsNothing);
        await tester.runAsync(cubit.close);
      });
    }

    testWidgets('without a gift cubit Home still draws (older tests)', (
      tester,
    ) async {
      await pumpHome(tester);
      expect(find.byKey(GiftButton.faceKey), findsNothing);
    });
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
    await tester.tap(find.bySemanticsLabel('830 coins. Opens the Shop.'));
    expect(shops, [ShopTab.coins]);

    await tester.tap(find.bySemanticsLabel('Settings'));
    expect(settingsOpened, isTrue);
  });

  testWidgets('the Daily tile ignores taps while it is locked', (tester) async {
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
    // NestyHub:39: Nunito 800 12.
    final footer = tester.widget<Text>(find.text('After Level 2'));
    expect(footer.style!.fontSize, 12);
    expect(footer.style!.fontWeight, FontWeight.w800);
    await tester.tap(find.text('Daily Puzzle'));
    expect(dailyOpened, isFalse, reason: 'the locked tile ignores taps');
  });

  testWidgets('a locked tile tells a screen reader why, as its footer does '
      '(review R15)', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(
          playRequest: PlayRequest.campaign(1),
          raceUnlockLevel: 20,
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Daily Puzzle')).value,
      'After Level 2',
    );
    // One sentence names the tile and why it is locked (copy.md A11y
    // `a11y_home_versus_locked`).
    expect(
      find.bySemanticsLabel('vs Computer, locked. After Level 20.'),
      findsOneWidget,
    );
    handle.dispose();
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
          dailyLit: true,
        ),
      ),
      onDaily: () => dailyOpened = true,
    );
    expect(find.text('After Level 2'), findsNothing);
    expect(find.bySemanticsLabel('5-day streak'), findsOneWidget);
    await tester.tap(find.text('Daily Puzzle'));
    expect(dailyOpened, isTrue);
  });

  // E2 the gentle streak (m7-design §8, §15.7): the Home badge takes its
  // paused look, never red (Q96).
  testWidgets('the Daily tile\'s streak badge is paused when the flame is '
      'out', (tester) async {
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(
          playRequest: PlayRequest.campaign(4),
          dailyUnlocked: true,
          dailyStreak: 9,
        ),
      ),
    );
    expect(find.bySemanticsLabel('9-day streak, paused'), findsOneWidget);
    expect(find.bySemanticsLabel('9-day streak'), findsNothing);
  });

  testWidgets('the chapter card opens Chapters and the Records button opens '
      'Records (frame 2.1)', (tester) async {
    var chaptersOpened = false;
    var recordsOpened = false;
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(
          playRequest: PlayRequest.campaign(56),
          tier: Tier.hard,
          chapterNumber: 3,
          chapterId: 'ch03',
          chapterStars: 39,
          chapterStarsPossible: 60,
        ),
      ),
      onChapters: () => chaptersOpened = true,
      onRecords: () => recordsOpened = true,
    );
    expect(find.text('CHAPTER 3'), findsOneWidget);
    expect(find.text('Seaside Market'), findsOneWidget);
    expect(find.text('39/60'), findsOneWidget);
    expect(find.text('Records'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Chapter 3, Seaside Market. 39 of 60 stars. Opens Chapters.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Seaside Market'));
    expect(chaptersOpened, isTrue);
    expect(recordsOpened, isFalse);

    await tester.tap(find.text('Records'));
    expect(recordsOpened, isTrue);
  });

  testWidgets('the chapter card and the Records button are one row, the same '
      'height, 60 at least, the button 62 wide', (tester) async {
    await pumpHome(tester);
    final card = tester.getRect(find.byType(HomeChapterCard));
    final button = tester.getRect(find.byType(HomeRecordsButton));
    expect(card.height, greaterThanOrEqualTo(60));
    expect(button.height, card.height);
    expect(button.width, 62);
    expect(button.top, card.top);
    // Frame 2.1: the card ends 88 from the right, the button starts 78.
    expect(390 - card.right, 88);
    expect(390 - button.right, 16);
  });

  testWidgets('the chapter card\'s type follows NestyHub:25-26 and its chip '
      'is 30 tall (phase 5)', (tester) async {
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(
          playRequest: PlayRequest.campaign(56),
          tier: Tier.hard,
          chapterNumber: 3,
          chapterId: 'ch03',
          chapterStars: 39,
          chapterStarsPossible: 60,
        ),
      ),
    );
    final kicker = tester.widget<Text>(find.text('CHAPTER 3'));
    expect(kicker.style!.fontSize, 11);
    expect(kicker.style!.letterSpacing, closeTo(11 * 0.08, 1e-9));
    final name = tester.widget<Text>(find.text('Seaside Market'));
    expect(name.style!.fontSize, 17);
    expect(name.style!.height, 1.1);
    expect(tester.getSize(find.byType(StarsChip)).height, 30);
    expect(tester.widget<Text>(find.text('Records')).style!.fontSize, 11);
  });

  testWidgets('Bonus Endless: the card reads BONUS ENDLESS / Bonus levels '
      'with the whole campaign\'s stars, and PLAY wears BONUS (frame 12.2)', (
    tester,
  ) async {
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(
          playRequest: PlayRequest.bonus(7),
          chapterNumber: 10,
          chapterId: 'ch10',
          isBonus: true,
          chapterStars: 552,
          chapterStarsPossible: 600,
          coins: 6420,
        ),
      ),
    );
    expect(find.text('BONUS ENDLESS'), findsOneWidget);
    expect(find.text('Bonus levels'), findsOneWidget);
    expect(find.text('552/600'), findsOneWidget);
    expect(find.text('Bonus Level 7'), findsOneWidget);
    // NestyHub:290: a label over 9 characters is set at 28 (f12-2).
    expect(tester.widget<Text>(find.text('Bonus Level 7')).style!.fontSize, 28);
    expect(find.text('BONUS'), findsOneWidget);
    expect(find.text('HARD'), findsNothing);
    expect(
      find.bySemanticsLabel('Bonus levels. 552 of 600 stars. Opens Chapters.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'a Super Hard level: the bolt badge, not the flame (frame 12.1)',
    (tester) async {
      await pumpHome(
        tester,
        state: const AsyncValue.data(
          data: HomeState(
            playRequest: PlayRequest.campaign(60),
            tier: Tier.superhard,
          ),
        ),
      );
      expect(find.text('SUPER HARD'), findsOneWidget);
      expect(find.byIcon(NestyIcons.bolt), findsOneWidget);
      expect(
        find.bySemanticsLabel('Play level 60, Super Hard'),
        findsOneWidget,
      );
    },
  );

  testWidgets('a Normal level has no badge on PLAY', (tester) async {
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(playRequest: PlayRequest.campaign(3)),
      ),
    );
    expect(find.text('HARD'), findsNothing);
    expect(find.text('SUPER HARD'), findsNothing);
    expect(find.text('BONUS'), findsNothing);
  });

  testWidgets('the vs Computer tile is locked below raceUnlockLevel: the '
      'locked portrait with a lock chip, "After Level 20", dimmed, and it '
      'never taps (frame 9.1)', (tester) async {
    var opened = 0;
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(
          playRequest: PlayRequest.campaign(4),
          raceUnlockLevel: 20,
        ),
      ),
      onVsComputer: () => opened++,
    );
    expect(find.text('vs Computer'), findsOneWidget);
    expect(find.text('After Level 20'), findsOneWidget);
    expect(find.byIcon(NestyIcons.lock), findsOneWidget);
    // Locked: the tag is not shown yet (no rival to label).
    expect(find.byType(ComputerTag), findsNothing);
    final portrait = tester.widget<UiArtImage>(
      find.byWidgetPredicate(
        (w) => w is UiArtImage && w.art == UiArt.rivalLocked,
      ),
    );
    expect(portrait.size.width, 58);

    await tester.tap(find.text('vs Computer'));
    await tester.pump();
    expect(opened, 0, reason: 'no tap and no shake while locked');
  });

  testWidgets('the vs Computer tile, unlocked: rival 1\'s portrait, the '
      'Computer tag under the label, and a tap opens rival select', (
    tester,
  ) async {
    var opened = 0;
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(
          playRequest: PlayRequest.campaign(21),
          raceUnlockLevel: 20,
          raceUnlocked: true,
        ),
      ),
      onVsComputer: () => opened++,
    );
    expect(find.text('After Level 20'), findsNothing);
    expect(find.byIcon(NestyIcons.lock), findsNothing);
    // Every computer rival surface labels it a computer (ethics 4).
    expect(find.byType(ComputerTag), findsOneWidget);
    expect(find.text('Computer'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is UiArtImage && w.art == UiArt.rival1),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('vs Computer. Race a computer on the same puzzle.'),
      findsOneWidget,
    );
    await tester.tap(find.text('vs Computer'));
    expect(opened, 1);
  });

  testWidgets('the tiles are Daily, vs Computer, Remove Ads, left to right', (
    tester,
  ) async {
    await pumpHome(tester);
    final xs = [
      for (final label in ['Daily Puzzle', 'vs Computer', 'Remove Ads'])
        tester.getCenter(find.text(label)).dx,
    ];
    expect(xs, orderedEquals([...xs]..sort()));
    expect(xs.toSet(), hasLength(3));
  });

  testWidgets('a locked Daily tile has no lock glyph and no badge, only the '
      'dimmed tile and its footer (frame 12.3)', (tester) async {
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(playRequest: PlayRequest.campaign(2), coins: 10),
      ),
    );
    expect(find.byType(StreakBadge), findsNothing);
    expect(find.text('After Level 2'), findsOneWidget);
    expect(
      tester
          .widgetList<Opacity>(find.byType(Opacity))
          .where((o) => o.opacity == 0.6)
          .length,
      2,
      reason: 'Daily and vs Computer are dimmed to 60 %',
    );
  });

  group('the Daily badge (frames 2.1, 12.2)', () {
    HomeState streak({int days = 4, bool lit = true, bool relit = false}) =>
        HomeState(
          playRequest: const PlayRequest.campaign(9),
          dailyUnlocked: true,
          dailyStreak: days,
          dailyLit: lit,
          streakRelit: relit,
        );

    testWidgets('lit: the flame with its count, and a 26 tall pill', (
      tester,
    ) async {
      await pumpHome(tester, state: AsyncValue.data(data: streak()));
      expect(find.text('4'), findsOneWidget);
      expect(find.byIcon(NestyIcons.localFireDepartment), findsOneWidget);
      expect(tester.getSize(find.byType(StreakBadge)).height, 26);
    });

    testWidgets('a streak of 0 keeps the unlit flame and no number', (
      tester,
    ) async {
      await pumpHome(
        tester,
        state: AsyncValue.data(data: streak(days: 0, lit: false)),
      );
      expect(find.byType(StreakBadge), findsOneWidget);
      expect(find.byIcon(NestyIcons.localFireDepartment), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(StreakBadge),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
      expect(find.bySemanticsLabel(RegExp('streak')), findsNothing);
    });

    testWidgets('paused: the resting colours, never red, the number stays', (
      tester,
    ) async {
      await pumpHome(
        tester,
        state: AsyncValue.data(data: streak(days: 9, lit: false)),
      );
      final flame = tester.widget<Icon>(
        find.byIcon(NestyIcons.localFireDepartment),
      );
      expect(flame.color, AppColorTokens.streakPausedGlyph);
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('relit: the lit look plus the glow ring, faded in once', (
      tester,
    ) async {
      await pumpHome(tester, state: AsyncValue.data(data: streak(relit: true)));
      bool ring() => tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .any(
            (b) =>
                b.decoration is BoxDecoration &&
                (b.decoration as BoxDecoration).border is Border &&
                ((b.decoration as BoxDecoration).border! as Border).top.color ==
                    AppColorTokens.relitGlow,
          );
      expect(ring(), isTrue);
      final fade = find.descendant(
        of: find.byType(StreakBadge),
        matching: find.byType(Opacity),
      );
      expect(fade, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      expect(ring(), isTrue, reason: 'stays after the fade, no loop');
    });

    testWidgets('the relit glow reports when it is over, once (4.10)', (
      tester,
    ) async {
      var ended = 0;
      await pumpScreen(
        tester,
        HomeView(
          state: AsyncValue.data(data: streak(relit: true)),
          onRetry: () {},
          onPlay: (_) {},
          onDaily: () {},
          onRelitGlowEnd: () => ended++,
          onMuseum: () {},
          onShop: (_) {},
          onSettings: () {},
          library: FakeFxLibrary(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(ended, 0);
      await tester.pump(const Duration(seconds: 3));
      expect(ended, 1);
    });

    testWidgets('a glow built under a covering route waits for Home to show '
        '(4.10)', (tester) async {
      // Home's cubit hears of the relight during the daily's solve, while
      // the Daily screen covers Home (an offstage route: its tickers are
      // muted, but their clocks run). The glow must still play once Home
      // shows, not end unseen.
      var ended = 0;
      final covered = ValueNotifier(true);
      addTearDown(covered.dispose);
      await pumpScreen(
        tester,
        ValueListenableBuilder<bool>(
          valueListenable: covered,
          builder: (context, hidden, child) =>
              TickerMode(enabled: !hidden, child: child!),
          child: StreakBadge(
            days: 5,
            look: StreakLook.relit,
            onRelitGlowEnd: () => ended++,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 6));
      expect(ended, 0, reason: 'nothing plays while covered');
      covered.value = false;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(ended, 0, reason: 'the glow starts when Home shows');
      final fade = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(StreakBadge),
          matching: find.byType(Opacity),
        ),
      );
      expect(fade.opacity, 1, reason: 'held for glowMs');
      await tester.pump(const Duration(seconds: 3));
      expect(ended, 1);
    });

    testWidgets('relit under reduce motion is a static ring', (tester) async {
      await pumpScreen(
        tester,
        HomeView(
          state: AsyncValue.data(data: streak(relit: true)),
          onRetry: () {},
          onPlay: (_) {},
          onDaily: () {},
          onMuseum: () {},
          onShop: (_) {},
          onSettings: () {},
          library: FakeFxLibrary(),
        ),
        reduceMotion: true,
      );
      await tester.pump();
      expect(find.byType(StreakBadge), findsOneWidget);
      // No fade tween is running: everything settles at once.
      await tester.pumpAndSettle(const Duration(milliseconds: 16));
    });
  });

  // D111 (the owner's simulator review, 2026-09-28): Home dropped its
  // Museum tile (the bottom nav's Museum tab already covers it), so this
  // file no longer has a "the Museum tile shows..." test; `onMuseum` stays
  // a required `HomeView` constructor argument (`pumpHome` still passes
  // it, defaulted through the helper below) even though nothing here taps
  // it any more.

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
  });

  testWidgets('Home has no Museum tile: the bottom nav\'s Museum tab covers '
      'it (D111)', (tester) async {
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(
          playRequest: PlayRequest.campaign(4),
          museumDone: 15,
          museumTotal: 20,
        ),
      ),
    );
    expect(find.text('Museum'), findsNothing);
    expect(find.text('15/20'), findsNothing);
    expect(find.text('Daily Puzzle'), findsOneWidget);
    expect(find.text('Remove Ads'), findsOneWidget);
    expect(find.text('vs Computer'), findsOneWidget);
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

  testWidgets('the picker opens scrolled to Home\'s own campaign level '
      '(owner-fixes lane, 2026-09-28)', (tester) async {
    // The default state's `playRequest` (top of this file): campaign 56.
    await pumpHome(tester, repository: levels());
    await tester.tap(find.text('Jump to a level'));
    await tester.pumpAndSettle();
    final sheet = tester.widget<LevelPickerSheet>(
      find.byType(LevelPickerSheet),
    );
    expect(sheet.currentOrder, 56);
  });

  testWidgets('the picker opens unscrolled for a bonus PLAY (no campaign '
      'order to scroll to)', (tester) async {
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(playRequest: PlayRequest.bonus(3)),
      ),
      repository: levels(),
    );
    await tester.tap(find.text('Jump to a level'));
    await tester.pumpAndSettle();
    final sheet = tester.widget<LevelPickerSheet>(
      find.byType(LevelPickerSheet),
    );
    expect(sheet.currentOrder, isNull);
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
