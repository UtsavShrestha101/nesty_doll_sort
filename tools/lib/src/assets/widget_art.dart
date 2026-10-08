// Claude Design's home-screen widget art (m7-6, App Flow 14.4):
// `design/ui/widget/`. It is not a Flutter asset: the widget is native
// (WidgetKit and RemoteViews), so `sync_design_assets` validates the folder
// and copies nothing into `apps/game/assets/`. Stage 4 of the local habits
// (docs/plans/plan-local-habits.md §4) generates the iOS asset catalog and
// the Android drawables from these files, as `design/ui/notification/`
// became the Android notification icon (`android_vector.dart`).
//
// What the delivery promises (tokens.json `habits.widget.art`, DELIVERY.md
// Part 1) and this file checks, so a richer export is noticed before stage
// 4 converts it:
// - each SVG of `files` exists, its viewBox has the dp size's aspect, and
//   it is flat: solid `fill`s on paths, rects, circles and ellipses, with
//   no gradient, filter, mask, clip, pattern, image, text, stroke, opacity
//   or transform (Android takes them as vector drawables);
// - the doll is one colour, #000000 (a template image, tinted per family);
// - each SVG has `name.png`, `name-2x.png` and `name-3x.png` at its dp size
//   × 1, 2 and 3;
// - the two picker previews are PNGs at their pixel sizes;
// - nothing else is in the folder.
import 'dart:io';

import 'package:nesty_render/svg_tools.dart';
import 'package:nesty_tools/src/assets/png_formats.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

/// The `design/ui/` folder of the widget's art.
const widgetArtFolder = 'widget';

/// Repo-relative folder of the widget's art.
const widgetArtDir = 'design/ui/$widgetArtFolder';

/// The raster scales every SVG also ships at, by file-name suffix (tokens
/// `habits.widget.art.png`: "name.png (1×), name-2x.png and name-3x.png").
const widgetPngScales = {'': 1, '-2x': 2, '-3x': 3};

/// The widget art tokens.json names: each SVG's dp size, the picker
/// previews' pixel sizes.
final class WidgetArt {
  const WidgetArt(this.svgs, this.previews);

  /// `flame_lit.svg` → its dp size (width, height), in file order.
  final Map<String, ({double width, double height})> svgs;

  /// `preview_2x2.png` → its pixel size, in file order.
  final Map<String, ({int width, int height})> previews;
}

final _previews = RegExp(
  r'^(preview_\w+\.png) \((\d+) × (\d+)\) and (preview_\w+\.png) \((\d+) × '
  r'(\d+)\), 3× captures for Android’s previewImage$',
);
final _svgFile = RegExp(r'^[a-z0-9_]+\.svg$');

/// `habits.widget.art` of the decoded tokens.json [tokens]. Throws a
/// [FormatException] naming the path when its shape is not the m7-6 one.
WidgetArt widgetArtOf(Map<String, Object?> tokens) {
  Object? at(String path) {
    Object? node = tokens;
    for (final key in path.split('.')) {
      if (node is! Map<String, Object?> || !node.containsKey(key)) {
        throw FormatException('tokens.json `$path`: missing');
      }
      node = node[key];
    }
    return node;
  }

  const base = 'habits.widget.art';
  if (at('$base.folder') != 'ui/$widgetArtFolder/') {
    throw const FormatException(
      'tokens.json `$base.folder`: expected "ui/$widgetArtFolder/"',
    );
  }
  final files = at('$base.files');
  if (files is! Map<String, Object?> || files.isEmpty) {
    throw const FormatException(
      'tokens.json `$base.files`: expected an object',
    );
  }
  final svgs = <String, ({double width, double height})>{};
  for (final MapEntry(:key, :value) in files.entries) {
    if (!_svgFile.hasMatch(key)) {
      throw FormatException('tokens.json `$base.files`: "$key" is not .svg');
    }
    svgs[key] = switch (value) {
      final num side => (width: side.toDouble(), height: side.toDouble()),
      [final num w, final num h] => (width: w.toDouble(), height: h.toDouble()),
      _ => throw FormatException(
        'tokens.json `$base.files.$key`: a dp size or [width, height]',
      ),
    };
  }
  final previews = at('$base.previews');
  final m = previews is String ? _previews.firstMatch(previews) : null;
  if (m == null) {
    throw FormatException(
      'tokens.json `$base.previews`: unexpected wording "$previews"',
    );
  }
  return WidgetArt(svgs, {
    m[1]!: (width: int.parse(m[2]!), height: int.parse(m[3]!)),
    m[4]!: (width: int.parse(m[5]!), height: int.parse(m[6]!)),
  });
}

/// The shapes a flat vector drawable is made of.
const _shapes = {'path', 'rect', 'circle', 'ellipse'};

/// Each shape's geometry attributes; `fill` and `fill-rule` are checked on
/// their own.
const _geometry = {
  'path': {'d'},
  'rect': {'x', 'y', 'width', 'height', 'rx', 'ry'},
  'circle': {'cx', 'cy', 'r'},
  'ellipse': {'cx', 'cy', 'rx', 'ry'},
};

final _solid = RegExp(r'^#(?:[0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$');
final _viewBox = RegExp(r'^\s*0\s+0\s+(\d+(?:\.\d+)?)\s+(\d+(?:\.\d+)?)\s*$');

