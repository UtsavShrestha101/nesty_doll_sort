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

/// The image layers as `FxImageLayer` fields: key path, slot, scale,
/// anchor, animated.
List<(String, FxImageSlot?, Offset, Offset, bool)> _imageLayers(
  Map<String, Object?> json,
) {
  final assets = {for (final a in _maps(json['assets'])) a['id']: a};
  final out = <(String, FxImageSlot?, Offset, Offset, bool)>[];
  void visit(List<Map<String, Object?>> layers, List<String> prefix) {
    for (final layer in layers) {
      final path = [...prefix, layer['nm']! as String];
      if (layer['ty'] == 2) {
        final scale = _prop(layer, 's')!;
        out.add((
          path.join(' › '),
          FxImageSlot.fromAssetId(layer['refId']! as String),
          _firstValue(scale) / 100,
          _firstValue(_prop(layer, 'a')!),
          scale['a'] == 1,
        ));
      } else if (layer['ty'] == 0) {
        visit(_maps(assets[layer['refId']]!['layers']), path);
      }
    }
  }

  visit(_maps(json['layers']), const []);
  return out;
}

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
      // exactly when it has markers.
      final hasTravel = names.contains('travel');
      expect(
        spec.kind,
        hasTravel
            ? FxKind.boardSpace
            : spec.markers.isNotEmpty
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
        expect(spec.travel!.holds, [
          for (var i = 0; i + 1 < keyframes.length; i++)
            if (_offset(keyframes[i]['s']) == _offset(keyframes[i + 1]['s']))
              FxHold(
                (keyframes[i]['t']! as num).toDouble(),
                (keyframes[i + 1]['t']! as num).toDouble(),
                _offset(keyframes[i]['s']),
              ),
        ]);
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

      expect(spec.roles, [
        for (final role in FxRole.values)
          if (names.contains('${role.name}_size')) role,
      ]);
      expect([
        for (final l in spec.imageLayers)
          (l.keyPath.join(' › '), l.slot, l.scale, l.anchor, l.scaleAnimated),
      ], _imageLayers(json));
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

    test('doll_complete holds travel at S until the fly', () {
      final hold = fxSpecOf(FxId.dollComplete).travel!.holds.single;
      expect(hold.start, 0);
      expect(hold.end, FxTiming.completeHoldEndFrame);
      expect(hold.value, fxSpecOf(FxId.dollComplete).travel!.s);
    });

    test('fx_ice stage n rests on frame 16n; shatter starts at stage 3', () {
      final ice = fxSpecOf(FxId.fxIce);
      for (var n = 1; n <= 3; n++) {
        expect(
          ice.marker('crack_$n')!.start,
          FxTiming.iceStageFrames * (n - 1),
        );
      }
      expect(ice.marker('shatter')!.start, FxTiming.iceStageFrames * 3);
      expect(ice.marker('shatter')!.end, ice.frames);
    });

    test('the pulsing layers are the three animated-scale image layers', () {
      expect(
        {
          for (final spec in fxSpecs.values)
            for (final l in spec.imageLayers)
              if (l.scaleAnimated) l.slot,
        },
        {FxImageSlot.glowRing, FxImageSlot.extraSlot, FxImageSlot.iceShatter},
      );
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
