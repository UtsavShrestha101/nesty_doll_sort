import 'dart:convert';

import 'package:nesty_core/src/codec/json_values.dart';
import 'package:nesty_core/src/codec/level_issue.dart';
import 'package:nesty_core/src/models/doll.dart';
import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/models/equality.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/models/nest.dart';
import 'package:nesty_core/src/models/slot.dart';
import 'package:nesty_core/src/models/slot_id.dart';

/// What [LevelCodec.decode] produced: a [level] when the input is a
/// well-formed schema-v1 level, and every [issues] found.
///
/// The codec checks what a [Level] can't represent: the schema (types,
/// required and unknown keys, the schema version), the doll tokens, invalid
/// nests (§2.1), empty towers and negative ice. Everything a `Level` can hold
/// is the `Validator`'s job, including the §5.3 rules, the id length, the
/// seed range, doll sizes above `maxSize` and gold (owner override D22), so
/// a level built in code is checked exactly like one read from JSON.
final class LevelDecodeResult {
  LevelDecodeResult({this.level, List<LevelIssue> issues = const []})
    : issues = List.unmodifiable(issues);

  /// The decoded level. Null exactly when [issues] contains an error.
  final Level? level;

  final List<LevelIssue> issues;

  /// True when a level was decoded.
  bool get isOk => level != null;

  @override
  bool operator ==(Object other) =>
      other is LevelDecodeResult &&
      other.level == level &&
      listEquals(other.issues, issues);

  @override
  int get hashCode => Object.hash(level, Object.hashAll(issues));

  @override
  String toString() => 'LevelDecodeResult(${level?.id}, $issues)';
}

/// Level JSON (spec §5.1) to [Level] and back.
///
/// Strict (design A21): tokens must match `^([a-z]+)([1-6])$`, unknown keys
/// are rejected, `"nest"` is required on open and locked slots with `null`
/// for an empty slot, and `ice` may be omitted (it is written only when above
/// 0). Issues are collected, not fail-fast, each with a JSON pointer into the
/// input and ARB-ready args (see [IssueCodes]). A document with another
/// `schemaVersion` is not read further, because its shape is unknown.
///
/// Issue order is the same on every platform: document order, and inside
/// the level and each slot the known fields in canonical order, then the
/// unknown keys sorted by code unit (JSON object key order is not portable:
/// the web lists integer-like keys first).
///
/// Integers: any JSON number with an integral value in ±(2^53 − 1) is read
/// as an int, so `3` and `3.0` decode alike. On the web every JSON number is
/// a double, so this is the only rule that gives the same answer in the
/// admin (browser) and the game (VM, AOT).
///
/// [encode] writes the canonical key order `schemaVersion, id, maxSize,
/// shelves[, generatorVersion, seed]` and, per slot, `type, unlockColor,
/// nest|stack, ice` (design A20), so `jsonEncode(encode(level))` is a stable
/// byte string (the generator's golden hashes rely on it). For every level,
/// `decode(encode(level)).level == level`.
///
/// Issue args: `field` names the offending value: a key of the level or of
/// a slot, or `level`, `shelf`, `slot`, `nest` (an element of `stack`) or
/// `doll` (a token) for unnamed values. `expected` is one of `object`,
/// `array`, `arrayOrNull`, `string` or `integer`.
abstract final class LevelCodec {
  /// Decodes an already-parsed JSON value (a `Map` for a valid level).
  static LevelDecodeResult decode(Object? json) => _LevelDecoder().decode(json);

  /// Parses [source] as JSON, then [decode]s it. Malformed JSON is reported
  /// as `schema.invalidJson`.
  static LevelDecodeResult decodeString(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException catch (e) {
      // The parser's text differs between the VM and the web (dart2js wraps
      // JSON.parse), so it stays in the message and is not an ARB arg.
      return LevelDecodeResult(
        issues: [
          LevelIssue(
            code: IssueCodes.invalidJson,
            message: 'Not valid JSON: ${e.message}',
          ),
        ],
      );
    }
    return decode(json);
  }

  /// The level as a JSON map in canonical key order.
  static Map<String, Object?> encode(Level level) => {
    _Keys.schemaVersion: level.schemaVersion,
    _Keys.id: level.id,
    _Keys.maxSize: level.maxSize,
    _Keys.shelves: [
      for (final shelf in level.shelves)
        [for (final slot in shelf) _slot(slot)],
    ],
    // Design A20: written only for a generated level.
    _Keys.generatorVersion: ?level.generatorVersion,
    _Keys.seed: ?level.seed,
  };

