// The home-screen widget's native art, generated from Claude Design's
// `design/ui/widget/` (m7-6, App Flow 14.4; docs/plans/plan-local-habits.md
// §4; stage 4 contract §5): the iOS asset catalog of the `NestyWidget`
// extension and the Android vector drawables and picker preview of
// `NestyWidgetProvider`. `widget_art.dart` validates the folder; this file
// converts what it promises (flat solid shapes, 1×/2×/3× PNGs).
//
// - iOS: `apps/game/ios/NestyWidget/Assets.xcassets/<Set>.imageset/`, the
//   PNGs byte for byte minus their C2PA `caBX` chunk, with a Contents.json;
//   `WidgetDoll` is a template image (the widget tints it per colour family).
// - Android: `res/drawable{,-night}/nesty_widget_*.xml` vector drawables
//   (every `<rect>`, `<circle>` and `<ellipse>` becomes a `<path>` of arcs)
//   and `res/drawable-nodpi/nesty_widget_preview_2x2.png`. `preview_4x2.png`
//   is validated and unused: one provider has one `previewImage` slot.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:nesty_render/svg_tools.dart';
import 'package:nesty_tools/src/assets/widget_art.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

/// Repo-relative asset catalog of the widget extension.
const widgetIosCatalog = 'apps/game/ios/NestyWidget/Assets.xcassets';

/// Repo-relative Android resources.
const widgetAndroidRes = 'apps/game/android/app/src/main/res';

/// An image set of the catalog → its `design/ui/widget/` stem.
const widgetImageSets = {
  'WidgetFlameLit': 'flame_lit',
  'WidgetFlameUnlit': 'flame_unlit',
  'WidgetFlameUnlitDark': 'flame_unlit_dark',
  'WidgetDoll': 'doll',
  'WidgetDailyMark': 'daily_mark',
};

/// The image sets drawn as templates (tinted by the widget).
const widgetTemplateSets = {'WidgetDoll'};

/// An Android drawable (`<folder>/<name>.xml`) → its design stem.
const widgetAndroidDrawables = {
  'drawable/nesty_widget_flame_lit.xml': 'flame_lit',
  'drawable/nesty_widget_flame_unlit.xml': 'flame_unlit',
  'drawable-night/nesty_widget_flame_unlit.xml': 'flame_unlit_dark',
  'drawable/nesty_widget_doll.xml': 'doll',
  'drawable/nesty_widget_daily_mark.xml': 'daily_mark',
};

/// The picker preview that ships (the other one is unused).
const widgetAndroidPreviewSource = 'preview_2x2.png';
const widgetAndroidPreviewPath = 'drawable-nodpi/nesty_widget_preview_2x2.png';

/// The catalog root's Contents.json.
String iosCatalogContents() =>
    '${_json({
      'info': {'author': 'xcode', 'version': 1},
    })}\n';

/// `<Set>.imageset/Contents.json` of [set]: the three scales, and a
/// template rendering intent for the tinted doll.
String iosImageSetContents(String set) =>
    '${_json({
      'images': [
        for (final (scale, suffix) in const [('1x', ''), ('2x', '@2x'), ('3x', '@3x')]) {'filename': '$set$suffix.png', 'idiom': 'universal', 'scale': scale},
      ],
      'info': {'author': 'xcode', 'version': 1},
      if (widgetTemplateSets.contains(set)) 'properties': {'template-rendering-intent': 'template'},
    })}\n';

String _json(Object value) => const JsonEncoder.withIndent('  ').convert(value);

/// [png] without its `caBX` chunk (the C2PA manifest the design export
/// embeds), every other chunk untouched. Throws a [FormatException] when it
/// is not a well-formed PNG.
Uint8List stripPngMetadata(List<int> png) {
  final data = Uint8List.fromList(png);
  const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  if (data.length < 8) throw const FormatException('not a PNG');
  for (var i = 0; i < 8; i++) {
    if (data[i] != signature[i]) throw const FormatException('not a PNG');
  }
  final view = ByteData.sublistView(data);
  final out = BytesBuilder()..add(data.sublist(0, 8));
  var offset = 8;
  while (offset < data.length) {
    if (offset + 12 > data.length) {
      throw const FormatException('a PNG chunk is cut short');
    }
    final length = view.getUint32(offset, Endian.big);
    final end = offset + 12 + length;
    if (end > data.length) {
      throw const FormatException('a PNG chunk is cut short');
    }
    final type = String.fromCharCodes(data, offset + 4, offset + 8);
    if (type != 'caBX') out.add(data.sublist(offset, end));
    offset = end;
  }
  return out.toBytes();
}

/// Problems with a widget SVG as an Android vector, or its XML.
final class WidgetVector {
  const WidgetVector(this.xml, this.issues);

  final String? xml;
  final List<String> issues;
}

final _viewBox = RegExp(r'^\s*0\s+0\s+(\d+(?:\.\d+)?)\s+(\d+(?:\.\d+)?)\s*$');
final _hex3 = RegExp(r'^#([0-9A-Fa-f])([0-9A-Fa-f])([0-9A-Fa-f])$');
final _hex6 = RegExp(r'^#[0-9A-Fa-f]{6}$');

