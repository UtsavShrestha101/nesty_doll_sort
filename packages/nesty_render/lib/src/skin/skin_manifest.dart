import 'dart:convert' show jsonDecode;
import 'dart:ui' show Offset, Size;

import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:nesty_render/src/svg_tools/skin_manifest_validator.dart';
import 'package:nesty_render/src/svg_tools/svg_issue.dart';
import 'package:nesty_render/src/svg_tools/svg_validator.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// A `skin.json` that failed validation (spec §12.2).
final class SkinManifestException implements Exception {
  const SkinManifestException(this.issues);

  final List<SvgIssue> issues;

  @override
  String toString() => 'SkinManifestException: ${issues.join('; ')}';
}

/// A skin's sidecar `skin.json` (spec §12.2), validated.
///
/// The optional keys the design handoff added default to the design tokens
/// (`SkinTokens`), which every shipped skin matches.
@immutable
final class SkinManifest {
  const SkinManifest({
    required this.skinId,
    required this.version,
    this.name,
    this.splitY = SkinTokens.splitY,
    this.lidLiftPx = SkinTokens.lidLiftPx,
    this.symbolAnchor = SkinTokens.symbolAnchor,
    this.symbolSize = SkinTokens.symbolSize,
    this.artboard = SkinTokens.artboard,
    this.groups = skinGroupIds,
    this.tinted = supportedTinted,
    this.lidGroups = supportedLidGroups,
  });

  /// Parses and validates a decoded `skin.json`. [expectedSkinId] is the
  /// folder it was loaded from. Throws [SkinManifestException].
  factory SkinManifest.fromJson(Object? json, {String? expectedSkinId}) {
    final issues = [
      ...validateSkinManifest(json, expectedSkinId: expectedSkinId),
    ];
    if (issues.isEmpty) {
      final map = json! as Map<String, Object?>;
      issues.addAll(_layerPlanIssues(map));
    }
    if (issues.isNotEmpty) throw SkinManifestException(issues);
    final map = json! as Map<String, Object?>;
    final anchor = map['symbolAnchor']! as List<Object?>;
    final artboard = map['artboard'] as List<Object?>?;
    return SkinManifest(
      skinId: map['skinId']! as String,
      name: map['name'] as String?,
      version: map['version']! as int,
      splitY: (map['splitY']! as num).toDouble(),
      lidLiftPx: (map['lidLiftPx']! as num).toDouble(),
      symbolAnchor: Offset(
        (anchor[0]! as num).toDouble(),
        (anchor[1]! as num).toDouble(),
      ),
      symbolSize: (map['symbolSize']! as num).toDouble(),
      artboard: artboard == null
          ? SkinTokens.artboard
          : Size(
              (artboard[0]! as num).toDouble(),
              (artboard[1]! as num).toDouble(),
            ),
      groups: _stringsOr(map['groups'], skinGroupIds),
      tinted: _stringsOr(map['tinted'], supportedTinted),
      lidGroups: _stringsOr(map['lidGroups'], supportedLidGroups),
    );
  }

  /// Parses `skin.json` source text. Throws [SkinManifestException] for
  /// malformed JSON too.
  factory SkinManifest.parse(String source, {String? expectedSkinId}) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException catch (e) {
      throw SkinManifestException([
        SvgIssue('manifestNotJson', 'skin.json is not JSON: ${e.message}'),
      ]);
    }
    return SkinManifest.fromJson(json, expectedSkinId: expectedSkinId);
  }

  /// The tinted groups the renderer supports: spec §12.2's table marks
  /// exactly these two "Tinted? yes".
  static const supportedTinted = ['bottom_mask', 'top_mask'];

  /// The groups that move with the lid (spec §12.2 "Rendering").
  static const supportedLidGroups = [
    'top_mask',
    'face',
    'top_detail',
    'shine_top',
  ];

  final String skinId;
  final String? name;
  final int version;

  /// Art y where the lid splits from the body.
  final double splitY;

  /// How far the lid rises when fully open, in art units.
  final double lidLiftPx;

  /// Centre of the belly symbol box, in art units.
  final Offset symbolAnchor;

  /// Side of the (subtle) belly symbol box, in art units.
  final double symbolSize;

  /// The artboard (512 × 768).
  final Size artboard;

  final List<String> groups;
  final List<String> tinted;
  final List<String> lidGroups;

  /// Identifies this skin's rasters in caches: a new [version] (a re-upload,
  /// spec §14.1) must never reuse the old images.
  String get cacheKey => '$skinId@$version';

  /// [lidLiftPx] as a fraction of the doll height, the unit of
  /// `DollPaintParams.lidLift`: the lid of the design's `_open` renders.
  double get openLidLift => lidLiftPx / artboard.height;

  // The raster layer plan (SkinLayer) is fixed to spec §12.2's table. A
  // manifest that tints or lifts other groups would render differently from
  // what it asks for, so it is rejected rather than silently ignored.
  static List<SvgIssue> _layerPlanIssues(Map<String, Object?> json) {
    final issues = <SvgIssue>[];
    void check(String key, List<String> supported) {
      final value = json[key];
      if (value == null) return;
      final list = (value as List<Object?>).cast<String>().toSet();
      if (list.length != supported.length || !list.containsAll(supported)) {
        issues.add(
          SvgIssue(
            'manifestUnsupportedLayers',
            '"$key" is $value; the renderer supports only $supported '
                '(spec §12.2).',
          ),
        );
      }
    }

    check('tinted', supportedTinted);
    check('lidGroups', supportedLidGroups);
    return issues;
  }

  static List<String> _stringsOr(Object? value, List<String> fallback) =>
      value == null
      ? fallback
      : List.unmodifiable((value as List<Object?>).cast<String>());

  @override
  bool operator ==(Object other) =>
      other is SkinManifest &&
      other.skinId == skinId &&
      other.name == name &&
      other.version == version &&
      other.splitY == splitY &&
      other.lidLiftPx == lidLiftPx &&
      other.symbolAnchor == symbolAnchor &&
      other.symbolSize == symbolSize &&
      other.artboard == artboard &&
      listEquals(other.groups, groups) &&
      listEquals(other.tinted, tinted) &&
      listEquals(other.lidGroups, lidGroups);

  @override
  int get hashCode => Object.hash(
    skinId,
    name,
    version,
    splitY,
    lidLiftPx,
    symbolAnchor,
    symbolSize,
    artboard,
    Object.hashAll(groups),
    Object.hashAll(tinted),
    Object.hashAll(lidGroups),
  );

  @override
  String toString() => 'SkinManifest($cacheKey)';
}
