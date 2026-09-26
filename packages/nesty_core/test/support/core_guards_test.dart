// Proves the architecture guards fire on offending code and stay quiet on
// look-alikes in comments and strings. Without this, a scanner bug could make
// architecture_guard_test.dart pass while enforcing nothing.
import 'package:test/test.dart';

import 'core_guards.dart';
import 'dart_source_scanner.dart';

void main() {
  List<int> linesFlagged(CoreGuard guard, String source) =>
      [for (final (line, _) in guard.check(ScannedSource.parse(source))) line]
        ..sort();

  group('noFlutterImports', () {
    test('flags Flutter, Flame and dart:ui imports and exports', () {
      const source = '''
import 'package:flutter/material.dart';
import "package:flutter_test/flutter_test.dart";
import 'dart:ui' as ui;
export 'package:flame/game.dart';
import 'package:nesty_core/nesty_core.dart';
''';
      expect(linesFlagged(noFlutterImports, source), [1, 2, 3, 4]);
    });

    test('flags the Flutter branch of a conditional import', () {
      const source = '''
import 'src/stub.dart'
    if (dart.library.ui) 'package:flutter/foundation.dart';
''';
      expect(linesFlagged(noFlutterImports, source), [1]);
    });

    test('ignores imports inside comments and strings', () {
      const source = '''
// import 'package:flutter/material.dart';
/* import 'dart:ui'; /* nested */ still a comment */
const example = """
import 'package:flutter/material.dart';
""";
''';
      expect(linesFlagged(noFlutterImports, source), isEmpty);
    });
  });

  group('platformNeutralImports', () {
    test('flags web-only and VM-only libraries', () {
      const source = '''
import 'dart:io';
import 'dart:isolate';
import 'dart:js_interop';
import 'dart:convert';
import 'dart:math';
''';
      expect(linesFlagged(platformNeutralImports, source), [1, 2, 3]);
    });
  });

  group('noDartMathRandom', () {
    test('flags every way of reaching dart:math Random', () {
      const source = '''
import 'dart:math' show Random, max;
import 'dart:math' as math;
final a = Random(42);
final b = math.Random(7);
late Random c;
final d = '\${Random(1).nextInt(3)}';
''';
      expect(linesFlagged(noDartMathRandom, source), [1, 3, 4, 5, 6]);
    });

    test('allows hide Random, other names and mentions in text', () {
      const source = r'''
import 'dart:math' hide Random;
final r = SeededRandom(1); // Random() in a comment
/// Doc comment mentioning Random.secure().
const message = 'never use Random() here';
const raw = r'$Random';
''';
      expect(linesFlagged(noDartMathRandom, source), isEmpty);
    });
  });

  group('noUnseededRandom', () {
    test('flags Random() and Random.secure() but not a seeded Random', () {
      const source = '''
final a = Random();
final b = Random ( );
final c = Random.secure();
final d = Random(seed);
''';
      expect(linesFlagged(noUnseededRandom, source), [1, 2, 3]);
    });
  });

  group('noWallClock', () {
    test('flags DateTime.now, DateTime.timestamp and tear-offs', () {
      const source = r'''
final a = DateTime.now();
final b = DateTime.timestamp();
final c = DateTime.now;
final d = 'at ${DateTime.now()}';
''';
      expect(linesFlagged(noWallClock, source), [1, 2, 3, 4]);
    });

    test('ignores comments, strings and explicit dates', () {
      const source = '''
// DateTime.now() is banned in core.
const hint = 'pass the date in instead of DateTime.now()';
final fixed = DateTime.utc(2026, 9, 25);
''';
      expect(linesFlagged(noWallClock, source), isEmpty);
    });

    test('flags Stopwatch construction and type annotations', () {
      const source = '''
final sw = Stopwatch()..start();
Stopwatch? s;
final ok = elapsedNodes < budget;
''';
      expect(linesFlagged(noWallClock, source), [1, 2]);
    });

    test('ignores Stopwatch in comments and strings', () {
      const source = '''
// Stopwatch is banned
const note = 'no Stopwatch here';
final MyStopwatchLike w = MyStopwatchLike();
''';
      expect(linesFlagged(noWallClock, source), isEmpty);
    });
  });

  group('ScannedSource', () {
    test('keeps both views aligned with the source', () {
      const source = '''
/* c */ final s = 'a\$b \${x + 1} \\' q'; // tail
''';
      final scanned = ScannedSource.parse(source);
      expect(scanned.code.length, source.length);
      expect(scanned.codeAndStrings.length, source.length);
    });

    test('recovers from an unterminated string at the end of the line', () {
      const source = "final s = 'oops\nfinal t = DateTime.now();\n";
      expect(linesFlagged(noWallClock, source), [2]);
    });
  });
}
