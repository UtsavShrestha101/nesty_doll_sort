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
 int get homeLevelNumber;/// A past day the month's picker has chosen (frame 14.3b, spec-prop
/// §7.5c): its card is open under the month card. Page state, not a
/// route; null while none is.
 LocalDate? get selectedPastDate;/// The chosen day's colours once its board resolves (the card's
/// preview); null shows the spinner.
 List<DollColor>? get pastPreviewColors;/// The chosen day's board did not resolve: the preview is hidden, Play
/// still works.
 bool get pastPreviewFailed;/// The chosen day's difficulty facts for the card's chip
/// ("5 colors · Hard"): `DifficultyCurve.dailyTier` and the colour
/// count of `dailyParams`, both pure functions of the date.
 Tier? get pastTier; int get pastColorCount;/// 0 shows today's month; -1 the month before, while the window
/// reaches into it (the ‹ chip, frame 14.2c). Never further.
 int get monthOffset;
/// Create a copy of DailyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyStateCopyWith<DailyState> get copyWith => _$DailyStateCopyWithImpl<DailyState>(this as DailyState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DailyState'))
    ..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('coins', coins))..add(DiagnosticsProperty('rewardCoins', rewardCoins))..add(DiagnosticsProperty('chestCoins', chestCoins))..add(DiagnosticsProperty('untilNextPuzzle', untilNextPuzzle))..add(DiagnosticsProperty('previewColors', previewColors))..add(DiagnosticsProperty('previewFailed', previewFailed))..add(DiagnosticsProperty('homeRequest', homeRequest))..add(DiagnosticsProperty('homeLevelNumber', homeLevelNumber))..add(DiagnosticsProperty('selectedPastDate', selectedPastDate))..add(DiagnosticsProperty('pastPreviewColors', pastPreviewColors))..add(DiagnosticsProperty('pastPreviewFailed', pastPreviewFailed))..add(DiagnosticsProperty('pastTier', pastTier))..add(DiagnosticsProperty('pastColorCount', pastColorCount))..add(DiagnosticsProperty('monthOffset', monthOffset));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyState&&(identical(other.status, status) || other.status == status)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.chestCoins, chestCoins) || other.chestCoins == chestCoins)&&(identical(other.untilNextPuzzle, untilNextPuzzle) || other.untilNextPuzzle == untilNextPuzzle)&&const DeepCollectionEquality().equals(other.previewColors, previewColors)&&(identical(other.previewFailed, previewFailed) || other.previewFailed == previewFailed)&&(identical(other.homeRequest, homeRequest) || other.homeRequest == homeRequest)&&(identical(other.homeLevelNumber, homeLevelNumber) || other.homeLevelNumber == homeLevelNumber)&&(identical(other.selectedPastDate, selectedPastDate) || other.selectedPastDate == selectedPastDate)&&const DeepCollectionEquality().equals(other.pastPreviewColors, pastPreviewColors)&&(identical(other.pastPreviewFailed, pastPreviewFailed) || other.pastPreviewFailed == pastPreviewFailed)&&(identical(other.pastTier, pastTier) || other.pastTier == pastTier)&&(identical(other.pastColorCount, pastColorCount) || other.pastColorCount == pastColorCount)&&(identical(other.monthOffset, monthOffset) || other.monthOffset == monthOffset));
}


@override
int get hashCode => Object.hash(runtimeType,status,coins,rewardCoins,chestCoins,untilNextPuzzle,const DeepCollectionEquality().hash(previewColors),previewFailed,homeRequest,homeLevelNumber,selectedPastDate,const DeepCollectionEquality().hash(pastPreviewColors),pastPreviewFailed,pastTier,pastColorCount,monthOffset);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DailyState(status: $status, coins: $coins, rewardCoins: $rewardCoins, chestCoins: $chestCoins, untilNextPuzzle: $untilNextPuzzle, previewColors: $previewColors, previewFailed: $previewFailed, homeRequest: $homeRequest, homeLevelNumber: $homeLevelNumber, selectedPastDate: $selectedPastDate, pastPreviewColors: $pastPreviewColors, pastPreviewFailed: $pastPreviewFailed, pastTier: $pastTier, pastColorCount: $pastColorCount, monthOffset: $monthOffset)';
}


}

