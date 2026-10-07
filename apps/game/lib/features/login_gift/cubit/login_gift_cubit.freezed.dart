// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_gift_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginGiftState {

 LoginGiftPhase get phase; List<LoginGiftReward> get track; int get claims; LocalDate get today;/// While claimed coins are in the air, the most Home's coin pill may
/// show (coins before the claim plus those landed so far); null
/// otherwise. Home shows `min(home.coins, coinsCap)`.
 int? get coinsCap;/// The player's hint boosters, the count Home's tally shows once a
/// gift's hint lands (frame 13.5c, `gift.tally.count`).
 int get hints;/// The player's extra slot boosters, the tally's count for a gift's
/// slot (frame 13.6d).
 int get slots;
/// Create a copy of LoginGiftState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginGiftStateCopyWith<LoginGiftState> get copyWith => _$LoginGiftStateCopyWithImpl<LoginGiftState>(this as LoginGiftState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginGiftState&&(identical(other.phase, phase) || other.phase == phase)&&const DeepCollectionEquality().equals(other.track, track)&&(identical(other.claims, claims) || other.claims == claims)&&(identical(other.today, today) || other.today == today)&&(identical(other.coinsCap, coinsCap) || other.coinsCap == coinsCap)&&(identical(other.hints, hints) || other.hints == hints)&&(identical(other.slots, slots) || other.slots == slots));
}


@override
int get hashCode => Object.hash(runtimeType,phase,const DeepCollectionEquality().hash(track),claims,today,coinsCap,hints,slots);

@override
String toString() {
  return 'LoginGiftState(phase: $phase, track: $track, claims: $claims, today: $today, coinsCap: $coinsCap, hints: $hints, slots: $slots)';
}


}

/// @nodoc
abstract mixin class $LoginGiftStateCopyWith<$Res>  {
  factory $LoginGiftStateCopyWith(LoginGiftState value, $Res Function(LoginGiftState) _then) = _$LoginGiftStateCopyWithImpl;
@useResult
$Res call({
 LoginGiftPhase phase, List<LoginGiftReward> track, int claims, LocalDate today, int? coinsCap, int hints, int slots
});




}
/// @nodoc
class _$LoginGiftStateCopyWithImpl<$Res>
    implements $LoginGiftStateCopyWith<$Res> {
  _$LoginGiftStateCopyWithImpl(this._self, this._then);

  final LoginGiftState _self;
  final $Res Function(LoginGiftState) _then;

/// Create a copy of LoginGiftState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? track = null,Object? claims = null,Object? today = null,Object? coinsCap = freezed,Object? hints = null,Object? slots = null,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as LoginGiftPhase,track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as List<LoginGiftReward>,claims: null == claims ? _self.claims : claims // ignore: cast_nullable_to_non_nullable
as int,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,coinsCap: freezed == coinsCap ? _self.coinsCap : coinsCap // ignore: cast_nullable_to_non_nullable
as int?,hints: null == hints ? _self.hints : hints // ignore: cast_nullable_to_non_nullable
as int,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginGiftState].
extension LoginGiftStatePatterns on LoginGiftState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginGiftState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginGiftState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginGiftState value)  $default,){
final _that = this;
switch (_that) {
case _LoginGiftState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginGiftState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginGiftState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LoginGiftPhase phase,  List<LoginGiftReward> track,  int claims,  LocalDate today,  int? coinsCap,  int hints,  int slots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginGiftState() when $default != null:
return $default(_that.phase,_that.track,_that.claims,_that.today,_that.coinsCap,_that.hints,_that.slots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LoginGiftPhase phase,  List<LoginGiftReward> track,  int claims,  LocalDate today,  int? coinsCap,  int hints,  int slots)  $default,) {final _that = this;
switch (_that) {
case _LoginGiftState():
return $default(_that.phase,_that.track,_that.claims,_that.today,_that.coinsCap,_that.hints,_that.slots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LoginGiftPhase phase,  List<LoginGiftReward> track,  int claims,  LocalDate today,  int? coinsCap,  int hints,  int slots)?  $default,) {final _that = this;
switch (_that) {
case _LoginGiftState() when $default != null:
return $default(_that.phase,_that.track,_that.claims,_that.today,_that.coinsCap,_that.hints,_that.slots);case _:
  return null;

}
}

}

/// @nodoc


class _LoginGiftState extends LoginGiftState {
  const _LoginGiftState({required this.phase, required final  List<LoginGiftReward> track, required this.claims, required this.today, this.coinsCap, this.hints = 0, this.slots = 0}): _track = track,super._();
  

@override final  LoginGiftPhase phase;
 final  List<LoginGiftReward> _track;
@override List<LoginGiftReward> get track {
  if (_track is EqualUnmodifiableListView) return _track;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_track);
}

@override final  int claims;
@override final  LocalDate today;
/// While claimed coins are in the air, the most Home's coin pill may
/// show (coins before the claim plus those landed so far); null
/// otherwise. Home shows `min(home.coins, coinsCap)`.
@override final  int? coinsCap;
/// The player's hint boosters, the count Home's tally shows once a
/// gift's hint lands (frame 13.5c, `gift.tally.count`).
@override@JsonKey() final  int hints;
/// The player's extra slot boosters, the tally's count for a gift's
/// slot (frame 13.6d).
@override@JsonKey() final  int slots;

/// Create a copy of LoginGiftState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginGiftStateCopyWith<_LoginGiftState> get copyWith => __$LoginGiftStateCopyWithImpl<_LoginGiftState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginGiftState&&(identical(other.phase, phase) || other.phase == phase)&&const DeepCollectionEquality().equals(other._track, _track)&&(identical(other.claims, claims) || other.claims == claims)&&(identical(other.today, today) || other.today == today)&&(identical(other.coinsCap, coinsCap) || other.coinsCap == coinsCap)&&(identical(other.hints, hints) || other.hints == hints)&&(identical(other.slots, slots) || other.slots == slots));
}


