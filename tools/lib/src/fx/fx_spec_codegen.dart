import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/fx/lottie_json.dart';
import 'package:nesty_tools/src/fx/lottie_sources.dart';

/// Repo-relative output of `gen_fx_spec`.
const fxSpecGenPath = 'apps/game/lib/features/fx/fx_spec.gen.dart';

/// A stretch where `travel` holds still (m2-lottie-design §6): the game's
/// `FxHold`.
final class TravelHold {
  const TravelHold(this.start, this.end, this.value);

  final double start;
  final double end;
  final LottiePoint value;

  @override
  bool operator ==(Object other) =>
      other is TravelHold &&
      other.start == start &&
      other.end == end &&
      other.value == value;

  @override
  int get hashCode => Object.hash(start, end, value);

  @override
  String toString() => 'TravelHold($start–$end at $value)';
}

/// One image layer with its authored transform: the game's `FxImageLayer`.
final class ImageLayerFacts {
  const ImageLayerFacts({
    required this.keyPath,
    required this.assetId,
    required this.scale,
    required this.anchor,
    required this.scaleAnimated,
  });

  /// The layer's name, prefixed by each enclosing precomp layer's name.
  final List<String> keyPath;
  final String assetId;

  /// `ks.s / 100`; the first keyframe's value when [scaleAnimated].
  final LottiePoint scale;

  /// `ks.a`, in declared asset px.
  final LottiePoint anchor;
  final bool scaleAnimated;

  @override
  String toString() => 'ImageLayerFacts(${keyPath.join(' › ')} = $assetId)';
}

/// Everything `fx_spec.gen.dart` says about one file: the JSON's facts plus
/// the contract's anchor, kind, loop and travel S/T.
final class FxSpecFacts {
  const FxSpecFacts({
    required this.contract,
    required this.frames,
    required this.width,
    required this.height,
    required this.markers,
    required this.holds,
    required this.roles,
    required this.imageLayers,
    required this.textLayers,
    required this.colorFills,
  });

  final LottieFileContract contract;
  final int frames;
  final double width;
  final double height;
  final List<LottieMarker> markers;

  /// The `travel` holds, in frame order (board-space files).
  final List<TravelHold> holds;

  /// In `LottieRole` order.
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
          final animated = lottieIsAnimated(scale);
          final scaleValue = scale == null
              ? const LottiePoint(100, 100)
              : animated
              ? lottiePoint(lottieMaps(scale['k']).first['s'])!
              : lottiePoint(scale['k'])!;
          imageLayers.add(
            ImageLayerFacts(
              keyPath: [...prefix, name],
              assetId: layer['refId']! as String,
              scale: LottiePoint(scaleValue.x / 100, scaleValue.y / 100),
              anchor:
                  lottiePoint(lottieTransform(layer, 'a')?['k']) ??
                  LottiePoint.zero,
              scaleAnimated: animated,
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
    holds: contract.kind == LottieKind.boardSpace
        ? travelHolds(layers.firstWhere((l) => l['nm'] == 'travel'))
        : const [],
    roles: [
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

/// The holds of a `travel` null: each keyframe whose end value equals its
/// start (two equal consecutive keyframes, or a hold keyframe `h: 1`) holds
/// from its time to the next keyframe's. lottie 3.6.1 skips the position
/// callback there (audit #2). Adjacent holds at one value merge. Nothing
/// holds after the last keyframe: the callback still runs there (probe
/// `tail_hold_test`).
List<TravelHold> travelHolds(Map<String, Object?> travel) {
  final keyframes = lottieMaps(lottieTransform(travel, 'p')!['k']);
  final holds = <TravelHold>[];
  for (var i = 0; i + 1 < keyframes.length; i++) {
    final kf = keyframes[i];
    final next = keyframes[i + 1];
    final start = lottiePoint(kf['s'])!;
    final end = lottiePoint(kf['e']) ?? lottiePoint(next['s']) ?? start;
    if (kf['h'] != 1 && start != end) continue;
    final from = (kf['t']! as num).toDouble();
    final to = (next['t']! as num).toDouble();
    if (holds.isNotEmpty &&
        holds.last.end == from &&
        holds.last.value == start) {
      holds[holds.length - 1] = TravelHold(holds.last.start, to, start);
    } else {
      holds.add(TravelHold(from, to, start));
    }
  }
  return holds;
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
      '// (anchor, kind, loop, travel S/T), the LOTTIE.md contract table in',
    )
    ..writeln('// tools/lib/src/fx/lottie_contract.dart.')
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
      b.write(
        '    travel: FxTravel(s: ${_offset(c.travelS!)}, '
        't: ${_offset(c.travelT!)}',
      );
      if (f.holds.isNotEmpty) {
        b.write(', holds: [');
        for (final h in f.holds) {
          b.write('FxHold(${_n(h.start)}, ${_n(h.end)}, ${_offset(h.value)}),');
        }
        b.write(']');
      }
      b.writeln('),');
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
          ..writeln('        anchor: ${_offset(l.anchor)},');
        if (l.scaleAnimated) b.writeln('        scaleAnimated: true,');
        b.writeln('      ),');
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
