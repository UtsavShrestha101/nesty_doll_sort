import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// E1, the respect rules (spec-prop §1.1 rule 2: no paid or unpaid
/// randomness in rewards; docs/plans/m7-design.md §17): no reward path in
/// `apps/game/lib` reads `dart:math`'s `Random` or any other unseeded
/// source. Rewards come from the save's fixed rules and Remote Config; the
/// race's pace jitter (phase 2) comes from nesty_core's seeded `Prng`.
///
/// The paths scanned are the ones that decide or pay a reward: the save,
/// the daily streak and its chest, the records and badges, the milestone
/// chest, the gameplay bloc, and the screens that grant nothing but show
/// rewards (Chapters, Records), and the chest opening that shows and counts
/// up a chest's contents (owner-chest's `ChestRewardSequence` and both
/// chest modals: the amounts it shows must be the ones paid), and vs
/// Computer's (m7-design P2.12): the race's rules and pace, its frame
/// clock, and the race feature (the cubit that pays a win, rival select
/// that shows the rewards). Run from `apps/game`.
void main() {
  const rewardPaths = [
    'lib/core/services/save',
    'lib/core/services/daily',
    'lib/core/services/records',
    'lib/core/services/chest',
    'lib/features/gameplay/bloc',
    'lib/features/chapters',
    'lib/features/records',
    'lib/features/fx/chest',
    'lib/features/gameplay/overlays/milestone_chest_modal.dart',
    'lib/features/daily/widgets/daily_chest_modal.dart',
    // vs Computer (m7-design P2.12): the rival's moves and the pace jitter
    // draw only from nesty_core's seeded streams (`RivalBot`, `Prng`).
    'lib/core/services/race',
    'lib/core/services/ticker',
    'lib/features/race',
    // The star rating (m7-design P3.12): stars are a pure function of the
    // moves and the par, drawn by the one widget every star surface uses.
    'lib/core/ui/widgets/stars',
  ];

  /// An unseeded or platform random source, or the wall clock (which a
  /// reward must never depend on either: rule 7's spirit, the clock is
  /// `AppClock`).
  final forbidden = RegExp(
    r'\bRandom\s*\(|\bRandom\.secure\b|\bmath\.Random\b|'
    r'\bDateTime\.now\s*\(',
  );

  /// The one allowed use: the Settings footer's Player ID (m3-design §3.1),
  /// an identity, not a reward.
  bool allowed(String file, String line) =>
      file.endsWith('in_memory_save_service.dart') &&
      (line.contains('newPlayerId') ||
          line.contains('Random.secure()') ||
          line.contains('math.Random? random'));

  test('no reward path reads an unseeded random source', () {
    final offences = <String>[];
    for (final path in rewardPaths) {
      final Iterable<FileSystemEntity> entities;
      if (File(path).existsSync()) {
        entities = [File(path)];
      } else if (Directory(path).existsSync()) {
        entities = Directory(path).listSync(recursive: true);
      } else {
        continue;
      }
      for (final entity in entities) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path.endsWith('.freezed.dart') ||
            entity.path.endsWith('.g.dart')) {
          continue;
        }
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          final code = line.split('//').first;
          if (forbidden.hasMatch(code) && !allowed(entity.path, line)) {
            offences.add('${entity.path}:${i + 1}: ${line.trim()}');
          }
        }
      }
    }
    expect(offences, isEmpty);
  });

  test('every scanned path exists (a rename would silently drop it)', () {
    for (final path in rewardPaths) {
      expect(
        File(path).existsSync() || Directory(path).existsSync(),
        isTrue,
        reason: path,
      );
    }
  });

  test('the scan sees a random source when there is one', () {
    expect(forbidden.hasMatch('final r = math.Random();'), isTrue);
    expect(forbidden.hasMatch('final r = Random(42);'), isTrue);
    expect(forbidden.hasMatch('DateTime.now()'), isTrue);
    expect(forbidden.hasMatch('final prng = Prng(seed);'), isFalse);
  });
}
