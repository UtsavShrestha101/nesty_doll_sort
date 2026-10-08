// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'welcome_back_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WelcomeBackState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WelcomeBackState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WelcomeBackState()';
}


}

/// @nodoc
class $WelcomeBackStateCopyWith<$Res>  {
$WelcomeBackStateCopyWith(WelcomeBackState _, $Res Function(WelcomeBackState) __);
}


/// Adds pattern-matching-related methods to [WelcomeBackState].
extension WelcomeBackStatePatterns on WelcomeBackState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WelcomeBackHidden value)?  hidden,TResult Function( WelcomeBackShown value)?  shown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WelcomeBackHidden() when hidden != null:
return hidden(_that);case WelcomeBackShown() when shown != null:
return shown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WelcomeBackHidden value)  hidden,required TResult Function( WelcomeBackShown value)  shown,}){
final _that = this;
switch (_that) {
case WelcomeBackHidden():
return hidden(_that);case WelcomeBackShown():
return shown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WelcomeBackHidden value)?  hidden,TResult? Function( WelcomeBackShown value)?  shown,}){
final _that = this;
switch (_that) {
case WelcomeBackHidden() when hidden != null:
return hidden(_that);case WelcomeBackShown() when shown != null:
return shown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  hidden,TResult Function( WelcomeBackVariant variant,  int streak)?  shown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WelcomeBackHidden() when hidden != null:
return hidden();case WelcomeBackShown() when shown != null:
return shown(_that.variant,_that.streak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  hidden,required TResult Function( WelcomeBackVariant variant,  int streak)  shown,}) {final _that = this;
switch (_that) {
case WelcomeBackHidden():
return hidden();case WelcomeBackShown():
return shown(_that.variant,_that.streak);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  hidden,TResult? Function( WelcomeBackVariant variant,  int streak)?  shown,}) {final _that = this;
switch (_that) {
case WelcomeBackHidden() when hidden != null:
return hidden();case WelcomeBackShown() when shown != null:
return shown(_that.variant,_that.streak);case _:
  return null;

}
}

}

/// @nodoc


class WelcomeBackHidden implements WelcomeBackState {
  const WelcomeBackHidden();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WelcomeBackHidden);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WelcomeBackState.hidden()';
}


}




/// @nodoc


class WelcomeBackShown implements WelcomeBackState {
  const WelcomeBackShown({required this.variant, required this.streak});
  

 final  WelcomeBackVariant variant;
 final  int streak;

/// Create a copy of WelcomeBackState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WelcomeBackShownCopyWith<WelcomeBackShown> get copyWith => _$WelcomeBackShownCopyWithImpl<WelcomeBackShown>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WelcomeBackShown&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.streak, streak) || other.streak == streak));
}


@override
int get hashCode => Object.hash(runtimeType,variant,streak);

@override
String toString() {
  return 'WelcomeBackState.shown(variant: $variant, streak: $streak)';
}


}

/// @nodoc
abstract mixin class $WelcomeBackShownCopyWith<$Res> implements $WelcomeBackStateCopyWith<$Res> {
  factory $WelcomeBackShownCopyWith(WelcomeBackShown value, $Res Function(WelcomeBackShown) _then) = _$WelcomeBackShownCopyWithImpl;
@useResult
$Res call({
 WelcomeBackVariant variant, int streak
});




}
/// @nodoc
class _$WelcomeBackShownCopyWithImpl<$Res>
    implements $WelcomeBackShownCopyWith<$Res> {
  _$WelcomeBackShownCopyWithImpl(this._self, this._then);

  final WelcomeBackShown _self;
  final $Res Function(WelcomeBackShown) _then;

/// Create a copy of WelcomeBackState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? variant = null,Object? streak = null,}) {
  return _then(WelcomeBackShown(
variant: null == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as WelcomeBackVariant,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
