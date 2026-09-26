// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_async_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AsyncValue<T> {

 T? get data;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncValue<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'AsyncValue<$T>(data: $data)';
}


}

/// @nodoc
class $AsyncValueCopyWith<T,$Res>  {
$AsyncValueCopyWith(AsyncValue<T> _, $Res Function(AsyncValue<T>) __);
}


/// Adds pattern-matching-related methods to [AsyncValue].
extension AsyncValuePatterns<T> on AsyncValue<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AsyncValueInitial<T> value)?  initial,TResult Function( AsyncValueLoading<T> value)?  loading,TResult Function( AsyncValueData<T> value)?  data,TResult Function( AsyncValueError<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AsyncValueInitial() when initial != null:
return initial(_that);case AsyncValueLoading() when loading != null:
return loading(_that);case AsyncValueData() when data != null:
return data(_that);case AsyncValueError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AsyncValueInitial<T> value)  initial,required TResult Function( AsyncValueLoading<T> value)  loading,required TResult Function( AsyncValueData<T> value)  data,required TResult Function( AsyncValueError<T> value)  error,}){
final _that = this;
switch (_that) {
case AsyncValueInitial():
return initial(_that);case AsyncValueLoading():
return loading(_that);case AsyncValueData():
return data(_that);case AsyncValueError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AsyncValueInitial<T> value)?  initial,TResult? Function( AsyncValueLoading<T> value)?  loading,TResult? Function( AsyncValueData<T> value)?  data,TResult? Function( AsyncValueError<T> value)?  error,}){
final _that = this;
switch (_that) {
case AsyncValueInitial() when initial != null:
return initial(_that);case AsyncValueLoading() when loading != null:
return loading(_that);case AsyncValueData() when data != null:
return data(_that);case AsyncValueError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( T? data)?  initial,TResult Function( T? data)?  loading,TResult Function( T data)?  data,TResult Function( AppException exception,  T? data)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AsyncValueInitial() when initial != null:
return initial(_that.data);case AsyncValueLoading() when loading != null:
return loading(_that.data);case AsyncValueData() when data != null:
return data(_that.data);case AsyncValueError() when error != null:
return error(_that.exception,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( T? data)  initial,required TResult Function( T? data)  loading,required TResult Function( T data)  data,required TResult Function( AppException exception,  T? data)  error,}) {final _that = this;
switch (_that) {
case AsyncValueInitial():
return initial(_that.data);case AsyncValueLoading():
return loading(_that.data);case AsyncValueData():
return data(_that.data);case AsyncValueError():
return error(_that.exception,_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( T? data)?  initial,TResult? Function( T? data)?  loading,TResult? Function( T data)?  data,TResult? Function( AppException exception,  T? data)?  error,}) {final _that = this;
switch (_that) {
case AsyncValueInitial() when initial != null:
return initial(_that.data);case AsyncValueLoading() when loading != null:
return loading(_that.data);case AsyncValueData() when data != null:
return data(_that.data);case AsyncValueError() when error != null:
return error(_that.exception,_that.data);case _:
  return null;

}
}

}

/// @nodoc


class AsyncValueInitial<T> implements AsyncValue<T> {
  const AsyncValueInitial({this.data});
  

@override final  T? data;

/// Create a copy of AsyncValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsyncValueInitialCopyWith<T, AsyncValueInitial<T>> get copyWith => _$AsyncValueInitialCopyWithImpl<T, AsyncValueInitial<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncValueInitial<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'AsyncValue<$T>.initial(data: $data)';
}


}

/// @nodoc
abstract mixin class $AsyncValueInitialCopyWith<T,$Res> implements $AsyncValueCopyWith<T, $Res> {
  factory $AsyncValueInitialCopyWith(AsyncValueInitial<T> value, $Res Function(AsyncValueInitial<T>) _then) = _$AsyncValueInitialCopyWithImpl;
@useResult
$Res call({
 T? data
});




}
/// @nodoc
class _$AsyncValueInitialCopyWithImpl<T,$Res>
    implements $AsyncValueInitialCopyWith<T, $Res> {
  _$AsyncValueInitialCopyWithImpl(this._self, this._then);

  final AsyncValueInitial<T> _self;
  final $Res Function(AsyncValueInitial<T>) _then;

/// Create a copy of AsyncValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(AsyncValueInitial<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}


}

