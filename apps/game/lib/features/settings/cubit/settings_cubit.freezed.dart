// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

 bool get soundEnabled; bool get musicEnabled; bool get hapticsEnabled; SymbolsMode get symbolsMode;/// Relaxed mode (E6; docs/plans/m7-design.md §10, §15.5).
 bool get relaxedMode;/// The reduce-motion override (E14; m7-design §14, §15.5).
 ReduceMotionMode get reduceMotion;/// `AppInfoService.load()`'s version and build (the footer).
 String get version; String get buildNumber;/// `SaveService.playerId` (the footer).
 String get playerId;/// The opt-in daily reminder (E4; spec-prop §7.9; m7-design P3.10):
/// hidden until `reminder.available` (the daily is unlocked, Q139).
 ReminderStatus get reminder;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.musicEnabled, musicEnabled) || other.musicEnabled == musicEnabled)&&(identical(other.hapticsEnabled, hapticsEnabled) || other.hapticsEnabled == hapticsEnabled)&&(identical(other.symbolsMode, symbolsMode) || other.symbolsMode == symbolsMode)&&(identical(other.relaxedMode, relaxedMode) || other.relaxedMode == relaxedMode)&&(identical(other.reduceMotion, reduceMotion) || other.reduceMotion == reduceMotion)&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.reminder, reminder) || other.reminder == reminder));
}


@override
int get hashCode => Object.hash(runtimeType,soundEnabled,musicEnabled,hapticsEnabled,symbolsMode,relaxedMode,reduceMotion,version,buildNumber,playerId,reminder);

@override
String toString() {
  return 'SettingsState(soundEnabled: $soundEnabled, musicEnabled: $musicEnabled, hapticsEnabled: $hapticsEnabled, symbolsMode: $symbolsMode, relaxedMode: $relaxedMode, reduceMotion: $reduceMotion, version: $version, buildNumber: $buildNumber, playerId: $playerId, reminder: $reminder)';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 bool soundEnabled, bool musicEnabled, bool hapticsEnabled, SymbolsMode symbolsMode, bool relaxedMode, ReduceMotionMode reduceMotion, String version, String buildNumber, String playerId, ReminderStatus reminder
});


$ReminderStatusCopyWith<$Res> get reminder;

}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? soundEnabled = null,Object? musicEnabled = null,Object? hapticsEnabled = null,Object? symbolsMode = null,Object? relaxedMode = null,Object? reduceMotion = null,Object? version = null,Object? buildNumber = null,Object? playerId = null,Object? reminder = null,}) {
  return _then(_self.copyWith(
soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,musicEnabled: null == musicEnabled ? _self.musicEnabled : musicEnabled // ignore: cast_nullable_to_non_nullable
as bool,hapticsEnabled: null == hapticsEnabled ? _self.hapticsEnabled : hapticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,symbolsMode: null == symbolsMode ? _self.symbolsMode : symbolsMode // ignore: cast_nullable_to_non_nullable
as SymbolsMode,relaxedMode: null == relaxedMode ? _self.relaxedMode : relaxedMode // ignore: cast_nullable_to_non_nullable
as bool,reduceMotion: null == reduceMotion ? _self.reduceMotion : reduceMotion // ignore: cast_nullable_to_non_nullable
as ReduceMotionMode,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,reminder: null == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as ReminderStatus,
  ));
}
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReminderStatusCopyWith<$Res> get reminder {
  
  return $ReminderStatusCopyWith<$Res>(_self.reminder, (value) {
    return _then(_self.copyWith(reminder: value));
  });
}
}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool soundEnabled,  bool musicEnabled,  bool hapticsEnabled,  SymbolsMode symbolsMode,  bool relaxedMode,  ReduceMotionMode reduceMotion,  String version,  String buildNumber,  String playerId,  ReminderStatus reminder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.soundEnabled,_that.musicEnabled,_that.hapticsEnabled,_that.symbolsMode,_that.relaxedMode,_that.reduceMotion,_that.version,_that.buildNumber,_that.playerId,_that.reminder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool soundEnabled,  bool musicEnabled,  bool hapticsEnabled,  SymbolsMode symbolsMode,  bool relaxedMode,  ReduceMotionMode reduceMotion,  String version,  String buildNumber,  String playerId,  ReminderStatus reminder)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.soundEnabled,_that.musicEnabled,_that.hapticsEnabled,_that.symbolsMode,_that.relaxedMode,_that.reduceMotion,_that.version,_that.buildNumber,_that.playerId,_that.reminder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool soundEnabled,  bool musicEnabled,  bool hapticsEnabled,  SymbolsMode symbolsMode,  bool relaxedMode,  ReduceMotionMode reduceMotion,  String version,  String buildNumber,  String playerId,  ReminderStatus reminder)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.soundEnabled,_that.musicEnabled,_that.hapticsEnabled,_that.symbolsMode,_that.relaxedMode,_that.reduceMotion,_that.version,_that.buildNumber,_that.playerId,_that.reminder);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState implements SettingsState {
  const _SettingsState({this.soundEnabled = true, this.musicEnabled = true, this.hapticsEnabled = true, this.symbolsMode = SettingsDefaults.symbols, this.relaxedMode = SettingsDefaults.relaxed, this.reduceMotion = SettingsDefaults.reduceMotion, this.version = '', this.buildNumber = '', this.playerId = '', this.reminder = const ReminderStatus()});
  

@override@JsonKey() final  bool soundEnabled;
@override@JsonKey() final  bool musicEnabled;
@override@JsonKey() final  bool hapticsEnabled;
@override@JsonKey() final  SymbolsMode symbolsMode;
/// Relaxed mode (E6; docs/plans/m7-design.md §10, §15.5).
@override@JsonKey() final  bool relaxedMode;
/// The reduce-motion override (E14; m7-design §14, §15.5).
@override@JsonKey() final  ReduceMotionMode reduceMotion;
/// `AppInfoService.load()`'s version and build (the footer).
@override@JsonKey() final  String version;
@override@JsonKey() final  String buildNumber;
/// `SaveService.playerId` (the footer).
@override@JsonKey() final  String playerId;
/// The opt-in daily reminder (E4; spec-prop §7.9; m7-design P3.10):
/// hidden until `reminder.available` (the daily is unlocked, Q139).
@override@JsonKey() final  ReminderStatus reminder;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.musicEnabled, musicEnabled) || other.musicEnabled == musicEnabled)&&(identical(other.hapticsEnabled, hapticsEnabled) || other.hapticsEnabled == hapticsEnabled)&&(identical(other.symbolsMode, symbolsMode) || other.symbolsMode == symbolsMode)&&(identical(other.relaxedMode, relaxedMode) || other.relaxedMode == relaxedMode)&&(identical(other.reduceMotion, reduceMotion) || other.reduceMotion == reduceMotion)&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.reminder, reminder) || other.reminder == reminder));
}


