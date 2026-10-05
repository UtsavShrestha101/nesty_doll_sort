// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

/// What PLAY starts (`LevelResolver.homeRequest`): a campaign level
/// while one is left, else Bonus Endless (m3-design §7.4, D74). A saved
/// board of this request continues.
 PlayRequest get playRequest;/// [playRequest]'s tier, for the play button's badge (§6.6): the
/// bundle entry's for a campaign level, `DifficultyCurve.tierForLevel`
/// for a bonus one.
 Tier get tier;/// The board theme behind the hero: `selectedTheme ?? current chapter's
/// theme` (m3-design §10.3, §9.4).
 String get themeId;/// The coin pill.
 int get coins;/// Hides the Remove Ads tile (spec §9.2; M6).
 bool get adsRemoved;/// The Daily tile: locked before Level 2 is won (m3-design §8.3).
 bool get dailyUnlocked;/// The Daily tile's flame badge, 0 hides it.
 int get dailyStreak;/// The Daily tile's flame is lit (`DailyStatus.lit`); with
/// [dailyStreak] above 0 and this false, the badge shows its resting,
/// paused look (E2; docs/plans/m7-design.md §8, §15.7).
 bool get dailyLit;/// vs Computer's unlock level (`race_unlock_level`, default 20): the
/// locked tile's "After Level {n}" (m7-design §15.8).
 int get raceUnlockLevel;/// That level is won (`highestLevel > raceUnlockLevel`). The race
/// itself lands in M7 phase 2; until then the tile stays locked and
/// says it is coming (m7-design §15.8).
 bool get raceUnlocked;/// The next uncollected figurine's id (`FigurineInfo.id`), null once
/// every catalog chapter is collected (`museumAllCollected`).
 String? get museumFigurineId;/// Its locked art (`FigurineInfo.lockedArtAsset`).
 String? get museumLockedArtAsset;/// The current chapter's levels already won, of [museumTotal]
/// (m3-design §10.3's "15/20"); meaningless once [museumAllCollected].
 int get museumDone; int get museumTotal;/// Every catalog chapter's figurine is in the museum (Bonus Endless):
/// [museumCollectedCount] of [museumCollectedTotal]. Home has no Museum
/// tile any more (D111); the Museum's own 6.1c says every family is home.
 bool get museumAllCollected; int get museumCollectedCount; int get museumCollectedTotal;/// The chapter card (frame 2.1; menus spec 1.1): the chapter the PLAY
/// level is in, 1-based, and its id (`ch03`, the `chapterName` select
/// key and the palette's theme). In Bonus Endless ([isBonus]) it stays
/// the last chapter's, only for the palette (frame 12.2).
 int get chapterNumber; String get chapterId;/// PLAY is a Bonus Endless board: the card reads "BONUS ENDLESS / Bonus
/// levels" with the whole campaign's stars (frame 12.2).
 bool get isBonus;/// The card's stars chip: the chapter's best stars, of
/// [chapterStarsPossible] (`StarRating.maxStars` × its levels with a par,
/// 60 for a full chapter). In Bonus Endless the same two fields hold the
/// campaign's total, of 600.
 int get chapterStars; int get chapterStarsPossible;/// The flame was paused and a solve lit it again, and Home hasn't
