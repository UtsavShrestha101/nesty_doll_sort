import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';

// TODO(v1.1): with Android's "Remove animations" on, Off can't bring back
// full motion: an `AnimationController` with the default behaviour runs at
// 5 % of its duration whenever `SemanticsBinding.disableAnimations` (the
// platform's flag, not this `MediaQuery`) is set. It errs toward less
// motion; the fix is `AnimationBehavior.preserve` on the app's own
// controllers (M7 review R7's note, BACKLOG).

/// Wraps [child] in a `MediaQuery` whose `disableAnimations` follows [mode]
/// over the operating system's own setting (E14, docs/plans/m7-design.md
/// §14): System follows the OS, On always reduces motion, Off never does.
/// Every reader of `MediaQuery.disableAnimations` (`context.reduceMotion`,
/// `LottieFxView`, the UI kit's duration tokens, the board's `MotionSpec`)
/// follows it without change. Sounds and haptics are unaffected (they read
/// their own settings, not this flag).
///
/// The OS setting is either flag the engine reports ([systemReducesMotion]).
/// Android's "Remove animations" sets `AccessibilityFeatures
/// .disableAnimations`, which `MediaQuery` carries. iOS's Reduce Motion
/// sets only `AccessibilityFeatures.reduceMotion` (Flutter 3.41's
/// `FlutterViewController.mm`), which `MediaQueryData` has no field for, so
/// a `MediaQuery` rebuild never reports it: this widget reads the
/// platform's features itself and rebuilds when they change (review R7,
/// spec-prop §16 "follow the system setting").
class ReduceMotionOverride extends StatefulWidget {
  const ReduceMotionOverride({
    required this.mode,
    required this.child,
    super.key,
  });

  final ReduceMotionMode mode;
  final Widget child;

  /// Whether the operating system asks for reduced motion under
  /// [context]: Android's "Remove animations" (through `MediaQuery`) or
  /// iOS's Reduce Motion (only on the view's `AccessibilityFeatures`).
  static bool systemReducesMotion(BuildContext context) =>
      (MediaQuery.maybeDisableAnimationsOf(context) ?? false) ||
      (View.maybeOf(
            context,
          )?.platformDispatcher.accessibilityFeatures.reduceMotion ??
          false);

  @override
  State<ReduceMotionOverride> createState() => _ReduceMotionOverrideState();
}

class _ReduceMotionOverrideState extends State<ReduceMotionOverride>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // iOS's flag alone changing leaves `MediaQueryData` equal, so nothing
  // above rebuilds this widget: the binding's notice does.
  @override
  void didChangeAccessibilityFeatures() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      disableAnimations: widget.mode.resolve(
        systemDisablesAnimations: ReduceMotionOverride.systemReducesMotion(
          context,
        ),
      ),
    ),
    child: widget.child,
  );
}
