// The game is offline-first (CLAUDE.md rule 3): every sound, symbol, skin,
// board sprite, theme, level, animation and font the code references must
// be in the bundle. These checks load through the real asset bundle, so a
// folder missing from pubspec.yaml fails here, not on a device. Later
// features extend the lists (museum PNGs).
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
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

  group('audio (design/audio/AUDIO.md)', () {
    test('every sound event file and music loop ships in its format', () {
      // SFX are WAV; the jingles and the streamed loops are Ogg Vorbis.
      expectAssets(SoundTokens.allFiles.map((f) => 'assets/audio/$f.wav'));
      expectAssets(SoundTokens.jingleFiles.map((f) => 'assets/audio/$f.ogg'));
      expectAssets(SoundTokens.musicFiles.map((f) => 'assets/audio/$f.ogg'));
      expect(SoundTokens.musicFiles, [
        SoundTokens.musicGame,
        SoundTokens.musicHome,
      ]);
    });

    test('nothing else ships in assets/audio/ (never AUDIO.md)', () {
      expect(assets.where((a) => a.startsWith('assets/audio/')).toSet(), {
        for (final f in SoundTokens.allFiles) 'assets/audio/$f.wav',
        for (final f in SoundTokens.jingleFiles) 'assets/audio/$f.ogg',
        for (final f in SoundTokens.musicFiles) 'assets/audio/$f.ogg',
      });
    });

    test(
      'the loops start with an Ogg page and are their token length',
      () async {
        for (final (file, frames) in [
          (SoundTokens.musicHome, SoundTokens.musicHomeFrames),
          (SoundTokens.musicGame, SoundTokens.musicGameFrames),
        ]) {
          final data = await rootBundle.load('assets/audio/$file.ogg');
          final bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
          expect(String.fromCharCodes(bytes, 0, 4), 'OggS', reason: file);
          // Walk the pages: the last one's granule position is the stream's
          // length in frames (sync_design_assets checks every page and its
          // CRC; this pins the bundled copy).
          final view = ByteData.sublistView(bytes);
          var offset = 0;
          var granule = -1;
          while (offset + 27 <= bytes.length) {
            granule = view.getInt64(offset + 6, Endian.little);
            final segments = bytes[offset + 26];
            var body = 0;
            for (var i = 0; i < segments; i++) {
              body += bytes[offset + 27 + i];
            }
            offset += 27 + segments + body;
          }
          expect(offset, bytes.length, reason: file);
          expect(granule, frames, reason: file);
        }
      },
    );
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

  test('the offline level bundle ships and decodes without issues', () async {
    expectAssets(['assets/levels/bundle.json']);
    final result = LevelBundleCodec.decodeString(
      await rootBundle.loadString('assets/levels/bundle.json'),
    );
    expect(result.issues, isEmpty);
    final levels = result.bundle!.levels;
    expect(levels, isNotEmpty);
    expect(
      [for (final e in levels) e.order],
      [for (var i = 1; i <= levels.length; i++) i],
    );
  });

  group('Lottie (PROGRESS D40, D50)', () {
    test('exactly the 29 FxId files ship under assets/lottie/, no PNG', () {
      final shipped = assets
          .where((a) => a.startsWith('${FxId.assetDirectory}/'))
          .toSet();
      expect(shipped, {for (final id in FxId.values) id.assetPath});
      expect(assets.where((a) => a.endsWith('.png')), isEmpty);
    });

    test('each parses with LottieComposition.fromBytes, clean, decoding no '
        'image', () async {
      for (final id in FxId.values) {
        final data = await rootBundle.load(id.assetPath);
        final composition = await LottieComposition.fromBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        // lottie logs every feature it can't draw as a warning. The one it
        // logs for more than 4 image layers is advice, not a failure: every
        // doll and board piece is an image slot by design (LOTTIE.md
        // "Image slots"), so fx_glass_unlock (6) and fx_ice (7) get it.
        final warnings = composition.warnings.where(
          (w) => !w.contains('Lottie should primarily be used with shapes'),
        );
        expect(warnings, isEmpty, reason: id.fileName);
        expect(composition.frameRate, 60, reason: id.fileName);
        // D50: fromBytes never loads the placeholder PNGs.
        for (final image in composition.images.values) {
          expect(
            image.loadedImage,
            isNull,
            reason: '${id.fileName} ${image.id}',
          );
        }
      }
    });
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
