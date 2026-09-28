import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_request.freezed.dart';

/// The three kinds of board the game plays (spec §7.1, §7.5;
/// docs/plans/m3-design.md §6).
enum PlayKind {
  /// A published level, by global play order.
  campaign('campaign'),

  /// Bonus Endless, past the last published level (spec §7.1).
  bonus('bonus'),

  /// The daily puzzle (spec §7.5).
  daily('daily');

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
/// (docs/plans/m3-design.md §6). `LevelResolver` turns it into a playable
/// `PlayEntry`.
@freezed
sealed class PlayRequest with _$PlayRequest {
  /// Published level [order] (1-based global play order, spec §7.1).
  const factory PlayRequest.campaign(int order) = CampaignPlay;

  /// "Bonus Level [number]" (from 1): `DifficultyCurve.bonusParams(
  /// levelCount + number)`, generated on the device (spec §7.1).
  const factory PlayRequest.bonus(int number) = BonusPlay;

  /// The daily puzzle of [yyyymmdd] (spec §7.5), such as 20260926.
  const factory PlayRequest.daily(int yyyymmdd) = DailyPlay;

  const PlayRequest._();

  /// The request of [kind] with [number] (the order, the bonus number or
  /// the date), or null when [number] can't be one: below 1, or not a
  /// `yyyymmdd` of years 1–9999 for a daily.
  static PlayRequest? tryCreate(PlayKind kind, int number) {
    if (number < 1) return null;
    return switch (kind) {
      PlayKind.campaign => PlayRequest.campaign(number),
      PlayKind.bonus => PlayRequest.bonus(number),
      PlayKind.daily =>
        number >= 10101 && number <= 99991231
            ? PlayRequest.daily(number)
            : null,
    };
  }

  PlayKind get kind => switch (this) {
    CampaignPlay() => PlayKind.campaign,
    BonusPlay() => PlayKind.bonus,
    DailyPlay() => PlayKind.daily,
  };

  /// The order, the bonus number or the date: with [kind], what the save's
  /// `inProgress` stores.
  int get number => switch (this) {
    CampaignPlay(:final order) => order,
    BonusPlay(:final number) => number,
    DailyPlay(:final yyyymmdd) => yyyymmdd,
  };

  /// True for the levels generated on the device (bonus and daily): their
  /// in-progress save embeds the level JSON (m3-design §3.4).
  bool get isGenerated => kind != PlayKind.campaign;
}
