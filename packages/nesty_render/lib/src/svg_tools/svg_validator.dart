import 'package:nesty_render/src/svg_tools/svg_issue.dart';
import 'package:xml/xml.dart';

/// The SVG namespace every element must be in.
const svgNamespaceUri = 'http://www.w3.org/2000/svg';

/// The top-level `<g id>` groups of a doll skin, in paint order (spec §12.2).
const skinGroupIds = <String>[
  'shadow',
  'bottom_mask',
  'bottom_detail',
  'top_mask',
  'face',
  'top_detail',
  'shine_top',
  'shine_bottom',
];

/// The skin artboard, `[width, height]` (spec §12.2).
const skinArtboard = <int>[512, 768];

// Spec §12.2 "Allowed SVG features: paths, basic shapes, linear and radial
// gradients, opacity, clipPath" — an allowlist, so anything new (pattern,
// use, marker…) is rejected until someone checks flutter_svg renders it.
const _allowedElements = <String>{
  'g',
  'defs',
  'path',
  'rect',
  'circle',
  'ellipse',
  'line',
  'polyline',
  'polygon',
  'linearGradient',
  'radialGradient',
  'stop',
  'clipPath',
  'title',
  'desc',
};

// Known-unsupported features get their own code so the message says why
// (flutter_svg ignores or mis-renders them; spec §12.2 "Not allowed").
const _forbiddenElements = <String>{
  'filter',
  'mask',
  'text',
  'tspan',
  'textPath',
  'image',
  'foreignObject',
  'style',
  'script',
};

const _gradientElements = <String>{'linearGradient', 'radialGradient'};

final _urlReference = RegExp(r'url\(\s*#([^)\s]+)\s*\)');
final _viewBox = RegExp(
  r'^\s*(-?[\d.]+)[\s,]+(-?[\d.]+)[\s,]+([\d.]+)[\s,]+([\d.]+)\s*$',
);

/// Validates [svg] against the renderable subset of spec §12.2.
///
/// Returns every issue found (empty when the file is fine), so a tool can
/// print them all at once instead of failing on the first.
List<SvgIssue> validateSvg(String svg) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(svg);
  } on XmlException catch (e) {
    return [SvgIssue('parseError', 'Not well-formed XML: ${e.message}')];
  }
  final root = document.rootElement;
  if (root.name.local != 'svg' || root.name.namespaceUri != svgNamespaceUri) {
    return [
      SvgIssue(
        'notSvg',
        'Root element is <${root.name.qualified}>, expected <svg> in the '
            '$svgNamespaceUri namespace.',
      ),
    ];
  }

  final issues = <SvgIssue>[];
  if (_parseViewBox(root.getAttribute('viewBox')) == null) {
    issues.add(
      const SvgIssue('missingViewBox', 'The root <svg> needs a viewBox.'),
    );
  }
  _checkAttributes(root, issues);

  final ids = <String>{};
  final references = <String>[];
  for (final attribute in root.attributes) {
    references.addAll(_references(attribute.value));
  }
  for (final element in root.descendantElements) {
    final name = element.name.local;
    final where = _describe(element);
    if (element.name.namespaceUri != svgNamespaceUri) {
      issues.add(
        SvgIssue(
          'foreignNamespace',
          '$where is outside the SVG namespace'
              '${name == 'manifest' ? ' (C2PA metadata; strip it first)' : ''}.',
        ),
      );
      continue;
    }
    if (name == 'svg') {
      issues.add(SvgIssue('nestedSvg', '$where: nested <svg> is not allowed.'));
    } else if (name == 'metadata') {
      issues.add(
        SvgIssue(
          'metadata',
          '$where: strip <metadata> with stripSvgMetadata before shipping.',
        ),
      );
    } else if (_forbiddenElements.contains(name)) {
      issues.add(
        SvgIssue(
          'forbiddenElement',
          '$where is not allowed (spec §12.2: no filters, masks, text, '
              'images or stylesheets).',
        ),
      );
    } else if (!_allowedElements.contains(name)) {
      issues.add(
        SvgIssue(
          'unsupportedElement',
          '$where is outside the allowed subset (spec §12.2).',
        ),
      );
    }
    final id = element.getAttribute('id');
    if (id != null && !ids.add(id)) {
      issues.add(SvgIssue('duplicateId', '$where: id "$id" is not unique.'));
    }
    _checkAttributes(element, issues);
    for (final attribute in element.attributes) {
      references.addAll(_references(attribute.value));
    }
    final href = _href(element);
    if (href != null && _gradientElements.contains(name)) {
      if (href.startsWith('#')) references.add(href.substring(1));
    }
  }
  for (final reference in references) {
    if (!ids.contains(reference)) {
      issues.add(
        SvgIssue(
          'danglingReference',
          'url(#$reference) does not match any element id.',
        ),
      );
    }
  }
  return issues;
}

