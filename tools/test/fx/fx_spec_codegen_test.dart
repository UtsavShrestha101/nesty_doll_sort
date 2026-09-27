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

  test('board-space files carry S/T and never a hold (LOTTIE.md v3)', () {
    final source = fxSpecSource(facts);
    expect(
      source,
      contains('travel: FxTravel(s: Offset(100, 650), t: Offset(195, 144)),'),
    );
    expect(source, isNot(contains('FxHold(')));
    expect(source, isNot(contains('holds:')));
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

    test(
      'board pieces are 3× rasters at 33.33 %, dolls 512×768 at 19.53 %',
      () {
        final glow = of('fx_select_glow').imageLayers.single;
        expect(glow.scale, const LottiePoint(0.3333, 0.3333));
        expect(glow.anchor, const LottiePoint(174, 78));
        final symbol = of(
          'fx_glass_unlock',
        ).imageLayers.firstWhere((l) => l.assetId == 'unlock_symbol');
        expect(symbol.anchor, const LottiePoint(18, 18));
        for (final f in facts) {
          for (final l in f.imageLayers) {
            final doll =
                l.assetId.startsWith('doll_') ||
                l.assetId.startsWith('mover_') ||
                l.assetId.startsWith('target_');
            expect(
              l.scale,
              anyOf(
                const LottiePoint(1, 1), // a precomp child at the artboard
                doll
                    ? const LottiePoint(0.1953, 0.1953)
                    : const LottiePoint(0.3333, 0.3333),
              ),
              reason: '${f.contract.name} ${l.keyPath.join(' › ')}',
            );
          }
        }
      },
    );

    test('fx_ice: one layer per crack stage, plus one per stage-less hit', () {
      expect(
        of('fx_ice').imageLayers.map((l) => '${l.keyPath.single}=${l.assetId}'),
        [
          'ice_shatter=ice_shatter',
          'ice_3=ice_3',
          'ice_2=ice_2',
          'ice_1=ice_1',
          'ice_0=ice_0',
          'ice_0_hit=ice_0',
          'ice_1_hit=ice_1',
          'ice_2_hit=ice_2',
          'ice_3_hit=ice_3',
          'doll_lid=doll_lid',
          'doll_body=doll_body',
        ],
      );
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
    // fx_ice in the JSON's order: cracks and shatter, rests (dr 0), hits.
    expect(of('fx_ice').markers.map((m) => m.toString()), [
      'crack_1 0.0+16.0',
      'crack_2 16.0+16.0',
      'crack_3 32.0+16.0',
      'shatter 48.0+33.0',
      'rest_0 0.0+0.0',
      'rest_1 16.0+0.0',
      'rest_2 32.0+0.0',
      'rest_3 48.0+0.0',
      'crack_hit_0 82.0+16.0',
      'crack_hit_1 99.0+16.0',
      'crack_hit_2 116.0+16.0',
      'crack_hit_3 133.0+16.0',
    ]);
    expect(of('fx_ice').frames, 150);
    expect(of('doll_reveal').frames, 31);
  });

  test('emits short literals: no float noise, Offset.zero for (0, 0)', () {
    final source = fxSpecSource(facts);
    expect(source, contains('scale: Offset(0.1953, 0.1953)'));
    expect(source, contains('scale: Offset(0.3333, 0.3333)'));
    expect(source, contains('anchor: Offset(90, 170.8)'));
    expect(source, contains('anchor: Offset(205, 55)'));
    expect(source, contains("FxMarker('rest_0', 0, 0)"));
    expect(source, contains('anchor: Offset.zero,'));
    expect(source, isNot(contains('scaleAnimated')));
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
