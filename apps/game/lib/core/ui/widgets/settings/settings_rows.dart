import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_feedback.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';
import 'package:nesty_game/core/ui/widgets/toggle/nesty_toggle.dart';

/// The 44 dp icon tile of frames 10.2e and 10.2f (radius 14, a tint under a
/// tinted glyph; ui-spec-menus §7.1): [face] fills it, [glyph] colours the
/// icon. A row without one keeps the bare icon (Records).
@immutable
class SettingsTile {
  const SettingsTile({required this.face, required this.glyph});

  /// Sound, Music, Haptics, Language, Restore and the other links: the wood
  /// tint at half strength under the secondary text colour.
  static final wood = SettingsTile(
    face: AppColorTokens.woodLight.withValues(alpha: 0.5),
    glyph: AppColorTokens.textSecondary,
  );

  /// The reminder bell and its Time row (`dailyTop` at .35, `coinText`).
  static final reminder = SettingsTile(
    face: AppColorTokens.dailyTop.withValues(alpha: 0.35),
    glyph: AppColorTokens.coinText,
  );

  /// The reminder blocked by the phone (frame 10.2f): the wood tile.
  static final reminderOff = wood;

  /// Relaxed mode.
  static const relaxed = SettingsTile(
    face: AppColorTokens.successTint,
    glyph: AppColorTokens.success,
  );

  /// Reduce motion.
  static const motion = SettingsTile(
    face: AppColorTokens.iceTint,
    glyph: AppColorTokens.iceEdge,
  );

  final Color face;
  final Color glyph;

  /// The tile's side.
  static const double size = 44;

  /// The gap between the tile and its text: the text column starts at
  /// [size] + [gap] (frame 10.2f's Open phone settings pill lines up with
  /// it).
  static const double gap = 14;
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon, required this.tile});

  final IconData icon;
  final SettingsTile? tile;

  @override
  Widget build(BuildContext context) {
    final tile = this.tile;
    if (tile == null) {
      return Icon(icon, size: 24, color: AppColorTokens.textSecondary);
    }
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: SettingsTile.size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tile.face,
            borderRadius: const BorderRadius.all(Radius.circular(14)),
          ),
          child: Icon(icon, size: 24, color: tile.glyph),
        ),
      ),
    );
  }
}

/// A rounded card grouping [SettingsRow]/[SettingsToggleRow] children with a
/// dashed divider between them (design/README.md "08 Settings & system",
/// frame 8.1's toggles and link cards). With [tiled] (the m7-3 Settings,
/// frames 10.2e and 10.2f) the divider is a solid 1 px line inset by the
/// icon tile's width.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.tiled = false,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final bool tiled;

  // TODO(design): #F0E0C4 is frame-only (10.2e); ask for a tokens.json color.
  static const _tiledDivider = Color(0xFFF0E0C4);

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
    ],
  );

  @override
  Widget build(BuildContext context) => NestySurface(
    style: _style,
    radius: const BorderRadius.all(Radius.circular(24)),
    width: double.infinity,
    padding: padding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            tiled
                ? const Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: SettingsTile.size + SettingsTile.gap + 14,
                    ),
                    child: SizedBox(
                      height: 1,
                      width: double.infinity,
                      child: ColoredBox(color: _tiledDivider),
                    ),
                  )
                : const _DashedDivider(),
          children[i],
        ],
      ],
    ),
  );
}

