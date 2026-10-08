import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

void main() {
  group('EllipseGradientTransform (tokens v6 gradient.figurinePanel*)', () {
    const transform = EllipseGradientTransform(
      center: Alignment(0, -0.4),
      radiusX: 0.6,
      radiusY: 0.7,
    );

    test('scales the radius-0.5 circle into the CSS ellipse on any box', () {
      for (final box in const [
        Rect.fromLTWH(0, 0, 200, 100),
        Rect.fromLTWH(10, 20, 300, 300),
        Rect.fromLTWH(0, 0, 120, 360),
      ]) {
        final m = transform.transform(box);
        final c = const Alignment(0, -0.4).withinRect(box);
        final r = box.shortestSide * 0.5;
        // The circle's right and bottom points land on the ellipse's, CSS
        // `ellipse 60% 70% at 50% 30%`: rx = 0.6 w, ry = 0.7 h.
        final right = MatrixUtils.transformPoint(m, c + Offset(r, 0));
        final bottom = MatrixUtils.transformPoint(m, c + Offset(0, r));
        expect(right.dx, closeTo(c.dx + 0.6 * box.width, 1e-9));
        expect(right.dy, closeTo(c.dy, 1e-9));
        expect(bottom.dx, closeTo(c.dx, 1e-9));
        expect(bottom.dy, closeTo(c.dy + 0.7 * box.height, 1e-9));
        // The centre stays put.
        final centre = MatrixUtils.transformPoint(m, c);
        expect(centre.dx, closeTo(c.dx, 1e-9));
        expect(centre.dy, closeTo(c.dy, 1e-9));
      }
    });

    test('an empty box is the identity', () {
      expect(transform.transform(Rect.zero), Matrix4.identity());
    });

    test('the generated panels centre the transform on the gradient', () {
      for (final gradient in const [
        AppGradientTokens.figurinePanelEarned,
        AppGradientTokens.figurinePanelLocked,
      ]) {
        expect(gradient.radius, 0.5);
        final t = gradient.transform! as EllipseGradientTransform;
        expect(t.center, gradient.center);
        expect(t, transform);
      }
    });
  });
}
