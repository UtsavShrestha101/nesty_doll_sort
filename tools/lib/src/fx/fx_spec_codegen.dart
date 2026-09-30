import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/fx/lottie_json.dart';
import 'package:nesty_tools/src/fx/lottie_sources.dart';

/// Repo-relative output of `gen_fx_spec`.
const fxSpecGenPath = 'apps/game/lib/features/fx/fx_spec.gen.dart';

/// One image layer with its authored transform: the game's `FxImageLayer`.
/// The transform is static: validation rejects an animated one (LOTTIE.md v3
/// "Format"), so the game's `FxImageLayer.scaleAnimated` is never set.
final class ImageLayerFacts {
  const ImageLayerFacts({
    required this.keyPath,
    required this.assetId,
    required this.scale,
    required this.anchor,
  });

  /// The layer's name, prefixed by each enclosing precomp layer's name.
  final List<String> keyPath;
  final String assetId;

  /// `ks.s / 100`.
  final LottiePoint scale;

  /// `ks.a`, in declared asset px.
  final LottiePoint anchor;

  @override
  String toString() => 'ImageLayerFacts(${keyPath.join(' › ')} = $assetId)';
}

/// Everything `fx_spec.gen.dart` says about one file: the JSON's facts plus
/// the contract's anchor, kind, loop and travel S/T. `travel` never holds:
/// validation rejects a hold (LOTTIE.md v3), so the game's `FxTravel.holds`
/// stays empty.
final class FxSpecFacts {
  const FxSpecFacts({
    required this.contract,
    required this.frames,
    required this.width,
    required this.height,
    required this.markers,
    required this.roles,
    required this.imageLayers,
    required this.textLayers,
    required this.colorFills,
  });

  final LottieFileContract contract;

  /// The contract's scale nulls, sorted (`FxSpec.scaleNulls`).
  List<String> get scaleNulls => [...contract.scaleNulls]..sort();
  final int frames;
  final double width;
  final double height;

  /// In the JSON's order.
  final List<LottieMarker> markers;

  /// In `LottieRole` order; empty when the contract's `sizesAuthored`.
  final List<LottieRole> roles;

  /// Depth-first in layer order, precomp children after their precomp.
  final List<ImageLayerFacts> imageLayers;

  /// In layer order.
  final List<String> textLayers;

  /// In [lottieHookFills] order.
  final List<String> colorFills;
}

/// The facts of one validated export. Call only on a source whose
/// validation passed: shapes the validator rejects throw here.
FxSpecFacts extractFxSpecFacts(LottieSource source) {
  final json = source.json!;
  final contract = source.contract;
  final layers = lottieMaps(json['layers']);
  final assets = {
    for (final a in lottieMaps(json['assets'])) a['id']! as String: a,
  };

  final imageLayers = <ImageLayerFacts>[];
  void visit(
    List<Map<String, Object?>> layers,
    List<String> prefix,
    int depth,
  ) {
    if (depth > 8) {
      throw StateError('${source.path}: precomps nest deeper than 8');
    }
    for (final layer in layers) {
      final name = layer['nm']! as String;
      switch (layer['ty']) {
        case LottieLayerType.image:
          final scale = lottieTransform(layer, 's');
          final scaleValue = scale == null
              ? const LottiePoint(100, 100)
              : lottiePoint(scale['k'])!;
          imageLayers.add(
            ImageLayerFacts(
              keyPath: [...prefix, name],
              assetId: layer['refId']! as String,
              scale: LottiePoint(scaleValue.x / 100, scaleValue.y / 100),
              anchor:
                  lottiePoint(lottieTransform(layer, 'a')?['k']) ??
                  LottiePoint.zero,
            ),
          );
        case LottieLayerType.precomp:
          final precomp = assets[layer['refId']]!;
          visit(lottieMaps(precomp['layers']), [...prefix, name], depth + 1);
      }
    }
  }

  visit(layers, const [], 0);

  final allLayers = [
    ...layers,
    for (final a in assets.values) ...lottieMaps(a['layers']),
  ];
  final fills = <String>{};
  void visitShapes(List<Map<String, Object?>> shapes) {
    for (final shape in shapes) {
      if (shape['ty'] == 'fl' && lottieHookFills.contains(shape['nm'])) {
        fills.add(shape['nm']! as String);
      }
      if (shape['ty'] == 'gr') visitShapes(lottieMaps(shape['it']));
    }
  }

  for (final layer in allLayers) {
    visitShapes(lottieMaps(layer['shapes']));
  }

  final names = {for (final l in layers) l['nm']};
  final op = json['op']! as num;
  final ip = json['ip']! as num;
  return FxSpecFacts(
    contract: contract,
    frames: (op - ip).toInt(),
    width: (json['w']! as num).toDouble(),
    height: (json['h']! as num).toDouble(),
    markers: [
      for (final m in lottieMaps(json['markers']))
        LottieMarker(
          m['cm']! as String,
          (m['tm']! as num).toDouble(),
          (m['dr']! as num).toDouble(),
        ),
    ],
    // The roles the game drives: none when the file authors its sizes.
    roles: [
      if (!contract.sizesAuthored)
        for (final role in LottieRole.values)
          if (names.contains(role.sizeNull)) role,
    ],
    imageLayers: imageLayers,
    textLayers: [
      for (final l in allLayers)
        if (l['ty'] == LottieLayerType.text) l['nm']! as String,
    ],
    colorFills: [
      for (final f in lottieHookFills)
        if (fills.contains(f)) f,
    ],
  );
}

