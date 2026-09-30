// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReminderPlan {

/// The local time of day it fires, every day (0–23, 0–59).
 int get hour; int get minute;/// `reminderNotificationTitle`: "Today's puzzle is ready" (spec-prop
/// §7.9's words). The same warm text every day; it never names the
/// streak.
 String get title;/// `reminderNotificationBody`.
 String get body;/// Android's notification channel, as the system settings list it
/// (`reminderChannelName`, `reminderChannelDescription`).
 String get channelName; String get channelDescription;
/// Create a copy of ReminderPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReminderPlanCopyWith<ReminderPlan> get copyWith => _$ReminderPlanCopyWithImpl<ReminderPlan>(this as ReminderPlan, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReminderPlan&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.channelDescription, channelDescription) || other.channelDescription == channelDescription));
}


@override
int get hashCode => Object.hash(runtimeType,hour,minute,title,body,channelName,channelDescription);

@override
String toString() {
  return 'ReminderPlan(hour: $hour, minute: $minute, title: $title, body: $body, channelName: $channelName, channelDescription: $channelDescription)';
}


}

/// @nodoc
abstract mixin class $ReminderPlanCopyWith<$Res>  {
  factory $ReminderPlanCopyWith(ReminderPlan value, $Res Function(ReminderPlan) _then) = _$ReminderPlanCopyWithImpl;
@useResult
$Res call({
 int hour, int minute, String title, String body, String channelName, String channelDescription
});




}
/// @nodoc
class _$ReminderPlanCopyWithImpl<$Res>
    implements $ReminderPlanCopyWith<$Res> {
  _$ReminderPlanCopyWithImpl(this._self, this._then);

  final ReminderPlan _self;
  final $Res Function(ReminderPlan) _then;

/// Create a copy of ReminderPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hour = null,Object? minute = null,Object? title = null,Object? body = null,Object? channelName = null,Object? channelDescription = null,}) {
  return _then(_self.copyWith(
hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,channelDescription: null == channelDescription ? _self.channelDescription : channelDescription // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReminderPlan].
extension ReminderPlanPatterns on ReminderPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReminderPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReminderPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReminderPlan value)  $default,){
final _that = this;
switch (_that) {
case _ReminderPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReminderPlan value)?  $default,){
final _that = this;
switch (_that) {
case _ReminderPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int hour,  int minute,  String title,  String body,  String channelName,  String channelDescription)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReminderPlan() when $default != null:
return $default(_that.hour,_that.minute,_that.title,_that.body,_that.channelName,_that.channelDescription);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int hour,  int minute,  String title,  String body,  String channelName,  String channelDescription)  $default,) {final _that = this;
switch (_that) {
case _ReminderPlan():
return $default(_that.hour,_that.minute,_that.title,_that.body,_that.channelName,_that.channelDescription);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int hour,  int minute,  String title,  String body,  String channelName,  String channelDescription)?  $default,) {final _that = this;
switch (_that) {
case _ReminderPlan() when $default != null:
return $default(_that.hour,_that.minute,_that.title,_that.body,_that.channelName,_that.channelDescription);case _:
  return null;

}
}

}

/// @nodoc


class _ReminderPlan implements ReminderPlan {
  const _ReminderPlan({required this.hour, required this.minute, required this.title, required this.body, required this.channelName, required this.channelDescription});
  

/// The local time of day it fires, every day (0–23, 0–59).
@override final  int hour;
@override final  int minute;
/// `reminderNotificationTitle`: "Today's puzzle is ready" (spec-prop
/// §7.9's words). The same warm text every day; it never names the
/// streak.
@override final  String title;
/// `reminderNotificationBody`.
@override final  String body;
/// Android's notification channel, as the system settings list it
/// (`reminderChannelName`, `reminderChannelDescription`).
@override final  String channelName;
@override final  String channelDescription;

/// Create a copy of ReminderPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReminderPlanCopyWith<_ReminderPlan> get copyWith => __$ReminderPlanCopyWithImpl<_ReminderPlan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReminderPlan&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.channelDescription, channelDescription) || other.channelDescription == channelDescription));
}


@override
int get hashCode => Object.hash(runtimeType,hour,minute,title,body,channelName,channelDescription);

@override
String toString() {
  return 'ReminderPlan(hour: $hour, minute: $minute, title: $title, body: $body, channelName: $channelName, channelDescription: $channelDescription)';
}


}

/// @nodoc
abstract mixin class _$ReminderPlanCopyWith<$Res> implements $ReminderPlanCopyWith<$Res> {
  factory _$ReminderPlanCopyWith(_ReminderPlan value, $Res Function(_ReminderPlan) _then) = __$ReminderPlanCopyWithImpl;
@override @useResult
$Res call({
 int hour, int minute, String title, String body, String channelName, String channelDescription
});




}
/// @nodoc
class __$ReminderPlanCopyWithImpl<$Res>
    implements _$ReminderPlanCopyWith<$Res> {
  __$ReminderPlanCopyWithImpl(this._self, this._then);

  final _ReminderPlan _self;
  final $Res Function(_ReminderPlan) _then;

/// Create a copy of ReminderPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hour = null,Object? minute = null,Object? title = null,Object? body = null,Object? channelName = null,Object? channelDescription = null,}) {
  return _then(_ReminderPlan(
hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,channelDescription: null == channelDescription ? _self.channelDescription : channelDescription // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
