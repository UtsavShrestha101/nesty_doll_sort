import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/fx/chest/reward_flight.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

/// The extra-slot chip the daily gift's Day 7 chest adds to the shared chest
/// moment (plan-login-gift section 7.5b). The milestone and Daily chests pass
/// no slots, so their chips are unchanged (their own tests cover them).
void main() {
  setUpAll(loadBundledFonts);

  Widget sequence({int coins = 100, int hints = 0, int slots = 1}) =>
      ChestRewardSequence(
        title: 'Day 7 gift',
        body: 'Day 7 body',
        coins: coins,
        hints: hints,
        slots: slots,
        library: FakeFxLibrary(),
        onCollect: () {},
      );

  Future<void> toIdle(WidgetTester tester) => tester.pump(
    const Duration(milliseconds: ChestRewardSequence.arrivalMs + 50),
  );

  testWidgets('shows a coin chip and a slot chip, with the promised amounts '
      'before it opens', (tester) async {
    await pumpScreen(tester, sequence());
    await toIdle(tester);
    expect(find.text('+100 coins'), findsOneWidget);
    expect(find.text('+1 slot'), findsOneWidget);
    final chips = tester.widgetList<RewardChip>(find.byType(RewardChip));
    expect(chips.map((c) => c.kind), [
      RewardChipKind.coin,
      RewardChipKind.slot,
    ]);
    // `chest.slotChip`: the disc is ui/chest/chip_slot.svg at 30.
    final disc = tester.widget<UiArtImage>(
      find.descendant(
        of: find.byWidget(chips.last),
        matching: find.byType(UiArtImage),
      ),
    );
    expect(disc.art, UiArt.chipSlot);
    expect(disc.size, const Size.square(ChestSlotChipTokens.discSize));
  });

  testWidgets('the slot chip falls back to "+1" only when "+1 slot" can\'t '
      'fit its row at 0.85 (copy.md "Short forms")', (tester) async {
    Future<void> chipIn(double width) => pumpScreen(
      tester,
      Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: const Wrap(
              children: [
                RewardChip(
                  kind: RewardChipKind.slot,
                  label: '+1 slot',
                  short: '+1',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await chipIn(300);
    expect(find.text('+1 slot'), findsOneWidget);
    await chipIn(100);
    expect(find.text('+1'), findsOneWidget);
    expect(find.bySemanticsLabel('+1 slot'), findsOneWidget);
  });

  testWidgets('Collect flies the slot to slotTarget after onCollectStart, '
      'and onSlotLanded fires as it lands (13.6d)', (tester) async {
    final events = <String>[];
    var targetAsked = false;
    await pumpScreen(
      tester,
      ChestRewardSequence(
        title: 'Day 7 gift',
        body: 'Day 7 body',
        coins: 100,
        slots: 1,
        cardTop: ChestCardTokens.cardTopDay7,
        library: FakeFxLibrary(),
        coinTarget: () => const Rect.fromLTWH(16, 66, 110, 42),
        slotTarget: () {
          targetAsked = true;
          expect(events, contains('start'));
          return const Rect.fromLTWH(21, 125, 26, 26);
        },
        onCollectStart: () => events.add('start'),
        onSlotLanded: () => events.add('slot'),
        onCollect: () => events.add('collect'),
      ),
    );
    await toIdle(tester);
    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.tap(find.text('Collect'));
    await tester.pump();
    expect(targetAsked, isTrue);
    expect(find.byKey(RewardFlight.trailKey), findsNWidgets(2));
    await tester.pump(const Duration(milliseconds: 700));
    expect(events, containsAllInOrder(['start', 'slot']));
    await tester.pump(const Duration(milliseconds: 600));
    expect(events.last, 'collect');
  });

  testWidgets('cardTop places the card: the gift\'s Day 7 at 176 with the '
      'house ribbon', (tester) async {
    await pumpScreen(
      tester,
      ChestRewardSequence(
        title: 'Day 7 gift',
        body: 'Day 7 body',
        coins: 100,
        slots: 1,
        cardTop: ChestCardTokens.cardTopDay7,
        library: FakeFxLibrary(),
        onCollect: () {},
      ),
    );
    await toIdle(tester);
    final card = tester.getRect(find.byKey(ChestRewardSequence.cardKey));
    final milestone = tester.getRect(find.byType(RibbonTitle));
    expect(
      tester.widget<RibbonTitle>(find.byType(RibbonTitle)).gradient,
      AppGradientTokens.primary,
    );
    await pumpScreen(tester, sequence());
    await toIdle(tester);
    final atDefault = tester.getRect(find.byKey(ChestRewardSequence.cardKey));
    expect(
      card.top - atDefault.top,
      closeTo(ChestCardTokens.cardTopDay7 - ChestCardTokens.cardTop, 0.5),
    );
    expect(milestone.width, greaterThan(0));
  });

  testWidgets('the contents are spoken with the slot', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, sequence());
    await toIdle(tester);
    expect(
      // `gift_a11y_chest_contents` in `a11y_chest_contents`.
      find.bySemanticsLabel('Chest. Inside: 100 coins, 1 extra slot.'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('hints and slots together are both spoken and shown', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, sequence(hints: 1, slots: 2));
    await toIdle(tester);
    expect(find.byType(RewardChip), findsNWidgets(3));
    expect(find.text('+2 slots'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Chest. Inside: 100 coins, 1 hint, 2 extra slots.'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('no slots, no slot chip (the milestone and Daily chests)', (
    tester,
  ) async {
    await pumpScreen(tester, sequence(slots: 0, hints: 1));
    await toIdle(tester);
    expect(find.text('+1 slot'), findsNothing);
    expect(find.byType(RewardChip), findsNWidgets(2));
  });
}
