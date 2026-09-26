import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// tokens.json `shadow.pressed`: "buttons move down by (edge − 2) px and
/// the solid edge shrinks to 2 px".
void main() {
  test(
    'raised surfaces use the tokens: 5 px edge, 3 px travel, pressed stack',
    () {
      const style = SurfaceStyles.raised;
      expect(style.edge, 5);
      expect(style.travel, 3);
      expect(style.pressed, AppShadowTokens.pressed);
    },
  );

  test('button edges by size, and their travel', () {
    for (final size in TactileButtonSize.values) {
      final style = TactileButtonVariant.primary.surface(size.edge);
      expect(style.edge, size.edge, reason: size.name);
      expect(style.travel, size.edge - AppShadowTokens.pressedEdge);
    }
    expect(TactileButtonSize.large.edge, 6);
    expect(TactileButtonSize.compact.edge, 4);
  });

  test('a derived pressed stack shrinks the edge and tightens the drop', () {
    final style = TactileButtonVariant.primary.surface(6);
    final pressed = style.pressed;
    expect(pressed, hasLength(style.shadows.length));
    // Inset highlight unchanged.
    expect(pressed[0], style.shadows[0]);
    // Edge 6 → 2.
    expect(pressed[1].dy, AppShadowTokens.pressedEdge);
    expect(pressed[1].color, AppColorTokens.primaryEdge);
    // Drop 0 10 18 → 0 4 8.1 (Design System primary pressed: 0 4 8).
    expect(pressed[2].dy, closeTo(4, 0.001));
    expect(pressed[2].blur, closeTo(8.1, 0.001));
  });

  test('the primary style matches tokens.json shadow.primaryButton', () {
    expect(
      TactileButtonVariant.primary.surface(6).shadows,
      AppShadowTokens.primaryButton,
    );
    expect(
      TactileButtonVariant.ad.surface(6).shadows,
      AppShadowTokens.adButton,
    );
  });

  test('styles are cached per variant and edge', () {
    expect(
      identical(
        TactileButtonVariant.success.surface(5),
        TactileButtonVariant.success.surface(5),
      ),
      isTrue,
    );
  });

  test('the close button travels 2 px as its 3 px shade shrinks to 1', () {
    const style = SurfaceStyles.closeButton;
    expect(style.edge, 0);
    expect(style.travel, 2);
    expect(style.pressed.single.dy, -1);
  });

  test('flat surfaces have no travel', () {
    expect(SurfaceStyles.disabled.travel, 0);
    expect(SurfaceStyles.card.edge, 8);
  });

  test('NestyShadow equality drives repaint checks', () {
    const a = NestyShadow(color: AppColorTokens.primaryEdge, dy: 6);
    expect(a, const NestyShadow(color: AppColorTokens.primaryEdge, dy: 6));
    expect(a == a.copyWith(dy: 2), isFalse);
    expect(a.isSolidEdge, isTrue);
    expect(a.copyWith(blur: 4).isSolidEdge, isFalse);
    expect(a.copyWith(inset: true).isSolidEdge, isFalse);
  });
}
