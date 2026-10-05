import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/feedback/nesty_banner.dart';
import 'package:nesty_game/core/ui/widgets/feedback/toast_queue.dart';

export 'package:nesty_game/core/ui/widgets/feedback/nesty_banner.dart'
    show NestyBanner, NestyBannerTone;
export 'package:nesty_game/core/ui/widgets/feedback/toast_queue.dart'
    show
        ToastCard,
        ToastHost,
        ToastPill,
        ToastPlacement,
        ToastQueue,
        ToastSpec,
        ToastTone;

/// A transient toast (tokens.json `toast.app`, m7-4 1.5; frame 5.2 "Streak
/// saved!", frame 8.3 "Purchases restored"): a [ToastCard] in the app
/// geometry, 40 dp icon disc.
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

  static const double iconSize = ToastLayoutTokens.appIcon;

  /// tokens.json `motion.toast.autoDismissMs` (2.5 s; Q136).
  static const Duration defaultDuration = ToastSpec.defaultDuration;

  /// The [ToastTone] a banner tone's toast takes in a [ToastHost]'s queue.
  static ToastTone toneOf(NestyBannerTone tone) => switch (tone) {
    NestyBannerTone.success => ToastTone.success,
    NestyBannerTone.info => ToastTone.info,
    NestyBannerTone.warning || NestyBannerTone.danger => ToastTone.warning,
  };

  @override
  Widget build(BuildContext context) => ToastCard(
    placement: ToastPlacement.app,
    spec: ToastSpec(
      tone: toneOf(tone),
      icon: icon,
      title: title,
      message: message,
    ),
  );

  /// Queues the toast on the nearest [ToastHost] (the app root's, or a
  /// result card's own): one at a time, [duration] each, 300 ms apart, at
  /// the host's top (phase 4 architecture §3.12). [margin] is ignored
  /// there.
  ///
  /// With no host above [context] (a widget test's bare page) it inserts an
  /// [Overlay] entry instead, fading in and out over `motion.ui.modalIn`
  /// and dismissing itself after [duration] (respecting reduced motion),
  /// placed by [margin] (frames 5.2/8.3: left/right 16, 4 dp under the safe
  /// top).
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
      top: ToastLayoutTokens.appTopBelowSafeTop,
    ),
  }) {
    final queue = ToastHost.maybeOf(context);
    if (queue != null) {
      queue.enqueue(
        ToastSpec(
          tone: toneOf(tone),
          icon: icon,
          title: title,
          message: message,
          duration: duration,
        ),
      );
      return;
    }
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

  /// Starts the fade-out after the toast's duration. Held so [dispose] can
  /// cancel it: a tree torn down first (a win card closing over its badge
  /// toasts) must not leave a timer behind.
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    // Fades in on the next frame instead of at build time, so the
    // AnimatedOpacity actually animates from 0.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    _dismissTimer = Timer(widget.duration, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
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
              // The entry sits in the navigator's Overlay, outside every
              // page's Material, where the inherited text style is
              // MaterialApp's fallback (a yellow double underline): give the
              // toast the body style a page's Material gives it
              // (AppTheme's bodyMedium).
              child: DefaultTextStyle(
                style: context.scriptStyle(
                  AppTextStyles.bodySmall,
                  role: ScriptTextRole.body,
                ),
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
    ),
  );
}
