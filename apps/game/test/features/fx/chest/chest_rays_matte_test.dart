// m7-6 item 10 (LOTTIE.md "m7-6"): `ui_chest`'s rays are nested wedges under
// the alpha matte `rays_matte`, a radial falloff from the chest. The game
// installs no delegate on the chest, so this checks the bundled file's own
// playback: the rays fade out with distance, nothing reaches the canvas
// edge, and open_idle still loops without a jump.
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/asset_fx_library.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_id.dart';

import '../support/fx_test_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AssetFxLibrary library;

  setUpAll(() async {
    library = AssetFxLibrary(yieldToFrames: () async {});
    await library.load();
  });

  test('the rays fade with the distance from the chest, and never reach the '
      'canvas edge', () async {
    final clip = FxDrawable.of(library, FxId.uiChest)!;
    // Inside open_idle (290-410).
    final snap = await snapshotDrawable(clip, 350, pixelRatio: 1);
    // Down the centre line: strong near the chest, faint further up, clear
    // by the matte's r 80.
    final near = snap.alphaAt(100, 100);
    final mid = snap.alphaAt(100, 60);
    expect(near, greaterThan(60), reason: 'the rays are lit by the chest');
    expect(mid, inExclusiveRange(0, near), reason: 'and fall off');
    expect(snap.alphaAt(100, 30), 0);
    // Not one lit pixel in the top band, where the unmatted wedges reached.
    for (var y = 0; y < 40; y++) {
      for (var x = 0; x < snap.width; x++) {
        expect(snap.alphaAt(x, y), 0, reason: '($x, $y)');
      }
    }
  });

  test('open_idle still loops without a jump: its first and last frame '
      'match', () async {
    final clip = FxDrawable.of(library, FxId.uiChest)!;
    final first = await snapshotDrawable(clip, 290, pixelRatio: 1);
    final last = await snapshotDrawable(clip, 410, pixelRatio: 1);
    expect(first.differingPixels(last), lessThan(40));
  });
}
