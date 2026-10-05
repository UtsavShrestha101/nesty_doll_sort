import 'package:intl/intl.dart';

/// A pure-Dart reader of the ICU subset gen-l10n accepts with
/// `use-escaping` off (`apps/game/l10n.yaml`): literal text (apostrophes
/// are literal), `{name}` placeholders, and `{name, plural, …}` /
/// `{name, select, …}` with nested messages (docs: build/m7-p5/p5/l10n.md
/// §1.1, §5). The l10n checkers (`arb_checks.dart`) parse every value with
/// it, so a broken message fails a host test before gen-l10n sees it.
sealed class IcuNode {
  const IcuNode();
}

/// Literal text between placeholders.
final class IcuText extends IcuNode {
  const IcuText(this.text);

  final String text;
}

/// `{name}`.
final class IcuArg extends IcuNode {
  const IcuArg(this.name);

  final String name;
}

enum IcuChoiceKind { plural, select }

/// One `key{message}` branch of a plural or a select, in source order.
final class IcuBranch {
  const IcuBranch(this.key, this.body);

  final String key;
  final List<IcuNode> body;
}

/// `{name, plural, …}` or `{name, select, …}`.
final class IcuChoice extends IcuNode {
  const IcuChoice(this.name, this.kind, this.branches);

  final String name;
  final IcuChoiceKind kind;
  final List<IcuBranch> branches;

  Iterable<String> get keys => branches.map((branch) => branch.key);

  /// The first branch written for [key] (gen-l10n keeps the first and
  /// silently drops a repeat).
  List<IcuNode>? branch(String key) {
    for (final branch in branches) {
      if (branch.key == key) return branch.body;
    }
    return null;
  }
}

/// A parse failure, with the offset it happened at.
final class IcuFormatException implements Exception {
  const IcuFormatException(this.message, this.offset);

  final String message;
  final int offset;

  @override
  String toString() => 'ICU error at $offset: $message';
}

/// Parses [source] into its top-level nodes. Throws [IcuFormatException].
List<IcuNode> parseIcu(String source) => _IcuParser(source).parseRoot();

final class _IcuParser {
  _IcuParser(this.source);

  final String source;
  int pos = 0;

  static final _identifier = RegExp('[A-Za-z0-9_]');
  static final _space = RegExp(r'\s');

  List<IcuNode> parseRoot() {
    final nodes = _parseMessage(nested: false);
    if (pos < source.length) {
      throw IcuFormatException('unexpected "${source[pos]}"', pos);
    }
    return nodes;
  }

  List<IcuNode> _parseMessage({required bool nested}) {
    final nodes = <IcuNode>[];
    final text = StringBuffer();
    void flush() {
      if (text.isEmpty) return;
      nodes.add(IcuText(text.toString()));
      text.clear();
    }

    while (pos < source.length) {
      final char = source[pos];
      if (char == '{') {
        flush();
        nodes.add(_parseArgument());
      } else if (char == '}') {
        if (!nested) throw IcuFormatException('unbalanced "}"', pos);
        break;
      } else {
        text.write(char);
        pos++;
      }
    }
    if (nested && pos >= source.length) {
      throw IcuFormatException('unterminated branch', pos);
    }
    flush();
    return nodes;
  }

  IcuNode _parseArgument() {
    final start = pos;
    _expect('{');
    _skipSpace();
    final name = _readIdentifier();
    if (name.isEmpty) throw IcuFormatException('empty placeholder', start);
    _skipSpace();
    if (_peek('}')) {
      pos++;
      return IcuArg(name);
    }
    _expect(',');
    _skipSpace();
    final type = _readIdentifier();
    final kind = switch (type) {
      'plural' => IcuChoiceKind.plural,
      'select' => IcuChoiceKind.select,
      _ => throw IcuFormatException(
        'unsupported argument type "$type" (gen-l10n reads plural and '
        'select only)',
        pos,
      ),
    };
    _skipSpace();
    _expect(',');
    final branches = <IcuBranch>[];
    while (true) {
      _skipSpace();
      if (pos >= source.length) {
        throw IcuFormatException('unterminated $type', start);
      }
      if (_peek('}')) {
        pos++;
        break;
      }
      final keyStart = pos;
      while (pos < source.length &&
          !_space.hasMatch(source[pos]) &&
          source[pos] != '{' &&
          source[pos] != '}') {
        pos++;
      }
      final key = source.substring(keyStart, pos);
      if (key.isEmpty) throw IcuFormatException('empty branch key', keyStart);
      _skipSpace();
      _expect('{');
      final body = _parseMessage(nested: true);
      _expect('}');
      branches.add(IcuBranch(key, body));
    }
    if (branches.isEmpty) throw IcuFormatException('no branches', start);
    return IcuChoice(name, kind, branches);
  }

