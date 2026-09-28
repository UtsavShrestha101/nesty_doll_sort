import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
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
    this.library,
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

  /// The HUD's height below the safe-area top: down to the counter canvas'
  /// bottom (top + 70 + 30).
  static const double height = 100;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: top + height,
      child: CustomMultiChildLayout(
        delegate: _HudLayout(top: top),
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
          LayoutId(
            id: _HudSlot.coins,
            // A huge balance at 1.3× text shrinks rather than overflow.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: CoinPill(coins: coins),
            ),
          ),
          LayoutId(id: _HudSlot.level, child: _levelPill()),
          LayoutId(
            id: _HudSlot.counter,
            child: IgnorePointer(
              child: FamilyCounter(
                done: setsDone,
                total: setsTotal,
                sparkleScale: sparkleScale,
                library: library,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The level pill (frames 2.2, 4.10, 5.3): the daily's date chip, else
  /// Bonus Endless's "Bonus Level N", else the normal level/tier pill.
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

enum _HudSlot { pause, coins, level, counter }

final class _HudLayout extends MultiChildLayoutDelegate {
  _HudLayout({required this.top});

  final double top;

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

    final side = _side + math.max(pause.width, coins.width);
    final pillMax = math.max(0.0, width - 2 * side - 2 * _pillGap);
    final pill = layoutChild(
      _HudSlot.level,
      BoxConstraints(maxWidth: pillMax, maxHeight: size.height),
    );
    positionChild(
      _HudSlot.level,
      Offset((width - pill.width) / 2, top + _pillTop),
    );

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
  bool shouldRelayout(_HudLayout oldDelegate) => oldDelegate.top != top;
}