@override
int get hashCode => Object.hash(runtimeType,phase,const DeepCollectionEquality().hash(_track),claims,today,coinsCap,hints,slots);

@override
String toString() {
  return 'LoginGiftState(phase: $phase, track: $track, claims: $claims, today: $today, coinsCap: $coinsCap, hints: $hints, slots: $slots)';
}


}

/// @nodoc
abstract mixin class _$LoginGiftStateCopyWith<$Res> implements $LoginGiftStateCopyWith<$Res> {
  factory _$LoginGiftStateCopyWith(_LoginGiftState value, $Res Function(_LoginGiftState) _then) = __$LoginGiftStateCopyWithImpl;
@override @useResult
$Res call({
 LoginGiftPhase phase, List<LoginGiftReward> track, int claims, LocalDate today, int? coinsCap, int hints, int slots
});




}
/// @nodoc
class __$LoginGiftStateCopyWithImpl<$Res>
    implements _$LoginGiftStateCopyWith<$Res> {
  __$LoginGiftStateCopyWithImpl(this._self, this._then);

  final _LoginGiftState _self;
  final $Res Function(_LoginGiftState) _then;

/// Create a copy of LoginGiftState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? track = null,Object? claims = null,Object? today = null,Object? coinsCap = freezed,Object? hints = null,Object? slots = null,}) {
  return _then(_LoginGiftState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as LoginGiftPhase,track: null == track ? _self._track : track // ignore: cast_nullable_to_non_nullable
as List<LoginGiftReward>,claims: null == claims ? _self.claims : claims // ignore: cast_nullable_to_non_nullable
as int,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,coinsCap: freezed == coinsCap ? _self.coinsCap : coinsCap // ignore: cast_nullable_to_non_nullable
as int?,hints: null == hints ? _self.hints : hints // ignore: cast_nullable_to_non_nullable
as int,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
