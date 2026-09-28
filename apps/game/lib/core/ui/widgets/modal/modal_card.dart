import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/nesty_close_button.dart';
import 'package:nesty_game/core/ui/widgets/modal/ribbon_title.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';

export 'package:nesty_game/core/ui/widgets/modal/ribbon_title.dart';

/// "Modal card: left/right 24–32, radius 32, surface gradient, card shadow.
/// Orange ribbon title pill at top −18 […]. Close button at top-right,
/// inset 12" (design/README.md "Components"; NestyOverlay Pause 3.9, buy
/// popups 3.2/3.3).
///
/// The caller places the card (its horizontal margin, its top) and gives it
/// a scrim; the card lays [child] out in a column-friendly box. With a
/// [title] the padding is the frames' `40 22 22` so content clears the
/// ribbon; without, `22 20 22` (intro cards). The ribbon overhangs the top
/// by [RibbonTitle.overhang]: leave that much room above the card.
///
/// [title] draws the default orange [RibbonTitle]; [ribbon] replaces it
/// with another style of ribbon, such as the day-7 chest's
/// [RibbonTitle.streak] (NestyMenus 5.6). Give one or the other.
class ModalCard extends StatelessWidget {
  const ModalCard({
    required this.child,
    this.title,
    this.ribbon,
    this.onClose,
    this.closeSemanticLabel,
    this.padding,
    super.key,
  }) : assert(title == null || ribbon == null, 'a title or a ribbon');

  final Widget child;
  final String? title;

  /// A ribbon other than the default `RibbonTitle(title)`; the padding is
  /// the titled one.
  final RibbonTitle? ribbon;

  /// Shows the close button when set.
  final VoidCallback? onClose;
  final String? closeSemanticLabel;

  /// Overrides the default padding.
  final EdgeInsetsGeometry? padding;

  static const EdgeInsets titledPadding = EdgeInsets.fromLTRB(22, 40, 22, 22);
  static const EdgeInsets plainPadding = EdgeInsets.fromLTRB(20, 22, 20, 22);

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final ribbon = this.ribbon ?? (title == null ? null : RibbonTitle(title));
    final onClose = this.onClose;
    final card = NestySurface(
      style: SurfaceStyles.card,
      radius: const BorderRadius.all(Radius.circular(AppRadii.card)),
      width: double.infinity,
      padding: padding ?? (ribbon == null ? plainPadding : titledPadding),
      child: child,
    );
    if (ribbon == null && onClose == null) return card;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        if (ribbon != null)
          Positioned(
            top: -RibbonTitle.overhang,
            // The ribbon keeps clear of the close button on both sides.
            left: 56,
            right: 56,
            child: Center(child: ribbon),
          ),
        if (onClose != null)
          PositionedDirectional(
            top: NestyCloseButton.boxInset(12),
            end: NestyCloseButton.boxInset(12),
            child: NestyCloseButton(
              onPressed: onClose,
              semanticLabel: closeSemanticLabel,
            ),
          ),
      ],
    );
  }
}
