/// Source rules that `nesty_core/lib` must always satisfy.
///
/// They turn CLAUDE.md rules 2 and 7, spec §6.5 and the web-safe arithmetic
/// rules of docs/plans/m1-core-design.md §3 (Q9) into checks that fail
/// `dart test`, instead of relying on review. Shared by the guard test (which
/// runs them on `lib/`) and the scanner tests (which prove each one fires).
///
/// The VM runs `dart test` without a web platform unless CI asks for one, so
/// a construct that only misbehaves in dart2js must be caught here: the
/// parity suites compare against VM-computed constants and can't see it on
/// the VM. ("Mask after `<<`" is not mechanically checkable; the parity
/// suites on node and chrome cover it.)
library;

import 'dart_source_scanner.dart';

/// One rule. [check] returns `(line, detail)` for every offending spot.
class CoreGuard {
  const CoreGuard(this.description, this.check);

  final String description;
  final List<(int, String)> Function(ScannedSource source) check;
}

/// All guards, in the order the guard test reports them.
final List<CoreGuard> coreGuards = [
  noFlutterImports,
  platformNeutralImports,
  noDartMathRandom,
  noUnseededRandom,
  noWallClock,
  noBitwiseNot,
  no64BitTypedLists,
  noHashCollections,
];

/// CLAUDE.md rule 2: core is pure Dart, so the game, the web admin and the
/// Dart VM (tests, tools) all run the same rules. Flame is Flutter too.
final noFlutterImports = CoreGuard(
  'imports nothing from Flutter, Flame or dart:ui (CLAUDE.md rule 2)',
  (source) => _bannedUris(source, _flutterUri),
);

/// Core also runs in the Flutter Web admin (Solve / Simulate / Playtest,
/// spec §15) and on mobile, so it may only use libraries that exist on both.
/// Isolates are the game's job (CLAUDE.md rule 8), not core's.
final platformNeutralImports = CoreGuard(
  'imports only platform-neutral dart: libraries (web admin + mobile)',
  (source) => _bannedUris(source, _platformUri),
);

/// Spec §6.5: dart:math `Random` may change its sequence between SDK
/// versions, which would silently change every generated and daily level.
/// Any reference counts: constructor, `Random.secure`, prefixed
/// `math.Random`, a type annotation, or `show Random`.
final noDartMathRandom = CoreGuard(
  'never uses dart:math Random (spec §6.5 — use the core PRNG)',
  (source) => [
    for (final line in codeMatches(source, RegExp(r'\bRandom\b')))
      (line, 'references Random'),
    for (final directive in directives(source))
      if (directive.uris.contains('dart:math') &&
          RegExp(r'\bshow\b[^;]*\bRandom\b').hasMatch(directive.code))
        (directive.line, 'imports Random from dart:math'),
  ],
);

/// CLAUDE.md rule 7: an unseeded generator makes the generator and simulator
/// non-reproducible. Overlaps [noDartMathRandom] on purpose, to give the
/// precise reason when this is the mistake.
final noUnseededRandom = CoreGuard(
  'never constructs an unseeded Random (CLAUDE.md rule 7)',
  (source) => [
    for (final line in codeMatches(
      source,
      RegExp(r'\bRandom\s*(\(\s*\)|\.\s*secure\b)'),
    ))
      (line, 'unseeded Random'),
  ],
);

/// CLAUDE.md rule 7: time must be passed in (e.g. the daily seed `yyyymmdd`
/// of spec §7.5 comes from the caller), never read inside core. Tear-offs
/// such as `DateTime.now` without a call are caught too.
///
/// `Stopwatch` is banned as well (.claude/rules/nesty-core.md): the spec
/// budgets solver and simulator work in nodes, not time (§6.3), so a
/// time-based cutoff would make solve and generate results depend on device
/// speed, and the daily puzzle could differ between two phones.
final noWallClock = CoreGuard(
  'never reads the clock (CLAUDE.md rule 7)',
  (source) => [
    for (final line in codeMatches(
      source,
      RegExp(r'\bDateTime\s*\.\s*(now|timestamp)\b'),
    ))
      (line, 'reads the wall clock'),
    for (final line in codeMatches(source, RegExp(r'\bStopwatch\b')))
      (line, 'reads the clock (Stopwatch)'),
  ],
);

/// Design §3 (Q9): `~x` is negative on the VM and a 32-bit unsigned value
/// in dart2js, so the same expression gives different canonical keys,
/// hashes and seeds. Use `not32` (src/util/u32.dart) or `x ^ (x & y)` for
/// `x & ~y`. Integer division `~/` is fine.
final noBitwiseNot = CoreGuard(
  'never uses the bitwise NOT operator ~ (design §3, web-safe arithmetic)',
  (source) => [
    for (final line in codeMatches(source, RegExp(r'~(?!/)')))
      (line, 'uses ~ (use not32 or x ^ (x & y))'),
  ],
);

/// Design §3 (Q9): 64-bit typed lists don't exist in dart2js (the admin),
/// which throws on them; every core value fits 32 bits.
final no64BitTypedLists = CoreGuard(
  'never uses 64-bit typed lists (design §3, web-safe arithmetic)',
  (source) => [
    for (final line in codeMatches(
      source,
      RegExp(r'\b(Int64List|Uint64List|Int64x2List)\b'),
    ))
      (line, 'uses a 64-bit typed list'),
  ],
);

/// Design §3 (Q9): `HashMap` and `HashSet` iterate in hash order, which
/// differs between platforms and SDKs, so any result built by iterating one
/// could differ between the phones and the web admin. Map and set literals
/// are insertion-ordered (`LinkedHashMap`/`LinkedHashSet`) and allowed.
final noHashCollections = CoreGuard(
  'never uses HashMap or HashSet (design §3: no hash-order iteration)',
  (source) => [
    for (final line in codeMatches(source, RegExp(r'\b(HashMap|HashSet)\b')))
      (line, 'uses a hash-ordered collection'),
  ],
);

final _flutterUri = RegExp(
  r'^(dart:ui(_web)?$|package:(flutter|flame)(_[a-z0-9_]*)?/)',
);

// dart:io, dart:isolate, dart:ffi, dart:mirrors and dart:cli do not exist on
// the web; the others do not exist on mobile or the VM.
final _platformUri = RegExp(
  r'^dart:(io|isolate|ffi|mirrors|cli|html|js|js_interop|js_interop_unsafe'
  r'|js_util|indexed_db|svg|web_audio|web_gl)$',
);

List<(int, String)> _bannedUris(ScannedSource source, RegExp banned) => [
  for (final directive in directives(source))
    for (final uri in directive.uris)
      if (banned.hasMatch(uri)) (directive.line, "uses '$uri'"),
];
