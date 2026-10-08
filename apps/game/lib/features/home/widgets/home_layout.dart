import 'dart:math' as math;

import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// Where Home's blocks sit on a screen (frames 2.1 and 2.1b; tokens
/// `layout.home` and `layout.homeShort`), in dp from the top of the safe
/// area.
///
/// The frames give two screens: 390×844 (the body ends at the nav, y 738) and
/// 390×693 (a 16:9 phone, nav at 587). Between them, and below, every number
/// is interpolated on the body's height, so Home moves smoothly through every
/// phone; under the short frame's body the remaining squeeze is the caller's
/// (the hero scales down into what is left). Menus spec 1.1's proposed rule
/// ("the 844 numbers until the gap between Play and the tiles is under 24")
/// gives the same two ends; the blend just avoids a jump between them
/// (BACKLOG "Home between 700 and 844 dp").
class HomeLayout {
  const HomeLayout._({
    required this.t,
    required this.chapterCardTop,
    required this.plankTop,
    required this.playTop,
    required this.playHeight,
    required this.tilesTop,
    required this.tilesHeight,
    required this.dollScale,
  });

  /// The design's status bar in each frame: everything is measured from it.
  static const double _tallStatusBar = 59;
  static const double _shortStatusBar = HomeShortTokens.statusBar;

  /// The body's height under the safe area in each frame (nav's y minus its
  /// status bar).
  static const double _tallBody = HomeTokens.bottomNav - _tallStatusBar;
  static const double _shortBody = HomeShortTokens.bottomNav - _shortStatusBar;

  /// 0 on the tall frame's body, 1 on the short one's (clamped).
  final double t;

  /// Below the safe area's top.
  final double chapterCardTop;
  final double plankTop;
  final double playTop;
  final double playHeight;
  final double tilesTop;
  final double tilesHeight;

  /// The dolls' scale on the plank (`HomeShortTokens.dollScale` at 1).
  final double dollScale;

  /// The layout for a body [bodyHeight] tall under the safe area.
  factory HomeLayout.forBody(double bodyHeight) {
    final t = ((_tallBody - bodyHeight) / (_tallBody - _shortBody)).clamp(
      0.0,
      1.0,
    );
    double lerp(double tall, double short) => tall + (short - tall) * t;
    return HomeLayout._(
      t: t,
      chapterCardTop: lerp(
        HomeTokens.chapterCardTop - _tallStatusBar,
        HomeShortTokens.chapterCard - _shortStatusBar,
      ),
      plankTop: lerp(
        HomeTokens.plankTop - _tallStatusBar,
        HomeShortTokens.plankTop - _shortStatusBar,
      ),
      playTop: lerp(
        HomeTokens.playButtonTop - _tallStatusBar,
        HomeShortTokens.playButtonTop - _shortStatusBar,
      ),
      playHeight: lerp(
        HomeTokens.playButtonHeight,
        HomeShortTokens.playButtonHeight,
      ),
      tilesTop: lerp(
        HomeTokens.tilesTop - _tallStatusBar,
        HomeShortTokens.tilesTop - _shortStatusBar,
      ),
      tilesHeight: lerp(HomeTokens.tilesHeight, HomeShortTokens.tilesHeight),
      dollScale: lerp(1, HomeShortTokens.dollScale),
    );
  }

  /// Where the welcome-back card sits: 74 dp under the chapter card's top
  /// (frame 14.1a: 198 on 844, 158 on 693), so the blend is the chapter
  /// card's own (tokens `habits.welcomeBack.place`).
  double get welcomeCardTop =>
      chapterCardTop + HabitsWelcomeTokens.placeBelowChapterCardTop;

  /// The tallest doll's box, at scale 1, that makes the rule give the
  /// design's 0.78 on the 844 frame: (plank base 384 - card bottom 198 + 84
  /// - clearance 8) / 0.78.
  static const double _tallestDollBox =
      (HomeTokens.plankTop +
          12 -
          (HomeTokens.chapterCardTop +
              HabitsWelcomeTokens.placeBelowChapterCardTop +
              HabitsWelcomeTokens.cardMinHeight) -
          HabitsWelcomeTokens.placeDollClearance) /
      HabitsWelcomeTokens.placeH844DollScale;

  /// The dolls' scale and opacity while the welcome card, [cardHeight] tall,
  /// stands above the plank: they scale about the plank so the tallest
  /// clears the card by 8 dp, and below 0.6 they fade out (opacity 0) and
  /// the empty plank stays. Only the dolls move. [scale] is then the
  /// layout's own, so they fade back in without a size change.
  ({double scale, double opacity}) dollsUnder(double cardHeight) {
    final room =
        plankTop +
        12 -
        (welcomeCardTop + cardHeight) -
        HabitsWelcomeTokens.placeDollClearance;
    final fit = math.min(dollScale, room / _tallestDollBox);
    if (fit < HabitsWelcomeTokens.placeDollFadeBelow) {
      return (scale: dollScale, opacity: 0);
    }
    return (scale: fit, opacity: 1);
  }

  /// The hero block's top: the twinkles start 192 dp above the plank in the
  /// tall frame; kept at the plank's own offset so they scale with it.
  double get heroTop => plankTop - 192;

  /// The hero block's bottom: the PLAY button's edge and shadow (18 dp).
  double get heroBottom => playTop + playHeight + 18;

  /// The chapter card and the Records button share this height at 1×.
  static const double cardHeight = HomeTokens.chapterCardHeight;

  /// The least room kept under the tiles when the body is shorter than the
  /// short frame's: the tiles then sit this far above the body's bottom.
  static const double tilesBottomGap = 12;

  /// The tiles' top for a body [bodyHeight] tall, never lower than the body
  /// lets them sit ([tilesBottomGap] above its bottom).
  double tilesTopIn(double bodyHeight) =>
      math.min(tilesTop, bodyHeight - tilesBottomGap - tilesHeight);
}