@override
int get hashCode => Object.hash(runtimeType,soundEnabled,musicEnabled,hapticsEnabled,symbolsMode,relaxedMode,reduceMotion,version,buildNumber,playerId,reminder);

@override
String toString() {
  return 'SettingsState(soundEnabled: $soundEnabled, musicEnabled: $musicEnabled, hapticsEnabled: $hapticsEnabled, symbolsMode: $symbolsMode, relaxedMode: $relaxedMode, reduceMotion: $reduceMotion, version: $version, buildNumber: $buildNumber, playerId: $playerId, reminder: $reminder)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 bool soundEnabled, bool musicEnabled, bool hapticsEnabled, SymbolsMode symbolsMode, bool relaxedMode, ReduceMotionMode reduceMotion, String version, String buildNumber, String playerId, ReminderStatus reminder
});


@override $ReminderStatusCopyWith<$Res> get reminder;

}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? soundEnabled = null,Object? musicEnabled = null,Object? hapticsEnabled = null,Object? symbolsMode = null,Object? relaxedMode = null,Object? reduceMotion = null,Object? version = null,Object? buildNumber = null,Object? playerId = null,Object? reminder = null,}) {
  return _then(_SettingsState(
soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,musicEnabled: null == musicEnabled ? _self.musicEnabled : musicEnabled // ignore: cast_nullable_to_non_nullable
as bool,hapticsEnabled: null == hapticsEnabled ? _self.hapticsEnabled : hapticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,symbolsMode: null == symbolsMode ? _self.symbolsMode : symbolsMode // ignore: cast_nullable_to_non_nullable
as SymbolsMode,relaxedMode: null == relaxedMode ? _self.relaxedMode : relaxedMode // ignore: cast_nullable_to_non_nullable
as bool,reduceMotion: null == reduceMotion ? _self.reduceMotion : reduceMotion // ignore: cast_nullable_to_non_nullable
as ReduceMotionMode,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,reminder: null == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as ReminderStatus,
  ));
}

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReminderStatusCopyWith<$Res> get reminder {
  
  return $ReminderStatusCopyWith<$Res>(_self.reminder, (value) {
    return _then(_self.copyWith(reminder: value));
  });
}
}

// dart format on
