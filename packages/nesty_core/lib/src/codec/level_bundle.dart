import 'dart:convert';

import 'package:nesty_core/src/codec/level_codec.dart';
import 'package:nesty_core/src/codec/level_issue.dart';
import 'package:nesty_core/src/models/equality.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/simulator/tier.dart';

/// One level of the bundle, with the play metadata of spec §5.2 that the
/// game needs offline.
final class LevelBundleEntry {
  const LevelBundleEntry({
    required this.order,
    required this.chapterId,
    required this.tier,
    required this.version,
    required this.rewardCoins,
    required this.level,
    this.par,
  });

  /// Global play order, 1-based and continuous (spec §5.2, §7.1).
  final int order;

  /// The chapter, such as `ch01` (20 levels each, spec §7.1).
  final String chapterId;

  final Tier tier;

  /// The level document's edit version, 1 or more (spec §5.2); the
  /// in-progress save is only restored while it matches (spec §13.3).
  final int version;

  /// Coins for winning, from the tier (spec §7.3, design A27).
  final int rewardCoins;

  /// The level itself: the entry's `data` (spec §5.1).
  final Level level;

  /// The fewest moves that solve [level] from its start: the solver's
  /// optimal solution at the admin budget (spec §5.2 `metrics.solverMoves`,
  /// §6.3), written by `nesty_levels bundle build` and checked by `bundle
  /// check` (spec-prop §7.10, D125). The star rating's par
  /// (`StarRating`). Null means no stars for this entry (content without a
  /// proven par plays without them); never below 1.
  final int? par;

  @override
  bool operator ==(Object other) =>
      other is LevelBundleEntry &&
      other.order == order &&
      other.chapterId == chapterId &&
      other.tier == tier &&
      other.version == version &&
      other.rewardCoins == rewardCoins &&
      other.par == par &&
      other.level == level;

  @override
  int get hashCode =>
      Object.hash(order, chapterId, tier, version, rewardCoins, par, level);

  @override
  String toString() =>
      'LevelBundleEntry($order, ${level.id}, ${tier.id}'
      '${par == null ? '' : ', par $par'})';
}

/// The bundled levels file, `apps/game/assets/levels/bundle.json`
/// (spec §13.4, design §4): the minimum the game can play offline.
final class LevelBundle {
  /// Copies [levels] sorted by [LevelBundleEntry.order]. The sort is stable,
  /// so entries that share an order (only a bundle built in code can have
  /// them; the decoder skips them) keep the order they were given in.
  LevelBundle({
    required this.levelsVersion,
    required List<LevelBundleEntry> levels,
    this.bundleVersion = currentBundleVersion,
  }) : levels = List.unmodifiable(_byOrder(levels));

  /// The `format` marker every bundle file carries.
  static const String format = 'nesty.levels';

  /// The bundle file version this package reads and writes.
  static const int currentBundleVersion = 1;

  final int bundleVersion;

  /// The content version, compared with the remote manifest's
  /// `levelsVersion` (spec §13.4).
  final int levelsVersion;

  /// Entries sorted by [LevelBundleEntry.order].
  final List<LevelBundleEntry> levels;

  // Sorting here, not only in the encoder, keeps the `levels` promise for a
  // bundle built in code, so the game can index by position (spec §13.4
  // "build the level list by order"). Dart's List.sort isn't stable, so ties
  // fall back to the given position.
  static List<LevelBundleEntry> _byOrder(List<LevelBundleEntry> levels) {
    final indexed = [for (var i = 0; i < levels.length; i++) (i, levels[i])]
      ..sort((a, b) {
        final byOrder = a.$2.order.compareTo(b.$2.order);
        return byOrder != 0 ? byOrder : a.$1.compareTo(b.$1);
      });
    return [for (final (_, entry) in indexed) entry];
  }

  @override
  bool operator ==(Object other) =>
      other is LevelBundle &&
      other.bundleVersion == bundleVersion &&
      other.levelsVersion == levelsVersion &&
      listEquals(other.levels, levels);

  @override
  int get hashCode =>
      Object.hash(bundleVersion, levelsVersion, Object.hashAll(levels));

  @override
  String toString() =>
      'LevelBundle(v$bundleVersion, levels $levelsVersion, '
      '${levels.length} entries)';
}

/// What [LevelBundleCodec.decode] produced.
///
/// Invalid entries are skipped with issues and the rest still load, so one
/// bad level can't block the game (spec §5.3). [bundle] is null only when
/// the file itself is unusable: not JSON, not an object, a missing or wrong
/// `format`, an unsupported `bundleVersion`, or a missing or bad
/// `levelsVersion` or `levels`.
final class LevelBundleDecodeResult {
  LevelBundleDecodeResult({this.bundle, List<LevelIssue> issues = const []})
    : issues = List.unmodifiable(issues);