  /// [encode] as a string: compact when [indent] is null (identical to
  /// `jsonEncode(encode(level))`), else pretty-printed with [indent].
  static String encodeString(Level level, {String? indent}) {
    final json = encode(level);
    return indent == null
        ? jsonEncode(json)
        : JsonEncoder.withIndent(indent).convert(json);
  }

  static Map<String, Object?> _slot(Slot slot) => switch (slot) {
    OpenSlot(:final nest) => {
      _Keys.type: _Keys.open,
      _Keys.nest: _nest(nest),
      if (slot.ice > 0) _Keys.ice: slot.ice,
    },
    TowerSlot(:final stack) => {
      _Keys.type: _Keys.tower,
      _Keys.stack: [for (final nest in stack) _nest(nest)],
      if (slot.ice > 0) _Keys.ice: slot.ice,
    },
    LockedSlot(:final unlockColor, :final nest) => {
      _Keys.type: _Keys.locked,
      _Keys.unlockColor: unlockColor.id,
      _Keys.nest: _nest(nest),
      if (slot.ice > 0) _Keys.ice: slot.ice,
    },
  };

  // Spec §5.1: a nest is its dolls' tokens, outer to inner.
  static List<String>? _nest(Nest? nest) =>
      nest == null ? null : [for (final doll in nest.dolls) doll.token];
}

/// The level-JSON keys and slot type names of spec §5.1.
abstract final class _Keys {
  static const schemaVersion = 'schemaVersion';
  static const id = 'id';
  static const maxSize = 'maxSize';
  static const shelves = 'shelves';
  static const generatorVersion = 'generatorVersion';
  static const seed = 'seed';

  static const type = 'type';
  static const unlockColor = 'unlockColor';
  static const nest = 'nest';
  static const stack = 'stack';
  static const ice = 'ice';

  static const open = 'open';
  static const tower = 'tower';
  static const locked = 'locked';

  static const Set<String> level = {
    schemaVersion,
    id,
    maxSize,
    shelves,
    generatorVersion,
    seed,
  };

  static const Set<String> openSlot = {type, nest, ice};
  static const Set<String> towerSlot = {type, stack, ice};
  static const Set<String> lockedSlot = {type, unlockColor, nest, ice};
}

/// The `expected` arg of `schema.wrongType`.
abstract final class _Expected {
  static const object = 'object';
  static const array = 'array';
  static const arrayOrNull = 'arrayOrNull';
  static const string = 'string';
  static const integer = 'integer';
}

/// One decode: collects issues while it walks the document in order.
final class _LevelDecoder {
  final List<LevelIssue> _issues = [];

  // Error issues so far, counted as they are added: a slot compares the
  // count before and after it, so a rescan would make decoding quadratic in
  // the number of issues (a corrupt 1 MB document would stall the isolate).
  int _errors = 0;

  LevelDecodeResult decode(Object? json) {
    final root = _asMap(json, const [], 'level');
    if (root == null) return _done(null);

    // §5.3 rule 1: a document of another schema version is not read
    // further, because its shape is unknown. A missing or mistyped version
    // is reported and the rest is read as v1, so the author sees everything.
    final version = _required(root, _Keys.schemaVersion, const []);
    if (version.present) {
      final number = _asInt(version.value, const [_Keys.schemaVersion]);
      if (number != null && number != Level.currentSchemaVersion) {
        _add(
          IssueCodes.unsupportedVersion,
          'schemaVersion $number is not supported (this build reads '
          '${Level.currentSchemaVersion})',
          const [_Keys.schemaVersion],
          args: {'version': number, 'supported': Level.currentSchemaVersion},
        );
        return _done(null);
      }
    }

    final id = _requiredString(root, _Keys.id);
    final maxSize = _requiredInt(root, _Keys.maxSize);
    final shelves = _shelves(root);
    final generatorVersion = _optionalInt(root, _Keys.generatorVersion);
    final seed = _optionalInt(root, _Keys.seed);
    _rejectUnknownKeys(root, _Keys.level, const []);

    if (_hasError || id == null || maxSize == null || shelves == null) {
      return _done(null);
    }
    return _done(
      Level(
        id: id,
        maxSize: maxSize,
        shelves: shelves,
        generatorVersion: generatorVersion,
        seed: seed,
      ),
    );
  }

