// What the barrel keeps internal (docs/plans/m1-core-design.md §1; the race
// API of m7-design Phase 2): the rules engine, util and the solver's search
// internals are not exported, and the simulator's bots file exports only
// the `SimBot` policy enum, so apps can name a rival's policy but never
// drive `BotPlayer` or a `Board` themselves (CLAUDE.md rule 2).
//
// public_api_test.dart proves at compile time that the public names are
// exported; a name that must be absent can only be checked in the source.
// VM only: it reads the barrel with dart:io.
@TestOn('vm')
library;

import 'dart:io';
import 'dart:isolate';

import 'package:test/test.dart';

import '../support/dart_source_scanner.dart';

void main() {
  late List<Directive> exports;

  setUpAll(() async {
    final barrel = await Isolate.resolvePackageUri(
      Uri.parse('package:nesty_core/nesty_core.dart'),
    );
    if (barrel == null) {
      throw StateError('package:nesty_core is not in the package config.');
    }
    final source = ScannedSource.parse(File.fromUri(barrel).readAsStringSync());
    exports = [
      for (final directive in directives(source))
        if (directive.code.trimLeft().startsWith('export')) directive,
    ];
  });

  List<String> uris() => [for (final e in exports) ...e.uris];

  test('finds the exports, so the checks are not vacuous', () {
    expect(uris(), contains('package:nesty_core/src/simulator/rival_bot.dart'));
    expect(uris(), contains('package:nesty_core/src/generator/curve.dart'));
  });

  test('the bots file is exported once, showing SimBot only', () {
    final bots = [
      for (final e in exports)
        if (e.uris.contains('package:nesty_core/src/simulator/bots.dart')) e,
    ];
    expect(bots, hasLength(1));
    final combinators = bots.single.code
        .replaceAll(RegExp(r'''(['"]).*?\1'''), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    expect(combinators, 'export show SimBot;');
  });

  test('no engine, util or solver-search library is exported', () {
    final internal = RegExp(
      r'^package:nesty_core/src/('
      r'rules/engine/|util/|'
      r'solver/(bucket_queue|canonical|node_store|search|visited_table)\.dart)',
    );
    expect(uris().where(internal.hasMatch), isEmpty);
  });
}
