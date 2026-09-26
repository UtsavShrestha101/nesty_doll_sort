import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';

export 'package:nesty_game/core/ui/widgets/sheet/sheet_row.dart';

/// "Bottom sheet: radius 34 on top, surface, 44×5 grabber, title 30/700,
/// rows are 20-radius white cards" (design/README.md "Components";
/// NestyOverlay Out of moves 3.5).
///
/// The caller docks it to the bottom (over a scrim) and animates it in
/// (`motion.ui.sheetIn`, 280 ms). Its bottom padding clears the home
/// indicator. On a short screen at 1.3× text the rows scroll instead of
/// overflowing.
class NestySheet extends StatelessWidget {
  const NestySheet({
    required this.title,
    required this.children,
    this.subtitle,
    this.showGrabber = true,
    this.gap = 12,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// Usually [SheetRow]s.
  final List<Widget> children;
  final bool showGrabber;

  /// Space between rows.
  final double gap;

  static const BorderRadius radius = BorderRadius.vertical(
    top: Radius.circular(AppRadii.sheet),
  );

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    // The frame's 40 px bottom includes the 34 px home indicator.
    final safeBottom = MediaQuery.maybeViewPaddingOf(context)?.bottom ?? 0;
    final bottom = math.max(22, safeBottom + 6).toDouble();
    return NestySurface(
      style: SurfaceStyles.sheet,
      radius: radius,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, 14, 22, bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showGrabber)
            const SizedBox(
              width: 44,
              height: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.sheetGrabber,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(
              title,
              style: AppTextStyles.sheetTitle,
              textAlign: TextAlign.center,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTextStyleTokens.body.copyWith(
                fontSize: 15,
                height: 1.4,
                color: AppColors.textBrown,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              // Room for the rows' 5 px edges and the highlighted ring.
              padding: const EdgeInsets.fromLTRB(3, 3, 3, 6),
              clipBehavior: Clip.none,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) SizedBox(height: gap),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
