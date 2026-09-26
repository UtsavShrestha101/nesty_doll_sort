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

/// The level the play button starts (spec §10.2 #2): the save's
/// current level, moved past any skipped bundled level.
 int get currentLevel;/// Its tier, for the play button's HARD / SUPER HARD badge (§6.6).
 Tier get tier;/// Its chapter (`ch01`): Home's background follows the player's
/// chapter.
 String get chapterId;/// The coin pill.
 int get coins;/// Levels available offline.
 int get levelCount;/// Every bundled level is won: Play shows All Levels Done (frame 4.9)
/// until Bonus Endless (M3).
 bool get allLevelsDone;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.levelCount, levelCount) || other.levelCount == levelCount)&&(identical(other.allLevelsDone, allLevelsDone) || other.allLevelsDone == allLevelsDone));
}


@override
int get hashCode => Object.hash(runtimeType,currentLevel,tier,chapterId,coins,levelCount,allLevelsDone);

@override
String toString() {
  return 'HomeState(currentLevel: $currentLevel, tier: $tier, chapterId: $chapterId, coins: $coins, levelCount: $levelCount, allLevelsDone: $allLevelsDone)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 int currentLevel, Tier tier, String chapterId, int coins, int levelCount, bool allLevelsDone
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentLevel = null,Object? tier = null,Object? chapterId = null,Object? coins = null,Object? levelCount = null,Object? allLevelsDone = null,}) {
  return _then(_self.copyWith(
currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as int,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,levelCount: null == levelCount ? _self.levelCount : levelCount // ignore: cast_nullable_to_non_nullable
as int,allLevelsDone: null == allLevelsDone ? _self.allLevelsDone : allLevelsDone // ignore: cast_nullable_to_non_nullable
as bool,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentLevel,  Tier tier,  String chapterId,  int coins,  int levelCount,  bool allLevelsDone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.currentLevel,_that.tier,_that.chapterId,_that.coins,_that.levelCount,_that.allLevelsDone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentLevel,  Tier tier,  String chapterId,  int coins,  int levelCount,  bool allLevelsDone)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.currentLevel,_that.tier,_that.chapterId,_that.coins,_that.levelCount,_that.allLevelsDone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentLevel,  Tier tier,  String chapterId,  int coins,  int levelCount,  bool allLevelsDone)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.currentLevel,_that.tier,_that.chapterId,_that.coins,_that.levelCount,_that.allLevelsDone);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({this.currentLevel = 1, this.tier = Tier.easy, this.chapterId = 'ch01', this.coins = 0, this.levelCount = 0, this.allLevelsDone = false});
  

/// The level the play button starts (spec §10.2 #2): the save's
/// current level, moved past any skipped bundled level.
@override@JsonKey() final  int currentLevel;
/// Its tier, for the play button's HARD / SUPER HARD badge (§6.6).
@override@JsonKey() final  Tier tier;
/// Its chapter (`ch01`): Home's background follows the player's
/// chapter.
@override@JsonKey() final  String chapterId;
/// The coin pill.
@override@JsonKey() final  int coins;
/// Levels available offline.
@override@JsonKey() final  int levelCount;
/// Every bundled level is won: Play shows All Levels Done (frame 4.9)
/// until Bonus Endless (M3).
@override@JsonKey() final  bool allLevelsDone;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.levelCount, levelCount) || other.levelCount == levelCount)&&(identical(other.allLevelsDone, allLevelsDone) || other.allLevelsDone == allLevelsDone));
}


@override
int get hashCode => Object.hash(runtimeType,currentLevel,tier,chapterId,coins,levelCount,allLevelsDone);

@override
String toString() {
  return 'HomeState(currentLevel: $currentLevel, tier: $tier, chapterId: $chapterId, coins: $coins, levelCount: $levelCount, allLevelsDone: $allLevelsDone)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 int currentLevel, Tier tier, String chapterId, int coins, int levelCount, bool allLevelsDone
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentLevel = null,Object? tier = null,Object? chapterId = null,Object? coins = null,Object? levelCount = null,Object? allLevelsDone = null,}) {
  return _then(_HomeState(
currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as int,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,levelCount: null == levelCount ? _self.levelCount : levelCount // ignore: cast_nullable_to_non_nullable
as int,allLevelsDone: null == allLevelsDone ? _self.allLevelsDone : allLevelsDone // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
