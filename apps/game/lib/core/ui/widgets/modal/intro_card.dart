import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/tactile_button.dart';
import 'package:nesty_game/core/ui/widgets/modal/modal_card.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/wood/plank_strip.dart';

/// A mechanic intro card (design/README.md "4.1–4.3, 4.8 Intro cards": "'NEW'
/// chip (or 'v1.1' for gold), title 34/700, a 302×230 illustration with
/// plank, text 16/600, 'Got it'"; docs/plans/m3-design.md §10.4).
///
/// [illustration] is the mechanic's art (towers, glass, ice), drawn over the
/// plank inside the 302×230 slot: the mechanic's intro loop (`ui_intro_*`,
/// m7-3's D) or, without its file or skin, the still picture.
class IntroCard extends StatelessWidget {
  const IntroCard({
    required this.badgeLabel,
    required this.title,
    required this.text,
    required this.onGotIt,
    this.illustration,
    super.key,
  });

  /// "NEW" ([introNew]) or "v1.1" for a later gold-doll card.
  final String badgeLabel;
  final String title;
  final String text;
  final Widget? illustration;
  final VoidCallback onGotIt;

  static const Size illustrationSize = Size(302, 230);

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NewChip(badgeLabel),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyleTokens.h1.copyWith(fontSize: 34, height: 1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _Illustration(illustration: illustration),
          const SizedBox(height: 16),
          Text(
            text,
            style: context.scriptStyle(
              AppTextStyleTokens.body.copyWith(
                fontSize: 16,
                height: 1.45,
                color: AppColorTokens.iconBrown,
              ),
              role: ScriptTextRole.body,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TactileButton(
            label: context.localizations.introGotIt,
            onPressed: onGotIt,
          ),
        ],
      ),
    );
  }
}

class _NewChip extends StatelessWidget {
  const _NewChip(this.label);

  final String label;

  static const _style = SurfaceStyle(
    color: AppColorTokens.badge,
    shadows: [NestyShadow(color: AppColorTokens.badgeEdge, dy: 3)],
  );

  @override
  Widget build(BuildContext context) => NestySurface(
    style: _style,
    radius: const BorderRadius.all(Radius.circular(10)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    child: Text(
      label,
      style: AppTextStyleTokens.tierChip.copyWith(
        fontSize: 12,
        letterSpacing: context.script.tracking(1.44),
        color: const Color(0xFFFFFFFF),
      ),
    ),
  );
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.illustration});

  final Widget? illustration;

  /// The slot's `#FCEBCB → #F3D4A0` background; not in tokens.json.
  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFCEBCB), Color(0xFFF3D4A0)],
  );

  @override
  Widget build(BuildContext context) {
    final illustration = this.illustration;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox.fromSize(
        size: IntroCard.illustrationSize,
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: _gradient),
          child: Stack(
            children: [
              const PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 12,
                child: PlankStrip(height: 30),
              ),
              if (illustration != null) Positioned.fill(child: illustration),
            ],
          ),
        ),
      ),
    );
  }
}
