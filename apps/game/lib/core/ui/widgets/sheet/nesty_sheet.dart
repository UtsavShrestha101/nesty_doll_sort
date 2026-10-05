import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
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
///
/// With a [titleAction] the title row is frame 8.2's instead (NestyMenus
/// language sheet): the title left-aligned at 26/700 with the action on
/// its right, 16 px under the grabber and 12 px above the rows.
class NestySheet extends StatelessWidget {
  const NestySheet({
    required this.title,
    required this.children,
    this.subtitle,
    this.titleAction,
    this.showGrabber = true,
    this.gap = 12,
    this.scrollFade,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// A trailing action on the title's row (frame 8.2's "Done").
  final Widget? titleAction;

  /// Usually [SheetRow]s.
  final List<Widget> children;
  final bool showGrabber;

  /// Space between rows.
  final double gap;

  /// A 16 dp fade of this colour over the scroll area's bottom edge while
  /// more rows are below (frame 8.2b's `#FCEBD0`). Null draws none.
  final Color? scrollFade;

  static const BorderRadius radius = BorderRadius.vertical(
    top: Radius.circular(AppRadii.sheet),
  );

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final titleAction = this.titleAction;
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
          if (titleAction == null) ...[
            const SizedBox(height: 20),
            Semantics(
              header: true,
              namesRoute: true,
              child: Text(
                title,
                style: AppTextStyles.sheetTitle,
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    namesRoute: true,
                    child: Text(title, style: AppTextStyleTokens.screenTitle),
                  ),
                ),
                const SizedBox(width: 12),
                titleAction,
              ],
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: context.scriptStyle(
                AppTextStyleTokens.body.copyWith(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textBrown,
                ),
                role: ScriptTextRole.body,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: titleAction == null ? 20 : 12),
          Flexible(
            child: _SheetScroll(
              fade: scrollFade,
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

/// The sheet's scrolling rows, with the optional bottom fade.
class _SheetScroll extends StatefulWidget {
  const _SheetScroll({required this.child, this.fade});

  final Widget child;
  final Color? fade;

  @override
  State<_SheetScroll> createState() => _SheetScrollState();
}

class _SheetScrollState extends State<_SheetScroll> {
  final ScrollController _controller = ScrollController();
  bool _moreBelow = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
    // The extent is known after the first layout.
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  void _update() {
    if (!mounted || !_controller.hasClients) return;
    final below = _controller.position.extentAfter > 0.5;
    if (below != _moreBelow) setState(() => _moreBelow = below);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = widget.fade;
    // Rows can grow (a new language's text), so the extent is re-read after
    // every layout.
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
    final scroll = SingleChildScrollView(
      controller: _controller,
      // Room for the rows' 5 px edges and the highlighted 3 px ring,
      // inside the clip. The clip keeps rows scrolled out of view from
      // painting over the title and the screen above (the dev level
      // picker's 200 tiles did, owner's review 2026-09-28).
      padding: const EdgeInsets.fromLTRB(3, 3, 3, 6),
      child: widget.child,
    );
    if (fade == null) return scroll;
    return Stack(
      children: [
        scroll,
        if (_moreBelow)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 16,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [fade.withValues(alpha: 0), fade],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
