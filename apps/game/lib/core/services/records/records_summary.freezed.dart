// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'records_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecordsSummary {

/// `RecordRules.levelsWon`: campaign levels behind `highestLevel` plus
/// the Bonus Endless levels won.
 int get levelsWon;/// `records.families`.
 int get families;/// `records.dolls`.
 int get dolls;/// `records.dailies`.
 int get dailies;/// `records.longestRun`: the longest unbroken daily run.
 int get longestRun;/// Races won per rival, rivals 1–3 (`race.rivals[i].wins`; 0 until the
/// race lands in phase 2).
 List<int> get raceWins;/// The badges earned, in `BadgeId` order.
 List<BadgeId> get badges;/// Best stars earned over every level (`levelStars` summed; spec-prop
/// §7.10, m7-design P3.5): Records' "Stars" row.
 int get stars;/// `StarRating.maxStars` × the bundled levels with a par (600 at
/// launch): the "Stars" row's total.
 int get starsPossible;/// Levels at 3 stars: Records' "Levels with 3 stars" row.
 int get threeStarLevels;
/// Create a copy of RecordsSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordsSummaryCopyWith<RecordsSummary> get copyWith => _$RecordsSummaryCopyWithImpl<RecordsSummary>(this as RecordsSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordsSummary&&(identical(other.levelsWon, levelsWon) || other.levelsWon == levelsWon)&&(identical(other.families, families) || other.families == families)&&(identical(other.dolls, dolls) || other.dolls == dolls)&&(identical(other.dailies, dailies) || other.dailies == dailies)&&(identical(other.longestRun, longestRun) || other.longestRun == longestRun)&&const DeepCollectionEquality().equals(other.raceWins, raceWins)&&const DeepCollectionEquality().equals(other.badges, badges)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.starsPossible, starsPossible) || other.starsPossible == starsPossible)&&(identical(other.threeStarLevels, threeStarLevels) || other.threeStarLevels == threeStarLevels));
}


@override
int get hashCode => Object.hash(runtimeType,levelsWon,families,dolls,dailies,longestRun,const DeepCollectionEquality().hash(raceWins),const DeepCollectionEquality().hash(badges),stars,starsPossible,threeStarLevels);

@override
String toString() {
  return 'RecordsSummary(levelsWon: $levelsWon, families: $families, dolls: $dolls, dailies: $dailies, longestRun: $longestRun, raceWins: $raceWins, badges: $badges, stars: $stars, starsPossible: $starsPossible, threeStarLevels: $threeStarLevels)';
}


}

