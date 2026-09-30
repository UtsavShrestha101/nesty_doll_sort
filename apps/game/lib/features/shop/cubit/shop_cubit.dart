import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/repository/catalog_repository.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/shop/model/purchase_outcome.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';

part 'shop_cubit.freezed.dart';
part 'shop_state.dart';

/// The Shop (spec §7.4, §10.2 #12, frames 7.1–7.8; docs/plans/m3-design.md
/// §10.7): Skins and Themes are live; Coins and No Ads show the
/// store-unavailable card until M6 (D75). Follows [SaveService.changes] and
/// [SkinService.selectedSkinChanges], so a purchase or an equip made here or
/// from the skin detail page updates every open tab at once. Both are
/// needed: the save's own change can fire before [SkinService.selectSkin]
/// (which rasterizes the new skin) has actually finished, so relying on it
/// alone left the Skins grid's "Equipped" ring stale until the page was
/// reopened (owner 2026-09-28 simulator review, frame 7.3).
@injectable
class ShopCubit extends BaseAsyncCubit<ShopState> {
  ShopCubit(
    this._catalog,
    this._save,
    this._skins,
    this._levels,
    this._analytics,
    this._jingles,
  ) {
    _saveChanges = _save.changes.listen((_) => _refresh());
    _skinChanges = _skins.selectedSkinChanges.listen((_) => _refresh());
  }

  final CatalogRepository _catalog;
  final SaveService _save;
  final SkinService _skins;
  final LevelRepository _levels;
  final AnalyticsService _analytics;
  final JingleCues _jingles;
  late final StreamSubscription<void> _saveChanges;
  late final StreamSubscription<String> _skinChanges;

  /// Loads the Shop open on [initialTab] (Home's coin pill "+" asks for
  /// [ShopTab.coins], the Remove Ads tile for [ShopTab.noAds]; the route's
  /// default is [ShopTab.skins]).
  Future<void> load(ShopTab initialTab) async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async => _read(initialTab));
  }

  /// The save changed (a purchase, an equip): refresh without a spinner.
  void _refresh() {
    final tab = state.data?.tab;
    if (isClosed || tab == null) return;
    unawaited(runGuarded(() async => _read(tab)));
  }

  /// The segmented control (frame 7.1): no reload needed, so this never
  /// shows a spinner.
  void selectTab(ShopTab tab) {
    final current = state.data;
    if (current == null || current.tab == tab) return;
    unawaited(runGuarded(() async => current.copyWith(tab: tab)));
  }

  ShopState _read(ShopTab tab) {
    final reached = _reachedChapterNumber();
    return ShopState(
      tab: tab,
      coins: _save.coins,
      skins: [
        for (final skin in _catalog.skins)
          if (skin.sold) skin,
      ],
      ownedSkins: _save.document.ownedSkins,
      selectedSkinId: _skins.selectedSkinId,
      themes: _catalog.themes,
      ownedThemes: _save.document.ownedThemes,
      selectedThemeId: _save.document.selectedTheme,
      currentChapterThemeId: _themeIdOfChapter(reached),
      reachedChapterNumber: reached,
    );
  }

  /// The chapter of `entryAt(currentLevel)`, or the last published chapter
  /// in Bonus Endless (m3-design §9.4, mirroring `DefaultLevelResolver`'s
  /// theme lookup).
  int _reachedChapterNumber() {
    final entry = _levels.entryAt(_save.currentLevel) ?? _lastEntry();
    if (entry == null) return 1;
    return _catalog.chapter(entry.chapterId)?.number ?? 1;
  }

  LevelBundleEntry? _lastEntry() {
    final count = _levels.levelCount;
    return count < 1 ? null : _levels.entryAt(count);
  }

  String _themeIdOfChapter(int number) =>
      _catalog.chapterNumbered(number)?.themeId ??
      (_catalog.themes.isEmpty ? '' : _catalog.themes.first.id);

  // --- Skins (frames 7.3, 7.4) --------------------------------------------

  /// Buys [skinId], spending its coins, then equips it at once (m3-design
  /// §9.4): [PurchaseOutcome.unavailable], with nothing spent, when it's
  /// unsold or already owned; [PurchaseOutcome.needsCoins], with nothing
  /// spent, when it's unaffordable (D112: every price is the same orange
  /// button, frames 7.3, 7.7, so the caller opens the not-enough-coins
  /// dialog rather than doing nothing).
  Future<PurchaseOutcome> buySkin(String skinId) async {
    final skin = _catalog.skin(skinId);
    if (skin == null || !skin.sold) return PurchaseOutcome.unavailable;
    if (_save.document.ownedSkins.contains(skinId)) {
      return PurchaseOutcome.unavailable;
    }
    if (_save.coins < skin.priceCoins) return PurchaseOutcome.needsCoins;
    if (!_save.purchaseSkin(skinId, skin.priceCoins)) {
      return PurchaseOutcome.unavailable;
    }
    await _equipSkin(skinId);
    _jingles.reward();
    return PurchaseOutcome.bought;
  }

  /// Equips an already-owned skin (frame 7.3's Equip): false when it isn't
  /// owned.
  Future<bool> equipSkin(String skinId) async {
    if (!_save.document.ownedSkins.contains(skinId)) return false;
    await _equipSkin(skinId);
    return true;
  }

  Future<void> _equipSkin(String skinId) async {
    _save.selectSkin(skinId);
    await _skins.selectSkin(skinId);
    unawaited(_analytics.logEvent('skin_equip', parameters: {'skin': skinId}));
  }

  // --- Themes (frame 7.7) --------------------------------------------------

  /// Buys [themeId] before its chapter is reached, then uses it at once
  /// (turning "Match each chapter" off): [PurchaseOutcome.unavailable], with
  /// nothing spent, when it's already owned; [PurchaseOutcome.needsCoins],
  /// with nothing spent, when it's unaffordable (D112, as for a skin).
  Future<PurchaseOutcome> buyTheme(String themeId) async {
    final theme = _catalog.theme(themeId);
    if (theme == null) return PurchaseOutcome.unavailable;
    final owned = theme.isOwned(
      ownedThemes: _save.document.ownedThemes,
      reachedChapter: _reachedChapterNumber(),
    );
    if (owned) return PurchaseOutcome.unavailable;
    if (_save.coins < theme.priceCoins) return PurchaseOutcome.needsCoins;
    if (!_save.purchaseTheme(themeId, theme.priceCoins)) {
      return PurchaseOutcome.unavailable;
    }
    _save.selectTheme(themeId);
    _jingles.reward();
    return PurchaseOutcome.bought;
  }

  /// Uses an already-owned theme (turns "Match each chapter" off).
  void useTheme(String themeId) => _save.selectTheme(themeId);

  /// The "Match each chapter" toggle: on selects no theme (`null`, so the
  /// board always follows the current chapter); off with nothing chosen
  /// yet selects the reached chapter's theme, so a concrete one reads "in
  /// use" (m3-design §10.7).
  void setMatchesChapter(bool value) {
    if (value) {
      _save.selectTheme(null);
    } else {
      _save.selectTheme(state.data?.currentChapterThemeId);
    }
  }

  @override
  Future<void> close() async {
    await _saveChanges.cancel();
    await _skinChanges.cancel();
    return super.close();
  }
}
