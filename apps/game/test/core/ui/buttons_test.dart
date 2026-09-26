import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/ui/nesty_ui.dart';

import 'support/ui_harness.dart';

/// The disabled, hidden and claimed states of design/README.md
/// "Components", and the controls built on the tactile surface.
void main() {
  setUpAll(loadBundledFonts);

  group('RewardedAdButton', () {
    testWidgets('is hidden when no ad can be shown (§9.1)', (tester) async {
      await pumpUi(
        tester,
        Column(
          children: [
            RewardedAdButton(
              label: '×3 coins',
              available: false,
              onPressed: () {},
            ),
            RewardedAdButton.compact(available: false, onPressed: () {}),
          ],
        ),
      );
      expect(find.text('×3 coins'), findsNothing);
      expect(find.byType(TactileSurface), findsNothing);
      for (final element in find.byType(RewardedAdButton).evaluate()) {
        expect((element.renderObject! as RenderBox).size, Size.zero);
      }
    });

    testWidgets('shows the ▶ box and its label when available', (tester) async {
      var pressed = 0;
      await pumpUi(
        tester,
        RewardedAdButton(label: '×3 coins', onPressed: () => pressed++),
        feedback: RecordingFeedback(),
      );
      expect(find.byType(AdPlayGlyph), findsOneWidget);
      await tester.tap(find.text('×3 coins'));
      await tester.pumpAndSettle();
      expect(pressed, 1);
    });

    testWidgets('claimed shows "Reward added" and is not a button', (
      tester,
    ) async {
      await pumpUi(
        tester,
        const RewardedAdButton(
          label: '×3 coins',
          claimed: true,
          available: false,
          onPressed: null,
        ),
      );
      expect(find.text('Reward added'), findsOneWidget);
      expect(find.byIcon(NestyIcons.checkCircle), findsOneWidget);
      expect(find.byType(TactileSurface), findsNothing);
    });

    testWidgets('compact is 44×40 with a screen-reader label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUi(
        tester,
        Center(child: RewardedAdButton.compact(onPressed: () {})),
      );
      expect(tester.getSize(find.byType(TactileSurface)), const Size(44, 40));
      expect(find.bySemanticsLabel('Watch an ad'), findsOneWidget);
      handle.dispose();
    });
  });

  group('CoinPriceButton', () {
    testWidgets('reads "60 coins" with a coin, and pays on tap', (
      tester,
    ) async {
      var pressed = 0;
      await pumpUi(
        tester,
        CoinPriceButton(price: 60, onPressed: () => pressed++),
        feedback: RecordingFeedback(),
      );
      expect(find.text('60 coins'), findsOneWidget);
      final coin = tester.widget<CoinIcon>(find.byType(CoinIcon));
      expect(coin.disabled, isFalse);
      await tester.tap(find.byType(CoinPriceButton));
      await tester.pumpAndSettle();
      expect(pressed, 1);
    });

    testWidgets("disabled (can't afford): grey coin, muted text, sunk face", (
      tester,
    ) async {
      final feedback = RecordingFeedback();
      await pumpUi(
        tester,
        const CoinPriceButton(price: 150, onPressed: null),
        feedback: feedback,
      );
      expect(tester.widget<CoinIcon>(find.byType(CoinIcon)).disabled, isTrue);
      expect(
        tester.widget<Text>(find.text('150 coins')).style?.color,
        AppColors.disabledText,
      );
      await tester.tap(find.byType(CoinPriceButton));
      await tester.pumpAndSettle();
      expect(feedback.activations, 0);
    });

    testWidgets('the compact chip shows the bare number', (tester) async {
      await pumpUi(
        tester,
        Center(child: CoinPriceChip(price: 150, onPressed: () {})),
      );
      expect(find.text('150'), findsOneWidget);
      expect(tester.getSize(find.byType(CoinPriceChip)).height, 40);
    });
  });

  group('TactileButton', () {
    testWidgets('fills its width, or hugs the label with expand: false', (
      tester,
    ) async {
      await pumpUi(
        tester,
        Column(
          children: [
            TactileButton(label: 'Resume', onPressed: () {}),
            TactileButton(label: 'Home', expand: false, onPressed: () {}),
          ],
        ),
      );
      final full = tester.getSize(find.widgetWithText(TactileButton, 'Resume'));
      final hug = tester.getSize(find.widgetWithText(TactileButton, 'Home'));
      expect(full.width, 390);
      expect(full.height, TactileButtonSize.large.height);
      expect(hug.width, lessThan(200));
    });

    testWidgets('a long label shrinks instead of overflowing', (tester) async {
      await pumpUi(
        tester,
        Center(
          child: SizedBox(
            width: 160,
            child: TactileButton(
              label: 'Weiterspielen mit einem sehr langen Wort',
              onPressed: () {},
            ),
          ),
        ),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('IconTactileButton', () {
    testWidgets('is 48 square by default with its semantics label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUi(
        tester,
        Center(
          child: IconTactileButton(
            icon: NestyIcons.pause,
            semanticLabel: 'Pause',
            onPressed: () {},
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(IconTactileButton)),
        const Size(48, 48),
      );
      expect(find.bySemanticsLabel('Pause'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('disabled mutes the glyph', (tester) async {
      await pumpUi(
        tester,
        const Center(
          child: IconTactileButton(
            icon: NestyIcons.settings,
            semanticLabel: 'Settings',
            onPressed: null,
          ),
        ),
      );
      final icon = tester.widget<Icon>(find.byIcon(NestyIcons.settings));
      expect(icon.color, AppColors.disabledText);
    });
  });

  group('NestyToggle', () {
    testWidgets('a tap asks for the opposite value, with feedback', (
      tester,
    ) async {
      final feedback = RecordingFeedback();
      bool? asked;
      await pumpUi(
        tester,
        Center(child: NestyToggle(value: true, onChanged: (v) => asked = v)),
        feedback: feedback,
      );
      await tester.tap(find.byType(NestyToggle));
      await tester.pumpAndSettle();
      expect(asked, isFalse);
      expect(feedback.activations, 1);
    });

    testWidgets('disabled ignores taps', (tester) async {
      final feedback = RecordingFeedback();
      await pumpUi(
        tester,
        const Center(child: NestyToggle(value: false, onChanged: null)),
        feedback: feedback,
      );
      await tester.tap(find.byType(NestyToggle));
      await tester.pumpAndSettle();
      expect(feedback.activations, 0);
    });

    testWidgets('the lottie slot replaces the static drawing', (tester) async {
      const key = Key('ui_toggle');
      await pumpUi(
        tester,
        Center(
          child: NestyToggle(
            value: false,
            onChanged: (_) {},
            lottie: const SizedBox.expand(key: key),
          ),
        ),
      );
      expect(tester.getSize(find.byKey(key)), NestyToggle.size);
    });

    testWidgets('screen readers get a toggled switch', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUi(
        tester,
        Center(
          child: NestyToggle(
            value: true,
            semanticLabel: 'Sound',
            onChanged: (_) {},
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(NestyToggle)),
        matchesSemantics(
          label: 'Sound',
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('pills', () {
    testWidgets('LevelPill shows the tier chip only for hard and super hard', (
      tester,
    ) async {
      await pumpUi(
        tester,
        const Column(
          children: [
            LevelPill(level: 3, tier: Tier.easy),
            LevelPill(level: 5, tier: Tier.medium),
            LevelPill(level: 6, tier: Tier.hard),
            LevelPill(level: 10, tier: Tier.superhard),
          ],
        ),
      );
      expect(find.text('HARD'), findsOneWidget);
      expect(find.text('SUPER HARD'), findsOneWidget);
      expect(find.text('Level 3'), findsOneWidget);
      for (final element in find.byType(LevelPill).evaluate()) {
        expect(
          (element.renderObject! as RenderBox).size.height,
          HudTokens.levelPillHeight,
        );
      }
    });

    testWidgets('LevelPill tells screen readers the tier', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUi(tester, const LevelPill(level: 56, tier: Tier.hard));
      expect(find.bySemanticsLabel('Level 56 · Hard'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('CoinPill groups digits; the Home pill opens the shop', (
      tester,
    ) async {
      var opened = 0;
      await pumpUi(
        tester,
        Column(
          children: [
            const CoinPill(coins: 6190),
            CoinPill(coins: 830, onAdd: () => opened++),
          ],
        ),
        feedback: RecordingFeedback(),
      );
      expect(find.text('6,190'), findsOneWidget);
      expect(find.byIcon(NestyIcons.add), findsOneWidget);
      await tester.tap(find.byIcon(NestyIcons.add));
      await tester.pumpAndSettle();
      expect(opened, 1);
    });
  });

  group('Scrim', () {
    testWidgets('blocks taps behind it; dismisses when asked', (tester) async {
      var behind = 0;
      var dismissed = 0;
      await pumpUi(
        tester,
        Stack(
          children: [
            Positioned.fill(child: GestureDetector(onTap: () => behind++)),
            Positioned.fill(child: Scrim(onDismiss: () => dismissed++)),
          ],
        ),
      );
      await tester.tapAt(const Offset(100, 100));
      await tester.pumpAndSettle();
      expect(behind, 0);
      expect(dismissed, 1);
    });
  });
}