/// Problems with one widget SVG ([svg] as exported, metadata included)
/// drawn at [width] × [height] dp. [oneColour], when given, is the only
/// fill allowed (the doll's template black). Empty when it is a flat
/// vector stage 4 can convert.
List<String> validateWidgetSvg(
  String svg, {
  required double width,
  required double height,
  String? oneColour,
}) {
  final stripped = stripSvgMetadata(svg);
  final issues = [for (final i in validateSvg(stripped)) i.toString()];
  final XmlDocument doc;
  try {
    doc = XmlDocument.parse(stripped);
  } on XmlException {
    return issues; // validateSvg reported it.
  }
  final root = doc.rootElement;
  final box = _viewBox.firstMatch(root.getAttribute('viewBox') ?? '');
  if (box == null) {
    issues.add(
      'viewBox must be "0 0 W H", got "${root.getAttribute('viewBox')}"',
    );
  } else {
    final w = double.parse(box[1]!);
    final h = double.parse(box[2]!);
    if ((w / h - width / height).abs() > 0.001) {
      issues.add(
        'the viewBox $w×$h is not the $width×$height dp aspect '
        '(habits.widget.art.files)',
      );
    }
  }
  for (final attribute in root.attributes) {
    final name = attribute.name.qualified;
    const allowed = {'xmlns', 'viewBox', 'width', 'height', 'version'};
    if (!allowed.contains(name) && !name.startsWith('xmlns:')) {
      issues.add('<svg $name> is not flat art (Android vector drawables)');
    }
  }
  var shapes = 0;
  for (final e in root.descendantElements) {
    final tag = e.name.local;
    if (tag == 'g') {
      if (e.attributes.isNotEmpty) {
        issues.add('<g> carries attributes; keep groups bare');
      }
      continue;
    }
    if (!_shapes.contains(tag)) {
      issues.add(
        '<$tag> is not a flat shape (no gradients, filters, masks, clips, '
        'patterns, images or text: Android vector drawables)',
      );
      continue;
    }
    shapes++;
    final fill = e.getAttribute('fill');
    if (fill == null || !_solid.hasMatch(fill)) {
      issues.add('<$tag> needs a solid fill (#RRGGBB), got "$fill"');
    } else if (oneColour != null &&
        fill.toUpperCase() != oneColour.toUpperCase()) {
      issues.add('<$tag> is $fill; this art is one colour, $oneColour');
    }
    for (final attribute in e.attributes) {
      final name = attribute.name.qualified;
      if (name == 'fill' || _geometry[tag]!.contains(name)) continue;
      if (name == 'fill-rule' &&
          (attribute.value == 'evenodd' || attribute.value == 'nonzero')) {
        continue;
      }
      issues.add(
        '<$tag $name="${attribute.value}"> is not flat art (strokes, '
        'opacity, transforms and styles stay out)',
      );
    }
  }
  if (shapes == 0) issues.add('no shapes');
  return issues;
}

/// Validates `design/ui/widget/` under [repoRoot] against the art the
/// decoded tokens.json [tokens] names. Returns `source: issue` lines.
List<String> validateWidgetArt(
  Directory repoRoot,
  Map<String, Object?> tokens,
) {
  final WidgetArt art;
  try {
    art = widgetArtOf(tokens);
  } on FormatException catch (e) {
    return ['design/tokens.json: ${e.message}'];
  }
  final dir = Directory(p.join(repoRoot.path, widgetArtDir));
  if (!dir.existsSync()) return ['$widgetArtDir: missing'];
  final issues = <String>[];
  final expected = <String>{};
  for (final MapEntry(key: name, value: size) in art.svgs.entries) {
    final stem = p.basenameWithoutExtension(name);
    expected.add(name);
    final svg = File(p.join(dir.path, name));
    if (!svg.existsSync()) {
      issues.add('$widgetArtDir/$name: missing');
    } else {
      for (final issue in validateWidgetSvg(
        svg.readAsStringSync(),
        width: size.width,
        height: size.height,
        oneColour: stem == 'doll' ? '#000000' : null,
      )) {
        issues.add('$widgetArtDir/$name: $issue');
      }
    }
    for (final MapEntry(key: suffix, value: scale) in widgetPngScales.entries) {
      final png = '$stem$suffix.png';
      expected.add(png);
      issues.addAll(
        _checkPng(
          File(p.join(dir.path, png)),
          '$widgetArtDir/$png',
          (size.width * scale).round(),
          (size.height * scale).round(),
        ),
      );
    }
  }
  for (final MapEntry(key: name, value: size) in art.previews.entries) {
    expected.add(name);
    issues.addAll(
      _checkPng(
        File(p.join(dir.path, name)),
        '$widgetArtDir/$name',
        size.width,
        size.height,
      ),
    );
  }
  final present = [
    for (final entry in dir.listSync())
      if (!p.basename(entry.path).startsWith('.')) p.basename(entry.path),
  ]..sort();
  for (final name in present) {
    if (!expected.contains(name)) {
      issues.add(
        '$widgetArtDir/$name: not in tokens.json `habits.widget.art` (the '
        'widget art is its SVGs, their 1×/2×/3× PNGs and the two previews)',
      );
    }
  }
  return issues;
}

List<String> _checkPng(File file, String rel, int width, int height) {
  if (!file.existsSync()) return ['$rel: missing'];
  return [
    for (final issue in validatePngSize(file.readAsBytesSync(), width, height))
      '$rel: $issue',
  ];
}
