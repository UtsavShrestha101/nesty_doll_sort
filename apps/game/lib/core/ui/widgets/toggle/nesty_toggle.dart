import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_painter.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_feedback.dart';
import 'package:nesty_game/core/ui/widgets/tactile/touch_target.dart';

/// "Toggle: 54×30 track, radius 15, on `#46A758`, off `#D9C2A0`, 24px knob
/// `#FFFDF7` at x 3 / 27, spring `cubic-bezier(.3,1.4,.5,1)` 180 ms"
/// (design/README.md "Components"; Pause 3.9, Settings 8.1).
///
/// In M2 the look is the `ui_toggle` Lottie (LOTTIE.md: `on` 0–11, `off`
/// 11–22): the screens lane passes it as [lottie] and drives it from
/// [value]. Without it (or when the file failed to load, lottie design §10)
/// this draws the static track and knob. Either way this widget owns the
/// tap, the `button` sound and selection haptic, and the semantics.
class NestyToggle extends StatelessWidget {
  const NestyToggle({
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.lottie,
    super.key,
  });

  final bool value;

  /// Null disables it.
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  /// Replaces the static drawing: a 54×30 `ui_toggle` view.
  final Widget? lottie;

  static const Size size = Size(54, 30);

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    void toggle() {
      if (onChanged == null) return;
      TactileFeedback.of(context)?.activate();
      onChanged(!value);
    }

    return Semantics(
      container: true,
      toggled: value,
      enabled: onChanged != null,
      label: semanticLabel,
      onTap: onChanged == null ? null : toggle,
      child: TouchTarget(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: onChanged == null ? null : toggle,
          child: SizedBox.fromSize(
            size: size,
            child: ExcludeSemantics(child: lottie ?? _StaticToggle(value)),
          ),
        ),
      ),
    );
  }
}

class _StaticToggle extends StatelessWidget {
  const _StaticToggle(this.value);

  final bool value;

  static const _track = BorderRadius.all(Radius.circular(AppRadii.toggle));
  static const _knob = BorderRadius.all(Radius.circular(12));

  static const _knobStyle = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [NestyShadow(color: Color(0x4D5A3214), dy: 2)],
  );

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final ms =
        UiMotionTokens.toggleMs *
        (reduced ? UiMotionTokens.reducedMotionDurationScale : 1);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value ? 1 : 0),
      duration: Duration(milliseconds: ms.round()),
      curve: UiMotionTokens.curveToggle,
      builder: (context, t, _) {
        final track = SurfaceStyle(
          color: Color.lerp(
            AppColorTokens.toggleOff,
            AppColorTokens.success,
            t.clamp(0.0, 1.0),
          ),
          shadows: const [
            NestyShadow(color: Color(0x403C1905), inset: true, dy: 2, blur: 3),
          ],
        );
        return CustomPaint(
          painter: SurfacePainter(style: track, radius: _track),
          child: Padding(
            // The spring overshoots a little past either end.
            padding: EdgeInsetsDirectional.only(
              start: (3 + 24 * t).clamp(0.0, 30.0),
              top: 3,
            ),
            child: const Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox.square(
                dimension: 24,
                child: CustomPaint(painter: _KnobPainter()),
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _KnobPainter extends CustomPainter {
  const _KnobPainter();

  @override
  void paint(Canvas canvas, Size size) => SurfacePainter(
    style: _StaticToggle._knobStyle,
    radius: _StaticToggle._knob,
  ).paint(canvas, size);

  @override
  bool shouldRepaint(_KnobPainter oldDelegate) => false;
}
