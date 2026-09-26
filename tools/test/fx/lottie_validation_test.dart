import 'dart:convert';
import 'dart:io';

import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/fx/lottie_sources.dart';
import 'package:nesty_tools/src/fx/lottie_validation.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _root = findRepoRoot();

/// A fresh, mutable copy of the owner's export [name].
Map<String, Object?> _real(String name) =>
    jsonDecode(
          File(
            p.join(_root.path, designLottieDir, '$name.json'),
          ).readAsStringSync(),
        )
        as Map<String, Object?>;

List<String> _codes(Map<String, Object?> json, String name) => [
  for (final issue in validateLottie(json, lottieContractOf(name)!)) issue.code,
];

List<Map<String, Object?>> _layers(Map<String, Object?> json) =>
    (json['layers']! as List<Object?>).cast<Map<String, Object?>>();

Map<String, Object?> _layer(Map<String, Object?> json, String name) =>
    _layers(json).firstWhere((l) => l['nm'] == name);

Map<String, Object?> _ks(Map<String, Object?> layer, String key) =>
    (layer['ks']! as Map<String, Object?>)[key]! as Map<String, Object?>;

List<Map<String, Object?>> _keyframes(Map<String, Object?> prop) =>
    (prop['k']! as List<Object?>).cast<Map<String, Object?>>();

Map<String, Object?> _asset(Map<String, Object?> json, String id) =>
    (json['assets']! as List<Object?>).cast<Map<String, Object?>>().firstWhere(
      (a) => a['id'] == id,
    );

