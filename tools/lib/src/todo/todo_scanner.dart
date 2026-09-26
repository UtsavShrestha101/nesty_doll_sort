// Finds tagged work markers in first-party files so no future-milestone
// work is lost (docs/TODO_INDEX.md), and flags markers without a tag.
//
// A marker is the word `TODO` or `FIXME`, optionally followed by a tag in
// parentheses and a colon, inside a comment (or anywhere in Markdown prose).
// Markers inside `inline code` or fenced code blocks are references to the
// convention, not work items, and are skipped (which is also why this file
// only ever names the markers inside backticks).

/// The tags a marker may carry. Combinations such as `M3/M4` are allowed.
const milestoneTags = ['M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7', 'M8'];
const otherTags = ['v1.1', 'design', 'later'];
const allowedTags = [...milestoneTags, ...otherTags];

final _marker = RegExp(r'\b(TODO|FIXME)\b(?:\(([^)\n]*)\))?:?');
final _codeSpan = RegExp(r'`[^`\n]*`');

/// File extensions the scanner reads, with the comment syntax it expects.
const _slashComments = {'dart', 'gradle', 'kts', 'kt', 'swift', 'rules'};
const _hashComments = {'sh', 'yaml', 'yml'};
const _xmlComments = {'plist'};
const _markdown = {'md'};

/// Every extension [scanTodos] reads.
const scannedExtensions = {
  ..._slashComments,
  ..._hashComments,
  ..._xmlComments,
  ..._markdown,
};

/// One marker found in a file.
final class TodoMarker {
  TodoMarker({
    required this.path,
    required this.line,
    required this.kind,
    required this.tag,
    required this.text,
  });

  /// Repo-relative path with `/` separators.
  final String path;

  /// 1-based line number.
  final int line;

  /// `TODO` or `FIXME`.
  final String kind;

  /// The raw tag (`M3/M4`), or null when the marker has none.
  final String? tag;

  /// The marker's description, including comment continuation lines.
  final String text;

  /// The individual tags of [tag] (`M3/M4` → `[M3, M4]`).
  List<String> get tags => tag == null ? const [] : tag!.split('/');

  /// True when every part of [tag] is an [allowedTags] entry.
  bool get hasValidTag =>
      tag != null && tags.isNotEmpty && tags.every(allowedTags.contains);

  String get location => '$path:$line';
}

/// A problem `--check` reports.
final class TodoViolation {
  TodoViolation(this.marker, this.message);
  final TodoMarker marker;
  final String message;

  @override
  String toString() => '${marker.location}: $message';
}

/// Scans one file's [content]. [path] decides the comment syntax.
List<TodoMarker> scanTodos(String path, String content) {
  final ext = path.contains('.') ? path.split('.').last.toLowerCase() : '';
  if (!scannedExtensions.contains(ext)) return const [];
  final isMarkdown = _markdown.contains(ext);
  final lines = content.split('\n');
  final regions = _commentRegions(lines, ext);
  final markers = <TodoMarker>[];
  for (var i = 0; i < lines.length; i++) {
    final region = regions[i];
    if (region == null) continue;
    for (final match in _marker.allMatches(region.masked)) {
      final next = _marker.firstMatch(region.masked.substring(match.end));
      final end = next == null ? region.text.length : match.end + next.start;
      final parts = [_clean(region.text.substring(match.end, end))];
      // Continuation lines of the same comment block belong to the last
      // marker on the line.
      if (next == null) {
        for (var j = i + 1; j < lines.length && j <= i + 8; j++) {
          final cont = regions[j];
          if (cont == null ||
              !cont.continues(region, isMarkdown) ||
              cont.masked.trim().isEmpty) {
            break;
          }
          final hit = _marker.firstMatch(cont.masked);
          parts.add(
            _clean(hit == null ? cont.text : cont.text.substring(0, hit.start)),
          );
          if (hit != null || cont.closes) break;
        }
      }
      markers.add(
        TodoMarker(
          path: path,
          line: i + 1,
          kind: match[1]!,
          tag: match[2]?.trim(),
          text: _truncate(
            _dropUnbalancedParen(parts.where((p) => p.isNotEmpty).join(' ')),
          ),
        ),
      );
    }
  }
  return markers;
}

/// Problems with [markers]: untagged markers outside Markdown prose, and
/// tags that are not in [allowedTags].
List<TodoViolation> checkTodos(Iterable<TodoMarker> markers) => [
  for (final m in markers)
    if (m.tag == null && !m.path.endsWith('.md'))
      TodoViolation(
        m,
        '${m.kind} without a tag. Write ${m.kind}(<tag>): with a tag from '
        '${allowedTags.join(', ')} (combos like M3/M4 are fine).',
      )
    else if (m.tag != null && !m.hasValidTag)
      TodoViolation(
        m,
        'Unknown tag "${m.tag}". Allowed: ${allowedTags.join(', ')} '
        '(combos like M3/M4).',
      ),
];

