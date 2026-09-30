// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder_offer_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReminderOfferState {

 ReminderOfferStep get step;/// The time the chip shows: the solve's hour, minute 0 (Q81), until the
/// player changes it.
 int get hour; int get minute;
/// Create a copy of ReminderOfferState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReminderOfferStateCopyWith<ReminderOfferState> get copyWith => _$ReminderOfferStateCopyWithImpl<ReminderOfferState>(this as ReminderOfferState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReminderOfferState&&(identical(other.step, step) || other.step == step)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.minute, minute) || other.minute == minute));
}


@override
int get hashCode => Object.hash(runtimeType,step,hour,minute);

@override
String toString() {
  return 'ReminderOfferState(step: $step, hour: $hour, minute: $minute)';
}


}

/// @nodoc
abstract mixin class $ReminderOfferStateCopyWith<$Res>  {
  factory $ReminderOfferStateCopyWith(ReminderOfferState value, $Res Function(ReminderOfferState) _then) = _$ReminderOfferStateCopyWithImpl;
@useResult
$Res call({
 ReminderOfferStep step, int hour, int minute
});




}
/// @nodoc
class _$ReminderOfferStateCopyWithImpl<$Res>
    implements $ReminderOfferStateCopyWith<$Res> {
  _$ReminderOfferStateCopyWithImpl(this._self, this._then);

  final ReminderOfferState _self;
  final $Res Function(ReminderOfferState) _then;

/// Create a copy of ReminderOfferState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? hour = null,Object? minute = null,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as ReminderOfferStep,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReminderOfferState].
extension ReminderOfferStatePatterns on ReminderOfferState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReminderOfferState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReminderOfferState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReminderOfferState value)  $default,){
final _that = this;
switch (_that) {
case _ReminderOfferState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReminderOfferState value)?  $default,){
final _that = this;
switch (_that) {
case _ReminderOfferState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReminderOfferStep step,  int hour,  int minute)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReminderOfferState() when $default != null:
return $default(_that.step,_that.hour,_that.minute);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReminderOfferStep step,  int hour,  int minute)  $default,) {final _that = this;
switch (_that) {
case _ReminderOfferState():
return $default(_that.step,_that.hour,_that.minute);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReminderOfferStep step,  int hour,  int minute)?  $default,) {final _that = this;
switch (_that) {
case _ReminderOfferState() when $default != null:
return $default(_that.step,_that.hour,_that.minute);case _:
  return null;

}
}

}

/// @nodoc


class _ReminderOfferState implements ReminderOfferState {
  const _ReminderOfferState({this.step = ReminderOfferStep.hidden, this.hour = ReminderSettings.defaultHour, this.minute = ReminderSettings.defaultMinute});
  

@override@JsonKey() final  ReminderOfferStep step;
/// The time the chip shows: the solve's hour, minute 0 (Q81), until the
/// player changes it.
@override@JsonKey() final  int hour;
@override@JsonKey() final  int minute;

/// Create a copy of ReminderOfferState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReminderOfferStateCopyWith<_ReminderOfferState> get copyWith => __$ReminderOfferStateCopyWithImpl<_ReminderOfferState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReminderOfferState&&(identical(other.step, step) || other.step == step)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.minute, minute) || other.minute == minute));
}


@override
int get hashCode => Object.hash(runtimeType,step,hour,minute);

@override
String toString() {
  return 'ReminderOfferState(step: $step, hour: $hour, minute: $minute)';
}


}

/// @nodoc
abstract mixin class _$ReminderOfferStateCopyWith<$Res> implements $ReminderOfferStateCopyWith<$Res> {
  factory _$ReminderOfferStateCopyWith(_ReminderOfferState value, $Res Function(_ReminderOfferState) _then) = __$ReminderOfferStateCopyWithImpl;
@override @useResult
$Res call({
 ReminderOfferStep step, int hour, int minute
});




}
/// @nodoc
class __$ReminderOfferStateCopyWithImpl<$Res>
    implements _$ReminderOfferStateCopyWith<$Res> {
  __$ReminderOfferStateCopyWithImpl(this._self, this._then);

  final _ReminderOfferState _self;
  final $Res Function(_ReminderOfferState) _then;

/// Create a copy of ReminderOfferState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? hour = null,Object? minute = null,}) {
  return _then(_ReminderOfferState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as ReminderOfferStep,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
