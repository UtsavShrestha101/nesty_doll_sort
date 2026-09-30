// fx_spec.gen.dart against the JSON the game actually ships
// (assets/lottie/, written by sync_design_assets). The tools' own test checks
// the file is exactly what gen_fx_spec emits; this one re-reads the shipped
// exports independently, so a skipped sync or regeneration, or a generator
// bug, fails here in the game's own suite (m2-lottie-design §17 "Tools").
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';

/// `flutter test` runs with apps/game as the working directory.
Map<String, Object?> _shipped(FxId id) =>
    jsonDecode(File(id.assetPath).readAsStringSync()) as Map<String, Object?>;

List<Map<String, Object?>> _maps(Object? value) =>
    (value as List<Object?>? ?? const []).cast<Map<String, Object?>>();

Map<String, Object?>? _prop(Map<String, Object?> layer, String key) =>
    (layer['ks'] as Map<String, Object?>?)?[key] as Map<String, Object?>?;

Offset _offset(Object? value) {
  final list = value! as List<Object?>;
  return Offset((list[0]! as num).toDouble(), (list[1]! as num).toDouble());
}

/// A property's value, or its first keyframe's when animated.
Offset _firstValue(Map<String, Object?> prop) =>
    prop['a'] == 1 ? _offset(_maps(prop['k']).first['s']) : _offset(prop['k']);

/// Every image layer of [json], root first, with its key path (a precomp
/// child is prefixed by its precomp layer's name).
List<(String, Map<String, Object?>)> _imageLayerMaps(
  Map<String, Object?> json,
) {
  final assets = {for (final a in _maps(json['assets'])) a['id']: a};
  final out = <(String, Map<String, Object?>)>[];
  void visit(List<Map<String, Object?>> layers, List<String> prefix) {
    for (final layer in layers) {
      final path = [...prefix, layer['nm']! as String];
      if (layer['ty'] == 2) {
        out.add((path.join(' › '), layer));
      } else if (layer['ty'] == 0) {
        visit(_maps(assets[layer['refId']]!['layers']), path);
      }
    }
  }

  visit(_maps(json['layers']), const []);
  return out;
}

/// The image layers as `FxImageLayer` fields: key path, slot, scale,
/// anchor.
List<(String, FxImageSlot?, Offset, Offset)> _imageLayers(
  Map<String, Object?> json,
) => [
  for (final (path, layer) in _imageLayerMaps(json))
    (
      path,
      FxImageSlot.fromAssetId(layer['refId']! as String),
      _firstValue(_prop(layer, 's')!) / 100,
      _firstValue(_prop(layer, 'a')!),
    ),
];

/// The root layer called [name] of [json].
Map<String, Object?> _root(Map<String, Object?> json, String name) =>
    _maps(json['layers']).firstWhere((l) => l['nm'] == name);

bool _animated(Map<String, Object?> layer, String key) =>
    _prop(layer, key)?['a'] == 1;

Set<String> _fillNames(Map<String, Object?> json) {
  final names = <String>{};
  void visit(List<Map<String, Object?>> shapes) {
    for (final shape in shapes) {
      if (shape['ty'] == 'fl') names.add(shape['nm']! as String);
      if (shape['ty'] == 'gr') visit(_maps(shape['it']));
    }
  }

  for (final layer in [
    ..._maps(json['layers']),
    for (final a in _maps(json['assets'])) ..._maps(a['layers']),
  ]) {
    visit(_maps(layer['shapes']));
  }
  return names;
}

