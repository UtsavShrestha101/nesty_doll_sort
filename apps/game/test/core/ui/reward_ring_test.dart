import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import '../../features/support/screen_harness.dart';

/// m7-4 1.7 (`motion.chest.collect.pillRing` and `hintRing`): the chest
/// flights' ring round the coin pill and the Hint badge.
void main() {
  Widget pill({required bool visible}) => Center(
    child: RewardRing.pill(
      visible: visible,
      child: const SizedBox(key: Key('target'), width: 104, height: 48),
    ),
  );

  AnimatedOpacity fade(WidgetTester tester) => tester.widget<AnimatedOpacity>(
    find.ancestor(
      of: find.byKey(RewardRing.ringKey),
      matching: find.byType(AnimatedOpacity),
    ),
  );

  testWidgets('the pill ring is the pill\'s own rectangle with the token '
      'shadows, in over 80 ms and out over 240 ms, layout unchanged', (
    tester,
  ) async {
    await pumpScreen(tester, pill(visible: false));
    final size = tester.getSize(find.byKey(const Key('target')));
    expect(
      find.byKey(RewardRing.ringKey),
      findsNothing,
      reason: 'a ring that never showed adds nothing to the tree',
    );

    await pumpScreen(tester, pill(visible: true));
    expect(fade(tester).opacity, 1);
    expect(fade(tester).duration, RewardRing.fadeIn);
    expect(RewardRing.fadeIn.inMilliseconds, 80);
    final ring = find.byKey(RewardRing.ringKey);
    final painter =
        tester.widget<CustomPaint>(ring).painter! as RingGlowPainter;
    expect(painter.circle, isFalse);
    expect(painter.shadows, const [
      NestyShadow(color: Color(0xCCFFD66E), spread: 4),
      NestyShadow(color: Color(0x99FFCD50), blur: 18, spread: 6),
    ]);
    expect(
      tester.getRect(ring),
      tester.getRect(find.byKey(const Key('target'))),
      reason: 'the shadows (4 dp spread) draw outside the pill\'s own box',
    );
    expect(tester.getSize(find.byKey(const Key('target'))), size);

    // Hidden again: it fades out over 240 ms rather than vanishing.
    await pumpScreen(tester, pill(visible: false));
    expect(fade(tester).opacity, 0);
    expect(fade(tester).duration, RewardRing.fadeOut);
    expect(RewardRing.fadeOut.inMilliseconds, 240);
  });

  testWidgets('the hint ring is a 38 dp circle centred on the child', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const Center(
        child: RewardRing.hint(
          visible: true,
          child: SizedBox(key: Key('badge'), width: 22, height: 22),
        ),
      ),
    );
    final ring = find.byKey(RewardRing.ringKey);
    expect(tester.getSize(ring), const Size.square(38));
    expect(
      tester.getCenter(ring),
      tester.getCenter(find.byKey(const Key('badge'))),
    );
    final painter =
        tester.widget<CustomPaint>(ring).painter! as RingGlowPainter;
    expect(painter.circle, isTrue);
    expect(painter.shadows, ChestCollectTokens.hintRingShadow);
    expect(ChestCollectTokens.hintRingSize, 38);
  });

  testWidgets('the ring paints only outside its shape, as CSS does (m7-5 '
      'Part 2 item 3): the pill and the badge stay readable', (tester) async {
    final recorder = PictureRecorder();
    const size = Size(110, 42);
    const RingGlowPainter.pill().paint(Canvas(recorder), size);
    final image = await tester.runAsync(
      () => recorder.endRecording().toImage(110, 42),
    );
    final bytes = await tester.runAsync(image!.toByteData);
    // Inside the stadium, nothing is painted.
    final centre = (21 * 110 + 55) * 4;
    expect(bytes!.getUint8(centre + 3), 0);
    image.dispose();
  });

  testWidgets('reduced motion: no ring (the flights do not fly)', (
    tester,
  ) async {
    await pumpScreen(tester, pill(visible: true), reduceMotion: true);
    expect(find.byKey(RewardRing.ringKey), findsNothing);
  });
}
