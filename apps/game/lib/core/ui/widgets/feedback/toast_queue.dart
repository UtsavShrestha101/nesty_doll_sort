import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// Where a toast sits, which picks its geometry (tokens.json `toast`, m7-4
/// 1.5): [app] is the app-wide toast over a screen (frames 5.2, 8.3), 4 dp
/// under the safe top; [inPlace] is a toast on a card or a board (frames
/// 10.6, 10.9, 12.7, 12.9), at a design y of 60, 124 or 152.
enum ToastPlacement { app, inPlace }

/// A toast's kind and colours (tokens.json `color.toast*`, m7-4 1.2; frames
/// 5.2, 8.3, 10.6, 10.9, 12.7, 12.9): the card's face, its edge and the lead
/// disc, plus the text colours the app toast reads on that face.
enum ToastTone {
  /// "Reminder set", relaxed mode, a race's rival unlocked, "Purchases
  /// restored".
  success(
    face: AppColorTokens.toastSuccessFace,
    edge: AppColorTokens.toastSuccessRing,
    disc: AppColorTokens.toastSuccessAccent,
    appTitle: AppColors.successToastTitle,
    appMessage: AppColors.successToastMessage,
  ),

  /// Information (a board note, "Streak saved!"): the info disc is a
  /// gradient.
  info(
    face: AppColorTokens.toastInfoFace,
    edge: AppColorTokens.toastInfoRing,
    disc: AppColorTokens.toastInfoAccent,
    discGradient: ToastLayoutTokens.appIconDiscInfo,
    appTitle: AppColors.infoTitle,
    appMessage: AppColors.infoText,
  ),

  /// "Badge earned · …": its lead is the badge's own art, with no disc.
  badge(
    face: AppColorTokens.toastBadgeFace,
    edge: AppColorTokens.toastBadgeRing,
    disc: AppColorTokens.toastBadgeAccent,
  ),

  /// The soft-stuck hint, a caution.
  warning(
    face: AppColorTokens.toastWarnFace,
    edge: AppColorTokens.toastWarnRing,
    disc: AppColorTokens.toastWarnAccent,
  );

  const ToastTone({
    required this.face,
    required this.edge,
    required this.disc,
    this.discGradient,
    this.appTitle = AppColorTokens.textPrimary,
    this.appMessage = AppColorTokens.textSecondary,
  });

  final Color face;
  final Color edge;
  final Color disc;

  /// The disc's gradient where the frame draws one (info); else [disc].
  final Gradient? discGradient;

  /// The title and line colours of the app toast (`toast.app`); an in-place
  /// toast's are always `#5B3A21` and `#8A5B3A`.
  final Color appTitle;
  final Color appMessage;
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

  /// How long a toast stays while a screen reader is on
  /// (`MediaQuery.accessibleNavigation`; TalkBack T1, WCAG 2.2.1): the 2.5 s
  /// is too short to move focus to a toast and read it again, so it stays
  /// four times as long. It still leaves with its card and the live-region
  /// announcement is unchanged. Sighted play keeps [defaultDuration].
  static const Duration accessibleDuration = Duration(seconds: 10);

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

/// Hosts a [ToastQueue] over [child], drawing its toasts by [placement]
/// (phase 4 architecture §3.12, §6.4; lead note 5; tokens.json `toast`).
///
/// The app root holds one ([ToastHost.app], above every route), so
/// `NestyToast.show` from any screen queues there: 4 dp under the safe top
/// (m7-4 1.5; frames 5.2, 8.3), in the app geometry. A result card or board
/// adds its own, scoped in-place host (the win card's badge toasts at
/// [ToastTokens.badgeToastTop], above the ribbon): its toasts leave with it,
/// since disposing the host drops its queue.
///
/// An in-place [top] is a design screen y on the 390×844 reference with its
/// 59 dp safe area (60 for badge and race toasts, 152 for board toasts, 124
/// for "Reminder set"); on a device it sits `top − 59` below the safe-area
/// top. Toasts take no touch. Under reduce motion they fade without the
/// slide.
class ToastHost extends StatefulWidget {
  const ToastHost({
    required this.child,
    this.top = boardTop,
    this.placement = ToastPlacement.inPlace,
    super.key,
  });

