// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayRequest {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayRequest);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlayRequest()';
}


}

/// @nodoc
class $PlayRequestCopyWith<$Res>  {
$PlayRequestCopyWith(PlayRequest _, $Res Function(PlayRequest) __);
}


/// Adds pattern-matching-related methods to [PlayRequest].
extension PlayRequestPatterns on PlayRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CampaignPlay value)?  campaign,TResult Function( BonusPlay value)?  bonus,TResult Function( DailyPlay value)?  daily,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CampaignPlay() when campaign != null:
return campaign(_that);case BonusPlay() when bonus != null:
return bonus(_that);case DailyPlay() when daily != null:
return daily(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CampaignPlay value)  campaign,required TResult Function( BonusPlay value)  bonus,required TResult Function( DailyPlay value)  daily,}){
final _that = this;
switch (_that) {
case CampaignPlay():
return campaign(_that);case BonusPlay():
return bonus(_that);case DailyPlay():
return daily(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CampaignPlay value)?  campaign,TResult? Function( BonusPlay value)?  bonus,TResult? Function( DailyPlay value)?  daily,}){
final _that = this;
switch (_that) {
case CampaignPlay() when campaign != null:
return campaign(_that);case BonusPlay() when bonus != null:
return bonus(_that);case DailyPlay() when daily != null:
return daily(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int order)?  campaign,TResult Function( int number)?  bonus,TResult Function( int yyyymmdd)?  daily,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CampaignPlay() when campaign != null:
return campaign(_that.order);case BonusPlay() when bonus != null:
return bonus(_that.number);case DailyPlay() when daily != null:
return daily(_that.yyyymmdd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int order)  campaign,required TResult Function( int number)  bonus,required TResult Function( int yyyymmdd)  daily,}) {final _that = this;
switch (_that) {
case CampaignPlay():
return campaign(_that.order);case BonusPlay():
return bonus(_that.number);case DailyPlay():
return daily(_that.yyyymmdd);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int order)?  campaign,TResult? Function( int number)?  bonus,TResult? Function( int yyyymmdd)?  daily,}) {final _that = this;
switch (_that) {
case CampaignPlay() when campaign != null:
return campaign(_that.order);case BonusPlay() when bonus != null:
return bonus(_that.number);case DailyPlay() when daily != null:
return daily(_that.yyyymmdd);case _:
  return null;

}
}

}

/// @nodoc


class CampaignPlay extends PlayRequest {
  const CampaignPlay(this.order): super._();
  

 final  int order;

/// Create a copy of PlayRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CampaignPlayCopyWith<CampaignPlay> get copyWith => _$CampaignPlayCopyWithImpl<CampaignPlay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CampaignPlay&&(identical(other.order, order) || other.order == order));
}


@override
int get hashCode => Object.hash(runtimeType,order);

@override
String toString() {
  return 'PlayRequest.campaign(order: $order)';
}


}

/// @nodoc
abstract mixin class $CampaignPlayCopyWith<$Res> implements $PlayRequestCopyWith<$Res> {
  factory $CampaignPlayCopyWith(CampaignPlay value, $Res Function(CampaignPlay) _then) = _$CampaignPlayCopyWithImpl;
@useResult
$Res call({
 int order
});




}
/// @nodoc
class _$CampaignPlayCopyWithImpl<$Res>
    implements $CampaignPlayCopyWith<$Res> {
  _$CampaignPlayCopyWithImpl(this._self, this._then);

  final CampaignPlay _self;
  final $Res Function(CampaignPlay) _then;

/// Create a copy of PlayRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? order = null,}) {
  return _then(CampaignPlay(
null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class BonusPlay extends PlayRequest {
  const BonusPlay(this.number): super._();
  

 final  int number;

/// Create a copy of PlayRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BonusPlayCopyWith<BonusPlay> get copyWith => _$BonusPlayCopyWithImpl<BonusPlay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BonusPlay&&(identical(other.number, number) || other.number == number));
}


@override
int get hashCode => Object.hash(runtimeType,number);

@override
String toString() {
  return 'PlayRequest.bonus(number: $number)';
}


}

/// @nodoc
abstract mixin class $BonusPlayCopyWith<$Res> implements $PlayRequestCopyWith<$Res> {
  factory $BonusPlayCopyWith(BonusPlay value, $Res Function(BonusPlay) _then) = _$BonusPlayCopyWithImpl;
@useResult
$Res call({
 int number
});




}
/// @nodoc
class _$BonusPlayCopyWithImpl<$Res>
    implements $BonusPlayCopyWith<$Res> {
  _$BonusPlayCopyWithImpl(this._self, this._then);

  final BonusPlay _self;
  final $Res Function(BonusPlay) _then;

/// Create a copy of PlayRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? number = null,}) {
  return _then(BonusPlay(
null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class DailyPlay extends PlayRequest {
  const DailyPlay(this.yyyymmdd): super._();
  

 final  int yyyymmdd;

/// Create a copy of PlayRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyPlayCopyWith<DailyPlay> get copyWith => _$DailyPlayCopyWithImpl<DailyPlay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyPlay&&(identical(other.yyyymmdd, yyyymmdd) || other.yyyymmdd == yyyymmdd));
}


@override
int get hashCode => Object.hash(runtimeType,yyyymmdd);

@override
String toString() {
  return 'PlayRequest.daily(yyyymmdd: $yyyymmdd)';
}


}

/// @nodoc
abstract mixin class $DailyPlayCopyWith<$Res> implements $PlayRequestCopyWith<$Res> {
  factory $DailyPlayCopyWith(DailyPlay value, $Res Function(DailyPlay) _then) = _$DailyPlayCopyWithImpl;
@useResult
$Res call({
 int yyyymmdd
});




}
/// @nodoc
class _$DailyPlayCopyWithImpl<$Res>
    implements $DailyPlayCopyWith<$Res> {
  _$DailyPlayCopyWithImpl(this._self, this._then);

  final DailyPlay _self;
  final $Res Function(DailyPlay) _then;

/// Create a copy of PlayRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? yyyymmdd = null,}) {
  return _then(DailyPlay(
null == yyyymmdd ? _self.yyyymmdd : yyyymmdd // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
