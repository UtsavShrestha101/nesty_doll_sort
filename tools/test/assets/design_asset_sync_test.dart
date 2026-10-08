import 'dart:convert';
import 'dart:io';

import 'package:nesty_tools/src/assets/android_vector.dart';
import 'package:nesty_tools/src/assets/design_asset_sync.dart';
import 'package:nesty_tools/src/assets/widget_native_art.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _ns = 'xmlns="http://www.w3.org/2000/svg"';
const _c2pa = '<metadata><c2pa:manifest>QUJD</c2pa:manifest></metadata>';

String _svg(String body, {String box = '0 0 10 10'}) =>
    '<svg $_ns viewBox="$box" xmlns:c2pa="http://c2pa.org/manifest">'
    '$_c2pa$body</svg>';

String _skinSvg() => _svg(
  const [
    'shadow',
    'bottom_mask',
    'bottom_detail',
    'top_mask',
    'face',
    'top_detail',
    'shine_top',
    'shine_bottom',
  ].map((g) => '<g id="$g"><rect width="1" height="1"/></g>').join(),
  box: '0 0 512 768',
);

String _skinJson(String id) =>
    '{"skinId":"$id","splitY":400,"lidLiftPx":120,'
    '"symbolAnchor":[256,590],"symbolSize":110,"version":1}';

/// A 44.1 kHz WAV of two 16-bit frames, mono unless [channels] says.
List<int> _wav({int channels = 1}) {
  List<int> u16(int v) => [v & 0xFF, v >> 8];
  List<int> u32(int v) => [for (var i = 0; i < 4; i++) v >> (8 * i) & 0xFF];
  final data = List.filled(2 * channels * 2, 0);
  return [
    ...'RIFF'.codeUnits,
    ...u32(4 + 24 + 8 + data.length),
    ...'WAVE'.codeUnits,
    ...'fmt '.codeUnits,
    ...u32(16),
    ...u16(1),
    ...u16(channels),
    ...u32(44100),
    ...u32(44100 * channels * 2),
    ...u16(channels * 2),
    ...u16(16),
    ...'data'.codeUnits,
    ...u32(data.length),
    ...data,
  ];
}

/// The owner's `jingle_oom.ogg`: a real Ogg Vorbis stream for scratch repos.
List<int> _realOgg() => File(
  p.join(findRepoRoot().path, 'design/audio/jingle_oom.ogg'),
).readAsBytesSync();

/// A minimal PNG at [width]×[height]: just enough of the signature and the
/// IHDR chunk for `validateMuseumPng` to read, since the sync ships bytes
/// unchanged and never decodes the image.
List<int> _png({int width = 600, int height = 600}) {
  List<int> u32(int v) => [
    (v >> 24) & 0xFF,
    (v >> 16) & 0xFF,
    (v >> 8) & 0xFF,
    v & 0xFF,
  ];
  return [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // signature
    ...u32(13), ...'IHDR'.codeUnits, // length, type
    ...u32(width), ...u32(height), // IHDR data
    8, 6, 0, 0, 0, // bit depth 8, color type 6 (RGBA), the rest 0
    ...u32(0), // CRC (unchecked)
  ];
}

/// A notification icon the Android converter accepts.
String _icon() => _svg(
  '<defs></defs><path d="M2 2H8V8H2Z" fill="#FFFFFF" fill-rule="evenodd"/>',
  box: '0 0 24 24',
);

/// The scratch repo's one Lottie export: the owner's `fx_sparkle`, checked
/// against its real contract entry.
final _fakeLottieTable = [lottieContractOf('fx_sparkle')!];

/// The scratch repo's one museum figurine.
const _fakeMuseumIds = ['classic'];

/// [planDesignAssetSync] for a [_fakeRepo].
AssetSyncPlan _plan(Directory root) => planDesignAssetSync(
  root,
  lottieTable: _fakeLottieTable,
  museumFigurineIds: _fakeMuseumIds,
);

