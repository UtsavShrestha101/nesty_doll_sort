/// A token value had an unexpected shape. The codegen fails with this
/// instead of guessing, so a design change is noticed.
final class TokenFormatException implements Exception {
  TokenFormatException(this.path, this.message);

  final String path;
  final String message;

  @override
  String toString() => 'tokens.json `$path`: $message';
}

/// How the generated code accounts for one tokens.json leaf.
sealed class LeafUse {
  const LeafUse();
}

/// The leaf became (part of) these generated constants, e.g.
/// `AppColorTokens.background`.
final class EmittedAs extends LeafUse {
  EmittedAs(this.symbols);
  final Set<String> symbols;
}

/// The leaf is prose (or intentionally hand-written elsewhere) and is kept
/// as documentation only; [reason] says why.
final class DocumentedOnly extends LeafUse {
  const DocumentedOnly(this.reason);
  final String reason;
}

/// Typed, path-based access to the decoded tokens.json that records which
/// leaves were used. A *leaf* is any value that is not a JSON object
/// (numbers, strings, booleans and whole lists).
///
/// After codegen, [unaccounted] must be empty: every leaf was either emitted
/// or explicitly documented. That is the parity guarantee: a token added to
/// tokens.json without codegen support fails the build.
final class TokenReader {
  TokenReader(this.root);

  final Map<String, Object?> root;

  final Map<String, LeafUse> _uses = {};

  /// Every leaf path and how it is used (for tests and diagnostics).
  Map<String, LeafUse> get uses => Map.unmodifiable(_uses);

  Object? _raw(String path) {
    Object? node = root;
    for (final key in path.split('.')) {
      if (node is! Map<String, Object?> || !node.containsKey(key)) {
        throw TokenFormatException(path, 'missing');
      }
      node = node[key];
    }
    return node;
  }

  /// The raw value at [path] without recording a use, for cross-checks
  /// between sections (the leaf must still be accounted for elsewhere).
  Object? peek(String path) => _raw(path);

  /// True when [path] exists.
  bool has(String path) {
    try {
      _raw(path);
      return true;
    } on TokenFormatException {
      return false;
    }
  }

  /// The keys of the object at [path], in file order.
  List<String> keys(String path) {
    final node = path.isEmpty ? root : _raw(path);
    if (node is! Map<String, Object?>) {
      throw TokenFormatException(path, 'expected an object, got $node');
    }
    return node.keys.toList();
  }

  T _leaf<T>(String path, String expected, String symbol) {
    final node = _raw(path);
    if (node is Map) {
      throw TokenFormatException(path, 'expected $expected, got an object');
    }
    if (node is! T) {
      throw TokenFormatException(path, 'expected $expected, got "$node"');
    }
    _emit(path, symbol);
    return node;
  }

  void _emit(String path, String symbol) {
    final use = _uses[path];
    if (use is DocumentedOnly) {
      throw StateError('`$path` is both documented and emitted');
    }
    final emitted = use is EmittedAs ? use : EmittedAs({});
    _uses[path] = emitted;
    emitted.symbols.add(symbol);
  }

  /// A number, recorded as emitted into [symbol].
  num number(String path, {required String symbol}) =>
      _leaf<num>(path, 'a number', symbol);

  /// An integer, recorded as emitted into [symbol].
  int integer(String path, {required String symbol}) {
    final n = number(path, symbol: symbol);
    if (n is! int) throw TokenFormatException(path, 'expected an integer');
    return n;
  }

  /// A string, recorded as emitted into [symbol].
  String string(String path, {required String symbol}) =>
      _leaf<String>(path, 'a string', symbol);

  /// A boolean, recorded as emitted into [symbol].
  bool boolean(String path, {required String symbol}) =>
      _leaf<bool>(path, 'a boolean', symbol);

  /// A list, recorded as emitted into [symbol].
  List<Object?> list(String path, {required String symbol}) =>
      _leaf<List<Object?>>(path, 'a list', symbol);

  /// A list of numbers of exactly [length] (when given).
  List<num> numbers(String path, {required String symbol, int? length}) {
    final values = list(path, symbol: symbol);
    if (length != null && values.length != length) {
      throw TokenFormatException(path, 'expected $length numbers');
    }
    if (!values.every((v) => v is num)) {
      throw TokenFormatException(path, 'expected numbers only');
    }
    return values.cast<num>();
  }

  /// A list of strings.
  List<String> strings(String path, {required String symbol}) {
    final values = list(path, symbol: symbol);
    if (!values.every((v) => v is String)) {
      throw TokenFormatException(path, 'expected strings only');
    }
    return values.cast<String>();
  }

  /// A prose leaf that becomes documentation only; returns its text.
  String documented(String path, {required String reason}) {
    final node = _raw(path);
    if (node is Map) throw TokenFormatException(path, 'expected a leaf');
    if (_uses[path] is EmittedAs) {
      throw StateError('`$path` is both emitted and documented');
    }
    _uses[path] = DocumentedOnly(reason);
    return '$node';
  }

  /// A prose leaf kept as documentation whose exact wording hand-written
  /// code follows (a formula, a rule of placement): any other text fails
  /// the codegen, so a design change is re-read before the code is trusted.
  String documentedExact(
    String path,
    String expected, {
    required String reason,
  }) {
    final text = documented(path, reason: reason);
    if (text != expected) {
      throw TokenFormatException(
        path,
        'the wording changed ("$text"); re-read it, update the hand-written '
        'code ($reason) and the expected text in tools/lib/src/tokens/',
      );
    }
    return text;
  }

  /// Marks every leaf under [path] as documented only (e.g. `haptics`,
  /// whose patterns are hand-written code).
  void documentedTree(String path, {required String reason}) {
    for (final leaf in leafPaths(_raw(path), path)) {
      documented(leaf, reason: reason);
    }
  }

  /// Leaves that were neither emitted nor documented.
  List<String> get unaccounted => [
    for (final leaf in leafPaths(root, ''))
      if (!_uses.containsKey(leaf)) leaf,
  ];
}

/// Every leaf path under [node] (dotted, in file order).
List<String> leafPaths(Object? node, String prefix) {
  if (node is! Map<String, Object?>) return [prefix];
  return [
    for (final entry in node.entries)
      ...leafPaths(
        entry.value,
        prefix.isEmpty ? entry.key : '$prefix.${entry.key}',
      ),
  ];
}
