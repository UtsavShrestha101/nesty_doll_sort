import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';

/// `fx_twinkle` over a purchase (LOTTIE.md "Win, Chapter complete, Shop":
/// `fx_twinkle`, 2.0–2.4 s, random phase; docs/plans/m3-design.md §10.7): a
/// short burst of twinkle stars over the card that was just bought or
/// equipped, then gone.
///
/// TODO(design): no frame times a Shop purchase's celebration; this shows
/// one twinkle cycle (2.2 s) and removes itself, matching the file's own
/// length rather than looping like Home's ambient stars.
abstract final class PurchaseTwinkleBurst {
  static const Duration _duration = Duration(milliseconds: 2200);

  static const List<({double dx, double dy, double size, double phaseMs})>
  _points = [
    (dx: 0.18, dy: 0.22, size: 22, phaseMs: 0),
    (dx: 0.82, dy: 0.18, size: 18, phaseMs: 300),
    (dx: 0.5, dy: 0.82, size: 20, phaseMs: 600),
  ];

  /// Finds [context]'s render box (a card's `GlobalKey`-free `context` is
  /// enough: it is called from inside the card that was tapped) and shows
  /// the burst over it in the nearest `Overlay`. A missing overlay or an
  /// unattached box (the widget was already disposed) does nothing.
  static void showOver(BuildContext context, {FxLibrary? library}) {
    final overlay = Overlay.maybeOf(context);
    final renderObject = context.findRenderObject();
    if (overlay == null ||
        renderObject is! RenderBox ||
        !renderObject.attached) {
      return;
    }
    final origin = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: origin.dx,
        top: origin.dy,
        width: size.width,
        height: size.height,
        child: IgnorePointer(
          child: Stack(
            children: [
              for (final t in _points)
                Positioned(
                  left: size.width * t.dx - t.size / 2,
                  top: size.height * t.dy - t.size / 2,
                  child: LottieTwinkle(
                    size: t.size,
                    phaseMs: t.phaseMs,
                    library: library,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Timer(_duration, () {
      if (entry.mounted) entry.remove();
    });
  }
}