/// The comment part of one line, or null when the line has no comment.
final class _Region {
  _Region(this.text, this.masked, this.prefix, {this.closes = false});

  /// Comment text as written.
  final String text;

  /// [text] with code spans blanked out (same length), for finding markers.
  final String masked;

  /// The comment token that opened the region on this line (`//`, `///`,
  /// `#`, `*`, `<!--`, or '' for Markdown prose / block comment bodies).
  final String prefix;

  /// True when the comment ends on this line (`*/`, `-->`).
  final bool closes;

  bool continues(_Region previous, bool markdown) =>
      markdown ? !_startsBlock(masked) : prefix == previous.prefix;

  static bool _startsBlock(String text) =>
      RegExp(r'^\s*(?:[-*+] |\d+\. |#|\||<!--)').hasMatch(text);
}

List<_Region?> _commentRegions(List<String> lines, String ext) {
  final regions = <_Region?>[];
  var inBlock = false; // /* … */ or <!-- … -->
  var inFence = false; // ``` in Markdown
  for (final raw in lines) {
    // Masking keeps every index, so slices of `masked` and `raw` line up.
    final masked = raw.replaceAllMapped(_codeSpan, (m) => ' ' * m[0]!.length);
    _Region region(int start, int end, String prefix, {bool closes = false}) =>
        _Region(
          raw.substring(start, end),
          masked.substring(start, end),
          prefix,
          closes: closes,
        );

    if (_markdown.contains(ext)) {
      if (raw.trimLeft().startsWith('```')) {
        inFence = !inFence;
        regions.add(null);
        continue;
      }
      regions.add(
        inFence
            ? null
            : region(0, raw.length, '', closes: masked.contains('-->')),
      );
      continue;
    }
    final closer = _xmlComments.contains(ext) ? '-->' : '*/';
    if (inBlock) {
      final end = masked.indexOf(closer);
      inBlock = end == -1;
      final bodyEnd = end == -1 ? raw.length : end;
      final star = RegExp(r'^\s*\*(?!/)').firstMatch(masked);
      regions.add(
        region(
          star == null ? 0 : star.end,
          bodyEnd < (star?.end ?? 0) ? star!.end : bodyEnd,
          star == null ? '' : '*',
          closes: !inBlock,
        ),
      );
      continue;
    }
    final start = _commentStart(masked, ext);
    if (start == null) {
      regions.add(null);
      continue;
    }
    final (index, token) = start;
    var bodyStart = index + token.length;
    var bodyEnd = raw.length;
    var closes = false;
    if (token == '/*' || token == '<!--') {
      final end = masked.indexOf(closer, bodyStart);
      if (end == -1) {
        inBlock = true;
      } else {
        bodyEnd = end;
        closes = true;
      }
    }
    var prefix = token;
    if (token == '//' && masked.startsWith('/', bodyStart)) {
      prefix = '///';
      bodyStart++;
    }
    regions.add(region(bodyStart, bodyEnd, prefix, closes: closes));
  }
  return regions;
}

(int, String)? _commentStart(String line, String ext) {
  final candidates = <(int, String)>[];
  void find(String token) {
    final i = line.indexOf(token);
    if (i != -1) candidates.add((i, token));
  }

  if (_slashComments.contains(ext)) {
    find('//');
    find('/*');
  } else if (_hashComments.contains(ext)) {
    // `#` starts a comment at line start or after whitespace (not in `a#b`).
    final m = RegExp(r'(^|\s)#').firstMatch(line);
    if (m != null) candidates.add((m.start + m[1]!.length, '#'));
  } else if (_xmlComments.contains(ext)) {
    find('<!--');
  }
  if (candidates.isEmpty) return null;
  candidates.sort((a, b) => a.$1.compareTo(b.$1));
  return candidates.first;
}

String _clean(String text) => text
    .replaceAll(RegExp(r'\s*(\*/|-->)\s*$'), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

// `(TODO(M3): pause menu).` → `pause menu.`: the marker sat inside
// parentheses that closed after it.
String _dropUnbalancedParen(String text) {
  final opens = '('.allMatches(text).length;
  final closes = ')'.allMatches(text).length;
  if (closes <= opens) return text;
  final i = text.lastIndexOf(')');
  return (text.substring(0, i) + text.substring(i + 1)).trim();
}

String _truncate(String text) {
  const max = 220;
  if (text.length <= max) return text;
  final cut = text.lastIndexOf(' ', max);
  return '${text.substring(0, cut == -1 ? max : cut)} …';
}
