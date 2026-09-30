// Converts Claude Design's monochrome notification icon
// (`design/ui/notification/ic_notification.svg`) into the Android vector
// drawable the daily reminder names as its small icon (E4, spec-prop §7.9;
// phase 4 architecture §1.3). Android draws a status-bar icon as a white
// silhouette of its alpha, so the converter accepts only what that needs:
// white-filled `<path>`s on a `0 0 W H` viewBox, nothing that would need a
// transform, a stroke or a second colour. Anything else is an issue, so a
// richer export is noticed instead of silently mis-drawn.
import 'package:nesty_render/svg_tools.dart';
import 'package:xml/xml.dart';

/// Repo-relative source and output of the notification icon. The main
/// source set serves every flavor.
const notificationIconSource = 'design/ui/notification/ic_notification.svg';
const notificationIconDrawable =
    'apps/game/android/app/src/main/res/drawable/ic_notification.xml';

/// The drawable's size: Android's status-bar icon box.
const _iconDp = 24;

final _viewBox = RegExp(r'^\s*0\s+0\s+(\d+(?:\.\d+)?)\s+(\d+(?:\.\d+)?)\s*$');
const _white = {'#fff', '#ffffff', 'white'};

/// The result of one conversion: the drawable's XML, or why there is none.
final class AndroidVector {
  const AndroidVector(this.xml, this.issues);

  /// The `<vector>` drawable (null when [issues] is not empty).
  final String? xml;

  /// What the SVG does that a notification icon can't (English, for tools).
  final List<String> issues;
}

/// Converts [svg] (metadata is stripped first) into an Android
/// `<vector>` drawable: one `<path>` per SVG path, white, even-odd where
/// the SVG says `fill-rule="evenodd"`. SVG path data (arcs included) is
/// valid `android:pathData`, so each `d` is copied as it is.
AndroidVector androidVectorOf(String svg) {
  final issues = <String>[];
  final XmlDocument doc;
  try {
    doc = XmlDocument.parse(stripSvgMetadata(svg));
  } on XmlException catch (e) {
    return AndroidVector(null, ['not XML: ${e.message}']);
  }
  final root = doc.rootElement;
  if (root.name.local != 'svg') {
    return AndroidVector(null, ['the root is <${root.name.local}>, not <svg>']);
  }
  final box = _viewBox.firstMatch(root.getAttribute('viewBox') ?? '');
  if (box == null) {
    issues.add(
      'viewBox must be "0 0 W H", got "${root.getAttribute('viewBox')}"',
    );
  }
  for (final attribute in root.attributes) {
    final name = attribute.name.qualified;
    const allowed = {'xmlns', 'viewBox', 'width', 'height', 'version'};
    if (!allowed.contains(name) && !name.startsWith('xmlns:')) {
      issues.add('<svg> has $name="${attribute.value}"');
    }
  }

  final paths = <(String, bool)>[];
  for (final element in root.childElements) {
    final tag = element.name.local;
    if (tag == 'defs' || tag == 'title' || tag == 'desc') {
      if (tag == 'defs' && element.childElements.isNotEmpty) {
        issues.add('<defs> is not empty (gradients, clips and masks are out)');
      }
      continue;
    }
    if (tag != 'path') {
      issues.add(
        '<$tag> is not a <path>; draw every shape as a path (no groups, '
        'circles or rects)',
      );
      continue;
    }
    final d = element.getAttribute('d')?.trim() ?? '';
    if (d.isEmpty) issues.add('a <path> has no d');
    var evenOdd = false;
    for (final attribute in element.attributes) {
      final name = attribute.name.qualified;
      final value = attribute.value.trim();
      switch (name) {
        case 'd':
          break;
        case 'fill':
          if (!_white.contains(value.toLowerCase())) {
            issues.add('a <path> is filled $value, not white');
          }
        case 'fill-rule':
          if (value == 'evenodd') {
            evenOdd = true;
          } else if (value != 'nonzero') {
            issues.add('a <path> has fill-rule="$value"');
          }
        default:
          issues.add(
            'a <path> has $name="$value" (only d, a white fill and '
            'fill-rule are allowed)',
          );
      }
    }
    if (element.getAttribute('fill') == null) {
      issues.add('a <path> has no fill (it must be white)');
    }
    if (element.childElements.isNotEmpty) {
      issues.add('a <path> has children');
    }
    paths.add((d, evenOdd));
  }
  if (paths.isEmpty) issues.add('there is no <path>');
  if (issues.isNotEmpty || box == null) return AndroidVector(null, issues);

  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="utf-8"?>')
    ..writeln('<!--')
    ..writeln(
      '  GENERATED — do not edit; run dart run nesty_tools:sync_design_assets',
    )
    ..writeln()
    ..writeln('  Source: $notificationIconSource. The daily')
    ..writeln(
      "  reminder's small icon (E4, spec-prop §7.9); Android draws it as a",
    )
    ..writeln(
      '  white silhouette of its alpha. res/raw/keep.xml keeps it through R8',
    )
    ..writeln('  resource shrinking.')
    ..writeln('-->')
    ..writeln(
      '<vector xmlns:android="http://schemas.android.com/apk/res/android"',
    )
    ..writeln('    android:width="${_iconDp}dp"')
    ..writeln('    android:height="${_iconDp}dp"')
    ..writeln('    android:viewportWidth="${_number(box[1]!)}"')
    ..write('    android:viewportHeight="${_number(box[2]!)}">');
  for (final (d, evenOdd) in paths) {
    buffer
      ..writeln()
      ..writeln('    <path')
      ..writeln('        android:fillColor="#FFFFFFFF"');
    if (evenOdd) buffer.writeln('        android:fillType="evenOdd"');
    buffer.write('        android:pathData="${_escape(d)}" />');
  }
  buffer
    ..writeln()
    ..writeln('</vector>');
  return AndroidVector(buffer.toString(), const []);
}

/// `24.0` → `24`, `23.5` stays.
String _number(String text) {
  final value = double.parse(text);
  return value == value.roundToDouble() ? '${value.toInt()}' : text;
}

String _escape(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll('<', '&lt;');
