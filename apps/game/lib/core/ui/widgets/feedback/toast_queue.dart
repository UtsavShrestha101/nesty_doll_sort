import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// A toast's kind and colours (ui-spec-game §1 "Toast"; frames 10.6, 10.9,
/// 12.7, 12.9): the card's face, its edge and the lead disc. Warning is the
/// tokens' own; the others are frame-only.
enum ToastTone {
  // TODO(design): success, info and badge are frame-only colours (NestyMeta);
  // ask Claude Design to add them to tokens.json `color`.

  /// "Reminder set", relaxed mode, a race's rival unlocked.
  success(
    face: Color(0xFFEAF7EC),
    edge: Color(0xFFA6DDB3),
    disc: Color(0xFF46A758),
  ),

  /// Information (the stuck hint, a board note).
  info(
    face: Color(0xFFE8F3FF),
    edge: Color(0xFF9CC4EA),
    disc: Color(0xFF3E8EDE),
  ),

  /// "Badge earned · …": its lead is the badge's own art.
  badge(
    face: Color(0xFFFFF7E0),
    edge: Color(0xFFE6C36A),
    disc: Color(0xFFF5C518),
  ),

  /// The +1 Slot limit, a caution.
  warning(
    face: AppColorTokens.warningTint,
    edge: AppColorTokens.warningEdge,
    disc: AppColorTokens.primary,
  );

  const ToastTone({required this.face, required this.edge, required this.disc});

  final Color face;
  final Color edge;
  final Color disc;
}

/// One toast in a [ToastQueue] (phase 4 architecture §3.12, §6.4): its
/// [tone], [title] (wraps), an optional [message] line, and a lead: the
/// [leading] widget (a badge's 38 dp art) or else [icon] in the tone's
/// 32 dp disc.
@immutable
final class ToastSpec {
  const ToastSpec({
    required this.tone,
    required this.title,
    this.message,
    this.icon,
    this.leading,
    this.duration = defaultDuration,
  });

  /// tokens.json `motion.toast.autoDismissMs`: 2.5 s on screen.
  static const Duration defaultDuration = Duration(
    milliseconds: ToastTokens.autoDismissMs,
  );

  final ToastTone tone;
  final String title;
  final String? message;
  final IconData? icon;
  final Widget? leading;

  /// How long it stays before it fades out.
  final Duration duration;
}

/// Where toasts wait their turn (tokens.json `motion.toast`: one at a time,
/// the next 300 ms after the last leaves; Q136).
abstract interface class ToastQueue {
  /// Shows [spec] now, or after the ones already waiting.
  void enqueue(ToastSpec spec);

  /// Drops every waiting toast and the one on screen (a result card
  /// leaving: `motion.toast.leavesWithCard`).
  void clear();
}

/// Hosts a [ToastQueue] over [child], drawing its toasts at [top] (phase 4
/// architecture §3.12, §6.4; lead note 5).
///
/// The app root holds one (`App`'s builder, above every route), so
/// `NestyToast.show` from any screen queues there. A result card adds its
/// own, scoped host (the win card's badge toasts at [ToastTokens.badgeToastTop],
/// above the ribbon): its toasts leave with it, since disposing the host
/// drops its queue.
///
/// [top] is a design screen y on the 390×844 reference with its 59 dp safe
/// area (60 for badge and race toasts, 152 for board toasts, 124 for
/// "Reminder set"); on a device it sits `top − 59` below the safe-area top.
/// Toasts take no touch. Under reduce motion they fade without the slide.
class ToastHost extends StatefulWidget {
  const ToastHost({required this.child, this.top = boardTop, super.key});

  /// The design's safe-area top the [top] values are measured on.
  static const double designSafeTop = 59;

  /// Board toasts (the +1 Slot limit, relaxed mode): 152, under the family
  /// counter, where the soft-stuck banner sits.
  static const double boardTop = 152;

  /// Badge and race toasts, above the result card's ribbon.
  static const double badgeTop = ToastTokens.badgeToastTop;

  /// "Reminder set for …" on the Daily screen.
  static const double reminderTop = 124;

  /// The app root's host: 58 below the safe-area top, clear of a screen's
  /// header, where frames 5.2 ("Freeze used") and 8.3 ("Purchases
  /// restored") put their toasts.
  static const double appTop = designSafeTop + 58;

  /// The toasts' side inset (ui-spec-game §1 "Toast": left/right 20).
  static const double side = 20;

  final Widget child;
  final double top;

  /// The nearest host's queue, or null when there is none (a widget test's
  /// bare page: `NestyToast.show` then inserts an overlay entry itself).
  static ToastQueue? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_ToastScope>()?.queue;

