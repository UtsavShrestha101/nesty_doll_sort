// Every shipped file loads through the real library and every hook the
// runtime drives resolves on it (docs/plans/m2-lottie-design.md §17 "FX
// runtime"): markers, image ids, sizes, fills, travel, text nulls.
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/asset_fx_library.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';

import 'support/fx_test_art.dart';

/// Frames spread over [spec], plus each marker's start.
List<double> _samples(FxSpec spec) => {
  for (var i = 0; i <= 8; i++) spec.frames * i / 8,
  for (final m in spec.markers) m.start + 1,
}.toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AssetFxLibrary library;

  setUpAll(() async {
    library = AssetFxLibrary(yieldToFrames: () async {});
    await library.load();
  });

  test('all 29 files load from the bundle, none failed', () {
    expect(library.isLoaded, isTrue);
    expect(library.failed, isEmpty);
    for (final id in FxId.values) {
      expect(library[id], isNotNull, reason: id.fileName);
    }
    expect(library.blank!.width, 1);
    expect(library.blank!.height, 1);
  });

  for (final id in FxId.values) {
    group(id.fileName, () {
      final spec = fxSpecOf(id);

      test('canvas, length and markers match its spec', () {
        final c = library[id]!;
        expect(c.bounds.width, spec.width);
        expect(c.bounds.height, spec.height);
        expect(c.frameRate, FxSpec.frameRate);
        expect(
          c.durationFrames,
          closeTo(FxPlayer.durationFramesOf(spec), 1e-9),
        );
        expect(
          [for (final m in c.markers) (m.name, m.startFrame, m.durationFrames)],
          [for (final m in spec.markers) (m.name, m.start, m.duration)],
        );
        // A marker's end can pass lottie's last frame: the player clamps.
        for (final m in spec.markers) {
          expect(
            FxPlayer.forSpec(spec).progressOf(m.end),
            lessThanOrEqualTo(1),
          );
        }
      });

      test('its image assets are exactly its image layers\' slots', () {
        expect(library[id]!.images.keys.toSet(), {
          for (final l in spec.imageLayers) l.slot.assetId,
        });
      });

      if (spec.imageLayers.isNotEmpty) {
        test('every image layer draws a slot', () async {
          final art = BlobArt(1);
          final clip = FxDrawable.of(library, id)!..images.source = art;
          clip.images.request
            ..doll = DollColor.red
            ..mover = DollColor.blue
            ..target = DollColor.green
            ..unlockColor = DollColor.yellow;
          for (final frame in _samples(spec)) {
            await snapshotDrawable(clip, frame);
          }
          expect(art.requested, {for (final l in spec.imageLayers) l.slot});
        });
      }

      for (final role in spec.roles) {
        test('${role.name}_size resolves', () async {
          Future<double> area(double? k) async {
            // Doll art only: the board pieces of glass and ice would
            // outweigh the doll.
            final art = BlobArt(1);
            final clip = FxDrawable.of(library, id)!
              ..images.source = _DollsOnly(art);
            clip.images.request
              ..doll = DollColor.red
              ..mover = role == FxRole.mover ? DollColor.blue : null
              ..target = role == FxRole.target ? DollColor.green : null;
            clip.params.setSize(role, k);
            var total = 0.0;
            for (final frame in _samples(spec)) {
              final snap = await snapshotDrawable(clip, frame);
              for (var i = 3; i < snap.bytes.length; i += 4) {
                total += snap.bytes[i];
              }
            }
            return total;
          }

          // In doll_nest/doll_swallow mover_size is inside target_size, so
          // shrinking the target also shrinks the mover: either way the
          // drawn area must drop when the role's size does.
          expect(await area(0.3), lessThan(await area(null) * 0.8));
        });
      }

      for (final fill in spec.colorFills) {
        test('$fill resolves', () async {
          const magenta = Color(0xFFFF00FF);
          final clip = FxDrawable.of(library, id)!..images.source = BlobArt(1);
          clip.images.request
            ..doll = DollColor.red
            ..mover = DollColor.blue
            ..target = DollColor.green;
          if (fill == 'rim_tint') {
            clip.params.rimColor = magenta;
          } else {
            clip.params.tintColor = magenta;
          }
          var found = 0;
          for (final frame in _samples(spec)) {
            final snap = await snapshotDrawable(clip, frame, pixelRatio: 2);
            final c = snap.centroidWhere(
              (r, g, b, a) => a > 200 && r > 230 && g < 30 && b > 230,
            );
            if (c != null) found++;
          }
          expect(found, greaterThan(0));
        });
      }

      final travel = spec.travel;
      if (travel != null) {
        test('travel resolves: the remapped point is captured', () async {
          final clip = FxDrawable.of(library, id)!;
          const src = Offset(123, 456);
          clip.params.setTravel(src, const Offset(234, 567));
          await snapshotDrawable(clip, 0);
          expect(clip.params.trailPoint, src);
        });
      }
    });
  }

  test('text files: the counter and ribbon nulls are captured', () async {
    final counter = FxDrawable.of(library, FxId.uiFamilyCounter)!;
    await snapshotDrawable(counter, 6);
    expect(counter.params.textNullPosition, const Offset(60, 30));
    expect(counter.params.textNullScale, closeTo(1.22, 0.005));

    final win = FxDrawable.of(library, FxId.uiWinRibbon)!;
    await snapshotDrawable(win, 0);
    expect(win.params.textNullScale, closeTo(0.6, 0.005));
    await snapshotDrawable(win, 18);
    expect(win.params.textNullScale, closeTo(1, 0.005));
    expect(win.params.textNullPosition, const Offset(180, 55));

    final chapter = FxDrawable.of(library, FxId.uiChapterRibbon)!;
    await snapshotDrawable(chapter, 100);
    expect(chapter.params.textNullPosition, const Offset(180, 50));
    await snapshotDrawable(chapter, 156);
    expect(chapter.params.textNullPosition.dy, closeTo(42, 0.5));
  });
}

/// [source] for the doll slots only.
final class _DollsOnly implements FxImageSource {
  _DollsOnly(this.source);

  final FxImageSource source;

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) =>
      slot.isDoll ? source.rasterFor(slot, request) : null;
}
