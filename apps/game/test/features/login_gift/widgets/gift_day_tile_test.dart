import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_reward.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/login_gift/cubit/login_gift_cubit.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_day_tile.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_metrics.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

/// A day tile's four looks (frames 13.3–13.8, `gift.tile`): done sunk with
/// the gift at half strength and a green check, today ringed in orange and
/// lifted, later plain white, and Day 7's wide tile with the chest and its
/// chips; the claim's sink and the check's pop.
void main() {
  setUpAll(loadBundledFonts);

  Widget tile({
    int day = 2,
    LoginGiftReward reward = const LoginGiftReward(coins: 30),
    GiftTileState state = GiftTileState.later,
    bool wide = false,
    double width = 110,
  }) => Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(40),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: wide ? 350 : width,
          child: GiftDayTile(
            day: day,
            reward: reward,
            tileState: state,
            wide: wide,
          ),
        ),
      ),
    ),
  );

  Future<void> pumpTile(
    WidgetTester tester, {
    int day = 2,
    LoginGiftReward reward = const LoginGiftReward(coins: 30),
    GiftTileState state = GiftTileState.later,
    bool wide = false,
    double textScale = 1,
    bool reduceMotion = false,
  }) => pumpScreen(
    tester,
    tile(day: day, reward: reward, state: state, wide: wide),
    textScale: textScale,
    reduceMotion: reduceMotion,
  );

  SurfaceStyle faceStyle(WidgetTester tester) =>
      tester.widget<NestySurface>(find.byKey(GiftDayTile.faceKey)).style;

  testWidgets('a later day is plain white: its art, its amount and no check', (
    tester,
  ) async {
    await pumpTile(tester);
    expect(find.text('Day 2'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.byKey(GiftDayTile.checkKey), findsNothing);
    expect(find.byIcon(NestyIcons.lock), findsNothing);
    expect(faceStyle(tester).color, GiftTileTokens.laterFace);
    expect(faceStyle(tester).shadows, GiftTileTokens.laterShadow);
    final art = tester.widget<UiArtImage>(find.byType(UiArtImage));
    expect(art.art, UiArt.coinFlight);
    expect(art.size, const Size.square(GiftTileTokens.art));
    final label = tester.widget<Text>(find.text('Day 2'));
    expect(label.style!.color, GiftTileTokens.laterLabel);
    expect(label.style!.fontWeight, FontWeight.w800);
    expect(label.style!.fontSize, 13);
  });

  testWidgets('a done day is sunk, at half strength, with the green check', (
    tester,
  ) async {
    await pumpTile(tester, state: GiftTileState.done);
    expect(faceStyle(tester).color, GiftTileTokens.doneFace);
    expect(faceStyle(tester).shadows, GiftTileTokens.doneShadow);
    final check = tester.getRect(find.byKey(GiftDayTile.checkKey));
    final face = tester.getRect(find.byKey(GiftDayTile.faceKey));
    expect(check.size, const Size.square(22));
    expect(check.top - face.top, closeTo(7, 0.01));
    expect(face.right - check.right, closeTo(8, 0.01));
    expect(
      find.descendant(
        of: find.byKey(GiftDayTile.checkKey),
        matching: find.byIcon(IconUses.giftDayDone),
      ),
      findsOneWidget,
    );
    final content = tester.widget<Opacity>(
      find.ancestor(of: find.text('30'), matching: find.byType(Opacity)).first,
    );
    expect(content.opacity, GiftTileTokens.doneContentOpacity);
  });

  testWidgets('today is ringed in orange and lifted 2 dp; no check', (
    tester,
  ) async {
    await pumpTile(tester);
    final later = tester.getRect(find.byKey(GiftDayTile.faceKey));
    await pumpTile(tester, state: GiftTileState.today);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(GiftDayTile.checkKey), findsNothing);
    expect(faceStyle(tester).shadows, GiftTileTokens.todayShadow);
    final today = tester.getRect(find.byKey(GiftDayTile.faceKey));
    expect(today.top - later.top, GiftTileTokens.todayLift);
    final label = tester.widget<Text>(find.text('Day 2'));
    expect(label.style!.color, GiftTileTokens.todayLabel);
  });

  testWidgets('a tile is 100 tall on 844 and 86 on 16:9; the art and amount '
      'follow gift.short', (tester) async {
    await pumpTile(tester);
    expect(tester.getSize(find.byKey(GiftDayTile.faceKey)).height, 100);
    await pumpScreen(tester, tile(), size: const Size(390, 693));
    expect(tester.getSize(find.byKey(GiftDayTile.faceKey)).height, 86);
    expect(
      tester.widget<UiArtImage>(find.byType(UiArtImage)).size,
      const Size.square(GiftShortTokens.art),
    );
    expect(
      tester.widget<Text>(find.text('30')).style!.fontSize,
      GiftShortTokens.amount,
    );
    // Between the two frames every number blends.
    expect(GiftSheetMetrics.forHeight(768).tileHeight, closeTo(93, 0.5));
  });

  testWidgets('"Day N" sits at the same height in every state', (tester) async {
    final tops = <GiftTileState, double>{};
    for (final state in GiftTileState.values) {
      await pumpTile(tester, state: state);
      final face = tester.getRect(find.byKey(GiftDayTile.faceKey));
      tops[state] = tester.getRect(find.text('Day 2')).top - face.top;
    }
    expect(tops[GiftTileState.later], tops[GiftTileState.done]);
    expect(tops[GiftTileState.today], tops[GiftTileState.done]);
  });

  /// A tile whose state [state] changes in place (the claim).
  Future<void> pumpLive(
    WidgetTester tester,
    ValueNotifier<GiftTileState> state, {
    bool reduceMotion = false,
  }) => pumpScreen(
    tester,
    Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 110,
            child: ValueListenableBuilder<GiftTileState>(
              valueListenable: state,
              builder: (context, value, _) => GiftDayTile(
                day: 4,
                reward: const LoginGiftReward(coins: 40),
                tileState: value,
              ),
            ),
          ),
        ),
      ),
    ),
    reduceMotion: reduceMotion,
  );

  testWidgets('the claim: today sinks to done over 160 ms and the check pops '
      '(motion.tagPop)', (tester) async {
    final state = ValueNotifier(GiftTileState.today);
    addTearDown(state.dispose);
    await pumpLive(tester, state);
    state.value = GiftTileState.done;
    await tester.pump();
    // Mid-sink: both looks are on screen, the check is growing.
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.byKey(GiftDayTile.checkKey), findsOneWidget);
    expect(find.byType(NestySurface), findsWidgets);
    final scales = tester
        .widgetList<Transform>(
          find.ancestor(
            of: find.byKey(GiftDayTile.checkKey),
            matching: find.byType(Transform),
          ),
        )
        .map((t) => t.transform.storage[0]);
    expect(scales.reduce((a, b) => a < b ? a : b), lessThan(1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(faceStyle(tester).color, GiftTileTokens.doneFace);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('reduce motion: the looks cross-fade over 200 ms, no pop', (
    tester,
  ) async {
    final state = ValueNotifier(GiftTileState.today);
    addTearDown(state.dispose);
    await pumpLive(tester, state, reduceMotion: true);
    state.value = GiftTileState.done;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
    final scales = tester
        .widgetList<Transform>(
          find.ancestor(
            of: find.byKey(GiftDayTile.checkKey),
            matching: find.byType(Transform),
          ),
        )
        .map((t) => t.transform.storage[0]);
    expect(scales.every((s) => s == 1), isTrue);
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('Day 7: the closed chest and both rewards as chips (the slot '
      'chip on chip_slot.svg); done dims them and checks the tile', (
    tester,
  ) async {
    await pumpTile(
      tester,
      day: 7,
      reward: const LoginGiftReward(coins: 100, slots: 1),
      wide: true,
    );
    expect(find.text('Day 7'), findsOneWidget);
    expect(find.text('+100 coins'), findsOneWidget);
    expect(find.text('+1 slot'), findsOneWidget);
    final arts = tester
        .widgetList<UiArtImage>(find.byType(UiArtImage))
        .map((a) => a.art)
        .toList();
    expect(arts, [UiArt.chestClosed, UiArt.coinFlight, UiArt.chipSlot]);
    final chest = tester.widget<UiArtImage>(find.byType(UiArtImage).first);
    expect(chest.size, GiftSheetTokens.day7Chest);
    final chip = tester.getRect(find.byType(GiftChip).first);
    expect(chip.height, GiftSheetTokens.day7ChipsHeight);
    expect(tester.getSize(find.byKey(GiftDayTile.faceKey)).height, 112);

    await pumpTile(
      tester,
      day: 7,
      reward: const LoginGiftReward(coins: 100, slots: 1),
      state: GiftTileState.done,
      wide: true,
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(GiftDayTile.checkKey), findsOneWidget);
    final dims = tester
        .widgetList<Opacity>(find.byType(Opacity))
        .where((o) => o.opacity == GiftTileTokens.doneContentOpacity);
    expect(dims, hasLength(2), reason: 'the chest and the chips');
  });

  testWidgets('Day 7 at 1.3× text on a narrow tile: the chips wrap to two '
      'rows and the tile grows instead of overflowing', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 280,
              child: GiftDayTile(
                day: 7,
                reward: const LoginGiftReward(coins: 100, slots: 1),
                tileState: GiftTileState.later,
                wide: true,
                metrics: GiftSheetMetrics.forHeight(844),
              ),
            ),
          ),
        ),
      ),
      size: const Size(360, 640),
      textScale: 1.3,
    );
    final chips = find.byType(GiftChip);
    expect(
      tester.getRect(chips.last).top,
      greaterThan(tester.getRect(chips.first).top),
    );
    expect(tester.takeException(), isNull);
  });

  /// How big [text] is drawn against its own style (a `FittedBox` above
  /// it would shrink it).
  double drawnScale(WidgetTester tester, Finder text) =>
      tester.renderObject<RenderBox>(text).getTransformTo(null).storage[0];

  testWidgets('a tuned track\'s big amount is never scaled down: the art '
      'steps above it, then the compact form takes over ("tile amounts never '
      'scale")', (tester) async {
    // 4 digits beside the art don't fit a 110 dp tile: the art goes above.
    await pumpTile(tester, reward: const LoginGiftReward(coins: 99999));
    expect(find.text('99999'), findsOneWidget);
    expect(drawnScale(tester, find.text('99999')), 1);
    final art = tester.getRect(find.byType(UiArtImage));
    expect(
      art.bottom,
      lessThanOrEqualTo(tester.getRect(find.text('99999')).top + 0.01),
    );
    // Too wide even alone: the locale's compact form, at full size.
    // (A 360 dp phone's tile, 101 wide, at 1.3× text.)
    await pumpScreen(
      tester,
      tile(reward: const LoginGiftReward(coins: 100000), width: 101),
      size: const Size(360, 640),
      textScale: 1.3,
    );
    expect(find.text('100K'), findsOneWidget);
    expect(drawnScale(tester, find.text('100K')), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a tuned track: two rewards on one day stack a line each, at '
      'full size, never overflowing', (tester) async {
    await pumpTile(
      tester,
      reward: const LoginGiftReward(coins: 99999, hints: 99),
      textScale: 1.3,
    );
    expect(find.text('100K'), findsOneWidget);
    expect(find.text('99'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('one semantics node: "Day N, gift. State"', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpTile(tester, state: GiftTileState.done);
    expect(find.bySemanticsLabel('Day 2, 30 coins. Claimed'), findsOneWidget);
    await pumpTile(tester, day: 3, reward: const LoginGiftReward(hints: 1));
    expect(find.bySemanticsLabel('Day 3, 1 hint. Coming up'), findsOneWidget);
    await pumpTile(
      tester,
      day: 7,
      reward: const LoginGiftReward(coins: 100, slots: 1),
      state: GiftTileState.today,
      wide: true,
    );
    // Day 7's two phrases join with `gift_a11y_chest_contents`.
    expect(
      find.bySemanticsLabel('Day 7, 100 coins, 1 extra slot. Today’s gift'),
      findsOneWidget,
    );
    handle.dispose();
  });
}
