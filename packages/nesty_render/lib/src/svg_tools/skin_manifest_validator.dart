import 'package:nesty_render/src/svg_tools/svg_issue.dart';
import 'package:nesty_render/src/svg_tools/svg_validator.dart';

// Spec §12.2 lists the minimal sidecar; the design handoff adds name,
// artboard, groups, tinted and lidGroups, which are checked when present.
const _requiredKeys = <String>{
  'skinId',
  'splitY',
  'lidLiftPx',
  'symbolAnchor',
  'symbolSize',
  'version',
};
const _optionalKeys = <String>{
  'name',
  'artboard',
  'groups',
  'tinted',
  'lidGroups',
};

final _skinIdPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

/// Validates a decoded `skin.json` (spec §12.2).
///
/// [expectedSkinId] is the folder the manifest lives in; the two must match
/// so an asset path always names the skin it holds. Unknown keys are an
/// issue too: a new field needs a schema change here first, not a silent
/// pass-through.
List<SvgIssue> validateSkinManifest(Object? json, {String? expectedSkinId}) {
  if (json is! Map<String, Object?>) {
    return const [
      SvgIssue('manifestNotObject', 'skin.json must be a JSON object.'),
    ];
  }
  final issues = <SvgIssue>[];
  for (final key in _requiredKeys) {
    if (!json.containsKey(key)) {
      issues.add(SvgIssue('manifestMissingKey', 'Missing "$key".'));
    }
  }
  for (final key in json.keys) {
    if (!_requiredKeys.contains(key) && !_optionalKeys.contains(key)) {
      issues.add(SvgIssue('manifestUnknownKey', 'Unknown key "$key".'));
    }
  }

  void bad(String key, String expected) => issues.add(
    SvgIssue('manifestBadValue', '"$key" is ${json[key]}, expected $expected.'),
  );

  final skinId = json['skinId'];
  if (json.containsKey('skinId')) {
    if (skinId is! String || !_skinIdPattern.hasMatch(skinId)) {
      bad('skinId', 'a lowercase kebab-case id');
    } else if (expectedSkinId != null && skinId != expectedSkinId) {
      bad('skinId', '"$expectedSkinId" (the folder name)');
    }
  }
  final name = json['name'];
  if (json.containsKey('name') && (name is! String || name.trim().isEmpty)) {
    bad('name', 'a non-empty string');
  }
  final version = json['version'];
  if (json.containsKey('version') && (version is! int || version < 1)) {
    bad('version', 'an integer ≥ 1');
  }

  var width = skinArtboard[0].toDouble();
  var height = skinArtboard[1].toDouble();
  if (json.containsKey('artboard')) {
    final artboard = _numbers(json['artboard'], 2);
    if (artboard == null ||
        artboard[0] != skinArtboard[0] ||
        artboard[1] != skinArtboard[1]) {
      bad('artboard', '[${skinArtboard[0]}, ${skinArtboard[1]}]');
    } else {
      width = artboard[0];
      height = artboard[1];
    }
  }
  final splitY = json['splitY'];
  if (json.containsKey('splitY') &&
      (splitY is! num || splitY <= 0 || splitY >= height)) {
    bad('splitY', 'a number between 0 and $height');
  }
  final lidLift = json['lidLiftPx'];
  if (json.containsKey('lidLiftPx') &&
      (lidLift is! num || lidLift <= 0 || lidLift >= height)) {
    bad('lidLiftPx', 'a positive number below $height');
  }
  if (json.containsKey('symbolAnchor')) {
    final anchor = _numbers(json['symbolAnchor'], 2);
    if (anchor == null ||
        anchor[0] < 0 ||
        anchor[0] > width ||
        anchor[1] < 0 ||
        anchor[1] > height) {
      bad('symbolAnchor', '[x, y] inside the artboard');
    }
  }
  final symbolSize = json['symbolSize'];
  if (json.containsKey('symbolSize') &&
      (symbolSize is! num || symbolSize <= 0 || symbolSize > width)) {
    bad('symbolSize', 'a positive number no wider than the artboard');
  }

  if (json.containsKey('groups')) {
    final groups = _strings(json['groups']);
    if (groups == null || groups.join(',') != skinGroupIds.join(',')) {
      bad('groups', '[${skinGroupIds.join(', ')}]');
    }
  }
  for (final key in const ['tinted', 'lidGroups']) {
    if (!json.containsKey(key)) continue;
    final list = _strings(json[key]);
    if (list == null ||
        list.isEmpty ||
        list.toSet().length != list.length ||
        !list.every(skinGroupIds.contains)) {
      bad(key, 'a non-empty list of distinct skin group ids');
    }
  }
  return issues;
}

List<double>? _numbers(Object? value, int length) {
  if (value is! List<Object?> || value.length != length) return null;
  if (!value.every((v) => v is num)) return null;
  return [for (final v in value) (v! as num).toDouble()];
}

List<String>? _strings(Object? value) {
  if (value is! List<Object?>) return null;
  if (!value.every((v) => v is String)) return null;
  return value.cast<String>();
}
