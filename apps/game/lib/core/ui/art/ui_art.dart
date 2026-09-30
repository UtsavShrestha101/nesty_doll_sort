import 'dart:ui' show Size;

import 'package:nesty_game/core/services/records/badge.dart';

/// Every UI illustration Claude Design delivered in m7-3 (`design/ui/**`,
/// synced by `sync_design_assets` to `assets/ui/<folder>/<file>.svg`; PROGRESS
/// D176): the stars, the chest, the reward-flight sprites, the rival
/// portraits and the twelve badges, earned and locked (phase 4 architecture
/// §3.4).
///
/// Each value names its file and its viewBox, so a caller can size a box to
/// the art's aspect ratio before it has loaded. Draw one with `UiArtImage`, or
/// from a `UiArtLibrary` raster in a dense grid; a Lottie slot reads it
/// through `UiArtImageSource` (`FxImageSlot.art`).
///
/// `ui_art_test` pins this list to the synced folder: a file with no value, or
/// a value with no file, fails.
enum UiArt {
  /// An earned star (`ui_stars`' `star_filled` slot; `StarRow`).
  starFilled('stars', 'star_filled', Size(96, 96)),

  /// An unearned star: the cream outline, never a grey fill (tokens
  /// `color.starEmpty` names this file).
  starEmpty('stars', 'star_empty', Size(96, 96)),

  /// The glow behind an earned star (`ui_stars`' `star_glow` slot).
  starGlow('stars', 'star_glow', Size(160, 160)),

  /// The milestone and day-7 chest, shut (`ui_chest`'s `chest_closed` slot,
  /// the day strip, the win card's chest row, Chapters' level-10 mark).
  chestClosed('chest', 'chest_closed', Size(180, 150)),

  /// The chest with its lid up (`ui_chest`'s `chest_open` slot).
  chestOpen('chest', 'chest_open', Size(180, 150)),

  /// A coin flying from the chest to the coin pill (§3.5 "Collect").
  coinFlight('sprites', 'coin_flight', Size(48, 48)),

  /// The hint flying from the chest to the Hint button.
  hintFlight('sprites', 'hint_flight', Size(48, 48)),

  /// The three computer rivals' portraits (Pebble, Button, Comet) and a
  /// locked rival's (frame 9.2).
  rival1('rivals', 'rival_1', Size(96, 96)),
  rival2('rivals', 'rival_2', Size(96, 96)),
  rival3('rivals', 'rival_3', Size(96, 96)),
  rivalLocked('rivals', 'rival_locked', Size(96, 96)),

  // The twelve badges (frame 10.6), earned and locked, in `BadgeId` order.
  badgeFirstFamily('badges', 'first_family', Size(96, 96)),
  badgeFirstFamilyLocked('badges', 'first_family_locked', Size(96, 96)),
  badgeGlassBreaker('badges', 'glass_breaker', Size(96, 96)),
  badgeGlassBreakerLocked('badges', 'glass_breaker_locked', Size(96, 96)),
  badgeIceMelter('badges', 'ice_melter', Size(96, 96)),
  badgeIceMelterLocked('badges', 'ice_melter_locked', Size(96, 96)),
  badgeTallOrder('badges', 'tall_order', Size(96, 96)),
  badgeTallOrderLocked('badges', 'tall_order_locked', Size(96, 96)),
  badgeGrandNest('badges', 'grand_nest', Size(96, 96)),
  badgeGrandNestLocked('badges', 'grand_nest_locked', Size(96, 96)),
  badgeLevel100('badges', 'level_100', Size(96, 96)),
  badgeLevel100Locked('badges', 'level_100_locked', Size(96, 96)),
  badgeLevel200('badges', 'level_200', Size(96, 96)),
  badgeLevel200Locked('badges', 'level_200_locked', Size(96, 96)),
  badgeDailies7('badges', 'dailies_7', Size(96, 96)),
  badgeDailies7Locked('badges', 'dailies_7_locked', Size(96, 96)),
  badgeDailies30('badges', 'dailies_30', Size(96, 96)),
  badgeDailies30Locked('badges', 'dailies_30_locked', Size(96, 96)),
  badgeFirstRace('badges', 'first_race', Size(96, 96)),
  badgeFirstRaceLocked('badges', 'first_race_locked', Size(96, 96)),
  badgeAllRivals('badges', 'all_rivals', Size(96, 96)),
  badgeAllRivalsLocked('badges', 'all_rivals_locked', Size(96, 96)),
  badgeMuseumFull('badges', 'museum_full', Size(96, 96)),
  badgeMuseumFullLocked('badges', 'museum_full_locked', Size(96, 96));

  const UiArt(this.folder, this.fileName, this.viewBox);

  /// Where `sync_design_assets` writes `design/ui/**`.
  static const assetDirectory = 'assets/ui';

  /// The subfolder of [assetDirectory] (`stars`, `chest`, `sprites`,
  /// `rivals`, `badges`).
  final String folder;

  /// The file's base name, without `.svg`.
  final String fileName;

  /// The SVG's viewBox size, in its own units: the art's aspect ratio.
  final Size viewBox;

  /// `assets/ui/<folder>/<fileName>.svg`.
  String get assetPath => '$assetDirectory/$folder/$fileName.svg';

  /// Width ÷ height of [viewBox].
  double get aspectRatio => viewBox.width / viewBox.height;

  /// The art of [badge]: its earned face, or the locked one (frame 10.6).
  static UiArt badge(BadgeId badge, {required bool earned}) {
    final (onArt, offArt) = switch (badge) {
      BadgeId.firstFamily => (badgeFirstFamily, badgeFirstFamilyLocked),
      BadgeId.glassBreaker => (badgeGlassBreaker, badgeGlassBreakerLocked),
      BadgeId.iceMelter => (badgeIceMelter, badgeIceMelterLocked),
      BadgeId.tallOrder => (badgeTallOrder, badgeTallOrderLocked),
      BadgeId.grandNest => (badgeGrandNest, badgeGrandNestLocked),
      BadgeId.level100 => (badgeLevel100, badgeLevel100Locked),
      BadgeId.level200 => (badgeLevel200, badgeLevel200Locked),
      BadgeId.dailies7 => (badgeDailies7, badgeDailies7Locked),
      BadgeId.dailies30 => (badgeDailies30, badgeDailies30Locked),
      BadgeId.firstRace => (badgeFirstRace, badgeFirstRaceLocked),
      BadgeId.allRivals => (badgeAllRivals, badgeAllRivalsLocked),
      BadgeId.museumFull => (badgeMuseumFull, badgeMuseumFullLocked),
    };
    return earned ? onArt : offArt;
  }

  /// The portrait of computer rival [number] (1–3), or the locked portrait
  /// for null or any other number (frame 9.2's locked card).
  static UiArt rival(int? number) => switch (number) {
    1 => rival1,
    2 => rival2,
    3 => rival3,
    _ => rivalLocked,
  };
}
