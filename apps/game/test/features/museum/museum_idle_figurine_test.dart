import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';
import 'package:nesty_game/features/museum/widgets/museum_idle_figurine.dart';

import '../../core/ui/support/ui_harness.dart';
import '../fx/support/fx_test_art.dart';

/// A collected niche's `ui_museum_idle` (m7-4 J.2; tokens `motion.museumIdle`,
/// LOTTIE.md "When each one plays"): the file loops on the figurine from a
/// random frame of its own, the canvas hangs round the 62 dp art box with the
/// figurine's base on the box's bottom centre, it rests on frame 0 under
/// reduce motion, and the still art stands in until the file and the art are
/// ready (rule 3).
void main() {
  setUpAll(loadBundledFonts);

  bool ticking() => SchedulerBinding.instance.transientCallbackCount > 0;

  Future<FakeFxLibrary> library() async {
    final library = FakeFxLibrary()..blank = transparentPixel;
    library.compositions[FxId.uiMuseumIdle] = await shipped(FxId.uiMuseumIdle);
    return library;
  }

  Future<ui.Image?> art(String asset, int pixels) async => transparentPixel;

  Future<void> pump(
    WidgetTester tester, {
    FakeFxLibrary? fx,
    String id = 'classic',
    FigurineRasterLoader? loader,
    bool reduce = false,
  }) => pumpUi(
    tester,
    Center(
      child: MuseumIdleFigurine(
        figurineId: id,
        library: fx,
        loadRaster: loader ?? art,
      ),
    ),
    reduceMotion: reduce,
  );

  testWidgets('the clip loops on the figurine: a 90 dp canvas hangs 14 dp out '
      'each side and 10 dp under the 62 dp box (base at the bottom centre)', (
    tester,
  ) async {
    final fx = await tester.runAsync(library);
    await pump(tester, fx: fx);
    await tester.pump();
    expect(find.byType(LottieFxView), findsOneWidget);
    expect(find.byType(FigurineImage), findsNothing);
    final box = tester.getRect(
      find
          .descendant(
            of: find.byType(MuseumIdleFigurine),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(box.size, const Size(62, 62));
    final canvas = tester.getRect(find.byType(LottieFxView));
    expect(canvas.size, const Size(90, 90));
    // The base of the figurine, (45, 80) in the canvas, is the box's bottom
    // centre.
    expect(canvas.left + 45, closeTo(box.center.dx, 0.01));
    expect(canvas.top + 80, closeTo(box.bottom, 0.01));
    await tester.pump(const Duration(milliseconds: 500));
    expect(ticking(), isTrue, reason: 'it loops');
  });

  test('each figurine starts at its own frame, the same on every visit', () {
    final ids = [
      'classic',
      'sailor',
      'baker',
      'astronaut',
      'gardener',
      'snow',
      'circus',
      'musician',
      'royal',
      'explorer',
    ];
    final starts = {for (final id in ids) id: MuseumIdleFigurine.startMsOf(id)};
    expect(starts.values.toSet().length, 10);
    for (final start in starts.values) {
      expect(start, inInclusiveRange(0, 4000));
    }
    expect(MuseumIdleFigurine.startMsOf('classic'), starts['classic']);
  });

  testWidgets('reduce motion rests on frame 0: nothing is scheduled', (
    tester,
  ) async {
    final fx = await tester.runAsync(library);
    await pump(tester, fx: fx, reduce: true);
    await tester.pump();
    expect(find.byType(LottieFxView), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(ticking(), isFalse);
  });

  testWidgets('turning reduce motion on stops the loop', (tester) async {
    final fx = await tester.runAsync(library);
    await pump(tester, fx: fx);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(ticking(), isTrue);
    await pump(tester, fx: fx, reduce: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(ticking(), isFalse);
  });

  testWidgets('without the file the still figurine shows (rule 3)', (
    tester,
  ) async {
    await pump(tester, fx: FakeFxLibrary());
    await tester.pump();
    expect(find.byType(LottieFxView), findsNothing);
    expect(find.byType(FigurineImage), findsOneWidget);
  });

  testWidgets('without the art the still figurine shows', (tester) async {
    final fx = await tester.runAsync(library);
    await pump(tester, fx: fx, loader: (asset, pixels) async => null);
    await tester.pump();
    expect(find.byType(LottieFxView), findsNothing);
    expect(find.byType(FigurineImage), findsOneWidget);
  });

  testWidgets('a figurine the catalog does not know draws no clip', (
    tester,
  ) async {
    final fx = await tester.runAsync(library);
    await pump(tester, fx: fx, id: 'nobody');
    await tester.pump();
    expect(find.byType(LottieFxView), findsNothing);
  });
}
