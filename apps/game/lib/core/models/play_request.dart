import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_request.freezed.dart';

/// The kinds of board the game plays (spec §7.1, §7.5; spec-prop §7.1,
/// §7.7; docs/plans/m3-design.md §6, docs/plans/m7-design.md §6, P2.4).
enum PlayKind {
  /// A published level, by global play order.
  campaign('campaign'),

  /// Bonus Endless, past the last published level (spec §7.1).
  bonus('bonus'),

  /// The daily puzzle (spec §7.5).
  daily('daily'),

  /// A won published level played again from Chapters (spec-prop §7.1,
  /// m7-design §6). It is never saved in progress, so its [id] is never
  /// stored: the save's codec drops an `inProgress` of this kind.
  replay('replay'),

  /// A vs Computer race (spec-prop §7.7, m7-design P2.4). "A race in
  /// progress is never resumed", so its [id] is never stored either: the
  /// save ignores it and the codec drops an `inProgress` of this kind.
  race('race');

  const PlayKind(this.id);

  /// The id the save's `inProgress.kind` stores (a storage contract).
  final String id;

  /// The kind with [id], or null.
  static PlayKind? tryFromId(Object? id) {
    for (final kind in values) {
      if (kind.id == id) return kind;
    }
    return null;
  }
}

/// What to play: the argument of `GameplayRoute` and `GameplayStarted`
/// (docs/plans/m3-design.md §6, m7-design §6). `LevelResolver` turns it
/// into a playable `PlayEntry`.
@freezed
sealed class PlayRequest with _$PlayRequest {
  /// Published level [order] (1-based global play order, spec §7.1).
  const factory PlayRequest.campaign(int order) = CampaignPlay;

  /// "Bonus Level [number]" (from 1): `DifficultyCurve.bonusParams(
  /// levelCount + number)`, generated on the device (spec §7.1).
  const factory PlayRequest.bonus(int number) = BonusPlay;

  /// The daily puzzle of [yyyymmdd] (spec §7.5), such as 20260926.
  const factory PlayRequest.daily(int yyyymmdd) = DailyPlay;

  /// Won published level [order] played again from Chapters (spec-prop
  /// §7.1, m7-design §6, §11): the same bundled board, but it pays no
  /// coins, never moves `currentLevel`, never opens a milestone chest or
  /// the Museum, shows no tutorial or intro card and is never saved in
  /// progress. Its win still records the best moves and the records.
  const factory PlayRequest.replay(int order) = ReplayPlay;

  /// Race [raceNo] against computer rival [rival] (spec-prop §7.7,
  /// m7-design P2.4): `DifficultyCurve.raceParams(rival:, raceNo:,
  /// highestWonLevel:)`, generated on the device. [rival] is 1–3 and
  /// [raceNo] 1–`DifficultyCurve.maxRaceNo`; the save stores the raceNo when
  /// the race is chosen (`SaveService.beginRace`), so the request is all a
  /// Rematch needs. It pays through `SaveService.recordRaceWin`, never
  /// `recordLevelWin`, and is never saved in progress.
  const factory PlayRequest.race({required int rival, required int raceNo}) =
      RacePlay;

  const PlayRequest._();

  /// The request of [kind] with [number] (the order, the bonus number or
  /// the date), or null when [number] can't be one: below 1, or not a
  /// `yyyymmdd` of years 1–9999 for a daily. Always null for a race, which
  /// takes two numbers and is never stored (m7-design P2.4).
  static PlayRequest? tryCreate(PlayKind kind, int number) {
    if (number < 1) return null;
    return switch (kind) {
      PlayKind.campaign => PlayRequest.campaign(number),
      PlayKind.bonus => PlayRequest.bonus(number),
      PlayKind.daily =>
        number >= 10101 && number <= 99991231
            ? PlayRequest.daily(number)
            : null,
      PlayKind.replay => PlayRequest.replay(number),
      PlayKind.race => null,
    };
  }

  PlayKind get kind => switch (this) {
    CampaignPlay() => PlayKind.campaign,
    BonusPlay() => PlayKind.bonus,
    DailyPlay() => PlayKind.daily,
    ReplayPlay() => PlayKind.replay,
    RacePlay() => PlayKind.race,
  };

  /// The order, the bonus number, the date or a race's raceNo: with
  /// [kind], what the save's `inProgress` stores (a race never is).
  int get number => switch (this) {
    CampaignPlay(:final order) => order,
    BonusPlay(:final number) => number,
    DailyPlay(:final yyyymmdd) => yyyymmdd,
    ReplayPlay(:final order) => order,
    RacePlay(:final raceNo) => raceNo,
  };

  /// True for the levels generated on the device (bonus, daily and race):
  /// the bloc shows the generating state while they are made, and a bonus
  /// or daily in-progress save embeds the level JSON (m3-design §3.4; a
  /// race is never saved, m7-design P2.4).
  bool get isGenerated =>
      kind == PlayKind.bonus || kind == PlayKind.daily || kind == PlayKind.race;

  /// True for a published level from the bundle (campaign and replay):
  /// the boards whose best moves are kept (m7-design §11).
  bool get isBundled => kind == PlayKind.campaign || kind == PlayKind.replay;

  /// A replay (m7-design §6): no pay, no progress, no in-progress save.
  bool get isReplay => kind == PlayKind.replay;

  /// A vs Computer race (m7-design P2.4): no level record, no in-progress
  /// save, Hint and +1 Slot off, undo free.
  bool get isRace => kind == PlayKind.race;
}