/// @nodoc
abstract mixin class $DailyStateCopyWith<$Res>  {
  factory $DailyStateCopyWith(DailyState value, $Res Function(DailyState) _then) = _$DailyStateCopyWithImpl;
@useResult
$Res call({
 DailyStatus status, int coins, int rewardCoins, int chestCoins, Duration? untilNextPuzzle, List<DollColor>? previewColors, bool previewFailed, PlayRequest homeRequest, int homeLevelNumber, LocalDate? selectedPastDate, List<DollColor>? pastPreviewColors, bool pastPreviewFailed, Tier? pastTier, int pastColorCount, int monthOffset
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
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? coins = null,Object? rewardCoins = null,Object? chestCoins = null,Object? untilNextPuzzle = freezed,Object? previewColors = freezed,Object? previewFailed = null,Object? homeRequest = null,Object? homeLevelNumber = null,Object? selectedPastDate = freezed,Object? pastPreviewColors = freezed,Object? pastPreviewFailed = null,Object? pastTier = freezed,Object? pastColorCount = null,Object? monthOffset = null,}) {
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
as int,selectedPastDate: freezed == selectedPastDate ? _self.selectedPastDate : selectedPastDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,pastPreviewColors: freezed == pastPreviewColors ? _self.pastPreviewColors : pastPreviewColors // ignore: cast_nullable_to_non_nullable
as List<DollColor>?,pastPreviewFailed: null == pastPreviewFailed ? _self.pastPreviewFailed : pastPreviewFailed // ignore: cast_nullable_to_non_nullable
as bool,pastTier: freezed == pastTier ? _self.pastTier : pastTier // ignore: cast_nullable_to_non_nullable
as Tier?,pastColorCount: null == pastColorCount ? _self.pastColorCount : pastColorCount // ignore: cast_nullable_to_non_nullable
as int,monthOffset: null == monthOffset ? _self.monthOffset : monthOffset // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DailyStatus status,  int coins,  int rewardCoins,  int chestCoins,  Duration? untilNextPuzzle,  List<DollColor>? previewColors,  bool previewFailed,  PlayRequest homeRequest,  int homeLevelNumber,  LocalDate? selectedPastDate,  List<DollColor>? pastPreviewColors,  bool pastPreviewFailed,  Tier? pastTier,  int pastColorCount,  int monthOffset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyState() when $default != null:
return $default(_that.status,_that.coins,_that.rewardCoins,_that.chestCoins,_that.untilNextPuzzle,_that.previewColors,_that.previewFailed,_that.homeRequest,_that.homeLevelNumber,_that.selectedPastDate,_that.pastPreviewColors,_that.pastPreviewFailed,_that.pastTier,_that.pastColorCount,_that.monthOffset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DailyStatus status,  int coins,  int rewardCoins,  int chestCoins,  Duration? untilNextPuzzle,  List<DollColor>? previewColors,  bool previewFailed,  PlayRequest homeRequest,  int homeLevelNumber,  LocalDate? selectedPastDate,  List<DollColor>? pastPreviewColors,  bool pastPreviewFailed,  Tier? pastTier,  int pastColorCount,  int monthOffset)  $default,) {final _that = this;
switch (_that) {
case _DailyState():
return $default(_that.status,_that.coins,_that.rewardCoins,_that.chestCoins,_that.untilNextPuzzle,_that.previewColors,_that.previewFailed,_that.homeRequest,_that.homeLevelNumber,_that.selectedPastDate,_that.pastPreviewColors,_that.pastPreviewFailed,_that.pastTier,_that.pastColorCount,_that.monthOffset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DailyStatus status,  int coins,  int rewardCoins,  int chestCoins,  Duration? untilNextPuzzle,  List<DollColor>? previewColors,  bool previewFailed,  PlayRequest homeRequest,  int homeLevelNumber,  LocalDate? selectedPastDate,  List<DollColor>? pastPreviewColors,  bool pastPreviewFailed,  Tier? pastTier,  int pastColorCount,  int monthOffset)?  $default,) {final _that = this;
switch (_that) {
case _DailyState() when $default != null:
return $default(_that.status,_that.coins,_that.rewardCoins,_that.chestCoins,_that.untilNextPuzzle,_that.previewColors,_that.previewFailed,_that.homeRequest,_that.homeLevelNumber,_that.selectedPastDate,_that.pastPreviewColors,_that.pastPreviewFailed,_that.pastTier,_that.pastColorCount,_that.monthOffset);case _:
  return null;

}
}

}

/// @nodoc


class _DailyState with DiagnosticableTreeMixin implements DailyState {
  const _DailyState({required this.status, this.coins = 0, this.rewardCoins = 50, this.chestCoins = 300, this.untilNextPuzzle, final  List<DollColor>? previewColors, this.previewFailed = false, this.homeRequest = const PlayRequest.campaign(1), this.homeLevelNumber = 1, this.selectedPastDate, final  List<DollColor>? pastPreviewColors, this.pastPreviewFailed = false, this.pastTier, this.pastColorCount = 0, this.monthOffset = 0}): _previewColors = previewColors,_pastPreviewColors = pastPreviewColors;
  

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
/// A past day the month's picker has chosen (frame 14.3b, spec-prop
/// §7.5c): its card is open under the month card. Page state, not a
/// route; null while none is.
@override final  LocalDate? selectedPastDate;
/// The chosen day's colours once its board resolves (the card's
/// preview); null shows the spinner.
 final  List<DollColor>? _pastPreviewColors;
/// The chosen day's colours once its board resolves (the card's
/// preview); null shows the spinner.
@override List<DollColor>? get pastPreviewColors {
  final value = _pastPreviewColors;
  if (value == null) return null;
  if (_pastPreviewColors is EqualUnmodifiableListView) return _pastPreviewColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// The chosen day's board did not resolve: the preview is hidden, Play
/// still works.
@override@JsonKey() final  bool pastPreviewFailed;
/// The chosen day's difficulty facts for the card's chip
/// ("5 colors · Hard"): `DifficultyCurve.dailyTier` and the colour
/// count of `dailyParams`, both pure functions of the date.
@override final  Tier? pastTier;
@override@JsonKey() final  int pastColorCount;
/// 0 shows today's month; -1 the month before, while the window
/// reaches into it (the ‹ chip, frame 14.2c). Never further.
@override@JsonKey() final  int monthOffset;

/// Create a copy of DailyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyStateCopyWith<_DailyState> get copyWith => __$DailyStateCopyWithImpl<_DailyState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DailyState'))
    ..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('coins', coins))..add(DiagnosticsProperty('rewardCoins', rewardCoins))..add(DiagnosticsProperty('chestCoins', chestCoins))..add(DiagnosticsProperty('untilNextPuzzle', untilNextPuzzle))..add(DiagnosticsProperty('previewColors', previewColors))..add(DiagnosticsProperty('previewFailed', previewFailed))..add(DiagnosticsProperty('homeRequest', homeRequest))..add(DiagnosticsProperty('homeLevelNumber', homeLevelNumber))..add(DiagnosticsProperty('selectedPastDate', selectedPastDate))..add(DiagnosticsProperty('pastPreviewColors', pastPreviewColors))..add(DiagnosticsProperty('pastPreviewFailed', pastPreviewFailed))..add(DiagnosticsProperty('pastTier', pastTier))..add(DiagnosticsProperty('pastColorCount', pastColorCount))..add(DiagnosticsProperty('monthOffset', monthOffset));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyState&&(identical(other.status, status) || other.status == status)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.chestCoins, chestCoins) || other.chestCoins == chestCoins)&&(identical(other.untilNextPuzzle, untilNextPuzzle) || other.untilNextPuzzle == untilNextPuzzle)&&const DeepCollectionEquality().equals(other._previewColors, _previewColors)&&(identical(other.previewFailed, previewFailed) || other.previewFailed == previewFailed)&&(identical(other.homeRequest, homeRequest) || other.homeRequest == homeRequest)&&(identical(other.homeLevelNumber, homeLevelNumber) || other.homeLevelNumber == homeLevelNumber)&&(identical(other.selectedPastDate, selectedPastDate) || other.selectedPastDate == selectedPastDate)&&const DeepCollectionEquality().equals(other._pastPreviewColors, _pastPreviewColors)&&(identical(other.pastPreviewFailed, pastPreviewFailed) || other.pastPreviewFailed == pastPreviewFailed)&&(identical(other.pastTier, pastTier) || other.pastTier == pastTier)&&(identical(other.pastColorCount, pastColorCount) || other.pastColorCount == pastColorCount)&&(identical(other.monthOffset, monthOffset) || other.monthOffset == monthOffset));
}


