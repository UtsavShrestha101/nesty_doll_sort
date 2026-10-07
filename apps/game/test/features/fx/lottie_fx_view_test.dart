// The widget host and the text overlay (docs/plans/m2-lottie-design.md §2
// "Widgets", §12, §13).
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_drawable_params.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_ribbon.dart';
import 'package:nesty_game/features/fx/fx_text_overlay.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';

import 'support/fx_test_art.dart';

Widget _host(Widget child, {bool reducedMotion = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reducedMotion),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: SizedBox(width: 240, height: 120, child: child)),
  ),
);

Future<FakeFxLibrary> _library(List<FxId> ids) async {
  final library = FakeFxLibrary()..blank = transparentPixel;
  for (final id in ids) {
    library.compositions[id] = await shipped(id);
  }
  return library;
}

bool _ticking() => SchedulerBinding.instance.transientCallbackCount > 0;

void main() {
  group('text layers (D44)', () {
    for (final id in [
      FxId.uiWinRibbon,
      FxId.uiChapterRibbon,
      FxId.uiFamilyCounter,
    ]) {
      test('${id.fileName}: the Lottie text is hidden and nothing else '
          'changes', () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        final composition = await shipped(id);
        final clip = await shippedDrawable(id);
        final textLayers = switch (id) {
          FxId.uiFamilyCounter => const ['count_new', 'count_old'],
          _ => const ['label', 'label_shadow'],
        };
        Future<Snapshot> authored({required bool withText}) {
          final drawable = LottieDrawable(composition, frameRate: FrameRate.max)
            ..delegates = LottieDelegates(
              values: [
                if (!withText)
                  for (final name in textLayers)
                    ValueDelegate.transformOpacity([name], value: 0),
              ],
            );
          drawable.setProgress(10 / composition.durationFrames);
          return snapshot(
            drawable.size.width,
            drawable.size.height,
            (canvas) => drawable.draw(canvas, Offset.zero & drawable.size),
          );
        }

        final ours = await snapshotDrawable(clip, 10);
        expect(ours.differingPixels(await authored(withText: false)), 0);
        expect(
          ours.differingPixels(await authored(withText: true)),
          greaterThan(20),
        );
      });
    }
  });

  group('FxTextOverlay', () {
    test('the label follows the captured null transform', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final overlay = FxTextOverlay(FxTextHook.of(FxId.uiWinRibbon)!)
        ..label = 'Level Complete!';
      final params = FxDrawableParams();
      Future<Rect> drawn(Offset position, double scale) async {
        params
          ..textNullPosition = position
          ..textNullScale = scale;
        final snap = await snapshot(410, 110, (canvas) {
          overlay.paint(canvas, params, frame: 18, playing: false);
        });
        return snap.alphaBounds()!;
      }

      final rest = await drawn(const Offset(205, 55), 1);
      final moved = await drawn(const Offset(185, 45), 1);
      expect(moved.left - rest.left, closeTo(-20, 1));
      expect(moved.top - rest.top, closeTo(-10, 1));
      expect(rest.center.dx, closeTo(205, 2));
      final small = await drawn(const Offset(205, 55), 0.6);
      expect(small.width, closeTo(rest.width * 0.6, 3));
      overlay.dispose();
    });

    for (final (id, box, label, band) in const [
      (
        FxId.uiWinRibbon,
        Rect.fromLTWH(205 - 133, 55 - 20, 266, 40),
        'STUFE ABGESCHLOSSEN – HERVORRAGEND GEMACHT!',
        null,
      ),
      (
        FxId.uiChapterRibbon,
        Rect.fromLTWH(205 - 156, 50 - 16, 312, 32),
        'KAPITEL 10 · VERSCHNEITE BERGHÜTTE AM WALDRAND',
        null,
      ),
      // A 320 dp phone: both bands are 250 (the screen − 70), the boxes 226
      // and 226 (m7-5).
      (
        FxId.uiWinRibbon,
        Rect.fromLTWH(205 - 113, 55 - 20, 226, 40),
        'STUFE ABGESCHLOSSEN – HERVORRAGEND GEMACHT!',
        250.0,
      ),
      (
        FxId.uiChapterRibbon,
        Rect.fromLTWH(205 - 113, 50 - 16, 226, 32),
        'KAPITEL 10 · VERSCHNEITE BERGHÜTTE AM WALDRAND',
        250.0,
      ),
    ]) {
      test('${id.fileName}${band == null ? '' : ' on a $band band'}: a long '
          'all-caps label is drawn inside its text box on the anchor, scaled '
          'down to fit', () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        final hook = FxTextHook.of(id)!;
        final ribbon = FxRibbon.of(id)!;
        final overlay = FxTextOverlay(
          hook,
          style: band == null ? null : ribbon.labelFor(band),
        )..label = label;
        final params = FxDrawableParams()
          ..textNullPosition = hook.style.restNull
          ..textNullScale = 1;
        final snap = await snapshot(
          hook.style.canvas.width,
          hook.style.canvas.height,
          (canvas) => overlay.paint(canvas, params, frame: 18, playing: false),
        );
        // One antialiased pixel of slack at each edge.
        final drawn = snap.alphaBounds()!;
        expect(drawn.left, greaterThanOrEqualTo(box.left - 1));
        expect(drawn.right, lessThanOrEqualTo(box.right + 1));
        expect(drawn.top, greaterThanOrEqualTo(box.top - 1));
        // The hard shadow sits 2 below the letters.
        expect(drawn.bottom, lessThanOrEqualTo(box.bottom + 3));
        expect(
          drawn.width,
          greaterThan(box.width - 12),
          reason: 'fitted, not tiny',
        );
        expect(drawn.center.dx, closeTo(hook.style.restNull.dx, 1));
        overlay.dispose();
      });
    }

    test('the counter shows the old count until the swap frame while it '
        'plays', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final overlay = FxTextOverlay(FxTextHook.of(FxId.uiFamilyCounter)!)
        ..label = '12 / 40'
        ..previousLabel = '1 / 4';
      final params = FxDrawableParams()
        ..textNullPosition = const Offset(60, 30);
      // Both labels are fitted to the 52-unit band, so the longer new
      // count is laid out smaller: its glyphs are shorter.
      Future<double> height(double frame, {required bool playing}) async {
        final snap = await snapshot(120, 60, (canvas) {
          overlay.paint(canvas, params, frame: frame, playing: playing);
        });
        return snap.alphaBounds()!.height;
      }

      final before = await height(3, playing: true);
      final after = await height(8, playing: true);
      final resting = await height(3, playing: false);
      expect(before, greaterThan(after));
      expect(resting, after);
      overlay.dispose();
    });
  });

  group('LottieFxView', () {
    testWidgets('a one-shot ticks only while it plays', (tester) async {
      final library = await tester.runAsync(
        () => _library([FxId.uiFamilyCounter]),
      );
      final controller = LottieFxController(FxId.uiFamilyCounter);
      var finished = 0;
      controller.onFinished = () => finished++;
      await tester.pumpWidget(
        _host(
          LottieFxView(
            id: FxId.uiFamilyCounter,
            controller: controller,
            library: library,
            label: '2 / 4',
            previousLabel: '1 / 4',
          ),
        ),
      );
      expect(_ticking(), isFalse, reason: 'idle: nothing scheduled');
      expect(find.byType(CustomPaint), paints..paragraph());

      controller.playMarker('bump');
      await tester.pump();
      expect(_ticking(), isTrue);
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.player.frame, closeTo(6, 0.5));
      await tester.pump(const Duration(milliseconds: 150));
      expect(finished, 1);
      expect(controller.player.isFinished, isTrue);
      await tester.pump();
      expect(_ticking(), isFalse, reason: 'a paused view costs nothing');
      controller.dispose();
    });

    testWidgets('autoplay loops a looping file; reduced motion rests an '
        'ambient one on frame 0', (tester) async {
      final library = await tester.runAsync(() => _library([FxId.fxTwinkle]));
      await tester.pumpWidget(
        _host(LottieFxView(id: FxId.fxTwinkle, library: library)),
      );
      await tester.pump(const Duration(seconds: 3));
      expect(_ticking(), isTrue);

      await tester.pumpWidget(
        _host(
          LottieFxView(id: FxId.fxTwinkle, library: library),
          reducedMotion: true,
        ),
      );
      await tester.pump();
      expect(_ticking(), isFalse);
    });

    testWidgets('reduced motion plays a one-shot at 2×', (tester) async {
      final library = await tester.runAsync(() => _library([FxId.uiToggle]));
      final controller = LottieFxController(FxId.uiToggle);
      await tester.pumpWidget(
        _host(
          LottieFxView(
            id: FxId.uiToggle,
            controller: controller,
            library: library,
          ),
          reducedMotion: true,
        ),
      );
      controller.playMarker('on');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      // 50 ms at 2× = 6 frames of the 11-frame `on`.
      expect(controller.player.frame, closeTo(6, 0.5));
      await tester.pump(const Duration(milliseconds: 60));
      expect(controller.player.isFinished, isTrue);
      expect(controller.player.frame, 11);
      controller.dispose();
    });

    testWidgets('confetti draws nothing under reduced motion', (tester) async {
      final library = await tester.runAsync(() => _library([FxId.fxConfetti]));
      final controller = LottieFxController(FxId.fxConfetti);
      await tester.pumpWidget(
        _host(
          LottieFxView(
            id: FxId.fxConfetti,
            controller: controller,
            library: library,
          ),
          reducedMotion: true,
        ),
      );
      expect(controller.isSkipped, isTrue);
      expect(find.byType(CustomPaint), isNot(paints..path()));
      controller.dispose();
    });

    testWidgets('a missing file shows the fallback and the label at rest '
        '(rule 3)', (tester) async {
      final library = FakeFxLibrary();
      await tester.pumpWidget(
        _host(
          LottieFxView(
            id: FxId.uiWinRibbon,
            library: library,
            label: 'Level Complete!',
            fallback: const ColoredBox(
              key: Key('ribbon-fallback'),
              color: Colors.orange,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('ribbon-fallback')), findsOneWidget);
      expect(find.byType(CustomPaint), paints..paragraph());
    });

    testWidgets('picks up its composition as soon as the library has '
        'parsed it', (tester) async {
      final composition = await tester.runAsync(
        () => shipped(FxId.uiBoosterGlow),
      );
      final library = _SlowLibrary();
      final controller = LottieFxController(FxId.uiBoosterGlow)..playWhole();
      await tester.pumpWidget(
        _host(
          LottieFxView(
            id: FxId.uiBoosterGlow,
            controller: controller,
            library: library,
          ),
        ),
      );
      await tester.pump();
      expect(_ticking(), isFalse, reason: 'nothing to draw yet');
      expect(find.byType(CustomPaint), isNot(paints..path()));

      library.parsed(FxId.uiBoosterGlow, composition!);
      await tester.pump();
      expect(_ticking(), isTrue);
      await tester.pump(const Duration(milliseconds: 500));
      expect(controller.player.frame, closeTo(30, 0.5));
      expect(find.byType(CustomPaint), paints..path());
      library.finish();
      controller.dispose();
    });

    testWidgets('a playing view repaints only its own layer, never the '
        'surfaces around it (rule 8, review PERF-RULES-1)', (tester) async {
      final library = await tester.runAsync(() => _library([FxId.fxTwinkle]));
      final sibling = _CountingPainter();
      final controller = LottieFxController(FxId.fxTwinkle)..playWhole();
      await tester.pumpWidget(
        _host(
          Stack(
            children: [
              // Stands for Home's PLAY button or a coin pill next to a
              // looping twinkle.
              Positioned.fill(child: CustomPaint(painter: sibling)),
              Positioned(
                left: 0,
                top: 0,
                width: 32,
                height: 32,
                child: LottieFxView(
                  id: FxId.fxTwinkle,
                  controller: controller,
                  library: library,
                ),
              ),
            ],
          ),
        ),
      );
      final before = sibling.paints;
      final frame = controller.player.frame;
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(_ticking(), isTrue);
      expect(controller.player.frame, isNot(frame), reason: 'it played');
      expect(sibling.paints, before, reason: 'the sibling kept its layer');
      controller.dispose();
    });

    testWidgets('the splash loader seeks its progress frame', (tester) async {
      final library = await tester.runAsync(
        () => _library([FxId.uiSplashLoader]),
      );
      final controller = LottieFxController(FxId.uiSplashLoader)..seek(40);
      await tester.pumpWidget(
        _host(
          LottieFxView(
            id: FxId.uiSplashLoader,
            controller: controller,
            library: library,
          ),
        ),
      );
      expect(_ticking(), isFalse);
      expect(controller.player.progress, closeTo(40 / 99.99, 1e-9));
      controller.dispose();
    });
  });
}

/// Counts its paints: a surface that must not repaint with its neighbours.
final class _CountingPainter extends CustomPainter {
  int paints = 0;

  @override
  void paint(Canvas canvas, Size size) => paints++;

  @override
  bool shouldRepaint(_CountingPainter oldDelegate) => false;
}

/// A library still loading: files arrive one by one, as `AssetFxLibrary`
/// reports them.
final class _SlowLibrary implements FxLibrary {
  final Map<FxId, LottieComposition> _compositions = {};
  final List<void Function(double)> _listeners = [];
  final Completer<void> _done = Completer<void>();

  void parsed(FxId id, LottieComposition composition) {
    _compositions[id] = composition;
    for (final listener in _listeners) {
      listener(0.5);
    }
  }

  void finish() => _done.complete();

  @override
  Future<void> load({void Function(double progress)? onProgress}) {
    if (onProgress != null) _listeners.add(onProgress);
    return _done.future;
  }

  @override
  bool get isLoaded => _done.isCompleted;

  @override
  LottieComposition? operator [](FxId id) => _compositions[id];

  @override
  Set<FxId> get failed => const {};

  @override
  ui.Image? get blank => transparentPixel;
}
