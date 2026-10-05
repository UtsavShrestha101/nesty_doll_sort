import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The glow ring a chest's flights light around their target while sprites
/// land (tokens.json `motion.chest.collect.pillRing` and `hintRing`, m7-4
/// 1.7; frame 10.3d):
///
/// - [RewardRing.pill] is the HUD's coin pill's: the pill's own rectangle
///   with `0 0 0 4px rgba(255,214,110,.8), 0 0 18px 6px rgba(255,205,80,.6)`
///   round it, in over 80 ms and out over 240 ms;
/// - [RewardRing.hint] is the Hint badge's: a 38 dp circle centred on the
///   badge with `0 0 0 3px #FFE08A, 0 0 14px 4px rgba(255,205,80,.7)`, on
///   the same fade.
///
/// It never changes the child's layout. Under reduced motion (the flights
/// don't fly) it paints nothing.
class RewardRing extends StatefulWidget {
  /// The coin pill's ring: the child's own box.
  const RewardRing.pill({required this.visible, required this.child, super.key})
    : _hint = false;

  /// The Hint badge's ring: [ChestCollectTokens.hintRingSize], centred on
  /// the child.
  const RewardRing.hint({required this.visible, required this.child, super.key})
    : _hint = true;

  final bool visible;
  final Widget child;
  final bool _hint;

  /// The ring while it is shown or fading, for tests.
  static const Key ringKey = Key('reward-ring');

  /// The ring's fade-in (`pillRing.inMs`).
  static const Duration fadeIn = Duration(
    milliseconds: ChestCollectTokens.pillRingInMs,
  );

  /// The ring's fade-out (`pillRing.outMs`).
  static const Duration fadeOut = Duration(
    milliseconds: ChestCollectTokens.pillRingOutMs,
  );

  static List<BoxShadow> _shadows(List<NestyShadow> shadows) => [
    for (final shadow in shadows) shadow.toBoxShadow(),
  ];

  @override
  State<RewardRing> createState() => _RewardRingState();
}

class _RewardRingState extends State<RewardRing> {
  /// The ring joins the tree the first time it shows and stays (at opacity
  /// 0) so its fade-out can run; until then a booster's badge carries
  /// nothing extra.
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    if (context.reduceMotion) return child;
    if (widget.visible) _shown = true;
    if (!_shown) return child;
    final visible = widget.visible;
    final ring = widget._hint
        ? OverflowBox(
            minWidth: ChestCollectTokens.hintRingSize,
            maxWidth: ChestCollectTokens.hintRingSize,
            minHeight: ChestCollectTokens.hintRingSize,
            maxHeight: ChestCollectTokens.hintRingSize,
            child: DecoratedBox(
              key: RewardRing.ringKey,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: RewardRing._shadows(
                  ChestCollectTokens.hintRingShadow,
                ),
              ),
            ),
          )
        : DecoratedBox(
            key: RewardRing.ringKey,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: RewardRing._shadows(ChestCollectTokens.pillRingShadow),
            ),
          );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: visible ? RewardRing.fadeIn : RewardRing.fadeOut,
              child: ring,
            ),
          ),
        ),
      ],
    );
  }
}
