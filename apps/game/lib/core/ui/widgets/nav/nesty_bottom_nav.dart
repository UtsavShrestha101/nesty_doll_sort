import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_feedback.dart';
import 'package:nesty_game/core/ui/widgets/wood/wood_bar.dart';

export 'package:nesty_game/core/ui/widgets/wood/wood_bar.dart';

/// One [NestyBottomNav] destination: a `NestyIcons.*` glyph and its already
/// localized label (Shop, Home, Museum).
@immutable
class NestyBottomNavItem {
  const NestyBottomNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// "Bottom nav: Wood bar from y = 738. Items Shop · Home · Museum, 80 wide.
/// Inactive: 48 square, 18% cream fill, cream glyph. Active: 58×52 surface
/// tile lifted −6px, glyph `#C4631E`" (design/README.md "Components"; frame
/// 2.1, tokens.json `layout.bottomNav`).
///
/// Sits on a [WoodBar]; the caller docks it to the screen's bottom (a
/// `Scaffold.bottomNavigationBar` or a `Stack`). Tapping the already
/// selected item is a no-op, like [NestySegmentedTabs].
class NestyBottomNav extends StatelessWidget {
  const NestyBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<NestyBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const double itemWidth = 80;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    return WoodBar(
      padding: EdgeInsets.fromLTRB(16, 10, 16, math.max(10, bottomSafe)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++)
            _NavItemView(
              item: items[i],
              selected: i == selectedIndex,
              onTap: () => onChanged(i),
            ),
        ],
      ),
    );
  }
}

class _NavItemView extends StatelessWidget {
  const _NavItemView({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NestyBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  /// `rgba(255,240,215,.18)`: the inactive tile's cream fill.
  static const _inactiveFill = Color(0x2EFFF0D7);

  void _handleTap(BuildContext context) {
    if (selected) return;
    TactileFeedback.of(context)?.activate();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final ms =
        UiMotionTokens.tabLiftMs *
        (reduced ? UiMotionTokens.reducedMotionDurationScale : 1);
    final duration = Duration(milliseconds: ms.round());
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      onTap: () => _handleTap(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: () => _handleTap(context),
        child: SizedBox(
          width: NestyBottomNav.itemWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: BottomNavTokens.activeItemSize.height,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: UiMotionTokens.curveEaseOut,
                    switchOutCurve: UiMotionTokens.curveEaseOut,
                    child: selected
                        ? _active(key: true)
                        : _inactive(key: false),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: duration,
                curve: UiMotionTokens.curveEaseOut,
                style: AppTextStyleTokens.tabLabel.copyWith(
                  color: selected
                      ? AppColorTokens.textOnWood
                      : AppColorTokens.textOnWoodMuted,
                ),
                child: Text(item.label, maxLines: 1, softWrap: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _active({required bool key}) => Transform.translate(
    key: ValueKey(key),
    offset: const Offset(0, BottomNavTokens.lift),
    child: NestySurface(
      style: SurfaceStyles.booster,
      radius: const BorderRadius.all(Radius.circular(AppRadii.booster)),
      width: BottomNavTokens.activeItemSize.width,
      height: BottomNavTokens.activeItemSize.height,
      alignment: Alignment.center,
      child: ExcludeSemantics(
        child: Icon(item.icon, size: 30, color: AppColorTokens.primaryEdge),
      ),
    ),
  );

  Widget _inactive({required bool key}) => DecoratedBox(
    key: ValueKey(key),
    decoration: const BoxDecoration(
      color: _inactiveFill,
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    child: SizedBox(
      width: BottomNavTokens.itemSize.width,
      height: BottomNavTokens.itemSize.height,
      child: Center(
        child: ExcludeSemantics(
          child: Icon(
            item.icon,
            size: 27,
            color: AppColorTokens.textOnWoodMuted,
          ),
        ),
      ),
    ),
  );
}
