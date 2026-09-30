// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'records_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecordsState {

/// The header's coin pill (`SaveService.coins`).
 int get coins;/// The records and badges (`RecordsSummary.of`).
 RecordsSummary get summary;/// Whether each rival, 1–3, is unlocked (`race.rivals[i].unlocked`): a
/// locked one shows the locked portrait and a dash (frame 10.6).
 List<bool> get rivalsUnlocked;
/// Create a copy of RecordsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordsStateCopyWith<RecordsState> get copyWith => _$RecordsStateCopyWithImpl<RecordsState>(this as RecordsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordsState&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.rivalsUnlocked, rivalsUnlocked));
}


@override
int get hashCode => Object.hash(runtimeType,coins,summary,const DeepCollectionEquality().hash(rivalsUnlocked));

@override
String toString() {
  return 'RecordsState(coins: $coins, summary: $summary, rivalsUnlocked: $rivalsUnlocked)';
}


}

/// @nodoc
abstract mixin class $RecordsStateCopyWith<$Res>  {
  factory $RecordsStateCopyWith(RecordsState value, $Res Function(RecordsState) _then) = _$RecordsStateCopyWithImpl;
@useResult
$Res call({
 int coins, RecordsSummary summary, List<bool> rivalsUnlocked
});


$RecordsSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$RecordsStateCopyWithImpl<$Res>
    implements $RecordsStateCopyWith<$Res> {
  _$RecordsStateCopyWithImpl(this._self, this._then);

  final RecordsState _self;
  final $Res Function(RecordsState) _then;

/// Create a copy of RecordsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coins = null,Object? summary = null,Object? rivalsUnlocked = null,}) {
  return _then(_self.copyWith(
coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as RecordsSummary,rivalsUnlocked: null == rivalsUnlocked ? _self.rivalsUnlocked : rivalsUnlocked // ignore: cast_nullable_to_non_nullable
as List<bool>,
  ));
}
/// Create a copy of RecordsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordsSummaryCopyWith<$Res> get summary {
  
  return $RecordsSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecordsState].
extension RecordsStatePatterns on RecordsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordsState value)  $default,){
final _that = this;
switch (_that) {
case _RecordsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordsState value)?  $default,){
final _that = this;
switch (_that) {
case _RecordsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int coins,  RecordsSummary summary,  List<bool> rivalsUnlocked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordsState() when $default != null:
return $default(_that.coins,_that.summary,_that.rivalsUnlocked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int coins,  RecordsSummary summary,  List<bool> rivalsUnlocked)  $default,) {final _that = this;
switch (_that) {
case _RecordsState():
return $default(_that.coins,_that.summary,_that.rivalsUnlocked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int coins,  RecordsSummary summary,  List<bool> rivalsUnlocked)?  $default,) {final _that = this;
switch (_that) {
case _RecordsState() when $default != null:
return $default(_that.coins,_that.summary,_that.rivalsUnlocked);case _:
  return null;

}
}

}

/// @nodoc


class _RecordsState implements RecordsState {
  const _RecordsState({this.coins = 0, this.summary = const RecordsSummary(), final  List<bool> rivalsUnlocked = const <bool>[true, false, false]}): _rivalsUnlocked = rivalsUnlocked;
  

/// The header's coin pill (`SaveService.coins`).
@override@JsonKey() final  int coins;
/// The records and badges (`RecordsSummary.of`).
@override@JsonKey() final  RecordsSummary summary;
/// Whether each rival, 1–3, is unlocked (`race.rivals[i].unlocked`): a
/// locked one shows the locked portrait and a dash (frame 10.6).
 final  List<bool> _rivalsUnlocked;
/// Whether each rival, 1–3, is unlocked (`race.rivals[i].unlocked`): a
/// locked one shows the locked portrait and a dash (frame 10.6).
@override@JsonKey() List<bool> get rivalsUnlocked {
  if (_rivalsUnlocked is EqualUnmodifiableListView) return _rivalsUnlocked;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rivalsUnlocked);
}


/// Create a copy of RecordsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordsStateCopyWith<_RecordsState> get copyWith => __$RecordsStateCopyWithImpl<_RecordsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordsState&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._rivalsUnlocked, _rivalsUnlocked));
}


@override
int get hashCode => Object.hash(runtimeType,coins,summary,const DeepCollectionEquality().hash(_rivalsUnlocked));

@override
String toString() {
  return 'RecordsState(coins: $coins, summary: $summary, rivalsUnlocked: $rivalsUnlocked)';
}


}

/// @nodoc
abstract mixin class _$RecordsStateCopyWith<$Res> implements $RecordsStateCopyWith<$Res> {
  factory _$RecordsStateCopyWith(_RecordsState value, $Res Function(_RecordsState) _then) = __$RecordsStateCopyWithImpl;
@override @useResult
$Res call({
 int coins, RecordsSummary summary, List<bool> rivalsUnlocked
});


@override $RecordsSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$RecordsStateCopyWithImpl<$Res>
    implements _$RecordsStateCopyWith<$Res> {
  __$RecordsStateCopyWithImpl(this._self, this._then);

  final _RecordsState _self;
  final $Res Function(_RecordsState) _then;

/// Create a copy of RecordsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coins = null,Object? summary = null,Object? rivalsUnlocked = null,}) {
  return _then(_RecordsState(
coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as RecordsSummary,rivalsUnlocked: null == rivalsUnlocked ? _self._rivalsUnlocked : rivalsUnlocked // ignore: cast_nullable_to_non_nullable
as List<bool>,
  ));
}

/// Create a copy of RecordsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordsSummaryCopyWith<$Res> get summary {
  
  return $RecordsSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
