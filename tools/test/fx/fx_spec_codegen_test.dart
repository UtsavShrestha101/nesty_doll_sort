import 'dart:io';

import 'package:nesty_tools/src/dart_format.dart';
import 'package:nesty_tools/src/fx/fx_spec_codegen.dart';
import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/fx/lottie_sources.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final root = findRepoRoot();
  final facts = fxSpecFactsOf(readDesignLottie(root));
  FxSpecFacts of(String name) =>
      facts.firstWhere((f) => f.contract.name == name);

  test('the committed fx_spec.gen.dart is up to date', () async {
    final target = p.join(root.path, fxSpecGenPath);
    expect(
      File(target).readAsStringSync(),
      await formatDart(fxSpecSource(facts), targetPath: target),
      reason: 'run dart run nesty_tools:gen_fx_spec',
    );
  });

  test('is byte-stable: the same exports give the same source', () {
    final again = fxSpecFactsOf(readDesignLottie(root));
    expect(fxSpecSource(again), fxSpecSource(facts));
  });

  test('one spec per contract entry, in FxId order', () {
    expect(facts.map((f) => f.contract.name), [
      for (final c in lottieContracts) c.name,
    ]);
    final source = fxSpecSource(facts);
    for (final c in lottieContracts) {
      expect(
        source,
        contains('FxId.${lottieMemberName(c.name)}: FxSpec('),
        reason: c.name,
      );
    }
  });

  group('travel holds (m2-lottie-design §6)', () {
    test('doll_complete holds at S until the fly; ui_drag_hand at S and T', () {
      expect(of('doll_complete').holds, const [
        TravelHold(0, 42, LottiePoint(100, 650)),
      ]);
      expect(of('ui_drag_hand').holds, const [
        TravelHold(0, 21.6, LottiePoint(100, 500)),
        TravelHold(86.4, 108, LottiePoint(300, 500)),
      ]);
    });

    test('doll_move and doll_invalid never hold', () {
      expect(of('doll_move').holds, isEmpty);
      expect(of('doll_invalid').holds, isEmpty);
    });

    Map<String, Object?> travel(List<Map<String, Object?>> keyframes) => {
      'nm': 'travel',
      'ks': {
        'p': {'a': 1, 'k': keyframes},
      },
    };

    test('a hold keyframe (h: 1) holds, and adjacent holds merge', () {
      expect(
        travelHolds(
          travel([
            {
              't': 0,
              's': [1, 2, 0],
              'h': 1,
            },
            {
              't': 5,
              's': [1, 2, 0],
            },
            {
              't': 9,
              's': [1, 2, 0],
            },
            {
              't': 12,
              's': [4, 2, 0],
            },
            {
              't': 20,
              's': [6, 2, 0],
            },
          ]),
        ),
        // 0–5 (h: 1) and 5–9 (equal values) merge; 9 → 12 moves.
        const [TravelHold(0, 9, LottiePoint(1, 2))],
      );
    });

    test('an old-style end value (e) decides, and the tail never holds', () {
      expect(
        travelHolds(
          travel([
            {
              't': 0,
              's': [1, 2, 0],
              'e': [1, 2, 0],
            },
            {
              't': 5,
              's': [9, 2, 0],
              'e': [3, 2, 0],
            },
            {'t': 9},
          ]),
        ),
        const [TravelHold(0, 5, LottiePoint(1, 2))],
      );
    });
  });

  group('image layers (m2-lottie-design §3)', () {
    test('precomp children are keyed through their precomp layer', () {
      final reveal = of('doll_reveal').imageLayers;
      expect(reveal.map((l) => l.keyPath.join(' › ')), [
        'color_doll › lid',
        'color_doll › body',
        'doll_silhouette',
      ]);
      expect(reveal.first.scale, const LottiePoint(1, 1));
      expect(reveal.first.anchor, LottiePoint.zero);
      expect(reveal.last.scale, const LottiePoint(0.1953, 0.1953));
      expect(reveal.last.anchor, const LottiePoint(256, 742));

      final unlock = of('fx_glass_unlock').imageLayers;
      expect(unlock.first.keyPath, ['padlock_ping', 'lock']);
      expect(unlock.first.assetId, 'glass_case_0');
      expect(
        of('doll_complete').imageLayers.map((l) => l.keyPath.first),
        containsAll(['shine_matte', 'doll_lid', 'doll_body']),
      );
    });

    test('exactly glow_ring, extra_slot and ice_shatter scale over time', () {
      expect(
        [
          for (final f in facts)
            for (final l in f.imageLayers)
              if (l.scaleAnimated) l.assetId,
        ],
        ['glow_ring', 'ice_shatter', 'extra_slot'],
      );
      // The first keyframe's value stands in for the animated scale.
      final glow = of('fx_select_glow').imageLayers.single;
      expect(glow.scale, const LottiePoint(0.9, 0.9));
      expect(glow.anchor, const LottiePoint(58, 26));
    });

    test('every image layer uses one of the file\'s assets', () {
      for (final f in facts) {
        expect(
          f.imageLayers.map((l) => l.assetId).toSet(),
          f.contract.imageAssets,
          reason: f.contract.name,
        );
      }
    });
  });

  test('roles, text layers and colour fills come from the JSON', () {
    expect(of('doll_nest').roles, [LottieRole.mover, LottieRole.target]);
    expect(of('fx_ice').roles, [LottieRole.doll]);
    expect(of('fx_sparkle').roles, isEmpty);
    expect(of('ui_family_counter').textLayers, ['count_new', 'count_old']);
    expect(of('ui_chapter_ribbon').textLayers, ['label', 'label_shadow']);
    expect(of('doll_swallow').colorFills, ['rim_tint']);
    expect(of('fx_twinkle').colorFills, ['tint']);
    expect(of('ui_toggle').markers.map((m) => m.name), ['on', 'off']);
  });

  test('emits short literals: no float noise, Offset.zero for (0, 0)', () {
    final source = fxSpecSource(facts);
    expect(source, contains('scale: Offset(0.1953, 0.1953)'));
    expect(source, contains('anchor: Offset(90, 170.8)'));
    expect(source, contains('FxHold(0, 21.6, Offset(100, 500))'));
    expect(source, contains('anchor: Offset.zero,'));
    expect(source, isNot(contains('0000000')));
    expect(source, isNot(contains('.0,')));
  });

  test('refuses to generate from exports with issues', () {
    expect(
      () => fxSpecFactsOf(LottieSourceSet(const [], ['x.json: frameRate'])),
      throwsStateError,
    );
  });
}