/// Converts the flat widget SVG [svg] (validated by `validateWidgetSvg`)
/// into a `<vector>` drawable [widthDp] × [heightDp] in size, [source] being
/// the design file named in the header.
WidgetVector widgetVectorOf(
  String svg, {
  required String source,
  required double widthDp,
  required double heightDp,
}) {
  final XmlDocument doc;
  try {
    doc = XmlDocument.parse(stripSvgMetadata(svg));
  } on XmlException catch (e) {
    return WidgetVector(null, ['not XML: ${e.message}']);
  }
  final root = doc.rootElement;
  final box = _viewBox.firstMatch(root.getAttribute('viewBox') ?? '');
  if (box == null) {
    return const WidgetVector(null, ['viewBox must be "0 0 W H"']);
  }
  final issues = <String>[];
  final paths = <_VectorPath>[];
  void visit(XmlElement element) {
    for (final child in element.childElements) {
      final tag = child.name.local;
      switch (tag) {
        case 'g':
          visit(child);
        case 'path' || 'rect' || 'circle' || 'ellipse':
          final fill = _androidColor(child.getAttribute('fill'));
          final pathData = _pathData(child);
          if (fill == null) {
            issues.add('<$tag> has no solid fill');
          } else if (pathData == null) {
            issues.add('<$tag> has no geometry');
          } else {
            paths.add(
              _VectorPath(
                fill,
                pathData,
                evenOdd: child.getAttribute('fill-rule') == 'evenodd',
              ),
            );
          }
        case 'metadata' || 'title' || 'desc' || 'defs':
          break;
        default:
          issues.add('<$tag> is not a flat shape');
      }
    }
  }

  visit(root);
  if (paths.isEmpty) issues.add('no shapes');
  if (issues.isNotEmpty) return WidgetVector(null, issues);

  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="utf-8"?>')
    ..writeln('<!--')
    ..writeln(
      '  GENERATED — do not edit; run dart run nesty_tools:sync_design_assets',
    )
    ..writeln()
    ..writeln('  Source: $source. The home-screen widget\'s art (local habits')
    ..writeln('  stage 4); RemoteViews draw it, so it is flat and solid.')
    ..writeln('-->')
    ..writeln(
      '<vector xmlns:android="http://schemas.android.com/apk/res/android"',
    )
    ..writeln('    android:width="${_n(widthDp)}dp"')
    ..writeln('    android:height="${_n(heightDp)}dp"')
    ..writeln('    android:viewportWidth="${_n(double.parse(box[1]!))}"')
    ..write('    android:viewportHeight="${_n(double.parse(box[2]!))}">');
  for (final path in paths) {
    buffer
      ..writeln()
      ..writeln('    <path')
      ..writeln('        android:fillColor="${path.color}"');
    if (path.evenOdd) buffer.writeln('        android:fillType="evenOdd"');
    buffer.write('        android:pathData="${_escape(path.data)}" />');
  }
  buffer
    ..writeln()
    ..writeln('</vector>');
  return WidgetVector(buffer.toString(), const []);
}

final class _VectorPath {
  const _VectorPath(this.color, this.data, {required this.evenOdd});

  final String color;
  final String data;
  final bool evenOdd;
}

/// `#RGB` / `#RRGGBB` → Android's `#AARRGGBB`; null for anything else.
String? _androidColor(String? fill) {
  if (fill == null) return null;
  final short = _hex3.firstMatch(fill);
  if (short != null) {
    return '#FF${short[1]}${short[1]}${short[2]}${short[2]}${short[3]}${short[3]}'
        .toUpperCase();
  }
  if (_hex6.hasMatch(fill)) return '#FF${fill.substring(1).toUpperCase()}';
  return null;
}

/// SVG path data of a flat shape: a path's own `d`, a rect (with its
/// rounded corners) or a circle or ellipse as arcs.
String? _pathData(XmlElement e) {
  double num(String name, [double fallback = 0]) =>
      double.tryParse(e.getAttribute(name) ?? '') ?? fallback;
  switch (e.name.local) {
    case 'path':
      final d = e.getAttribute('d')?.trim();
      return d == null || d.isEmpty ? null : d;
    case 'rect':
      final x = num('x');
      final y = num('y');
      final w = num('width');
      final h = num('height');
      if (w <= 0 || h <= 0) return null;
      var rx = num('rx', num('ry'));
      var ry = num('ry', rx);
      rx = rx.clamp(0, w / 2).toDouble();
      ry = ry.clamp(0, h / 2).toDouble();
      if (rx == 0 || ry == 0) {
        return 'M${_n(x)} ${_n(y)}H${_n(x + w)}V${_n(y + h)}H${_n(x)}Z';
      }
      return 'M${_n(x + rx)} ${_n(y)}'
          'H${_n(x + w - rx)}'
          'A${_n(rx)} ${_n(ry)} 0 0 1 ${_n(x + w)} ${_n(y + ry)}'
          'V${_n(y + h - ry)}'
          'A${_n(rx)} ${_n(ry)} 0 0 1 ${_n(x + w - rx)} ${_n(y + h)}'
          'H${_n(x + rx)}'
          'A${_n(rx)} ${_n(ry)} 0 0 1 ${_n(x)} ${_n(y + h - ry)}'
          'V${_n(y + ry)}'
          'A${_n(rx)} ${_n(ry)} 0 0 1 ${_n(x + rx)} ${_n(y)}Z';
    case 'circle':
      final r = num('r');
      return r <= 0 ? null : _ellipse(num('cx'), num('cy'), r, r);
    case 'ellipse':
      final rx = num('rx');
      final ry = num('ry');
      return rx <= 0 || ry <= 0 ? null : _ellipse(num('cx'), num('cy'), rx, ry);
  }
  return null;
}