/// A minimal repo with one of everything the sync copies.
Directory _fakeRepo() {
  final root = Directory.systemTemp.createTempSync('nesty_sync_');
  void write(String path, Object content) {
    final file = File(p.join(root.path, path))
      ..parent.createSync(recursive: true);
    content is String
        ? file.writeAsStringSync(content)
        : file.writeAsBytesSync(content as List<int>);
  }

  write('design/skins/classic/classic.svg', _skinSvg());
  write('design/skins/classic/skin.json', _skinJson('classic'));
  write('design/symbols/heart.svg', _svg('<path d="M0 0"/>'));
  write('design/board/shelf-plank.svg', _svg('<rect width="1" height="1"/>'));
  write('design/board/slot-stand.svg', _svg('<rect width="1" height="1"/>'));
  write(
    'design/themes/ch07_toy_attic.svg',
    _svg('<rect width="1" height="1"/>'),
  );
  write('design/audio/pick.wav', _wav());
  write('design/audio/jingle_oom.ogg', _realOgg());
  write('design/audio/AUDIO.md', '# Audio');
  write(
    'design/lottie/fx_sparkle.json',
    File(
      p.join(findRepoRoot().path, 'design/lottie/fx_sparkle.json'),
    ).readAsBytesSync(),
  );
  write('design/lottie/LOTTIE.md', '# Lottie');
  write('design/lottie/images/glow_ring.png', [0x89, 0x50, 0x4e, 0x47]);
  write('design/museum/png/01-classic.png', _png());
  write('design/museum/png/01-classic-locked.png', _png());
  for (final folder in uiArtFolders) {
    write('design/ui/$folder/${folder}_1.svg', _svg('<path d="M0 0"/>'));
  }
  write('design/ui/notification/ic_notification.svg', _icon());
  write('design/tokens.json', '{"dollColor":{"red":{"symbol":"heart"}}}');
  write(
    'apps/game/pubspec.yaml',
    'flutter:\n  assets:\n'
        '    - assets/audio/\n    - assets/board/\n'
        '    - assets/lottie/\n    - assets/museum/\n'
        '    - assets/skins/classic/\n    - assets/symbols/\n'
        '    - assets/themes/ch07/\n'
        '${uiArtFolders.map((f) => '    - assets/ui/$f/\n').join()}',
  );
  addTearDown(() => root.deleteSync(recursive: true));
  return root;
}

Iterable<String> _destinationsOf(AssetSyncPlan plan) =>
    plan.assets.map((a) => a.destination);