  bool get _hasError => _errors > 0;

  LevelDecodeResult _done(Level? level) =>
      LevelDecodeResult(level: _hasError ? null : level, issues: _issues);

  // --- Shelves and slots ---

  List<List<Slot>>? _shelves(Map<Object?, Object?> root) {
    const path = [_Keys.shelves];
    final field = _required(root, _Keys.shelves, const []);
    if (!field.present) return null;
    final shelves = _asList(field.value, path, _Keys.shelves);
    if (shelves == null) return null;
    final result = <List<Slot>>[];
    var ok = true;
    for (var row = 0; row < shelves.length; row++) {
      final shelf = _asList(shelves[row], [...path, row], 'shelf');
      if (shelf == null) {
        ok = false;
        continue;
      }
      final slots = <Slot>[];
      for (var col = 0; col < shelf.length; col++) {
        final slot = _slot(shelf[col], row, col);
        if (slot == null) {
          ok = false;
        } else {
          slots.add(slot);
        }
      }
      result.add(slots);
    }
    return ok ? result : null;
  }

  Slot? _slot(Object? value, int row, int col) {
    final path = <Object>[_Keys.shelves, row, col];
    final slotId = SlotId.grid(row, col);
    final slot = _asMap(value, path, 'slot', slotId: slotId);
    if (slot == null) return null;

    final typeField = _required(slot, _Keys.type, path, slotId: slotId);
    if (!typeField.present) return null;
    final type = _asString(
      typeField.value,
      [...path, _Keys.type],
      _Keys.type,
      slotId: slotId,
    );
    if (type == null) return null;

    // Fields in canonical order, then unknown keys, as for the level.
    final errorsBefore = _errorCount;
    final Slot? result;
    switch (type) {
      case _Keys.open:
        final nest = _slotNest(slot, path, slotId);
        final ice = _ice(slot, path, slotId);
        _rejectUnknownKeys(slot, _Keys.openSlot, path, slotId: slotId);
        result = nest.ok && ice != null
            ? OpenSlot(nest: nest.nest, ice: ice)
            : null;
      case _Keys.tower:
        final stack = _stack(slot, path, slotId);
        final ice = _ice(slot, path, slotId);
        _rejectUnknownKeys(slot, _Keys.towerSlot, path, slotId: slotId);
        result = stack != null && ice != null
            ? TowerSlot(stack, ice: ice)
            : null;
      case _Keys.locked:
        final unlockColor = _unlockColor(slot, path, slotId);
        final nest = _slotNest(slot, path, slotId);
        final ice = _ice(slot, path, slotId);
        _rejectUnknownKeys(slot, _Keys.lockedSlot, path, slotId: slotId);
        result = unlockColor != null && nest.ok && ice != null
            ? LockedSlot(unlockColor: unlockColor, nest: nest.nest, ice: ice)
            : null;
      default:
        // Which keys are allowed depends on the type, so the rest of the
        // slot isn't checked.
        _add(
          IssueCodes.unknownSlotType,
          'Unknown slot type "$type" (expected open, tower or locked)',
          [...path, _Keys.type],
          slotId: slotId,
          args: {'type': type},
        );
        return null;
    }
    return _errorCount == errorsBefore ? result : null;
  }

  int get _errorCount => _errors;

  /// The `nest` of an open or locked slot: required, `null` when empty.
  ({bool ok, Nest? nest}) _slotNest(
    Map<Object?, Object?> slot,
    List<Object> path,
    String slotId,
  ) {
    final field = _required(slot, _Keys.nest, path, slotId: slotId);
    if (!field.present) return (ok: false, nest: null);
    if (field.value == null) return (ok: true, nest: null);
    final nest = _nest(
      field.value,
      [...path, _Keys.nest],
      _Keys.nest,
      _Expected.arrayOrNull,
      slotId,
    );
    return (ok: nest != null, nest: nest);
  }

