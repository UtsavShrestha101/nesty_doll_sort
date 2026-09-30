import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/race/race_rules.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

part 'rival_select_cubit.freezed.dart';
part 'rival_select_state.dart';

/// Rival select (vs Computer; frame 9.2; spec-prop §7.7; docs/plans/
/// m7-design.md P2.8): the three computer rivals from the save's
/// `race.rivals`, each with its reward, and [begin], which stores the next
/// raceNo for the race the player chose. It follows [SaveService.changes],
/// so a rival a race just unlocked shows unlocked on the way back.
@injectable
class RivalSelectCubit extends BaseAsyncCubit<RivalSelectState> {
  RivalSelectCubit(this._save, this._remoteConfig) {
    _saveChanges = _save.changes.listen((_) => _refresh());
  }

  final SaveService _save;
  final RemoteConfigService _remoteConfig;
  late final StreamSubscription<void> _saveChanges;

  /// The player's own pick this visit (null until a tap): it wins over the
  /// default as long as that rival stays unlocked.
  int? _picked;

  Future<void> load() async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async => _read());
  }

  /// Selects [rival] for the one Start (frame 9.2). A locked or unknown
  /// rival is ignored: it is not selectable, and nothing changes.
  void select(int rival) {
    final data = state.data;
    if (isClosed || data == null) return;
    final card = data.rivals.where((c) => c.number == rival).firstOrNull;
    if (card == null || !card.unlocked || data.selected == rival) return;
    _picked = rival;
    emit(AsyncValue.data(data: data.copyWith(selected: rival)));
  }

  /// The race against [rival] the player chose (spec-prop §7.7):
  /// `SaveService.beginRace` stores its raceNo now, so a quit or a kill
  /// never hands this board back as a new race, and the request to push
  /// (`GameplayRoute(request: …)`) is returned. Null, with nothing written,
  /// while the mode is locked (`RaceRules.modeUnlocked`) or the rival is.
  RacePlay? begin(int rival) {
    if (!RaceRules.modeUnlocked(_save.highestLevel, _remoteConfig)) {
      return null;
    }
    final raceNo = _save.beginRace(rival);
    if (raceNo == null) return null;
    return RacePlay(rival: rival, raceNo: raceNo);
  }

  void _refresh() {
    if (isClosed || !state.hasData) return;
    unawaited(runGuarded(() async => _read()));
  }

  RivalSelectState _read() {
    final rivals = _save.document.race.rivals;
    final cards = [
      for (var i = 0; i < rivals.length; i++)
        RivalCard(
          number: i + 1,
          unlocked: rivals[i].unlocked,
          wins: rivals[i].wins,
          rewardCoins: RaceRules.rewardCoins(i + 1, _remoteConfig),
          beaten: rivals[i].wins > 0,
          isNew: i > 0 && rivals[i].unlocked && rivals[i].raceNo == 0,
        ),
    ];
    return RivalSelectState(
      coins: _save.coins,
      rivals: cards,
      selected: _defaultOr(cards, _picked),
    );
  }

  /// [picked] while that rival is unlocked, else the newest unlocked rival
  /// never raced ("New"), else the highest unlocked (the last raced), else
  /// Pebble (frame 9.2).
  static int _defaultOr(List<RivalCard> cards, int? picked) {
    if (picked != null && cards.any((c) => c.number == picked && c.unlocked)) {
      return picked;
    }
    final fresh = cards.where((c) => c.isNew).lastOrNull;
    if (fresh != null) return fresh.number;
    return cards.where((c) => c.unlocked).lastOrNull?.number ?? 1;
  }

  @override
  Future<void> close() async {
    await _saveChanges.cancel();
    return super.close();
  }
}