void main() {
  group('the owner\'s exports', () {
    test('all 29 validate against the contract with no issue', () {
      final set = readDesignLottie(_root);
      expect(set.issues, isEmpty);
      expect(set.sources.map((s) => s.name), [
        for (final c in lottieContracts) c.name,
      ]);
    });

    test('trim paths (ui_spinner) and polystars (fx_sparkle) are fine', () {
      expect(_codes(_real('ui_spinner'), 'ui_spinner'), isEmpty);
      expect(_codes(_real('fx_sparkle'), 'fx_sparkle'), isEmpty);
    });

    test('an inverted alpha matte (tt 2) is fine', () {
      final json = _real('doll_complete');
      _layer(json, 'shine')['tt'] = 2;
      expect(_codes(json, 'doll_complete'), isEmpty);
    });
  });

  group('the header against LOTTIE.md "Files"', () {
    test('version, frame rate, in point, length and canvas', () {
      Map<String, Object?> pick(void Function(Map<String, Object?>) edit) {
        final json = _real('doll_pick');
        edit(json);
        return json;
      }

      expect(_codes(pick((j) => j['v'] = '5.6.0'), 'doll_pick'), [
        LottieIssueCodes.version,
      ]);
      expect(_codes(pick((j) => j['fr'] = 30), 'doll_pick'), [
        LottieIssueCodes.frameRate,
      ]);
      expect(_codes(pick((j) => j['ip'] = 1), 'doll_pick'), [
        LottieIssueCodes.inPoint,
      ]);
      expect(_codes(pick((j) => j['op'] = 42), 'doll_pick'), [
        LottieIssueCodes.length,
      ]);
      expect(_codes(pick((j) => j['op'] = 41.5), 'doll_pick'), [
        LottieIssueCodes.length,
      ]);
      expect(_codes(pick((j) => j['w'] = 161), 'doll_pick'), [
        LottieIssueCodes.canvas,
      ]);
      expect(_codes(pick((j) => j['ddd'] = 1), 'doll_pick'), [
        LottieIssueCodes.threeD,
      ]);
    });

    test('markers must be exactly the table\'s segments', () {
      final shifted = _real('doll_pick');
      ((shifted['markers']! as List<Object?>)[1]! as Map)['dr'] = 25;
      expect(_codes(shifted, 'doll_pick'), [LottieIssueCodes.markers]);

      final renamed = _real('fx_ice');
      ((renamed['markers']! as List<Object?>)[3]! as Map)['cm'] = 'burst';
      expect(_codes(renamed, 'fx_ice'), [LottieIssueCodes.markers]);

      final extra = _real('doll_move')
        ..['markers'] = [
          {'cm': 'go', 'tm': 0, 'dr': 16},
        ];
      expect(_codes(extra, 'doll_move'), [LottieIssueCodes.markers]);
    });

    test('a root that is not an object', () {
      expect(
        validateLottie(const [], lottieContractOf('doll_pick')!).single.code,
        LottieIssueCodes.notObject,
      );
    });
  });

  group('image slots (LOTTIE.md "Image slots")', () {
    test('ids must be exactly the contract\'s, and all slots', () {
      final json = _real('doll_pick');
      (json['assets']! as List<Object?>).add({
        'id': 'doll_eyes',
        'w': 10,
        'h': 10,
        'u': 'images/',
        'p': 'eyes.png',
        'e': 0,
      });
      expect(_codes(json, 'doll_pick'), [
        LottieIssueCodes.imageAssets, // not a slot
        LottieIssueCodes.imageAssets, // not the contract's set
      ]);
    });

    test('declared sizes, embedded images and dangling refs', () {
      final size = _real('doll_pick');
      _asset(size, 'doll_lid')['w'] = 256;
      expect(_codes(size, 'doll_pick'), [LottieIssueCodes.imageSize]);

      final embedded = _real('doll_pick');
      _asset(embedded, 'doll_lid')
        ..['e'] = 1
        ..['p'] = 'data:image/png;base64,AAAA';
      expect(_codes(embedded, 'doll_pick'), [LottieIssueCodes.embeddedImage]);

      final dangling = _real('doll_pick');
      _layer(dangling, 'doll_lid')['refId'] = 'nope';
      expect(_codes(dangling, 'doll_pick'), [LottieIssueCodes.missingRef]);
    });

    test('an image layer\'s anchor must be static (compensation)', () {
      final json = _real('doll_pick');
      (_layer(json, 'doll_lid')['ks']! as Map<String, Object?>)['a'] = {
        'a': 1,
        'k': [
          {
            't': 0,
            's': [256, 742, 0],
          },
          {
            't': 10,
            's': [250, 742, 0],
          },
        ],
      };
      expect(_codes(json, 'doll_pick'), [LottieIssueCodes.imageAnchor]);
    });
  });

  group('blocked features', () {
    test('expressions', () {
      final json = _real('doll_move');
      _ks(_layer(json, 'travel'), 'p')['x'] = 'wiggle(2, 10)';
      expect(_codes(json, 'doll_move'), [LottieIssueCodes.expression]);
    });

    test('effects and layer styles', () {
      final json = _real('doll_pick');
      _layer(json, 'doll')['ef'] = <Object?>[];
      _layer(json, 'doll_lid')['sy'] = <Object?>[];
      expect(
        _codes(json, 'doll_pick'),
        unorderedEquals([LottieIssueCodes.effect, LottieIssueCodes.layerStyle]),
      );
    });

    test('merge paths, also inside a group', () {
      final json = _real('fx_sparkle');
      final shapes = _layer(json, 'sparkle')['shapes']! as List<Object?>;
      shapes.add({
        'ty': 'gr',
        'nm': 'group',
        'it': [
          {'ty': 'mm', 'nm': 'merge', 'mm': 1},
        ],
      });
      expect(_codes(json, 'fx_sparkle'), [LottieIssueCodes.mergePath]);
    });

    test('shape types lottie drops', () {
      final json = _real('fx_sparkle');
      (_layer(json, 'sparkle')['shapes']! as List<Object?>).add({
        'ty': 'pb',
        'nm': 'pucker',
      });
      expect(_codes(json, 'fx_sparkle'), [LottieIssueCodes.unsupportedShape]);
    });

    test('luma and luma-inverted mattes (tt 3, 4)', () {
      for (final tt in [3, 4, 7]) {
        final json = _real('doll_complete');
        _layer(json, 'shine')['tt'] = tt;
        expect(_codes(json, 'doll_complete'), [
          LottieIssueCodes.lumaMatte,
        ], reason: 'tt $tt');
      }
    });

    test('matte parents, 3D layers and time remap', () {
      final json = _real('doll_complete');
      _layer(json, 'shine')['tp'] = 6;
      _layer(json, 'doll')['ddd'] = 1;
      _layer(json, 'doll_lid')['tm'] = {'a': 0, 'k': 0};
      expect(
        _codes(json, 'doll_complete'),
        unorderedEquals([
          LottieIssueCodes.matteParent,
          LottieIssueCodes.threeD,
          LottieIssueCodes.timeRemap,
        ]),
      );
    });

    test('checks layers inside precomps too', () {
      final json = _real('doll_reveal');
      final colorDoll = _asset(json, 'color_doll');
      ((colorDoll['layers']! as List<Object?>).first! as Map)['ef'] =
          <Object?>[];
      expect(_codes(json, 'doll_reveal'), [LottieIssueCodes.effect]);
    });

    test('layer types lottie can\'t draw (camera, audio)', () {
      final json = _real('fx_sparkle');
      (json['layers']! as List<Object?>).add({
        'ty': 13,
        'nm': 'camera',
        'ind': 99,
      });
      expect(_codes(json, 'fx_sparkle'), [LottieIssueCodes.unsupportedLayer]);
    });

    test('text outside the three text files', () {
      final json = _real('fx_sparkle');
      (json['layers']! as List<Object?>).add({
        'ty': 5,
        'nm': 'caption',
        'ind': 99,
      });
      expect(_codes(json, 'fx_sparkle'), [LottieIssueCodes.text]);
    });
  });

  group('named hooks', () {
    test('size nulls must be exactly the roles, static and nulls', () {
      final missing = _real('doll_pick');
      _layers(missing).removeWhere((l) => l['nm'] == 'doll_size');
      expect(_codes(missing, 'doll_pick'), [LottieIssueCodes.hooks]);

      final animated = _real('doll_pick');
      (_layer(animated, 'doll_size')['ks']! as Map<String, Object?>)['s'] = {
        'a': 1,
        'k': [
          {
            't': 0,
            's': [100, 100, 100],
          },
          {
            't': 5,
            's': [90, 90, 100],
          },
        ],
      };
      expect(_codes(animated, 'doll_pick'), [LottieIssueCodes.hooks]);

      final stray = _real('doll_move');
      (stray['layers']! as List<Object?>).add({
        'ty': 3,
        'nm': 'mover_size',
        'ind': 99,
        'ks': <String, Object?>{},
      });
      expect(_codes(stray, 'doll_move'), [LottieIssueCodes.hooks]);
    });

    test('travel and target_pos are where the contract says', () {
      final renamed = _real('doll_move');
      _layer(renamed, 'travel')['nm'] = 'path';
      expect(_codes(renamed, 'doll_move'), [LottieIssueCodes.hooks]);

      final stray = _real('doll_move');
      (stray['layers']! as List<Object?>).add({
        'ty': 3,
        'nm': 'target_pos',
        'ind': 99,
        'ks': <String, Object?>{},
      });
      expect(_codes(stray, 'doll_move'), [LottieIssueCodes.hooks]);

      final duplicated = _real('doll_move');
      (duplicated['layers']! as List<Object?>).add(
        jsonDecode(jsonEncode(_layer(duplicated, 'travel'))),
      );
      expect(_codes(duplicated, 'doll_move'), [LottieIssueCodes.hooks]);
    });

    test('the layers the runtime keys on must exist', () {
      final json = _real('fx_glass_unlock');
      _layer(json, 'padlock_ping')['nm'] = 'padlock';
      expect(_codes(json, 'fx_glass_unlock'), [LottieIssueCodes.hooks]);

      final counter = _real('ui_family_counter');
      _layer(counter, 'counter')['nm'] = 'pill_null';
      expect(_codes(counter, 'ui_family_counter'), [LottieIssueCodes.hooks]);
    });

    test('rim_tint and tint fills are exactly the contract\'s', () {
      final missing = _real('doll_nest');
      final rim = _layer(missing, 'target_rim');
      final group = (rim['shapes']! as List<Object?>)[1]! as Map;
      ((group['it']! as List<Object?>)[1]! as Map)['nm'] = 'rim_fill';
      expect(_codes(missing, 'doll_nest'), [LottieIssueCodes.fills]);

      final stray = _real('fx_sparkle');
      void rename(List<Object?> shapes) {
        for (final s in shapes.cast<Map<String, Object?>>()) {
          if (s['ty'] == 'fl') s['nm'] = 'tint';
          if (s['ty'] == 'gr') rename(s['it']! as List<Object?>);
        }
      }

      rename(_layer(stray, 'sparkle')['shapes']! as List<Object?>);
      expect(_codes(stray, 'fx_sparkle'), [LottieIssueCodes.fills]);
    });

    test('a hook fill name on a stroke or a layer is refused', () {
      final stroke = _real('fx_twinkle');
      (_layer(stroke, 'twinkle')['shapes']! as List<Object?>).add({
        'ty': 'st',
        'nm': 'tint',
      });
      expect(_codes(stroke, 'fx_twinkle'), [LottieIssueCodes.fills]);

      final layer = _real('fx_twinkle');
      _layer(layer, 'twinkle')['nm'] = 'tint';
      expect(_codes(layer, 'fx_twinkle'), [LottieIssueCodes.fills]);
    });

    test('the text files name exactly their text layers', () {
      final json = _real('ui_win_ribbon');
      _layer(json, 'label_shadow')['nm'] = 'shadow';
      expect(_codes(json, 'ui_win_ribbon'), [LottieIssueCodes.text]);
    });
  });

  group('the travel null (LOTTIE.md "Travel remap")', () {
    Map<String, Object?> travelOf(Map<String, Object?> json) =>
        _layer(json, 'travel');

    test('starts at S', () {
      final json = _real('doll_move');
      _keyframes(_ks(travelOf(json), 'p')).first['s'] = [110, 500, 0];
      expect(_codes(json, 'doll_move'), [LottieIssueCodes.travel]);
    });

    test('stays on the S→T line, with no spatial tangents', () {
      final off = _real('doll_invalid');
      _keyframes(_ks(travelOf(off), 'p'))[1]['s'] = [200, 510, 0];
      expect(_codes(off, 'doll_invalid'), [LottieIssueCodes.travel]);

      final curved = _real('doll_move');
      _keyframes(_ks(travelOf(curved), 'p')).first['to'] = [0, -40, 0];
      expect(_codes(curved, 'doll_move'), [LottieIssueCodes.travel]);

      // Zero tangents are what a straight export writes: fine.
      final straight = _real('doll_move');
      _keyframes(_ks(travelOf(straight), 'p')).first
        ..['to'] = [0, 0, 0]
        ..['ti'] = [0, 0, 0];
      expect(_codes(straight, 'doll_move'), isEmpty);
    });

    test('is an unparented null with a static zero anchor, not split', () {
      final parented = _real('doll_move');
      travelOf(parented)['parent'] = 3;
      expect(_codes(parented, 'doll_move'), [LottieIssueCodes.travel]);

      final anchored = _real('doll_complete');
      _ks(travelOf(anchored), 'a')['k'] = [5, 0, 0];
      expect(_codes(anchored, 'doll_complete'), [LottieIssueCodes.travel]);

      final split = _real('ui_drag_hand');
      (travelOf(split)['ks']! as Map<String, Object?>)['p'] = {
        's': true,
        'x': {'a': 0, 'k': 100},
        'y': {'a': 0, 'k': 500},
      };
      expect(_codes(split, 'ui_drag_hand'), [LottieIssueCodes.travel]);
    });
  });

  group('readDesignLottie on a scratch repo', () {
    late Directory root;
    const table = [
      LottieFileContract(
        'fx_sparkle',
        width: 64,
        height: 64,
        frames: 16,
        kind: LottieKind.inPlace,
        anchor: LottiePoint(32, 32),
      ),
    ];

    setUp(() {
      root = Directory.systemTemp.createTempSync('nesty_lottie_');
      addTearDown(() => root.deleteSync(recursive: true));
      final dir = Directory(p.join(root.path, designLottieDir))
        ..createSync(recursive: true);
      File(
        p.join(_root.path, designLottieDir, 'fx_sparkle.json'),
      ).copySync(p.join(dir.path, 'fx_sparkle.json'));
      File(p.join(dir.path, lottieContractDoc)).writeAsStringSync('# doc');
      File(p.join(dir.path, lottiePlaceholderDir, 'glow_ring.png'))
        ..createSync(recursive: true)
        ..writeAsBytesSync([0x89, 0x50]);
    });

    File file(String name) => File(p.join(root.path, designLottieDir, name));

    test('reads the JSON and skips LOTTIE.md and images/', () {
      final set = readDesignLottie(root, contracts: table);
      expect(set.issues, isEmpty);
      expect(set.sources.single.path, 'design/lottie/fx_sparkle.json');
      expect(
        set.sources.single.bytes,
        file('fx_sparkle.json').readAsBytesSync(),
      );
    });

    test('reports a missing file, junk and files with no contract', () {
      file('fx_sparkle.json').deleteSync();
      file('doll_dance.json').writeAsStringSync('{}');
      file('notes.txt').writeAsStringSync('x');
      Directory(p.join(root.path, designLottieDir, 'old')).createSync();
      final issues = readDesignLottie(root, contracts: table).issues;
      expect(issues, [
        contains('doll_dance.json: no contract entry'),
        contains('notes.txt: unexpected file'),
        contains('design/lottie/old: unexpected folder'),
        contains('design/lottie/fx_sparkle.json: missing'),
      ]);
    });

    test('reports a file that is not JSON', () {
      file('fx_sparkle.json').writeAsStringSync('{"v": ');
      expect(
        readDesignLottie(root, contracts: table).issues.single,
        startsWith('design/lottie/fx_sparkle.json: notJson'),
      );
    });

    test('prefixes each validation issue with the file', () {
      final json =
          jsonDecode(file('fx_sparkle.json').readAsStringSync())
              as Map<String, Object?>;
      json['fr'] = 30;
      file('fx_sparkle.json').writeAsStringSync(jsonEncode(json));
      expect(readDesignLottie(root, contracts: table).issues, [
        'design/lottie/fx_sparkle.json: frameRate: fr is 30, expected 60',
      ]);
    });
  });
}
