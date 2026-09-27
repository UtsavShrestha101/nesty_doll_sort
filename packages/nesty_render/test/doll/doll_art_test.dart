// DollArt's shared geometry (spec §12.2) against the tokens it follows.
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

void main() {
  test('the reveal wipe grows from the doll centre, art (256, 476): owner '
      'decision 3d, tokens motion.reveal.type', () {
    expect(DollArt.revealCenter, const Offset(256, 476));
    expect(DollArt.revealCenter, MotionTokens.revealWipeCenter);
    // 62 % down the artboard, as the motion prototype's `at 50% 62%`.
    expect(DollArt.revealCenter.dx, DollArt.width / 2);
    expect(DollArt.revealCenter.dy / DollArt.height, closeTo(0.62, 0.001));
  });
}
