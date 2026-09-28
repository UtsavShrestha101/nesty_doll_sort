// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayEntry {

/// What was asked for.
 PlayRequest get request;/// The board (a bundled level, or one generated on the device).
 Level get level;/// Its tier: the bundle's for a campaign level; the simulated tier of a
/// bonus level (it plays as its tier, Q31); `DifficultyCurve.dailyTier`
/// for the daily (spec §7.5 "tier medium/hard").
 Tier get tier;/// What the in-progress save must match to restore (spec §13.3): the
/// bundle entry's `version`, or the generated level's
/// `generatorVersion`.
 int get levelVersion;/// Coins a win pays: `winRewardFor(tier)` for campaign and bonus levels,
/// `daily_reward` for the daily (spec §7.3, §9.4). The chapter bonus is
/// separate (m3-design §7.1).
 int get rewardCoins;/// The chapter theme behind the board when the player keeps "Match each
/// chapter" (`selectedTheme` null, spec §7.4): the level's chapter's
/// theme, the last chapter's for a bonus level, the player's current
/// chapter's for the daily (m3-design §9.1).
 String get themeId;/// A campaign level's chapter, such as `ch03`; null for bonus and
/// daily boards (they sit outside the chapters, m3-design §7.4).
 String? get chapterId;/// A campaign level that is its chapter's last: its win completes the
/// chapter (m3-design §9.3).
 bool get completesChapter;/// A generated level the simulator flags "expert only" (spec §6.4). It
/// plays as its tier and nothing is shown (Q31, m3-design §7.4).
 bool get expertOnly;/// A campaign level's bundle entry (the M2 widgets read it).
 LevelBundleEntry? get bundleEntry;
/// Create a copy of PlayEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayEntryCopyWith<PlayEntry> get copyWith => _$PlayEntryCopyWithImpl<PlayEntry>(this as PlayEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayEntry&&(identical(other.request, request) || other.request == request)&&(identical(other.level, level) || other.level == level)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.levelVersion, levelVersion) || other.levelVersion == levelVersion)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.themeId, themeId) || other.themeId == themeId)&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.completesChapter, completesChapter) || other.completesChapter == completesChapter)&&(identical(other.expertOnly, expertOnly) || other.expertOnly == expertOnly)&&(identical(other.bundleEntry, bundleEntry) || other.bundleEntry == bundleEntry));
}


@override
int get hashCode => Object.hash(runtimeType,request,level,tier,levelVersion,rewardCoins,themeId,chapterId,completesChapter,expertOnly,bundleEntry);

@override
String toString() {
  return 'PlayEntry(request: $request, level: $level, tier: $tier, levelVersion: $levelVersion, rewardCoins: $rewardCoins, themeId: $themeId, chapterId: $chapterId, completesChapter: $completesChapter, expertOnly: $expertOnly, bundleEntry: $bundleEntry)';
}


}

/// @nodoc
abstract mixin class $PlayEntryCopyWith<$Res>  {
  factory $PlayEntryCopyWith(PlayEntry value, $Res Function(PlayEntry) _then) = _$PlayEntryCopyWithImpl;
@useResult
$Res call({
 PlayRequest request, Level level, Tier tier, int levelVersion, int rewardCoins, String themeId, String? chapterId, bool completesChapter, bool expertOnly, LevelBundleEntry? bundleEntry
});


$PlayRequestCopyWith<$Res> get request;

}
/// @nodoc
class _$PlayEntryCopyWithImpl<$Res>
    implements $PlayEntryCopyWith<$Res> {
  _$PlayEntryCopyWithImpl(this._self, this._then);

  final PlayEntry _self;
  final $Res Function(PlayEntry) _then;

/// Create a copy of PlayEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? request = null,Object? level = null,Object? tier = null,Object? levelVersion = null,Object? rewardCoins = null,Object? themeId = null,Object? chapterId = freezed,Object? completesChapter = null,Object? expertOnly = null,Object? bundleEntry = freezed,}) {
  return _then(_self.copyWith(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PlayRequest,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as Level,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,levelVersion: null == levelVersion ? _self.levelVersion : levelVersion // ignore: cast_nullable_to_non_nullable
as int,rewardCoins: null == rewardCoins ? _self.rewardCoins : rewardCoins // ignore: cast_nullable_to_non_nullable
as int,themeId: null == themeId ? _self.themeId : themeId // ignore: cast_nullable_to_non_nullable
as String,chapterId: freezed == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String?,completesChapter: null == completesChapter ? _self.completesChapter : completesChapter // ignore: cast_nullable_to_non_nullable
as bool,expertOnly: null == expertOnly ? _self.expertOnly : expertOnly // ignore: cast_nullable_to_non_nullable
as bool,bundleEntry: freezed == bundleEntry ? _self.bundleEntry : bundleEntry // ignore: cast_nullable_to_non_nullable
as LevelBundleEntry?,
  ));
}
/// Create a copy of PlayEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res> get request {
  
  return $PlayRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayEntry].
