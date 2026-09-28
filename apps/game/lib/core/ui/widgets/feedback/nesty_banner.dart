import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// Banner tones (design/README.md "Banners / toasts"): warning (soft stuck
/// 3.4), danger ("Offline", 3.7), success, info (ice, "Streak saved!").
enum NestyBannerTone {
  warning(
    surface: SurfaceStyle(
      color: AppColorTokens.warningTint,
      shadows: [
        NestyShadow(color: AppColors.warningHighlight, inset: true, dy: 2),
        NestyShadow(color: AppColorTokens.warningEdge, dy: 4),
        NestyShadow(color: Color(0x33783C14), dy: 8, blur: 14),
      ],
    ),
    iconFace: AppColorTokens.primary,
    title: AppColorTokens.textPrimary,
    message: AppColorTokens.textSecondary,
  ),
  danger(
    surface: SurfaceStyle(
      color: AppColorTokens.dangerTint,
      shadows: [
        NestyShadow(color: AppColors.dangerHighlight, inset: true, dy: 2),
        NestyShadow(color: AppColorTokens.dangerTintEdge, dy: 4),
      ],
    ),
    iconFace: AppColorTokens.danger,
    title: AppColorTokens.textPrimary,
    message: AppColorTokens.textSecondary,
  ),

  /// Frame 8.3's "Purchases restored" toast pins the exact colours.
  success(
    surface: SurfaceStyle(
      color: AppColors.successBannerFace,
      shadows: [
        NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
        NestyShadow(color: AppColorTokens.successRing, dy: 4),
      ],
    ),
    iconFace: AppColorTokens.success,
    title: AppColors.successToastTitle,
    message: AppColors.successToastMessage,
  ),
  info(
    surface: SurfaceStyle(
      color: AppColors.infoFace,
      shadows: [
        NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
        NestyShadow(color: AppColors.infoEdge, dy: 4),
        NestyShadow(color: Color(0x401E3C64), dy: 12, blur: 24),
      ],
    ),
    iconGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColorTokens.iceTop, AppColorTokens.ice],
    ),
    title: AppColors.infoTitle,
    message: AppColors.infoText,
  );

  const NestyBannerTone({
    required this.surface,
    required this.title,
    required this.message,
    this.iconFace,
    this.iconGradient,
  });

  final SurfaceStyle surface;
  final Color? iconFace;
  final Gradient? iconGradient;
  final Color title;
  final Color message;
}

/// A banner: an icon disc, a Fredoka 16/700 title, a Nunito 12/700 line
/// and an optional trailing [action] (the soft-stuck banner's Undo, frame
/// 3.4; NestyBoard / NestyOverlay).
///
/// Its height follows its text, so 1.3× text and long translations wrap
/// instead of overflowing. Screen readers announce it when it appears. The
/// caller positions it (e.g. left/right 20, top 152) and animates it in.
class NestyBanner extends StatelessWidget {
  const NestyBanner({
    required this.tone,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.iconSize = 30,
    super.key,
  });

  final NestyBannerTone tone;

  /// A `NestyIcons.*` glyph (sentiment_neutral, wifi_off, ac_unit, …).
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  /// The icon disc's diameter: 30 inline (the default), 40 for a
  /// [NestyToast] (frames 5.2, 8.3).
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    final action = this.action;
    final text = Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyleTokens.cardTitle.copyWith(
              fontSize: 16,
              color: tone.title,
            ),
          ),
          if (message != null)
            Text(
              message,
              style: AppTextStyleTokens.caption.copyWith(
                height: 1.3,
                color: tone.message,
              ),
            ),
        ],
      ),
    );
    return NestySurface(
      style: tone.surface,
      radius: BorderRadius.circular(tone == NestyBannerTone.info ? 22 : 20),
      padding: action == null
          ? const EdgeInsetsDirectional.fromSTEB(10, 9, 16, 9)
          : const EdgeInsetsDirectional.fromSTEB(12, 9, 9, 9),
      child: Row(
        children: [
          _IconDisc(icon: icon, tone: tone, dimension: iconSize),
          const SizedBox(width: 10),
          Expanded(child: text),
          if (action != null) ...[const SizedBox(width: 10), action],
        ],
      ),
    );
  }
}

class _IconDisc extends StatelessWidget {
  const _IconDisc({
    required this.icon,
    required this.tone,
    this.dimension = 30,
  });

  final IconData icon;
  final NestyBannerTone tone;
  final double dimension;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: dimension,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tone.iconFace,
        gradient: tone.iconGradient,
      ),
      child: Icon(
        icon,
        size: dimension * 2 / 3,
        color: const Color(0xFFFFFFFF),
      ),
    ),
  );
}