  final LevelBundle? bundle;

  /// Every problem, with JSON pointers into the bundle
  /// (e.g. `/levels/3/data/shelves/0/1`).
  final List<LevelIssue> issues;

  @override
  bool operator ==(Object other) =>
      other is LevelBundleDecodeResult &&
      other.bundle == bundle &&
      listEquals(other.issues, issues);

  @override
  int get hashCode => Object.hash(bundle, Object.hashAll(issues));

  @override
  String toString() => 'LevelBundleDecodeResult($bundle, $issues)';
}

/// [LevelBundle] to JSON and back (design §4).
///
/// The encoder is deterministic so the committed file never churns: 2-space
/// indent, fixed key order (`format, bundleVersion, levelsVersion, levels`;
/// per entry `order, chapterId, tier, version, rewardCoins, par, data`, with
/// `par` written only when the entry has one, so a par-less bundle encodes
/// as it did before stars), entries sorted by order, `data` in the level
/// codec's canonical form, no timestamps. It writes the bundle as given and
/// checks nothing; the level tools (`nesty_levels bundle build`) check
/// before they encode.
///
/// The decoder is strict like the level codec (design A21): unknown keys,
/// wrong types and values out of range are issues, and integers are read by
/// value (`1.0` is `1`) so the admin (browser) and the game (VM) agree. It
/// does not run the validator: the game's loader validates each level
/// itself (rules 1–7, design A6).
///
/// Decoding goes in this order, and issues come back in it:
/// 1. `format`, then `bundleVersion`. A file that fails either is not read
///    further, because its shape is unknown.
/// 2. `levelsVersion` (an integer, 0 or more), then `levels`, entry by entry.
///    Each entry needs `order` (1 or more), `chapterId` (a string), `tier` (a
///    `Tier` id, else `bundle.unknownTier`), `version` (1 or more),
///    `rewardCoins` (0 or more) and `data` (a level; its issues are reported
///    under `/levels/<i>/data`). An entry with any error is skipped.
///    `par` is optional and read leniently (spec-prop §7.10): absent is no
///    par; an integer of 1 or more by value (`2.0` is 2) is the par;
///    anything else is one *warning* (`schema.wrongType` or
///    `schema.valueOutOfRange` at `/levels/<i>/par`) and no par, and the
///    entry is kept, so a bad par never makes a level unplayable.
/// 3. Among the entries with no error, in file order, one that reuses an
///    earlier entry's order (`bundle.duplicateOrder`) or level id
///    (`bundle.duplicateId`, with the kept entry's `order`) is skipped.
/// 4. Orders must run 1, 2, 3, … with no gap: each gap is one
///    `bundle.orderGap` with the `expected` and `found` orders, at the entry
///    with the found order. Every entry whose `order` could be read counts,
///    so a skipped level doesn't also report a gap. The entries are kept.
/// 5. Unknown top-level keys.
///
/// Unknown keys (of the bundle and of each entry) are reported sorted by
/// code unit, so the order is the same on the VM and the web.
///
/// Issue args extend the level codec's: `field` may also be `bundle` (the
/// document) or `entry` (an element of `levels`).
abstract final class LevelBundleCodec {
  /// Decodes an already-parsed JSON value.
  static LevelBundleDecodeResult decode(Object? json) =>
      _BundleDecoder().decode(json);

