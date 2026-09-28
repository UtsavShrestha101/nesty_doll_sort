import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';
import 'package:nesty_game/core/ui/widgets/toggle/nesty_toggle.dart';

/// A rounded card grouping [SettingsRow]/[SettingsToggleRow] children with a
/// dashed divider between them (design/README.md "08 Settings & system",
/// frame 8.1's toggles and link cards).
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

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
          if (i > 0) const _DashedDivider(),
          children[i],
        ],
      ],
    ),
  );
}

/// A settings link row: an icon, its label, an optional trailing [value]
/// and a chevron (frame 8.1's Language/Restore Purchases/Privacy/Support
/// rows). With [onTap] null the row is shown but unresponsive (Restore
/// Purchases and Privacy choices, disabled until M6).
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.showChevron = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool showChevron;
  final VoidCallback? onTap;

  static const _transparent = SurfaceStyle(
    color: Color(0x00000000),
    shadows: [],
  );

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: TactileSurface(
        style: _transparent,
        radius: BorderRadius.zero,
        onPressed: onTap,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          children: [
            Icon(icon, size: 23, color: AppColorTokens.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyleTokens.row.copyWith(fontSize: 16),
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(
                value,
                style: AppTextStyleTokens.caption.copyWith(
                  fontSize: 14,
                  height: 1,
                  color: AppColorTokens.textMuted,
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
    );
  }
}

/// A settings toggle row: an icon, its label and a [NestyToggle] (frame
/// 8.1's Sound/Music/Haptics).
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Icon(icon, size: 24, color: AppColorTokens.textSecondary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyleTokens.row)),
        NestyToggle(value: value, onChanged: onChanged, semanticLabel: label),
      ],
    ),
  );
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
