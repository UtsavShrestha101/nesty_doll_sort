import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// E1, the respect rules for the star rating (D125; spec-prop §7.10 "stars
/// never gate progress, pay nothing and never go down", §1.1 rules 1 and 2;
/// docs/plans/m7-design.md P3.12): no reward, unlock or gate path names the
/// stars, and a 1-star win pays and unlocks exactly what a 3-star win does.
///
/// Stars are read only by the save's star step, the records and chapters
/// totals, the bloc's win state and the star widget; everything that pays
/// a reward (the milestone chest, the daily and its chest, the win's coins,
/// badges), opens a level (the resolvers, the router) or gates a mode (vs
/// Computer, the Shop, the Museum) must never read them. Home only shows
/// the chapter's and the campaign's star totals (frame 2.1's chapter card,
/// phase 4), through `ChapterStarTally` in `features/chapters/cubit/`, so
/// `features/home` still never names the rule and stays in the scan. Run
/// from `apps/game`.
void main() {
  /// The reward, unlock and gate paths (m7-design P3.12). Every one must
  /// exist, so a rename can't quietly empty the scan.
  const gatePaths = [
    'lib/core/services/chest',
    'lib/core/services/daily',
    'lib/core/services/race',
    'lib/core/repository',
    'lib/core/router',
    'lib/features/home',
    'lib/features/race',
    'lib/features/shop',
    'lib/features/museum',
    'lib/core/services/records/badge_rules.dart',
    'lib/features/gameplay/bloc/win_reward.dart',
  ];

  /// The star rating's names: the save's field, core's rule, the app's glue
  /// and the rule's functions.
  final starNames = RegExp(
    r'\blevelStars\b|\bStarRating\b|\bStarRules\b|'
    r'\bstarsFor(Win)?\b',
  );

  List<File> dartFilesUnder(String path) {
    if (File(path).existsSync()) return [File(path)];
    return Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where(
          (file) =>
              !file.path.endsWith('.freezed.dart') &&
              !file.path.endsWith('.g.dart') &&
              !file.path.endsWith('.gr.dart'),
        )
        .toList();
  }

  test('every scanned path exists', () {
    for (final path in gatePaths) {
      expect(
        File(path).existsSync() || Directory(path).existsSync(),
        isTrue,
        reason: '$path is gone: update the scan to where it moved',
      );
    }
  });

  test('no reward, unlock or gate path names the stars', () {
    final offences = <String>[];
    var scanned = 0;
    for (final path in gatePaths) {
      for (final file in dartFilesUnder(path)) {
        scanned++;
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          // Code only: a doc comment may explain that stars gate nothing.
          final code = lines[i].split('//').first;
          if (starNames.hasMatch(code)) {
            offences.add('${file.path}:${i + 1}: ${lines[i].trim()}');
          }
        }
      }
    }
    expect(scanned, greaterThan(20), reason: 'the scan found too few files');
    expect(offences, isEmpty, reason: offences.join('\n'));
  });

  group('a 1-star win pays and unlocks what a 3-star win does', () {
    LevelWinRecord win(int order, {required int stars}) => LevelWinRecord(
      request: PlayRequest.campaign(order),
      rewardCoins: 10,
      moves: 14,
      families: 4,
      starsKey: 'L${order.toString().padLeft(4, '0')}',
      stars: stars,
    );

    test('the same coins, progress, chests, records and badges', () {
      final low = FakeSaveService();
      final high = FakeSaveService();
      // Twenty levels: past the first milestone chest's cadence and a
      // chapter's end, so every reward path the win reaches runs.
      for (var order = 1; order <= 20; order++) {
        final lowOutcome = low.recordLevelWin(win(order, stars: 1));
        final highOutcome = high.recordLevelWin(win(order, stars: 3));
        expect(lowOutcome.stars, 1);
        expect(highOutcome.stars, 3);
      }
      expect(low.document.levelStars.values.toSet(), {1});
      expect(high.document.levelStars.values.toSet(), {3});
      // Apart from the stars themselves and the one-time tip, the two saves
      // are the same document.
      SaveDocument withoutStars(SaveDocument doc) =>
          doc.copyWith(levelStars: const {}, starTipShown: false);
      expect(withoutStars(low.document), withoutStars(high.document));
      expect(low.document.coins, high.document.coins);
      expect(low.document.currentLevel, high.document.currentLevel);
      expect(low.document.highestLevel, 21);
    });
  });
}
