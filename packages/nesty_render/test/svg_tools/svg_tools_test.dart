import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/svg_tools.dart';

const _ns = 'xmlns="http://www.w3.org/2000/svg"';

String _svg(String body, {String viewBox = '0 0 10 10'}) =>
    '<svg $_ns viewBox="$viewBox">$body</svg>';

String _skin({List<String> groups = skinGroupIds, String extra = ''}) => _svg(
  '<defs><linearGradient id="a"><stop offset="0"/></linearGradient></defs>'
  '${groups.map((g) => '<g id="$g"><rect width="1" height="1" '
      'fill="url(#a)"/></g>').join()}$extra',
  viewBox: '0 0 512 768',
);

List<String> _codes(List<SvgIssue> issues) => [for (final i in issues) i.code];

void main() {
  group('stripSvgMetadata', () {
    const c2pa =
        '<svg $_ns viewBox="0 0 1 1" xmlns:c2pa="http://c2pa.org/manifest">'
        '<metadata><c2pa:manifest>AAAA</c2pa:manifest></metadata>'
        '<path d="M0 0"/></svg>';

    test('removes the C2PA metadata block and its namespace only', () {
      expect(
        stripSvgMetadata(c2pa),
        '<svg $_ns viewBox="0 0 1 1"><path d="M0 0"/></svg>',
      );
    });

    test('is idempotent', () {
      final once = stripSvgMetadata(c2pa);
      expect(stripSvgMetadata(once), once);
    });

    test('removes self-closing and multi-line metadata', () {
      expect(
        stripSvgMetadata(
          '<svg $_ns><metadata/>\n<metadata a="1">\nx\n'
          '</metadata ><g/></svg>',
        ),
        '<svg $_ns>\n<g/></svg>',
      );
    });

    test('the stripped design file validates, the raw one does not', () {
      expect(_codes(validateSvg(c2pa)), contains('metadata'));
      expect(validateSvg(stripSvgMetadata(c2pa)), isEmpty);
    });
  });

  group('validateSvg', () {
    test('accepts the spec §12.2 subset', () {
      final svg = _svg(
        '<defs><radialGradient id="r"><stop offset="0" stop-color="#fff"/>'
        '</radialGradient><linearGradient id="l" href="#r"/>'
        '<clipPath id="c"><rect width="5" height="5"/></clipPath></defs>'
        '<g clip-path="url(#c)" opacity="0.5"><path d="M0 0L1 1" '
        'fill="url(#l)"/><circle r="1"/><ellipse rx="1" ry="2"/>'
        '<polygon points="0,0 1,1"/></g>',
      );
      expect(validateSvg(svg), isEmpty);
    });

    test('rejects malformed XML', () {
      expect(_codes(validateSvg('<svg $_ns><g></svg>')), ['parseError']);
    });

    test('rejects a non-svg root', () {
      expect(_codes(validateSvg('<html/>')), ['notSvg']);
      expect(_codes(validateSvg('<svg viewBox="0 0 1 1"/>')), ['notSvg']);
    });

    test('requires a viewBox', () {
      expect(_codes(validateSvg('<svg $_ns/>')), ['missingViewBox']);
    });

    for (final element in [
      'filter',
      'mask',
      'text',
      'image',
      'foreignObject',
      'style',
    ]) {
      test('rejects <$element>', () {
        expect(_codes(validateSvg(_svg('<$element/>'))), ['forbiddenElement']);
      });
    }

    test('rejects nested <svg>', () {
      expect(_codes(validateSvg(_svg('<g><svg/></g>'))), ['nestedSvg']);
    });

    test('rejects elements outside the allowlist', () {
      expect(_codes(validateSvg(_svg('<pattern/>'))), ['unsupportedElement']);
      expect(_codes(validateSvg(_svg('<use/>'))), ['unsupportedElement']);
    });

    test('rejects style attributes and mix-blend-mode', () {
      expect(_codes(validateSvg(_svg('<g style="fill:red"/>'))), [
        'styleAttribute',
      ]);
      expect(_codes(validateSvg(_svg('<g mix-blend-mode="multiply"/>'))), [
        'blendMode',
      ]);
    });

    test('rejects filter and mask attributes', () {
      expect(_codes(validateSvg(_svg('<g filter="x"/><g mask="y"/>'))), [
        'forbiddenAttribute',
        'forbiddenAttribute',
      ]);
    });

    test('rejects hrefs other than local gradient references', () {
      expect(
        _codes(validateSvg(_svg('<linearGradient href="http://x/#a"/>'))),
        ['externalReference'],
      );
    });

    test('rejects dangling url(#id) references and duplicate ids', () {
      expect(_codes(validateSvg(_svg('<rect fill="url(#nope)"/>'))), [
        'danglingReference',
      ]);
      expect(_codes(validateSvg(_svg('<g id="a"/><g id="a"/>'))), [
        'duplicateId',
      ]);
    });

    test('reports every issue, not just the first', () {
      expect(_codes(validateSvg(_svg('<text/><g style="a"/><mask/>'))), [
        'forbiddenElement',
        'styleAttribute',
        'forbiddenElement',
      ]);
    });
  });

  group('validateSkinSvg', () {
    test('accepts the eight groups in paint order', () {
      expect(validateSkinSvg(_skin()), isEmpty);
    });

    test('rejects missing, extra or reordered groups', () {
      expect(_codes(validateSkinSvg(_skin(groups: skinGroupIds.sublist(1)))), [
        'skinGroups',
      ]);
      expect(
        _codes(validateSkinSvg(_skin(groups: [...skinGroupIds.reversed]))),
        ['skinGroups'],
      );
      expect(
        _codes(validateSkinSvg(_skin(groups: [...skinGroupIds, 'extra']))),
        ['skinGroups'],
      );
    });

    test('rejects shapes outside the groups', () {
      expect(_codes(validateSkinSvg(_skin(extra: '<rect/>'))), [
        'skinStrayElement',
      ]);
    });

    test('rejects the wrong artboard', () {
      final svg = _skin().replaceFirst('0 0 512 768', '0 0 100 100');
      expect(_codes(validateSkinSvg(svg)), ['skinArtboard']);
    });
  });

  group('validateSkinManifest', () {
    Map<String, Object?> manifest() => {
      'skinId': 'forest-bear',
      'name': 'Forest Bear',
      'splitY': 400,
      'lidLiftPx': 120,
      'symbolAnchor': [256, 590],
      'symbolSize': 110,
      'artboard': [512, 768],
      'groups': [...skinGroupIds],
      'tinted': ['bottom_mask', 'top_mask'],
      'lidGroups': ['top_mask', 'face', 'top_detail', 'shine_top'],
      'version': 1,
    };

    test('accepts the design handoff shape', () {
      expect(
        validateSkinManifest(manifest(), expectedSkinId: 'forest-bear'),
        isEmpty,
      );
    });

    test('accepts the minimal spec §12.2 sidecar', () {
      final minimal = manifest()
        ..remove('name')
        ..remove('artboard')
        ..remove('groups')
        ..remove('tinted')
        ..remove('lidGroups');
      expect(validateSkinManifest(minimal), isEmpty);
    });

    test('rejects a non-object', () {
      expect(_codes(validateSkinManifest([1])), ['manifestNotObject']);
    });

    test('rejects missing and unknown keys', () {
      final json = manifest()
        ..remove('splitY')
        ..['colour'] = 'red';
      expect(_codes(validateSkinManifest(json)), [
        'manifestMissingKey',
        'manifestUnknownKey',
      ]);
    });

    test('rejects a skinId that does not match its folder', () {
      expect(
        _codes(validateSkinManifest(manifest(), expectedSkinId: 'forest')),
        ['manifestBadValue'],
      );
    });

    final badValues = <String, Object?>{
      'skinId': 'Forest Bear',
      'name': '',
      'version': 0,
      'artboard': [512, 512],
      'splitY': 900,
      'lidLiftPx': -1,
      'symbolAnchor': [256],
      'symbolSize': 'big',
      'groups': ['shadow'],
      'tinted': ['bottom_mask', 'bottom_mask'],
      'lidGroups': ['lid'],
    };
    badValues.forEach((key, value) {
      test('rejects a bad "$key"', () {
        final json = manifest()..[key] = value;
        expect(_codes(validateSkinManifest(json)), ['manifestBadValue']);
      });
    });
  });
}