  /// Spec §3.2, §5.3 rule 5: a tower's stack, bottom to top, never empty at
  /// the start. Depth above 4 is representable, so the validator reports it.
  List<Nest>? _stack(
    Map<Object?, Object?> slot,
    List<Object> path,
    String slotId,
  ) {
    final field = _required(slot, _Keys.stack, path, slotId: slotId);
    if (!field.present) return null;
    final stackPath = [...path, _Keys.stack];
    final stack = _asList(field.value, stackPath, _Keys.stack, slotId: slotId);
    if (stack == null) return null;
    if (stack.isEmpty) {
      _add(
        IssueCodes.towerEmptyAtStart,
        'A tower must hold at least one nest at the start',
        stackPath,
        slotId: slotId,
      );
      return null;
    }
    final nests = <Nest>[];
    var ok = true;
    for (var i = 0; i < stack.length; i++) {
      final nest = _nest(
        stack[i],
        [...stackPath, i],
        _Keys.nest,
        _Expected.array,
        slotId,
      );
      if (nest == null) {
        ok = false;
      } else {
        nests.add(nest);
      }
    }
    return ok ? nests : null;
  }

  DollColor? _unlockColor(
    Map<Object?, Object?> slot,
    List<Object> path,
    String slotId,
  ) {
    final field = _required(slot, _Keys.unlockColor, path, slotId: slotId);
    if (!field.present) return null;
    final colorPath = [...path, _Keys.unlockColor];
    final id = _asString(
      field.value,
      colorPath,
      _Keys.unlockColor,
      slotId: slotId,
    );
    if (id == null) return null;
    final color = JsonValues.colorsById[id];
    if (color == null) {
      _add(
        IssueCodes.unknownDollColor,
        'Unknown color "$id"',
        colorPath,
        slotId: slotId,
        args: {'token': id, 'color': id},
      );
    }
    return color;
  }

  /// Spec §3.4: the ice counter, 0 when omitted. Null after an issue.
  int? _ice(Map<Object?, Object?> slot, List<Object> path, String slotId) {
    if (!slot.containsKey(_Keys.ice)) return 0;
    final icePath = [...path, _Keys.ice];
    final ice = _asInt(slot[_Keys.ice], icePath, slotId: slotId);
    if (ice == null) return null;
    if (ice < 0) {
      _add(
        IssueCodes.negativeIce,
        'Ice must be 0 or more (got $ice)',
        icePath,
        slotId: slotId,
        args: {'ice': ice},
      );
      return null;
    }
    return ice;
  }

  // --- Nests and dolls (spec §2.1, §5.1) ---

  /// A nest written as tokens, outer to inner. Every token is checked before
  /// the nest itself, so each bad token is reported once.
  Nest? _nest(
    Object? value,
    List<Object> path,
    String field,
    String expected,
    String slotId,
  ) {
    final tokens = _asList(
      value,
      path,
      field,
      expected: expected,
      slotId: slotId,
    );
    if (tokens == null) return null;
    if (tokens.isEmpty) {
      _add(
        IssueCodes.emptyNest,
        'A nest must hold at least one doll',
        path,
        slotId: slotId,
      );
      return null;
    }
    final dolls = <Doll>[];
    for (var i = 0; i < tokens.length; i++) {
      final doll = _doll(tokens[i], [...path, i], slotId);
      if (doll != null) dolls.add(doll);
    }
    if (dolls.length != tokens.length) return null;

    final written = dolls.map((doll) => doll.token).join(', ');
    final gold = dolls.where((doll) => doll.color == DollColor.gold);
    final colors = dolls.map((doll) => doll.color).toSet();
    if (colors.length > 1 && gold.isNotEmpty) {
      // Spec §3.5: a nest with gold takes the color of its other dolls. That
      // rule is v1.1 (D22) and such a nest isn't representable before it, so
      // it is reported as unsupported gold, not as mixed colors.
      _add(
        IssueCodes.goldNotSupported,
        'Gold dolls are not supported yet ([$written])',
        path,
        slotId: slotId,
        args: {'token': gold.first.token},
      );
      return null;
    }
    if (colors.length > 1) {
      _add(
        IssueCodes.mixedColors,
        'A nest must be one color ([$written])',
        path,
        slotId: slotId,
        args: {'tokens': written},
      );
      return null;
    }
    final nest = Nest.tryFromDolls(dolls);
    if (nest == null) {
      _add(
        IssueCodes.notConsecutive,
        'Sizes must be consecutive and decreasing ([$written])',
        path,
        slotId: slotId,
        args: {'tokens': written},
      );
    }
    return nest;
  }

