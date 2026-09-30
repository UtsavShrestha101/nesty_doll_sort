import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import 'support/ui_harness.dart';

/// design/README.md "Booster button": 80×58, badges at the top-right corner
/// (NestyBoard: count `right:-6; top:-7`, ad `-7, -8`, coin `-9, -9`), and a
/// glow drawn behind it (the `ui_booster_glow` slot, 130×110, centred).
void main() {
  setUpAll(loadBundledFonts);

  Future<void> pumpBooster(
    WidgetTester tester, {
    BoosterBadge? badge,
    Widget? glow,
    VoidCallback? onPressed,
    RecordingFeedback? feedback,
    bool spent = false,
    String? spentLabel,
    String? gainTag,
    int badgeBump = 0,
  }) => pumpUi(
    tester,
    Center(
      child: BoosterButton(
        icon: NestyIcons.lightbulb,
        label: 'Hint',
        badge: badge,
        glow: glow,
        onPressed: onPressed,
        spent: spent,
        spentLabel: spentLabel,
        gainTag: gainTag,
        badgeBump: badgeBump,
      ),
    ),
    feedback: feedback ?? RecordingFeedback(),
  );

  Rect buttonRect(WidgetTester tester) =>
      tester.getRect(find.byType(TactileSurface));

  Rect badgeRect(WidgetTester tester) =>
      tester.getRect(find.byType(BoosterBadgeView));

  testWidgets('is 80×58', (tester) async {
    await pumpBooster(tester, onPressed: () {});
    expect(tester.getSize(find.byType(BoosterButton)), const Size(80, 58));
  });

  for (final (badge, dx, dy) in [
    (const BoosterBadge.count(2), 6.0, -7.0),
    (const BoosterBadge.ad(), 7.0, -8.0),
    (const BoosterBadge.coin(20), 9.0, -9.0),
    (const BoosterBadge.infinite(), 6.0, -7.0),
  ]) {
    testWidgets('${badge.runtimeType} sits at the top-right, ($dx, $dy)', (
      tester,
    ) async {
      await pumpBooster(tester, badge: badge, onPressed: () {});
      final button = buttonRect(tester);
      final badgeBox = badgeRect(tester);
      expect(badgeBox.right - button.right, closeTo(dx, 0.01));
      expect(badgeBox.top - button.top, closeTo(dy, 0.01));
      expect(badgeBox.height, closeTo(22, 0.01));
      // The badge doesn't change the button's own size.
      expect(tester.getSize(find.byType(BoosterButton)), const Size(80, 58));
    });
  }

  testWidgets('a count badge is at least 22 wide and shows the number', (
    tester,
  ) async {
    await pumpBooster(tester, badge: const BoosterBadge.count(3));
    expect(find.text('3'), findsOneWidget);
    expect(badgeRect(tester).width, greaterThanOrEqualTo(22));
  });

  testWidgets('a coin badge shows its price', (tester) async {
    await pumpBooster(tester, badge: const BoosterBadge.coin(20));
    expect(find.text('20'), findsOneWidget);
    expect(find.byType(CoinIcon), findsOneWidget);
  });

  testWidgets('relaxed mode\'s infinite badge is the all_inclusive glyph in '
      'the pink count bubble (frame 10.9; E6)', (tester) async {
    await pumpBooster(tester, badge: const BoosterBadge.infinite());
    expect(find.byIcon(IconUses.undoUnlimited), findsOneWidget);
    expect(find.text('∞'), findsNothing);
    final bubble = tester.widget<NestySurface>(
      find.ancestor(
        of: find.byIcon(IconUses.undoUnlimited),
        matching: find.byType(NestySurface),
      ),
    );
    expect(bubble.style.color, AppColorTokens.badge);
  });

  testWidgets('a spent booster (frame 12.9): the sunk face, the muted glyph '
      'and label, "2/2", still tappable', (tester) async {
    var taps = 0;
    await pumpBooster(
      tester,
      badge: const BoosterBadge.limit(2, 2),
      spent: true,
      spentLabel: '+Slot, 2 of 2 used',
      onPressed: () => taps++,
    );
    expect(find.text('2/2'), findsOneWidget);
    final face = tester.widget<TactileSurface>(find.byType(TactileSurface));
    expect(face.style, BoosterButton.spentStyle);
    expect(face.style.color, const Color(0xFFE8DCCB));
    expect(
      tester.widget<Icon>(find.byType(Icon)).color,
      BoosterButton.spentColor,
    );
    await tester.tap(find.byType(TactileSurface));
    expect(taps, 1);
  });

  testWidgets('a spent booster reads "+Slot, 2 of 2 used" to a screen '
      'reader', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpBooster(
      tester,
      badge: const BoosterBadge.limit(2, 2),
      spent: true,
      spentLabel: '+Slot, 2 of 2 used',
      onPressed: () {},
    );
    expect(find.bySemanticsLabel('+Slot, 2 of 2 used'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the gain tag and the badge bump (frame 10.3d)', (tester) async {
    await pumpBooster(
      tester,
      badge: const BoosterBadge.count(3),
      gainTag: '+1',
      badgeBump: 0,
      onPressed: () {},
    );
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('the glow slot is 130×110, centred behind the button', (
    tester,
  ) async {
    const glowKey = Key('glow');
    await pumpBooster(
      tester,
      glow: const ColoredBox(key: glowKey, color: Color(0x80FFE08A)),
      onPressed: () {},
    );
    final glow = tester.getRect(find.byKey(glowKey));
    final button = buttonRect(tester);
    expect(glow.size, BoosterButton.glowSize);
    expect(glow.center, button.center);
    // Behind: painted before the button, and it takes no taps.
    final stack = tester.widget<Stack>(
      find.descendant(
        of: find.byType(BoosterButton),
        matching: find.byType(Stack),
      ),
    );
    expect(stack.children.first, isA<Positioned>());
    expect(
      find.ancestor(
        of: find.byKey(glowKey),
        matching: find.byType(IgnorePointer),
      ),
      findsWidgets,
    );
  });

  testWidgets('a tap on the badge still presses the button', (tester) async {
    var pressed = 0;
    await pumpBooster(
      tester,
      badge: const BoosterBadge.count(2),
      onPressed: () => pressed++,
    );
    final button = buttonRect(tester);
    // The part of the badge that overlaps the button.
    await tester.tapAt(button.topRight + const Offset(-4, 4));
    await tester.pumpAndSettle();
    expect(pressed, 1);
  });

  testWidgets('disabled: no press, no feedback, faded content', (tester) async {
    final feedback = RecordingFeedback();
    await pumpBooster(
      tester,
      badge: const BoosterBadge.count(2),
      feedback: feedback,
    );
    await tester.tap(find.byType(BoosterButton));
    await tester.pumpAndSettle();
    expect(feedback.activations, 0);
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Hint'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, lessThan(1));
    // The badge stays readable.
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('screen readers hear the label and the badge', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpBooster(
      tester,
      badge: const BoosterBadge.count(2),
      onPressed: () {},
    );
    expect(find.bySemanticsLabel('Hint, 2 left'), findsOneWidget);
    await pumpBooster(tester, badge: const BoosterBadge.coin(20));
    expect(find.bySemanticsLabel('Hint, 20 coins'), findsOneWidget);
    await pumpBooster(tester, badge: const BoosterBadge.ad());
    expect(
      find.bySemanticsLabel('Hint, watch an ad for one more'),
      findsOneWidget,
    );
    await pumpBooster(tester, badge: const BoosterBadge.infinite());
    expect(find.bySemanticsLabel('Hint, unlimited'), findsOneWidget);
    await pumpBooster(tester, badge: const BoosterBadge.limit(2, 2));
    expect(find.bySemanticsLabel('Hint, 2 of 2 used'), findsOneWidget);
    handle.dispose();
  });
}
