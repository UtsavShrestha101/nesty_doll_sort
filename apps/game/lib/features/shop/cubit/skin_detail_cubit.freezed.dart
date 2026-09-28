// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'skin_detail_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SkinDetailState {

 SkinInfo get skin; bool get owned; bool get equipped; int get coins;
/// Create a copy of SkinDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkinDetailStateCopyWith<SkinDetailState> get copyWith => _$SkinDetailStateCopyWithImpl<SkinDetailState>(this as SkinDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkinDetailState&&(identical(other.skin, skin) || other.skin == skin)&&(identical(other.owned, owned) || other.owned == owned)&&(identical(other.equipped, equipped) || other.equipped == equipped)&&(identical(other.coins, coins) || other.coins == coins));
}


@override
int get hashCode => Object.hash(runtimeType,skin,owned,equipped,coins);

@override
String toString() {
  return 'SkinDetailState(skin: $skin, owned: $owned, equipped: $equipped, coins: $coins)';
}


}

/// @nodoc
abstract mixin class $SkinDetailStateCopyWith<$Res>  {
  factory $SkinDetailStateCopyWith(SkinDetailState value, $Res Function(SkinDetailState) _then) = _$SkinDetailStateCopyWithImpl;
@useResult
$Res call({
 SkinInfo skin, bool owned, bool equipped, int coins
});


$SkinInfoCopyWith<$Res> get skin;

}
/// @nodoc
class _$SkinDetailStateCopyWithImpl<$Res>
    implements $SkinDetailStateCopyWith<$Res> {
  _$SkinDetailStateCopyWithImpl(this._self, this._then);

  final SkinDetailState _self;
  final $Res Function(SkinDetailState) _then;

/// Create a copy of SkinDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? skin = null,Object? owned = null,Object? equipped = null,Object? coins = null,}) {
  return _then(_self.copyWith(
skin: null == skin ? _self.skin : skin // ignore: cast_nullable_to_non_nullable
as SkinInfo,owned: null == owned ? _self.owned : owned // ignore: cast_nullable_to_non_nullable
as bool,equipped: null == equipped ? _self.equipped : equipped // ignore: cast_nullable_to_non_nullable
as bool,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SkinDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SkinInfoCopyWith<$Res> get skin {
  
  return $SkinInfoCopyWith<$Res>(_self.skin, (value) {
    return _then(_self.copyWith(skin: value));
  });
}
}


/// Adds pattern-matching-related methods to [SkinDetailState].
extension SkinDetailStatePatterns on SkinDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SkinDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SkinDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SkinDetailState value)  $default,){
final _that = this;
switch (_that) {
case _SkinDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SkinDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _SkinDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SkinInfo skin,  bool owned,  bool equipped,  int coins)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SkinDetailState() when $default != null:
return $default(_that.skin,_that.owned,_that.equipped,_that.coins);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SkinInfo skin,  bool owned,  bool equipped,  int coins)  $default,) {final _that = this;
switch (_that) {
case _SkinDetailState():
return $default(_that.skin,_that.owned,_that.equipped,_that.coins);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SkinInfo skin,  bool owned,  bool equipped,  int coins)?  $default,) {final _that = this;
switch (_that) {
case _SkinDetailState() when $default != null:
return $default(_that.skin,_that.owned,_that.equipped,_that.coins);case _:
  return null;

}
}

}

/// @nodoc


class _SkinDetailState implements SkinDetailState {
  const _SkinDetailState({required this.skin, required this.owned, required this.equipped, required this.coins});
  

@override final  SkinInfo skin;
@override final  bool owned;
@override final  bool equipped;
@override final  int coins;

/// Create a copy of SkinDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SkinDetailStateCopyWith<_SkinDetailState> get copyWith => __$SkinDetailStateCopyWithImpl<_SkinDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SkinDetailState&&(identical(other.skin, skin) || other.skin == skin)&&(identical(other.owned, owned) || other.owned == owned)&&(identical(other.equipped, equipped) || other.equipped == equipped)&&(identical(other.coins, coins) || other.coins == coins));
}


@override
int get hashCode => Object.hash(runtimeType,skin,owned,equipped,coins);

@override
String toString() {
  return 'SkinDetailState(skin: $skin, owned: $owned, equipped: $equipped, coins: $coins)';
}


}

/// @nodoc
abstract mixin class _$SkinDetailStateCopyWith<$Res> implements $SkinDetailStateCopyWith<$Res> {
  factory _$SkinDetailStateCopyWith(_SkinDetailState value, $Res Function(_SkinDetailState) _then) = __$SkinDetailStateCopyWithImpl;
@override @useResult
$Res call({
 SkinInfo skin, bool owned, bool equipped, int coins
});


@override $SkinInfoCopyWith<$Res> get skin;

}
/// @nodoc
class __$SkinDetailStateCopyWithImpl<$Res>
    implements _$SkinDetailStateCopyWith<$Res> {
  __$SkinDetailStateCopyWithImpl(this._self, this._then);

  final _SkinDetailState _self;
  final $Res Function(_SkinDetailState) _then;

/// Create a copy of SkinDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? skin = null,Object? owned = null,Object? equipped = null,Object? coins = null,}) {
  return _then(_SkinDetailState(
skin: null == skin ? _self.skin : skin // ignore: cast_nullable_to_non_nullable
as SkinInfo,owned: null == owned ? _self.owned : owned // ignore: cast_nullable_to_non_nullable
as bool,equipped: null == equipped ? _self.equipped : equipped // ignore: cast_nullable_to_non_nullable
as bool,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SkinDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SkinInfoCopyWith<$Res> get skin {
  
  return $SkinInfoCopyWith<$Res>(_self.skin, (value) {
    return _then(_self.copyWith(skin: value));
  });
}
}

// dart format on
