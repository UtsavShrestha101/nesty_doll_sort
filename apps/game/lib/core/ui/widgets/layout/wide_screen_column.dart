import 'package:flutter/widgets.dart';

/// Centres [child] in a column at most [maxWidth] dp wide (docs/plans/
/// m7-design.md §15's shared rule: "on 768 × 1024 content sits in a ~600 dp
/// column and grids gain columns", a placeholder while the owner's Q16 on a
/// tablet layout is open).
///
/// On a narrower screen [child] simply takes the full width it is given, so
/// this changes nothing on a phone.
class WideScreenColumn extends StatelessWidget {
  const WideScreenColumn({required this.child, this.maxWidth = 600, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
