import 'dart:convert';
import 'dart:io';

import 'package:nesty_tools/src/assets/widget_art.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:nesty_tools/src/tokens/design_tokens_codegen.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _ns = 'xmlns="http://www.w3.org/2000/svg"';

String _svg(String body, {String box = '0 0 48 48'}) =>
    '<svg $_ns viewBox="$box">$body</svg>';

void main() {
  final root = findRepoRoot();
  final tokens =
      jsonDecode(File(p.join(root.path, tokensJsonPath)).readAsStringSync())
          as Map<String, Object?>;

  group('the real m7-6 widget art', () {
    test('is what tokens.json `habits.widget.art` names', () {
      final art = widgetArtOf(tokens);
      expect(art.svgs, {
        'flame_lit.svg': (width: 44.0, height: 44.0),
        'flame_unlit.svg': (width: 44.0, height: 44.0),
        'flame_unlit_dark.svg': (width: 44.0, height: 44.0),
        'doll.svg': (width: 18.0, height: 24.0),
        'daily_mark.svg': (width: 52.0, height: 52.0),
      });
      expect(art.previews, {
        'preview_2x2.png': (width: 492, height: 492),
        'preview_4x2.png': (width: 1044, height: 492),
      });
    });

    test('validates: flat SVGs, 1×/2×/3× PNGs, the previews, nothing else', () {
      expect(validateWidgetArt(root, tokens), isEmpty);
      final files = Directory(p.join(root.path, widgetArtDir))
          .listSync()
          .map((e) => p.basename(e.path))
          .where((n) => !n.startsWith('.'));
      // 5 SVGs × (svg + 3 PNGs) + 2 previews.
      expect(files, hasLength(22));
    });

    test('never ships as a Flutter asset', () {
      expect(
        Directory(p.join(root.path, 'apps/game/assets/ui/widget')).existsSync(),
        isFalse,
      );
    });
  });

  group('validateWidgetSvg', () {
    test('accepts flat paths, rects, circles and ellipses', () {
      expect(
        validateWidgetSvg(
          _svg(
            '<g><path d="M0 0H4V4Z" fill="#F2702B" fill-rule="evenodd"/>'
            '<rect x="1" y="1" width="4" height="4" rx="1" fill="#FFF"/>'
            '<circle cx="2" cy="2" r="1" fill="#000000"/>'
            '<ellipse cx="2" cy="2" rx="1" ry="2" fill="#FFF1DE"/></g>',
          ),
          width: 44,
          height: 44,
        ),
        isEmpty,
      );
    });

    test('refuses what a vector drawable conversion would lose', () {
      for (final (body, words) in [
        ('<path d="M0 0" fill="url(#g)"/>', 'needs a solid fill'),
        ('<path d="M0 0"/>', 'needs a solid fill'),
        ('<path d="M0 0" fill="#FFF" stroke="#000"/>', 'stroke'),
        ('<path d="M0 0" fill="#FFF" opacity="0.5"/>', 'opacity'),
        ('<path d="M0 0" fill="#FFF" transform="scale(2)"/>', 'transform'),
        ('<g transform="scale(2)"><path d="M0 0" fill="#FFF"/></g>', '<g>'),
        ('<radialGradient id="g"/><path d="M0 0" fill="#FFF"/>', 'flat'),
        ('<filter id="f"/><path d="M0 0" fill="#FFF"/>', 'flat'),
        ('<mask id="m"/><path d="M0 0" fill="#FFF"/>', 'flat'),
        ('', 'no shapes'),
      ]) {
        expect(
          validateWidgetSvg(_svg(body), width: 44, height: 44),
          contains(contains(words)),
          reason: body,
        );
      }
    });

    test('keeps the dp aspect and the doll\'s one colour', () {
      expect(
        validateWidgetSvg(
          _svg('<path d="M0 0" fill="#000000"/>', box: '0 0 24 24'),
          width: 18,
          height: 24,
        ),
        [contains('is not the 18.0×24.0 dp aspect')],
      );
      expect(
        validateWidgetSvg(
          _svg('<path d="M0 0" fill="#5B3A21"/>', box: '0 0 24 32'),
          width: 18,
          height: 24,
          oneColour: '#000000',
        ),
        [contains('this art is one colour, #000000')],
      );
    });
  });

  test('widgetArtOf fails loudly on a changed shape', () {
    Map<String, Object?> withArt(Map<String, Object?> art) => {
      'habits': {
        'widget': {'art': art},
      },
    };
    final good = {
      'folder': 'ui/widget/',
      'files': {'a.svg': 10},
      'previews':
          'preview_2x2.png (1 × 1) and preview_4x2.png (2 × 1), 3× captures '
          'for Android’s previewImage',
    };
    expect(widgetArtOf(withArt(good)).svgs.keys, ['a.svg']);
    for (final bad in [
      {...good, 'folder': 'ui/widgets/'},
      {
        ...good,
        'files': {'a.png': 10},
      },
      {
        ...good,
        'files': {'a.svg': 'big'},
      },
      {...good, 'previews': 'preview_2x2.png and preview_4x2.png'},
    ]) {
      expect(() => widgetArtOf(withArt(bad)), throwsFormatException);
    }
  });
}
