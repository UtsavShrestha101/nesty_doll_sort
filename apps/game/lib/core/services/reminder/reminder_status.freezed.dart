// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReminderStatus {

 ReminderSettings get settings; NotificationPermission get permission;/// The daily is unlocked (`DailyService.isUnlocked`, Level 2 won):
/// before that Settings hides the reminder rows (default, an owner
/// question).
 bool get available;
/// Create a copy of ReminderStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReminderStatusCopyWith<ReminderStatus> get copyWith => _$ReminderStatusCopyWithImpl<ReminderStatus>(this as ReminderStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReminderStatus&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.permission, permission) || other.permission == permission)&&(identical(other.available, available) || other.available == available));
}


@override
int get hashCode => Object.hash(runtimeType,settings,permission,available);

@override
String toString() {
  return 'ReminderStatus(settings: $settings, permission: $permission, available: $available)';
}


}

/// @nodoc
abstract mixin class $ReminderStatusCopyWith<$Res>  {
  factory $ReminderStatusCopyWith(ReminderStatus value, $Res Function(ReminderStatus) _then) = _$ReminderStatusCopyWithImpl;
@useResult
$Res call({
 ReminderSettings settings, NotificationPermission permission, bool available
});


$ReminderSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$ReminderStatusCopyWithImpl<$Res>
    implements $ReminderStatusCopyWith<$Res> {
  _$ReminderStatusCopyWithImpl(this._self, this._then);

  final ReminderStatus _self;
  final $Res Function(ReminderStatus) _then;

/// Create a copy of ReminderStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? settings = null,Object? permission = null,Object? available = null,}) {
  return _then(_self.copyWith(
settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as ReminderSettings,permission: null == permission ? _self.permission : permission // ignore: cast_nullable_to_non_nullable
as NotificationPermission,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ReminderStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReminderSettingsCopyWith<$Res> get settings {
  
  return $ReminderSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReminderStatus].
extension ReminderStatusPatterns on ReminderStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReminderStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReminderStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReminderStatus value)  $default,){
final _that = this;
switch (_that) {
case _ReminderStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReminderStatus value)?  $default,){
final _that = this;
switch (_that) {
case _ReminderStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReminderSettings settings,  NotificationPermission permission,  bool available)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReminderStatus() when $default != null:
return $default(_that.settings,_that.permission,_that.available);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReminderSettings settings,  NotificationPermission permission,  bool available)  $default,) {final _that = this;
switch (_that) {
case _ReminderStatus():
return $default(_that.settings,_that.permission,_that.available);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReminderSettings settings,  NotificationPermission permission,  bool available)?  $default,) {final _that = this;
switch (_that) {
case _ReminderStatus() when $default != null:
return $default(_that.settings,_that.permission,_that.available);case _:
  return null;

}
}

}

/// @nodoc


class _ReminderStatus extends ReminderStatus {
  const _ReminderStatus({this.settings = const ReminderSettings(), this.permission = NotificationPermission.unknown, this.available = false}): super._();
  

@override@JsonKey() final  ReminderSettings settings;
@override@JsonKey() final  NotificationPermission permission;
/// The daily is unlocked (`DailyService.isUnlocked`, Level 2 won):
/// before that Settings hides the reminder rows (default, an owner
/// question).
@override@JsonKey() final  bool available;

/// Create a copy of ReminderStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReminderStatusCopyWith<_ReminderStatus> get copyWith => __$ReminderStatusCopyWithImpl<_ReminderStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReminderStatus&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.permission, permission) || other.permission == permission)&&(identical(other.available, available) || other.available == available));
}


@override
int get hashCode => Object.hash(runtimeType,settings,permission,available);

@override
String toString() {
  return 'ReminderStatus(settings: $settings, permission: $permission, available: $available)';
}


}

/// @nodoc
abstract mixin class _$ReminderStatusCopyWith<$Res> implements $ReminderStatusCopyWith<$Res> {
  factory _$ReminderStatusCopyWith(_ReminderStatus value, $Res Function(_ReminderStatus) _then) = __$ReminderStatusCopyWithImpl;
@override @useResult
$Res call({
 ReminderSettings settings, NotificationPermission permission, bool available
});


@override $ReminderSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class __$ReminderStatusCopyWithImpl<$Res>
    implements _$ReminderStatusCopyWith<$Res> {
  __$ReminderStatusCopyWithImpl(this._self, this._then);

  final _ReminderStatus _self;
  final $Res Function(_ReminderStatus) _then;

/// Create a copy of ReminderStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? settings = null,Object? permission = null,Object? available = null,}) {
  return _then(_ReminderStatus(
settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as ReminderSettings,permission: null == permission ? _self.permission : permission // ignore: cast_nullable_to_non_nullable
as NotificationPermission,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ReminderStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReminderSettingsCopyWith<$Res> get settings {
  
  return $ReminderSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}

// dart format on