  /// Parses [source] as JSON, then [decode]s it. Malformed JSON is reported
  /// as `schema.invalidJson`.
  static LevelBundleDecodeResult decodeString(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException catch (e) {
      // As in LevelCodec: the parser's text differs between the VM and the
      // web, so it is only in the message.
      return LevelBundleDecodeResult(
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

  /// The bundle as a JSON map in the fixed key order.
  static Map<String, Object?> encode(LevelBundle bundle) => {
    _Keys.format: LevelBundle.format,
    _Keys.bundleVersion: bundle.bundleVersion,
    _Keys.levelsVersion: bundle.levelsVersion,
    _Keys.levels: [for (final entry in bundle.levels) _entry(entry)],
  };

  /// The file's exact text: [encode] with a 2-space indent and a trailing
  /// newline.
  static String encodeString(LevelBundle bundle) =>
      '${const JsonEncoder.withIndent('  ').convert(encode(bundle))}\n';

  static Map<String, Object?> _entry(LevelBundleEntry entry) => {
    _Keys.order: entry.order,
    _Keys.chapterId: entry.chapterId,
    _Keys.tier: entry.tier.id,
    _Keys.version: entry.version,
    _Keys.rewardCoins: entry.rewardCoins,
    _Keys.par: ?entry.par,
    _Keys.data: LevelCodec.encode(entry.level),
  };
}

/// The bundle-JSON keys of design §4.
abstract final class _Keys {
  static const format = 'format';
  static const bundleVersion = 'bundleVersion';
  static const levelsVersion = 'levelsVersion';
  static const levels = 'levels';

  static const order = 'order';
  static const chapterId = 'chapterId';
  static const tier = 'tier';
  static const version = 'version';
  static const rewardCoins = 'rewardCoins';
  static const par = 'par';
  static const data = 'data';

  static const Set<String> bundle = {
    format,
    bundleVersion,
    levelsVersion,
    levels,
  };

  static const Set<String> entry = {
    order,
    chapterId,
    tier,
    version,
    rewardCoins,
    par,
    data,
  };
}

/// The `expected` arg of `schema.wrongType`, as in the level codec.
abstract final class _Expected {
  static const object = 'object';
  static const array = 'array';
  static const string = 'string';
  static const integer = 'integer';
}

// 2^53 − 1: the largest integer every platform reads exactly from JSON (the
// web's numbers are doubles), as in the level codec.
const int _maxJsonInteger = 0x1FFFFFFFFFFFFF;

/// One parsed entry: the fields that could be read, and whether any error
/// was found in it.
final class _ParsedEntry {
  _ParsedEntry(this.index, this.order, this.entry);

  final int index;

  /// The entry's `order`, when it could be read (even if the entry has
  /// other errors), for the gap check.
  final int? order;

  /// The entry, when it has no error.
  final LevelBundleEntry? entry;
}

/// One decode: collects issues while it walks the document in order.
final class _BundleDecoder {
  final List<LevelIssue> _issues = [];

  // Error issues so far, counted as they are recorded: every entry compares
  // the count before and after it, so a rescan would make decoding
  // quadratic in the number of issues.
  int _errors = 0;

  LevelBundleDecodeResult decode(Object? json) {
    if (json is! Map) {
      _wrongType(const [], 'bundle', _Expected.object);
      return _done(null);
    }

    // A file of another format or bundle version is not read further,
    // because its shape is unknown (like `schemaVersion` in the level codec).
    final format = _requiredString(json, _Keys.format, const []);
    if (format == null) return _done(null);
    if (format != LevelBundle.format) {
      _add(
        IssueCodes.bundleBadFormat,
        'Not a level bundle: format is "$format" (expected '
        '"${LevelBundle.format}")',
        const [_Keys.format],
        args: {'format': format},
      );
      return _done(null);
    }
    final bundleVersion = _requiredInt(json, _Keys.bundleVersion, const []);
    if (bundleVersion == null) return _done(null);
    if (bundleVersion != LevelBundle.currentBundleVersion) {
      _add(
        IssueCodes.bundleUnsupportedVersion,
        'bundleVersion $bundleVersion is not supported (this build reads '
        '${LevelBundle.currentBundleVersion})',
        const [_Keys.bundleVersion],
        args: {
          'version': bundleVersion,
          'supported': LevelBundle.currentBundleVersion,
        },
      );
      return _done(null);
    }

    final levelsVersion = _requiredInt(
      json,
      _Keys.levelsVersion,
      const [],
      min: 0,
    );
    final entries = _levels(json);
    _rejectUnknownKeys(json, _Keys.bundle, const []);

    if (levelsVersion == null || entries == null) return _done(null);
    return _done(LevelBundle(levelsVersion: levelsVersion, levels: entries));
  }

  LevelBundleDecodeResult _done(LevelBundle? bundle) =>
      LevelBundleDecodeResult(bundle: bundle, issues: _issues);

  int get _errorCount => _errors;

  void _record(LevelIssue issue) {
    if (issue.isError) _errors++;
    _issues.add(issue);
  }

  // --- Entries ---

  List<LevelBundleEntry>? _levels(Map<Object?, Object?> root) {
    final field = _required(root, _Keys.levels, const []);
    if (!field.present) return null;
    final list = _asList(field.value, const [_Keys.levels], _Keys.levels);
    if (list == null) return null;

    final parsed = [for (var i = 0; i < list.length; i++) _entry(list[i], i)];

    // Step 3 of the class doc: the first error-free entry to use an order or
    // an id keeps it.
    final orderTaken = <int>{};
    final idOwner = <String, int>{};
    final accepted = <LevelBundleEntry>[];
    for (final item in parsed) {
      final entry = item.entry;
      if (entry == null) continue;
      final path = <Object>[_Keys.levels, item.index];
      if (orderTaken.contains(entry.order)) {
        _add(
          IssueCodes.bundleDuplicateOrder,
          'Order ${entry.order} is already used by an earlier entry',
          [...path, _Keys.order],
          args: {'order': entry.order},
        );
        continue;
      }
      final owner = idOwner[entry.level.id];
      if (owner != null) {
        _add(
          IssueCodes.bundleDuplicateId,
          'Level id "${entry.level.id}" is already used by the entry with '
          'order $owner',
          [...path, _Keys.data, 'id'],
          args: {'id': entry.level.id, 'order': owner},
        );
        continue;
      }
      orderTaken.add(entry.order);
      idOwner[entry.level.id] = entry.order;
      accepted.add(entry);
    }

    _checkGaps(parsed);
    return accepted;
  }

  /// Step 4 of the class doc: orders run 1, 2, 3, … Each gap is reported
  /// once, at the first entry (in file order) holding the order found after
  /// it.
  void _checkGaps(List<_ParsedEntry> parsed) {
    final firstIndex = <int, int>{};
    for (final item in parsed) {
      final order = item.order;
      if (order != null) firstIndex.putIfAbsent(order, () => item.index);
    }
    final orders = firstIndex.keys.toList()..sort();
    var expected = 1;
    for (final order in orders) {
      if (order != expected) {
        _add(
          IssueCodes.bundleOrderGap,
          'Orders must be continuous from 1: expected $expected, found '
          '$order',
          [_Keys.levels, firstIndex[order]!, _Keys.order],
          args: {'expected': expected, 'found': order},
        );
      }
      expected = order + 1;
    }
  }

  _ParsedEntry _entry(Object? value, int index) {
    final path = <Object>[_Keys.levels, index];
    if (value is! Map) {
      _wrongType(path, 'entry', _Expected.object);
      return _ParsedEntry(index, null, null);
    }
    final errorsBefore = _errorCount;
    // Fields in canonical order, then unknown keys, as in the level codec.
    final order = _requiredInt(value, _Keys.order, path, min: 1);
    final chapterId = _requiredString(value, _Keys.chapterId, path);
    final tier = _tier(value, path);
    final version = _requiredInt(value, _Keys.version, path, min: 1);
    final rewardCoins = _requiredInt(value, _Keys.rewardCoins, path, min: 0);
    final par = _par(value, path);
    final level = _data(value, path);
    _rejectUnknownKeys(value, _Keys.entry, path);

    if (_errorCount != errorsBefore ||
        order == null ||
        chapterId == null ||
        tier == null ||
        version == null ||
        rewardCoins == null ||
        level == null) {
      return _ParsedEntry(index, order, null);
    }
    return _ParsedEntry(
      index,
      order,
      LevelBundleEntry(
        order: order,
        chapterId: chapterId,
        tier: tier,
        version: version,
        rewardCoins: rewardCoins,
        level: level,
        par: par,
      ),
    );
  }

  /// The entry's optional `par` (spec-prop §7.10), read leniently: absent
  /// is null with no issue; an integral number of at least 1 by value is
  /// the par; anything else is one warning and null, and never an error,
  /// so the entry is kept.
  int? _par(Map<Object?, Object?> entry, List<Object> path) {
    if (!entry.containsKey(_Keys.par)) return null;
    final value = entry[_Keys.par];
    final at = [...path, _Keys.par];
    // As _asInt: test the value, not the Dart type, so the web agrees.
    if (value is! num ||
        !value.isFinite ||
        value != value.truncateToDouble() ||
        value.abs() > _maxJsonInteger) {
      _add(
        IssueCodes.wrongType,
        '"${_Keys.par}" must be ${_article(_Expected.integer)}; the level '
        'plays without stars',
        at,
        args: {'field': _Keys.par, 'expected': _Expected.integer},
        severity: IssueSeverity.warning,
      );
      return null;
    }
    final par = value.toInt();
    if (par >= 1) return par;
    _add(
      IssueCodes.valueOutOfRange,
      '"${_Keys.par}" must be 1 or more (got $par); the level plays without '
      'stars',
      at,
      args: {
        'field': _Keys.par,
        'value': par,
        'min': 1,
        'max': _maxJsonInteger,
      },
      severity: IssueSeverity.warning,
    );
    return null;
  }

  Tier? _tier(Map<Object?, Object?> entry, List<Object> path) {
    final id = _requiredString(entry, _Keys.tier, path);
    if (id == null) return null;
    final tier = Tier.tryFromId(id);
    if (tier == null) {
      _add(
        IssueCodes.bundleUnknownTier,
        'Unknown tier "$id" (expected one of '
        '${Tier.values.map((t) => t.id).join(', ')})',
        [...path, _Keys.tier],
        args: {'tier': id},
      );
    }
    return tier;
  }

  /// The entry's level, decoded by the one level codec; its issues are
  /// re-rooted under the entry's `data`.
  Level? _data(Map<Object?, Object?> entry, List<Object> path) {
    final field = _required(entry, _Keys.data, path);
    if (!field.present) return null;
    final decoded = LevelCodec.decode(field.value);
    final prefix = LevelIssue.pointer([...path, _Keys.data]);
    for (final issue in decoded.issues) {
      _record(
        LevelIssue(
          code: issue.code,
          message: issue.message,
          severity: issue.severity,
          path: '$prefix${issue.path}',
          slotId: issue.slotId,
          args: issue.args,
        ),
      );
    }
    return decoded.level;
  }

  // --- Fields and JSON types ---

  ({bool present, Object? value}) _required(
    Map<Object?, Object?> map,
    String key,
    List<Object> parentPath,
  ) {
    if (map.containsKey(key)) return (present: true, value: map[key]);
    _add(
      IssueCodes.missingField,
      'Missing "$key"',
      parentPath,
      args: {'field': key},
    );
    return (present: false, value: null);
  }

  String? _requiredString(
    Map<Object?, Object?> map,
    String key,
    List<Object> parentPath,
  ) {
    final field = _required(map, key, parentPath);
    if (!field.present) return null;
    final value = field.value;
    if (value is String) return value;
    _wrongType([...parentPath, key], key, _Expected.string);
    return null;
  }

  /// A required integer of at least [min]; `schema.valueOutOfRange` below.
  int? _requiredInt(
    Map<Object?, Object?> map,
    String key,
    List<Object> parentPath, {
    int? min,
  }) {
    final field = _required(map, key, parentPath);
    if (!field.present) return null;
    final path = [...parentPath, key];
    final value = _asInt(field.value, path, key);
    if (value == null || min == null || value >= min) return value;
    _add(
      IssueCodes.valueOutOfRange,
      '"$key" must be $min or more (got $value)',
      path,
      args: {'field': key, 'value': value, 'min': min, 'max': _maxJsonInteger},
    );
    return null;
  }

  /// Reports every key of [map] outside [allowed], sorted by code unit so
  /// the order is the same on the VM and the web (see the level codec).
  void _rejectUnknownKeys(
    Map<Object?, Object?> map,
    Set<String> allowed,
    List<Object> path,
  ) {
    final unknown = [
      for (final key in map.keys)
        if (key is! String || !allowed.contains(key)) '$key',
    ]..sort();
    for (final name in unknown) {
      _add(
        IssueCodes.unknownField,
        'Unknown field "$name"',
        [...path, name],
        args: {'field': name},
      );
    }
  }

  List<Object?>? _asList(Object? value, List<Object> path, String field) {
    if (value is List) return value;
    _wrongType(path, field, _Expected.array);
    return null;
  }

  /// An integral JSON number within ±(2^53 − 1), else `schema.wrongType`.
  int? _asInt(Object? value, List<Object> path, String field) {
    // On the web `3.0 is int` is true and every number is also a double, so
    // test the value, not the Dart type, to agree across platforms.
    if (value is num &&
        value.isFinite &&
        value == value.truncateToDouble() &&
        value.abs() <= _maxJsonInteger) {
      return value.toInt();
    }
    _wrongType(path, field, _Expected.integer);
    return null;
  }

  void _wrongType(List<Object> path, String field, String expected) {
    _add(
      IssueCodes.wrongType,
      '"$field" must be ${_article(expected)}',
      path,
      args: {'field': field, 'expected': expected},
    );
  }

  static String _article(String expected) => switch (expected) {
    _Expected.object => 'an object',
    _Expected.array => 'an array',
    _Expected.integer => 'an integer (a whole number up to 2^53 − 1)',
    _ => 'a $expected',
  };

  void _add(
    String code,
    String message,
    List<Object> path, {
    Map<String, Object> args = const {},
    IssueSeverity severity = IssueSeverity.error,
  }) {
    _record(
      LevelIssue(
        code: code,
        message: message,
        severity: severity,
        path: LevelIssue.pointer(path),
        args: args,
      ),
    );
  }
}