/// A settings link row: an icon, its label, an optional trailing [value]
/// and a chevron (frame 8.1's Language/Restore Purchases/Privacy/Support
/// rows). With [onTap] null the row is shown but unresponsive (Restore
/// Purchases and Privacy choices, disabled until M6). With a [tile] the
/// icon sits on its 44 dp tile and the label is Fredoka (frames 10.2e and
/// 10.2f).
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.showChevron = true,
    this.tile,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool showChevron;
  final VoidCallback? onTap;
  final SettingsTile? tile;

  static const _transparent = SurfaceStyle(
    color: Color(0x00000000),
    shadows: [],
  );

  /// The row's least height: a full touch target.
  static const double minHeight = 48;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    final tile = this.tile;
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      // 12 + 12 around the 23 px icon is 47: at least 48 dp for its target
      // (spec §10.3; m7-design §15, review R21).
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minHeight),
        child: TactileSurface(
          style: _transparent,
          radius: BorderRadius.zero,
          onPressed: onTap,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: tile == null ? 12 : 8),
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            children: [
              if (tile == null)
                Icon(icon, size: 23, color: AppColorTokens.textSecondary)
              else
                _TileIcon(icon: icon, tile: tile),
              SizedBox(width: tile == null ? 12 : SettingsTile.gap),
              Expanded(
                child: Text(
                  label,
                  style: tile == null
                      ? AppTextStyleTokens.row.copyWith(fontSize: 16)
                      : _tiledTitle,
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                Text(
                  value,
                  style: AppTextStyleTokens.caption.copyWith(
                    fontSize: 14,
                    height: 1,
                    color: tile == null
                        ? AppColorTokens.textMuted
                        : AppColorTokens.textSecondary,
                  ),
                ),
              ],
              if (showChevron) ...[
                const SizedBox(width: 4),
                const Icon(
                  NestyIcons.chevronRight,
                  size: 22,
                  color: AppColors.chevron,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A tiled row's title: Fredoka 700 19 (ui-spec-menus §0.12).
final TextStyle _tiledTitle = AppTextStyleTokens.cardTitle.copyWith(
  fontSize: 19,
  height: 1.15,
  color: AppColorTokens.textPrimary,
);

/// A tiled row's subtitle: Nunito 700 13, `textSecondary`.
final TextStyle _tiledSubtitle = AppTextStyleTokens.caption.copyWith(
  fontSize: 13,
  color: AppColorTokens.textSecondary,
);

/// A settings toggle row: an icon, its label and a [NestyToggle] (frame
/// 8.1's Sound/Music/Haptics).
///
/// An optional [subtitle] (docs/plans/m7-design.md §15.5: Relaxed mode's
/// "Unlimited free undo", `caption`/`textMuted`, wraps) sits under the
/// label; existing rows that don't pass one are unchanged. With a [tile]
/// the icon sits on its 44 dp tile (frames 10.2e and 10.2f), and a [footer]
/// (the blocked reminder's "Open phone settings" pill) sits under the text,
/// on the text's own column.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.tile,
    this.footer,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? subtitle;
  final SettingsTile? tile;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final tile = this.tile;
    final footer = this.footer;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tile == null ? 12 : 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _TileIcon(icon: icon, tile: tile),
              SizedBox(width: tile == null ? 12 : SettingsTile.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: tile == null
                          ? AppTextStyleTokens.row
                          : _tiledTitle,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: tile == null
                            ? AppTextStyleTokens.caption.copyWith(
                                fontSize: 12,
                                color: AppColorTokens.textMuted,
                              )
                            : _tiledSubtitle,
                      ),
                  ],
                ),
              ),
              NestyToggle(
                value: value,
                onChanged: onChanged,
                semanticLabel: label,
              ),
            ],
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: SettingsTile.size + SettingsTile.gap,
                top: 4,
              ),
              child: footer,
            ),
        ],
      ),
    );
  }
}

/// A pill button inside a settings row (frame 10.2f's "Open phone
/// settings"): 44 tall, radius 16, white with a 4 px edge, a 20 dp glyph and
/// a Fredoka 16 label. Its touch area is padded to 48 dp.
class SettingsPillButton extends StatelessWidget {
  const SettingsPillButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  static const double height = 44;