/// @nodoc
abstract mixin class $RecordsSummaryCopyWith<$Res>  {
  factory $RecordsSummaryCopyWith(RecordsSummary value, $Res Function(RecordsSummary) _then) = _$RecordsSummaryCopyWithImpl;
@useResult
$Res call({
 int levelsWon, int families, int dolls, int dailies, int longestRun, List<int> raceWins, List<BadgeId> badges, int stars, int starsPossible, int threeStarLevels
});




}
/// @nodoc
class _$RecordsSummaryCopyWithImpl<$Res>
    implements $RecordsSummaryCopyWith<$Res> {
  _$RecordsSummaryCopyWithImpl(this._self, this._then);

  final RecordsSummary _self;
  final $Res Function(RecordsSummary) _then;

/// Create a copy of RecordsSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? levelsWon = null,Object? families = null,Object? dolls = null,Object? dailies = null,Object? longestRun = null,Object? raceWins = null,Object? badges = null,Object? stars = null,Object? starsPossible = null,Object? threeStarLevels = null,}) {
  return _then(_self.copyWith(
levelsWon: null == levelsWon ? _self.levelsWon : levelsWon // ignore: cast_nullable_to_non_nullable
as int,families: null == families ? _self.families : families // ignore: cast_nullable_to_non_nullable
as int,dolls: null == dolls ? _self.dolls : dolls // ignore: cast_nullable_to_non_nullable
as int,dailies: null == dailies ? _self.dailies : dailies // ignore: cast_nullable_to_non_nullable
as int,longestRun: null == longestRun ? _self.longestRun : longestRun // ignore: cast_nullable_to_non_nullable
as int,raceWins: null == raceWins ? _self.raceWins : raceWins // ignore: cast_nullable_to_non_nullable
as List<int>,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<BadgeId>,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,starsPossible: null == starsPossible ? _self.starsPossible : starsPossible // ignore: cast_nullable_to_non_nullable
as int,threeStarLevels: null == threeStarLevels ? _self.threeStarLevels : threeStarLevels // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordsSummary].
extension RecordsSummaryPatterns on RecordsSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordsSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordsSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordsSummary value)  $default,){
final _that = this;
switch (_that) {
case _RecordsSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordsSummary value)?  $default,){
final _that = this;
switch (_that) {
case _RecordsSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int levelsWon,  int families,  int dolls,  int dailies,  int longestRun,  List<int> raceWins,  List<BadgeId> badges,  int stars,  int starsPossible,  int threeStarLevels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordsSummary() when $default != null:
return $default(_that.levelsWon,_that.families,_that.dolls,_that.dailies,_that.longestRun,_that.raceWins,_that.badges,_that.stars,_that.starsPossible,_that.threeStarLevels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int levelsWon,  int families,  int dolls,  int dailies,  int longestRun,  List<int> raceWins,  List<BadgeId> badges,  int stars,  int starsPossible,  int threeStarLevels)  $default,) {final _that = this;
switch (_that) {
case _RecordsSummary():
return $default(_that.levelsWon,_that.families,_that.dolls,_that.dailies,_that.longestRun,_that.raceWins,_that.badges,_that.stars,_that.starsPossible,_that.threeStarLevels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int levelsWon,  int families,  int dolls,  int dailies,  int longestRun,  List<int> raceWins,  List<BadgeId> badges,  int stars,  int starsPossible,  int threeStarLevels)?  $default,) {final _that = this;
switch (_that) {
case _RecordsSummary() when $default != null:
return $default(_that.levelsWon,_that.families,_that.dolls,_that.dailies,_that.longestRun,_that.raceWins,_that.badges,_that.stars,_that.starsPossible,_that.threeStarLevels);case _:
  return null;

}
}

}

/// @nodoc


class _RecordsSummary implements RecordsSummary {
  const _RecordsSummary({this.levelsWon = 0, this.families = 0, this.dolls = 0, this.dailies = 0, this.longestRun = 0, final  List<int> raceWins = const <int>[0, 0, 0], final  List<BadgeId> badges = const <BadgeId>[], this.stars = 0, this.starsPossible = 0, this.threeStarLevels = 0}): _raceWins = raceWins,_badges = badges;
  

/// `RecordRules.levelsWon`: campaign levels behind `highestLevel` plus
/// the Bonus Endless levels won.
@override@JsonKey() final  int levelsWon;
/// `records.families`.
@override@JsonKey() final  int families;
/// `records.dolls`.
@override@JsonKey() final  int dolls;
/// `records.dailies`.
@override@JsonKey() final  int dailies;
/// `records.longestRun`: the longest unbroken daily run.
@override@JsonKey() final  int longestRun;
/// Races won per rival, rivals 1–3 (`race.rivals[i].wins`; 0 until the
/// race lands in phase 2).
 final  List<int> _raceWins;
/// Races won per rival, rivals 1–3 (`race.rivals[i].wins`; 0 until the
/// race lands in phase 2).
@override@JsonKey() List<int> get raceWins {
  if (_raceWins is EqualUnmodifiableListView) return _raceWins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_raceWins);
}

/// The badges earned, in `BadgeId` order.
 final  List<BadgeId> _badges;
/// The badges earned, in `BadgeId` order.
@override@JsonKey() List<BadgeId> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

/// Best stars earned over every level (`levelStars` summed; spec-prop
/// §7.10, m7-design P3.5): Records' "Stars" row.
@override@JsonKey() final  int stars;
/// `StarRating.maxStars` × the bundled levels with a par (600 at
/// launch): the "Stars" row's total.
@override@JsonKey() final  int starsPossible;
/// Levels at 3 stars: Records' "Levels with 3 stars" row.
@override@JsonKey() final  int threeStarLevels;

/// Create a copy of RecordsSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordsSummaryCopyWith<_RecordsSummary> get copyWith => __$RecordsSummaryCopyWithImpl<_RecordsSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordsSummary&&(identical(other.levelsWon, levelsWon) || other.levelsWon == levelsWon)&&(identical(other.families, families) || other.families == families)&&(identical(other.dolls, dolls) || other.dolls == dolls)&&(identical(other.dailies, dailies) || other.dailies == dailies)&&(identical(other.longestRun, longestRun) || other.longestRun == longestRun)&&const DeepCollectionEquality().equals(other._raceWins, _raceWins)&&const DeepCollectionEquality().equals(other._badges, _badges)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.starsPossible, starsPossible) || other.starsPossible == starsPossible)&&(identical(other.threeStarLevels, threeStarLevels) || other.threeStarLevels == threeStarLevels));
}


@override
int get hashCode => Object.hash(runtimeType,levelsWon,families,dolls,dailies,longestRun,const DeepCollectionEquality().hash(_raceWins),const DeepCollectionEquality().hash(_badges),stars,starsPossible,threeStarLevels);

@override
String toString() {
  return 'RecordsSummary(levelsWon: $levelsWon, families: $families, dolls: $dolls, dailies: $dailies, longestRun: $longestRun, raceWins: $raceWins, badges: $badges, stars: $stars, starsPossible: $starsPossible, threeStarLevels: $threeStarLevels)';
}


}

