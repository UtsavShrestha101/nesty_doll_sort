import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/lottie/lottie_text_overlay.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/text/fit_text.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_ribbon.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';

/// The race results' ribbon (frames 9.4, 9.5; ui-spec-game §1
/// "VersusRibbonTitle"): `ui_win_ribbon` recoloured to versus's indigo by its
/// named fills, `tokens.versus.ribbon` (band `#4E5FD9`, edge `#3242A8`, tail
/// `#4250C6`, fold `#1F297F`; m7-4 4.3: no separate file), with the title in
/// the ribbon's white Fredoka. It plays the ribbon's pop once, and rests on
/// its last frame under reduced motion.
///
/// A modal's title: it is a header that names the overlay's route, read as
/// [title]. It is drawn at full size; on a phone narrower than 360 dp its
/// band narrows to the screen − 70, as the win card's does (LOTTIE.md
/// m7-5). Without the file (rule 3, R10) a [RibbonRestPainter] draws its
/// rest look.
class VersusRibbon extends StatefulWidget {
  const VersusRibbon({
    required this.title,
    this.shortTitle,
    this.library,
    super.key,
  });

  final String title;

  /// The ARB's short form (`raceWinTitleShort`, `raceLossTitleShort`),
  /// drawn when [title] needs more than textFit.winRibbon's `minScale`.
  final String? shortTitle;

  /// The FX library (the DI one by default).
  final FxLibrary? library;

  /// The ribbon's canvas (`ui_win_ribbon`'s, 410×110), centred on the band.
  static const Size canvas = Size(410, 110);

  @override
  State<VersusRibbon> createState() => _VersusRibbonState();
}

class _VersusRibbonState extends State<VersusRibbon> {
  final LottieFxController _controller = LottieFxController(FxId.uiWinRibbon);

  @override
  void initState() {
    super.initState();
    _controller.params.setRibbonColors(WinRibbonTokens.versusColors);
    _controller.playWhole();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The band is 290, or the screen − 70 on a narrower phone (m7-5), and
    // the title's box narrows with it.
    final bandWidth = FxRibbon.win.bandWidthFor(
      MediaQuery.sizeOf(context).width,
    );
    _controller.params.ribbonBandWidth = bandWidth;
    final style = FxRibbon.win.labelFor(bandWidth);
    final shortTitle = widget.shortTitle;
    final label = shortTitle == null
        ? widget.title
        : RibbonLabel.pick(
            context,
            style: style,
            full: widget.title,
            short: shortTitle,
            minScale: TextFitTokens.winRibbonMinScale,
          );
    return Semantics(
      header: true,
      namesRoute: true,
      label: widget.title,
      excludeSemantics: true,
      child: SizedBox(
        width: VersusRibbon.canvas.width,
        height: VersusRibbon.canvas.height,
        child: LottieTextOverlay(
          label: label,
          semanticLabel: widget.title,
          style: style,
          lottie: LottieFxView(
            id: FxId.uiWinRibbon,
            controller: _controller,
            library: widget.library,
            label: label,
            labelStyle: style,
            fallback: CustomPaint(
              painter: RibbonRestPainter(
                ribbon: FxRibbon.win,
                colors: WinRibbonTokens.versusColors,
                bandWidth: bandWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