  String _readIdentifier() {
    final start = pos;
    while (pos < source.length && _identifier.hasMatch(source[pos])) {
      pos++;
    }
    return source.substring(start, pos);
  }

  bool _peek(String char) => pos < source.length && source[pos] == char;

  void _expect(String char) {
    if (!_peek(char)) {
      throw IcuFormatException(
        'expected "$char", found '
        '${pos < source.length ? '"${source[pos]}"' : 'the end'}',
        pos,
      );
    }
    pos++;
  }

  void _skipSpace() {
    while (pos < source.length && _space.hasMatch(source[pos])) {
      pos++;
    }
  }
}

/// Every node of [nodes], depth first, branch bodies included.
Iterable<IcuNode> walkIcu(List<IcuNode> nodes) sync* {
  for (final node in nodes) {
    yield node;
    if (node is IcuChoice) {
      for (final branch in node.branches) {
        yield* walkIcu(branch.body);
      }
    }
  }
}

/// The placeholder names [nodes] reference: plain arguments and the
/// variables plurals and selects switch on.
Set<String> referencedPlaceholders(List<IcuNode> nodes) => {
  for (final node in walkIcu(nodes))
    if (node is IcuArg) node.name else if (node is IcuChoice) node.name,
};

/// Every plural or select in [nodes], nested ones included.
Iterable<IcuChoice> choicesIn(List<IcuNode> nodes, IcuChoiceKind kind) =>
    walkIcu(nodes).whereType<IcuChoice>().where((c) => c.kind == kind);

/// The words a reader sees in [nodes]: every branch's text, placeholders
/// as a neutral space, branches on their own lines. The respect checks
/// match against this, so a placeholder or a select case key ("ice_melter",
/// "{before}") never reads as copy.
String readableText(List<IcuNode> nodes) {
  final out = StringBuffer();
  for (final node in nodes) {
    switch (node) {
      case IcuText(:final text):
        out.write(text);
      case IcuArg():
        out.write(' ');
      case IcuChoice(:final branches):
        for (final branch in branches) {
          out
            ..write('\n')
            ..write(readableText(branch.body))
            ..write('\n');
        }
    }
  }
  return out.toString();
}

/// [nodes] as source-like text with `{name}` kept: a branch's body, for
/// "does it show the number" (`plural_shape_test.dart`).
String bodyText(List<IcuNode> nodes) {
  final out = StringBuffer();
  for (final node in nodes) {
    switch (node) {
      case IcuText(:final text):
        out.write(text);
      case IcuArg(:final name):
        out.write('{$name}');
      case IcuChoice(:final name, :final branches):
        out.write('{$name: ');
        for (final branch in branches) {
          out.write('${branch.key}[${bodyText(branch.body)}] ');
        }
        out.write('}');
    }
  }
  return out.toString();
}

/// gen-l10n's mapping of a plural key onto `Intl.pluralLogic`'s
/// parameters (flutter_tools `pluralCases`): `=0` and `zero` are `zero`,
/// `=1` and `one` are `one`, `=2` and `two` are `two`. Null for a key
/// gen-l10n rejects.
String? pluralParameterOf(String key) => switch (key) {
  '=0' || 'zero' => 'zero',
  '=1' || 'one' => 'one',
  '=2' || 'two' => 'two',
  'few' => 'few',
  'many' => 'many',
  'other' => 'other',
  _ => null,
};

/// The branch key of [plural] the app shows for [count] in [localeName],
/// the way gen-l10n's generated code picks it: each key becomes an
/// `Intl.pluralLogic` parameter (the first key written wins a parameter),
/// and `Intl.pluralLogic` takes an exact 0, 1 or 2 first, then the
/// locale's CLDR rule, then `other`. This is where a copied `=1{1 …}`
/// shows for 0 in fr, pt and hi (l10n.md §5.2).
String pickPluralBranch(IcuChoice plural, int count, String localeName) {
  final parameters = <String, String>{};
  for (final key in plural.keys) {
    final parameter = pluralParameterOf(key);
    if (parameter != null) parameters.putIfAbsent(parameter, () => key);
  }
  return Intl.pluralLogic<String>(
    count,
    locale: localeName,
    zero: parameters['zero'],
    one: parameters['one'],
    two: parameters['two'],
    few: parameters['few'],
    many: parameters['many'],
    other: parameters['other'] ?? 'other',
  );
}

/// The CLDR category intl's rule gives [count] in [localeName], with no
/// exact-number shortcut.
String cldrCategoryOf(int count, String localeName) => Intl.pluralLogic<String>(
  count,
  locale: localeName,
  zero: 'zero',
  one: 'one',
  two: 'two',
  few: 'few',
  many: 'many',
  other: 'other',
  useExplicitNumberCases: false,
);
