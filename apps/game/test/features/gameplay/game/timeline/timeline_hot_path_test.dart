// CLAUDE.md rule 8: what the board timeline runs every frame (advance, the
// dispatch loop, the input queries, the tweens the board reads, the anchor
// resolvers of the re-pitch lerp) must not allocate. Dart has no allocation
// counter a test can read, so this guards the source, as nesty_render's
// hot_path_allocation_test does: no allocating construct may appear between
// the "Hot path" / "End of hot path" markers.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _dir = 'lib/features/gameplay/game/timeline';

const _files = [
  '$_dir/board_timeline.dart',
  '$_dir/hand_tween.dart',
  '$_dir/slot_reservations.dart',
  '$_dir/fx_placement.dart',
];

final _forbidden = <String, RegExp>{
  'Offset(…)': RegExp(r'\bOffset\('),
  'Rect.from…': RegExp(r'\bRect\.from'),
  'toReference (allocates an Offset)': RegExp(r'\btoReference\('),
  'command/cue/clip construction': RegExp(
    r'\b(StartClip|PlayClipSegment|PlaceClip|ReleaseClipSlots|StopClip|'
    r'PlaySlotFx|ReleaseSlotFx|SyncSlot|StartTween|EndTween|SetHintArc|'
    r'FamilyLanded|BoardWon|BoardOutOfMoves|ResetBoard|FxCue|FxClip|'
    r'FxSegment|FxPlacement|FxClipParams|TimelineBatch|_Queued|_Track)\(',
  ),
  'List/Map/Set building': RegExp(
    r'\b(List|Map|Set)\.|\.to(List|Set)\(|<\w+>\[|\[\s*\]|\{\s*\}\s*;',
  ),
  'map/where/expand': RegExp(r'\.(map|where|expand|fold|forEach|any)\('),
  'for-in (iterator)': RegExp(r'\bfor\s*\(\s*(final|var)\s+\w+\s+in\b'),
  'string interpolation': RegExp(r'''['"][^'"\n]*\$'''),
  'closure': RegExp(r'[(,=]\s*\([^()]*\)\s*(=>|\{)'),
};

final _region = RegExp(
  r'// ── Hot path:[^\n]*\n([\s\S]*?)// ── End of hot path\. ──',
);

void main() {
  for (final path in _files) {
    test('$path hot path allocates nothing', () {
      final source = File(path).readAsStringSync();
      final regions = _region.allMatches(source).toList();
      expect(regions, isNotEmpty, reason: 'no hot-path markers in $path');
      final offending = <String>[];
      for (final region in regions) {
        for (final line in region[1]!.split('\n')) {
          final code = line.replaceFirst(RegExp(r'//.*$'), '');
          // `case StartClip():` is an object pattern, not a construction.
          if (code.trimLeft().startsWith('case ')) continue;
          _forbidden.forEach((what, pattern) {
            if (pattern.hasMatch(code)) offending.add('$what: ${line.trim()}');
          });
        }
      }
      expect(offending, isEmpty);
    });
  }

  test('the per-frame entry points are inside the hot path', () {
    String hot(String path) => _region
        .allMatches(File(path).readAsStringSync())
        .map((m) => m[1]!)
        .join();
    final timeline = hot('$_dir/board_timeline.dart');
    for (final signature in [
      'void advance(double dtMs)',
      'void _dispatchDue()',
      'void _dispatch(_Queued item)',
      'bool _canStart(',
      'bool get inputLocked',
      'bool isReserved(String slotId)',
      'bool acceptsInput(String slotId)',
      'bool before(_Queued other)',
    ]) {
      expect(timeline, contains(signature), reason: signature);
    }
    final tweens = hot('$_dir/hand_tween.dart');
    for (final signature in [
      'void update(double nowMs)',
      'double buriedBaseY(int depth)',
      'double lerp(double a, double b)',
    ]) {
      expect(tweens, contains(signature), reason: signature);
    }
  });

  test('the guard catches what it should and passes what it should', () {
    bool flagged(String line) =>
        !line.trimLeft().startsWith('case ') &&
        _forbidden.values.any((pattern) => pattern.hasMatch(line));
    for (final bad in [
      'final p = Offset(x, y);',
      'final r = fit.toReference(x, y);',
      '_commands.execute(StopClip(0, clip), 0);',
      'for (final item in _queue) {',
      'final due = _queue.where((q) => q.at <= now).toList();',
      "debugPrint('late \$lateMs');",
      'final xs = <double>[];',
      '_queue.sort((a, b) => a.seq - b.seq);',
    ]) {
      expect(flagged(bad), isTrue, reason: bad);
    }
    for (final good in [
      'while (_head < _queue.length && _queue[_head].at <= _now) {',
      'for (var i = 0; i < _tweens.length; i++) {',
      '_commands.execute(command, lateMs);',
      'case StartTween(:final tween):',
      'if (track == null || !track.live) return;',
      '_set(t < 0 ? 0 : (t > 1 ? 1 : t));',
    ]) {
      expect(flagged(good), isFalse, reason: good);
    }
  });
}
