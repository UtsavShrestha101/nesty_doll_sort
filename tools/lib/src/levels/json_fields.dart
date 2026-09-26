import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/finding.dart';

// 2^53 − 1: the largest integer every platform reads exactly from JSON, the
// core codecs' limit too.
const int _maxJsonInteger = 0x1FFFFFFFFFFFFF;

/// Strict reading of the tools' own JSON inputs (the manifest, generator
/// params), in the style of the core codecs: unknown keys, wrong types and
/// values out of range are findings with a JSON pointer, collected rather
/// than thrown, so an author sees every problem at once.
///
/// Codes are `<codePrefix>.wrongType`, `.missingField`, `.unknownField` and
/// `.valueOutOfRange`.
final class JsonFields {
  JsonFields({required this.subject, required this.codePrefix});

  /// The file (or option) being read, for [Finding.subject].
  final String subject;

  /// `manifest` or `params`.
  final String codePrefix;

  final List<Finding> findings = [];

  int get errorCount => findings.where((f) => f.isError).length;

  void add(String code, String message, List<Object> path) => findings.add(
    Finding(code, message, subject: subject, path: LevelIssue.pointer(path)),
  );

  Map<Object?, Object?>? object(Object? value, List<Object> path, String what) {
    if (value is Map) return value;
    _wrongType(path, what, 'an object');
    return null;
  }

  List<Object?>? array(Object? value, List<Object> path, String what) {
    if (value is List) return value;
    _wrongType(path, what, 'an array');
    return null;
  }

  ({bool present, Object? value}) required(
    Map<Object?, Object?> map,
    String key,
    List<Object> parentPath,
  ) {
    if (map.containsKey(key)) return (present: true, value: map[key]);
    add('$codePrefix.missingField', 'Missing "$key"', parentPath);
    return (present: false, value: null);
  }

  /// A string field; [optional] ones may be absent (null result, no
  /// finding). [nonEmpty] rejects `""` and whitespace-only text with
  /// [emptyCode].
  String? string(
    Map<Object?, Object?> map,
    String key,
    List<Object> parentPath, {
    bool optional = false,
    bool nonEmpty = false,
    String? emptyCode,
  }) {
    if (optional && !map.containsKey(key)) return null;
    final field = required(map, key, parentPath);
    if (!field.present) return null;
    final path = [...parentPath, key];
    final value = field.value;
    if (value is! String) {
      _wrongType(path, key, 'a string');
      return null;
    }
    if (nonEmpty && value.trim().isEmpty) {
      add(
        emptyCode ?? '$codePrefix.wrongType',
        '"$key" must not be empty',
        path,
      );
      return null;
    }
    return value;
  }

  /// An integer field in [[min], [max]] (either bound optional). Integers are
  /// read by value, as in the core codecs: `3.0` is `3`.
  int? integer(
    Map<Object?, Object?> map,
    String key,
    List<Object> parentPath, {
    bool optional = false,
    int? min,
    int? max,
  }) {
    if (optional && !map.containsKey(key)) return null;
    final field = required(map, key, parentPath);
    if (!field.present) return null;
    final path = [...parentPath, key];
    final value = field.value;
    if (value is! num ||
        !value.isFinite ||
        value != value.truncateToDouble() ||
        value.abs() > _maxJsonInteger) {
      _wrongType(path, key, 'an integer');
      return null;
    }
    final number = value.toInt();
    if ((min != null && number < min) || (max != null && number > max)) {
      final range = max == null
          ? '$min or more'
          : min == null
          ? '$max or less'
          : '$min–$max';
      add(
        '$codePrefix.valueOutOfRange',
        '"$key" must be $range (got $number)',
        path,
      );
      return null;
    }
    return number;
  }

  void rejectUnknown(
    Map<Object?, Object?> map,
    Set<String> allowed,
    List<Object> path,
  ) {
    for (final key in map.keys) {
      if (key is String && allowed.contains(key)) continue;
      add(
        '$codePrefix.unknownField',
        'Unknown field "$key" (allowed: ${allowed.join(', ')})',
        [...path, '$key'],
      );
    }
  }

  void _wrongType(List<Object> path, String what, String expected) =>
      add('$codePrefix.wrongType', '"$what" must be $expected', path);
}