/// Validates a doll skin: everything [validateSvg] checks, plus the 512×768
/// artboard and the eight top-level groups of spec §12.2 in paint order.
List<SvgIssue> validateSkinSvg(String svg) {
  final issues = validateSvg(svg);
  if (issues.any((i) => i.code == 'parseError' || i.code == 'notSvg')) {
    return issues;
  }
  final root = XmlDocument.parse(svg).rootElement;
  final box = _parseViewBox(root.getAttribute('viewBox'));
  if (box != null &&
      (box[0] != 0 ||
          box[1] != 0 ||
          box[2] != skinArtboard[0] ||
          box[3] != skinArtboard[1])) {
    issues.add(
      SvgIssue(
        'skinArtboard',
        'viewBox is "${root.getAttribute('viewBox')}", expected '
            '"0 0 ${skinArtboard[0]} ${skinArtboard[1]}".',
      ),
    );
  }
  final groups = <String>[];
  for (final child in root.childElements) {
    final name = child.name.local;
    if (name == 'defs' || name == 'title' || name == 'desc') continue;
    if (name == 'g') {
      groups.add(child.getAttribute('id') ?? '<no id>');
    } else {
      issues.add(
        SvgIssue(
          'skinStrayElement',
          '${_describe(child)} sits outside the eight skin groups.',
        ),
      );
    }
  }
  if (!_sameList(groups, skinGroupIds)) {
    issues.add(
      SvgIssue(
        'skinGroups',
        'Top-level groups are [${groups.join(', ')}], expected '
            '[${skinGroupIds.join(', ')}] in this order.',
      ),
    );
  }
  return issues;
}

void _checkAttributes(XmlElement element, List<SvgIssue> issues) {
  final where = _describe(element);
  for (final attribute in element.attributes) {
    final name = attribute.name.local;
    final value = attribute.value;
    if (name == 'style') {
      issues.add(
        SvgIssue(
          'styleAttribute',
          '$where: use presentation attributes instead of style="…".',
        ),
      );
    } else if (name == 'mix-blend-mode' ||
        value.contains('mix-blend-mode') ||
        name == 'isolation') {
      issues.add(
        SvgIssue('blendMode', '$where: mix-blend-mode is not supported.'),
      );
    } else if (name == 'filter' || name == 'mask') {
      issues.add(
        SvgIssue('forbiddenAttribute', '$where: $name="…" is not allowed.'),
      );
    }
  }
  final href = _href(element);
  if (href != null &&
      !(_gradientElements.contains(element.name.local) &&
          href.startsWith('#'))) {
    issues.add(
      SvgIssue(
        'externalReference',
        '$where: href="$href" is only allowed as a local gradient reference.',
      ),
    );
  }
}

String? _href(XmlElement element) {
  for (final attribute in element.attributes) {
    if (attribute.name.local == 'href') return attribute.value;
  }
  return null;
}

Iterable<String> _references(String value) =>
    _urlReference.allMatches(value).map((m) => m.group(1)!);

List<double>? _parseViewBox(String? value) {
  if (value == null) return null;
  final match = _viewBox.firstMatch(value);
  if (match == null) return null;
  final parts = [for (var i = 1; i <= 4; i++) double.tryParse(match[i]!)];
  if (parts.contains(null)) return null;
  return parts.cast<double>();
}

String _describe(XmlElement element) {
  final id = element.getAttribute('id');
  return '<${element.name.qualified}${id == null ? '' : ' id="$id"'}>';
}

bool _sameList(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