  /// The app root's host: [ToastPlacement.app], the safe top + 4.
  const ToastHost.app({required this.child, super.key})
    : top = 0,
      placement = ToastPlacement.app;

  /// The design's safe-area top the [top] values are measured on.
  static const double designSafeTop = 59;

  /// Board toasts (the +1 Slot limit, relaxed mode): 152, under the family
  /// counter, where the soft-stuck banner sits.
  static const double boardTop = ToastLayoutTokens.inPlaceTopsBoard;

  /// Badge and race toasts, above the result card's ribbon.
  static const double badgeTop = ToastLayoutTokens.inPlaceTopsWinCard;

  /// "Reminder set for …" on the Daily screen.
  static const double reminderTop = ToastLayoutTokens.inPlaceTopsScreenHeader;

  /// The in-place toasts' side inset (`toast.inPlace.side`).
  static const double side = ToastLayoutTokens.inPlaceSide;

  final Widget child;

  /// The in-place design y; unused by the app placement.
  final double top;
  final ToastPlacement placement;

  /// The nearest host's queue, or null when there is none (a widget test's
  /// bare page: `NestyToast.show` then inserts an overlay entry itself).
  static ToastQueue? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_ToastScope>()?.queue;

  /// The nearest host's placement, or null with none.
  static ToastPlacement? placementOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_ToastScope>()?.placement;

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
    final screenReader =
        MediaQuery.maybeAccessibleNavigationOf(context) ?? false;
    final stay = screenReader && spec.duration < ToastSpec.accessibleDuration
        ? ToastSpec.accessibleDuration
        : spec.duration;
    _timer = Timer(stay, () {
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
    final placement = widget.placement;
    final isApp = placement == ToastPlacement.app;
    final side = isApp ? ToastLayoutTokens.appSide : ToastHost.side;
    return _ToastScope(
      queue: this,
      placement: placement,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (current != null)
            Positioned(
              left: side,
              right: side,
              top: isApp
                  ? safeTop + ToastLayoutTokens.appTopBelowSafeTop
                  : safeTop + widget.top - ToastHost.designSafeTop,
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
                      style: context.scriptStyle(
                        AppTextStyles.bodySmall,
                        role: ScriptTextRole.body,
                      ),
                      child: ToastCard(spec: current, placement: placement),
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
  const _ToastScope({
    required this.queue,
    required this.placement,
    required super.child,
  });

  final ToastQueue queue;
  final ToastPlacement placement;

  @override
  bool updateShouldNotify(_ToastScope oldWidget) =>
      !identical(oldWidget.queue, queue) || oldWidget.placement != placement;
}

/// One toast's card (tokens.json `toast.app` and `toast.inPlace`, m7-4 1.5):
/// the tone's face with an inner highlight, its 4 dp edge and a soft drop.
///
/// - [ToastPlacement.app] (frames 5.2, 8.3): padding 12/12/16/12, radius 22,
///   a 40 dp disc with a 26 dp glyph, the title Fredoka 700 17/1.1 and the
///   line Nunito 700 13/1.3 in the tone's own ink.
/// - [ToastPlacement.inPlace] (frames 10.6, 10.9, 12.7, 12.9): padding
///   8/8/14/8, radius 20, a 32 dp disc with a 20 dp glyph (a badge's art is
///   38 dp, no disc), the title Fredoka 700 15/1.3 and the line Nunito 700
///   12/1.3.
///
/// Screen readers announce it as it appears.
class ToastCard extends StatelessWidget {
  const ToastCard({
    required this.spec,
    this.placement = ToastPlacement.inPlace,
    super.key,
  });

  final ToastSpec spec;
  final ToastPlacement placement;

  /// The in-place disc, glyph and badge art sizes.
  static const double discSize = ToastLayoutTokens.inPlaceIcon;
  static const double glyphSize = ToastLayoutTokens.inPlaceGlyph;
  static const double leadingSize = ToastLayoutTokens.inPlaceArt;

  @override
  Widget build(BuildContext context) {
    final tone = spec.tone;
    final message = spec.message;
    final icon = spec.icon;
    final isApp = placement == ToastPlacement.app;
    final disc = isApp ? ToastLayoutTokens.appIcon : discSize;
    final glyph = isApp ? ToastLayoutTokens.appGlyph : glyphSize;
    final lead =
        spec.leading ??
        (icon == null
            ? null
            : SizedBox.square(
                dimension: disc,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tone.discGradient == null ? tone.disc : null,
                    gradient: tone.discGradient,
                  ),
                  child: Icon(
                    icon,
                    size: glyph,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ));
    final titleStyle =
        (isApp ? ToastLayoutTokens.appTitle : ToastLayoutTokens.inPlaceTitle)
            .copyWith(
              color: isApp ? tone.appTitle : AppColorTokens.textPrimary,
            );
    final messageStyle =
        (isApp ? ToastLayoutTokens.appMessage : ToastLayoutTokens.inPlaceSub)
            .copyWith(
              color: isApp ? tone.appMessage : AppColorTokens.textSecondary,
            );
    return NestySurface(
      style: SurfaceStyle(
        color: tone.face,
        shadows: isApp
            ? [
                ...ToastLayoutTokens.appHighlight,
                NestyShadow(
                  color: tone.edge,
                  dy: ToastLayoutTokens.appEdgeDepth,
                ),
                ...(tone == ToastTone.success
                    ? ToastLayoutTokens.appShadowSuccess
                    : ToastLayoutTokens.appShadow),
              ]
            : [
                ...ToastLayoutTokens.inPlaceHighlight,
                NestyShadow(
                  color: tone.edge,
                  dy: ToastLayoutTokens.inPlaceEdgeDepth,
                ),
                ...ToastLayoutTokens.inPlaceShadow,
              ],
      ),
      radius: BorderRadius.circular(
        isApp ? ToastLayoutTokens.appRadius : ToastLayoutTokens.inPlaceRadius,
      ),
      padding:
          (isApp
                  ? ToastLayoutTokens.appPadding
                  : ToastLayoutTokens.inPlacePadding)
              .resolve(Directionality.of(context)),
      child: Semantics(
        liveRegion: true,
        container: true,
        child: Row(
          children: [
            if (lead != null) ...[
              lead,
              SizedBox(
                width: isApp
                    ? ToastLayoutTokens.appGap
                    : ToastLayoutTokens.inPlaceGap,
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(spec.title, style: titleStyle),
                  if (message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(message, style: messageStyle),
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

/// The purchase pill (tokens.json `toast.pill`, frame 7.10): a cream pill
/// with a green check disc and a one-line label, 4 dp edge. The caller
/// places it.
class ToastPill extends StatelessWidget {
  const ToastPill({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => NestySurface(
    style: const SurfaceStyle(
      color: ToastLayoutTokens.pillFace,
      shadows: [
        NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
        ...ToastLayoutTokens.pillEdge,
        ...ToastLayoutTokens.inPlaceShadow,
      ],
    ),
    radius: BorderRadius.circular(ToastLayoutTokens.pillRadius),
    padding: ToastLayoutTokens.pillPadding.resolve(Directionality.of(context)),
    child: Semantics(
      liveRegion: true,
      container: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: ToastLayoutTokens.pillIcon,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColorTokens.toastSuccessAccent,
              ),
              child: Icon(
                icon,
                size: ToastLayoutTokens.inPlaceGlyph,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
          const SizedBox(width: ToastLayoutTokens.inPlaceGap),
          Flexible(
            child: Text(
              text,
              style: ToastLayoutTokens.pillText.copyWith(
                color: AppColorTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
