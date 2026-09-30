import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lets a control the design draws smaller than 48 dp answer touches, and
/// give a screen reader's focus box, across a [minSize] area centred on it
/// (48 dp, spec §10.3) without growing its layout box: the margin reaches
/// over the gaps the design already leaves around it, such as a theme
/// card's 30 px Use button between a 7 px gap and the card's 8 px padding.
///
/// [TouchTarget] is the default tool; it grows the box. This one is for a
/// control with no room to grow in a fixed-size cell. A touch in the
/// margin presses the control's centre, as with [TouchTarget]; it only
/// reaches as far as the ancestors' own boxes do, so the gaps must be
/// inside the card or row that holds it.
///
/// Its screen-reader node takes over the control's own (it merges its
/// descendants' semantics), so wrap exactly one control.
class TouchSlop extends SingleChildRenderObjectWidget {
  const TouchSlop({
    required Widget super.child,
    this.minSize = const Size.square(48),
    super.key,
  });

  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTouchSlop(minSize);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) =>
      (renderObject as _RenderTouchSlop).minSize = minSize;
}

final class _RenderTouchSlop extends RenderProxyBox {
  _RenderTouchSlop(this._minSize);

  Size _minSize;
  Size get minSize => _minSize;
  set minSize(Size value) {
    if (value == _minSize) return;
    _minSize = value;
    markNeedsSemanticsUpdate();
  }

  /// The area that answers: the box, grown to [minSize] about its centre.
  Rect get _area => Rect.fromCenter(
    center: size.center(Offset.zero),
    width: math.max(size.width, _minSize.width),
    height: math.max(size.height, _minSize.height),
  );

  @override
  Rect get semanticBounds => _area;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = true
      ..isMergingSemanticsOfDescendants = true;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!_area.contains(position)) return false;
    final child = this.child;
    if (child == null) return false;
    if (size.contains(position)) {
      if (child.hitTest(result, position: position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
      return false;
    }
    final center = child.size.center(Offset.zero);
    final hit = result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (result, _) => child.hitTest(result, position: center),
    );
    if (hit) result.add(BoxHitTestEntry(this, position));
    return hit;
  }
}
