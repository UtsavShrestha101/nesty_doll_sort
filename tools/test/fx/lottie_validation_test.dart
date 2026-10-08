import 'dart:convert';
import 'dart:io';

import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/fx/lottie_json.dart';
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
    test('all 37 validate against the contract with no issue', () {
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

    test('an image layer\'s transform must be static (compensation, v3)', () {
      Map<String, Object?> animated(List<num> from, List<num> to) => {
        'a': 1,
        'k': [
          {'t': 0, 's': from},
          {'t': 10, 's': to},
        ],
      };
      for (final (key, value) in [
        ('a', animated([256, 742, 0], [250, 742, 0])),
        ('p', animated([0, 0, 0], [0, -45, 0])),
        ('s', animated([19.53, 19.53, 100], [21, 21, 100])),
        ('r', animated([0], [8])),
        (
          'p',
          {
            's': true,
            'x': {'a': 0, 'k': 0},
            'y': animated([0], [-45]),
          },
        ),
      ]) {
        final json = _real('doll_pick');
        (_layer(json, 'doll_lid')['ks']! as Map<String, Object?>)[key] = value;
        expect(_codes(json, 'doll_pick'), [
          LottieIssueCodes.imageTransform,
        ], reason: key);
      }

      // Inside a precomp too; an animated opacity is fine (it isn't
      // inherited through parenting, so it stays on the image layer).
      final precomp = _real('doll_reveal');
      final lid = (_asset(precomp, 'color_doll')['layers']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .firstWhere((l) => l['nm'] == 'lid');
      (lid['ks']! as Map<String, Object?>)['s'] = animated(
        [100, 100, 100],
        [90, 90, 100],
      );
      expect(_codes(precomp, 'doll_reveal'), [LottieIssueCodes.imageTransform]);
      final fading = _real('fx_select_glow');
      expect(
        lottieIsAnimated(_ks(_layer(fading, 'glow_ring'), 'o')),
        isTrue,
        reason: 'the glow ring fades by opacity',
      );
      expect(_codes(fading, 'fx_select_glow'), isEmpty);
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

    test('m7-3: the intro loops author their size nulls, animated or not', () {
      // `family_size` shrinks the family into the counter (ui_intro_glass).
      expect(
        lottieIsAnimated(
          _ks(_layer(_real('ui_intro_glass'), 'family_size'), 's'),
        ),
        isTrue,
      );
      expect(_codes(_real('ui_intro_glass'), 'ui_intro_glass'), isEmpty);
      // They must still be exactly the roles: a missing doll is an issue.
      final missing = _real('ui_intro_ice');
      _layers(missing).removeWhere((l) => l['nm'] == 'family_2_size');
      expect(_codes(missing, 'ui_intro_ice'), [LottieIssueCodes.hooks]);
    });

    test(
      'm7-1: case_size is a static, unique null (LOTTIE.md "Case size")',
      () {
        Map<String, Object?> tall() => _real('fx_glass_unlock_tall');

        final missing = tall();
        _layers(missing).removeWhere((l) => l['nm'] == 'case_size');
        expect(_codes(missing, 'fx_glass_unlock_tall'), contains('hooks'));

        final animated = tall();
        (_layer(animated, 'case_size')['ks']! as Map<String, Object?>)['s'] = {
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
        expect(_codes(animated, 'fx_glass_unlock_tall'), [
          LottieIssueCodes.hooks,
        ]);

        final shape = tall();
        _layer(shape, 'case_size')['ty'] = 4; // A shape layer.
        expect(_codes(shape, 'fx_glass_unlock_tall'), [LottieIssueCodes.hooks]);

        final twice = tall();
        (twice['layers']! as List<Object?>).add({
          ..._layer(twice, 'case_size'),
          'ind': 99,
        });
        expect(_codes(twice, 'fx_glass_unlock_tall'), [LottieIssueCodes.hooks]);
      },
    );

    test('m7-3: ui_extra_slot rests on its `rest` marker at frame 0', () {
      expect(_codes(_real('ui_extra_slot'), 'ui_extra_slot'), isEmpty);
      final none = _real('ui_extra_slot')..remove('markers');
      expect(_codes(none, 'ui_extra_slot'), [LottieIssueCodes.markers]);
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

    test('so must the parent nulls that carry every pulse, bob and lift', () {
      for (final (file, name) in const [
        ('doll_nest', 'target_lid_lift'),
        ('doll_swallow', 'mover_lid_lift'),
        ('fx_select_glow', 'glow_pulse'),
        ('fx_ice', 'shatter_burst'),
        ('ui_hint_arrow', 'arrow_bob'),
        ('ui_extra_slot', 'slot_pulse'),
      ]) {
        final json = _real(file);
        _layer(json, name)['nm'] = '${name}_old';
        expect(_codes(json, file), [LottieIssueCodes.hooks], reason: name);
      }
    });

    test('rim_tint and tint fills are exactly the contract\'s', () {
      final missing = _real('doll_nest');
      final rim = _layer(missing, 'target_rim');
      final group = (rim['shapes']! as List<Object?>)[1]! as Map;
      ((group['it']! as List<Object?>)[1]! as Map)['nm'] = 'rim';
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

    test('the m7-4 named fills and rectangles are exactly the contract\'s', () {
      // "Tint and width": every ribbon fill the delegates key on.
      for (final name in ['ui_win_ribbon', 'ui_chapter_ribbon']) {
        expect(lottieContractOf(name)!.tintFills, {
          'band_fill',
          'edge_fill',
          'hi_fill',
          'tail_fill',
          'fold_fill',
        });
      }
      expect(lottieContractOf('ui_family_counter')!.sizedRects, {
        'pill_rect',
        'glow_rect',
      });
      // m7-5: both ribbons' bands take a width.
      for (final name in ['ui_win_ribbon', 'ui_chapter_ribbon']) {
        expect(lottieContractOf(name)!.sizedRects, {
          'band_rect',
          'edge_rect',
          'hi_rect',
        });
      }

      void renameAll(Map<String, Object?> layer, String from, String to) {
        void visit(List<Object?> shapes) {
          for (final s in shapes.cast<Map<String, Object?>>()) {
            if (s['nm'] == from) s['nm'] = to;
            if (s['ty'] == 'gr') visit(s['it']! as List<Object?>);
          }
        }

        visit(layer['shapes']! as List<Object?>);
      }

      // m7-3's ribbons, every fill called `fill`: the tails are lost.
      final ribbon = _real('ui_win_ribbon');
      renameAll(_layer(ribbon, 'tail_l'), 'tail_fill', 'fill');
      renameAll(_layer(ribbon, 'tail_r'), 'tail_fill', 'fill');
      expect(_codes(ribbon, 'ui_win_ribbon'), [LottieIssueCodes.namedShapes]);

      // m7-4's ribbons, the rects unnamed: the game can't set a width.
      final chapter = _real('ui_chapter_ribbon');
      renameAll(_layer(chapter, 'band'), 'hi_rect', 'rect');
      expect(_codes(chapter, 'ui_chapter_ribbon'), [
        LottieIssueCodes.namedShapes,
      ]);

      final counter = _real('ui_family_counter');
      renameAll(_layer(counter, 'pill'), 'pill_rect', 'rect');
      expect(_codes(counter, 'ui_family_counter'), [
        LottieIssueCodes.namedShapes,
      ]);

      // A `_fill` name on a stroke, and a stray one on a file with none.
      final stroke = _real('ui_family_counter');
      (_layer(stroke, 'glow')['shapes']! as List<Object?>).add({
        'ty': 'st',
        'nm': 'glow_fill',
      });
      expect(_codes(stroke, 'ui_family_counter'), [
        LottieIssueCodes.namedShapes,
      ]);
      final stray = _real('fx_sparkle');
      renameAll(_layer(stray, 'sparkle'), 'fill', 'gold_fill');
      expect(_codes(stray, 'fx_sparkle'), [LottieIssueCodes.namedShapes]);
    });

    test('the m7-6 chest rays fade through a gradient matte fill', () {
      expect(lottieContractOf('ui_chest')!.matteFills, {'falloff_fill'});
      expect(_codes(_real('ui_chest'), 'ui_chest'), isEmpty);

      List<Object?> falloffShapes(Map<String, Object?> json) =>
          ((_layer(json, 'rays_matte')['shapes']! as List<Object?>).first!
                  as Map<String, Object?>)['it']!
              as List<Object?>;

      // Off its alpha matte the gradient would draw over the chest.
      final unmatted = _real('ui_chest');
      _layer(unmatted, 'rays_matte').remove('td');
      expect(_codes(unmatted, 'ui_chest'), [LottieIssueCodes.namedShapes]);
      final untracked = _real('ui_chest');
      _layer(untracked, 'rays').remove('tt');
      expect(_codes(untracked, 'ui_chest'), [LottieIssueCodes.namedShapes]);

      // Renamed, the contract's matte fill is missing.
      final renamed = _real('ui_chest');
      for (final s in falloffShapes(renamed).cast<Map<String, Object?>>()) {
        if (s['nm'] == 'falloff_fill') s['nm'] = 'falloff';
      }
      expect(_codes(renamed, 'ui_chest'), [LottieIssueCodes.namedShapes]);

      // A tint fill turned into a gradient still fails as before: only the
      // contract's matte fills may be one.
      final ribbon = _real('ui_win_ribbon');
      void gradient(List<Object?> shapes) {
        for (final s in shapes.cast<Map<String, Object?>>()) {
          if (s['nm'] == 'band_fill') s['ty'] = 'gf';
          if (s['ty'] == 'gr') gradient(s['it']! as List<Object?>);
        }
      }

      gradient(_layer(ribbon, 'band')['shapes']! as List<Object?>);
      expect(
        validateLottie(
          ribbon,
          lottieContractOf('ui_win_ribbon')!,
        ).map((i) => i.message),
        contains(contains('"band_fill" names a gf, not a fl')),
      );

      // A gradient `_fill` on a file whose contract has none.
      final stray = _real('ui_chest');
      final shapes = falloffShapes(stray).cast<Map<String, Object?>>();
      final copy = jsonDecode(
        jsonEncode(shapes.firstWhere((s) => s['nm'] == 'falloff_fill')),
      );
      (_layer(stray, 'flash')['shapes']! as List<Object?>).add(
        (copy as Map<String, Object?>)..['nm'] = 'flash_fill',
      );
      expect(_codes(stray, 'ui_chest'), [LottieIssueCodes.namedShapes]);
    });

    test('the text files name exactly their text layers', () {
      final json = _real('ui_win_ribbon');
      _layer(json, 'label_shadow')['nm'] = 'shadow';
      expect(_codes(json, 'ui_win_ribbon'), [LottieIssueCodes.text]);
    });
  });

  group('remapped nulls never hold (LOTTIE.md v3 "Travel remap")', () {
    test('two equal consecutive travel keys are a hold', () {
      final json = _real('doll_complete');
      final keyframes =
          (_ks(_layer(json, 'travel'), 'p')['k']! as List<Object?>)..insert(0, {
            't': 0,
            's': [100, 650, 0],
          });
      expect(keyframes, hasLength(3));
      expect(_codes(json, 'doll_complete'), [LottieIssueCodes.hold]);
    });

    test('a hold keyframe (h: 1) is a hold', () {
      final json = _real('doll_move');
      _keyframes(_ks(_layer(json, 'travel'), 'p')).first['h'] = 1;
      expect(_codes(json, 'doll_move'), [LottieIssueCodes.hold]);
    });

    test('the drop null too', () {
      final json = _real('doll_reveal');
      (_ks(_layer(json, 'drop'), 'p')['k']! as List<Object?>).insert(1, {
        't': 3,
        's': [0, -18, 0],
      });
      expect(_codes(json, 'doll_reveal'), [LottieIssueCodes.hold]);
    });
  });

  group('the drop null (LOTTIE.md "Reveal drop")', () {
    test('lowers the doll from the contract\'s start to (0, 0)', () {
      final start = _real('doll_reveal');
      _keyframes(_ks(_layer(start, 'drop'), 'p')).first['s'] = [0, -20, 0];
      expect(_codes(start, 'doll_reveal'), [LottieIssueCodes.drop]);

      final end = _real('doll_reveal');
      _keyframes(_ks(_layer(end, 'drop'), 'p')).last['s'] = [0, 2, 0];
      expect(_codes(end, 'doll_reveal'), [LottieIssueCodes.drop]);

      final sideways = _real('doll_reveal');
      _keyframes(_ks(_layer(sideways, 'drop'), 'p')).last['s'] = [3, 0, 0];
      expect(_codes(sideways, 'doll_reveal'), [
        LottieIssueCodes.drop, // off the line
        LottieIssueCodes.drop, // does not end at (0, 0)
      ]);
    });

    test('is an unparented, keyframed null', () {
      final parented = _real('doll_reveal');
      _layer(parented, 'drop')['parent'] = 1;
      expect(_codes(parented, 'doll_reveal'), [LottieIssueCodes.drop]);

      final still = _real('doll_reveal');
      (_layer(still, 'drop')['ks']! as Map<String, Object?>)['p'] = {
        'a': 0,
        'k': [0, 0, 0],
      };
      expect(_codes(still, 'doll_reveal'), [LottieIssueCodes.drop]);
    });

    test('is a hook: only doll_reveal has one, and it must', () {
      final renamed = _real('doll_reveal');
      _layer(renamed, 'drop')['nm'] = 'lower';
      expect(_codes(renamed, 'doll_reveal'), [LottieIssueCodes.hooks]);

      final stray = _real('doll_pick');
      (stray['layers']! as List<Object?>).add({
        'ty': 3,
        'nm': 'drop',
        'ind': 99,
        'ks': <String, Object?>{},
      });
      expect(_codes(stray, 'doll_pick'), [LottieIssueCodes.hooks]);
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

    test('a placeholder PNG is named after an image slot (D50)', () {
      File(
        p.join(
          root.path,
          designLottieDir,
          lottiePlaceholderDir,
          'figurine.png',
        ),
      ).writeAsBytesSync([0x89, 0x50]);
      expect(readDesignLottie(root, contracts: table).issues, isEmpty);
      File(
        p.join(root.path, designLottieDir, lottiePlaceholderDir, 'mascot.png'),
      ).writeAsBytesSync([0x89, 0x50]);
      File(
        p.join(root.path, designLottieDir, lottiePlaceholderDir, 'notes.txt'),
      ).writeAsStringSync('x');
      expect(readDesignLottie(root, contracts: table).issues, [
        contains('images/mascot.png: no image slot "mascot"'),
        contains('images/notes.txt: unexpected file'),
      ]);
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
