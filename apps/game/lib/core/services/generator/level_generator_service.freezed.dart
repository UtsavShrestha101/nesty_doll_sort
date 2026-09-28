// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'level_generator_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GeneratedLevel {

/// The board; its `seed` is the one that produced it (a retry seed
/// after a `GeneratorFailure`, m3-design §5).
 Level get level;/// The simulated tier (`simulation.tier`): a bonus level plays as it
/// (Q31).
 Tier get tier;/// False when no attempt hit the target tier (design A15).
 bool get tierMatched;/// Spec §6.4's "expert only" flag; nothing is shown for it (Q31).
 bool get expertOnly;
/// Create a copy of GeneratedLevel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratedLevelCopyWith<GeneratedLevel> get copyWith => _$GeneratedLevelCopyWithImpl<GeneratedLevel>(this as GeneratedLevel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratedLevel&&(identical(other.level, level) || other.level == level)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.tierMatched, tierMatched) || other.tierMatched == tierMatched)&&(identical(other.expertOnly, expertOnly) || other.expertOnly == expertOnly));
}


@override
int get hashCode => Object.hash(runtimeType,level,tier,tierMatched,expertOnly);

@override
String toString() {
  return 'GeneratedLevel(level: $level, tier: $tier, tierMatched: $tierMatched, expertOnly: $expertOnly)';
}


}

/// @nodoc
abstract mixin class $GeneratedLevelCopyWith<$Res>  {
  factory $GeneratedLevelCopyWith(GeneratedLevel value, $Res Function(GeneratedLevel) _then) = _$GeneratedLevelCopyWithImpl;
@useResult
$Res call({
 Level level, Tier tier, bool tierMatched, bool expertOnly
});




}
/// @nodoc
class _$GeneratedLevelCopyWithImpl<$Res>
    implements $GeneratedLevelCopyWith<$Res> {
  _$GeneratedLevelCopyWithImpl(this._self, this._then);

  final GeneratedLevel _self;
  final $Res Function(GeneratedLevel) _then;

/// Create a copy of GeneratedLevel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? tier = null,Object? tierMatched = null,Object? expertOnly = null,}) {
  return _then(_self.copyWith(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as Level,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,tierMatched: null == tierMatched ? _self.tierMatched : tierMatched // ignore: cast_nullable_to_non_nullable
as bool,expertOnly: null == expertOnly ? _self.expertOnly : expertOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneratedLevel].
extension GeneratedLevelPatterns on GeneratedLevel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneratedLevel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneratedLevel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneratedLevel value)  $default,){
final _that = this;
switch (_that) {
case _GeneratedLevel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneratedLevel value)?  $default,){
final _that = this;
switch (_that) {
case _GeneratedLevel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Level level,  Tier tier,  bool tierMatched,  bool expertOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratedLevel() when $default != null:
return $default(_that.level,_that.tier,_that.tierMatched,_that.expertOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Level level,  Tier tier,  bool tierMatched,  bool expertOnly)  $default,) {final _that = this;
switch (_that) {
case _GeneratedLevel():
return $default(_that.level,_that.tier,_that.tierMatched,_that.expertOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Level level,  Tier tier,  bool tierMatched,  bool expertOnly)?  $default,) {final _that = this;
switch (_that) {
case _GeneratedLevel() when $default != null:
return $default(_that.level,_that.tier,_that.tierMatched,_that.expertOnly);case _:
  return null;

}
}

}

/// @nodoc


class _GeneratedLevel implements GeneratedLevel {
  const _GeneratedLevel({required this.level, required this.tier, required this.tierMatched, required this.expertOnly});
  

/// The board; its `seed` is the one that produced it (a retry seed
/// after a `GeneratorFailure`, m3-design §5).
@override final  Level level;
/// The simulated tier (`simulation.tier`): a bonus level plays as it
/// (Q31).
@override final  Tier tier;
/// False when no attempt hit the target tier (design A15).
@override final  bool tierMatched;
/// Spec §6.4's "expert only" flag; nothing is shown for it (Q31).
@override final  bool expertOnly;

/// Create a copy of GeneratedLevel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratedLevelCopyWith<_GeneratedLevel> get copyWith => __$GeneratedLevelCopyWithImpl<_GeneratedLevel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratedLevel&&(identical(other.level, level) || other.level == level)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.tierMatched, tierMatched) || other.tierMatched == tierMatched)&&(identical(other.expertOnly, expertOnly) || other.expertOnly == expertOnly));
}


@override
int get hashCode => Object.hash(runtimeType,level,tier,tierMatched,expertOnly);

@override
String toString() {
  return 'GeneratedLevel(level: $level, tier: $tier, tierMatched: $tierMatched, expertOnly: $expertOnly)';
}


}

/// @nodoc
abstract mixin class _$GeneratedLevelCopyWith<$Res> implements $GeneratedLevelCopyWith<$Res> {
  factory _$GeneratedLevelCopyWith(_GeneratedLevel value, $Res Function(_GeneratedLevel) _then) = __$GeneratedLevelCopyWithImpl;
@override @useResult
$Res call({
 Level level, Tier tier, bool tierMatched, bool expertOnly
});




}
/// @nodoc
class __$GeneratedLevelCopyWithImpl<$Res>
    implements _$GeneratedLevelCopyWith<$Res> {
  __$GeneratedLevelCopyWithImpl(this._self, this._then);

  final _GeneratedLevel _self;
  final $Res Function(_GeneratedLevel) _then;

/// Create a copy of GeneratedLevel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? tier = null,Object? tierMatched = null,Object? expertOnly = null,}) {
  return _then(_GeneratedLevel(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as Level,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,tierMatched: null == tierMatched ? _self.tierMatched : tierMatched // ignore: cast_nullable_to_non_nullable
as bool,expertOnly: null == expertOnly ? _self.expertOnly : expertOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
