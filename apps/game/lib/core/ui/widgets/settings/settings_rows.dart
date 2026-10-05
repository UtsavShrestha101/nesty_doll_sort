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

/// The icon tile of frames 10.2e, 10.2f and 10.2h (tokens
/// `layout.settingsRows.iconTiles`: 36 dp, radius 12, a 22 dp glyph): [face]
/// fills it, [glyph] colours the icon. A row without one keeps the bare icon
/// (Records).
@immutable
class SettingsTile {
  const SettingsTile({required this.face, required this.glyph});

  /// Sound, Music, Haptics, Language, Restore, the other links and a reminder
  /// that is switched off (10.2h): `default`, `#F6E2C2` under `#6E4526`.
  static final wood = SettingsTile(
    face: SettingsRowsTokens.iconTilesDefault[0],
    glyph: SettingsRowsTokens.iconTilesDefault[1],
  );

  /// The reminder bell and its Time row while it is on: `reminder`.
  static final reminder = SettingsTile(
    face: SettingsRowsTokens.iconTilesReminder[0],
    glyph: SettingsRowsTokens.iconTilesReminder[1],
  );

  /// The reminder blocked by the phone (frame 10.2f): `reminderBlocked`.
  static final reminderOff = SettingsTile(
    face: SettingsRowsTokens.iconTilesReminderBlocked[0],
    glyph: SettingsRowsTokens.iconTilesReminderBlocked[1],
  );

  /// Relaxed mode.
  static final relaxed = SettingsTile(
    face: SettingsRowsTokens.iconTilesRelaxed[0],
    glyph: SettingsRowsTokens.iconTilesRelaxed[1],
  );

  /// Reduce motion.
  static final motion = SettingsTile(
    face: SettingsRowsTokens.iconTilesReduceMotion[0],
    glyph: SettingsRowsTokens.iconTilesReduceMotion[1],
  );

  final Color face;
  final Color glyph;

  /// The tile's side.
  static const double size = SettingsRowsTokens.iconTilesSize;

  /// The gap between the tile and its text (NestyHub:151: 12): the text
  /// column starts at [size] + [gap] (the blocked row's actions line up with
  /// it).
  static const double gap = 12;
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
            borderRadius: const BorderRadius.all(
              Radius.circular(SettingsRowsTokens.iconTilesRadius),
            ),
          ),
          child: Icon(
            icon,
            size: SettingsRowsTokens.iconTilesGlyph,
            color: tile.glyph,
          ),
        ),
      ),
    );
  }
}

