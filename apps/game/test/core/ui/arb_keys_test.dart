import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// docs/plans/m3-design.md §13: every ARB key it lists must exist in
/// `lib/l10n/app_en.arb` with an `@key` block that has a non-empty
/// `description`. Run from `apps/game` (the test runner's cwd), like every
/// other test in this suite.
void main() {
  late Map<String, Object?> arb;

  setUpAll(() {
    final file = File('lib/l10n/app_en.arb');
    arb = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  });

  // m3 §13, in the order the plan lists them (existing keys it reuses are
  // covered by m2_copy_test.dart and are not repeated here).
  const m3Keys = [
    // Shell/Home
    'navShop',
    'navMuseum',
    'homeDailyTile',
    'homeMuseumTile',
    'homeRemoveAdsTile',
    'homeMuseumProgress',
    'homeDailyLocked',
    'streakBadgeSemantics',
    // Settings
    'settingColorSymbols',
    'symbolsSubtle',
    'symbolsLarge',
    'settingLanguage',
    'settingRestorePurchases',
    'settingPrivacyChoices',
    'settingPrivacyPolicy',
    'settingSupport',
    'settingSupportValue',
    'settingsFooter',
    'languageSheetTitle',
    'languageSheetDone',
    'languageName',
    'languageComingSoon',
    // Daily
    'dailyStreakDays',
    'dailyStreakKeep',
    'dailyStreakStart',
    'dailyStreakDone',
    'dailyStreakWeek',
    'dailyFreezes',
    'dailyDay',
    'dailyToday',
    'dailyTomorrow',
    'dailyChestRow',
    'dailyChestToGoToday',
    'dailyChestToGo',
    'dailyChestOpenedToday',
    'dailyPuzzleTitle',
    'dailyPuzzleInfo',
    'dailyPlay',
    'dailySolvedChip',
    'dailyNextPuzzle',
    'dailyCountdown',
    'playLevel',
    'dailySavedTitle',
    'dailySavedBody',
    'dailyChestTitle',
    'dailyChestBody',
    'dailyChestDouble',
    'dailyChestCollect',
    'dailyWinTitle',
    'dailyWinStreak',
    'dailyWinChestHint',
    'dailyBackToDaily',
    // Museum
    'museumTitle',
    'museumCount',
    'museumNextLine',
    'museumAllHome',
    'museumFamilyLabel',
    'museumSoonLabel',
    'figurineShortName',
    'figurineName',
    'figurineFlavor',
    'museumChapterChip',
    'museumCollectedOn',
    'museumCollected',
    'museumLockedText',
    // Shop
    'shopTitle',
    'shopTabCoins',
    'shopTabSkins',
    'shopTabThemes',
    'shopTabNoAds',
    'shopEquipped',
    'shopEquip',
    'skinName',
    'skinDescription',
    'skinDetailTitle',
    'skinDetailColors',
    'skinDetailSizes',
    'shopBuy',
    'balanceLine',
    'shopDownloading',
    'themesMatchTitle',
    'themesMatchSubtitle',
    'themeInUse',
    'themeUse',
    'themeChapterLock',
    'shopClosedTitle',
    'shopClosedBody',
    // Gameplay
    'buyUndoText',
    'buyHintText',
    'buySlotText',
    // copy.md m7-3's one chip for the three steps (E `tut_step_chip`).
    'tutorialStepChip',
    'tutorialStep1Title',
    'tutorialStep1Text',
    'tutorialStep2Title',
    'tutorialStep2Text',
    'tutorialStep3Title',
    'tutorialStep3Text',
    'tutorialSwallowChip',
    'tutorialSwallowTitle',
    'tutorialSwallowText',
    'introNew',
    'introTowersTitle',
    'introTowersText',
    'introGlassTitle',
    'introGlassText',
    'introIceTitle',
    'introIceText',
    'introGotIt',
    'chapterCompleteTitle',
    'chapterCompleteAdded',
    'chapterCompleteCoins',
    'chapterCompleteNext',
    'gameplayGenerating',
  ];

  test('every m3 §13 key exists with a description', () {
    for (final key in m3Keys) {
      expect(arb.containsKey(key), isTrue, reason: 'missing ARB key "$key"');
      final meta = arb['@$key'];
      expect(meta, isA<Map<String, Object?>>(), reason: 'missing "@$key"');
      final description = (meta! as Map<String, Object?>)['description'];
      expect(description, isA<String>(), reason: '"@$key" has no description');
      expect(
        (description! as String).trim(),
        isNotEmpty,
        reason: '"@$key".description is empty',
      );
    }
  });

  test('figurineName and figurineShortName cover every bundled figurine', () {
    const ids = [
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
    for (final key in ['figurineName', 'figurineShortName']) {
      final template = arb[key]! as String;
      for (final id in ids) {
        expect(
          template.contains('$id{'),
          isTrue,
          reason: '$key is missing the "$id" select case',
        );
      }
    }
  });

  test('no key is left with an empty description anywhere in the file', () {
    for (final entry in arb.entries) {
      if (!entry.key.startsWith('@') || entry.key == '@@locale') continue;
      final meta = entry.value;
      if (meta is! Map<String, Object?>) continue;
      final description = meta['description'];
      expect(
        description,
        isA<String>(),
        reason: '${entry.key} has no description',
      );
      expect(
        (description! as String).trim(),
        isNotEmpty,
        reason: '${entry.key}.description is empty',
      );
    }
  });
}
