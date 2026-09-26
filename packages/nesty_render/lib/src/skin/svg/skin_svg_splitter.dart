import 'package:nesty_render/src/svg_tools/svg_issue.dart';
import 'package:nesty_render/src/svg_tools/svg_sanitizer.dart';
import 'package:nesty_render/src/svg_tools/svg_validator.dart';
import 'package:xml/xml.dart';

// Pure Dart (package:xml only, no dart:ui) on purpose: the admin splits a
// skin on upload the same way (spec §12.2 "the admin splits the SVG into
// per-group SVG strings on upload (using the xml package)"), and a
// Flutter-free tool can too.

/// The per-group SVGs of one skin: group id → a standalone SVG that draws
/// only that group on the full 512×768 artboard (spec §12.2).
final class SkinLayers {
  /// Wraps already split layers, e.g. the per-group files a Storage skin
  /// ships (spec §14.2, M4). Every group of [skinGroupIds] must be present.
  SkinLayers(Map<String, String> groups) : groups = Map.unmodifiable(groups) {
    final missing = skinGroupIds.where((id) => !groups.containsKey(id));
    if (missing.isNotEmpty) {
      throw ArgumentError.value(
        groups.keys.toList(),
        'groups',
        'Missing skin layers: ${missing.join(', ')}',
      );
    }
  }

  /// Group id → standalone SVG source.
  final Map<String, String> groups;

  /// The standalone SVG of group [id]. Throws for an unknown id.
  String operator [](String id) =>
      groups[id] ?? (throw ArgumentError.value(id, 'id', 'Unknown skin group'));
}

/// A skin SVG that failed the spec §12.2 checks.
final class SkinSvgException implements Exception {
  const SkinSvgException(this.issues);

  final List<SvgIssue> issues;

  @override
  String toString() => 'SkinSvgException: ${issues.join('; ')}';
}

/// Splits a canonical skin SVG into its eight groups.
abstract final class SkinSvgSplitter {
  /// Validates [svg] (after stripping `<metadata>`, which the design exports
  /// carry) and returns one standalone SVG per group of [skinGroupIds].
  ///
  /// Each layer keeps the root's attributes except `width`/`height` (so it
  /// is sized by its viewBox), a copy of **every** `<defs>` (a group may
  /// reference any gradient or clip path, and a per-layer copy lets the
  /// gold rewrite change stops without touching other layers), and the
  /// group element itself with its own `clip-path`, `opacity` and
  /// `transform`. Throws [SkinSvgException] when the SVG breaks spec §12.2.
  static SkinLayers split(String svg) {
    final clean = stripSvgMetadata(svg);
    final issues = validateSkinSvg(clean);
    if (issues.isNotEmpty) throw SkinSvgException(issues);

    final root = XmlDocument.parse(clean).rootElement;
    final defs = [
      for (final child in root.childElements)
        if (child.name.local == 'defs') child,
    ];
    final attributes = [
      for (final a in root.attributes)
        if (a.name.qualified != 'width' && a.name.qualified != 'height')
          a.copy(),
    ];
    final groups = <String, String>{};
    for (final child in root.childElements) {
      if (child.name.local != 'g') continue;
      final id = child.getAttribute('id')!;
      final layer = XmlElement.tag(
        root.name.qualified,
        attributes: [for (final a in attributes) a.copy()],
        children: [for (final d in defs) d.copy(), child.copy()],
        isSelfClosing: false,
      );
      groups[id] = XmlDocument([layer]).toXmlString();
    }
    return SkinLayers(groups);
  }
}
