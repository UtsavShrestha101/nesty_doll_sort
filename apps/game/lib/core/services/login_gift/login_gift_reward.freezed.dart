// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_gift_reward.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginGiftReward {

 int get coins;/// Hint boosters (`BoosterKind.hint`).
 int get hints;/// Extra slot boosters (`BoosterKind.extraSlot`).
 int get slots;
/// Create a copy of LoginGiftReward
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginGiftRewardCopyWith<LoginGiftReward> get copyWith => _$LoginGiftRewardCopyWithImpl<LoginGiftReward>(this as LoginGiftReward, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginGiftReward&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.hints, hints) || other.hints == hints)&&(identical(other.slots, slots) || other.slots == slots));
}


@override
int get hashCode => Object.hash(runtimeType,coins,hints,slots);

@override
String toString() {
  return 'LoginGiftReward(coins: $coins, hints: $hints, slots: $slots)';
}


}

/// @nodoc
abstract mixin class $LoginGiftRewardCopyWith<$Res>  {
  factory $LoginGiftRewardCopyWith(LoginGiftReward value, $Res Function(LoginGiftReward) _then) = _$LoginGiftRewardCopyWithImpl;
@useResult
$Res call({
 int coins, int hints, int slots
});




}
/// @nodoc
class _$LoginGiftRewardCopyWithImpl<$Res>
    implements $LoginGiftRewardCopyWith<$Res> {
  _$LoginGiftRewardCopyWithImpl(this._self, this._then);

  final LoginGiftReward _self;
  final $Res Function(LoginGiftReward) _then;

/// Create a copy of LoginGiftReward
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coins = null,Object? hints = null,Object? slots = null,}) {
  return _then(_self.copyWith(
coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,hints: null == hints ? _self.hints : hints // ignore: cast_nullable_to_non_nullable
as int,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginGiftReward].
extension LoginGiftRewardPatterns on LoginGiftReward {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginGiftReward value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginGiftReward() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginGiftReward value)  $default,){
final _that = this;
switch (_that) {
case _LoginGiftReward():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginGiftReward value)?  $default,){
final _that = this;
switch (_that) {
case _LoginGiftReward() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int coins,  int hints,  int slots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginGiftReward() when $default != null:
return $default(_that.coins,_that.hints,_that.slots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int coins,  int hints,  int slots)  $default,) {final _that = this;
switch (_that) {
case _LoginGiftReward():
return $default(_that.coins,_that.hints,_that.slots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int coins,  int hints,  int slots)?  $default,) {final _that = this;
switch (_that) {
case _LoginGiftReward() when $default != null:
return $default(_that.coins,_that.hints,_that.slots);case _:
  return null;

}
}

}

/// @nodoc


class _LoginGiftReward implements LoginGiftReward {
  const _LoginGiftReward({this.coins = 0, this.hints = 0, this.slots = 0});
  

@override@JsonKey() final  int coins;
/// Hint boosters (`BoosterKind.hint`).
@override@JsonKey() final  int hints;
/// Extra slot boosters (`BoosterKind.extraSlot`).
@override@JsonKey() final  int slots;

/// Create a copy of LoginGiftReward
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginGiftRewardCopyWith<_LoginGiftReward> get copyWith => __$LoginGiftRewardCopyWithImpl<_LoginGiftReward>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginGiftReward&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.hints, hints) || other.hints == hints)&&(identical(other.slots, slots) || other.slots == slots));
}


@override
int get hashCode => Object.hash(runtimeType,coins,hints,slots);

@override
String toString() {
  return 'LoginGiftReward(coins: $coins, hints: $hints, slots: $slots)';
}


}