  static const _style = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4)],
  );

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: TactileSurface(
      style: _style,
      radius: const BorderRadius.all(Radius.circular(16)),
      onPressed: onPressed,
      height: height,
      minTouchSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColorTokens.textPrimary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyleTokens.buttonSmall.copyWith(
                fontSize: 16,
                color: AppColorTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// One option of a [SettingsSegmentedRow].
@immutable
class SettingsSegment<T> {
  const SettingsSegment({required this.value, required this.label});

  final T value;
  final String label;
}

/// A settings row whose choice is an inline segmented control under the
/// title (Reduce motion's Off · On · System, frames 10.2e and 10.2f; Q146;
/// ui-spec-menus §7.4): a sunk track with a raised thumb under the chosen
/// segment. The thumb glides over 180 ms (`motion.ui.tabLift`), and snaps
/// under reduced motion. Each segment is at least 48 dp tall to touch, and
/// the group reads as one radio group named [label] with the choice as its
/// value.
class SettingsSegmentedRow<T> extends StatelessWidget {
  const SettingsSegmentedRow({
    required this.icon,
    required this.label,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.tile,
    super.key,
  });

  final IconData icon;
  final String label;
  final List<SettingsSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final SettingsTile? tile;

  /// The track: 48 dp, so every segment's touch area is a full 48 (the
  /// spec's 44 grows by the hit-target rule).
  static const double trackHeight = 48;
  static const double _inset = 4;

  static const _trackStyle = SurfaceStyle(
    color: AppColorTokens.surfaceTrack,
    shadows: [NestyShadow(color: AppColors.divider, inset: true, dy: 2)],
  );

  static const _thumbStyle = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 3)],
  );

  @override
  Widget build(BuildContext context) {
    final tile = this.tile;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final index = math.max(0, segments.indexWhere((s) => s.value == selected));
    final current = segments[index].label;
    return Semantics(
      container: true,
      label: label,
      value: current,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Row(
                children: [
                  _TileIcon(icon: icon, tile: tile),
                  SizedBox(width: tile == null ? 12 : SettingsTile.gap),
                  Expanded(
                    child: Text(
                      label,
                      style: tile == null
                          ? AppTextStyleTokens.row
                          : _tiledTitle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: tile == null ? 0 : SettingsTile.size + SettingsTile.gap,
              ),
              child: NestySurface(
                style: _trackStyle,
                radius: const BorderRadius.all(Radius.circular(24)),
                height: trackHeight,
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final segmentWidth =
                        (constraints.maxWidth - 2 * _inset) / segments.length;
                    return Stack(
                      children: [
                        AnimatedPositionedDirectional(
                          duration: Duration(
                            milliseconds: reduced
                                ? 0
                                : UiMotionTokens.tabLiftMs,
                          ),
                          curve: UiMotionTokens.curveEaseOut,
                          start: _inset + index * segmentWidth,
                          top: _inset,
                          width: segmentWidth,
                          height: trackHeight - 2 * _inset,
                          child: const NestySurface(
                            style: _thumbStyle,
                            radius: BorderRadius.all(Radius.circular(20)),
                            child: SizedBox.expand(),
                          ),
                        ),
                        Row(
                          children: [
                            const SizedBox(width: _inset),
                            for (final segment in segments)
                              SizedBox(
                                width: segmentWidth,
                                height: trackHeight,
                                child: _Segment(
                                  label: segment.label,
                                  selected: segment.value == selected,
                                  onTap: () => onChanged(segment.value),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    void activate() {
      if (selected) return;
      TactileFeedback.of(context)?.activate();
      onTap();
    }

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      onTap: activate,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: activate,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyleTokens.buttonSmall.copyWith(
              fontSize: 16,
              color: selected
                  ? AppColorTokens.textPrimary
                  : AppColorTokens.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 1, child: CustomPaint(painter: _DashPainter()));
}

final class _DashPainter extends CustomPainter {
  const _DashPainter();

  static const _dash = 4.0;
  static const _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(math.min(x + _dash, size.width), 0),
        paint,
      );
      x += _dash + _gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => false;
}
