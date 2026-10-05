// The design SVGs the game ships (apps/game/assets, written by
// `dart run nesty_tools:sync_design_assets`) must compile with flutter_svg,
// the renderer nesty_render rasterizes skins and board sprites with
// (spec §12.2). Read from the workspace so this package's own tests catch a
// design export flutter_svg can't handle.
import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final assets = Directory('../../apps/game/assets');
  final svgs = assets.existsSync()
      ? (assets
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.svg'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path)))
      : <File>[];

  test('finds the synced game SVGs', () {
    // 7 skins, 11 symbols, 18 board pieces (m7-3's tall glass case) and
    // chapters 7–10's own plank, stand and tower (m7-4 A.5, 4 × 3), 10
    // chapter themes and 35 UI art files (m7-3's badges, chests, rivals,
    // sprites and stars).
    expect(svgs, hasLength(93), reason: 'run sync_design_assets first');
  });

  for (final file in svgs) {
    final name = file.path.substring(assets.path.length + 1);
    test('flutter_svg compiles $name', () async {
      final info = await vg.loadPicture(
        SvgStringLoader(file.readAsStringSync()),
        null,
      );
      addTearDown(info.picture.dispose);
      expect(info.size.width, greaterThan(0));
      expect(info.size.height, greaterThan(0));
    });
  }
}