/// glowed for that yet (this session or an earlier one): the tile's badge
/// shows its `relitGlow` ring once, 2,400 ms and a 400 ms fade, until
/// `HomeCubit.relitGlowFinished` (m7-4 4.10, `motion.relitHome`; frame
/// 10.7).
 bool get streakRelit;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.playRequest, playRequest) || other.playRequest == playRequest)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.themeId, themeId) || other.themeId == themeId)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.adsRemoved, adsRemoved) || other.adsRemoved == adsRemoved)&&(identical(other.dailyUnlocked, dailyUnlocked) || other.dailyUnlocked == dailyUnlocked)&&(identical(other.dailyStreak, dailyStreak) || other.dailyStreak == dailyStreak)&&(identical(other.dailyLit, dailyLit) || other.dailyLit == dailyLit)&&(identical(other.raceUnlockLevel, raceUnlockLevel) || other.raceUnlockLevel == raceUnlockLevel)&&(identical(other.raceUnlocked, raceUnlocked) || other.raceUnlocked == raceUnlocked)&&(identical(other.museumFigurineId, museumFigurineId) || other.museumFigurineId == museumFigurineId)&&(identical(other.museumLockedArtAsset, museumLockedArtAsset) || other.museumLockedArtAsset == museumLockedArtAsset)&&(identical(other.museumDone, museumDone) || other.museumDone == museumDone)&&(identical(other.museumTotal, museumTotal) || other.museumTotal == museumTotal)&&(identical(other.museumAllCollected, museumAllCollected) || other.museumAllCollected == museumAllCollected)&&(identical(other.museumCollectedCount, museumCollectedCount) || other.museumCollectedCount == museumCollectedCount)&&(identical(other.museumCollectedTotal, museumCollectedTotal) || other.museumCollectedTotal == museumCollectedTotal)&&(identical(other.chapterNumber, chapterNumber) || other.chapterNumber == chapterNumber)&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.isBonus, isBonus) || other.isBonus == isBonus)&&(identical(other.chapterStars, chapterStars) || other.chapterStars == chapterStars)&&(identical(other.chapterStarsPossible, chapterStarsPossible) || other.chapterStarsPossible == chapterStarsPossible)&&(identical(other.streakRelit, streakRelit) || other.streakRelit == streakRelit));
}


@override
int get hashCode => Object.hashAll([runtimeType,playRequest,tier,themeId,coins,adsRemoved,dailyUnlocked,dailyStreak,dailyLit,raceUnlockLevel,raceUnlocked,museumFigurineId,museumLockedArtAsset,museumDone,museumTotal,museumAllCollected,museumCollectedCount,museumCollectedTotal,chapterNumber,chapterId,isBonus,chapterStars,chapterStarsPossible,streakRelit]);

@override
String toString() {
  return 'HomeState(playRequest: $playRequest, tier: $tier, themeId: $themeId, coins: $coins, adsRemoved: $adsRemoved, dailyUnlocked: $dailyUnlocked, dailyStreak: $dailyStreak, dailyLit: $dailyLit, raceUnlockLevel: $raceUnlockLevel, raceUnlocked: $raceUnlocked, museumFigurineId: $museumFigurineId, museumLockedArtAsset: $museumLockedArtAsset, museumDone: $museumDone, museumTotal: $museumTotal, museumAllCollected: $museumAllCollected, museumCollectedCount: $museumCollectedCount, museumCollectedTotal: $museumCollectedTotal, chapterNumber: $chapterNumber, chapterId: $chapterId, isBonus: $isBonus, chapterStars: $chapterStars, chapterStarsPossible: $chapterStarsPossible, streakRelit: $streakRelit)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 PlayRequest playRequest, Tier tier, String themeId, int coins, bool adsRemoved, bool dailyUnlocked, int dailyStreak, bool dailyLit, int raceUnlockLevel, bool raceUnlocked, String? museumFigurineId, String? museumLockedArtAsset, int museumDone, int museumTotal, bool museumAllCollected, int museumCollectedCount, int museumCollectedTotal, int chapterNumber, String chapterId, bool isBonus, int chapterStars, int chapterStarsPossible, bool streakRelit
});


