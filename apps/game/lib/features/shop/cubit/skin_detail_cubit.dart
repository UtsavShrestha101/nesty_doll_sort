import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/repository/catalog_repository.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/shop/model/purchase_outcome.dart';

part 'skin_detail_cubit.freezed.dart';
part 'skin_detail_state.dart';

/// One skin's detail (frame 7.4; docs/plans/m3-design.md §10.7): all 11
/// colors, the size lineup, and Buy / Equip / Equipped. Follows
/// [SaveService.changes] and [SkinService.selectedSkinChanges] so a
/// purchase or equip elsewhere (or this screen's own) updates the balance
/// and the button state. Both are needed: the save's own change can fire
/// before [SkinService.selectSkin] (which rasterizes the new skin) has
/// actually finished, so relying on it alone left this page's Equipped
/// state stale until it was reopened (owner 2026-09-28 simulator review).
@injectable
class SkinDetailCubit extends BaseAsyncCubit<SkinDetailState> {
  SkinDetailCubit(
    this._catalog,
    this._save,
    this._skins,
    this._analytics,
    this._jingles,
  ) {
    _saveChanges = _save.changes.listen((_) => _refresh());
    _skinChanges = _skins.selectedSkinChanges.listen((_) => _refresh());
  }

  final CatalogRepository _catalog;
  final SaveService _save;
  final SkinService _skins;
  final AnalyticsService _analytics;
  final JingleCues _jingles;
  late final StreamSubscription<void> _saveChanges;
  late final StreamSubscription<String> _skinChanges;
  String? _skinId;

  /// Loads [skinId]'s detail. An id the catalog doesn't know (never reached
  /// through [SkinDetailRoute], but defensive) is a content error with a
  /// retry.
  Future<void> load(String skinId) async {
    _skinId = skinId;
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async => _read(skinId));
  }

  void _refresh() {
    final skinId = _skinId;
    if (isClosed || skinId == null || !state.hasData) return;
    unawaited(runGuarded(() async => _read(skinId)));
  }

  SkinDetailState _read(String skinId) {
    final skin = _catalog.skin(skinId);
    if (skin == null) {
      throw AppException(
        AppExceptionKind.content,
        message: 'no such skin: $skinId',
      );
    }
    return SkinDetailState(
      skin: skin,
      owned: _save.document.ownedSkins.contains(skinId),
      equipped: _skins.selectedSkinId == skinId,
      coins: _save.coins,
    );
  }

  /// Buys the skin, spending its coins, then equips it at once (m3-design
  /// §9.4). Nothing is spent when it's unsold or already owned
  /// ([PurchaseOutcome.unavailable]) or unaffordable
  /// ([PurchaseOutcome.needsCoins]: the page opens the Coins tab).
  Future<PurchaseOutcome> buy() async {
    final skin = state.data?.skin;
    if (skin == null || !skin.sold) return PurchaseOutcome.unavailable;
    if (_save.document.ownedSkins.contains(skin.id)) {
      return PurchaseOutcome.unavailable;
    }
    if (_save.coins < skin.priceCoins) return PurchaseOutcome.needsCoins;
    if (!_save.purchaseSkin(skin.id, skin.priceCoins)) {
      return PurchaseOutcome.unavailable;
    }
    await _equip(skin.id);
    _jingles.reward();
    return PurchaseOutcome.bought;
  }

  /// Equips the (already-owned) skin: false when it isn't owned.
  Future<bool> equip() async {
    final skin = state.data?.skin;
    if (skin == null || !_save.document.ownedSkins.contains(skin.id)) {
      return false;
    }
    await _equip(skin.id);
    return true;
  }

  Future<void> _equip(String skinId) async {
    _save.selectSkin(skinId);
    await _skins.selectSkin(skinId);
    unawaited(_analytics.logEvent('skin_equip', parameters: {'skin': skinId}));
  }

  @override
  Future<void> close() async {
    await _saveChanges.cancel();
    await _skinChanges.cancel();
    return super.close();
  }
}
