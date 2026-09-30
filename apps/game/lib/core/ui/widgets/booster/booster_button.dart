import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/booster/booster_badge.dart';
import 'package:nesty_game/core/ui/widgets/booster/bump_scale.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';

export 'package:nesty_game/core/ui/widgets/booster/booster_badge.dart';

/// "Booster button: 80×58, radius 18, surface gradient, 5px edge `#CFA36A`,
/// 25px glyph plus 13/600 label. Badges sit at top-right" (design/README.md
/// "Components"; NestyBoard booster bar). The bar sizes it
/// `min(80, (W − 56) / 4)` wide ([width]).
///
/// [glow] is the soft-stuck suggestion (frame 3.4: `ui_booster_glow`, a
/// Lottie the screens lane passes in). It is drawn behind the button in a
/// 130×110 box centred on it, as LOTTIE.md anchors it.
///
/// Disabled ([onPressed] null, e.g. nothing to undo) it can't be pressed and
/// its glyph and label fade; the badge stays readable.
///
/// [spent] is frame 12.9's face for a booster the level has no more of (+1
/// Slot at its limit of 2): the sunk `#E8DCCB` face with no edge, its glyph
/// and label `#A48B72`, and the "2/2" [badge]. It still takes a tap (the
/// board says why in a toast), and a screen reader hears it as disabled with
/// [spentLabel].
class BoosterButton extends StatelessWidget {
  const BoosterButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.badge,
    this.glow,
    this.width = 80,
    this.color = AppColors.iconBrown,
    this.spent = false,
    this.spentLabel,
    this.semanticHint,
    this.badgeBump = 0,
    this.gainTag,
    super.key,
  });

  /// A `NestyIcons.*` glyph (undo, lightbulb, add_box, restart_alt).
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final BoosterBadge? badge;

  /// Drawn behind the button (the `ui_booster_glow` Lottie).
  final Widget? glow;
  final double width;

  /// Glyph and label colour: brown, or `#2F7A3E` for +Slot (NestyBoard
  /// `BST`).
  final Color color;

  /// Frame 12.9's sunk face and its muted glyph and label.
  final bool spent;

  /// The badge bumps 1.3× for 240 ms each time this changes.
  final int badgeBump;

  /// A green tag above the button (the chest's "+1" as its hint lands,
  /// frame 10.3d); null shows none.
  final String? gainTag;

  /// A screen-reader hint after the label ("Suggested" on a glowing
  /// Restart, frame 12.7).
  final String? semanticHint;

  /// What a screen reader says for a [spent] button ("+1 Slot, 2 of 2
  /// used").
  final String? spentLabel;

  static const double height = 58;

  /// The sunk face (frame 12.9: `#E8DCCB`, `inset 0 2 4 rgba(90,45,15,.2)`,
  /// no edge).
  // TODO(design): add the disabled booster face to tokens.json.
  static const SurfaceStyle spentStyle = SurfaceStyle(
    color: Color(0xFFE8DCCB),
    shadows: [
      NestyShadow(color: Color(0x335A2D0F), inset: true, dy: 2, blur: 4),
    ],
  );

  /// The muted glyph and label of a [spent] button.
  static const Color spentColor = Color(0xFFA48B72);

  /// The glow's box (LOTTIE.md `ui_booster_glow`, 130×110).
  static const Size glowSize = Size(130, 110);

  static const double _disabledOpacity = 0.45;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final button = TactileSurface(
      style: spent ? spentStyle : SurfaceStyles.booster,
      radius: const BorderRadius.all(Radius.circular(AppRadii.booster)),
      onPressed: onPressed,
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      semanticLabel: _labelWithHint(context),
      excludeChildSemantics: true,
      child: Opacity(
        opacity: enabled || spent ? 1 : _disabledOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 25, color: spent ? spentColor : color),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: AppTextStyleTokens.boosterLabel.copyWith(
                  color: spent ? spentColor : color,
                ),
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
    final badge = this.badge;
    final glow = this.glow;
    if (badge == null && glow == null) return button;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (glow != null)
            Positioned(
              left: (width - glowSize.width) / 2,
              top: (height - glowSize.height) / 2,
              width: glowSize.width,
              height: glowSize.height,
              child: IgnorePointer(child: glow),
            ),
          Positioned.fill(child: button),
          if (badge != null)
            PositionedDirectional(
              end: -badge.cornerOffset.dx,
              top: badge.cornerOffset.dy,
              child: IgnorePointer(
                child: BumpScale(
                  trigger: badgeBump,
                  child: BoosterBadgeView(badge: badge),
                ),
              ),
            ),
          if (gainTag != null)
            Positioned(
              left: 0,
              right: 0,
              top: -30,
              child: IgnorePointer(child: Center(child: _GainTag(gainTag!))),
            ),
        ],
      ),
    );
  }

  String _labelWithHint(BuildContext context) {
    final base = spent ? (spentLabel ?? label) : _semantics(context);
    final hint = semanticHint;
    return hint == null ? base : '$base. $hint';
  }

  String _semantics(BuildContext context) {
    final l10n = context.localizations;
    return switch (badge) {
      null => label,
      BoosterCountBadge(:final count) => l10n.boosterCountSemantics(
        label,
        count,
      ),
      BoosterAdBadge() => l10n.boosterAdSemantics(label),
      BoosterCoinBadge(:final price) => l10n.boosterCoinSemantics(label, price),
      BoosterInfiniteBadge() => l10n.boosterUndoUnlimitedSemantics(label),
      BoosterLimitBadge(:final used, :final total) =>
        l10n.boosterLimitSemantics(label, used, total),
    };
  }
}

/// The green "+1" tag over a booster that just gained one (frame 10.3d:
/// Fredoka 700 13 white on `#46A758`, edge `#2F7A3E`, padding 3/8, radius
/// 10; frame-only colours).
// TODO(design): add the "+1" tag's colours to tokens.json.
class _GainTag extends StatelessWidget {
  const _GainTag(this.label);

  final String label;

  static const _style = SurfaceStyle(
    color: AppColorTokens.success,
    shadows: [NestyShadow(color: Color(0xFF2F7A3E), dy: 2)],
  );

  @override
  Widget build(BuildContext context) => NestySurface(
    style: _style,
    radius: const BorderRadius.all(Radius.circular(10)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    child: Text(
      label,
      style: AppTextStyleTokens.number.copyWith(
        fontSize: 13,
        height: 1,
        color: const Color(0xFFFFFFFF),
      ),
    ),
  );
}