$PlayRequestCopyWith<$Res> get playRequest;

}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playRequest = null,Object? tier = null,Object? themeId = null,Object? coins = null,Object? adsRemoved = null,Object? dailyUnlocked = null,Object? dailyStreak = null,Object? dailyLit = null,Object? raceUnlockLevel = null,Object? raceUnlocked = null,Object? museumFigurineId = freezed,Object? museumLockedArtAsset = freezed,Object? museumDone = null,Object? museumTotal = null,Object? museumAllCollected = null,Object? museumCollectedCount = null,Object? museumCollectedTotal = null,Object? chapterNumber = null,Object? chapterId = null,Object? isBonus = null,Object? chapterStars = null,Object? chapterStarsPossible = null,Object? streakRelit = null,}) {
  return _then(_self.copyWith(
playRequest: null == playRequest ? _self.playRequest : playRequest // ignore: cast_nullable_to_non_nullable
as PlayRequest,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,themeId: null == themeId ? _self.themeId : themeId // ignore: cast_nullable_to_non_nullable
as String,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,adsRemoved: null == adsRemoved ? _self.adsRemoved : adsRemoved // ignore: cast_nullable_to_non_nullable
as bool,dailyUnlocked: null == dailyUnlocked ? _self.dailyUnlocked : dailyUnlocked // ignore: cast_nullable_to_non_nullable
as bool,dailyStreak: null == dailyStreak ? _self.dailyStreak : dailyStreak // ignore: cast_nullable_to_non_nullable
as int,dailyLit: null == dailyLit ? _self.dailyLit : dailyLit // ignore: cast_nullable_to_non_nullable
as bool,raceUnlockLevel: null == raceUnlockLevel ? _self.raceUnlockLevel : raceUnlockLevel // ignore: cast_nullable_to_non_nullable
as int,raceUnlocked: null == raceUnlocked ? _self.raceUnlocked : raceUnlocked // ignore: cast_nullable_to_non_nullable
as bool,museumFigurineId: freezed == museumFigurineId ? _self.museumFigurineId : museumFigurineId // ignore: cast_nullable_to_non_nullable
as String?,museumLockedArtAsset: freezed == museumLockedArtAsset ? _self.museumLockedArtAsset : museumLockedArtAsset // ignore: cast_nullable_to_non_nullable
as String?,museumDone: null == museumDone ? _self.museumDone : museumDone // ignore: cast_nullable_to_non_nullable
as int,museumTotal: null == museumTotal ? _self.museumTotal : museumTotal // ignore: cast_nullable_to_non_nullable
as int,museumAllCollected: null == museumAllCollected ? _self.museumAllCollected : museumAllCollected // ignore: cast_nullable_to_non_nullable
as bool,museumCollectedCount: null == museumCollectedCount ? _self.museumCollectedCount : museumCollectedCount // ignore: cast_nullable_to_non_nullable
as int,museumCollectedTotal: null == museumCollectedTotal ? _self.museumCollectedTotal : museumCollectedTotal // ignore: cast_nullable_to_non_nullable
as int,chapterNumber: null == chapterNumber ? _self.chapterNumber : chapterNumber // ignore: cast_nullable_to_non_nullable
as int,chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String,isBonus: null == isBonus ? _self.isBonus : isBonus // ignore: cast_nullable_to_non_nullable
as bool,chapterStars: null == chapterStars ? _self.chapterStars : chapterStars // ignore: cast_nullable_to_non_nullable
as int,chapterStarsPossible: null == chapterStarsPossible ? _self.chapterStarsPossible : chapterStarsPossible // ignore: cast_nullable_to_non_nullable
as int,streakRelit: null == streakRelit ? _self.streakRelit : streakRelit // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res> get playRequest {
  
  return $PlayRequestCopyWith<$Res>(_self.playRequest, (value) {
    return _then(_self.copyWith(playRequest: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayRequest playRequest,  Tier tier,  String themeId,  int coins,  bool adsRemoved,  bool dailyUnlocked,  int dailyStreak,  bool dailyLit,  int raceUnlockLevel,  bool raceUnlocked,  String? museumFigurineId,  String? museumLockedArtAsset,  int museumDone,  int museumTotal,  bool museumAllCollected,  int museumCollectedCount,  int museumCollectedTotal,  int chapterNumber,  String chapterId,  bool isBonus,  int chapterStars,  int chapterStarsPossible,  bool streakRelit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.playRequest,_that.tier,_that.themeId,_that.coins,_that.adsRemoved,_that.dailyUnlocked,_that.dailyStreak,_that.dailyLit,_that.raceUnlockLevel,_that.raceUnlocked,_that.museumFigurineId,_that.museumLockedArtAsset,_that.museumDone,_that.museumTotal,_that.museumAllCollected,_that.museumCollectedCount,_that.museumCollectedTotal,_that.chapterNumber,_that.chapterId,_that.isBonus,_that.chapterStars,_that.chapterStarsPossible,_that.streakRelit);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayRequest playRequest,  Tier tier,  String themeId,  int coins,  bool adsRemoved,  bool dailyUnlocked,  int dailyStreak,  bool dailyLit,  int raceUnlockLevel,  bool raceUnlocked,  String? museumFigurineId,  String? museumLockedArtAsset,  int museumDone,  int museumTotal,  bool museumAllCollected,  int museumCollectedCount,  int museumCollectedTotal,  int chapterNumber,  String chapterId,  bool isBonus,  int chapterStars,  int chapterStarsPossible,  bool streakRelit)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.playRequest,_that.tier,_that.themeId,_that.coins,_that.adsRemoved,_that.dailyUnlocked,_that.dailyStreak,_that.dailyLit,_that.raceUnlockLevel,_that.raceUnlocked,_that.museumFigurineId,_that.museumLockedArtAsset,_that.museumDone,_that.museumTotal,_that.museumAllCollected,_that.museumCollectedCount,_that.museumCollectedTotal,_that.chapterNumber,_that.chapterId,_that.isBonus,_that.chapterStars,_that.chapterStarsPossible,_that.streakRelit);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayRequest playRequest,  Tier tier,  String themeId,  int coins,  bool adsRemoved,  bool dailyUnlocked,  int dailyStreak,  bool dailyLit,  int raceUnlockLevel,  bool raceUnlocked,  String? museumFigurineId,  String? museumLockedArtAsset,  int museumDone,  int museumTotal,  bool museumAllCollected,  int museumCollectedCount,  int museumCollectedTotal,  int chapterNumber,  String chapterId,  bool isBonus,  int chapterStars,  int chapterStarsPossible,  bool streakRelit)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.playRequest,_that.tier,_that.themeId,_that.coins,_that.adsRemoved,_that.dailyUnlocked,_that.dailyStreak,_that.dailyLit,_that.raceUnlockLevel,_that.raceUnlocked,_that.museumFigurineId,_that.museumLockedArtAsset,_that.museumDone,_that.museumTotal,_that.museumAllCollected,_that.museumCollectedCount,_that.museumCollectedTotal,_that.chapterNumber,_that.chapterId,_that.isBonus,_that.chapterStars,_that.chapterStarsPossible,_that.streakRelit);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState extends HomeState {
  const _HomeState({required this.playRequest, this.tier = Tier.easy, this.themeId = 'ch01', this.coins = 0, this.adsRemoved = false, this.dailyUnlocked = false, this.dailyStreak = 0, this.dailyLit = false, this.raceUnlockLevel = 20, this.raceUnlocked = false, this.museumFigurineId, this.museumLockedArtAsset, this.museumDone = 0, this.museumTotal = ChapterInfo.levelsPerChapter, this.museumAllCollected = false, this.museumCollectedCount = 0, this.museumCollectedTotal = 0, this.chapterNumber = 1, this.chapterId = 'ch01', this.isBonus = false, this.chapterStars = 0, this.chapterStarsPossible = 0, this.streakRelit = false}): super._();
  

/// What PLAY starts (`LevelResolver.homeRequest`): a campaign level
/// while one is left, else Bonus Endless (m3-design §7.4, D74). A saved
/// board of this request continues.
@override final  PlayRequest playRequest;
/// [playRequest]'s tier, for the play button's badge (§6.6): the
/// bundle entry's for a campaign level, `DifficultyCurve.tierForLevel`
/// for a bonus one.
@override@JsonKey() final  Tier tier;
/// The board theme behind the hero: `selectedTheme ?? current chapter's
/// theme` (m3-design §10.3, §9.4).
@override@JsonKey() final  String themeId;
/// The coin pill.
@override@JsonKey() final  int coins;
/// Hides the Remove Ads tile (spec §9.2; M6).
@override@JsonKey() final  bool adsRemoved;
/// The Daily tile: locked before Level 2 is won (m3-design §8.3).
@override@JsonKey() final  bool dailyUnlocked;
/// The Daily tile's flame badge, 0 hides it.
@override@JsonKey() final  int dailyStreak;
/// The Daily tile's flame is lit (`DailyStatus.lit`); with
/// [dailyStreak] above 0 and this false, the badge shows its resting,
/// paused look (E2; docs/plans/m7-design.md §8, §15.7).
@override@JsonKey() final  bool dailyLit;
/// vs Computer's unlock level (`race_unlock_level`, default 20): the
/// locked tile's "After Level {n}" (m7-design §15.8).
@override@JsonKey() final  int raceUnlockLevel;
/// That level is won (`highestLevel > raceUnlockLevel`). The race
/// itself lands in M7 phase 2; until then the tile stays locked and
/// says it is coming (m7-design §15.8).
@override@JsonKey() final  bool raceUnlocked;
/// The next uncollected figurine's id (`FigurineInfo.id`), null once
/// every catalog chapter is collected (`museumAllCollected`).
@override final  String? museumFigurineId;
/// Its locked art (`FigurineInfo.lockedArtAsset`).
@override final  String? museumLockedArtAsset;
/// The current chapter's levels already won, of [museumTotal]
/// (m3-design §10.3's "15/20"); meaningless once [museumAllCollected].
@override@JsonKey() final  int museumDone;
@override@JsonKey() final  int museumTotal;
/// Every catalog chapter's figurine is in the museum (Bonus Endless):
/// [museumCollectedCount] of [museumCollectedTotal]. Home has no Museum
/// tile any more (D111); the Museum's own 6.1c says every family is home.
@override@JsonKey() final  bool museumAllCollected;
@override@JsonKey() final  int museumCollectedCount;
@override@JsonKey() final  int museumCollectedTotal;
/// The chapter card (frame 2.1; menus spec 1.1): the chapter the PLAY
/// level is in, 1-based, and its id (`ch03`, the `chapterName` select
/// key and the palette's theme). In Bonus Endless ([isBonus]) it stays
/// the last chapter's, only for the palette (frame 12.2).
@override@JsonKey() final  int chapterNumber;
@override@JsonKey() final  String chapterId;
/// PLAY is a Bonus Endless board: the card reads "BONUS ENDLESS / Bonus
/// levels" with the whole campaign's stars (frame 12.2).
@override@JsonKey() final  bool isBonus;
/// The card's stars chip: the chapter's best stars, of
/// [chapterStarsPossible] (`StarRating.maxStars` × its levels with a par,
/// 60 for a full chapter). In Bonus Endless the same two fields hold the
/// campaign's total, of 600.
@override@JsonKey() final  int chapterStars;
@override@JsonKey() final  int chapterStarsPossible;
/// The flame was paused and a solve lit it again, and Home hasn't
/// glowed for that yet (this session or an earlier one): the tile's badge
/// shows its `relitGlow` ring once, 2,400 ms and a 400 ms fade, until
/// `HomeCubit.relitGlowFinished` (m7-4 4.10, `motion.relitHome`; frame
/// 10.7).
@override@JsonKey() final  bool streakRelit;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.playRequest, playRequest) || other.playRequest == playRequest)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.themeId, themeId) || other.themeId == themeId)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.adsRemoved, adsRemoved) || other.adsRemoved == adsRemoved)&&(identical(other.dailyUnlocked, dailyUnlocked) || other.dailyUnlocked == dailyUnlocked)&&(identical(other.dailyStreak, dailyStreak) || other.dailyStreak == dailyStreak)&&(identical(other.dailyLit, dailyLit) || other.dailyLit == dailyLit)&&(identical(other.raceUnlockLevel, raceUnlockLevel) || other.raceUnlockLevel == raceUnlockLevel)&&(identical(other.raceUnlocked, raceUnlocked) || other.raceUnlocked == raceUnlocked)&&(identical(other.museumFigurineId, museumFigurineId) || other.museumFigurineId == museumFigurineId)&&(identical(other.museumLockedArtAsset, museumLockedArtAsset) || other.museumLockedArtAsset == museumLockedArtAsset)&&(identical(other.museumDone, museumDone) || other.museumDone == museumDone)&&(identical(other.museumTotal, museumTotal) || other.museumTotal == museumTotal)&&(identical(other.museumAllCollected, museumAllCollected) || other.museumAllCollected == museumAllCollected)&&(identical(other.museumCollectedCount, museumCollectedCount) || other.museumCollectedCount == museumCollectedCount)&&(identical(other.museumCollectedTotal, museumCollectedTotal) || other.museumCollectedTotal == museumCollectedTotal)&&(identical(other.chapterNumber, chapterNumber) || other.chapterNumber == chapterNumber)&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.isBonus, isBonus) || other.isBonus == isBonus)&&(identical(other.chapterStars, chapterStars) || other.chapterStars == chapterStars)&&(identical(other.chapterStarsPossible, chapterStarsPossible) || other.chapterStarsPossible == chapterStarsPossible)&&(identical(other.streakRelit, streakRelit) || other.streakRelit == streakRelit));
}


