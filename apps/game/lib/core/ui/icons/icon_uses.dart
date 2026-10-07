import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/widgets.dart' show IconData;
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';

/// The glyph of every use tokens v3 names (tokens.json `icons`; design/README
/// "Icons"; phase 4 architecture §6.4), so a screen asks for "the reminder
/// glyph" instead of a font name, and the stand-ins M7 phases 1–3 used
/// (`download`, `calendarToday`, `smartDisplay`, `checkCircle`, `star`,
/// `bolt`, `sentimentSatisfied`, `extension`) retire in one place.
///
/// Each member is the `NestyIcons` glyph `IconTokens.<use>` names;
/// `icon_uses_test` pins the pairs, so a token rename fails a test instead of
/// drawing the wrong glyph. The two splash-error glyphs are ahead of the
/// tokens (lead note 2).
abstract final class IconUses {
  /// `auto_stories`: Chapters (Home's chapter card, the Chapters header).
  static const IconData chapters = NestyIcons.autoStories;

  /// `military_tech`: Records (Home's Records button, the Records header).
  static const IconData records = NestyIcons.militaryTech;

  /// `share`: the daily win card's Share on Android (and everywhere but
  /// iOS/macOS).
  static const IconData share = NestyIcons.share;

  /// `ios_share`: Share on iOS and macOS.
  static const IconData shareIos = NestyIcons.iosShare;

  /// `notifications`: the daily reminder (the offer, Settings' toggle).
  static const IconData reminder = NestyIcons.notifications;

  /// `notifications_off`: the reminder blocked by the phone (frame 10.2f).
  static const IconData reminderOff = NestyIcons.notificationsOff;

  /// `schedule`: the reminder's Time row and time chip.
  static const IconData reminderTime = NestyIcons.schedule;

  /// `spa`: Relaxed mode.
  static const IconData relaxedMode = NestyIcons.spa;

  /// `motion_photos_off`: Reduce motion.
  static const IconData reduceMotion = NestyIcons.motionPhotosOff;

  /// `route`: best moves (the win card's moves chip, Records' link).
  static const IconData bestMoves = NestyIcons.route;

  /// `flag`: a chapter's finale (Chapters' level 20 mark).
  static const IconData chapterFinale = NestyIcons.flag;

  /// `computer`: the Computer tag beside every rival (spec-prop §1.1 rule 5).
  static const IconData computerTag = NestyIcons.computer;

  /// `all_inclusive`: Undo's badge in Relaxed mode and a race (frame 10.9).
  static const IconData undoUnlimited = NestyIcons.allInclusive;

  /// `redeem`: a chest (the milestone and day-7 chests' chips and rows).
  static const IconData chest = NestyIcons.redeem;

  /// `check`: a claimed day on the daily gift's track.
  static const IconData giftDayDone = NestyIcons.check;

  /// `lightbulb`: a hint, in a gift tile and a chest chip.
  static const IconData rewardHint = NestyIcons.lightbulb;

  /// `add_box`: an extra slot (the +1 Slot booster's glyph), in a gift tile
  /// and a chest chip.
  static const IconData rewardSlot = NestyIcons.addBox;

  /// `replay`: a replay (the replay win card's reason line).
  static const IconData replay = NestyIcons.replay;

  /// `logout`: Leave race (frame 9.7).
  static const IconData leaveRace = NestyIcons.logout;

  /// `more_horiz`: the race strip's "thinking" glyph after the tag (9.3i,
  /// `layout.rivalStrip.forms.stateGlyph`).
  static const IconData raceStripThinking = NestyIcons.moreHoriz;

  /// `replay`: the race strip's "starting over" glyph after the tag (9.3i).
  static const IconData raceStripStartingOver = NestyIcons.replay;

  /// `check_circle`: the race strip's "finished" glyph after the tag (9.3i).
  static const IconData raceStripFinished = NestyIcons.checkCircle;

  /// `refresh`: Try again on a failure card.
  static const IconData retry = NestyIcons.refresh;

  /// `open_in_new`: Open phone settings.
  static const IconData openSettings = NestyIcons.openInNew;

  /// `check_circle`: Records' Levels won.
  static const IconData levelsWon = NestyIcons.checkCircle;

  /// `museum`: Records' Families home.
  static const IconData familiesHome = NestyIcons.museum;

  /// `layers`: Records' Dolls nested.
  static const IconData dollsNested = NestyIcons.layers;

  /// `extension`: Records' Daily puzzles solved.
  static const IconData dailiesSolved = NestyIcons.extension;

  /// `local_fire_department`: Records' Longest streak.
  static const IconData longestStreak = NestyIcons.localFireDepartment;

  /// `sd_card_alert`: the splash's storage error (frame 12.10).
  // TODO(design): ask Claude Design to add `storageError` and `contentError`
  // to tokens.json `icons` (lead note 2; ui-spec-game C9).
  static const IconData storageError = NestyIcons.sdCardAlert;

  /// `inventory_2`: the splash's content error (frame 12.11).
  static const IconData contentError = NestyIcons.inventory2;

  /// Share's glyph on [platform]: `ios_share` on iOS and macOS (tokens
  /// `icons.shareIOS`), `share` elsewhere (Q151).
  static IconData shareFor(TargetPlatform platform) => switch (platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => shareIos,
    _ => share,
  };
}