  @override
  State<ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<ToastHost> implements ToastQueue {
  final Queue<ToastSpec> _waiting = Queue();
  ToastSpec? _current;
  bool _visible = false;

  /// The on-screen timer, then the 300 ms gap: one at a time.
  Timer? _timer;

  /// Bumped per toast, so a stale fade's `onEnd` never removes the next.
  int _serial = 0;

  @override
  void enqueue(ToastSpec spec) {
    _waiting.add(spec);
    if (_current == null && _timer == null) _showNext();
  }

  @override
  void clear() {
    _waiting.clear();
    _timer?.cancel();
    _timer = null;
    if (mounted && _current != null) {
      setState(() {
        _current = null;
        _visible = false;
      });
    }
  }

  void _showNext() {
    if (!mounted || _waiting.isEmpty) return;
    final spec = _waiting.removeFirst();
    final serial = ++_serial;
    setState(() {
      _current = spec;
      _visible = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && serial == _serial) setState(() => _visible = true);
    });
    _timer = Timer(spec.duration, () {
      _timer = null;
      if (mounted && serial == _serial) setState(() => _visible = false);
    });
  }

  void _onFadeEnd(int serial) {
    if (_visible || serial != _serial || _current == null) return;
    setState(() => _current = null);
    _timer = Timer(const Duration(milliseconds: ToastTokens.gapMs), () {
      _timer = null;
      _showNext();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final fade = Duration(
      milliseconds:
          (UiMotionTokens.modalInMs *
                  (reduced ? UiMotionTokens.reducedMotionDurationScale : 1))
              .round(),
    );
    final safeTop = MediaQuery.maybePaddingOf(context)?.top ?? 0;
    final serial = _serial;
    return _ToastScope(
      queue: this,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (current != null)
            Positioned(
              left: ToastHost.side,
              right: ToastHost.side,
              top: safeTop + widget.top - ToastHost.designSafeTop,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: fade,
                  curve: UiMotionTokens.curveEaseOut,
                  onEnd: () => _onFadeEnd(serial),
                  child: AnimatedSlide(
                    offset: _visible || reduced
                        ? Offset.zero
                        : const Offset(0, -0.3),
                    duration: fade,
                    curve: UiMotionTokens.curveEaseOut,
                    // Above every page's Material: the body style a page's
                    // Material would give it (no fallback underline).
                    child: DefaultTextStyle(
                      style: AppTextStyles.bodySmall,
                      child: ToastCard(spec: current),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToastScope extends InheritedWidget {
  const _ToastScope({required this.queue, required super.child});

  final ToastQueue queue;

  @override
  bool updateShouldNotify(_ToastScope oldWidget) =>
      !identical(oldWidget.queue, queue);
}

/// One toast's card (ui-spec-game §1 "Toast"): padding 8/14/8/8, radius 20,
/// the tone's face with an inner highlight, its 4 dp edge and a soft drop;
/// the title Fredoka 700 15 (it wraps), the line Nunito 700 12. Screen
/// readers announce it as it appears.
class ToastCard extends StatelessWidget {
  const ToastCard({required this.spec, super.key});

  final ToastSpec spec;

  static const double discSize = 32;
  static const double glyphSize = 20;
  static const double leadingSize = 38;

  @override
  Widget build(BuildContext context) {
    final tone = spec.tone;
    final message = spec.message;
    final icon = spec.icon;
    final lead =
        spec.leading ??
        (icon == null
            ? null
            : SizedBox.square(
                dimension: discSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tone.disc,
                  ),
                  child: Icon(
                    icon,
                    size: glyphSize,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ));
    return NestySurface(
      style: SurfaceStyle(
        color: tone.face,
        shadows: [
          const NestyShadow(color: Color(0xB3FFFFFF), inset: true, dy: 2),
          NestyShadow(color: tone.edge, dy: 4),
          const NestyShadow(color: Color(0x335A3214), dy: 8, blur: 14),
        ],
      ),
      radius: const BorderRadius.all(Radius.circular(20)),
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 14, 8),
      child: Semantics(
        liveRegion: true,
        container: true,
        child: Row(
          children: [
            if (lead != null) ...[lead, const SizedBox(width: 10)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    spec.title,
                    style: AppTextStyleTokens.cardTitle.copyWith(
                      fontSize: 15,
                      color: AppColorTokens.textPrimary,
                    ),
                  ),
                  if (message != null)
                    Text(
                      message,
                      style: AppTextStyleTokens.caption.copyWith(
                        height: 1.3,
                        color: AppColorTokens.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
