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
    final decoration =
        tester.widget<DecoratedBox>(ring).decoration as BoxDecoration;
    expect(decoration.boxShadow, [
      const BoxShadow(color: Color(0xCCFFD66E), spreadRadius: 4),
      const BoxShadow(
        color: Color(0x99FFCD50),
        blurRadius: 18,
        spreadRadius: 6,
      ),
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
    final decoration =
        tester.widget<DecoratedBox>(ring).decoration as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.boxShadow, [
      for (final s in ChestCollectTokens.hintRingShadow) s.toBoxShadow(),
    ]);
    expect(ChestCollectTokens.hintRingSize, 38);
  });

  testWidgets('reduced motion: no ring (the flights do not fly)', (
    tester,
  ) async {
    await pumpScreen(tester, pill(visible: true), reduceMotion: true);
    expect(find.byKey(RewardRing.ringKey), findsNothing);
  });
}
