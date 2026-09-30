import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/services/records/badge.dart';

/// M7's copy (docs/plans/m7-design.md §16, P2.11, P3.11 and phase 4's P4
/// copy section; phase 4 architecture §4): every key the M7 phases added
/// exists in `lib/l10n/app_en.arb`, and since Claude Design's m7-3 copy.md
/// landed (D171) each description cites its copy.md id, or says why the
/// string is not in copy.md. Nothing is a placeholder any more. Run from
/// `apps/game`.
void main() {
  late Map<String, Object?> arb;

  setUpAll(() {
    arb =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
            as Map<String, Object?>;
  });

  const m7Phase1Keys = [
    // Streak (E2)
    'dailyStreakPaused',
    'dailyStreakRelitTitle',
    'dailyStreakRelitBody',
    'streakBadgeSemanticsPaused',
    // Chapters (E7)
    'chaptersTitle',
    'chaptersBestMoves',
    'chaptersLevelSemanticsWon',
    'chaptersLevelSemanticsWonNoBest',
    'chaptersLevelSemanticsCurrent',
    'chaptersLevelSemanticsLocked',
    // Records and badges (E8)
    'recordsTitle',
    'homeRecordsButton',
    'recordsLevelsWon',
    'recordsFamilies',
    'recordsDolls',
    'recordsDailies',
    'recordsLongestStreak',
    'recordsBestMovesLink',
    'recordsBadgesHeader',
    'badgeName',
    'badgeHint',
    'badgeSemanticsEarned',
    'badgeSemanticsLocked',
    'badgeEarnedToastTitle',
    // Win card (E5, E7)
    'winMovesBest',
    'winMovesOnly',
    'winChestCountdown',
    'winReplayReason',
    'winBackToChapters',
    // Milestone chest (E5)
    'chestMilestoneTitle',
    'chestMilestoneBody',
    'chestMilestoneBodyBonus',
    'chestContentsHint',
    'chestContentsSemantics',
    'chestOpen',
    // Settings (E6, E14)
    'settingRelaxedMode',
    'settingRelaxedModeSubtitle',
    'settingReduceMotion',
    'reduceMotionSystem',
    'reduceMotionOn',
    'reduceMotionOff',
    // Relaxed mode on the board (E6)
    'oomUndoFreeUnlimited',
    'boosterUndoUnlimitedSemantics',
    // Home (E10)
    'homeVsComputerTile',
    'homeVsComputerLocked',
  ];

  /// vs Computer (M7 phase 2; m7-design P2.11).
  const m7Phase2Keys = [
    'raceSelectTitle',
    'raceComputerTag',
    'raceRivalName',
    'raceRivalBlurb',
    'raceRivalSkill',
    'raceRivalReward',
    'raceRivalLocked',
    'raceRivalSemantics',
    'raceStart',
    'raceStripReady',
    'raceStripThinking',
    'raceStripStartingOver',
    'raceStripFinished',
    'raceStripFamilies',
    'raceStripSemantics',
    'raceAnnounceFamily',
    'raceAnnounceStartingOver',
    'raceAnnounceFinished',
    'raceWinTitle',
    'raceLossTitle',
    'raceLossBody',
    'raceRivalUnlockedTitle',
    'raceRivalUnlockedBody',
    'raceRematch',
    'raceNewRace',
    'raceBackToRivals',
    'racePauseSubtitle',
    'raceQuit',
  ];

  /// Star ratings, the share card and the reminder (M7 phase 3; P3.11).
  const m7Phase3Keys = [
    'starsSemantics',
    'winStarsTarget',
    'winStarsNewBest',
    'starsFirstTip',
    'chaptersStarsTotal',
    'chaptersStarsSemantics',
    'recordsStars',
    'dailyShare',
    'dailyShareSemantics',
    'dailyShareText',
    'reminderOfferTitle',
    'reminderOfferTime',
    'reminderOfferChangeTime',
    'reminderOfferYes',
    'reminderOfferNo',
    'reminderOfferDone',
    'reminderOfferDenied',
    'reminderNotificationTitle',
    'reminderNotificationBody',
    'reminderChannelName',
    'reminderChannelDescription',
    'settingReminder',
    'settingReminderTime',
    'settingReminderBlocked',
  ];

  /// copy.md m7-3's new keys (phase 4 architecture §4, "NEW").
  const m7Phase4Keys = [
    'raceSelectSubtitle',
    'raceStartHint',
    'raceStripPlayerFinished',
    'raceWinBody',
    'raceWinCoins',
    'raceLeaveTitle',
    'raceLeaveBody',
    'raceLeaveKeep',
    'racePauseHeader',
    'raceAnnounceStart',
    'raceAnnounceWon',
    'raceAnnounceLost',
    'raceRivalNew',
    'raceFailedTitle',
    'raceFailedBody',
    'dailyShareGlyph',
    'dailyShareTextNoStreak',
    'reminderOfferBody',
    'reminderOfferDeniedTitle',
    'settingReminderOn',
    'settingReminderOff',
    'settingOpenPhoneSettings',
    'reminderNotificationBody2',
    'reminderNotificationBody3',
    'badgeLine',
    'badgeLockedLine',
    'chestContentsCoins',
    'relaxedModeOn',
    'dailyStreakPausedChip',
    'museumLockedShelfShort',
    'museumLockedLine1',
    'museumLockedLine2',
    'museumNextFamily',
    'chaptersWonCount',
    'recordsStarsValue',
    'recordsRacesHeader',
    'starsNewBestSemantics',
    'starsHelperNote',
    'chaptersAllThreeStars',
    'chaptersLevelPlay',
    'homeBonusBadge',
    'homeBonusKicker',
    'homeBonusName',
    'gameplayFailedTitle',
    'gameplayFailedBody',
    'oomUndoSpent',
    'extraSlotLimitToast',
    'tutorialStepChip',
    'splashStorageTitle',
    'splashStorageBody',
    'splashContentTitle',
    'splashContentBody',
  ];

  /// Keys copy.md m7-3 retired (phase 4 architecture §4): their surfaces
  /// changed, so no code reads them.
  const retiredKeys = [
    // Records shows the rule's count of every family completed, a plain
    // number: "{count} of 10" counted the Museum's figurines (the phase-4
    // device run, Q159).
    'recordsFamiliesValue',
    'museumChaptersLink',
    'recordsRaceRow',
    'raceSelectRace',
    'raceRivalWins',
    'settingReduceMotionSheetTitle',
    'chestInside',
    'dailyShareFamilyGlyph',
    'tutorialStep1Chip',
    'tutorialStep2Chip',
    'hudRaceChip',
    // Earlier retirements (D170, P2.10).
    'hudReplayChip',
    'homeVsComputerSoon',
    // Phase 4's screens stopped drawing them (the integrator, D202): the
    // chapter card carries its own label (`homeChapterCardSemantics`), the
    // Museum's collection card became the header's count chip (6.1), and
    // frame 10.6 draws no "Levels with 3 stars" cell (copy.md G.11 still
    // lists `records_three_star_levels`: asked in "Follow-up after m7-3").
    'homeChaptersButton',
    'museumCollection',
    'recordsThreeStarLevels',
  ];

  /// Final copy since M7 phase 1: the board's digits.
  const m7FinalKeys = ['boardTowerHidden', 'boardIceCount'];

  const allM7Keys = [
    ...m7Phase1Keys,
    ...m7Phase2Keys,
    ...m7Phase3Keys,
    ...m7Phase4Keys,
  ];

  String descriptionOf(String key) {
    final meta = arb['@$key'];
    expect(meta, isA<Map<String, Object?>>(), reason: 'missing "@$key"');
    final description = (meta! as Map<String, Object?>)['description'];
    expect(description, isA<String>(), reason: '"@$key" has no description');
    return description! as String;
  }

  Set<String> placeholdersOf(String key) =>
      (((arb['@$key']! as Map<String, Object?>)['placeholders'] ??
                  const <String, Object?>{})
              as Map<String, Object?>)
          .keys
          .toSet();

  test('every M7 key exists with a description', () {
    for (final key in [...allM7Keys, ...m7FinalKeys]) {
      expect(arb.containsKey(key), isTrue, reason: 'missing ARB key "$key"');
      expect(descriptionOf(key).trim(), isNotEmpty, reason: key);
    }
  });

  test('nothing is a placeholder any more (copy.md m7-3, D171)', () {
    for (final key in arb.keys.where((k) => k.startsWith('@'))) {
      final meta = arb[key];
      if (meta is! Map<String, Object?>) continue;
      expect(
        meta['description'] as String? ?? '',
        isNot(contains('Placeholder until Claude Design')),
        reason: key,
      );
    }
  });

  test('each M7 key cites its copy.md id or says why it is not there', () {
    final cites = RegExp(r'copy\.md (G\.\d+|E|H)\b|Not in copy\.md m7-3');
    for (final key in allM7Keys) {
      expect(descriptionOf(key), matches(cites), reason: key);
    }
  });

  test('the retired keys are gone', () {
    for (final key in retiredKeys) {
      expect(arb.containsKey(key), isFalse, reason: key);
      expect(arb.containsKey('@$key'), isFalse, reason: '@$key');
    }
  });

  test('the share text is spoiler-free: date, glyphs, moves, streak day', () {
    expect(placeholdersOf('dailyShareText'), {
      'date',
      'glyphs',
      'moves',
      'day',
    });
    expect(placeholdersOf('dailyShareTextNoStreak'), {
      'date',
      'glyphs',
      'moves',
    });
    expect(placeholdersOf('dailyShareGlyph'), {'color'});
  });

  test('every select covers its ids', () {
    bool covers(String key, String id) =>
        (arb[key]! as String).contains('$id{');
    for (final badge in BadgeId.values) {
      for (final key in ['badgeName', 'badgeHint', 'badgeLine']) {
        expect(covers(key, badge.id), isTrue, reason: '$key ${badge.id}');
      }
    }
    for (var n = 1; n <= 10; n++) {
      final id = 'ch${n.toString().padLeft(2, '0')}';
      expect(covers('chapterName', id), isTrue, reason: id);
    }
    for (final id in BundledCatalogRepository.figurineIds) {
      expect(covers('figurineName', id), isTrue, reason: id);
      expect(covers('figurineFlavor', id), isTrue, reason: id);
    }
    for (final skin in BundledCatalogRepository.bundledSkins) {
      final id = skin.id.replaceAll('-', '_');
      expect(covers('skinName', id), isTrue, reason: id);
      expect(covers('skinDescription', id), isTrue, reason: id);
    }
    for (final color in [
      'red',
      'orange',
      'yellow',
      'green',
      'teal',
      'blue',
      'purple',
      'pink',
      'navy',
      'brown',
      'gold',
    ]) {
      expect(covers('dailyShareGlyph', color), isTrue, reason: color);
    }
  });

  test('the screen-reader rival strings say "computer" (spec-prop §1.1 '
      'rule 5)', () {
    // Visible rival names no longer carry the word: the Computer tag beside
    // every name does (phase 4 decision on Q-P4-7), which lane R's widget
    // tests pin. What a screen reader hears still says it.
    for (final key in [
      'raceComputerTag',
      'raceRivalSemantics',
      'raceStripSemantics',
      'raceAnnounceStart',
      'raceAnnounceFamily',
      'raceAnnounceStartingOver',
      'raceAnnounceFinished',
      'raceAnnounceLost',
      'racePauseHeader',
      'raceSelectTitle',
      'homeVsComputerTile',
    ]) {
      expect(
        (arb[key]! as String).toLowerCase(),
        contains('computer'),
        reason: key,
      );
    }
  });

  test('the race copy names no human status (spec-prop §1.1 rule 5)', () {
    // Never a human avatar, an "online" status, a typing indicator or chat
    // (vs-computer rule 11).
    const human = ['online', 'typing', 'player 2', 'opponent is', 'chat'];
    for (final key in [
      ...m7Phase2Keys,
      ...m7Phase4Keys.where((k) => k.startsWith('race')),
    ]) {
      final value = (arb[key]! as String).toLowerCase();
      for (final word in human) {
        expect(value, isNot(contains(word)), reason: key);
      }
    }
  });
}
