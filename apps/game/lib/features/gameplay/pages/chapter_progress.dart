import 'package:flutter/foundation.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_render/nesty_render.dart';

/// Where a level sits in its chapter (spec §7.1: 20 levels per chapter,
/// each with its own theme and museum figurine): the win overlay's chapter
/// card (frame 2.8 "Chapter 3 · 16 / 20") and the new-chapter ribbon (frame
/// 4.7, L21 opens ch02).
///
/// Read from the bundle's `chapterId`s, never from `order ~/ 20`, so a
/// chapter the admin makes shorter or longer still counts right.
@immutable
final class ChapterProgress {
  const ChapterProgress({
    required this.chapterId,
    required this.number,
    required this.done,
    required this.total,
    required this.isFirstLevel,
  });

  /// The chapter of [entry], counted in [levels].
  factory ChapterProgress.of(LevelBundleEntry entry, LevelRepository levels) {
    final id = entry.chapterId;
    var first = entry.order;
    while (first > 1 && levels.entryAt(first - 1)?.chapterId == id) {
      first--;
    }
    var last = entry.order;
    final count = levels.levelCount;
    while (last < count && levels.entryAt(last + 1)?.chapterId == id) {
      last++;
    }
    return ChapterProgress(
      chapterId: id,
      number: numberOf(id),
      done: entry.order - first + 1,
      total: last - first + 1,
      isFirstLevel: first == entry.order,
    );
  }

  /// The bundle's chapter id, such as `ch02`: also the theme and the
  /// `chapterName` ARB select key.
  final String chapterId;

  /// 1-based.
  final int number;

  /// Levels of the chapter up to and including this one.
  final int done;

  /// Levels in the chapter.
  final int total;

  /// The chapter's opening level: the ribbon of frame 4.7 names the
  /// chapter as it starts.
  final bool isFirstLevel;

  /// The chapter's theme (spec §12.4): its background and the ribbon's
  /// name.
  ChapterTheme get theme =>
      ChapterTheme.byId(chapterId) ?? ChapterTheme.forChapter(number);

  /// The last level of the chapter was just won (frame 4.5, "20 / 20").
  bool get isComplete => done >= total;

  /// 0–1, for the chapter bar.
  double get fraction => total <= 0 ? 0 : done / total;

  /// The ribbon plays on the opening level of every chapter after the
  /// first (the first opens with the tutorial, spec §7.6).
  bool get opensWithRibbon => isFirstLevel && number > 1;

  /// The museum figurine the chapter awards (spec §7.2, design/museum:
  /// `01-classic` … `10-explorer`), the `figurineName` ARB select key.
  String get figurineId => figurineIds[(number - 1) % figurineIds.length];

  static const figurineIds = [
    'classic',
    'sailor',
    'baker',
    'astronaut',
    'gardener',
    'snow',
    'circus',
    'musician',
    'royal',
    'explorer',
  ];

  /// The number in a `chNN` id, or 1 when it has none.
  static int numberOf(String chapterId) {
    final digits = chapterId.replaceAll(RegExp('[^0-9]'), '');
    final n = int.tryParse(digits);
    return n == null || n < 1 ? 1 : n;
  }

  @override
  bool operator ==(Object other) =>
      other is ChapterProgress &&
      other.chapterId == chapterId &&
      other.number == number &&
      other.done == done &&
      other.total == total &&
      other.isFirstLevel == isFirstLevel;

  @override
  int get hashCode => Object.hash(chapterId, number, done, total, isFirstLevel);

  @override
  String toString() =>
      'ChapterProgress($chapterId, $done / $total, first: $isFirstLevel)';
}
