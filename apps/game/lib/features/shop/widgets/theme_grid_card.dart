import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/shop/widgets/purchase_twinkle_burst.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

/// One Themes-tab tile (frame 7.7): the chapter's colour, its name, then In
/// use (green ring) / Use / a locked "Ch N" price.
///
/// TODO(design): the tile shows the chapter's flat fallback colour, not its
/// scenic background art. `SkinService.background` is one shared
/// full-screen rasterizer (one theme at a time); showing six thumbnails at
/// once needs its own small-preview cache, which no frame or m3-design
/// section asks for. Flagged for the integrator/a later milestone.
class ThemeGridCard extends StatelessWidget {
  const ThemeGridCard({
    required this.theme,
    required this.owned,
    required this.inUse,
    required this.onUse,
    required this.onBuy,
    super.key,
  });

  final ThemeInfo theme;
  final bool owned;
  final bool inUse;
  final VoidCallback onUse;

  /// Awaited by the caller, which shows the purchase celebration on
  /// success.
  final Future<bool> Function() onBuy;

  static const double thumbnailHeight = 74;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final ring = inUse ? AppColorTokens.success : null;
    return NestySurface(
      style: SurfaceStyle(
        gradient: AppGradientTokens.surface,
        shadows: [
          ...AppShadowTokens.raised,
          if (ring != null) NestyShadow(color: ring, spread: 3),
        ],
      ),
      radius: const BorderRadius.all(Radius.circular(20)),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(13)),
            child: Stack(
              children: [
                Container(
                  height: thumbnailHeight,
                  color:
                      ChapterTheme.byId(theme.id)?.fallbackColor ??
                      AppColorTokens.surfaceSunk,
                ),
                if (!owned)
                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: _LockChip(number: theme.chapterNumber),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2),
            child: Text(
              l10n.chapterName(theme.id),
              style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 7),
          if (inUse)
            _InUsePill(label: l10n.themeInUse)
          else if (owned)
            _UseButton(label: l10n.themeUse, onTap: onUse)
          else
            _LockedBuyButton(price: theme.priceCoins, onTap: onBuy),
        ],
      ),
    );
  }
}

/// The locked theme's top-right "lock · Ch N" chip.
class _LockChip extends StatelessWidget {
  const _LockChip({required this.number});

  final int number;

  static const _face = Color(0xB82D190A);
  static const _text = Color(0xFFFFEFD6);

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: _face,
      borderRadius: BorderRadius.all(Radius.circular(9)),
    ),
    child: Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 3, 7, 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(NestyIcons.lock, size: 13, color: _text),
          const SizedBox(width: 2),
          Text(
            context.localizations.themeChapterLock(number),
            style: AppTextStyleTokens.button.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
        ],
      ),
    ),
  );
}

class _InUsePill extends StatelessWidget {
  const _InUsePill({required this.label});

  final String label;

  static const _face = Color(0xFFDDF3E2);

  @override
  Widget build(BuildContext context) => NestySurface(
    style: const SurfaceStyle(
      color: _face,
      shadows: [
        NestyShadow(color: AppColorTokens.success, inset: true, spread: 2),
      ],
    ),
    radius: const BorderRadius.all(Radius.circular(12)),
    height: 30,
    alignment: Alignment.center,
    child: Text(
      label,
      style: AppTextStyleTokens.button.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColorTokens.success,
      ),
    ),
  );
}

class _UseButton extends StatelessWidget {
  const _UseButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TactileSurface(
    style: SurfaceStyles.raised,
    radius: const BorderRadius.all(Radius.circular(12)),
    onPressed: onTap,
    height: 30,
    alignment: Alignment.center,
    child: Text(
      label,
      style: AppTextStyleTokens.button.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.iconBrown,
      ),
    ),
  );
}

class _LockedBuyButton extends StatefulWidget {
  const _LockedBuyButton({required this.price, required this.onTap});

  final int price;
  final Future<bool> Function() onTap;

  @override
  State<_LockedBuyButton> createState() => _LockedBuyButtonState();
}

class _LockedBuyButtonState extends State<_LockedBuyButton> {
  bool _buying = false;

  Future<void> _tap() async {
    if (_buying) return;
    setState(() => _buying = true);
    final ok = await widget.onTap();
    if (!mounted) return;
    setState(() => _buying = false);
    if (ok) PurchaseTwinkleBurst.showOver(context);
  }

  @override
  Widget build(BuildContext context) => TactileButton(
    label: context.localizations.coinPrice(widget.price),
    onPressed: _buying ? null : _tap,
    variant: TactileButtonVariant.primary,
    size: TactileButtonSize.compact,
    leading: const CoinIcon(size: 18),
  );
}