/// A rounded card grouping [SettingsRow]/[SettingsToggleRow] children with a
/// dashed divider between them (design/README.md "08 Settings & system",
/// frame 8.1's toggles and link cards). With [tiled] (the m7-3 Settings,
/// frames 10.2e, 10.2f and 10.2h) the card is the frame's flat white one
/// (radius 22, 14 dp inside) and the divider a solid 1.5 dp line across it.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.children,
    this.padding = _defaultPadding,
    this.tiled = false,
    super.key,
  });

  static const _defaultPadding = EdgeInsets.symmetric(horizontal: 16);

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final bool tiled;

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
    ],
  );

  /// NestyHub:149: `#FFFDF7`, `inset 0 2px 0 #fff, 0 5px 0 #D8B07A`.
  static const _tiledStyle = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
    ],
  );

  @override
  Widget build(BuildContext context) => NestySurface(
    style: tiled ? _tiledStyle : _style,
    radius: BorderRadius.all(Radius.circular(tiled ? 22 : 24)),
    width: double.infinity,
    padding: tiled && padding == _defaultPadding
        ? const EdgeInsets.symmetric(horizontal: 14)
        : padding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            tiled
                // `layout.settingsRows.divider`: 1.5 dp `color.divider`, the
                // card's whole inner width (NestyHub:265).
                ? SizedBox(
                    height: SettingsRowsTokens.divider.width,
                    width: double.infinity,
                    child: ColoredBox(color: SettingsRowsTokens.divider.color),
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

  /// NestyHub:151: `min-height: 44px` inside a 6 + 6 dp padding.
  static const double _tiledMinHeight = 56;

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
        // A tiled row is the frame's 44 dp line inside 6 dp above and below.
        constraints: BoxConstraints(
          minHeight: tile == null ? minHeight : _tiledMinHeight,
        ),
        child: TactileSurface(
          style: _transparent,
          radius: BorderRadius.zero,
          onPressed: onTap,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: tile == null ? 12 : 6),
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
                    fontSize: tile == null ? 14 : 15,
                    height: 1,
                    fontWeight: tile == null ? null : FontWeight.w700,
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
                  color: AppColorTokens.chevron,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A tiled row's title: Fredoka 600 17/1.15 (NestyHub:153).
final TextStyle _tiledTitle = AppTextStyleTokens.cardTitle.copyWith(
  fontSize: 17,
  fontWeight: FontWeight.w600,
  height: 1.15,
  color: AppColorTokens.textPrimary,
);

/// A tiled row's subtitle: Nunito 700 12/1.3, `textSecondary` (NestyHub:153).
final TextStyle _tiledSubtitle = AppTextStyleTokens.caption.copyWith(
  fontSize: 12,
  height: 1.3,
  fontWeight: FontWeight.w700,
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
      padding: tile == null
          ? const EdgeInsets.symmetric(vertical: 12)
          // 6 above and below; a row with actions under it is 8 and 10
          // (NestyHub:265).
          : (footer == null
                ? const EdgeInsets.symmetric(vertical: 6)
                : const EdgeInsets.only(top: 8, bottom: 10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: tile == null ? 0 : 44),
            child: Row(
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
          ),
          if (footer != null)
            Padding(
              // NestyHub:160: `margin: 8px 0 4px 48px` (tile + gap).
              padding: const EdgeInsetsDirectional.only(
                start: SettingsTile.size + SettingsTile.gap,
                top: 8,
                bottom: 4,
              ),
              child: footer,
            ),
        ],
      ),
    );
  }
}

/// A pill button inside a settings row (frame 10.2f's "Open phone
/// settings", NestyHub:160): 36 tall, radius 14, white with a 4 px edge, a 19
/// dp glyph and a Fredoka 600 15 label in `iconBrown`. Its touch area is
/// padded to 48 dp.
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

  static const double height = 36;

  static const _style = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4),
    ],
  );

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    // Shrink to the pill: an Align that fills the width made a Wrap treat it
    // as a full line and pushed "Turn off" under it (frame 10.2f).
    widthFactor: 1,
    child: TactileSurface(
      style: _style,
      radius: const BorderRadius.all(Radius.circular(14)),
      onPressed: onPressed,
      height: height,
      minTouchSize: const Size(48, 48),
      padding: const EdgeInsetsDirectional.only(start: 10, end: 14),
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: AppColorTokens.iconBrown),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyleTokens.buttonSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColorTokens.iconBrown,
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
  static const double trackHeight = SettingsRowsTokens.segmentedHeight;
  static const double _inset = 4;

  static const _trackStyle = SurfaceStyle(
    color: AppColorTokens.surfaceTrack,
    shadows: [
      NestyShadow(color: AppColors.segmentedTrackShade, inset: true, dy: 2),
    ],
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
        // `padding: 8px 0 10px` (NestyHub:265).
        padding: tile == null
            ? const EdgeInsets.symmetric(vertical: 8)
            : const EdgeInsets.only(top: 8, bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: tile == null ? 0 : 44),
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
            // The frame's 2 dp under the track (`margin: 8px 0 2px 48px`).
            if (tile != null) const SizedBox(height: 2),
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
            // NestyHub:160: Fredoka 700 14.
            style: AppTextStyleTokens.buttonSmall.copyWith(
              fontSize: 14,
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
      ..color = AppColors.rowDash
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