/// @nodoc
abstract mixin class _$LoginGiftRewardCopyWith<$Res> implements $LoginGiftRewardCopyWith<$Res> {
  factory _$LoginGiftRewardCopyWith(_LoginGiftReward value, $Res Function(_LoginGiftReward) _then) = __$LoginGiftRewardCopyWithImpl;
@override @useResult
$Res call({
 int coins, int hints, int slots
});




}
/// @nodoc
class __$LoginGiftRewardCopyWithImpl<$Res>
    implements _$LoginGiftRewardCopyWith<$Res> {
  __$LoginGiftRewardCopyWithImpl(this._self, this._then);

  final _LoginGiftReward _self;
  final $Res Function(_LoginGiftReward) _then;

/// Create a copy of LoginGiftReward
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coins = null,Object? hints = null,Object? slots = null,}) {
  return _then(_LoginGiftReward(
coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,hints: null == hints ? _self.hints : hints // ignore: cast_nullable_to_non_nullable
as int,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$LoginGiftGrant {

/// The local date it was claimed on.
 LocalDate get date;/// The track's day it paid, 1–7 (`LoginGiftRules.dayOf`).
 int get day;/// `LoginGiftProgress.claims` after this claim.
 int get claims; LoginGiftReward get reward;
/// Create a copy of LoginGiftGrant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginGiftGrantCopyWith<LoginGiftGrant> get copyWith => _$LoginGiftGrantCopyWithImpl<LoginGiftGrant>(this as LoginGiftGrant, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginGiftGrant&&(identical(other.date, date) || other.date == date)&&(identical(other.day, day) || other.day == day)&&(identical(other.claims, claims) || other.claims == claims)&&(identical(other.reward, reward) || other.reward == reward));
}


@override
int get hashCode => Object.hash(runtimeType,date,day,claims,reward);

@override
String toString() {
  return 'LoginGiftGrant(date: $date, day: $day, claims: $claims, reward: $reward)';
}


}

/// @nodoc
abstract mixin class $LoginGiftGrantCopyWith<$Res>  {
  factory $LoginGiftGrantCopyWith(LoginGiftGrant value, $Res Function(LoginGiftGrant) _then) = _$LoginGiftGrantCopyWithImpl;
@useResult
$Res call({
 LocalDate date, int day, int claims, LoginGiftReward reward
});


$LoginGiftRewardCopyWith<$Res> get reward;

}
/// @nodoc
class _$LoginGiftGrantCopyWithImpl<$Res>
    implements $LoginGiftGrantCopyWith<$Res> {
  _$LoginGiftGrantCopyWithImpl(this._self, this._then);

  final LoginGiftGrant _self;
  final $Res Function(LoginGiftGrant) _then;

/// Create a copy of LoginGiftGrant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? day = null,Object? claims = null,Object? reward = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,claims: null == claims ? _self.claims : claims // ignore: cast_nullable_to_non_nullable
as int,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as LoginGiftReward,
  ));
}
/// Create a copy of LoginGiftGrant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoginGiftRewardCopyWith<$Res> get reward {
  
  return $LoginGiftRewardCopyWith<$Res>(_self.reward, (value) {
    return _then(_self.copyWith(reward: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoginGiftGrant].
extension LoginGiftGrantPatterns on LoginGiftGrant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginGiftGrant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginGiftGrant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginGiftGrant value)  $default,){
final _that = this;
switch (_that) {
case _LoginGiftGrant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginGiftGrant value)?  $default,){
final _that = this;
switch (_that) {
case _LoginGiftGrant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate date,  int day,  int claims,  LoginGiftReward reward)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginGiftGrant() when $default != null:
return $default(_that.date,_that.day,_that.claims,_that.reward);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate date,  int day,  int claims,  LoginGiftReward reward)  $default,) {final _that = this;
switch (_that) {
case _LoginGiftGrant():
return $default(_that.date,_that.day,_that.claims,_that.reward);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate date,  int day,  int claims,  LoginGiftReward reward)?  $default,) {final _that = this;
switch (_that) {
case _LoginGiftGrant() when $default != null:
return $default(_that.date,_that.day,_that.claims,_that.reward);case _:
  return null;

}
}

}

/// @nodoc


class _LoginGiftGrant implements LoginGiftGrant {
  const _LoginGiftGrant({required this.date, required this.day, required this.claims, required this.reward});
  

/// The local date it was claimed on.
@override final  LocalDate date;
/// The track's day it paid, 1–7 (`LoginGiftRules.dayOf`).
@override final  int day;
/// `LoginGiftProgress.claims` after this claim.
@override final  int claims;
@override final  LoginGiftReward reward;

/// Create a copy of LoginGiftGrant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginGiftGrantCopyWith<_LoginGiftGrant> get copyWith => __$LoginGiftGrantCopyWithImpl<_LoginGiftGrant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginGiftGrant&&(identical(other.date, date) || other.date == date)&&(identical(other.day, day) || other.day == day)&&(identical(other.claims, claims) || other.claims == claims)&&(identical(other.reward, reward) || other.reward == reward));
}


@override
int get hashCode => Object.hash(runtimeType,date,day,claims,reward);

@override
String toString() {
  return 'LoginGiftGrant(date: $date, day: $day, claims: $claims, reward: $reward)';
}


}

/// @nodoc
abstract mixin class _$LoginGiftGrantCopyWith<$Res> implements $LoginGiftGrantCopyWith<$Res> {
  factory _$LoginGiftGrantCopyWith(_LoginGiftGrant value, $Res Function(_LoginGiftGrant) _then) = __$LoginGiftGrantCopyWithImpl;
@override @useResult
$Res call({
 LocalDate date, int day, int claims, LoginGiftReward reward
});


@override $LoginGiftRewardCopyWith<$Res> get reward;

}
/// @nodoc
class __$LoginGiftGrantCopyWithImpl<$Res>
    implements _$LoginGiftGrantCopyWith<$Res> {
  __$LoginGiftGrantCopyWithImpl(this._self, this._then);

  final _LoginGiftGrant _self;
  final $Res Function(_LoginGiftGrant) _then;

/// Create a copy of LoginGiftGrant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? day = null,Object? claims = null,Object? reward = null,}) {
  return _then(_LoginGiftGrant(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,claims: null == claims ? _self.claims : claims // ignore: cast_nullable_to_non_nullable
as int,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as LoginGiftReward,
  ));
}

/// Create a copy of LoginGiftGrant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoginGiftRewardCopyWith<$Res> get reward {
  
  return $LoginGiftRewardCopyWith<$Res>(_self.reward, (value) {
    return _then(_self.copyWith(reward: value));
  });
}
}

// dart format on
