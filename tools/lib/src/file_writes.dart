import 'dart:convert';
import 'dart:io';

/// What happened to one output file.
enum WriteOutcome { created, updated, unchanged }

/// Writes [bytes] to [file] only when its content differs, so re-running a
/// generator leaves timestamps (and build caches) alone.
///
/// With [dryRun] nothing is written; the outcome says what would happen,
/// which is how the `--check` modes detect drift.
WriteOutcome writeBytesIfChanged(
  File file,
  List<int> bytes, {
  bool dryRun = false,
}) {
  if (file.existsSync()) {
    final current = file.readAsBytesSync();
    if (_sameBytes(current, bytes)) return WriteOutcome.unchanged;
    if (!dryRun) file.writeAsBytesSync(bytes, flush: true);
    return WriteOutcome.updated;
  }
  if (!dryRun) {
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes, flush: true);
  }
  return WriteOutcome.created;
}

/// [writeBytesIfChanged] for text, always UTF-8 whatever the platform's
/// system encoding.
WriteOutcome writeStringIfChanged(
  File file,
  String content, {
  bool dryRun = false,
}) => writeBytesIfChanged(file, utf8.encode(content), dryRun: dryRun);

bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
