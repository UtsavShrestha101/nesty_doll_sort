import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_button.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_sheet.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../support/gift_harness.dart';

/// Home's gift button (frame 13.1): hidden until the gift unlocks, a gold
/// dot only while today's gift can be claimed, and the only thing that
/// opens the sheet.
void main() {
  setUpAll(loadBundledFonts);

  testWidgets('hidden while locked (below the Daily unlock)', (tester) async {
    final rig = GiftRig(highestLevel: 1);
    await rig.pump(tester);
    expect(find.byKey(GiftButton.faceKey), findsNothing);
    expect(find.byType(UiArtImage), findsNothing);
    await rig.dispose(tester);
  });

  testWidgets('shown with its dot when today can be claimed', (tester) async {
    final rig = GiftRig();
    await rig.pump(tester);
    expect(find.byKey(GiftButton.faceKey), findsOneWidget);
    expect(find.byKey(GiftButton.dotKey), findsOneWidget);
    // A plain dot: no number, no text inside it.
    expect(
      find.descendant(
        of: find.byKey(GiftButton.dotKey),
        matching: find.byType(Text),
      ),
      findsNothing,
    );
    await rig.dispose(tester);
  });

  testWidgets('no dot once claimed or while waiting, but still there', (
    tester,
  ) async {
    final claimed = GiftRig(
      progress: LoginGiftProgress(
        claims: 1,
        lastClaim: giftToday,
        latestSeen: giftToday,
      ),
    );
    await claimed.pump(tester);
    expect(find.byKey(GiftButton.faceKey), findsOneWidget);
    expect(find.byKey(GiftButton.dotKey), findsNothing);
    await claimed.dispose(tester);

    // A clock wound back: today is earlier than the latest date seen.
    final waiting = GiftRig(
      progress: LoginGiftProgress(
        claims: 1,
        lastClaim: giftToday.addDays(1),
        latestSeen: giftToday.addDays(1),
      ),
    );
    await waiting.pump(tester);
    expect(find.byKey(GiftButton.faceKey), findsOneWidget);
    expect(find.byKey(GiftButton.dotKey), findsNothing);
    await waiting.dispose(tester);
  });

  testWidgets('semantics: ready, then at rest', (tester) async {
    final handle = tester.ensureSemantics();
    final rig = GiftRig();
    await rig.pump(tester);
    String label() => tester.getSemantics(find.byKey(GiftButton.faceKey)).label;
    expect(label(), 'Daily gift. A gift is ready.');
    await openGiftSheet(tester);
    await tester.tap(find.byKey(GiftSheet.claimKey));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 3));
    expect(label(), 'Daily gift');
    await rig.dispose(tester);
    handle.dispose();
  });

  testWidgets('the target is at least 48 dp', (tester) async {
    final rig = GiftRig();
    await rig.pump(tester);
    final size = tester.getSize(find.byKey(GiftButton.faceKey));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    await rig.dispose(tester);
  });

  testWidgets('13.1: a 46 dp face, radius 17, the cream face and edge, '
      'gift_glyph.svg at 28 (not `redeem`)', (tester) async {
    final rig = GiftRig();
    await rig.pump(tester);
    final surface = tester.widget<TactileSurface>(
      find.byKey(GiftButton.faceKey),
    );
    expect(surface.width, GiftButtonTokens.size);
    expect(surface.height, GiftButtonTokens.size);
    expect(GiftButtonTokens.size, 46);
    expect(surface.radius, const BorderRadius.all(Radius.circular(17)));
    expect(surface.style.gradient, GiftButtonTokens.face);
    expect(surface.style.shadows, GiftButtonTokens.shadow);
    final glyph = tester.widget<UiArtImage>(
      find.descendant(
        of: find.byKey(GiftButton.faceKey),
        matching: find.byType(UiArtImage),
      ),
    );
    expect(glyph.art, UiArt.giftGlyph);
    expect(glyph.size, const Size.square(28));
    expect(find.byIcon(NestyIcons.redeem), findsNothing);
    await rig.dispose(tester);
  });

  testWidgets('13.1: the ready dot is 12 dp, 3 dp past the face\'s top end '
      'corner, and still (no animation under it)', (tester) async {
    final rig = GiftRig();
    await rig.pump(tester);
    final face = tester.getRect(
      find
          .descendant(
            of: find.byKey(GiftButton.faceKey),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    expect(face.size, const Size.square(46));
    final dot = tester.getRect(find.byKey(GiftButton.dotKey));
    expect(dot.size, const Size.square(12));
    expect(dot.top, closeTo(face.top - 3, 0.01));
    expect(dot.right, closeTo(face.right + 3, 0.01));
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(GiftButton.dotKey),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.gradient, GiftButtonTokens.readyDotFace);
    // The cream ring is outside the dot, over its drop shadow.
    expect(decoration.boxShadow!.last.spreadRadius, 2.5);
    expect(decoration.boxShadow!.last.color, const Color(0xFFFFFDF7));
    // Still: it never moves or pulses (`gift.button.readyDot.motion`).
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.getRect(find.byKey(GiftButton.dotKey)), dot);
    expect(tester.hasRunningAnimations, isFalse);
    await rig.dispose(tester);
  });

  testWidgets('nothing opens the sheet until the button is pressed', (
    tester,
  ) async {
    final rig = GiftRig();
    await rig.pump(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(GiftSheet), findsNothing);
    await tester.tap(find.byType(GiftButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(GiftSheet), findsOneWidget);
    await rig.dispose(tester);
  });
}
