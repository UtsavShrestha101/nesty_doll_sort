import 'dart:convert';
import 'dart:io';

import 'package:nesty_tools/src/assets/design_asset_sync.dart';
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

/// The scratch repo's one Lottie export: the owner's `fx_sparkle`, checked
/// against its real contract entry.
final _fakeLottieTable = [lottieContractOf('fx_sparkle')!];

/// [planDesignAssetSync] for a [_fakeRepo].
AssetSyncPlan _plan(Directory root) =>
    planDesignAssetSync(root, lottieTable: _fakeLottieTable);

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
  write('design/tokens.json', '{"dollColor":{"red":{"symbol":"heart"}}}');
  write(
    'apps/game/pubspec.yaml',
    'flutter:\n  assets:\n'
        '    - assets/audio/\n    - assets/board/\n'
        '    - assets/lottie/\n'
        '    - assets/skins/classic/\n    - assets/symbols/\n'
        '    - assets/themes/ch07/\n',
  );
  addTearDown(() => root.deleteSync(recursive: true));
  return root;
}

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
      // 7 skins × (svg + json), 11 symbols, 17 board − 2 baked-pip stands,
      // 6 chapter themes, 17 SFX (WAV) + 2 music loops and 3 jingles (OGG),
      // 29 Lottie files.
      expect(counts, {
        'skins': 14,
        'symbols': 11,
        'board': 15,
        'themes': 6,
        'audio': 22,
        'lottie': 29,
      });
      final destinations = plan.assets.map((a) => a.destination);
      expect(destinations, contains('skins/forest-bear/skin.svg'));
      expect(destinations, contains('themes/ch06/background.svg'));
      expect(destinations, isNot(contains('board/slot-stand.svg')));
      expect(destinations, isNot(contains('board/tower-base.svg')));
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
    });

    test('ships the Lottie exports and the audio byte for byte', () {
      for (final a in plan.assets.where(
        (a) => a.category == 'lottie' || a.category == 'audio',
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
        'assets/skins/classic/',
        'assets/symbols/',
        'assets/themes/ch07/',
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

      final second = applyAssetSyncPlan(_plan(root), root);
      expect(second.outcomes.values.toSet(), {WriteOutcome.unchanged});
      expect(second.hasDrift, isFalse);
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
        'assets/skins/classic/',
        'assets/symbols/',
        'assets/themes/ch07/',
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
        reason: 'the default table wants all 29 files',
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

    test('rejects badly named theme and audio files', () {
      final root = _fakeRepo();
      File(
        p.join(root.path, 'design/themes/Chapter 8.svg'),
      ).writeAsStringSync(_svg(''));
      File(p.join(root.path, 'design/audio/Pick.mp3')).writeAsStringSync('x');
      expect(_plan(root).issues, hasLength(2));
    });
  });
}
