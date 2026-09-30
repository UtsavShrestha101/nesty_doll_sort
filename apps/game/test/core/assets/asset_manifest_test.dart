// The game is offline-first (CLAUDE.md rule 3): every sound, symbol, skin,
// board sprite, theme, level, animation and font the code references must
// be in the bundle. These checks load through the real asset bundle, so a
// folder missing from pubspec.yaml fails here, not on a device.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
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
  'glass-case-tall-0',
  'glass-case-tall-1',
  'glass-case-tall-2',
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

/// The M7 UI art (design m7-3, synced from design/ui/ by
/// `sync_design_assets`): every file the app draws, by folder.
final _uiArt = {
  'badges': [
    for (final badge in [
      'all_rivals',
      'dailies_30',
      'dailies_7',
      'first_family',
      'first_race',
      'glass_breaker',
      'grand_nest',
      'ice_melter',
      'level_100',
      'level_200',
      'museum_full',
      'tall_order',
    ]) ...[badge, '${badge}_locked'],
  ],
  'chest': ['chest_closed', 'chest_open'],
  'rivals': ['rival_1', 'rival_2', 'rival_3', 'rival_locked'],
  'sprites': ['coin_flight', 'hint_flight'],
  'stars': ['star_empty', 'star_filled', 'star_glow'],
};

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
      // m7-3: 23 SFX (the stars, the chest, the rival) and 5 jingles (the
      // race's win and loss).
      expect(SoundTokens.allFiles, hasLength(23));
      expect(
        SoundTokens.allFiles,
        containsAll([
          'star_1',
          'star_2',
          'star_3',
          'chest_wiggle',
          'chest_open',
          'rival_complete',
        ]),
      );
      expect(SoundTokens.jingleFiles, [
        'jingle_chapter',
        'jingle_oom',
        'jingle_reward',
        'jingle_versus_lose',
        'jingle_versus_win',
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
      final uiArt = _uiArt.values.fold(0, (n, files) => n + files.length);
      expect(
        svgs,
        hasLength(_skins.length + 11 + _boardSprites.length + 10 + uiArt),
      );
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

  test('board sprites and the ten chapter themes ship', () {
    expectAssets([
      for (final name in _boardSprites) 'assets/board/$name.svg',
      for (var ch = 1; ch <= 10; ch++)
        'assets/themes/ch${ch.toString().padLeft(2, '0')}/background.svg',
    ]);
    expect(
      assets,
      isNot(contains('assets/board/slot-stand.svg')),
      reason: 'the baked-pip stands are not used (spec §10.3)',
    );
  });

  test('the M7 UI art ships, and nothing else under assets/ui/', () {
    final expected = {
      for (final MapEntry(key: folder, value: files) in _uiArt.entries)
        for (final file in files) 'assets/ui/$folder/$file.svg',
    };
    expect(expected, hasLength(35));
    expect(assets.where((a) => a.startsWith('assets/ui/')).toSet(), expected);
    expect(
      assets.where(
        (a) => a.startsWith('assets/') && a.contains('notification'),
      ),
      isEmpty,
      reason: 'the notification icon is an Android drawable, not an asset',
    );
  });

  group('museum figurines (m3-design §9.5)', () {
    final chapters = BundledCatalogRepository.bundledChapters;

    test('every bundled figurine ships its earned and locked PNG', () {
      expectAssets([
        for (final chapter in chapters) ...[
          chapter.figurine.artAsset,
          chapter.figurine.lockedArtAsset,
        ],
      ]);
    });

    test('nothing else ships under assets/museum/', () {
      expect(assets.where((a) => a.startsWith('assets/museum/')).toSet(), {
        for (final chapter in chapters) ...[
          chapter.figurine.artAsset,
          chapter.figurine.lockedArtAsset,
        ],
      });
    });

    test('each is a real PNG at 600×600', () async {
      for (final chapter in chapters) {
        for (final asset in [
          chapter.figurine.artAsset,
          chapter.figurine.lockedArtAsset,
        ]) {
          final data = await rootBundle.load(asset);
          final bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
          expect(bytes.sublist(0, 8), const [
            0x89,
            0x50,
            0x4E,
            0x47,
            0x0D,
            0x0A,
            0x1A,
            0x0A,
          ], reason: asset);
          final view = ByteData.sublistView(bytes);
          expect(view.getUint32(16, Endian.big), 600, reason: '$asset width');
          expect(view.getUint32(20, Endian.big), 600, reason: '$asset height');
        }
      }
    });
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
    test('exactly the 35 FxId files ship under assets/lottie/, no PNG', () {
      final shipped = assets
          .where((a) => a.startsWith('${FxId.assetDirectory}/'))
          .toSet();
      expect(shipped, {for (final id in FxId.values) id.assetPath});
      // The placeholder PNGs never ship (D50); the bundled museum figurines
      // (m3-design §9.5) are the app's only legitimate PNGs.
      expect(
        assets.where(
          (a) => a.startsWith('${FxId.assetDirectory}/') && a.endsWith('.png'),
        ),
        isEmpty,
      );
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
    // 48 of v1, 18 m7 adds (I.10) and the splash errors' two (lead note 2).
    expect(NestyIcons.byName, hasLength(68));
    final codepoints = NestyIcons.byName.values.map((i) => i.codePoint);
    expect(codepoints.toSet(), hasLength(68));
    expect(
      NestyIcons.byName.values.every(
        (i) => i.fontFamily == NestyIcons.fontFamily,
      ),
      isTrue,
    );
  });
}
