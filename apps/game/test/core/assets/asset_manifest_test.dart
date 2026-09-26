// The game is offline-first (CLAUDE.md rule 3): every sound, symbol, skin,
// board sprite, theme and font the code references must be in the bundle.
// These checks load through the real asset bundle, so a folder missing from
// pubspec.yaml fails here, not on a device. Later features extend the lists
// (levels bundle, museum PNGs, music).
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_render/nesty_render.dart';
import 'package:nesty_render/svg_tools.dart';

const _skins = [
  'classic',
  'forest',
  'forest-bear',
  'ocean',
  'space',
  'sweets',
  'winter',
];

const _boardSprites = [
  'doll-silhouette',
  'extra-slot',
  'glass-case-0',
  'glass-case-1',
  'glass-case-2',
  'glow-ring',
  'hint-arrow',
  'ice-0',
  'ice-1',
  'ice-2',
  'ice-3',
  'ice-shatter',
  'shelf-plank',
  'slot-stand-blank',
  'tower-base-blank',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Set<String> assets;
  setUpAll(() async {
    assets = (await AssetManifest.loadFromAssetBundle(
      rootBundle,
    )).listAssets().toSet();
  });

  void expectAssets(Iterable<String> paths) {
    final missing = [
      for (final path in paths)
        if (!assets.contains(path)) path,
    ];
    expect(missing, isEmpty, reason: 'Not in the asset bundle');
  }

  test('every sound event file ships', () {
    expectAssets(SoundTokens.allFiles.map((f) => 'assets/audio/$f.wav'));
  });

  test('every doll color has its belly symbol', () {
    expectAssets(
      DollColorTokens.values.map((c) => 'assets/symbols/${c.symbol}.svg'),
    );
  });

  test('every skin ships an SVG and a valid skin.json', () async {
    expectAssets([
      for (final id in _skins) ...[
        'assets/skins/$id/skin.svg',
        'assets/skins/$id/skin.json',
      ],
    ]);
    for (final id in _skins) {
      final manifest = jsonDecode(
        await rootBundle.loadString('assets/skins/$id/skin.json'),
      );
      expect(
        validateSkinManifest(manifest, expectedSkinId: id),
        isEmpty,
        reason: id,
      );
    }
  });

  test(
    'bundled SVGs are metadata-free and pass the spec §12.2 rules',
    () async {
      final svgs = assets.where((a) => a.endsWith('.svg')).toList()..sort();
      expect(svgs, hasLength(_skins.length + 11 + _boardSprites.length + 6));
      for (final path in svgs) {
        final svg = await rootBundle.loadString(path);
        final issues = path.startsWith('assets/skins/')
            ? validateSkinSvg(svg)
            : validateSvg(svg);
        expect(issues, isEmpty, reason: path);
        expect(svg, isNot(contains('c2pa')), reason: path);
      }
    },
  );

  test('board sprites and the six chapter themes ship', () {
    expectAssets([
      for (final name in _boardSprites) 'assets/board/$name.svg',
      for (var ch = 1; ch <= 6; ch++)
        'assets/themes/ch${ch.toString().padLeft(2, '0')}/background.svg',
    ]);
    expect(
      assets,
      isNot(contains('assets/board/slot-stand.svg')),
      reason: 'the baked-pip stands are not used (spec §10.3)',
    );
  });

  test('the bundled font families are registered', () async {
    final manifest =
        jsonDecode(await rootBundle.loadString('FontManifest.json'))
            as List<Object?>;
    final families = {
      for (final entry in manifest.cast<Map<String, Object?>>())
        entry['family'],
    };
    expect(
      families,
      containsAll(<String>[
        AppFontTokens.displayFamily,
        AppFontTokens.bodyFamily,
        NestyIcons.fontFamily,
      ]),
    );
    expectAssets([
      'assets/fonts/Fredoka-OFL.txt',
      'assets/fonts/Nunito-OFL.txt',
      'assets/fonts/MaterialSymbols-LICENSE.txt',
    ]);
  });

  test('NestyIcons covers the design README glyph list once each', () {
    expect(NestyIcons.byName, hasLength(48));
    final codepoints = NestyIcons.byName.values.map((i) => i.codePoint);
    expect(codepoints.toSet(), hasLength(48));
    expect(
      NestyIcons.byName.values.every(
        (i) => i.fontFamily == NestyIcons.fontFamily,
      ),
      isTrue,
    );
  });
}
