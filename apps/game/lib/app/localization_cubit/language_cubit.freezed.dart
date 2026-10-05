// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'language_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LanguageState {

/// The language setting as persisted: [LocaleSetting.system] (follow
/// the phone; the default) or the code a sheet tap pinned.
 String get storedLanguageCode;/// The language the app renders in: [storedLanguageCode] resolved by
/// [AppLocaleResolver] against the phone's languages and the catalogs
/// present. Always a supported storage-style code (`en`, `pt_BR`).
 String get currentLanguageCode;/// The locale highlighted in a language picker before it's confirmed.
 String get selectedLanguageCode; bool get isLoading;/// The last [LanguageCubit.changeLanguage] failed to persist. The UI maps
/// this to an ARB string — the state carries no user-facing text.
 bool get hasError;
/// Create a copy of LanguageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LanguageStateCopyWith<LanguageState> get copyWith => _$LanguageStateCopyWithImpl<LanguageState>(this as LanguageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LanguageState&&(identical(other.storedLanguageCode, storedLanguageCode) || other.storedLanguageCode == storedLanguageCode)&&(identical(other.currentLanguageCode, currentLanguageCode) || other.currentLanguageCode == currentLanguageCode)&&(identical(other.selectedLanguageCode, selectedLanguageCode) || other.selectedLanguageCode == selectedLanguageCode)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasError, hasError) || other.hasError == hasError));
}


@override
int get hashCode => Object.hash(runtimeType,storedLanguageCode,currentLanguageCode,selectedLanguageCode,isLoading,hasError);

@override
String toString() {
  return 'LanguageState(storedLanguageCode: $storedLanguageCode, currentLanguageCode: $currentLanguageCode, selectedLanguageCode: $selectedLanguageCode, isLoading: $isLoading, hasError: $hasError)';
}


}