/// @nodoc


class AsyncValueLoading<T> implements AsyncValue<T> {
  const AsyncValueLoading({this.data});
  

@override final  T? data;

/// Create a copy of AsyncValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsyncValueLoadingCopyWith<T, AsyncValueLoading<T>> get copyWith => _$AsyncValueLoadingCopyWithImpl<T, AsyncValueLoading<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncValueLoading<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'AsyncValue<$T>.loading(data: $data)';
}


}

/// @nodoc
abstract mixin class $AsyncValueLoadingCopyWith<T,$Res> implements $AsyncValueCopyWith<T, $Res> {
  factory $AsyncValueLoadingCopyWith(AsyncValueLoading<T> value, $Res Function(AsyncValueLoading<T>) _then) = _$AsyncValueLoadingCopyWithImpl;
@useResult
$Res call({
 T? data
});




}
/// @nodoc
class _$AsyncValueLoadingCopyWithImpl<T,$Res>
    implements $AsyncValueLoadingCopyWith<T, $Res> {
  _$AsyncValueLoadingCopyWithImpl(this._self, this._then);

  final AsyncValueLoading<T> _self;
  final $Res Function(AsyncValueLoading<T>) _then;

/// Create a copy of AsyncValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(AsyncValueLoading<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}


}

/// @nodoc


class AsyncValueData<T> implements AsyncValue<T> {
  const AsyncValueData({required this.data});
  

@override final  T data;

/// Create a copy of AsyncValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsyncValueDataCopyWith<T, AsyncValueData<T>> get copyWith => _$AsyncValueDataCopyWithImpl<T, AsyncValueData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncValueData<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'AsyncValue<$T>.data(data: $data)';
}


}

/// @nodoc
abstract mixin class $AsyncValueDataCopyWith<T,$Res> implements $AsyncValueCopyWith<T, $Res> {
  factory $AsyncValueDataCopyWith(AsyncValueData<T> value, $Res Function(AsyncValueData<T>) _then) = _$AsyncValueDataCopyWithImpl;
@useResult
$Res call({
 T data
});




}
/// @nodoc
class _$AsyncValueDataCopyWithImpl<T,$Res>
    implements $AsyncValueDataCopyWith<T, $Res> {
  _$AsyncValueDataCopyWithImpl(this._self, this._then);

  final AsyncValueData<T> _self;
  final $Res Function(AsyncValueData<T>) _then;

/// Create a copy of AsyncValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(AsyncValueData<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class AsyncValueError<T> implements AsyncValue<T> {
  const AsyncValueError({required this.exception, this.data});
  

 final  AppException exception;
@override final  T? data;

/// Create a copy of AsyncValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsyncValueErrorCopyWith<T, AsyncValueError<T>> get copyWith => _$AsyncValueErrorCopyWithImpl<T, AsyncValueError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncValueError<T>&&(identical(other.exception, exception) || other.exception == exception)&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,exception,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'AsyncValue<$T>.error(exception: $exception, data: $data)';
}


}

/// @nodoc
abstract mixin class $AsyncValueErrorCopyWith<T,$Res> implements $AsyncValueCopyWith<T, $Res> {
  factory $AsyncValueErrorCopyWith(AsyncValueError<T> value, $Res Function(AsyncValueError<T>) _then) = _$AsyncValueErrorCopyWithImpl;
@useResult
$Res call({
 AppException exception, T? data
});




}
/// @nodoc
class _$AsyncValueErrorCopyWithImpl<T,$Res>
    implements $AsyncValueErrorCopyWith<T, $Res> {
  _$AsyncValueErrorCopyWithImpl(this._self, this._then);

  final AsyncValueError<T> _self;
  final $Res Function(AsyncValueError<T>) _then;

/// Create a copy of AsyncValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? exception = null,Object? data = freezed,}) {
  return _then(AsyncValueError<T>(
exception: null == exception ? _self.exception : exception // ignore: cast_nullable_to_non_nullable
as AppException,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}


}

// dart format on
