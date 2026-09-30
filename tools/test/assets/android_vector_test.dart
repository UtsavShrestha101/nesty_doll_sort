import 'dart:io';

import 'package:nesty_tools/src/assets/android_vector.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:xml/xml.dart';

const _ns = 'xmlns="http://www.w3.org/2000/svg"';

String _svg(String body, {String box = '0 0 24 24'}) =>
    '<svg $_ns viewBox="$box" width="24" height="24">$body</svg>';

const _square = '<path d="M2 2H8V8H2Z" fill="#FFFFFF"/>';

void main() {
  group('the design file (design/ui/notification/ic_notification.svg)', () {
    final design = File(
      p.join(findRepoRoot().path, notificationIconSource),
    ).readAsStringSync();
    final vector = androidVectorOf(design);

    test('converts with no issue, C2PA metadata and all', () {
      expect(vector.issues, isEmpty);
      expect(design, contains('c2pa'));
      expect(vector.xml, isNot(contains('c2pa')));
    });

    test('is a 24 dp white vector with the path data as drawn', () {
      final doc = XmlDocument.parse(vector.xml!);
      final root = doc.rootElement;
      expect(root.name.local, 'vector');
      String attr(XmlElement e, String name) => e.getAttribute(
        name,
        namespaceUri: 'http://schemas.android.com/apk/res/android',
      )!;
      expect(attr(root, 'width'), '24dp');
      expect(attr(root, 'height'), '24dp');
      expect(attr(root, 'viewportWidth'), '24');
      expect(attr(root, 'viewportHeight'), '24');
      final path = root.childElements.single;
      expect(attr(path, 'fillColor'), '#FFFFFFFF');
      // The doll's face is a hole: the even-odd rule keeps it open.
      expect(attr(path, 'fillType'), 'evenOdd');
      final d = XmlDocument.parse(
        design,
      ).findAllElements('path').single.getAttribute('d');
      expect(attr(path, 'pathData'), d);
    });

    test('is marked generated', () {
      expect(vector.xml, contains('GENERATED — do not edit'));
    });
  });

  group('accepts', () {
    test('a nonzero white path, #FFF and white, an empty <defs>', () {
      for (final fill in ['#FFF', '#ffffff', 'white']) {
        final v = androidVectorOf(
          _svg('<defs></defs><path d="M0 0H9V9Z" fill="$fill"/>'),
        );
        expect(v.issues, isEmpty, reason: fill);
        expect(v.xml, isNot(contains('fillType')), reason: fill);
      }
    });

    test('several paths, and a viewport other than 24', () {
      final v = androidVectorOf(
        _svg('$_square<path d="M1 1H2V2Z" fill="#FFFFFF"/>', box: '0 0 48 36'),
      );
      expect(v.issues, isEmpty);
      expect(RegExp('<path').allMatches(v.xml!), hasLength(2));
      expect(v.xml, contains('android:viewportWidth="48"'));
      expect(v.xml, contains('android:viewportHeight="36"'));
      expect(v.xml, contains('android:width="24dp"'));
    });
  });

  group('refuses what a status-bar icon cannot draw', () {
    List<String> issues(String body, {String box = '0 0 24 24'}) =>
        androidVectorOf(_svg(body, box: box)).issues;

    test('a group', () {
      expect(issues('<g>$_square</g>'), [
        contains('<g> is not a <path>'),
        'there is no <path>',
      ]);
    });

    test('a circle', () {
      expect(issues('<circle cx="4" cy="4" r="2" fill="#FFFFFF"/>'), [
        contains('<circle> is not a <path>'),
        'there is no <path>',
      ]);
    });

    test('a transform', () {
      expect(
        issues('<path d="M0 0H9" fill="#FFFFFF" transform="translate(1 1)"/>'),
        [contains('transform="translate(1 1)"')],
      );
    });

    test('a stroke', () {
      expect(issues('<path d="M0 0H9" fill="#FFFFFF" stroke="#FFFFFF"/>'), [
        contains('stroke="#FFFFFF"'),
      ]);
    });

    test('a coloured fill, or none', () {
      expect(issues('<path d="M0 0H9" fill="#F2893B"/>'), [
        'a <path> is filled #F2893B, not white',
      ]);
      expect(issues('<path d="M0 0H9"/>'), [
        'a <path> has no fill (it must be white)',
      ]);
    });

    test('a gradient in <defs>, an offset viewBox, no path at all', () {
      expect(issues('<defs><linearGradient id="g"/></defs>$_square'), [
        contains('<defs> is not empty'),
      ]);
      expect(issues(_square, box: '2 2 24 24'), [contains('viewBox')]);
      expect(issues(''), ['there is no <path>']);
    });

    test('an empty d, and a document that is not an SVG', () {
      expect(issues('<path d="" fill="#FFFFFF"/>'), ['a <path> has no d']);
      expect(androidVectorOf('<vector/>').issues, [
        'the root is <vector>, not <svg>',
      ]);
      expect(androidVectorOf('<svg').issues, [startsWith('not XML')]);
    });

    test('never returns XML with an issue', () {
      expect(androidVectorOf(_svg('<g/>')).xml, isNull);
    });
  });
}