extension PlayEntryPatterns on PlayEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayEntry value)  $default,){
final _that = this;
switch (_that) {
case _PlayEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PlayEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayRequest request,  Level level,  Tier tier,  int levelVersion,  int rewardCoins,  String themeId,  String? chapterId,  bool completesChapter,  bool expertOnly,  LevelBundleEntry? bundleEntry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayEntry() when $default != null:
return $default(_that.request,_that.level,_that.tier,_that.levelVersion,_that.rewardCoins,_that.themeId,_that.chapterId,_that.completesChapter,_that.expertOnly,_that.bundleEntry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayRequest request,  Level level,  Tier tier,  int levelVersion,  int rewardCoins,  String themeId,  String? chapterId,  bool completesChapter,  bool expertOnly,  LevelBundleEntry? bundleEntry)  $default,) {final _that = this;
switch (_that) {
case _PlayEntry():
return $default(_that.request,_that.level,_that.tier,_that.levelVersion,_that.rewardCoins,_that.themeId,_that.chapterId,_that.completesChapter,_that.expertOnly,_that.bundleEntry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayRequest request,  Level level,  Tier tier,  int levelVersion,  int rewardCoins,  String themeId,  String? chapterId,  bool completesChapter,  bool expertOnly,  LevelBundleEntry? bundleEntry)?  $default,) {final _that = this;
switch (_that) {
case _PlayEntry() when $default != null:
return $default(_that.request,_that.level,_that.tier,_that.levelVersion,_that.rewardCoins,_that.themeId,_that.chapterId,_that.completesChapter,_that.expertOnly,_that.bundleEntry);case _:
  return null;

}
}

}

/// @nodoc


class _PlayEntry extends PlayEntry {
  const _PlayEntry({required this.request, required this.level, required this.tier, required this.levelVersion, required this.rewardCoins, required this.themeId, this.chapterId, this.completesChapter = false, this.expertOnly = false, this.bundleEntry}): super._();
  

/// What was asked for.
@override final  PlayRequest request;
/// The board (a bundled level, or one generated on the device).
@override final  Level level;
/// Its tier: the bundle's for a campaign level; the simulated tier of a
/// bonus level (it plays as its tier, Q31); `DifficultyCurve.dailyTier`
/// for the daily (spec §7.5 "tier medium/hard").
@override final  Tier tier;
/// What the in-progress save must match to restore (spec §13.3): the
/// bundle entry's `version`, or the generated level's
/// `generatorVersion`.
@override final  int levelVersion;
/// Coins a win pays: `winRewardFor(tier)` for campaign and bonus levels,
/// `daily_reward` for the daily (spec §7.3, §9.4). The chapter bonus is
/// separate (m3-design §7.1).
@override final  int rewardCoins;
/// The chapter theme behind the board when the player keeps "Match each
/// chapter" (`selectedTheme` null, spec §7.4): the level's chapter's
/// theme, the last chapter's for a bonus level, the player's current
/// chapter's for the daily (m3-design §9.1).
@override final  String themeId;
/// A campaign level's chapter, such as `ch03`; null for bonus and
/// daily boards (they sit outside the chapters, m3-design §7.4).
@override final  String? chapterId;
/// A campaign level that is its chapter's last: its win completes the
/// chapter (m3-design §9.3).
@override@JsonKey() final  bool completesChapter;
/// A generated level the simulator flags "expert only" (spec §6.4). It
/// plays as its tier and nothing is shown (Q31, m3-design §7.4).
@override@JsonKey() final  bool expertOnly;
/// A campaign level's bundle entry (the M2 widgets read it).
@override final  LevelBundleEntry? bundleEntry;

/// Create a copy of PlayEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayEntryCopyWith<_PlayEntry> get copyWith => __$PlayEntryCopyWithImpl<_PlayEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayEntry&&(identical(other.request, request) || other.request == request)&&(identical(other.level, level) || other.level == level)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.levelVersion, levelVersion) || other.levelVersion == levelVersion)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.themeId, themeId) || other.themeId == themeId)&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.completesChapter, completesChapter) || other.completesChapter == completesChapter)&&(identical(other.expertOnly, expertOnly) || other.expertOnly == expertOnly)&&(identical(other.bundleEntry, bundleEntry) || other.bundleEntry == bundleEntry));
}


@override
int get hashCode => Object.hash(runtimeType,request,level,tier,levelVersion,rewardCoins,themeId,chapterId,completesChapter,expertOnly,bundleEntry);

@override
String toString() {
  return 'PlayEntry(request: $request, level: $level, tier: $tier, levelVersion: $levelVersion, rewardCoins: $rewardCoins, themeId: $themeId, chapterId: $chapterId, completesChapter: $completesChapter, expertOnly: $expertOnly, bundleEntry: $bundleEntry)';
}


}