void main() {
  group('the real design/ handoff', () {
    final root = findRepoRoot();
    final plan = planDesignAssetSync(root);

    test('validates cleanly', () {
      expect(plan.issues, isEmpty);
    });

    test('maps every asset family', () {
      final counts = <String, int>{};
      for (final a in plan.assets) {
        counts[a.category] = (counts[a.category] ?? 0) + 1;
      }
      // 7 skins × (svg + json), 11 symbols, 20 board − 2 baked-pip stands
      // (m7-3 adds the tall glass case's 3; m7-4 chapters 7–10's own plank,
      // blank stand and blank tower, 4 × 3), 10 chapter themes, 23 SFX (WAV)
      // + 2 music loops and 5 jingles (OGG), 37 Lottie files, 10 figurines ×
      // (earned + locked) museum PNGs, and m7-3's UI art: 24 badges, 2
      // chests, 4 rival portraits, 2 sprites, 3 stars. m7-5 adds a SFX
      // (gift_claim), the gift glyph, the slot chip and the slot sprite.
      expect(counts, {
        'skins': 14,
        'symbols': 11,
        'board': 30,
        'themes': 10,
        'audio': 31,
        'lottie': 37,
        'museum': 20,
        'ui': 38,
      });
      expect(
        [
          for (final folder in uiArtFolders)
            plan.assets
                .where((a) => a.destination.startsWith('ui/$folder/'))
                .length,
        ],
        [24, 3, 1, 4, 3, 3],
      );
      expect(
        _destinationsOf(plan),
        containsAll([
          'board/glass-case-tall-0.svg',
          'themes/ch07/background.svg',
          'themes/ch10/background.svg',
          'audio/star_1.wav',
          'audio/rival_complete.wav',
          'audio/jingle_versus_win.ogg',
          'audio/jingle_versus_lose.ogg',
          'lottie/fx_glass_unlock_tall.json',
          'lottie/ui_intro_ice.json',
          'lottie/ui_rival_react.json',
          'lottie/ui_museum_idle.json',
          'board/ch07/shelf-plank.svg',
          'board/ch07/slot-stand-blank.svg',
          'board/ch10/tower-base-blank.svg',
          'ui/badges/first_family.svg',
          'ui/badges/first_family_locked.svg',
          'ui/rivals/rival_locked.svg',
          'ui/stars/star_glow.svg',
          // m7-5: the daily gift's art and sound.
          'ui/gift/gift_glyph.svg',
          'ui/chest/chip_slot.svg',
          'ui/sprites/slot_flight.svg',
          'audio/gift_claim.wav',
        ]),
      );
      expect(
        _destinationsOf(plan).where((d) => d.contains('notification')),
        isEmpty,
        reason: 'the notification icon is a platform file, not an asset',
      );
      // The notification icon, then the widget's native art (iOS catalog,
      // Android drawables and picker preview; widget_native_art_test.dart
      // owns the details).
      final paths = plan.outputs.map((o) => o.path).toList();
      expect(paths, contains(notificationIconDrawable));
      expect(
        paths.where((p) => p != notificationIconDrawable),
        everyElement(
          anyOf(
            startsWith(widgetIosCatalog),
            startsWith('$widgetAndroidRes/drawable'),
          ),
        ),
      );
      expect(paths.length, greaterThan(25));
      final destinations = plan.assets.map((a) => a.destination);
      expect(destinations, contains('skins/forest-bear/skin.svg'));
      expect(destinations, contains('themes/ch06/background.svg'));
      expect(destinations, isNot(contains('board/slot-stand.svg')));
      expect(destinations, isNot(contains('board/tower-base.svg')));
      expect(destinations, isNot(contains('board/ch07/slot-stand.svg')));
      expect(destinations, isNot(contains('board/ch09/tower-base.svg')));
      expect(destinations, contains('lottie/doll_pick.json'));
      expect(
        destinations.where((d) => d.startsWith('audio/')),
        containsAll([
          'audio/clack_1.wav',
          'audio/music_home.ogg',
          'audio/music_game.ogg',
          'audio/jingle_chapter.ogg',
          'audio/jingle_reward.ogg',
          'audio/jingle_oom.ogg',
        ]),
      );
      expect(destinations, isNot(contains('audio/AUDIO.md')));
      expect(
        destinations.where((d) => d.startsWith('lottie/')),
        everyElement(endsWith('.json')),
        reason: 'no placeholder PNG and no LOTTIE.md ships (D50)',
      );
      expect(
        destinations.where((d) => d.startsWith('museum/')),
        containsAll([
          'museum/01-classic.png',
          'museum/01-classic-locked.png',
          'museum/10-explorer.png',
          'museum/10-explorer-locked.png',
        ]),
      );
      expect(
        destinations.where((d) => d.startsWith('museum/')),
        everyElement(endsWith('.png')),
        reason: 'the museum SVGs never ship (D18)',
      );
    });

    test('ships the Lottie exports, the audio and the museum art byte for '
        'byte', () {
      for (final a in plan.assets.where(
        (a) =>
            a.category == 'lottie' ||
            a.category == 'audio' ||
            a.category == 'museum',
      )) {
        expect(
          a.bytes,
          File(p.join(root.path, a.source)).readAsBytesSync(),
          reason: a.destination,
        );
      }
    });

    test('strips every C2PA block', () {
      for (final a in plan.assets.where(
        (a) => a.destination.endsWith('.svg'),
      )) {
        final text = String.fromCharCodes(a.bytes);
        expect(text, isNot(contains('<metadata')), reason: a.destination);
        expect(text, isNot(contains('c2pa')), reason: a.destination);
        expect(a.bytes.length, lessThan(a.sourceSize), reason: a.destination);
      }
    });

    test('apps/game/assets and pubspec.yaml are in sync', () {
      final result = applyAssetSyncPlan(plan, root, dryRun: true);
      expect(
        result.outcomes.entries
            .where((e) => e.value != WriteOutcome.unchanged)
            .map((e) => e.key),
        isEmpty,
        reason: 'run dart run nesty_tools:sync_design_assets',
      );
      expect(result.removed, isEmpty);
      expect(result.missingPubspecDirs, isEmpty);
      expect(
        result.outputOutcomes.entries
            .where((e) => e.value != WriteOutcome.unchanged)
            .map((e) => e.key),
        isEmpty,
        reason: 'run dart run nesty_tools:sync_design_assets',
      );
      expect(
        result.outputOutcomes.keys,
        contains(notificationIconDrawable),
      );
    });

    test('the Android notification icon is the design file, converted', () {
      final drawable = File(
        p.join(root.path, notificationIconDrawable),
      ).readAsStringSync();
      final design = File(
        p.join(root.path, notificationIconSource),
      ).readAsStringSync();
      expect(drawable, androidVectorOf(design).xml);
      expect(drawable, contains('GENERATED'));
      expect(drawable, contains('android:fillType="evenOdd"'));
      // The reminder names it by this resource; R8 keeps it (res/raw).
      expect(
        File(
          p.join(root.path, 'apps/game/android/app/src/main/res/raw/keep.xml'),
        ).readAsStringSync(),
        contains('@drawable/ic_notification'),
      );
    });
  });

  group('sync behaviour', () {
    test('writes sanitized copies, then is a no-op', () {
      final root = _fakeRepo();
      final plan = _plan(root);
      expect(plan.issues, isEmpty);
      expect(plan.assetDirectories, [
        'assets/audio/',
        'assets/board/',
        'assets/lottie/',
        'assets/museum/',
        'assets/skins/classic/',
        'assets/symbols/',
        'assets/themes/ch07/',
        for (final folder in uiArtFolders) 'assets/ui/$folder/',
      ]);

      final first = applyAssetSyncPlan(plan, root);
      expect(first.outcomes.values.toSet(), {WriteOutcome.created});
      expect(first.missingPubspecDirs, isEmpty);
      final heart = File(
        p.join(root.path, gameAssetsDir, 'symbols', 'heart.svg'),
      ).readAsStringSync();
      expect(heart, '<svg $_ns viewBox="0 0 10 10"><path d="M0 0"/></svg>');
      expect(
        File(
          p.join(root.path, gameAssetsDir, 'themes/ch07/background.svg'),
        ).existsSync(),
        isTrue,
      );

      expect(first.outputOutcomes, {
        notificationIconDrawable: WriteOutcome.created,
      });
      expect(
        File(
          p.join(root.path, gameAssetsDir, 'ui/stars/stars_1.svg'),
        ).readAsStringSync(),
        '<svg $_ns viewBox="0 0 10 10"><path d="M0 0"/></svg>',
      );

      final second = applyAssetSyncPlan(_plan(root), root);
      expect(second.outcomes.values.toSet(), {WriteOutcome.unchanged});
      expect(second.outputOutcomes.values.toSet(), {WriteOutcome.unchanged});
      expect(second.hasDrift, isFalse);
    });

    test(
      'an edited notification drawable is drift, and the sync rewrites it',
      () {
        final root = _fakeRepo();
        applyAssetSyncPlan(_plan(root), root);
        final drawable = File(p.join(root.path, notificationIconDrawable))
          ..writeAsStringSync('<vector/>');
        final check = applyAssetSyncPlan(_plan(root), root, dryRun: true);
        expect(
          check.outputOutcomes[notificationIconDrawable],
          WriteOutcome.updated,
        );
        expect(check.hasDrift, isTrue);
        expect(drawable.readAsStringSync(), '<vector/>');
        applyAssetSyncPlan(_plan(root), root);
        expect(
          drawable.readAsStringSync(),
          contains('android:pathData="M2 2H8V8H2Z"'),
        );
      },
    );

    test('UI art: design/ui/icons is an issue, and so are unknown folders', () {
      final root = _fakeRepo();
      void write(String path, String content) => (File(
        p.join(root.path, path),
      )..parent.createSync(recursive: true)).writeAsStringSync(content);
      write('design/ui/icons/share.svg', _svg('<path d="M0 0"/>'));
      write('design/ui/frames/frame.svg', _svg('<path d="M0 0"/>'));
      write('design/ui/stars/Star Big.svg', _svg('<path d="M0 0"/>'));
      write('design/ui/stars/star.png', 'x');
      write('design/ui/readme.txt', 'x');
      final issues = _plan(root).issues;
      expect(issues, [
        'design/ui/frames: unknown UI art folder (expected badges, chest, '
            'gift, rivals, sprites, stars, icons, notification, widget)',
        'design/ui/icons/share.svg: icons ship as glyphs of the bundled '
            'font; add the glyph to tokens.json `icons` and '
            'tools/fonts/nesty_symbols.txt instead',
        'design/ui/readme.txt: unexpected file in design/ui',
        'design/ui/stars/Star Big.svg: UI art files are named [a-z0-9_]+.svg',
        'design/ui/stars/star.png: UI art files are named [a-z0-9_]+.svg',
      ]);
    });

    test('the widget art (m7-6) is validated against tokens, never shipped', () {
      final root = _fakeRepo();
      void write(String path, Object content) {
        final file = File(p.join(root.path, path))
          ..parent.createSync(recursive: true);
        content is String
            ? file.writeAsStringSync(content)
            : file.writeAsBytesSync(content as List<int>);
      }

      write(
        'design/tokens.json',
        jsonEncode({
          'dollColor': {
            'red': {'symbol': 'heart'},
          },
          'habits': {
            'widget': {
              'art': {
                'folder': 'ui/widget/',
                'files': {'mark.svg': 20},
                'previews':
                    'preview_2x2.png (6 × 6) and preview_4x2.png (12 × 6), '
                    '3× captures for Android’s previewImage',
              },
            },
          },
        }),
      );
      write(
        'design/ui/widget/mark.svg',
        _svg('<rect width="4" height="4" rx="1" fill="#F5C518"/>'),
      );
      for (final (suffix, side) in [('', 20), ('-2x', 40), ('-3x', 60)]) {
        write(
          'design/ui/widget/mark$suffix.png',
          _png(width: side, height: side),
        );
      }
      write('design/ui/widget/preview_2x2.png', _png(width: 6, height: 6));
      write('design/ui/widget/preview_4x2.png', _png(width: 12, height: 6));
      final plan = _plan(root);
      expect(plan.issues, isEmpty);
      expect(_destinationsOf(plan).where((d) => d.contains('widget')), isEmpty);

      // A gradient, a wrong raster size and a stray file each block it.
      write(
        'design/ui/widget/mark.svg',
        _svg(
          '<linearGradient id="g"/><rect width="4" height="4" fill="url(#g)"/>',
        ),
      );
      write('design/ui/widget/mark-3x.png', _png(width: 40, height: 40));
      write('design/ui/widget/notes.txt', 'x');
      expect(_plan(root).issues, [
        contains('design/ui/widget/mark.svg: <linearGradient> is not a flat'),
        'design/ui/widget/mark.svg: <rect> needs a solid fill (#RRGGBB), got '
            '"url(#g)"',
        'design/ui/widget/mark-3x.png: 40×40, expected 60×60',
        'design/ui/widget/notes.txt: not in tokens.json `habits.widget.art` '
            '(the widget art is its SVGs, their 1×/2×/3× PNGs and the two '
            'previews)',
      ]);
    });

    test('UI art is validated like the board art (spec §12.2)', () {
      final root = _fakeRepo();
      File(
        p.join(root.path, 'design/ui/badges/badges_1.svg'),
      ).writeAsStringSync(_svg('<text>hi</text>'));
      expect(_plan(root).issues, [
        contains('design/ui/badges/badges_1.svg: forbiddenElement'),
      ]);
    });

    test('a notification icon the converter refuses blocks the sync', () {
      final root = _fakeRepo();
      final icon = File(p.join(root.path, notificationIconSource));
      icon.writeAsStringSync(
        _svg('<path d="M0 0H9" fill="#F2893B"/>', box: '0 0 24 24'),
      );
      expect(_plan(root).issues, [
        '$notificationIconSource: a <path> is filled #F2893B, not white',
      ]);
      icon.deleteSync();
      expect(_plan(root).issues, [
        "$notificationIconSource: missing (the daily reminder's small icon)",
      ]);
    });

    test('removes files the design no longer has (dry run only reports)', () {
      final root = _fakeRepo();
      applyAssetSyncPlan(_plan(root), root);
      final stale = File(p.join(root.path, gameAssetsDir, 'board', 'old.svg'))
        ..writeAsStringSync('x');

      final check = applyAssetSyncPlan(_plan(root), root, dryRun: true);
      expect(check.removed, ['board/old.svg']);
      expect(check.hasDrift, isTrue);
      expect(stale.existsSync(), isTrue);

      applyAssetSyncPlan(_plan(root), root);
      expect(stale.existsSync(), isFalse);
    });

    test('detects an edited asset as drift', () {
      final root = _fakeRepo();
      applyAssetSyncPlan(_plan(root), root);
      File(
        p.join(root.path, gameAssetsDir, 'symbols', 'heart.svg'),
      ).writeAsStringSync('<svg/>');
      final check = applyAssetSyncPlan(_plan(root), root, dryRun: true);
      expect(check.outcomes['symbols/heart.svg'], WriteOutcome.updated);
    });

    test('reports asset folders missing from pubspec.yaml', () {
      final root = _fakeRepo();
      File(
        p.join(root.path, 'apps/game/pubspec.yaml'),
      ).writeAsStringSync('flutter:\n  assets:\n    - assets/audio/\n');
      final result = applyAssetSyncPlan(_plan(root), root, dryRun: true);
      expect(result.missingPubspecDirs, [
        'assets/board/',
        'assets/lottie/',
        'assets/museum/',
        'assets/skins/classic/',
        'assets/symbols/',
        'assets/themes/ch07/',
        for (final folder in uiArtFolders) 'assets/ui/$folder/',
      ]);
    });

    test('refuses to write anything when validation fails', () {
      final root = _fakeRepo();
      File(
        p.join(root.path, 'design/symbols/heart.svg'),
      ).writeAsStringSync(_svg('<text>hi</text>'));
      File(
        p.join(root.path, 'design/skins/classic/skin.json'),
      ).writeAsStringSync(_skinJson('ocean'));
      final plan = _plan(root);
      expect(
        plan.issues,
        containsAll([
          contains('design/symbols/heart.svg: forbiddenElement'),
          contains('design/skins/classic/skin.json: manifestBadValue'),
        ]),
      );
      expect(() => applyAssetSyncPlan(plan, root), throwsStateError);
      expect(Directory(p.join(root.path, gameAssetsDir)).existsSync(), isFalse);
    });

    test('flags a doll color whose symbol is missing', () {
      final root = _fakeRepo();
      File(
        p.join(root.path, 'design/tokens.json'),
      ).writeAsStringSync('{"dollColor":{"blue":{"symbol":"drop"}}}');
      expect(_plan(root).issues, contains(contains('missing drop.svg')));
    });

    test('copies the Lottie JSON only: never LOTTIE.md or images/', () {
      final root = _fakeRepo();
      applyAssetSyncPlan(_plan(root), root);
      final lottie = Directory(p.join(root.path, gameAssetsDir, 'lottie'));
      expect(
        lottie
            .listSync(recursive: true)
            .map((e) => p.relative(e.path, from: lottie.path)),
        ['fx_sparkle.json'],
      );
    });

    test('removes a PNG from assets/lottie (placeholders never ship)', () {
      final root = _fakeRepo();
      applyAssetSyncPlan(_plan(root), root);
      final png = File(
        p.join(root.path, gameAssetsDir, 'lottie', 'images', 'glow_ring.png'),
      )..createSync(recursive: true);
      final check = applyAssetSyncPlan(_plan(root), root, dryRun: true);
      expect(check.removed, ['lottie/images/glow_ring.png']);
      expect(check.hasDrift, isTrue);
      applyAssetSyncPlan(_plan(root), root);
      expect(png.existsSync(), isFalse);
    });

    test('detects an edited Lottie file as drift', () {
      final root = _fakeRepo();
      applyAssetSyncPlan(_plan(root), root);
      File(
        p.join(root.path, gameAssetsDir, 'lottie', 'fx_sparkle.json'),
      ).writeAsStringSync('{}');
      expect(
        applyAssetSyncPlan(
          _plan(root),
          root,
          dryRun: true,
        ).outcomes['lottie/fx_sparkle.json'],
        WriteOutcome.updated,
      );
    });

    test('an invalid or missing Lottie export blocks the whole sync', () {
      final root = _fakeRepo();
      final sparkle = File(p.join(root.path, 'design/lottie/fx_sparkle.json'));
      sparkle.writeAsStringSync(
        sparkle.readAsStringSync().replaceFirst('"fr":60', '"fr":30'),
      );
      final plan = _plan(root);
      expect(plan.issues, [
        'design/lottie/fx_sparkle.json: frameRate: fr is 30, expected 60',
      ]);
      expect(() => applyAssetSyncPlan(plan, root), throwsStateError);

      sparkle.deleteSync();
      expect(
        _plan(root).issues,
        contains(contains('design/lottie/fx_sparkle.json: missing')),
      );
      expect(
        planDesignAssetSync(root).issues,
        contains(contains('design/lottie/doll_pick.json: missing')),
        reason: 'the default table wants all 35 files',
      );
    });

    test('ships OGG next to WAV, never AUDIO.md', () {
      final root = _fakeRepo();
      applyAssetSyncPlan(_plan(root), root);
      final audio = Directory(p.join(root.path, gameAssetsDir, 'audio'));
      expect(audio.listSync().map((e) => p.basename(e.path)).toList()..sort(), [
        'jingle_oom.ogg',
        'pick.wav',
      ]);
    });

    test('checks the audio formats (tokens.json `sound.format`)', () {
      final root = _fakeRepo();
      File(
        p.join(root.path, 'design/audio/pick.wav'),
      ).writeAsBytesSync(_wav(channels: 2));
      File(
        p.join(root.path, 'design/audio/jingle_oom.ogg'),
      ).writeAsBytesSync(_wav());
      expect(_plan(root).issues, [
        'design/audio/jingle_oom.ogg: not an Ogg file (no OggS capture '
            'pattern)',
        'design/audio/pick.wav: 2 channels, expected 1 (mono)',
      ]);
    });

    test(
      'every tokens.json sound file ships in its format, and only those',
      () {
        final root = _fakeRepo();
        File(p.join(root.path, 'design/tokens.json')).writeAsStringSync(
          jsonEncode({
            'dollColor': {
              'red': {'symbol': 'heart'},
            },
            'motion': {
              'combo': {'maxSteps': 5},
            },
            'sound': {
              'events': {
                'pick': 'pick',
                'outOfMoves': 'jingle_oom',
                'reward': 'jingle_reward',
              },
              'music': {
                'home': {'file': 'music_home', 'frames': 193145},
                'game': {'file': 'music_game', 'frames': 3024000},
              },
            },
          }),
        );
        void write(String name, List<int> bytes) => File(
          p.join(root.path, 'design/audio', name),
        ).writeAsBytesSync(bytes);
        write('jingle_reward.wav', _wav()); // a jingle as WAV
        write('music_home.ogg', _realOgg()); // 193,145 frames: as tokens say
        write('music_game.ogg', _realOgg()); // not 3,024,000
        write('bonk.wav', _wav()); // no event plays it
        expect(_plan(root).issues, [
          'design/audio: missing jingle_reward.ogg (tokens.json `sound` names '
              'it)',
          'design/audio/bonk.wav: no tokens.json `sound` event or music track '
              'uses it',
          'design/audio/jingle_reward.wav: no tokens.json `sound` event or '
              'music track uses it',
          'design/audio/music_game.ogg: the stream is 193145 frames long, '
              'tokens.json `sound.music` says 3024000',
        ]);
      },
    );

    test('ships a chapter\'s own wood from its tokens boardArt (m7-4 A.5)', () {
      final root = _fakeRepo();
      const files = [
        'shelf-plank.svg',
        'slot-stand.svg',
        'slot-stand-blank.svg',
        'tower-base.svg',
        'tower-base-blank.svg',
      ];
      void tokens(Map<String, Object?> boardArt) =>
          File(p.join(root.path, 'design/tokens.json')).writeAsStringSync(
            jsonEncode({
              'dollColor': {
                'red': {'symbol': 'heart'},
              },
              'theme': {
                'chapters': {
                  '1': {
                    'boardArt': {'dir': 'board/'},
                  },
                  '7': {'boardArt': boardArt},
                },
              },
            }),
          );
      tokens({'dir': 'board/ch07/', 'files': files});
      for (final name in files) {
        File(p.join(root.path, 'design/board/ch07', name))
          ..createSync(recursive: true)
          ..writeAsStringSync(_svg('<rect width="1" height="1"/>'));
      }
      final plan = _plan(root);
      expect(plan.issues, isEmpty);
      expect(
        _destinationsOf(plan).where((d) => d.startsWith('board/ch07/')),
        [
          'board/ch07/shelf-plank.svg',
          'board/ch07/slot-stand-blank.svg',
          'board/ch07/tower-base-blank.svg',
        ],
        reason: 'the pip-baked stand and tower never ship (spec §10.3)',
      );
      expect(plan.assetDirectories, contains('assets/board/ch07/'));

      // A file the tokens don't list, a missing one, and a folder no
      // chapter names.
      File(
        p.join(root.path, 'design/board/ch07/extra-slot.svg'),
      ).writeAsStringSync(_svg(''));
      File(p.join(root.path, 'design/board/ch07/shelf-plank.svg')).deleteSync();
      Directory(p.join(root.path, 'design/board/ch08')).createSync();
      expect(_plan(root).issues, [
        contains('design/board/ch07/extra-slot.svg: not in tokens.json'),
        'design/board/ch07/shelf-plank.svg: missing (tokens.json boardArt)',
        contains('design/board/ch08: no tokens.json'),
      ]);

      // A chapter the tokens give its own wood, with no folder.
      Directory(
        p.join(root.path, 'design/board/ch07'),
      ).deleteSync(recursive: true);
      Directory(p.join(root.path, 'design/board/ch08')).deleteSync();
      expect(_plan(root).issues, [
        'design/board/ch07: missing (tokens.json boardArt names it)',
      ]);
      tokens({'dir': 'board/chapter7/', 'files': files});
      expect(_plan(root).issues, [
        contains('`theme.chapters.7.boardArt` needs a board/chNN/ dir'),
      ]);
    });

    test('rejects badly named theme and audio files', () {
      final root = _fakeRepo();
      File(
        p.join(root.path, 'design/themes/Chapter 8.svg'),
      ).writeAsStringSync(_svg(''));
      File(p.join(root.path, 'design/audio/Pick.mp3')).writeAsStringSync('x');
      expect(_plan(root).issues, hasLength(2));
    });

    test('ships the museum figurine PNGs byte for byte', () {
      final root = _fakeRepo();
      applyAssetSyncPlan(_plan(root), root);
      final earned = File(
        p.join(root.path, gameAssetsDir, 'museum', '01-classic.png'),
      ).readAsBytesSync();
      expect(
        earned,
        File(
          p.join(root.path, 'design/museum/png/01-classic.png'),
        ).readAsBytesSync(),
      );
    });

    test('flags a museum PNG of the wrong size', () {
      final root = _fakeRepo();
      File(
        p.join(root.path, 'design/museum/png/01-classic.png'),
      ).writeAsBytesSync(_png(width: 300, height: 600));
      expect(_plan(root).issues, [
        'design/museum/png/01-classic.png: 300×600, expected 600×600',
      ]);
    });

    test('flags a museum file with a bad PNG signature', () {
      final root = _fakeRepo();
      File(
        p.join(root.path, 'design/museum/png/01-classic.png'),
      ).writeAsBytesSync(utf8.encode('not a png'));
      expect(_plan(root).issues, [
        'design/museum/png/01-classic.png: not a PNG file (bad signature)',
      ]);
    });

    test(
      'flags an unexpected file and a missing figurine in design/museum',
      () {
        final root = _fakeRepo();
        File(
          p.join(root.path, 'design/museum/png/01-classic.png'),
        ).deleteSync();
        File(
          p.join(root.path, 'design/museum/png/99-mystery.png'),
        ).writeAsBytesSync(_png());
        expect(_plan(root).issues, [
          'design/museum/png/99-mystery.png: not one of the expected museum '
              'figurines',
          'design/museum/png/01-classic.png: missing',
        ]);
      },
    );

    test('flags a missing design/museum/png folder', () {
      final root = _fakeRepo();
      Directory(p.join(root.path, 'design/museum')).deleteSync(recursive: true);
      expect(_plan(root).issues, contains('design/museum/png: missing'));
    });
  });
}