@override
int get hashCode => Object.hashAll([runtimeType,playRequest,tier,themeId,coins,adsRemoved,dailyUnlocked,dailyStreak,dailyLit,raceUnlockLevel,raceUnlocked,museumFigurineId,museumLockedArtAsset,museumDone,museumTotal,museumAllCollected,museumCollectedCount,museumCollectedTotal,chapterNumber,chapterId,isBonus,chapterStars,chapterStarsPossible,streakRelit]);

@override
String toString() {
  return 'HomeState(playRequest: $playRequest, tier: $tier, themeId: $themeId, coins: $coins, adsRemoved: $adsRemoved, dailyUnlocked: $dailyUnlocked, dailyStreak: $dailyStreak, dailyLit: $dailyLit, raceUnlockLevel: $raceUnlockLevel, raceUnlocked: $raceUnlocked, museumFigurineId: $museumFigurineId, museumLockedArtAsset: $museumLockedArtAsset, museumDone: $museumDone, museumTotal: $museumTotal, museumAllCollected: $museumAllCollected, museumCollectedCount: $museumCollectedCount, museumCollectedTotal: $museumCollectedTotal, chapterNumber: $chapterNumber, chapterId: $chapterId, isBonus: $isBonus, chapterStars: $chapterStars, chapterStarsPossible: $chapterStarsPossible, streakRelit: $streakRelit)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 PlayRequest playRequest, Tier tier, String themeId, int coins, bool adsRemoved, bool dailyUnlocked, int dailyStreak, bool dailyLit, int raceUnlockLevel, bool raceUnlocked, String? museumFigurineId, String? museumLockedArtAsset, int museumDone, int museumTotal, bool museumAllCollected, int museumCollectedCount, int museumCollectedTotal, int chapterNumber, String chapterId, bool isBonus, int chapterStars, int chapterStarsPossible, bool streakRelit
});