  Doll? _doll(Object? value, List<Object> path, String slotId) {
    final token = _asString(value, path, 'doll', slotId: slotId);
    if (token == null) return null;
    final match = JsonValues.dollToken.firstMatch(token);
    if (match == null) {
      _add(
        IssueCodes.badDollToken,
        'Bad doll token "$token" (expected a color and a size 1–6, '
        'such as red4)',
        path,
        slotId: slotId,
        args: {'token': token},
      );
      return null;
    }
    final colorId = match.group(1)!;
    final color = JsonValues.colorsById[colorId];
    if (color == null) {
      _add(
        IssueCodes.unknownDollColor,
        'Unknown color "$colorId" in "$token"',
        path,
        slotId: slotId,
        args: {'token': token, 'color': colorId},
      );
      return null;
    }
    return Doll(color, int.parse(match.group(2)!));
  }

  // --- Fields and JSON types ---

  ({bool present, Object? value}) _required(
    Map<Object?, Object?> map,
    String key,
    List<Object> parentPath, {
    String? slotId,
  }) {
    if (map.containsKey(key)) return (present: true, value: map[key]);
    _add(
      IssueCodes.missingField,
      'Missing "$key"',
      parentPath,
      slotId: slotId,
      args: {'field': key},
    );
    return (present: false, value: null);
  }

  String? _requiredString(Map<Object?, Object?> root, String key) {
    final field = _required(root, key, const []);
    return field.present ? _asString(field.value, [key], key) : null;
  }

  int? _requiredInt(Map<Object?, Object?> root, String key) {
    final field = _required(root, key, const []);
    return field.present ? _asInt(field.value, [key]) : null;
  }

  int? _optionalInt(Map<Object?, Object?> root, String key) =>
      root.containsKey(key) ? _asInt(root[key], [key]) : null;

  /// Reports every key of [map] outside [allowed], sorted by code unit.
  /// Not in document order: on the web `jsonDecode` wraps `JSON.parse`,
  /// whose objects list integer-like keys first, so only a sorted order is
  /// the same on the VM, dart2js and wasm.
  void _rejectUnknownKeys(
    Map<Object?, Object?> map,
    Set<String> allowed,
    List<Object> path, {
    String? slotId,
  }) {
    final unknown = [
      for (final key in map.keys)
        if (key is! String || !allowed.contains(key)) '$key',
    ]..sort();
    for (final name in unknown) {
      _add(
        IssueCodes.unknownField,
        'Unknown field "$name"',
        [...path, name],
        slotId: slotId,
        args: {'field': name},
      );
    }
  }

  Map<Object?, Object?>? _asMap(
    Object? value,
    List<Object> path,
    String field, {
    String? slotId,
  }) {
    if (value is Map) return value;
    _wrongType(path, field, _Expected.object, slotId);
    return null;
  }

  List<Object?>? _asList(
    Object? value,
    List<Object> path,
    String field, {
    String expected = _Expected.array,
    String? slotId,
  }) {
    if (value is List) return value;
    _wrongType(path, field, expected, slotId);
    return null;
  }

  String? _asString(
    Object? value,
    List<Object> path,
    String field, {
    String? slotId,
  }) {
    if (value is String) return value;
    _wrongType(path, field, _Expected.string, slotId);
    return null;
  }

  /// An integral JSON number within ±(2^53 − 1), else `schema.wrongType`.
  /// The field name is the last path segment.
  int? _asInt(Object? value, List<Object> path, {String? slotId}) {
    final number = JsonValues.integer(value);
    if (number == null) {
      _wrongType(path, '${path.last}', _Expected.integer, slotId);
    }
    return number;
  }

  void _wrongType(
    List<Object> path,
    String field,
    String expected,
    String? slotId,
  ) {
    _add(
      IssueCodes.wrongType,
      '"$field" must be ${_article(expected)}',
      path,
      slotId: slotId,
      args: {'field': field, 'expected': expected},
    );
  }

  static String _article(String expected) => switch (expected) {
    _Expected.object => 'an object',
    _Expected.array => 'an array',
    _Expected.arrayOrNull => 'an array or null',
    _Expected.integer => 'an integer (a whole number up to 2^53 − 1)',
    _ => 'a $expected',
  };

  void _add(
    String code,
    String message,
    List<Object> path, {
    String? slotId,
    Map<String, Object> args = const {},
  }) {
    final issue = LevelIssue(
      code: code,
      message: message,
      path: LevelIssue.pointer(path),
      slotId: slotId,
      args: args,
    );
    if (issue.isError) _errors++;
    _issues.add(issue);
  }
}
