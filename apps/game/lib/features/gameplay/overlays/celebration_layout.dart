import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// Which card the win overlay draws (ui-spec-game §2.2; frames 2.8, 11.2–11.2d,
/// 11.4–11.4c, 12.4).
enum CelebrationVariant {
  /// A campaign win with stars: the ribbon, `ui_stars`, the plank, the coin
  /// and moves chips, the progress card, the note or tip, Continue
  /// (`layout.winStars`).
  campaign,

  /// A replay from Chapters: no coin chip, the reason card in the progress
  /// card's place, Back to Chapters (`layout.replayCard`).
  replay,

  /// No stars (Bonus Endless 12.4, the Daily 5.4): the older card, with the
  /// plank at 350 and the dolls at 104 (NestyMeta `PLAIN`).
  plain,
}

/// Every y of a win card on the 390×844 reference with its 59 dp safe area
/// (ui-spec-game §1 "CelebrationLayout"; `WinStarsTokens`,
/// `WinStarsShortTokens`, `ReplayCardTokens`), as one function per variant so
/// the win card and its tests read one table.
///
/// A y is a screen y; the card's content starts below the safe area's top
/// ([designSafeTop] on the reference), so a widget places itself at
/// `y − designSafeTop`.
@immutable
final class CelebrationLayout {
  const CelebrationLayout({
    required this.ribbonCanvasTop,
    required this.starsTop,
    required this.plankTop,
    required this.dollHeight,
    required this.chipsTop,
    required this.cardTop,
    required this.noteTop,
    required this.buttonsTop,
  });

  /// The layout for [variant] on a screen [screenHeight] tall (the 16:9
  /// `winStarsShort` values below [shortBelow], for the campaign card).
  factory CelebrationLayout.of(
    CelebrationVariant variant, {
    required double screenHeight,
    required int families,
  }) {
    switch (variant) {
      case CelebrationVariant.campaign:
        if (screenHeight < shortBelow) {
          return _short;
        }
        return _campaign;
      case CelebrationVariant.replay:
        return _replay;
      case CelebrationVariant.plain:
        return CelebrationLayout(
          ribbonCanvasTop: _ribbonCanvasTop,
          starsTop: null,
          plankTop: 350,
          dollHeight: families > 4 ? 88 : 104,
          chipsTop: 404,
          cardTop: 484,
          noteTop: null,
          buttonsTop: 630,
        );
    }
  }

  /// The design's safe-area top the y values are measured on.
  static const double designSafeTop = 59;

  /// A screen shorter than this is the 16:9 reference (390×693): the
  /// `winStarsShort` card, with no note or tip (C11).
  static const double shortBelow = 760;

  /// `ui_win_ribbon`'s 410×110 canvas top: its band's centre stays at y 150
  /// on every card, as before (`WinOverlay.ribbonCenter`).
  static const double _ribbonCanvasTop = 95;

  /// The base of a doll standing on the plank: 11 below the plank's top.
  static const double dollBaseBelowPlank = 11;

  /// The plank's height.
  static const double plankHeight = 30;

  static const CelebrationLayout _campaign = CelebrationLayout(
    ribbonCanvasTop: _ribbonCanvasTop,
    starsTop: WinStarsTokens.starsCanvasTop,
    plankTop: WinStarsTokens.plankTop,
    dollHeight: WinStarsTokens.hopDollHeight,
    chipsTop: WinStarsTokens.coinRowTop,
    cardTop: WinStarsTokens.progressTop,
    noteTop: WinStarsTokens.notePillTop,
    buttonsTop: WinStarsTokens.buttonsTop,
  );

  static const CelebrationLayout _short = CelebrationLayout(
    // The ribbon band's top is `ribbonTop` (70 short, 118 tall); its canvas
    // starts 23 above the band.
    ribbonCanvasTop: WinStarsShortTokens.ribbonTop - 23,
    starsTop: WinStarsShortTokens.starsCanvasTop,
    plankTop: WinStarsShortTokens.plankTop,
    dollHeight: WinStarsShortTokens.hopDollHeight,
    chipsTop: WinStarsShortTokens.coinRowTop,
    cardTop: WinStarsShortTokens.progressTop,
    noteTop: null,
    buttonsTop: WinStarsShortTokens.buttonsTop,
  );

  static const CelebrationLayout _replay = CelebrationLayout(
    ribbonCanvasTop: _ribbonCanvasTop,
    starsTop: WinStarsTokens.starsCanvasTop,
    plankTop: WinStarsTokens.plankTop,
    dollHeight: WinStarsTokens.hopDollHeight,
    chipsTop: ReplayCardTokens.movesRowTop,
    cardTop: ReplayCardTokens.cardTop,
    noteTop: ReplayCardTokens.tipTop,
    buttonsTop: ReplayCardTokens.buttonTop,
  );

  /// The ribbon canvas' top y.
  final double ribbonCanvasTop;

  /// `ui_stars`' canvas top; null for a card without stars.
  final double? starsTop;

  /// The plank's top y (the dolls stand on it).
  final double plankTop;

  /// The hopping dolls' height.
  final double dollHeight;

  /// The coin and moves chips' row top (the moves chip alone on a replay).
  final double chipsTop;

  /// The progress card's top (the reason card's on a replay).
  final double cardTop;

  /// The note or tip pill's top; null where none shows (the short card, a
  /// card without stars).
  final double? noteTop;

  /// Where the button column starts (Continue takes the first slot while
  /// the ×3 button is absent, C12).
  final double buttonsTop;

  /// Whether this card draws stars.
  bool get hasStars => starsTop != null;

  /// A y as an offset below the safe area's top.
  static double below(double y) => y - designSafeTop;

  /// The gap between the card's bottom and the note pill's top when the card
  /// is at its natural height (602 − 500 − the card's 86).
  static const double noteGap = 16;

  /// The height of the block above the button when nothing grows: from the
  /// safe area's top to [buttonsTop].
  double get blockHeight => below(buttonsTop);
}
