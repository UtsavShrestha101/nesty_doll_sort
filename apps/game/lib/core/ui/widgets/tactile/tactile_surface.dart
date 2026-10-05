import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_painter.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_feedback.dart';
import 'package:nesty_game/core/ui/widgets/tactile/touch_target.dart';

/// Every pressable control of the design (design/README.md "Tactile
/// depth"): a gradient face with a 2 px white inner top highlight, a solid
/// bottom edge and a soft drop shadow ([SurfaceStyle]). Pressed, the face and
/// [child] move down by `edge − 2` px while the edge shrinks to 2 px, over
/// `motion.ui.buttonPress` (80 ms; half under reduced motion, PROGRESS D48).
///
/// Activating it (a tap, or the screen reader's action) plays the `button`
/// sound and the selection haptic ([TactileFeedback]) and calls
/// [onPressed]. With [onPressed] null it is disabled: no press, no feedback,
/// and [disabledStyle] (if given) replaces [style].
///
/// The widget's box is the face: the edge paints below it without taking
/// layout space, as in the prototypes' CSS. Only the face is hit-testable.
class TactileSurface extends StatefulWidget {
  const TactileSurface({
    required this.style,
    required this.radius,
    required this.child,
    required this.onPressed,
    this.disabledStyle,
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.semanticValue,
    this.selected,
    this.radioChecked,
    this.semanticAttributedLabel,
    this.customSemanticsActions,
    this.excludeChildSemantics = false,
    this.minTouchSize,
    this.feedback = true,
    super.key,
  });

  final SurfaceStyle style;

  /// Painted instead of [style] while disabled.
  final SurfaceStyle? disabledStyle;

  final BorderRadius radius;
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  /// The screen-reader label. Icon-only controls must set it.
  final String? semanticLabel;

  /// The control's state, read after its label ("Equipped", "After
  /// Level 2"), so the label stays the control's name.
  final String? semanticValue;

  /// Whether this is the chosen option of a group (a sheet's active row).
  /// Null (the default) exposes no selected state at all.
  final bool? selected;

  /// Makes this a radio of a mutually exclusive group (the language
  /// sheet's rows): checked or not, and no longer announced as a button.
  /// Null (the default) is a plain button.
  final bool? radioChecked;

  /// The label with its language spans (a name read in its own language),
  /// used instead of [semanticLabel] when set.
  final AttributedString? semanticAttributedLabel;

  /// Extra actions a screen reader offers on this control (the Skins
  /// card's Equip and Buy, whose own buttons its label covers).
  final Map<CustomSemanticsAction, VoidCallback>? customSemanticsActions;

  /// Hides [child]'s own semantics (when [semanticLabel] says it all).
  final bool excludeChildSemantics;

  /// Grows the touch area and the screen-reader node to at least this size
  /// ([TouchTarget], 48 dp by spec §10.3) around a smaller face, which
  /// stays centred and keeps its look. The widget's box grows with it.
  final Size? minTouchSize;

  /// False skips the sound and haptic (a control that plays its own).
  final bool feedback;

  bool get enabled => onPressed != null;

  @override
  State<TactileSurface> createState() => _TactileSurfaceState();
}

class _TactileSurfaceState extends State<TactileSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: UiMotionTokens.buttonPressMs),
  )..addStatusListener(_onStatus);

  late final CurvedAnimation _press = CurvedAnimation(
    parent: _controller,
    curve: UiMotionTokens.curveEaseOut,
  );

  /// True while a pointer holds the control down.
  bool _down = false;

  late SurfaceStyle _painted = _styleFor(widget);
  late SurfacePainter _painter = _painterFor(_painted);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final ms =
        UiMotionTokens.buttonPressMs *
        (reduced ? UiMotionTokens.reducedMotionDurationScale : 1);
    _controller.duration = Duration(microseconds: (ms * 1000).round());
  }

  @override
  void didUpdateWidget(TactileSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _controller.value != 0) {
      _down = false;
      _controller.value = 0;
    }
    final style = _styleFor(widget);
    if (style != _painted || widget.radius != oldWidget.radius) {
      _painted = style;
      _painter = _painterFor(style);
    }
  }

  @override
  void dispose() {
    _press.dispose();
    _controller.dispose();
    super.dispose();
  }

  static SurfaceStyle _styleFor(TactileSurface widget) =>
      widget.enabled ? widget.style : widget.disabledStyle ?? widget.style;

  SurfacePainter _painterFor(SurfaceStyle style) => SurfacePainter(
    style: style,
    radius: widget.radius,
    press: _press,
    pressed: style.pressed,
  );

  // A quick tap still shows the full press: the release waits for the
  // press to bottom out, then springs back.
  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_down) _controller.reverse();
  }

  void _handleDown(TapDownDetails _) {
    _down = true;
    _controller.forward();
  }

  void _handleUp(TapUpDetails _) => _release();

  void _release() {
    _down = false;
    if (_controller.isCompleted) _controller.reverse();
  }

  void _activate() {
    final onPressed = widget.onPressed;
    if (onPressed == null) return;
    if (widget.feedback) TactileFeedback.of(context)?.activate();
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final travel = _painted.travel;
    // Without an explicit size the face hugs its child (factor 1); with one,
    // the child is aligned inside it.
    final content = Padding(
      padding: widget.padding,
      child: Align(
        alignment: widget.alignment,
        widthFactor: widget.width == null ? 1 : null,
        heightFactor: widget.height == null ? 1 : null,
        child: widget.child,
      ),
    );
    Widget face = GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTapDown: enabled ? _handleDown : null,
      onTapUp: enabled ? _handleUp : null,
      onTapCancel: enabled ? _release : null,
      onTap: enabled ? _activate : null,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          painter: _painter,
          child: AnimatedBuilder(
            animation: _press,
            child: content,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, travel * _press.value),
              child: child,
            ),
          ),
        ),
      ),
    );
    // Inside the node, so a screen reader's focus box is the touch area
    // too, not just the face (review R24).
    final minTouchSize = widget.minTouchSize;
    if (minTouchSize != null) {
      face = TouchTarget(minSize: minTouchSize, child: face);
    }
    // Its own node: the child's text merges into the button's label.
    return Semantics(
      container: true,
      button: widget.radioChecked == null,
      inMutuallyExclusiveGroup: widget.radioChecked == null ? null : true,
      checked: widget.radioChecked,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticAttributedLabel == null
          ? widget.semanticLabel
          : null,
      attributedLabel: widget.semanticAttributedLabel,
      value: widget.semanticValue,
      excludeSemantics: widget.excludeChildSemantics,
      customSemanticsActions: widget.customSemanticsActions,
      onTap: enabled ? _activate : null,
      child: face,
    );
  }
}
