import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/l10n/app_localizations.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

/// The M2 copy from design/README.md and the App Flow frames, through the
/// generated English localizations (plurals, selects, number formats).
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('splash, home and tiers', () {
    expect(l10n.splashDollSort, 'DOLL SORT');
    expect(l10n.splashCaption, 'Dusting the shelves…');
    expect(l10n.homePlay, 'PLAY');
    expect(l10n.tierHard, 'HARD');
    expect(l10n.tierSuperHard, 'SUPER HARD');
    expect(
      l10n.levelWithTier(56, l10n.tierName(Tier.hard.id)),
      'Level 56 · Hard',
    );
    expect(l10n.tierName(Tier.superhard.id), 'Super Hard');
    for (final tier in Tier.values) {
      expect(l10n.tierName(tier.id), isNotEmpty, reason: tier.id);
    }
    expect(l10n.playLevelSemantics(56, 'Hard'), 'Play level 56, Hard');
    expect(l10n.homeAllLevelsDone, 'All done!');
    // A progress bar's value in the locale's percent format.
    expect(l10n.progressPercent(0.42), '42%');
    expect(l10n.progressPercent(1), '100%');
  });

  test('HUD, coins and boosters', () {
    expect(l10n.familyCounter(1, 4), '1 / 4');
    expect(l10n.familyCounterSemantics(1, 4), '1 of 4 families done');
    expect(l10n.familyCounterSemantics(1, 1), '1 of 1 family done');
    expect(l10n.coinsSemantics(1), '1 coin');
    expect(l10n.coinsSemantics(1240), '1,240 coins');
    expect(l10n.coinPrice(60), '60 coins');
    expect(l10n.boosterCountSemantics('Hint', 2), 'Hint, 2 left');
    expect(l10n.boosterCoinSemantics('Undo', 20), 'Undo, 20 coins');
    expect(l10n.bonusLevelTitle(1), 'Bonus Level 1');
  });

  test('soft stuck and out of moves (3.4, 3.5, 3.7, 3.8)', () {
    expect(l10n.softStuckTitle, 'Hmm, this looks stuck');
    expect(l10n.softStuckBody, 'Try Undo? You can keep playing too.');
    expect(l10n.softStuckBodyRestart, 'Try Restart? You can keep playing too.');
    expect(l10n.oomTitle, 'No moves left!');
    expect(l10n.oomSubtitle, 'Pick a way to keep sorting.');
    expect(l10n.oomUndoFree(1), 'Free · 1 left');
    expect(l10n.oomUndoFree(2), 'Free · 2 left');
    expect(l10n.oomSlotTitle, '+1 Slot');
    expect(l10n.oomRestartSubtitle, 'Start this level fresh, for free');
    expect(l10n.offlineAds, 'Ad buttons switch to coin prices');
    expect(l10n.connectToWatchAd, 'Connect to watch an ad');
  });

  test('win, chapter and all-levels-done (2.8, 4.7, 4.9)', () {
    expect(l10n.winTitle, 'Level Complete!');
    expect(l10n.winCoins(25), '+25');
    expect(l10n.winTripleCoins, '×3 coins');
    expect(l10n.winChapter(3), 'Chapter 3');
    expect(l10n.winChapterProgress(16, 20), '16 / 20');
    expect(
      l10n.winNextUp(l10n.figurineName('baker')),
      'Next up: The Baker Family',
    );
    expect(
      l10n.chapterRibbon(4, l10n.chapterName(ChapterTheme.ch04.id)),
      'CHAPTER 4 · Snowy Cabin',
    );
    for (final theme in ChapterTheme.values) {
      expect(l10n.chapterName(theme.id), isNotEmpty, reason: theme.id);
    }
    expect(l10n.allLevelsTitle, "You've finished all levels!");
    expect(l10n.allLevelsPlayBonus(1), 'Play Bonus Level 1');
  });

  test('pause (3.9)', () {
    expect(l10n.pauseTitle, 'Paused');
    expect(l10n.resume, 'Resume');
    expect(
      [l10n.settingSound, l10n.settingMusic, l10n.settingHaptics],
      ['Sound', 'Music', 'Haptics'],
    );
  });
}
