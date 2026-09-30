// Phase 4 lane B on the shipped files through the real delegates: the tall
// glass case (`fx_glass_unlock_tall`, its `case_size` null and the padlock
// inside `padlock_tall`), the padlock's ping (E.13), the tall ice's
// compensated doll, and the glass workarounds holding for both glass ids
// (architecture §1.2).
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_drawable_params.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_layout.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';

import 'support/fx_test_art.dart';

const _red = Color(0xFFFF0000);
const _blue = Color(0xFF0000FF);
const _cream = Color(0xFFFFF3D6);

FxRaster _solid(FxImageSlot slot, Color color) => FxRaster(
  insetBox(slot.declaredWidth.round(), slot.declaredHeight.round(), color),
  scale: 1,
);

bool _isRed(int r, int g, int b, int a) => a > 200 && r > 200 && g < 60;
bool _isBlue(int r, int g, int b, int a) => a > 200 && b > 200 && r < 60;
bool _isCream(int r, int g, int b, int a) =>
    a > 200 && r > 230 && g > 220 && b > 180 && b < 235;

const _pr = 4.0;

/// The tall glass with a solid case, symbol and doll.
Future<FxDrawable> _tall({bool withDoll = true}) async {
  final clip = await shippedDrawable(
    FxId.fxGlassUnlockTall,
    source: FixedArt({
      FxImageSlot.glassCaseTall0: _solid(FxImageSlot.glassCaseTall0, _cream),
      FxImageSlot.unlockSymbol: _solid(FxImageSlot.unlockSymbol, _blue),
      FxImageSlot.dollLid: _solid(FxImageSlot.dollLid, _red),
      FxImageSlot.dollBody: _solid(FxImageSlot.dollBody, _red),
    }),
  );
  clip.images.request
    ..doll = withDoll ? DollColor.red : null
    ..unlockColor = DollColor.blue;
  return clip;
}

Future<FxDrawable> _normal() async {
  final clip = await shippedDrawable(
    FxId.fxGlassUnlock,
    source: FixedArt({
      FxImageSlot.glassCase0: _solid(FxImageSlot.glassCase0, _cream),
      FxImageSlot.unlockSymbol: _solid(FxImageSlot.unlockSymbol, _blue),
      FxImageSlot.dollLid: _solid(FxImageSlot.dollLid, _red),
      FxImageSlot.dollBody: _solid(FxImageSlot.dollBody, _red),
    }),
  );
  clip.images.request
    ..doll = DollColor.red
    ..unlockColor = DollColor.blue;
  return clip;
}

Future<Snapshot> _at(FxDrawable clip, double frame, {bool rest = false}) {
  if (rest) {
    clip.player.rest(frame);
  } else {
    clip.player.seek(frame);
  }
  return snapshot(
    clip.spec.width,
    clip.spec.height,
    clip.draw,
    pixelRatio: _pr,
  );
}

Rect? _boundsOf(
  Snapshot snap,
  bool Function(int r, int g, int b, int a) test,
) => snap.boundsWhere((x, y) {
  final (r, g, b, a) = snap.at(x, y);
  return test(r, g, b, a);
});