@override $PlayRequestCopyWith<$Res> get playRequest;

}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playRequest = null,Object? tier = null,Object? themeId = null,Object? coins = null,Object? adsRemoved = null,Object? dailyUnlocked = null,Object? dailyStreak = null,Object? dailyLit = null,Object? raceUnlockLevel = null,Object? raceUnlocked = null,Object? museumFigurineId = freezed,Object? museumLockedArtAsset = freezed,Object? museumDone = null,Object? museumTotal = null,Object? museumAllCollected = null,Object? museumCollectedCount = null,Object? museumCollectedTotal = null,Object? chapterNumber = null,Object? chapterId = null,Object? isBonus = null,Object? chapterStars = null,Object? chapterStarsPossible = null,Object? streakRelit = null,}) {
  return _then(_HomeState(
playRequest: null == playRequest ? _self.playRequest : playRequest // ignore: cast_nullable_to_non_nullable
as PlayRequest,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,themeId: null == themeId ? _self.themeId : themeId // ignore: cast_nullable_to_non_nullable
as String,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,adsRemoved: null == adsRemoved ? _self.adsRemoved : adsRemoved // ignore: cast_nullable_to_non_nullable
as bool,dailyUnlocked: null == dailyUnlocked ? _self.dailyUnlocked : dailyUnlocked // ignore: cast_nullable_to_non_nullable
as bool,dailyStreak: null == dailyStreak ? _self.dailyStreak : dailyStreak // ignore: cast_nullable_to_non_nullable
as int,dailyLit: null == dailyLit ? _self.dailyLit : dailyLit // ignore: cast_nullable_to_non_nullable
as bool,raceUnlockLevel: null == raceUnlockLevel ? _self.raceUnlockLevel : raceUnlockLevel // ignore: cast_nullable_to_non_nullable
as int,raceUnlocked: null == raceUnlocked ? _self.raceUnlocked : raceUnlocked // ignore: cast_nullable_to_non_nullable
as bool,museumFigurineId: freezed == museumFigurineId ? _self.museumFigurineId : museumFigurineId // ignore: cast_nullable_to_non_nullable
as String?,museumLockedArtAsset: freezed == museumLockedArtAsset ? _self.museumLockedArtAsset : museumLockedArtAsset // ignore: cast_nullable_to_non_nullable
as String?,museumDone: null == museumDone ? _self.museumDone : museumDone // ignore: cast_nullable_to_non_nullable
as int,museumTotal: null == museumTotal ? _self.museumTotal : museumTotal // ignore: cast_nullable_to_non_nullable
as int,museumAllCollected: null == museumAllCollected ? _self.museumAllCollected : museumAllCollected // ignore: cast_nullable_to_non_nullable
as bool,museumCollectedCount: null == museumCollectedCount ? _self.museumCollectedCount : museumCollectedCount // ignore: cast_nullable_to_non_nullable
as int,museumCollectedTotal: null == museumCollectedTotal ? _self.museumCollectedTotal : museumCollectedTotal // ignore: cast_nullable_to_non_nullable
as int,chapterNumber: null == chapterNumber ? _self.chapterNumber : chapterNumber // ignore: cast_nullable_to_non_nullable
as int,chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String,isBonus: null == isBonus ? _self.isBonus : isBonus // ignore: cast_nullable_to_non_nullable
as bool,chapterStars: null == chapterStars ? _self.chapterStars : chapterStars // ignore: cast_nullable_to_non_nullable
as int,chapterStarsPossible: null == chapterStarsPossible ? _self.chapterStarsPossible : chapterStarsPossible // ignore: cast_nullable_to_non_nullable
as int,streakRelit: null == streakRelit ? _self.streakRelit : streakRelit // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res> get playRequest {
  
  return $PlayRequestCopyWith<$Res>(_self.playRequest, (value) {
    return _then(_self.copyWith(playRequest: value));
  });
}
}

// dart format on
