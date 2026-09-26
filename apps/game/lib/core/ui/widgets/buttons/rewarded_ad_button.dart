import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/ad_play_glyph.dart';
import 'package:nesty_game/core/ui/widgets/buttons/tactile_button.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';

/// "Rewarded ad button: primary shape in the ad gradient, 6px edge
/// `#5530A8`. Leading white 30×24 radius-7 box holding a purple play
/// triangle" (design/README.md "Components").
///
/// Rewarded videos are optional and only play on a ▶ tap (spec §9.1). When
/// no ad can be shown ([available] false: offline, not loaded, ads off),
/// the button is not shown at all: "Offline: hidden, or replaced by the
/// coin price". [claimed] shows frame 2.9's "Reward added" state.
class RewardedAdButton extends StatelessWidget {
  const RewardedAdButton({
    required this.label,
    required this.onPressed,
    this.available = true,
    this.claimed = false,
    this.size = TactileButtonSize.large,
    this.expand = true,
    super.key,
  }) : compact = false;

  /// The 44×40 ▶-only button of a sheet row (NestyOverlay OOM "+1 Slot").
  const RewardedAdButton.compact({
    required this.onPressed,
    this.available = true,
    super.key,
  }) : label = null,
       claimed = false,
       size = TactileButtonSize.compact,
       expand = false,
       compact = true;

  /// "×3 coins", "Watch ad", "Double it". Null only for [compact].
  final String? label;
  final VoidCallback? onPressed;
  final bool available;
  final bool claimed;
  final TactileButtonSize size;
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!available && !claimed) return const SizedBox.shrink();
    if (compact) {
      return TactileSurface(
        style: SurfaceStyles.adChip,
        disabledStyle: SurfaceStyles.disabled,
        radius: BorderRadius.circular(14),
        onPressed: onPressed,
        width: 44,
        height: 40,
        semanticLabel: context.localizations.watchAdSemantics,
        excludeChildSemantics: true,
        child: const Padding(
          padding: EdgeInsetsDirectional.only(start: 3),
          child: AdPlayGlyph.bare(),
        ),
      );
    }
    if (claimed) return _Claimed(label: context.localizations.winRewardAdded);
    return TactileButton(
      label: label!,
      onPressed: onPressed,
      variant: TactileButtonVariant.ad,
      size: size,
      expand: expand,
      leading: AdPlayGlyph(boxWidth: size == TactileButtonSize.large ? 30 : 26),
    );
  }
}

/// "The ad button becomes 'Reward added' (`#E9DDF9`, check icon)" — frame
/// 2.9. Not pressable.
class _Claimed extends StatelessWidget {
  const _Claimed({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyleTokens.button.copyWith(
      fontSize: 18,
      color: AppColorTokens.adEdge,
    );
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: NestySurface(
        style: SurfaceStyles.adClaimed,
        radius: BorderRadius.circular(TactileButtonSize.large.radius),
        width: double.infinity,
        height: TactileButtonSize.large.height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                NestyIcons.checkCircle,
                size: 24,
                color: AppColorTokens.adEdge,
              ),
              const SizedBox(width: 8),
              Text(label, style: style, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
