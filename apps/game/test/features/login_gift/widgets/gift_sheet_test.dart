import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_rules.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/fx/chest/reward_flight.dart';
import 'package:nesty_game/features/login_gift/cubit/login_gift_cubit.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_chest_modal.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_day_tile.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_scrim.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_sheet.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_tally.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../support/gift_harness.dart';

/// The gift sheet (frames 13.2-13.5) and its claim, over a real
/// `LoginGiftCubit` on fakes.
void main() {
  setUpAll(loadBundledFonts);

  // No clock, timer or countdown wording (D92): "12:30", "3h", "45 m".
  final clockText = RegExp(r'\d+:\d\d|\d+\s?h\b|\d+\s?m\b');

  List<String> allText(WidgetTester tester) => [
    for (final text in tester.widgetList<Text>(find.byType(Text)))
      text.data ?? text.textSpan?.toPlainText() ?? '',
  ];

  void expectNoClockText(WidgetTester tester) {
    for (final line in allText(tester)) {
      expect(clockText.hasMatch(line), isFalse, reason: 'clock text: $line');
    }
  }

  List<String> tileLabels(WidgetTester tester) => [
    for (final tile in tester.widgetList<GiftDayTile>(find.byType(GiftDayTile)))
      tester.getSemantics(find.byWidget(tile)).label,
  ];

  GiftScrim scrimOf(WidgetTester tester) =>
      (tester
                  .widget<CustomPaint>(
                    find.byWidgetPredicate(
                      (w) => w is CustomPaint && w.painter is GiftScrimPainter,
                    ),
                  )
                  .painter!
              as GiftScrimPainter)
          .scrim;

  group('the look (13.3, 13.3b)', () {
    testWidgets('on 844 the sheet is 556 tall (top 288): grabber, "Daily '
        'gift" and its sub line, the grid, Day 7 and Claim', (tester) async {
      final rig = GiftRig();
      await rig.pump(tester);
      await openGiftSheet(tester);
      final sheet = tester.getRect(find.byKey(GiftSheet.surfaceKey));
      expect(sheet.height, closeTo(GiftSheetTokens.height, 1));
      expect(sheet.top, closeTo(844 - GiftSheetTokens.height, 1));
      final surface = tester.widget<NestySurface>(
        find.byKey(GiftSheet.surfaceKey),
      );
      expect(surface.style.gradient, GiftSheetTokens.face);
      expect(surface.style.shadows, GiftSheetTokens.shadow);
      expect(
        surface.radius,
        const BorderRadius.vertical(top: Radius.circular(34)),
      );
      expect(find.text('One gift a day, at your own pace.'), findsOneWidget);
      final title = tester.widget<FitText>(find.byType(FitText).first);
      expect(title.full, 'Daily gift');
      expect(title.short, 'Gifts');
      expect(title.minScale, 0.85);
      expect(title.style.fontSize, 30);
      // Days 1-6 three across, 10 apart; Day 7 full width under them.
      final tiles = find.byType(GiftDayTile);
      final day1 = tester.getRect(tiles.at(0));
      final day2 = tester.getRect(tiles.at(1));
      final day7 = tester.getRect(tiles.at(6));
      expect(day2.left - day1.right, closeTo(10, 0.01));
      expect(day1.height, 100);
      expect(day7.width, closeTo(350, 0.01));
      expect(
        tester.getSize(find.byKey(GiftSheet.claimKey)).height,
        greaterThanOrEqualTo(58),
      );
      // The scrim is the token's.
      expect(
        tester
            .widget<CustomPaint>(
              find.byWidgetPredicate(
                (w) => w is CustomPaint && w.painter is GiftScrimPainter,
              ),
            )
            .painter,
        isA<GiftScrimPainter>().having(
          (p) => p.color,
          'color',
          GiftSheetTokens.scrim,
        ),
      );
      await rig.dispose(tester);
    });

    testWidgets('on 16:9 it takes gift.short: 86 dp tiles, the 26/14 title '
        'and sub, 461 tall but for the 58 dp Claim', (tester) async {
      final rig = GiftRig();
      await rig.pump(
        tester,
        size: const Size(390, 693),
        padding: const EdgeInsets.only(top: 20),
      );
      await openGiftSheet(tester);
      final sheet = tester.getRect(find.byKey(GiftSheet.surfaceKey));
      // The frame's Claim is 54; the game's large button is 58.
      expect(sheet.height, closeTo(GiftShortTokens.height + 4, 1));
      expect(tester.getSize(find.byType(GiftDayTile).first).height, 86);
      expect(
        tester.widget<FitText>(find.byType(FitText).first).style.fontSize,
        26,
      );
      expect(
        tester
            .widget<Text>(find.text('One gift a day, at your own pace.'))
            .style!
            .fontSize,
        14,
      );
      await rig.dispose(tester);
    });

    test('coins fly one sprite per 10, 2 to 6', () {
      expect(GiftSheet.coinSpritesFor(20), 2);
      expect(GiftSheet.coinSpritesFor(40), 4);
      expect(GiftSheet.coinSpritesFor(100), 6);
      expect(GiftSheet.coinSpritesFor(5), 2);
      expect(GiftSheet.coinSpritesFor(5000), 6);
    });
  });

  group('the track', () {
    testWidgets('all seven days show what they pay before any claim', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final rig = GiftRig();
      await rig.pump(tester);
      await openGiftSheet(tester);
      expect(find.text('Daily gift'), findsWidgets);
      expect(tileLabels(tester), [
        'Day 1, 20 coins. Today’s gift',
        'Day 2, 30 coins. Coming up',
        'Day 3, 1 hint. Coming up',
        'Day 4, 40 coins. Coming up',
        'Day 5, 50 coins. Coming up',
        'Day 6, 1 hint. Coming up',
        'Day 7, 100 coins, 1 extra slot. Coming up',
      ]);
      expect(find.text('Claim'), findsOneWidget);
      expectNoClockText(tester);
      await rig.dispose(tester);
      handle.dispose();
    });

    testWidgets('later days are plain, not locked or greyed', (tester) async {
      final rig = GiftRig();
      await rig.pump(tester);
      await openGiftSheet(tester);
      final tiles = tester.widgetList<GiftDayTile>(find.byType(GiftDayTile));
      final surfaces = [
        for (final tile in tiles)
          tester
              .widget<NestySurface>(
                find.descendant(
                  of: find.byWidget(tile),
                  matching: find.byKey(GiftDayTile.faceKey),
                ),
              )
              .style,
      ];
      expect(surfaces.skip(1).map((s) => s.shadows).toSet(), {
        GiftTileTokens.laterShadow,
      });
      expect(surfaces.first.shadows, GiftTileTokens.todayShadow);
      final contents = tester.widgetList<Opacity>(
        find.descendant(
          of: find.byType(GiftDayTile),
          matching: find.byType(Opacity),
        ),
      );
      expect(contents.every((o) => o.opacity == 1), isTrue);
      expect(find.byIcon(NestyIcons.lock), findsNothing);
      await rig.dispose(tester);
    });

    testWidgets('a gap in the days keeps the day: no missed mark', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final rig = GiftRig(
        progress: LoginGiftProgress(
          claims: 3,
          lastClaim: giftToday.addDays(-5),
          latestSeen: giftToday.addDays(-5),
        ),
      );
      await rig.pump(tester);
      await openGiftSheet(tester);
      final labels = tileLabels(tester);
      expect(labels.take(3), everyElement(endsWith('Claimed')));
      expect(labels[3], endsWith('Today’s gift'));
      expect(labels.skip(4), everyElement(endsWith('Coming up')));
      expect(find.byIcon(IconUses.giftDayDone), findsNWidgets(3));
      await rig.dispose(tester);
      handle.dispose();
    });
  });

  group('the calm lines', () {
    testWidgets('claimed today: the line and Tomorrow, no Claim', (
      tester,
    ) async {
      final rig = GiftRig(
        progress: LoginGiftProgress(
          claims: 1,
          lastClaim: giftToday,
          latestSeen: giftToday,
        ),
      );
      await rig.pump(tester);
      await openGiftSheet(tester);
      expect(find.text('Today’s gift is yours.'), findsOneWidget);
      expect(find.text('Tomorrow: 30 coins'), findsOneWidget);
      expect(find.text('Claim'), findsNothing);
      expectNoClockText(tester);
      await rig.dispose(tester);
    });

    testWidgets('"Tomorrow: …" takes the short slot phrase when it would wrap '
        'past two lines', (tester) async {
      final rig = GiftRig(
        trackJson:
            '[{"coins":20},{"coins":30},{"hints":1},{"coins":40},'
            '{"coins":50},{"hints":1},'
            '{"coins":1000000,"hints":99,"slots":99}]',
        progress: LoginGiftProgress(
          claims: 6,
          lastClaim: giftToday,
          latestSeen: giftToday,
        ),
      );
      await rig.pump(tester, size: const Size(360, 844), textScale: 2);
      await openGiftSheet(tester);
      final line = allText(
        tester,
      ).firstWhere((t) => t.startsWith('Tomorrow'), orElse: () => '');
      expect(line, contains('99 slots'));
      expect(line, isNot(contains('extra')));
      await rig.dispose(tester);
    });

    testWidgets('waiting (clock back): Next gift, no Claim', (tester) async {
      final rig = GiftRig(
        progress: LoginGiftProgress(
          claims: 1,
          lastClaim: giftToday.addDays(1),
          latestSeen: giftToday.addDays(1),
        ),
      );
      await rig.pump(tester);
      await openGiftSheet(tester);
      expect(find.text('Next gift: 30 coins'), findsOneWidget);
      expect(find.text('Claim'), findsNothing);
      expect(find.text('Today’s gift is yours.'), findsNothing);
      expectNoClockText(tester);
      await rig.dispose(tester);
    });
  });

  group('claiming Days 1-6', () {
    testWidgets('pays at once, the sheet turns claimed, the pill ticks up '
        'to the new balance as the coins land', (tester) async {
      final rig = GiftRig();
      await rig.pump(tester);
      await openGiftSheet(tester);
      expect(rig.shown(tester), 100);

      await tester.tap(find.byKey(GiftSheet.claimKey));
      await tester.pump();
      expect(rig.save.coins, 120, reason: 'paid at once');
      expect(rig.shown(tester), 100, reason: 'the pill waits for the coins');
      expect(find.byKey(RewardFlight.trailKey), findsOneWidget);
      expect(find.text('Today’s gift is yours.'), findsOneWidget);
      expect(find.text('Tomorrow: 30 coins'), findsOneWidget);
      // Claim cross-fades out over 200 ms.
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byKey(GiftSheet.claimKey), findsNothing);
      expect(find.byType(GiftSheet), findsOneWidget, reason: 'stays open');

      await tester.pump(const Duration(milliseconds: 350));
      expect(rig.shown(tester), inInclusiveRange(100, 120));
      await tester.pump(const Duration(seconds: 2));
      expect(rig.shown(tester), 120);
      expect(rig.cubit.state.data!.coinsCap, isNull);
      await rig.dispose(tester);
    });

    testWidgets('13.5: gift_claim and a light haptic on Claim; the scrim '
        'opens round the pill; coins and the ring as the first coin lands; '
        'both go 240 ms after the last', (tester) async {
      final feedback = RecordingGiftCues();
      final rig = GiftRig(feedback: feedback);
      await rig.pump(tester);
      await openGiftSheet(tester);
      await tester.tap(find.byKey(GiftSheet.claimKey));
      await tester.pump();
      expect(feedback.sounds, [SoundEffect.giftClaim]);
      expect(feedback.haptics, [HapticPattern.giftClaim]);
      await tester.pump(const Duration(milliseconds: 200));
      final scrim = scrimOf(tester);
      expect(scrim.pill, rig.pillRect());
      expect(scrim.holeOpen, 1);
      expect(scrim.ring, 0, reason: 'not before the first coin lands');
      expect(
        GiftScrim.holeOf(scrim.pill!).height,
        GiftClaimTokens.coinsPillHole.height,
      );
      // 20 coins: two sprites; the first lands at 700 ms.
      // Frame by frame to just past the first landing (700 ms).
      for (var ms = 200; ms < 740; ms += 16) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(feedback.sounds, [SoundEffect.giftClaim, SoundEffect.coins]);
      expect(scrimOf(tester).ring, greaterThan(0));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 300));
      expect(scrimOf(tester).ring, 0);
      expect(scrimOf(tester).holeOpen, 0);
      expect(rig.shown(tester), 120);
      await rig.dispose(tester);
    });

    testWidgets('13.5: the screen reader hears the claim once it lands', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final rig = GiftRig();
      await rig.pump(tester);
      await openGiftSheet(tester);
      await tester.tap(find.byKey(GiftSheet.claimKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.bySemanticsLabel(
          'Gift claimed: 20 coins. Today’s gift is yours. Tomorrow: 30 coins',
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 2));
      await rig.dispose(tester);
      handle.dispose();
    });

    testWidgets('reduce motion: no flight, the pill updates at once', (
      tester,
    ) async {
      final rig = GiftRig();
      await rig.pump(tester, reduceMotion: true);
      await openGiftSheet(tester);
      await tester.tap(find.byKey(GiftSheet.claimKey));
      await tester.pump();
      expect(find.byKey(RewardFlight.trailKey), findsNothing);
      expect(rig.save.coins, 120);
      expect(rig.shown(tester), 120);
      expect(rig.cubit.state.data!.coinsCap, isNull);
      expect(find.text('Today’s gift is yours.'), findsOneWidget);
      // 13.5r: the pill is ringed for 400 ms, at once.
      expect(scrimOf(tester).ring, 1);
      await tester.pump(const Duration(milliseconds: 450));
      expect(scrimOf(tester).ring, 0);
      await rig.dispose(tester);
    });

    testWidgets('a hint day pays the hint and flies it to the tally, no '
        'coins', (tester) async {
      final rig = GiftRig(
        progress: LoginGiftProgress(
          claims: 2,
          lastClaim: giftToday.addDays(-1),
          latestSeen: giftToday.addDays(-1),
        ),
      );
      await rig.pump(tester);
      final hintsBefore = rig.save.document.inventory.hint;
      await openGiftSheet(tester);
      await tester.tap(find.byKey(GiftSheet.claimKey));
      await tester.pump();
      expect(rig.save.document.inventory.hint, hintsBefore + 1);
      expect(rig.save.coins, 100);
      // One sprite (the hint) flies, with its trail, to the tally.
      expect(find.byKey(RewardFlight.trailKey), findsOneWidget);
      expect(find.byKey(GiftTally.boxKey), findsOneWidget);
      expect(rig.shown(tester), 100);
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byKey(GiftTally.tagKey), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
      expect(find.text('${hintsBefore + 1}'), findsOneWidget);
      // The tally lives in the root overlay, above every page's Material: its
      // text must not fall back to the debug underline (the m7-5 iOS run's
      // g_42 showed one).
      for (final text in ['+1', '${hintsBefore + 1}']) {
        final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
        expect(
          paragraph.text.style?.decoration ?? TextDecoration.none,
          TextDecoration.none,
          reason: text,
        );
      }
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(GiftTally.boxKey), findsNothing);
      await rig.dispose(tester);
    });

    testWidgets('closing the sheet mid-flight does not leave the pill held', (
      tester,
    ) async {
      final rig = GiftRig();
      await rig.pump(tester);
      await openGiftSheet(tester);
      await tester.tap(find.byKey(GiftSheet.claimKey));
      await tester.pump(const Duration(milliseconds: 100));
      // The player drags the sheet away (a pop, as the scrim tap is).
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(GiftSheet), findsNothing);
      expect(rig.cubit.state.data!.coinsCap, isNull);
      await tester.pump();
      expect(rig.shown(tester), 120);
      await rig.dispose(tester);
    });
  });

  group('claiming Day 7', () {
    GiftRig day7() => GiftRig(
      progress: LoginGiftProgress(
        claims: 6,
        lastClaim: giftToday.addDays(-1),
        latestSeen: giftToday.addDays(-1),
      ),
    );

    testWidgets('pays at once, closes the sheet and opens the chest with 100 '
        'coins and 1 slot; Collect closes it and the pill ends at the new '
        'balance', (tester) async {
      final rig = day7();
      await rig.pump(tester);
      final slotsBefore = rig.save.document.inventory.slot;
      await openGiftSheet(tester);
      expect(find.text('Claim'), findsOneWidget);

      await tester.tap(find.byKey(GiftSheet.claimKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(rig.save.coins, 200, reason: 'paid before the chest opens');
      expect(rig.save.document.inventory.slot, slotsBefore + 1);
      expect(find.byType(GiftSheet), findsNothing);
      expect(find.byType(GiftChestModal), findsOneWidget);
      expect(find.text('Day 7 gift'), findsOneWidget);
      expect(find.text('+100 coins'), findsOneWidget);
      expect(find.text('+1 slot'), findsOneWidget);
      expect(rig.shown(tester), 100, reason: 'held until the coins land');

      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 1500));
      expect(
        tester
            .widget<ChestRewardSequence>(find.byType(ChestRewardSequence))
            .cardTop,
        ChestCardTokens.cardTopDay7,
      );
      // The house orange ribbon, no gift tint.
      expect(
        tester.widget<RibbonTitle>(find.byType(RibbonTitle)).gradient,
        AppGradientTokens.primary,
      );
      await tester.tap(find.text('Collect'));
      await tester.pump(const Duration(milliseconds: 300));
      // 13.6d: the slot flies to the tally under the pill.
      expect(find.byKey(GiftTally.boxKey), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('${slotsBefore + 1}'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(GiftChestModal), findsNothing);
      expect(find.byKey(GiftTally.boxKey), findsNothing);
      expect(find.byType(ChestRewardSequence), findsNothing);
      expect(rig.shown(tester), 200);
      expect(rig.cubit.state.data!.coinsCap, isNull);
      expect(rig.cubit.state.data!.phase, LoginGiftPhase.claimed);
      expect(rig.cubit.state.data!.doneDays, LoginGiftRules.trackLength);
      await rig.dispose(tester);
    });

    testWidgets('reduce motion: the same chest, the pill is whole after '
        'Collect', (tester) async {
      final rig = day7();
      await rig.pump(tester, reduceMotion: true);
      await openGiftSheet(tester);
      await tester.tap(find.byKey(GiftSheet.claimKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('+1 slot'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Collect'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(GiftChestModal), findsNothing);
      expect(rig.shown(tester), 200);
      await rig.dispose(tester);
    });
  });
}
