import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/booster/booster_badge.dart';
import 'package:nesty_game/core/ui/widgets/booster/bump_scale.dart';
import 'package:nesty_game/core/ui/widgets/coins/reward_ring.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';
import 'package:nesty_game/core/ui/widgets/text/fit_text.dart';
import 'package:nesty_render/nesty_render.dart' show MotionTokens;

export 'package:nesty_game/core/ui/widgets/booster/booster_badge.dart';

/// The four boosters, for the words a screen reader says for each
/// (copy.md A11y `a11y_booster_*`).
enum BoosterButtonKind { undo, hint, slot, restart }

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
/// board says why in a toast), and a screen reader hears its limit badge
/// ("+Slot, 2 of 2 used", copy.md A11y `a11y_booster_slot_used`).
class BoosterButton extends StatelessWidget {
  const BoosterButton({
    required this.kind,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.shortLabel,
    this.badge,
    this.glow,
    this.width = 80,
    this.color = AppColors.iconBrown,
    this.spent = false,
    this.suggested = false,
    this.badgeBump = 0,
    this.badgeRing = false,
    this.gainTag,
    super.key,
  });

  /// Which booster this is: a screen reader says each by its own words
  /// (copy.md A11y `a11y_booster_*`), not by the visible [label].
  final BoosterButtonKind kind;

  /// A `NestyIcons.*` glyph (undo, lightbulb, add_box, restart_alt).
  final IconData icon;
  final String label;

  /// The ARB's short form, drawn when [label] doesn't fit the pad at
  /// textFit's `boosterLabels.minScale` 0.8 (a screen reader still hears
  /// [label]).
  final String? shortLabel;
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

  /// The chest flight's `relitGlow` ring round the badge while its sprite
  /// lands (frame 10.3d, F-CH2).
  final bool badgeRing;

  /// A green tag above the button (the chest's "+1" as its hint lands,
  /// frame 10.3d); null shows none.
  final String? gainTag;

  /// The glowing Restart of frame 12.7: nothing reads "Suggested" on
  /// screen, so a screen reader says it (copy.md A11y
  /// `a11y_booster_suggested`).
  final bool suggested;

  static const double height = 58;

  /// Half a 22 dp badge, to get from its corner offset to its centre.
  static const double _badgeHalf = 11;

  /// The sunk face (frame 12.9; tokens.json `color.disabledFace` and
  /// `disabledShade`: `#E8DCCB`, `inset 0 2 4 rgba(90,45,15,.2)`, no edge).
  static const SurfaceStyle spentStyle = SurfaceStyle(
    color: AppColorTokens.disabledFace,
    shadows: [
      NestyShadow(
        color: AppColorTokens.disabledShade,
        inset: true,
        dy: 2,
        blur: 4,
      ),
    ],
  );

  /// The muted glyph and label of a [spent] button (`color.disabledText`).
  static const Color spentColor = AppColorTokens.disabledText;

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
      semanticLabel: _semantics(context),
      excludeChildSemantics: true,
      child: Opacity(
        opacity: enabled || spent ? 1 : _disabledOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 25, color: spent ? spentColor : color),
            // Frame 12.9's disabled pad stacks its glyph and label 4 dp
            // apart (NestyMeta `slotCover`), the others 2.
            SizedBox(height: spent ? 4 : 2),
            FitText(
              label,
              short: shortLabel,
              minScale: TextFitTokens.boosterLabelsMinScale,
              style: AppTextStyleTokens.boosterLabel.copyWith(
                color: spent ? spentColor : color,
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
                  child: RewardRing.hint(
                    visible: badgeRing,
                    child: BoosterBadgeView(badge: badge),
                  ),
                ),
              ),
            ),
          if (gainTag != null && badge != null)
            Positioned(
              // `gainTag.offset` is from the badge's centre to the tag's
              // top-left (frame 10.3d). A badge is 22 dp tall and as wide as
              // its content; the count badge's is 22.
              left:
                  width +
                  badge.cornerOffset.dx -
                  _badgeHalf +
                  ChestCollectTokens.gainTagOffset.dx,
              top:
                  badge.cornerOffset.dy +
                  _badgeHalf +
                  ChestCollectTokens.gainTagOffset.dy,
              child: IgnorePointer(child: _GainTag(gainTag!)),
            ),
        ],
      ),
    );
  }

  /// The label a screen reader hears (copy.md A11y): the booster's own
  /// words, with its badge's state.
  String _semantics(BuildContext context) {
    final l10n = context.localizations;
    if (suggested) return l10n.boosterSuggestedSemantics(label);
    return switch (badge) {
      null =>
        kind == BoosterButtonKind.restart
            ? l10n.boosterRestartSemantics
            : label,
      BoosterCountBadge(:final count) => switch (kind) {
        BoosterButtonKind.undo => l10n.boosterUndoCountSemantics(count),
        BoosterButtonKind.hint => l10n.boosterHintCountSemantics(count),
        BoosterButtonKind.slot => l10n.boosterSlotCountSemantics(count),
        BoosterButtonKind.restart => l10n.boosterRestartSemantics,
      },
      BoosterAdBadge() => l10n.boosterAdSemantics(label),
      BoosterCoinBadge(:final price) => l10n.boosterCoinSemantics(label, price),
      BoosterInfiniteBadge() => l10n.boosterUndoUnlimitedSemantics,
      BoosterLimitBadge(:final used, :final total) =>
        l10n.boosterLimitSemantics(used, total),
    };
  }
}

/// The green "+N" tag over a booster that just gained some (tokens.json
/// `motion.chest.collect.gainTag`, frame 10.3d): Fredoka 700 13 white on
/// `#46A758`, edge `0 2px 0 #2F7A3E`, padding 3/8, radius 10. It pops in with
/// `motion.tagPop` (240 ms from 60 %, `easeOutBack`); under reduced motion it
/// just appears. The caller holds it for `gainTag.holdMs`.
class _GainTag extends StatelessWidget {
  const _GainTag(this.label);

  final String label;

  static const _style = SurfaceStyle(
    color: ChestCollectTokens.gainTagFace,
    shadows: ChestCollectTokens.gainTagEdge,
  );

  @override
  Widget build(BuildContext context) {
    final tag = NestySurface(
      style: _style,
      radius: BorderRadius.circular(ChestCollectTokens.gainTagRadius),
      padding: ChestCollectTokens.gainTagPadding,
      child: Text(
        label,
        style: ChestCollectTokens.gainTagFont.copyWith(height: 1),
      ),
    );
    if (context.reduceMotion) return tag;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: MotionTokens.tagPopFrom, end: 1),
      duration: const Duration(milliseconds: MotionTokens.tagPopMs),
      curve: MotionTokens.tagPopCurve,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        alignment: Alignment.topLeft,
        child: child,
      ),
      child: tag,
    );
  }
}