void main() {
  test('one spec per FxId, found by fxSpecOf', () {
    expect(fxSpecs.keys.toSet(), FxId.values.toSet());
    for (final id in FxId.values) {
      expect(fxSpecOf(id).id, id);
    }
  });

  for (final id in FxId.values) {
    test('${id.fileName} matches the shipped JSON', () {
      final spec = fxSpecOf(id);
      final json = _shipped(id);
      final rootLayers = _maps(json['layers']);
      final names = {for (final l in rootLayers) l['nm']};

      expect(spec.frames, (json['op']! as num) - (json['ip']! as num));
      expect((spec.width, spec.height), (json['w'], json['h']));
      expect(spec.markers, [
        for (final m in _maps(json['markers']))
          FxMarker(
            m['cm']! as String,
            (m['tm']! as num).toDouble(),
            (m['dr']! as num).toDouble(),
          ),
      ]);

      // Board space exactly when the file has a travel null; segmented
      // exactly when it has markers that name segments: a lone rest marker
      // (`ui_extra_slot`'s `rest`, m7-3) or an intro card's whole-file
      // `loop` doesn't make a file segmented.
      final hasTravel = names.contains('travel');
      final segments = spec.markers.where(
        (m) =>
            !(m.duration == 0 && spec.markers.every((n) => n.duration == 0)) &&
            !(m.name == 'loop' && m.start == 0 && m.end == spec.frames),
      );
      expect(
        spec.kind,
        hasTravel
            ? FxKind.boardSpace
            : segments.isNotEmpty
            ? FxKind.segmented
            : FxKind.inPlace,
      );
      expect(spec.travel != null, hasTravel);
      if (hasTravel) {
        expect(spec.anchor, Offset.zero);
        final keyframes = _maps(
          _prop(rootLayers.firstWhere((l) => l['nm'] == 'travel'), 'p')!['k'],
        );
        expect(spec.travel!.s, _offset(keyframes.first['s']));
        // No hold (LOTTIE.md v3): lottie calls the remap on every frame.
        for (var i = 0; i + 1 < keyframes.length; i++) {
          expect(
            _offset(keyframes[i]['s']),
            isNot(_offset(keyframes[i + 1]['s'])),
            reason: 'travel key $i',
          );
          expect(keyframes[i]['h'], isNot(1), reason: 'travel key $i');
        }
      } else {
        expect(
          spec.anchor.dx >= 0 &&
              spec.anchor.dx <= spec.width &&
              spec.anchor.dy >= 0 &&
              spec.anchor.dy <= spec.height,
          isTrue,
          reason: 'the anchor is on the canvas',
        );
      }

      // The size nulls the game drives. The intro loops (m7-3) animate
      // their own, so their FxSpec lists none; `family2`'s null is
      // `family_2_size`.
      String sizeNull(FxRole role) =>
          role == FxRole.family2 ? 'family_2_size' : '${role.name}_size';
      final authored = rootLayers.any(
        (l) =>
            FxRole.values.any((r) => l['nm'] == sizeNull(r)) &&
            _animated(l, 's'),
      );
      expect(spec.roles, [
        if (!authored)
          for (final role in FxRole.values)
            if (names.contains(sizeNull(role))) role,
      ]);
      expect([
        for (final l in spec.imageLayers)
          (l.keyPath.join(' › '), l.slot, l.scale, l.anchor),
      ], _imageLayers(json));
      // Static image transforms (LOTTIE.md v3): the compensation is a
      // static scale and anchor, exact on every frame.
      for (final (path, layer) in _imageLayerMaps(json)) {
        for (final key in const ['a', 'p', 's', 'r']) {
          expect(_animated(layer, key), isFalse, reason: '$path $key');
        }
      }
      expect(spec.textLayers, [
        for (final l in [
          ...rootLayers,
          for (final a in _maps(json['assets'])) ..._maps(a['layers']),
        ])
          if (l['ty'] == 5) l['nm'],
      ]);
      final fills = _fillNames(json);
      expect(spec.colorFills, [
        for (final hook in const ['rim_tint', 'tint'])
          if (fills.contains(hook)) hook,
      ]);
    });
  }

  group('what the timeline sequences on', () {
    test('doll_invalid: target_pos is authored at T', () {
      final json = _shipped(FxId.dollInvalid);
      final targetPos = _maps(
        json['layers'],
      ).firstWhere((l) => l['nm'] == 'target_pos');
      expect(
        _offset(_prop(targetPos, 'p')!['k']),
        fxSpecOf(FxId.dollInvalid).travel!.t,
      );
    });

    test('doll_complete: travel leaves S on the fly frame', () {
      final json = _shipped(FxId.dollComplete);
      final keyframes = _maps(_prop(_root(json, 'travel'), 'p')!['k']);
      expect(keyframes.first['t'], FxTiming.completeFlyFrame);
      expect(
        _offset(keyframes.first['s']),
        fxSpecOf(FxId.dollComplete).travel!.s,
      );
    });

    test('fx_ice: stage n rests on rest_n = 16n, the shatter starts at '
        'stage 3, and each crack_hit_n follows it', () {
      final ice = fxSpecOf(FxId.fxIce);
      for (var n = 1; n <= 3; n++) {
        expect(
          ice.marker('crack_$n')!.start,
          FxTiming.iceStageFrames * (n - 1),
        );
      }
      for (var n = 0; n <= 3; n++) {
        expect(ice.marker('rest_$n')!.start, FxTiming.iceStageFrames * n);
        expect(ice.marker('rest_$n')!.duration, 0);
      }
      final shatter = ice.marker('shatter')!;
      expect(shatter.start, FxTiming.iceStageFrames * 3);
      // One empty frame, then the four hits, to the end of the file.
      expect(ice.marker('crack_hit_0')!.start, shatter.end + 1);
      for (var n = 1; n <= 3; n++) {
        expect(
          ice.marker('crack_hit_$n')!.start,
          ice.marker('crack_hit_${n - 1}')!.end + 1,
        );
      }
      expect(ice.marker('crack_hit_3')!.end, ice.frames - 1);
    });

    test('the pulses, bursts, lifts and bobs live on parent nulls', () {
      for (final (id, image, parent) in const [
        (FxId.fxSelectGlow, 'glow_ring', 'glow_pulse'),
        (FxId.uiExtraSlot, 'extra_slot', 'slot_pulse'),
        (FxId.fxIce, 'ice_shatter', 'shatter_burst'),
        (FxId.dollNest, 'target_lid', 'target_lid_lift'),
        (FxId.dollSwallow, 'mover_lid', 'mover_lid_lift'),
        (FxId.uiHintArrow, 'hint_arrow', 'arrow_bob'),
      ]) {
        final json = _shipped(id);
        final nullLayer = _root(json, parent);
        expect(nullLayer['ty'], 3, reason: parent);
        expect(_root(json, image)['parent'], nullLayer['ind'], reason: image);
        expect(
          ['p', 's'].any((key) => _animated(nullLayer, key)),
          isTrue,
          reason: '$parent moves',
        );
      }
    });

    test('lengths the §7 table times cues on', () {
      expect(fxSpecOf(FxId.dollMove).durationMs, closeTo(266.67, 0.01));
      expect(fxSpecOf(FxId.dollNest).durationMs, closeTo(400, 1e-9));
      expect(fxSpecOf(FxId.dollComplete).durationMs, closeTo(1250, 1e-9));
      expect(fxSpecOf(FxId.dollInvalid).durationMs, closeTo(600, 1e-9));
      expect(fxSpecOf(FxId.uiFamilyCounter).marker('bump')!.durationMs, 200);
    });
  });
}