/// @nodoc
abstract mixin class $LanguageStateCopyWith<$Res>  {
  factory $LanguageStateCopyWith(LanguageState value, $Res Function(LanguageState) _then) = _$LanguageStateCopyWithImpl;
@useResult
$Res call({
 String storedLanguageCode, String currentLanguageCode, String selectedLanguageCode, bool isLoading, bool hasError
});




}
/// @nodoc
class _$LanguageStateCopyWithImpl<$Res>
    implements $LanguageStateCopyWith<$Res> {
  _$LanguageStateCopyWithImpl(this._self, this._then);

  final LanguageState _self;
  final $Res Function(LanguageState) _then;

/// Create a copy of LanguageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? storedLanguageCode = null,Object? currentLanguageCode = null,Object? selectedLanguageCode = null,Object? isLoading = null,Object? hasError = null,}) {
  return _then(_self.copyWith(
storedLanguageCode: null == storedLanguageCode ? _self.storedLanguageCode : storedLanguageCode // ignore: cast_nullable_to_non_nullable
as String,currentLanguageCode: null == currentLanguageCode ? _self.currentLanguageCode : currentLanguageCode // ignore: cast_nullable_to_non_nullable
as String,selectedLanguageCode: null == selectedLanguageCode ? _self.selectedLanguageCode : selectedLanguageCode // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LanguageState].
extension LanguageStatePatterns on LanguageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LanguageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LanguageState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LanguageState value)  $default,){
final _that = this;
switch (_that) {
case _LanguageState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LanguageState value)?  $default,){
final _that = this;
switch (_that) {
case _LanguageState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String storedLanguageCode,  String currentLanguageCode,  String selectedLanguageCode,  bool isLoading,  bool hasError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LanguageState() when $default != null:
return $default(_that.storedLanguageCode,_that.currentLanguageCode,_that.selectedLanguageCode,_that.isLoading,_that.hasError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String storedLanguageCode,  String currentLanguageCode,  String selectedLanguageCode,  bool isLoading,  bool hasError)  $default,) {final _that = this;
switch (_that) {
case _LanguageState():
return $default(_that.storedLanguageCode,_that.currentLanguageCode,_that.selectedLanguageCode,_that.isLoading,_that.hasError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String storedLanguageCode,  String currentLanguageCode,  String selectedLanguageCode,  bool isLoading,  bool hasError)?  $default,) {final _that = this;
switch (_that) {
case _LanguageState() when $default != null:
return $default(_that.storedLanguageCode,_that.currentLanguageCode,_that.selectedLanguageCode,_that.isLoading,_that.hasError);case _:
  return null;

}
}

}

/// @nodoc


class _LanguageState extends LanguageState {
  const _LanguageState({this.storedLanguageCode = SettingsDefaults.locale, this.currentLanguageCode = AppLocaleResolver.fallbackCode, this.selectedLanguageCode = AppLocaleResolver.fallbackCode, this.isLoading = false, this.hasError = false}): super._();
  

/// The language setting as persisted: [LocaleSetting.system] (follow
/// the phone; the default) or the code a sheet tap pinned.
@override@JsonKey() final  String storedLanguageCode;
/// The language the app renders in: [storedLanguageCode] resolved by
/// [AppLocaleResolver] against the phone's languages and the catalogs
/// present. Always a supported storage-style code (`en`, `pt_BR`).
@override@JsonKey() final  String currentLanguageCode;
/// The locale highlighted in a language picker before it's confirmed.
@override@JsonKey() final  String selectedLanguageCode;
@override@JsonKey() final  bool isLoading;
/// The last [LanguageCubit.changeLanguage] failed to persist. The UI maps
/// this to an ARB string — the state carries no user-facing text.
@override@JsonKey() final  bool hasError;

/// Create a copy of LanguageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LanguageStateCopyWith<_LanguageState> get copyWith => __$LanguageStateCopyWithImpl<_LanguageState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LanguageState&&(identical(other.storedLanguageCode, storedLanguageCode) || other.storedLanguageCode == storedLanguageCode)&&(identical(other.currentLanguageCode, currentLanguageCode) || other.currentLanguageCode == currentLanguageCode)&&(identical(other.selectedLanguageCode, selectedLanguageCode) || other.selectedLanguageCode == selectedLanguageCode)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasError, hasError) || other.hasError == hasError));
}


@override
int get hashCode => Object.hash(runtimeType,storedLanguageCode,currentLanguageCode,selectedLanguageCode,isLoading,hasError);

@override
String toString() {
  return 'LanguageState(storedLanguageCode: $storedLanguageCode, currentLanguageCode: $currentLanguageCode, selectedLanguageCode: $selectedLanguageCode, isLoading: $isLoading, hasError: $hasError)';
}


}

/// @nodoc
abstract mixin class _$LanguageStateCopyWith<$Res> implements $LanguageStateCopyWith<$Res> {
  factory _$LanguageStateCopyWith(_LanguageState value, $Res Function(_LanguageState) _then) = __$LanguageStateCopyWithImpl;
@override @useResult
$Res call({
 String storedLanguageCode, String currentLanguageCode, String selectedLanguageCode, bool isLoading, bool hasError
});




}
/// @nodoc
class __$LanguageStateCopyWithImpl<$Res>
    implements _$LanguageStateCopyWith<$Res> {
  __$LanguageStateCopyWithImpl(this._self, this._then);

  final _LanguageState _self;
  final $Res Function(_LanguageState) _then;

/// Create a copy of LanguageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? storedLanguageCode = null,Object? currentLanguageCode = null,Object? selectedLanguageCode = null,Object? isLoading = null,Object? hasError = null,}) {
  return _then(_LanguageState(
storedLanguageCode: null == storedLanguageCode ? _self.storedLanguageCode : storedLanguageCode // ignore: cast_nullable_to_non_nullable
as String,currentLanguageCode: null == currentLanguageCode ? _self.currentLanguageCode : currentLanguageCode // ignore: cast_nullable_to_non_nullable
as String,selectedLanguageCode: null == selectedLanguageCode ? _self.selectedLanguageCode : selectedLanguageCode // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
