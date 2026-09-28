// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyState implements DiagnosticableTreeMixin {

/// The reconciled streak, freezes, cycle and today's puzzle
/// (`DailyService.refresh`).
 DailyStatus get status;/// The header's coin pill (`SaveService.coins`).
 int get coins;/// `daily_reward` (Remote Config): the puzzle card's coin chip and the
/// win screen's "+50" (m3-design §7.1).
 int get rewardCoins;/// `streak7_reward`: the chest row's "· 300 coins" and the modal's
/// "+300".
 int get chestCoins;/// Until the next local midnight (frame 5.5 "Next puzzle in 14h 12m"),
/// refreshed once a minute while the screen is open.
 Duration? get untilNextPuzzle;/// Today's puzzle's colours, once `LevelResolver.resolve` lands (the
/// puzzle card's preview); null shows `ui_spinner` instead.
 List<DollColor>? get previewColors;/// The resolve failed (every retry): the preview is hidden, Play still
/// works (the gameplay page shows its own retry view).
 bool get previewFailed;/// Frame 5.5's "Play Level N" (`LevelResolver.homeRequest`): the
/// campaign level (or Bonus Endless) Home's PLAY would start.
 PlayRequest get homeRequest;/// The number frame 5.5's copy shows (`SaveService.currentLevel`).
 int get homeLevelNumber;
/// Create a copy of DailyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyStateCopyWith<DailyState> get copyWith => _$DailyStateCopyWithImpl<DailyState>(this as DailyState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DailyState'))
    ..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('coins', coins))..add(DiagnosticsProperty('rewardCoins', rewardCoins))..add(DiagnosticsProperty('chestCoins', chestCoins))..add(DiagnosticsProperty('untilNextPuzzle', untilNextPuzzle))..add(DiagnosticsProperty('previewColors', previewColors))..add(DiagnosticsProperty('previewFailed', previewFailed))..add(DiagnosticsProperty('homeRequest', homeRequest))..add(DiagnosticsProperty('homeLevelNumber', homeLevelNumber));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyState&&(identical(other.status, status) || other.status == status)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.chestCoins, chestCoins) || other.chestCoins == chestCoins)&&(identical(other.untilNextPuzzle, untilNextPuzzle) || other.untilNextPuzzle == untilNextPuzzle)&&const DeepCollectionEquality().equals(other.previewColors, previewColors)&&(identical(other.previewFailed, previewFailed) || other.previewFailed == previewFailed)&&(identical(other.homeRequest, homeRequest) || other.homeRequest == homeRequest)&&(identical(other.homeLevelNumber, homeLevelNumber) || other.homeLevelNumber == homeLevelNumber));
}


@override
int get hashCode => Object.hash(runtimeType,status,coins,rewardCoins,chestCoins,untilNextPuzzle,const DeepCollectionEquality().hash(previewColors),previewFailed,homeRequest,homeLevelNumber);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DailyState(status: $status, coins: $coins, rewardCoins: $rewardCoins, chestCoins: $chestCoins, untilNextPuzzle: $untilNextPuzzle, previewColors: $previewColors, previewFailed: $previewFailed, homeRequest: $homeRequest, homeLevelNumber: $homeLevelNumber)';
}


}