Rect _logical(Rect r) =>
    Rect.fromLTRB(r.left / _pr, r.top / _pr, r.right / _pr, r.bottom / _pr);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('fx_glass_unlock_tall (B.4)', () {
    test('the contract: 200×280, anchor (100, 212), case_size the one scale '
        'null', () {
      final spec = fxSpecOf(FxId.fxGlassUnlockTall);
      expect((spec.width, spec.height), (200, 280));
      expect(spec.anchor, const Offset(100, 212));
      expect(spec.scaleNulls, ['case_size']);
      expect(spec.frames, 54);
      expect(fxSpecOf(FxId.fxGlassUnlock).scaleNulls, isEmpty);
    });

    test('at 100 % the case is 93×152 with its top-left at (53.5, 64) and '
        'the doll base on the surface (100, 212)', () async {
      final clip = await _tall();
      final snap = await _at(clip, 0, rest: true);
      final box = _logical(_boundsOf(snap, _isCream)!);
      expect(box.left, closeTo(53.5, 0.6));
      expect(box.top, closeTo(64, 0.6));
      expect(box.width, closeTo(93, 1));
      expect(box.height, closeTo(152, 1));
    });

    test('the padlock inside padlock_tall: the symbol shows at rest, sits at '
        'caseTop + 0.898 × caseHeight, and is 12 dp at 100 %', () async {
      final clip = await _tall();
      final snap = await _at(clip, 0, rest: true);
      final symbol = _logical(_boundsOf(snap, _isBlue)!);
      // The image slot is 12 dp: with `unlock_symbol` at 33.33 % of 36 px.
      expect(symbol.width, closeTo(12, 1.2));
      expect(symbol.center.dx, closeTo(100, 1));
      expect(symbol.center.dy, closeTo(64 + 0.898 * 152, 2));
    });

    test('case_size scales everything but the doll about the surface: the '
        'case, its padlock, the flash, the shards and the glints', () async {
      Future<Rect> extent(
        double k,
        double frame, {
        required bool Function(int, int, int, int) test,
      }) async {
        final clip = await _tall(withDoll: false);
        clip.params.caseScale = k;
        return _logical(_boundsOf(await _at(clip, frame), test)!);
      }

      // The case at frame 0.
      final full = await extent(1, 0, test: _isCream);
      final half = await extent(0.5, 0, test: _isCream);
      expect(half.width, closeTo(full.width * 0.5, 1));
      expect(half.height, closeTo(full.height * 0.5, 1));
      expect(half.center.dx, closeTo(100, 1));
      // Its bottom stays on the surface line (4 dp under it at 100 %).
      expect(half.bottom, closeTo(212 + (full.bottom - 212) * 0.5, 1));

      // The padlock.
      final lock = await extent(1, 0, test: _isBlue);
      final lockHalf = await extent(0.5, 0, test: _isBlue);
      expect(lockHalf.width, closeTo(lock.width * 0.5, 1));
      expect(
        lockHalf.center.dy,
        closeTo(212 + (lock.center.dy - 212) * 0.5, 1),
      );

      // The shards and glints, mid-shatter: everything the file draws
      // except the doll moves about the surface by the same factor.
      Future<Rect> any(double k, double frame) async {
        final clip = await _tall(withDoll: false);
        clip.params.caseScale = k;
        final snap = await _at(clip, frame);
        return _logical(snap.alphaBounds(threshold: 16)!);
      }

      for (final frame in const [20.0, 28.0, 36.0]) {
        final a = await any(1, frame);
        final b = await any(0.5, frame);
        expect(b.width, closeTo(a.width * 0.5, 2.5), reason: 'frame $frame');
        expect(
          b.top,
          closeTo(212 + (a.top - 212) * 0.5, 2.5),
          reason: 'frame $frame',
        );
        expect(
          b.bottom,
          closeTo(212 + (a.bottom - 212) * 0.5, 2.5),
          reason: 'frame $frame',
        );
      }
    });

    test('doll_size = case_size = h / (150 · fs): the doll and its case grow '
        'together (FxLayout.applyDollHeights)', () async {
      final clip = await _tall();
      const fs = 0.9;
      const h = 142.1;
      FxLayout.applyDollHeights(
        clip.params,
        clip.spec,
        compositionScale: fs,
        doll: h,
      );
      expect(clip.params.caseScale, closeTo(h / (150 * fs), 1e-12));
      expect(
        clip.params.sizeOf(FxRole.doll)!.dx,
        closeTo(h / (150 * fs), 1e-12),
      );
      // On screen, at fs: the case is 0.62 h × 1.0133 h and the doll is h.
      clip.player.rest(0);
      final snap = await snapshot(clip.spec.width * fs, clip.spec.height * fs, (
        canvas,
      ) {
        canvas.scale(fs);
        clip.draw(canvas);
      }, pixelRatio: _pr);
      final box = _boundsOf(snap, _isCream)!;
      expect(box.width / _pr, closeTo(0.62 * h, 1.2));
      expect(box.height / _pr, closeTo(1.0133 * h, 1.2));
      // Without a doll height the case keeps its authored 100 %.
      final none = await _tall();
      FxLayout.applyDollHeights(none.params, none.spec, compositionScale: fs);
      expect(none.params.caseScale, isNull);
    });

    test('the freed doll lands on the surface (canvas 212) at frame 53, '
        'having hopped from it: no plinth lift', () async {
      final clip = await _tall();
      const h = 150.0;
      FxLayout.applyDollHeights(
        clip.params,
        clip.spec,
        compositionScale: 1,
        doll: h,
      );
      Future<double> bottom(double frame) async {
        final snap = await _at(clip, frame);
        return _boundsOf(snap, _isRed)!.bottom / _pr;
      }

      // The solid art reaches 26 of 768 units below the base.
      const below = h * 26 / 768;
      for (final frame in const [53.0, 53.5, 54.0]) {
        expect(
          await bottom(frame),
          closeTo(212 + below, 1.2),
          reason: '$frame',
        );
      }
      // The hop takes it up to 16 dp above the surface by frame 47.
      expect(await bottom(47), lessThan(212 + below - 8));
    });
  });

  group('the glass workarounds hold for both glass ids', () {
    for (final (id, make, centre) in [
      (FxId.fxGlassUnlock, _normal, const Offset(90, 156)),
      (FxId.fxGlassUnlockTall, _tall, const Offset(100, 200.5)),
    ]) {
      test('${id.fileName}: the unlock symbol shows at rest and while '
          'seeked at frame 0; padlock_ping covers it while playing', () async {
        final clip = await make();
        final resting = await _at(clip, 0, rest: true);
        final px = (centre.dx * _pr).round();
        final py = (centre.dy * _pr).round();
        var (r, g, b, a) = resting.at(px, py);
        expect(_isBlue(r, g, b, a), isTrue, reason: 'at rest ($r,$g,$b,$a)');
        final seeked = await _at(clip, 0);
        expect(seeked.at(px, py), resting.at(px, py));
        (r, g, b, a) = (await _at(clip, 1.5)).at(px, py);
        expect(_isBlue(r, g, b, a), isFalse, reason: 'frame 1.5');
      });
    }

    test('both files share the timing: 54 frames, the doll hidden in the '
        'case until it breaks', () {
      expect(
        fxSpecOf(FxId.fxGlassUnlockTall).frames,
        fxSpecOf(FxId.fxGlassUnlock).frames,
      );
      expect(FxLayout.usesFurnitureScale(FxId.fxGlassUnlockTall), isTrue);
      expect(FxLayout.usesFurnitureScale(FxId.fxGlassUnlock), isTrue);
    });
  });

  group('the padlock ping (E.13)', () {
    for (final (id, make) in [
      (FxId.fxGlassUnlock, _normal),
      (FxId.fxGlassUnlockTall, _tall),
    ]) {
      test('${id.fileName}: padlockPing scales the symbol about its own '
          'anchor and 1 leaves it as authored', () async {
        final clip = await make();
        final base = _logical(
          _boundsOf(await _at(clip, 0, rest: true), _isBlue)!,
        );
        clip.params.padlockPing = 1.15;
        final pinged = _logical(
          _boundsOf(await _at(clip, 0, rest: true), _isBlue)!,
        );
        expect(pinged.width, closeTo(base.width * 1.15, 1));
        expect(pinged.height, closeTo(base.height * 1.15, 1));
        clip.params.padlockPing = 1;
        final back = _logical(
          _boundsOf(await _at(clip, 0, rest: true), _isBlue)!,
        );
        expect(back, base);
        // The ping is a param: a clip returned to its pool forgets it.
        clip.params
          ..padlockPing = 1.15
          ..reset();
        expect(clip.params.padlockPing, 1);
      });
    }

    test(
      'the delegate leaves the authored padlock_ping animation alone while '
      'the ping is 1: the symbol is covered at frame 1.5 as before',
      () async {
        final clip = await _tall();
        final (r, g, b, a) = (await _at(
          clip,
          1.5,
        )).at((100 * _pr).round(), (200.5 * _pr).round());
        expect(_isBlue(r, g, b, a), isFalse);
      },
    );
  });

  group('the tall ice (B.3): fx_ice at (1, 1.05) with a compensated doll', () {
    test('the doll keeps its proportions under the stretch', () async {
      Future<Rect> doll({required double stretch}) async {
        final clip = await shippedDrawable(
          FxId.fxIce,
          source: FixedArt({
            FxImageSlot.dollLid: _solid(FxImageSlot.dollLid, _red),
            FxImageSlot.dollBody: _solid(FxImageSlot.dollBody, _red),
          }),
        );
        clip.images.request.doll = DollColor.red;
        FxLayout.applyDollHeights(
          clip.params,
          clip.spec,
          compositionScale: 1,
          doll: 140,
          stretchY: stretch,
        );
        clip.player.rest(0);
        final snap = await snapshot(
          clip.spec.width,
          clip.spec.height * stretch,
          (canvas) {
            canvas.scale(1, stretch);
            clip.draw(canvas);
          },
          pixelRatio: _pr,
        );
        return _logical(_boundsOf(snap, _isRed)!);
      }

      final plain = await doll(stretch: 1);
      final stretched = await doll(stretch: 1.05);
      expect(stretched.width, closeTo(plain.width, 1));
      expect(stretched.height, closeTo(plain.height, 1.2));
      // Its base lands 1.46 dp higher than unstretched: the design's "base
      // lands 1.5 dp high", inside the test's 2.
      final baseGap =
          (plain.bottom - 170.8) - (stretched.bottom - 170.8 * 1.05);
      expect(baseGap.abs(), lessThan(2));
    });

    test('doll_size keeps a factor pair (k, k / stretchY)', () {
      final params = FxDrawableParams()
        ..setSize(FxRole.doll, 0.9, stretchY: 1.05);
      expect(params.sizeOf(FxRole.doll), const Offset(0.9, 0.9 / 1.05));
      params.setSize(FxRole.doll, 0.9);
      expect(params.sizeOf(FxRole.doll), const Offset(0.9, 0.9));
    });
  });
}
