import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/feedback/nesty_banner.dart';

export 'package:nesty_game/core/ui/widgets/feedback/nesty_banner.dart'
    show NestyBanner, NestyBannerTone;

/// A transient banner ("Banners / toasts", design/README.md "Components";
/// frame 5.2 "Streak saved!", frame 8.3 "Purchases restored"): the same
/// [NestyBanner] look at its bigger 40 px icon disc.
///
/// Use [NestyToast.show] to display it as a self-dismissing overlay; build
/// it directly (as any [NestyBanner]) to lay it out inline in a widget test.
class NestyToast extends StatelessWidget {
  const NestyToast({
    required this.tone,
    required this.icon,
    required this.title,
    this.message,
    super.key,
  });

  final NestyBannerTone tone;
  final IconData icon;
  final String title;
  final String? message;

  static const double iconSize = 40;

  /// No frame times the auto-dismiss.
  /// TODO(design): picked a readable default; ask the owner for the real one.
  static const Duration defaultDuration = Duration(seconds: 3);

  @override
  Widget build(BuildContext context) => NestyBanner(
    tone: tone,
    icon: icon,
    title: title,
    message: message,
    iconSize: iconSize,
  );

  /// Inserts the toast above [context] (an [Overlay] entry, so it survives
  /// the caller's own rebuilds), fading in and out over
  /// `motion.ui.modalIn` and dismissing itself after [duration] (respecting
  /// reduced motion). The caller positions it with [margin] (frames 5.2/8.3:
  /// left/right 16, top 58, clear of the header).
  static void show(
    BuildContext context, {
    required NestyBannerTone tone,
    required IconData icon,
    required String title,
    String? message,
    Duration duration = defaultDuration,
    EdgeInsetsGeometry margin = const EdgeInsetsDirectional.only(
      start: 16,
      end: 16,
      top: 58,
    ),
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastOverlayItem(
        tone: tone,
        icon: icon,
        title: title,
        message: message,
        duration: duration,
        margin: margin,
        onDismissed: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _ToastOverlayItem extends StatefulWidget {
  const _ToastOverlayItem({
    required this.tone,
    required this.icon,
    required this.title,
    required this.message,
    required this.duration,
    required this.margin,
    required this.onDismissed,
  });

  final NestyBannerTone tone;
  final IconData icon;
  final String title;
  final String? message;
  final Duration duration;
  final EdgeInsetsGeometry margin;
  final VoidCallback onDismissed;

  @override
  State<_ToastOverlayItem> createState() => _ToastOverlayItemState();
}

class _ToastOverlayItemState extends State<_ToastOverlayItem> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Fades in on the next frame instead of at build time, so the
    // AnimatedOpacity actually animates from 0.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    Future<void>.delayed(widget.duration, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  int _fadeMs(BuildContext context) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return (UiMotionTokens.modalInMs *
            (reduced ? UiMotionTokens.reducedMotionDurationScale : 1))
        .round();
  }

  @override
  Widget build(BuildContext context) => Positioned(
    left: 0,
    right: 0,
    top: 0,
    child: SafeArea(
      child: Padding(
        padding: widget.margin,
        child: IgnorePointer(
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: Duration(milliseconds: _fadeMs(context)),
            curve: UiMotionTokens.curveEaseOut,
            onEnd: () {
              if (!_visible) widget.onDismissed();
            },
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0, -0.3),
              duration: Duration(milliseconds: _fadeMs(context)),
              curve: UiMotionTokens.curveEaseOut,
              child: NestyToast(
                tone: widget.tone,
                icon: widget.icon,
                title: widget.title,
                message: widget.message,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
