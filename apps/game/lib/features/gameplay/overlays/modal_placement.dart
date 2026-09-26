import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Places a modal card where its App Flow frame does (NestyOverlay: the
/// pause card at top 190, the all-levels card at 150, on the 390×844
/// reference with a 59 safe area): [cardTop] below the safe-area top.
///
/// A screen too short for that centres the card instead, and a card taller
/// than the screen (1.3× text on a small phone) scrolls. [side] is the
/// frame's left/right inset; [clearance] is what the card draws above its
/// box (the pause card's ribbon title).
class ModalPlacement extends StatelessWidget {
  const ModalPlacement({
    required this.cardTop,
    required this.side,
    required this.child,
    this.clearance = 0,
    this.maxWidth = 390,
    super.key,
  });

  /// The card's top below the safe-area top at the reference size.
  final double cardTop;
  final double side;

  /// Drawn above the card's box (a ribbon title's overhang).
  final double clearance;

  /// The widest the card and its insets get (the reference width).
  final double maxWidth;
  final Widget child;

  /// Kept clear above (past [clearance]) and below the card.
  static const double margin = 16;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: _TopOrCentered(
            top: cardTop - clearance - margin,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    side,
                    clearance + margin,
                    side,
                    margin,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Puts its child [top] from the top, or higher to centre it when the
/// space (the incoming minimum height) is too short for that; never above
/// the top.
class _TopOrCentered extends SingleChildRenderObjectWidget {
  const _TopOrCentered({required this.top, super.child});

  final double top;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTopOrCentered(top);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTopOrCentered renderObject,
  ) => renderObject.top = top;
}

final class _RenderTopOrCentered extends RenderShiftedBox {
  _RenderTopOrCentered(this._top) : super(null);

  double _top;
  set top(double value) {
    if (value == _top) return;
    _top = value;
    markNeedsLayout();
  }

  BoxConstraints _childConstraints(BoxConstraints constraints) =>
      BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
      );

  /// The frame's top, unless centring puts the card higher.
  double _offsetFor(BoxConstraints constraints, Size child) {
    final free = constraints.minHeight - child.height;
    return math.max(0, math.min(_top, free / 2)).toDouble();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    final childSize = child.getDryLayout(_childConstraints(constraints));
    final dy = _offsetFor(constraints, childSize);
    return constraints.constrain(Size(childSize.width, dy + childSize.height));
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_childConstraints(constraints), parentUsesSize: true);
    final dy = _offsetFor(constraints, child.size);
    (child.parentData! as BoxParentData).offset = Offset(0, dy);
    size = constraints.constrain(
      Size(child.size.width, dy + child.size.height),
    );
  }
}