/// @nodoc
abstract mixin class $DailyStateCopyWith<$Res>  {
  factory $DailyStateCopyWith(DailyState value, $Res Function(DailyState) _then) = _$DailyStateCopyWithImpl;
@useResult
$Res call({
 DailyStatus status, int coins, int rewardCoins, int chestCoins, Duration? untilNextPuzzle, List<DollColor>? previewColors, bool previewFailed, PlayRequest homeRequest, int homeLevelNumber
});


$DailyStatusCopyWith<$Res> get status;$PlayRequestCopyWith<$Res> get homeRequest;

}
/// @nodoc
class _$DailyStateCopyWithImpl<$Res>
    implements $DailyStateCopyWith<$Res> {
  _$DailyStateCopyWithImpl(this._self, this._then);

  final DailyState _self;
  final $Res Function(DailyState) _then;

/// Create a copy of DailyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? coins = null,Object? rewardCoins = null,Object? chestCoins = null,Object? untilNextPuzzle = freezed,Object? previewColors = freezed,Object? previewFailed = null,Object? homeRequest = null,Object? homeLevelNumber = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DailyStatus,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,rewardCoins: null == rewardCoins ? _self.rewardCoins : rewardCoins // ignore: cast_nullable_to_non_nullable
as int,chestCoins: null == chestCoins ? _self.chestCoins : chestCoins // ignore: cast_nullable_to_non_nullable
as int,untilNextPuzzle: freezed == untilNextPuzzle ? _self.untilNextPuzzle : untilNextPuzzle // ignore: cast_nullable_to_non_nullable
as Duration?,previewColors: freezed == previewColors ? _self.previewColors : previewColors // ignore: cast_nullable_to_non_nullable
as List<DollColor>?,previewFailed: null == previewFailed ? _self.previewFailed : previewFailed // ignore: cast_nullable_to_non_nullable
as bool,homeRequest: null == homeRequest ? _self.homeRequest : homeRequest // ignore: cast_nullable_to_non_nullable
as PlayRequest,homeLevelNumber: null == homeLevelNumber ? _self.homeLevelNumber : homeLevelNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of DailyState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailyStatusCopyWith<$Res> get status {
  
  return $DailyStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of DailyState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res> get homeRequest {
  
  return $PlayRequestCopyWith<$Res>(_self.homeRequest, (value) {
    return _then(_self.copyWith(homeRequest: value));
  });
}
}


/// Adds pattern-matching-related methods to [DailyState].
extension DailyStatePatterns on DailyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyState value)  $default,){
final _that = this;
switch (_that) {
case _DailyState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyState value)?  $default,){
final _that = this;
switch (_that) {
case _DailyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DailyStatus status,  int coins,  int rewardCoins,  int chestCoins,  Duration? untilNextPuzzle,  List<DollColor>? previewColors,  bool previewFailed,  PlayRequest homeRequest,  int homeLevelNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyState() when $default != null:
return $default(_that.status,_that.coins,_that.rewardCoins,_that.chestCoins,_that.untilNextPuzzle,_that.previewColors,_that.previewFailed,_that.homeRequest,_that.homeLevelNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DailyStatus status,  int coins,  int rewardCoins,  int chestCoins,  Duration? untilNextPuzzle,  List<DollColor>? previewColors,  bool previewFailed,  PlayRequest homeRequest,  int homeLevelNumber)  $default,) {final _that = this;
switch (_that) {
case _DailyState():
return $default(_that.status,_that.coins,_that.rewardCoins,_that.chestCoins,_that.untilNextPuzzle,_that.previewColors,_that.previewFailed,_that.homeRequest,_that.homeLevelNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DailyStatus status,  int coins,  int rewardCoins,  int chestCoins,  Duration? untilNextPuzzle,  List<DollColor>? previewColors,  bool previewFailed,  PlayRequest homeRequest,  int homeLevelNumber)?  $default,) {final _that = this;
switch (_that) {
case _DailyState() when $default != null:
return $default(_that.status,_that.coins,_that.rewardCoins,_that.chestCoins,_that.untilNextPuzzle,_that.previewColors,_that.previewFailed,_that.homeRequest,_that.homeLevelNumber);case _:
  return null;

}
}

}

/// @nodoc


class _DailyState with DiagnosticableTreeMixin implements DailyState {
  const _DailyState({required this.status, this.coins = 0, this.rewardCoins = 50, this.chestCoins = 300, this.untilNextPuzzle, final  List<DollColor>? previewColors, this.previewFailed = false, this.homeRequest = const PlayRequest.campaign(1), this.homeLevelNumber = 1}): _previewColors = previewColors;
  

/// The reconciled streak, freezes, cycle and today's puzzle
/// (`DailyService.refresh`).
@override final  DailyStatus status;
/// The header's coin pill (`SaveService.coins`).
@override@JsonKey() final  int coins;
/// `daily_reward` (Remote Config): the puzzle card's coin chip and the
/// win screen's "+50" (m3-design §7.1).
@override@JsonKey() final  int rewardCoins;
/// `streak7_reward`: the chest row's "· 300 coins" and the modal's
/// "+300".
@override@JsonKey() final  int chestCoins;
/// Until the next local midnight (frame 5.5 "Next puzzle in 14h 12m"),
/// refreshed once a minute while the screen is open.
@override final  Duration? untilNextPuzzle;
/// Today's puzzle's colours, once `LevelResolver.resolve` lands (the
/// puzzle card's preview); null shows `ui_spinner` instead.
 final  List<DollColor>? _previewColors;
/// Today's puzzle's colours, once `LevelResolver.resolve` lands (the
/// puzzle card's preview); null shows `ui_spinner` instead.
@override List<DollColor>? get previewColors {
  final value = _previewColors;
  if (value == null) return null;
  if (_previewColors is EqualUnmodifiableListView) return _previewColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// The resolve failed (every retry): the preview is hidden, Play still
/// works (the gameplay page shows its own retry view).
@override@JsonKey() final  bool previewFailed;
/// Frame 5.5's "Play Level N" (`LevelResolver.homeRequest`): the
/// campaign level (or Bonus Endless) Home's PLAY would start.
@override@JsonKey() final  PlayRequest homeRequest;
/// The number frame 5.5's copy shows (`SaveService.currentLevel`).
@override@JsonKey() final  int homeLevelNumber;

/// Create a copy of DailyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyStateCopyWith<_DailyState> get copyWith => __$DailyStateCopyWithImpl<_DailyState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DailyState'))
    ..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('coins', coins))..add(DiagnosticsProperty('rewardCoins', rewardCoins))..add(DiagnosticsProperty('chestCoins', chestCoins))..add(DiagnosticsProperty('untilNextPuzzle', untilNextPuzzle))..add(DiagnosticsProperty('previewColors', previewColors))..add(DiagnosticsProperty('previewFailed', previewFailed))..add(DiagnosticsProperty('homeRequest', homeRequest))..add(DiagnosticsProperty('homeLevelNumber', homeLevelNumber));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyState&&(identical(other.status, status) || other.status == status)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.chestCoins, chestCoins) || other.chestCoins == chestCoins)&&(identical(other.untilNextPuzzle, untilNextPuzzle) || other.untilNextPuzzle == untilNextPuzzle)&&const DeepCollectionEquality().equals(other._previewColors, _previewColors)&&(identical(other.previewFailed, previewFailed) || other.previewFailed == previewFailed)&&(identical(other.homeRequest, homeRequest) || other.homeRequest == homeRequest)&&(identical(other.homeLevelNumber, homeLevelNumber) || other.homeLevelNumber == homeLevelNumber));
}


