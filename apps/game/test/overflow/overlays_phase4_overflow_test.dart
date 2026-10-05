import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/next_level_failed_card.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';
import 'package:nesty_game/features/gameplay/widgets/family_counter.dart';
import 'package:nesty_game/features/gameplay/widgets/gameplay_hud.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// Phase 4's overlays that no other overflow suite owns (lane O; m7-design
/// P4.7, architecture §7.2): the failed card in both tones (12.6, 9.3f), the
/// booster face at its limit with its "2/2" badge (12.9), the HUD with a
/// two-digit family counter (E.18) and a chest bump, at the five acceptance
/// sizes and both text scales, with 48 dp targets, labels and no cut text.
/// The win card, the chest, the splash errors, the generating card, the
/// intro loops and the tutorial's step 3 sweep the same grid in their own
/// suites.
void main() {
  setUpAll(loadBundledFonts);

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      final where =
          '${size.width.toInt()}×${size.height.toInt()} at $scale× '
          'text';

      for (final versus in [false, true]) {
        testWidgets('the failed card (${versus ? 'a race' : 'a level'}) fits '
            '$where', (tester) async {
          await pumpScreen(
            tester,
            NextLevelFailedCard(
              title: versus
                  ? testL10n.raceFailedTitle
                  : testL10n.gameplayFailedTitle,
              body: versus
                  ? testL10n.raceFailedBody
                  : testL10n.gameplayFailedBody,
              retryLabel: testL10n.retry,
              secondaryLabel: testL10n.nextLevelFailedHome,
              onRetry: () {},
              onSecondary: () {},
              versus: versus,
            ),
            size: size,
            textScale: scale,
          );
          await tester.pump(const Duration(milliseconds: 400));
          await expectAccessibleLayout(tester);
        });
      }

      testWidgets('the sunk +1 Slot face with "2/2" fits $where', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          Scaffold(
            body: Center(
              child: BoosterButton(
                kind: BoosterButtonKind.slot,
                icon: NestyIcons.addBox,
                label: '+Slot',
                width: BoosterBar.buttonWidth(size.width),
                badge: const BoosterBadge.limit(2, 2),
                spent: true,
                onPressed: () {},
              ),
            ),
          ),
          size: size,
          textScale: scale,
        );
        await expectAccessibleLayout(tester);
      });

      testWidgets('the HUD with "12 / 12" and a chest bump fits $where', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: GameplayHud(
                level: 56,
                tier: Tier.superhard,
                coins: 99999,
                setsDone: 12,
                setsTotal: 12,
                coinBump: 1,
                onPause: () {},
                library: FakeFxLibrary(),
              ),
            ),
          ),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
        expect(find.byType(FamilyCounter), findsOneWidget);
      });
    }
  }
}
