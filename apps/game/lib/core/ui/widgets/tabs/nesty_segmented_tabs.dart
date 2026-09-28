import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_feedback.dart';

/// "Tabs (segmented): track height 44–46, radius 23, `#EAD3B0` with a sunk
/// shadow, padding 4. Active segment is a surface gradient with a 3px edge"
/// (design/README.md "Components"; NestyShop's Coins · Skins · Themes ·
/// No Ads, frame 7.3).
///
/// [labels] are already localized. Tapping the selected label is a no-op (no
/// feedback, no [onChanged] call); every other tap plays the `button` sound
/// and selection haptic ([TactileFeedback]) before calling [onChanged], as
/// every pressable control does.
class NestySegmentedTabs extends StatelessWidget {
  const NestySegmentedTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  }) : assert(labels.length > 1, 'a single tab has nothing to segment');

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const double height = 46;
  static const double _padding = 4;
  static const double _segmentRadius = 19;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final ms =
        UiMotionTokens.tabLiftMs *
        (reduced ? UiMotionTokens.reducedMotionDurationScale : 1);
    final duration = Duration(milliseconds: ms.round());
    return NestySurface(
      style: SurfaceStyles.progressTrack,
      radius: const BorderRadius.all(Radius.circular(23)),
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(_padding),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: _padding),
            Expanded(
              child: _Segment(
                label: labels[i],
                selected: i == selectedIndex,
                duration: duration,
                onTap: () => onChanged(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  static const _selectedStyle = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 3),
    ],
  );

  void _handleTap(BuildContext context) {
    if (selected) return;
    TactileFeedback.of(context)?.activate();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: () => _handleTap(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: () => _handleTap(context),
        child: SizedBox(
          height: NestySegmentedTabs.height - NestySegmentedTabs._padding * 2,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: duration,
                curve: UiMotionTokens.curveEaseOut,
                child: const NestySurface(
                  style: _selectedStyle,
                  radius: BorderRadius.all(
                    Radius.circular(NestySegmentedTabs._segmentRadius),
                  ),
                ),
              ),
              Center(
                child: AnimatedDefaultTextStyle(
                  duration: duration,
                  curve: UiMotionTokens.curveEaseOut,
                  style: AppTextStyleTokens.tabLabel.copyWith(
                    fontSize: 14,
                    color: selected
                        ? AppColorTokens.textPrimary
                        : AppColorTokens.textSecondary,
                  ),
                  child: Text(label, maxLines: 1, softWrap: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