/// @nodoc
abstract mixin class _$RecordsSummaryCopyWith<$Res> implements $RecordsSummaryCopyWith<$Res> {
  factory _$RecordsSummaryCopyWith(_RecordsSummary value, $Res Function(_RecordsSummary) _then) = __$RecordsSummaryCopyWithImpl;
@override @useResult
$Res call({
 int levelsWon, int families, int dolls, int dailies, int longestRun, List<int> raceWins, List<BadgeId> badges, int stars, int starsPossible, int threeStarLevels
});




}
/// @nodoc
class __$RecordsSummaryCopyWithImpl<$Res>
    implements _$RecordsSummaryCopyWith<$Res> {
  __$RecordsSummaryCopyWithImpl(this._self, this._then);

  final _RecordsSummary _self;
  final $Res Function(_RecordsSummary) _then;

/// Create a copy of RecordsSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? levelsWon = null,Object? families = null,Object? dolls = null,Object? dailies = null,Object? longestRun = null,Object? raceWins = null,Object? badges = null,Object? stars = null,Object? starsPossible = null,Object? threeStarLevels = null,}) {
  return _then(_RecordsSummary(
levelsWon: null == levelsWon ? _self.levelsWon : levelsWon // ignore: cast_nullable_to_non_nullable
as int,families: null == families ? _self.families : families // ignore: cast_nullable_to_non_nullable
as int,dolls: null == dolls ? _self.dolls : dolls // ignore: cast_nullable_to_non_nullable
as int,dailies: null == dailies ? _self.dailies : dailies // ignore: cast_nullable_to_non_nullable
as int,longestRun: null == longestRun ? _self.longestRun : longestRun // ignore: cast_nullable_to_non_nullable
as int,raceWins: null == raceWins ? _self._raceWins : raceWins // ignore: cast_nullable_to_non_nullable
as List<int>,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<BadgeId>,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,starsPossible: null == starsPossible ? _self.starsPossible : starsPossible // ignore: cast_nullable_to_non_nullable
as int,threeStarLevels: null == threeStarLevels ? _self.threeStarLevels : threeStarLevels // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
