import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// Frame 3.4's soft-stuck banner (spec §2.3): "Hmm, this looks stuck /
/// Try Undo? You can keep playing too." with an Undo button, over the top
/// shelf (NestyBoard: left/right 20, top 152 on a 59 safe area; the caller
/// places it).
///
/// It never blocks the board: only its own box takes touches, and none
/// while hidden. It slides and fades in when [visible] turns on, and out
/// when the next board change clears the bloc's `softStuck`
/// (`tokens.motion.ui`, halved under reduced motion).
///
/// With nothing to undo ([onUndo] null: a completing move cleared the
/// history, spec §2.4) it is frame 12.7's warn toast: "Try Restart? You can
/// keep playing too." with no button of its own, since Restart glows in the
/// booster bar (`BoosterBarModel.restartGlow`) instead of a dead Undo
/// (review FIDELITY-6). What it suggests is fixed while it shows and while
/// it slides out, so its copy never changes under the player's eyes.
class SoftStuckBanner extends StatefulWidget {
  const SoftStuckBanner({
    required this.visible,
    required this.onUndo,
    super.key,
  });

  final bool visible;

  /// Null when there is nothing to undo: the toast then suggests Restart.
  final VoidCallback? onUndo;

  /// The banner's top below the safe-area top (152 − 59).
  static const double top = 93;

  static const double side = 20;

  @override
  State<SoftStuckBanner> createState() => _SoftStuckBannerState();
}

class _SoftStuckBannerState extends State<SoftStuckBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: widget.visible ? 1 : 0,
  )..addStatusListener((_) => setState(() {}));

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: UiMotionTokens.curveEaseOut,
    reverseCurve: UiMotionTokens.curveEaseIn,
  );

  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -0.25),
    end: Offset.zero,
  ).animate(_curve);

  /// Suggests Restart instead of Undo: chosen when the banner shows, kept
  /// until it has slid out.
  late bool _restart = _suggestsRestart(widget);

  /// The button's action, followed while the banner shows and kept while
  /// it slides out (it takes no touch then), so the button doesn't grey out
  /// on its way out either.
  late VoidCallback? _action = widget.onUndo;

  static bool _suggestsRestart(SoftStuckBanner banner) => banner.onUndo == null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = context.uiDuration(UiMotionTokens.modalInMs);
  }

  @override
  void didUpdateWidget(SoftStuckBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible) {
      if (!oldWidget.visible || _controller.isDismissed) {
        _restart = _suggestsRestart(widget);
      }
      _action = widget.onUndo;
    }
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isDismissed) return const SizedBox.shrink();
    final l10n = context.localizations;
    return IgnorePointer(
      ignoring: !widget.visible,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _curve,
          child: NestyBanner(
            tone: NestyBannerTone.warning,
            icon: NestyIcons.sentimentNeutral,
            title: l10n.softStuckTitle,
            message: _restart ? l10n.softStuckBodyRestart : l10n.softStuckBody,
            action: _restart
                ? null
                : TactileButton(
                    label: l10n.softStuckAction,
                    icon: NestyIcons.undo,
                    size: TactileButtonSize.compact,
                    expand: false,
                    // The compact face in a full 48 dp target (review R20).
                    minTouchSize: const Size.square(48),
                    onPressed: _action,
                  ),
          ),
        ),
      ),
    );
  }
}