String _ellipse(double cx, double cy, double rx, double ry) =>
    'M${_n(cx - rx)} ${_n(cy)}'
    'A${_n(rx)} ${_n(ry)} 0 1 0 ${_n(cx + rx)} ${_n(cy)}'
    'A${_n(rx)} ${_n(ry)} 0 1 0 ${_n(cx - rx)} ${_n(cy)}Z';

/// `24.0` → `24`, `4.1` stays, without float noise (`4.1000000000000005`).
String _n(double value) {
  final rounded = double.parse(value.toStringAsFixed(3));
  return rounded == rounded.roundToDouble() ? '${rounded.toInt()}' : '$rounded';
}

String _escape(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll('<', '&lt;');

/// One generated native file: the design file it comes from, its
/// repo-relative [path] and its [bytes].
typedef WidgetNativeFile = ({String source, String path, List<int> bytes});

/// Every native file the widget art makes under [repoRoot], for the decoded
/// tokens.json [tokens] (the art `validateWidgetArt` already accepted), or
/// the issues that stop one. Sorted by path.
({List<WidgetNativeFile> files, List<String> issues}) planWidgetNativeArt(
  Directory repoRoot,
  Map<String, Object?> tokens,
) {
  final WidgetArt art;
  try {
    art = widgetArtOf(tokens);
  } on FormatException catch (e) {
    return (files: const [], issues: ['design/tokens.json: ${e.message}']);
  }
  // Art that is none of the m7-6 set (a scratch repo's) has nothing to
  // convert; a set that is partly there is an issue below.
  if (!widgetImageSets.values.any(
    (stem) => art.svgs.containsKey('$stem.svg'),
  )) {
    return (files: const [], issues: const []);
  }
  final files = <WidgetNativeFile>[];
  final issues = <String>[];
  File sourceOf(String name) => File(p.join(repoRoot.path, widgetArtDir, name));
  String rel(String name) => '$widgetArtDir/$name';

  Uint8List? pngOf(String name) {
    try {
      final stripped = stripPngMetadata(sourceOf(name).readAsBytesSync());
      if (String.fromCharCodes(stripped).contains('c2pa')) {
        issues.add('${rel(name)}: C2PA data survived stripping');
      }
      return stripped;
    } on Object catch (e) {
      issues.add('${rel(name)}: $e');
      return null;
    }
  }

  files.add((
    source: widgetArtDir,
    path: '$widgetIosCatalog/Contents.json',
    bytes: utf8.encode(iosCatalogContents()),
  ));
  for (final MapEntry(key: set, value: stem) in widgetImageSets.entries) {
    for (final (suffix, setSuffix) in const [
      ('', ''),
      ('-2x', '@2x'),
      ('-3x', '@3x'),
    ]) {
      final name = '$stem$suffix.png';
      final bytes = pngOf(name);
      if (bytes == null) continue;
      files.add((
        source: rel(name),
        path: '$widgetIosCatalog/$set.imageset/$set$setSuffix.png',
        bytes: bytes,
      ));
    }
    files.add((
      source: rel('$stem.png'),
      path: '$widgetIosCatalog/$set.imageset/Contents.json',
      bytes: utf8.encode(iosImageSetContents(set)),
    ));
  }
  for (final MapEntry(key: drawable, value: stem)
      in widgetAndroidDrawables.entries) {
    final name = '$stem.svg';
    final size = art.svgs[name];
    if (size == null) {
      issues.add('${rel(name)}: not in tokens.json `habits.widget.art.files`');
      continue;
    }
    final vector = widgetVectorOf(
      sourceOf(name).readAsStringSync(),
      source: rel(name),
      widthDp: size.width,
      heightDp: size.height,
    );
    for (final issue in vector.issues) {
      issues.add('${rel(name)}: $issue');
    }
    if (vector.xml case final xml?) {
      files.add((
        source: rel(name),
        path: '$widgetAndroidRes/$drawable',
        bytes: utf8.encode(xml),
      ));
    }
  }
  final preview = pngOf(widgetAndroidPreviewSource);
  if (preview != null) {
    files.add((
      source: rel(widgetAndroidPreviewSource),
      path: '$widgetAndroidRes/$widgetAndroidPreviewPath',
      bytes: preview,
    ));
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return (files: files, issues: issues);
}