@override
int get hashCode => Object.hash(runtimeType,status,coins,rewardCoins,chestCoins,untilNextPuzzle,const DeepCollectionEquality().hash(_previewColors),previewFailed,homeRequest,homeLevelNumber);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DailyState(status: $status, coins: $coins, rewardCoins: $rewardCoins, chestCoins: $chestCoins, untilNextPuzzle: $untilNextPuzzle, previewColors: $previewColors, previewFailed: $previewFailed, homeRequest: $homeRequest, homeLevelNumber: $homeLevelNumber)';
}


}

/// @nodoc
abstract mixin class _$DailyStateCopyWith<$Res> implements $DailyStateCopyWith<$Res> {
  factory _$DailyStateCopyWith(_DailyState value, $Res Function(_DailyState) _then) = __$DailyStateCopyWithImpl;
@override @useResult
$Res call({
 DailyStatus status, int coins, int rewardCoins, int chestCoins, Duration? untilNextPuzzle, List<DollColor>? previewColors, bool previewFailed, PlayRequest homeRequest, int homeLevelNumber
});


@override $DailyStatusCopyWith<$Res> get status;@override $PlayRequestCopyWith<$Res> get homeRequest;

}
/// @nodoc
class __$DailyStateCopyWithImpl<$Res>
    implements _$DailyStateCopyWith<$Res> {
  __$DailyStateCopyWithImpl(this._self, this._then);

  final _DailyState _self;
  final $Res Function(_DailyState) _then;

/// Create a copy of DailyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? coins = null,Object? rewardCoins = null,Object? chestCoins = null,Object? untilNextPuzzle = freezed,Object? previewColors = freezed,Object? previewFailed = null,Object? homeRequest = null,Object? homeLevelNumber = null,}) {
  return _then(_DailyState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DailyStatus,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,rewardCoins: null == rewardCoins ? _self.rewardCoins : rewardCoins // ignore: cast_nullable_to_non_nullable
as int,chestCoins: null == chestCoins ? _self.chestCoins : chestCoins // ignore: cast_nullable_to_non_nullable
as int,untilNextPuzzle: freezed == untilNextPuzzle ? _self.untilNextPuzzle : untilNextPuzzle // ignore: cast_nullable_to_non_nullable
as Duration?,previewColors: freezed == previewColors ? _self._previewColors : previewColors // ignore: cast_nullable_to_non_nullable
as List<DollColor>?,previewFailed: null == previewFailed ? _self.previewFailed : previewFailed // ignore: cast_nullable_to_non_nullable
as bool,homeRequest: null == homeRequest ? _self.homeRequest : homeRequest // ignore: cast_nullable_to_non_nullable
as PlayRequest,homeLevelNumber: null == homeLevelNumber ? _self.homeLevelNumber : homeLevelNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of DailyState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailyStatusCopyWith<$Res> get status {
  
  return $DailyStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of DailyState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res> get homeRequest {
  
  return $PlayRequestCopyWith<$Res>(_self.homeRequest, (value) {
    return _then(_self.copyWith(homeRequest: value));
  });
}
}

// dart format on
