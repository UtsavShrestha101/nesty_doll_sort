// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'splash_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SplashState implements DiagnosticableTreeMixin {

/// 0–1, the loader bar (`ui_splash_loader`'s frame = progress %).
 double get progress;/// Levels available offline after loading.
 int get levelCount;/// No level has been won yet (E9, spec-prop §10.1; docs/plans/
/// m7-design.md §13): the splash opens Level 1 (its tutorial, or the
/// board a kill left) instead of Home. The gameplay-bloc lane sets it
/// from the save and the splash page follows it.
 bool get opensFirstLevel;
/// Create a copy of SplashState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SplashStateCopyWith<SplashState> get copyWith => _$SplashStateCopyWithImpl<SplashState>(this as SplashState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SplashState'))
    ..add(DiagnosticsProperty('progress', progress))..add(DiagnosticsProperty('levelCount', levelCount))..add(DiagnosticsProperty('opensFirstLevel', opensFirstLevel));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SplashState&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.levelCount, levelCount) || other.levelCount == levelCount)&&(identical(other.opensFirstLevel, opensFirstLevel) || other.opensFirstLevel == opensFirstLevel));
}


@override
int get hashCode => Object.hash(runtimeType,progress,levelCount,opensFirstLevel);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SplashState(progress: $progress, levelCount: $levelCount, opensFirstLevel: $opensFirstLevel)';
}


}

/// @nodoc
abstract mixin class $SplashStateCopyWith<$Res>  {
  factory $SplashStateCopyWith(SplashState value, $Res Function(SplashState) _then) = _$SplashStateCopyWithImpl;
@useResult
$Res call({
 double progress, int levelCount, bool opensFirstLevel
});




}
/// @nodoc
class _$SplashStateCopyWithImpl<$Res>
    implements $SplashStateCopyWith<$Res> {
  _$SplashStateCopyWithImpl(this._self, this._then);

  final SplashState _self;
  final $Res Function(SplashState) _then;

/// Create a copy of SplashState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? progress = null,Object? levelCount = null,Object? opensFirstLevel = null,}) {
  return _then(_self.copyWith(
progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,levelCount: null == levelCount ? _self.levelCount : levelCount // ignore: cast_nullable_to_non_nullable
as int,opensFirstLevel: null == opensFirstLevel ? _self.opensFirstLevel : opensFirstLevel // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SplashState].
extension SplashStatePatterns on SplashState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SplashState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SplashState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SplashState value)  $default,){
final _that = this;
switch (_that) {
case _SplashState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SplashState value)?  $default,){
final _that = this;
switch (_that) {
case _SplashState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double progress,  int levelCount,  bool opensFirstLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SplashState() when $default != null:
return $default(_that.progress,_that.levelCount,_that.opensFirstLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double progress,  int levelCount,  bool opensFirstLevel)  $default,) {final _that = this;
switch (_that) {
case _SplashState():
return $default(_that.progress,_that.levelCount,_that.opensFirstLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double progress,  int levelCount,  bool opensFirstLevel)?  $default,) {final _that = this;
switch (_that) {
case _SplashState() when $default != null:
return $default(_that.progress,_that.levelCount,_that.opensFirstLevel);case _:
  return null;

}
}

}

/// @nodoc


class _SplashState with DiagnosticableTreeMixin implements SplashState {
  const _SplashState({this.progress = 0, this.levelCount = 0, this.opensFirstLevel = false});
  

/// 0–1, the loader bar (`ui_splash_loader`'s frame = progress %).
@override@JsonKey() final  double progress;
/// Levels available offline after loading.
@override@JsonKey() final  int levelCount;
/// No level has been won yet (E9, spec-prop §10.1; docs/plans/
/// m7-design.md §13): the splash opens Level 1 (its tutorial, or the
/// board a kill left) instead of Home. The gameplay-bloc lane sets it
/// from the save and the splash page follows it.
@override@JsonKey() final  bool opensFirstLevel;

/// Create a copy of SplashState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SplashStateCopyWith<_SplashState> get copyWith => __$SplashStateCopyWithImpl<_SplashState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SplashState'))
    ..add(DiagnosticsProperty('progress', progress))..add(DiagnosticsProperty('levelCount', levelCount))..add(DiagnosticsProperty('opensFirstLevel', opensFirstLevel));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SplashState&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.levelCount, levelCount) || other.levelCount == levelCount)&&(identical(other.opensFirstLevel, opensFirstLevel) || other.opensFirstLevel == opensFirstLevel));
}


@override
int get hashCode => Object.hash(runtimeType,progress,levelCount,opensFirstLevel);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SplashState(progress: $progress, levelCount: $levelCount, opensFirstLevel: $opensFirstLevel)';
}


}

/// @nodoc
abstract mixin class _$SplashStateCopyWith<$Res> implements $SplashStateCopyWith<$Res> {
  factory _$SplashStateCopyWith(_SplashState value, $Res Function(_SplashState) _then) = __$SplashStateCopyWithImpl;
@override @useResult
$Res call({
 double progress, int levelCount, bool opensFirstLevel
});




}
/// @nodoc
class __$SplashStateCopyWithImpl<$Res>
    implements _$SplashStateCopyWith<$Res> {
  __$SplashStateCopyWithImpl(this._self, this._then);

  final _SplashState _self;
  final $Res Function(_SplashState) _then;

/// Create a copy of SplashState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? progress = null,Object? levelCount = null,Object? opensFirstLevel = null,}) {
  return _then(_SplashState(
progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,levelCount: null == levelCount ? _self.levelCount : levelCount // ignore: cast_nullable_to_non_nullable
as int,opensFirstLevel: null == opensFirstLevel ? _self.opensFirstLevel : opensFirstLevel // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
