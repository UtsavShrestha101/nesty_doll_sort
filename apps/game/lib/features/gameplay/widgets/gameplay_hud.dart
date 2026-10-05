import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/booster/bump_scale.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/widgets/family_counter.dart';

/// The gameplay HUD (frame 2.2; NestyBoard; spec §10.2 #3), laid out from
/// the safe-area top: the pause button at (16, top + 3), the coin pill at
/// the right edge (top + 7), the level pill centred (top + 3) and the
/// family counter under it, centred on top + 70.
///
/// The level pill gets whatever the side controls leave
/// (`W − 2 · max(side widths) − 16`) and scales its content down to fit,
/// so a long translation at 1.3× text never collides with them (earlier
/// M2 design §2 "GameplayPage stack").
///
/// In a race the [raceStrip] takes the top row instead of the level and
/// coin pills (frame 9.3; tokens `layout.rivalStrip`: left 76, right 16,
/// top 62, 48 tall), and takes no touch: the board below it keeps its taps
/// (phase 4 architecture §6.6). The family counter stays under it.
class GameplayHud extends StatelessWidget {
  const GameplayHud({
    required this.level,
    required this.tier,
    required this.coins,
    required this.setsDone,
    required this.setsTotal,
    required this.onPause,
    this.sparkleScale = FamilyCounter.defaultSparkleScale,
    this.locked = false,
    this.bonusNumber,
    this.dailyDateLabel,
    this.raceStrip,
    this.familyCounterHidden = false,
    this.library,
    this.coinPillKey,
    this.coinBump = 0,
    this.coinRing = false,
    super.key,
  });

  final int level;
  final Tier tier;
  final int coins;

  /// Set for Bonus Endless (`PlayRequest.bonus`): the level pill shows
  /// "Bonus Level N" (frame 4.10) instead of [level]/[tier].
  final int? bonusNumber;

  /// Set for the daily puzzle (`PlayRequest.daily`): the level pill shows
  /// the calendar glyph and this formatted date (frame 5.3) instead of
  /// [level]/[tier]. Takes priority over [bonusNumber].
  final String? dailyDateLabel;

  /// A vs Computer race's rival strip (frame 9.3; lane R's `RivalStrip`),
  /// laid out in the top row in place of the level and coin pills, or null
  /// off a race. It gets the row's width and sizes its own height (48 in the
  /// design); a taller one scales down to the row. Wrapped in an
  /// `IgnorePointer` here.
  final Widget? raceStrip;

  /// Fades the family counter out (150 ms) while a hint's arrow over the
  /// middle top-shelf stand needs its place (frame 3.1b; the board's
  /// `GameplayBoard.familyCounterYield`), and back in when it clears
  /// (`layout.hintMiddle`: 150 ms each way; a cut under reduce motion).
  final bool familyCounterHidden;

  /// The counter as the board has shown it (sets that have landed).
  final int setsDone;
  final int setsTotal;

  /// The sparkle over the counter when a family lands, × the trail's
  /// (LOTTIE.md "Completed").
  final double sparkleScale;

  /// Null while pausing isn't possible (an overlay is open).
  final VoidCallback? onPause;

  /// While the won level locks input: the pause button keeps its look but
  /// takes no touch (review FIDELITY-2).
  final bool locked;

  /// The FX library (DI by default), for the counter's Lottie.
  final FxLibrary? library;

  /// Marks the coin pill's on-screen rect (`gameplay_view.dart`'s
  /// `_coinPillRect`), so the milestone chest modal's Collect step can fly
  /// coin sprites to it (m7-design chest sequence step 4). Null when
  /// nothing needs to find it.
  final GlobalKey? coinPillKey;

  /// The coin pill bumps (1.3× for 240 ms) each time
  /// this changes: a chest's coin sprite landed on it (frame 10.3d).
  final int coinBump;

  /// The ring round the coin pill while the chest's coins land.
  final bool coinRing;