/// `fx_spec.gen.dart` (unformatted) for [facts], in contract order.
String fxSpecSource(List<FxSpecFacts> facts) {
  final b = StringBuffer()
    ..writeln(
      '// GENERATED — do not edit; run dart run nesty_tools:gen_fx_spec',
    )
    ..writeln('//')
    ..writeln(
      '// Source: $designLottieDir/*.json (validated by sync_design_assets, '
      'shipped',
    )
    ..writeln(
      '// to apps/game/assets/$gameLottieDir/) and, for what the JSON does '
      'not carry',
    )
    ..writeln(
      '// (anchor, kind, loop, travel S/T, scale nulls), the LOTTIE.md v3 contract',
    )
    ..writeln(
      '// table in tools/lib/src/fx/lottie_contract.dart. Validation guarantees',
    )
    ..writeln(
      '// that no travel null holds and no image layer animates its transform.',
    )
    ..writeln()
    ..writeln("import 'dart:ui' show Offset;")
    ..writeln()
    ..writeln("import 'package:nesty_game/features/fx/fx_id.dart';")
    ..writeln("import 'package:nesty_game/features/fx/fx_image_source.dart';")
    ..writeln("import 'package:nesty_game/features/fx/fx_spec.dart';")
    ..writeln()
    ..writeln('/// Every file\'s [FxSpec], one per [FxId]')
    ..writeln('/// (docs/plans/m2-lottie-design.md §2 "Generated specs").')
    ..writeln('const Map<FxId, FxSpec> fxSpecs = {');
  for (final f in facts) {
    final c = f.contract;
    final id = 'FxId.${lottieMemberName(c.name)}';
    b
      ..writeln(
        '  // ${c.name}: ${f.frames} f (${_ms(f.frames)} ms), '
        '${_n(f.width)}×${_n(f.height)}${c.loops ? ', loops' : ''}.',
      )
      ..writeln('  $id: FxSpec(')
      ..writeln('    id: $id,')
      ..writeln('    frames: ${f.frames},')
      ..writeln('    width: ${_n(f.width)},')
      ..writeln('    height: ${_n(f.height)},')
      ..writeln('    anchor: ${_offset(c.anchor)},')
      ..writeln('    kind: FxKind.${c.kind.name},');
    if (f.markers.isNotEmpty) {
      b.writeln('    markers: [');
      for (final m in f.markers) {
        b.writeln(
          "      FxMarker('${m.name}', ${_n(m.start)}, ${_n(m.duration)}),",
        );
      }
      b.writeln('    ],');
    }
    if (c.kind == LottieKind.boardSpace) {
      b.writeln(
        '    travel: FxTravel(s: ${_offset(c.travelS!)}, '
        't: ${_offset(c.travelT!)}),',
      );
    }
    if (f.roles.isNotEmpty) {
      b.writeln(
        '    roles: [${f.roles.map((r) => 'FxRole.${r.name}').join(', ')}],',
      );
    }
    if (f.imageLayers.isNotEmpty) {
      b.writeln('    imageLayers: [');
      for (final l in f.imageLayers) {
        b
          ..writeln('      FxImageLayer(')
          ..writeln(
            '        keyPath: [${l.keyPath.map((k) => "'$k'").join(', ')}],',
          )
          ..writeln('        slot: FxImageSlot.${lottieMemberName(l.assetId)},')
          ..writeln('        scale: ${_offset(l.scale)},')
          ..writeln('        anchor: ${_offset(l.anchor)},')
          ..writeln('      ),');
      }
      b.writeln('    ],');
    }
    if (f.textLayers.isNotEmpty) {
      b.writeln(
        '    textLayers: [${f.textLayers.map((t) => "'$t'").join(', ')}],',
      );
    }
    if (f.colorFills.isNotEmpty) {
      b.writeln(
        '    colorFills: [${f.colorFills.map((t) => "'$t'").join(', ')}],',
      );
    }
    if (f.scaleNulls.isNotEmpty) {
      b.writeln(
        '    scaleNulls: [${f.scaleNulls.map((t) => "'$t'").join(', ')}],',
      );
    }
    if (c.loops) b.writeln('    loops: true,');
    b.writeln('  ),');
  }
  b
    ..writeln('};')
    ..writeln()
    ..writeln('/// The spec of [id]. Every [FxId] has one: the generator emits')
    ..writeln('/// one per LOTTIE.md file, and `fx_spec_drift_test` checks it.')
    ..writeln('FxSpec fxSpecOf(FxId id) => fxSpecs[id]!;');
  return b.toString();
}

/// Refuses to generate from sources with problems, and when any contract
/// entry has no source.
List<FxSpecFacts> fxSpecFactsOf(LottieSourceSet set) {
  if (set.issues.isNotEmpty) {
    throw StateError(
      'The Lottie exports failed validation:\n  ${set.issues.join('\n  ')}',
    );
  }
  return [for (final s in set.sources) extractFxSpecFacts(s)];
}

String _offset(LottiePoint p) =>
    p == LottiePoint.zero ? 'Offset.zero' : 'Offset(${_n(p.x)}, ${_n(p.y)})';

String _ms(int frames) {
  final ms = frames * 1000 / 60;
  return ms == ms.roundToDouble() ? '${ms.toInt()}' : ms.toStringAsFixed(0);
}

/// A stable, shortest literal: integers without `.0`; others rounded to
/// 1e-9 first so float noise (19.53 / 100) never reaches the file.
String _n(double v) {
  final rounded = double.parse(v.toStringAsFixed(9));
  if (rounded == rounded.roundToDouble()) {
    final i = rounded.toInt();
    return i == 0 ? '0' : '$i';
  }
  return '$rounded';
}
