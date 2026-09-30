import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/widgets/chest_icon.dart';
import 'package:nesty_game/features/daily/widgets/daily_chest_modal.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';

import '../../core/ui/support/ui_harness.dart';
import '../support/screen_harness.dart';

/// Frame 5.6 (NestyMenus `isChest`): the day-7 chest modal wears the streak
/// ribbon, not the primary one every other modal uses. It now gets the same
/// arrival/idle/open/collect moment as the milestone chest ("in this too we
/// need to have animations, gamification", m7-design "owner-chest" lane):
/// closed with its coins shown first, then Open reveals the lid tilted
/// back, the gold glow and the seven spilled coins under "Your chest is
/// open." (FIDELITY-12).
void main() {
  setUpAll(loadBundledFonts);

  Future<void> pumpModal(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) => pumpScreen(
    tester,
    Scaffold(body: DailyChestModal(coins: 300, onCollect: () {})),
    size: size,
    textScale: textScale,
  );

  /// Past arrival (~600 ms): idle, closed, Open live. Never
  /// `pumpAndSettle` here: idle's breath repeats until Open is tapped.
  Future<void> toIdle(WidgetTester tester) => tester.pump(
    const Duration(milliseconds: ChestRewardSequence.arrivalMs + 50),
  );

  testWidgets('closed: the coins are already shown, before it opens', (
    tester,
  ) async {
    await pumpModal(tester);
    await toIdle(tester);
    // Frame 5.6: closed, the contents shown first, then Open (spec-prop
    // §1.1 rule 2).
    expect(find.text('+300 coins'), findsOneWidget);
    expect(
      find.text('Seven days in a row. Here’s what’s inside.'),
      findsOneWidget,
    );
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Collect'), findsNothing);
    expect(find.text('Double it'), findsNothing); // TODO(M6): the ad.
  });

  testWidgets('the ribbon is the streak ribbon (#FFB27A → #F2702B, edge '
      '#B8501A), carrying the title', (tester) async {
    await pumpModal(tester);
    // `find.byType` matches the exact runtime type, and the sequence's own
    // ribbon drop-in is a `RibbonTitle` subclass (m7-design chest sequence
    // step 1): a predicate finds it by its actual (super)type instead.
    final ribbon = tester.widget<RibbonTitle>(
      find.byWidgetPredicate((w) => w is RibbonTitle),
    );
    expect(ribbon.title, '7-day streak!');
    expect(ribbon.gradient, AppGradientTokens.streak);
    expect(ribbon.edgeColor, AppColorTokens.streakEdge);
  });

  testWidgets('Open (frame 5.6b): the contents stay, Collect replaces '
      'Open', (tester) async {
    await pumpModal(tester);
    await toIdle(tester);
    await tester.tap(find.text('Open'));
    // The open state's gold rays turn for as long as the card is up, so
    // this pumps the wiggle and the burst rather than `pumpAndSettle`.
    await tester.pump(
      const Duration(
        milliseconds:
            ChestRewardSequence.wiggleMs + ChestRewardSequence.burstMs + 100,
      ),
    );

    expect(find.text('+300 coins'), findsOneWidget);
    expect(
      find.text('Seven days in a row. Here’s what’s inside.'),
      findsOneWidget,
    );
    expect(find.text('Collect'), findsOneWidget);
    expect(find.text('Open'), findsNothing);
  });

  testWidgets('Collect calls back once, with nothing to fly to (no HUD on '
      'the Daily screen): it bursts and counts up in place', (tester) async {
    var collected = 0;
    await pumpScreen(
      tester,
      Scaffold(body: DailyChestModal(coins: 300, onCollect: () => collected++)),
    );
    await toIdle(tester);
    await tester.tap(find.text('Open'));
    await tester.pump(
      const Duration(
        milliseconds:
            ChestRewardSequence.wiggleMs + ChestRewardSequence.burstMs + 100,
      ),
    );
    await tester.tap(find.text('Collect'));
    await tester.pump(
      const Duration(
        milliseconds:
            ChestRewardSequence.collectFlightMs +
            ChestRewardSequence.coinSpriteCount *
                ChestRewardSequence.collectStaggerMs +
            ChestRewardSequence.exitFadeMs +
            400,
      ),
    );
    expect(collected, 1);
  });

  testWidgets('the Daily row keeps the closed chest', (tester) async {
    await pumpScreen(tester, const Center(child: ChestIcon()));
    expect(tester.widget<ChestIcon>(find.byType(ChestIcon)).open, isFalse);
    expect(find.byType(CoinIcon), findsNothing);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits a ${size.width.toInt()}×${size.height.toInt()} '
          'phone at ${scale}x text', (tester) async {
        await pumpModal(tester, size: size, textScale: scale);
        await toIdle(tester);
        expectNoLayoutErrors(tester);
      });
    }
  }

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets('open fits a ${size.width.toInt()}×${size.height.toInt()} '
          'phone at ${scale}x text', (tester) async {
        await pumpModal(tester, size: size, textScale: scale);
        await toIdle(tester);
        await tester.tap(find.text('Open'));
        await tester.pump(
          const Duration(
            milliseconds:
                ChestRewardSequence.wiggleMs +
                ChestRewardSequence.burstMs +
                100,
          ),
        );
        expectNoLayoutErrors(tester);
      });
    }
  }
}