@override
int get hashCode => Object.hash(runtimeType,status,coins,rewardCoins,chestCoins,untilNextPuzzle,const DeepCollectionEquality().hash(_previewColors),previewFailed,homeRequest,homeLevelNumber,selectedPastDate,const DeepCollectionEquality().hash(_pastPreviewColors),pastPreviewFailed,pastTier,pastColorCount,monthOffset);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DailyState(status: $status, coins: $coins, rewardCoins: $rewardCoins, chestCoins: $chestCoins, untilNextPuzzle: $untilNextPuzzle, previewColors: $previewColors, previewFailed: $previewFailed, homeRequest: $homeRequest, homeLevelNumber: $homeLevelNumber, selectedPastDate: $selectedPastDate, pastPreviewColors: $pastPreviewColors, pastPreviewFailed: $pastPreviewFailed, pastTier: $pastTier, pastColorCount: $pastColorCount, monthOffset: $monthOffset)';
}


}

/// @nodoc
abstract mixin class _$DailyStateCopyWith<$Res> implements $DailyStateCopyWith<$Res> {
  factory _$DailyStateCopyWith(_DailyState value, $Res Function(_DailyState) _then) = __$DailyStateCopyWithImpl;
@override @useResult
$Res call({
 DailyStatus status, int coins, int rewardCoins, int chestCoins, Duration? untilNextPuzzle, List<DollColor>? previewColors, bool previewFailed, PlayRequest homeRequest, int homeLevelNumber, LocalDate? selectedPastDate, List<DollColor>? pastPreviewColors, bool pastPreviewFailed, Tier? pastTier, int pastColorCount, int monthOffset
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
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? coins = null,Object? rewardCoins = null,Object? chestCoins = null,Object? untilNextPuzzle = freezed,Object? previewColors = freezed,Object? previewFailed = null,Object? homeRequest = null,Object? homeLevelNumber = null,Object? selectedPastDate = freezed,Object? pastPreviewColors = freezed,Object? pastPreviewFailed = null,Object? pastTier = freezed,Object? pastColorCount = null,Object? monthOffset = null,}) {
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
as int,selectedPastDate: freezed == selectedPastDate ? _self.selectedPastDate : selectedPastDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,pastPreviewColors: freezed == pastPreviewColors ? _self._pastPreviewColors : pastPreviewColors // ignore: cast_nullable_to_non_nullable
as List<DollColor>?,pastPreviewFailed: null == pastPreviewFailed ? _self.pastPreviewFailed : pastPreviewFailed // ignore: cast_nullable_to_non_nullable
as bool,pastTier: freezed == pastTier ? _self.pastTier : pastTier // ignore: cast_nullable_to_non_nullable
as Tier?,pastColorCount: null == pastColorCount ? _self.pastColorCount : pastColorCount // ignore: cast_nullable_to_non_nullable
as int,monthOffset: null == monthOffset ? _self.monthOffset : monthOffset // ignore: cast_nullable_to_non_nullable
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