  /// The HUD's height below the safe-area top: down to the counter canvas'
  /// bottom (top + 70 + 30).
  static const double height = 100;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final strip = raceStrip;
    return SizedBox(
      height: top + height,
      child: CustomMultiChildLayout(
        delegate: _HudLayout(top: top, race: strip != null),
        children: [
          LayoutId(
            id: _HudSlot.pause,
            child: IgnorePointer(
              ignoring: locked,
              child: IconTactileButton(
                icon: NestyIcons.pause,
                semanticLabel: context.localizations.pause,
                onPressed: onPause,
                size: HudTokens.pauseButtonSize.width,
              ),
            ),
          ),
          if (strip != null)
            LayoutId(
              id: _HudSlot.strip,
              // The row is 48 tall; a taller strip (a long name at 1.3×
              // text) scales down to it instead of overflowing.
              child: IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, constraints) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: SizedBox(width: constraints.maxWidth, child: strip),
                  ),
                ),
              ),
            )
          else ...[
            LayoutId(
              id: _HudSlot.coins,
              // A huge balance at 1.3× text shrinks rather than overflow.
              child: BumpScale(
                trigger: coinBump,
                child: RewardRing.pill(
                  visible: coinRing,
                  child: FittedBox(
                    key: coinPillKey,
                    fit: BoxFit.scaleDown,
                    child: CoinPill(coins: coins),
                  ),
                ),
              ),
            ),
            LayoutId(id: _HudSlot.level, child: _levelPill()),
          ],
          LayoutId(
            id: _HudSlot.counter,
            child: IgnorePointer(
              // Frame 3.1b: out over 150 ms, back in over 150 ms.
              child: AnimatedOpacity(
                opacity: familyCounterHidden ? 0 : 1,
                duration: Duration(
                  milliseconds: context.reduceMotion
                      ? 0
                      : familyCounterHidden
                      ? HintMiddleTokens.familyCounterFadeOutMs
                      : HintMiddleTokens.familyCounterFadeInMs,
                ),
                child: FamilyCounter(
                  done: setsDone,
                  total: setsTotal,
                  sparkleScale: sparkleScale,
                  library: library,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The level pill (frames 2.2, 4.10, 5.3): the daily's date chip, else
  /// Bonus Endless's "Bonus Level N", else the normal level/tier pill. A
  /// replay shows the plain pill: its "Replay" tag is gone, since it looked
  /// like a button that did nothing and the win card already says a replay
  /// pays no coins (owner, 2026-09-29, D170).
  Widget _levelPill() {
    final dailyDateLabel = this.dailyDateLabel;
    final bonusNumber = this.bonusNumber;
    if (dailyDateLabel != null) {
      return LevelPill.daily(dateLabel: dailyDateLabel);
    }
    if (bonusNumber != null) return LevelPill.bonus(level: bonusNumber);
    return LevelPill(level: level, tier: tier);
  }
}

enum _HudSlot { pause, coins, level, strip, counter }

final class _HudLayout extends MultiChildLayoutDelegate {
  _HudLayout({required this.top, required this.race});

  final double top;

  /// The rival strip replaces the coin and level pills.
  final bool race;

  static const _side = HudTokens.side;

  /// NestyBoard: pause and pill at top 62, the coin pill at 66, on a 59
  /// safe area.
  static const _pillTop = HudTokens.top - 59;
  static const _coinTop = 7.0;

  /// The counter centre: (195, 129) on the reference screen.
  static const _counterCenter = 70.0;

  /// The level pill keeps this gap to each side control.
  static const _pillGap = 8.0;

  @override
  void performLayout(Size size) {
    final width = size.width;
    final pause = layoutChild(_HudSlot.pause, BoxConstraints.loose(size));
    positionChild(_HudSlot.pause, Offset(_side, top + _pillTop));

    if (race) {
      // tokens `layout.rivalStrip`: x 76 to W − 16, top 62, 48 tall.
      final stripWidth = math.max(
        0.0,
        width - RivalStripTokens.left - RivalStripTokens.right,
      );
      layoutChild(
        _HudSlot.strip,
        BoxConstraints.tightFor(
          width: stripWidth,
          height: RivalStripTokens.height,
        ),
      );
      positionChild(
        _HudSlot.strip,
        Offset(RivalStripTokens.left, top + RivalStripTokens.top - 59),
      );
      _layoutCounter(width);
      return;
    }

    // The coins may take up to a third of the width (a huge balance at
    // 1.3× text scales down inside the pill).
    final coins = layoutChild(
      _HudSlot.coins,
      BoxConstraints(maxWidth: width / 3, maxHeight: size.height),
    );
    positionChild(
      _HudSlot.coins,
      Offset(width - _side - coins.width, top + _coinTop),
    );

    // The pill is centred while it fits between the controls at their
    // wider one's width (the frames' look). A long tier name or a wide
    // balance would shrink it to nothing there, so it may take the free
    // width on its own side instead: it then sits against the narrower
    // control rather than at the centre (5B-5; build/m7-p5/reports/5b-og.md).
    final left = _side + pause.width + _pillGap;
    final right = width - _side - coins.width - _pillGap;
    final side = _side + math.max(pause.width, coins.width);
    final pillMax = math.max(0.0, right - left);
    final pill = layoutChild(
      _HudSlot.level,
      BoxConstraints(maxWidth: pillMax, maxHeight: size.height),
    );
    final centred = (width - pill.width) / 2;
    final fitsCentred = pill.width <= width - 2 * side - 2 * _pillGap;
    positionChild(
      _HudSlot.level,
      Offset(
        fitsCentred ? centred : centred.clamp(left, right - pill.width),
        top + _pillTop,
      ),
    );

    _layoutCounter(width);
  }

  void _layoutCounter(double width) {
    const canvas = FamilyCounter.canvas;
    layoutChild(_HudSlot.counter, BoxConstraints.tight(canvas));
    positionChild(
      _HudSlot.counter,
      Offset(
        (width - canvas.width) / 2,
        top + _counterCenter - canvas.height / 2,
      ),
    );
  }

  @override
  bool shouldRelayout(_HudLayout oldDelegate) =>
      oldDelegate.top != top || oldDelegate.race != race;
}
