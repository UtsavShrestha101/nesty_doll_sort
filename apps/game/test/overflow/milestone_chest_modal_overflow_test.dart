import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/gameplay/overlays/milestone_chest_modal.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow", §9, §15.4): the milestone
/// chest modal, closed and open, at the five acceptance sizes and both text
/// scales. New since the contracts stage landed (no dedicated widget test
/// exists yet; this only sweeps layout, not behaviour).
void main() {
  setUpAll(loadBundledFonts);

  const chest = ChestGrant(
    source: ChestSource.campaign,
    number: 10,
    coins: 100,
    hints: 1,
  );

  const bonusChest = ChestGrant(
    source: ChestSource.bonus,
    number: 120,
    coins: 100,
    hints: 1,
  );

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets('closed fits ${size.width.toInt()}×${size.height.toInt()} at '
          '$scale× text', (tester) async {
        await pumpScreen(
          tester,
          MilestoneChestModal(chest: chest, onCollect: () {}),
          size: size,
          textScale: scale,
        );
        // Past arrival (~600 ms): idle, closed, Open live. Never
        // `pumpAndSettle` here: idle's breath repeats until Open is
        // tapped.
        await tester.pump(
          const Duration(milliseconds: ChestRewardSequence.arrivalMs + 50),
        );
        await expectAccessibleLayout(tester);
      });

      testWidgets('open (a bonus level) fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          MilestoneChestModal(chest: bonusChest, onCollect: () {}),
          size: size,
          textScale: scale,
        );
        await tester.pump(
          const Duration(milliseconds: ChestRewardSequence.arrivalMs + 50),
        );
        await tester.tap(find.text(testL10n.chestOpen));
        // The wiggle then the burst are bounded `AnimationController`s
        // (never repeating), so `pumpAndSettle` is safe once Open has
        // been tapped (it stops the idle breath synchronously).
        await tester.pumpAndSettle();
        await expectAccessibleLayout(tester);
      });
    }
  }
}