/// @nodoc
abstract mixin class _$PlayEntryCopyWith<$Res> implements $PlayEntryCopyWith<$Res> {
  factory _$PlayEntryCopyWith(_PlayEntry value, $Res Function(_PlayEntry) _then) = __$PlayEntryCopyWithImpl;
@override @useResult
$Res call({
 PlayRequest request, Level level, Tier tier, int levelVersion, int rewardCoins, String themeId, String? chapterId, bool completesChapter, bool expertOnly, LevelBundleEntry? bundleEntry
});


@override $PlayRequestCopyWith<$Res> get request;

}
/// @nodoc
class __$PlayEntryCopyWithImpl<$Res>
    implements _$PlayEntryCopyWith<$Res> {
  __$PlayEntryCopyWithImpl(this._self, this._then);

  final _PlayEntry _self;
  final $Res Function(_PlayEntry) _then;

/// Create a copy of PlayEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? request = null,Object? level = null,Object? tier = null,Object? levelVersion = null,Object? rewardCoins = null,Object? themeId = null,Object? chapterId = freezed,Object? completesChapter = null,Object? expertOnly = null,Object? bundleEntry = freezed,}) {
  return _then(_PlayEntry(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PlayRequest,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as Level,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,levelVersion: null == levelVersion ? _self.levelVersion : levelVersion // ignore: cast_nullable_to_non_nullable
as int,rewardCoins: null == rewardCoins ? _self.rewardCoins : rewardCoins // ignore: cast_nullable_to_non_nullable
as int,themeId: null == themeId ? _self.themeId : themeId // ignore: cast_nullable_to_non_nullable
as String,chapterId: freezed == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String?,completesChapter: null == completesChapter ? _self.completesChapter : completesChapter // ignore: cast_nullable_to_non_nullable
as bool,expertOnly: null == expertOnly ? _self.expertOnly : expertOnly // ignore: cast_nullable_to_non_nullable
as bool,bundleEntry: freezed == bundleEntry ? _self.bundleEntry : bundleEntry // ignore: cast_nullable_to_non_nullable
as LevelBundleEntry?,
  ));
}

/// Create a copy of PlayEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res> get request {
  
  return $PlayRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}

// dart format on
