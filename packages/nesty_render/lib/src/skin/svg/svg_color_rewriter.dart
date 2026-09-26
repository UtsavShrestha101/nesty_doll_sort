import 'dart:ui' show Color;

import 'package:nesty_render/src/palette/color_math.dart';
import 'package:xml/xml.dart';

final _urlReference = RegExp(r'^url\(\s*#([^)\s]+)\s*\)$');
const _paintAttributes = ['fill', 'stroke'];
const _gradients = {'linearGradient', 'radialGradient'};

/// Rewrites the gray colours of a layer SVG, the way
/// design/generator/nesty-doll.js tints a mask group before it is drawn.
///
/// Used for the gold gradient map (spec §12.3, D19), which is not linear in
/// the gray level and so cannot be applied to the gray raster with a
/// `ColorFilter` the way the flat colours are.
abstract final class SvgColorRewriter {
  /// Returns [layerSvg] with every gray `fill` / `stroke` inside its
  /// drawable content, and every gray `stop-color` of the gradients that
  /// content references, replaced by `map(gray)`.
  ///
  /// [layerSvg] is one layer from `SkinSvgSplitter`: it owns its copy of
  /// the skin's `<defs>`, so rewriting a shared gradient here cannot leak
  /// into another layer (the JS clones such gradients for the same reason).
  /// Non-gray values, `none`, `currentColor`, opacity and geometry are left
  /// alone. Gradients inherited through `href` are rewritten too, since
  /// their stops are what the referencing element shows.
  static String rewriteGrays(String layerSvg, Color Function(int gray) map) {
    final document = XmlDocument.parse(layerSvg);
    _visitColors(document.rootElement, (element, attribute, value) {
      if (grayLevelOf(value) case final gray?) {
        element.setAttribute(attribute, hexOf(map(gray)));
      }
    });
    return document.toXmlString();
  }

  /// The colour values in [layerSvg]'s drawable content and referenced
  /// gradient stops that are not gray.
  ///
  /// A tinted mask group must be pure grayscale (spec §12.2): the JS leaves
  /// other colours untinted while `BlendMode.modulate` would tint them, so
  /// the skin tests assert this is empty for every mask of every skin.
  static Set<String> nonGrayColors(String layerSvg) {
    final found = <String>{};
    _visitColors(XmlDocument.parse(layerSvg).rootElement, (_, _, value) {
      if (value != 'none' && grayLevelOf(value) == null) found.add(value);
    });
    return found;
  }

  /// Calls [visit] for every `fill` / `stroke` of the root's drawable
  /// children that is not a `url(#…)` reference, and for every
  /// `stop-color` of the gradients those references reach.
  static void _visitColors(
    XmlElement root,
    void Function(XmlElement element, String attribute, String value) visit,
  ) {
    final byId = <String, XmlElement>{};
    for (final e in root.descendantElements) {
      final id = e.getAttribute('id');
      if (id != null) byId[id] = e;
    }
    final pending = <String>[];
    for (final content in root.childElements) {
      if (content.name.local == 'defs') continue;
      for (final e in [content, ...content.descendantElements]) {
        for (final name in _paintAttributes) {
          final value = e.getAttribute(name);
          if (value == null) continue;
          final ref = _urlReference.firstMatch(value);
          if (ref != null) {
            pending.add(ref.group(1)!);
          } else {
            visit(e, name, value);
          }
        }
      }
    }
    final done = <String>{};
    while (pending.isNotEmpty) {
      final id = pending.removeLast();
      if (!done.add(id)) continue;
      final gradient = byId[id];
      if (gradient == null || !_gradients.contains(gradient.name.local)) {
        continue;
      }
      for (final stop in gradient.childElements) {
        if (stop.name.local != 'stop') continue;
        final value = stop.getAttribute('stop-color');
        if (value != null) visit(stop, 'stop-color', value);
      }
      final href = _href(gradient);
      if (href != null && href.startsWith('#')) pending.add(href.substring(1));
    }
  }

  static String? _href(XmlElement element) {
    for (final attribute in element.attributes) {
      if (attribute.name.local == 'href') return attribute.value;
    }
    return null;
  }
}
