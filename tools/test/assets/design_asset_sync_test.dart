import 'dart:io';

import 'package:nesty_tools/src/assets/design_asset_sync.dart';
import 'package:nesty_tools/src/file_writes.dart';
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
  write('design/audio/pick.wav', [
    ...'RIFF'.codeUnits,
    0, 0, 0, 0, //
    ...'WAVE'.codeUnits,
    1, 2, 3,
  ]);
  write('design/tokens.json', '{"dollColor":{"red":{"symbol":"heart"}}}');
  write(
    'apps/game/pubspec.yaml',
    'flutter:\n  assets:\n'
        '    - assets/audio/\n    - assets/board/\n'
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
      // 6 chapter themes, 17 placeholder SFX.
      expect(counts, {
        'skins': 14,
        'symbols': 11,
        'board': 15,
        'themes': 6,
        'audio': 17,
      });
      final destinations = plan.assets.map((a) => a.destination);
      expect(destinations, contains('skins/forest-bear/skin.svg'));
      expect(destinations, contains('themes/ch06/background.svg'));
      expect(destinations, isNot(contains('board/slot-stand.svg')));
      expect(destinations, isNot(contains('board/tower-base.svg')));
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
      final plan = planDesignAssetSync(root);
      expect(plan.issues, isEmpty);
      expect(plan.assetDirectories, [
        'assets/audio/',
        'assets/board/',
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

      final second = applyAssetSyncPlan(planDesignAssetSync(root), root);
      expect(second.outcomes.values.toSet(), {WriteOutcome.unchanged});
      expect(second.hasDrift, isFalse);
    });

    test('removes files the design no longer has (dry run only reports)', () {
      final root = _fakeRepo();
      applyAssetSyncPlan(planDesignAssetSync(root), root);
      final stale = File(p.join(root.path, gameAssetsDir, 'board', 'old.svg'))
        ..writeAsStringSync('x');

      final check = applyAssetSyncPlan(
        planDesignAssetSync(root),
        root,
        dryRun: true,
      );
      expect(check.removed, ['board/old.svg']);
      expect(check.hasDrift, isTrue);
      expect(stale.existsSync(), isTrue);

      applyAssetSyncPlan(planDesignAssetSync(root), root);
      expect(stale.existsSync(), isFalse);
    });

    test('detects an edited asset as drift', () {
      final root = _fakeRepo();
      applyAssetSyncPlan(planDesignAssetSync(root), root);
      File(
        p.join(root.path, gameAssetsDir, 'symbols', 'heart.svg'),
      ).writeAsStringSync('<svg/>');
      final check = applyAssetSyncPlan(
        planDesignAssetSync(root),
        root,
        dryRun: true,
      );
      expect(check.outcomes['symbols/heart.svg'], WriteOutcome.updated);
    });

    test('reports asset folders missing from pubspec.yaml', () {
      final root = _fakeRepo();
      File(
        p.join(root.path, 'apps/game/pubspec.yaml'),
      ).writeAsStringSync('flutter:\n  assets:\n    - assets/audio/\n');
      final result = applyAssetSyncPlan(
        planDesignAssetSync(root),
        root,
        dryRun: true,
      );
      expect(result.missingPubspecDirs, [
        'assets/board/',
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
      final plan = planDesignAssetSync(root);
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
      expect(
        planDesignAssetSync(root).issues,
        contains(contains('missing drop.svg')),
      );
    });

    test('rejects badly named theme and audio files', () {
      final root = _fakeRepo();
      File(
        p.join(root.path, 'design/themes/Chapter 8.svg'),
      ).writeAsStringSync(_svg(''));
      File(p.join(root.path, 'design/audio/Pick.mp3')).writeAsStringSync('x');
      expect(planDesignAssetSync(root).issues, hasLength(2));
    });
  });
}
