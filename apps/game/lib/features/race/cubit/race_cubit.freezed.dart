// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'race_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RaceState implements DiagnosticableTreeMixin {

/// The race being played (the rival and its raceNo).
 RacePlay get request; RacePhase get phase;/// A [RaceHold] is on: the rival's clock is stopped.
 bool get held;/// Families on the board (both sides have the same board).
 int get totalSets;/// Families the rival has completed in its current run (0 again after
/// a restart).
 int get rivalSets; RivalActivity get activity;/// The rival's moves in this race, all runs together: bumped once per
/// rival move, so the strip can play its short "moved" beat (never per
/// frame).
 int get rivalMoves;/// How many times the rival started over in this race.
 int get rivalRestarts;/// The rival's board, from its mirrored `GameSession` (a mini board, if
/// Claude Design's frame 9.3 asks for one; tests). Null before the
/// board loads.
 GameState? get rivalBoard;/// Once [phase] is [RacePhase.finished]: who won.
 RaceResult? get result;/// Once the player won: what `SaveService.recordRaceWin` did (the
/// coins, the rival unlocked, the new badges), written exactly once.
 RaceWinOutcome? get outcome;
/// Create a copy of RaceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RaceStateCopyWith<RaceState> get copyWith => _$RaceStateCopyWithImpl<RaceState>(this as RaceState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RaceState'))
    ..add(DiagnosticsProperty('request', request))..add(DiagnosticsProperty('phase', phase))..add(DiagnosticsProperty('held', held))..add(DiagnosticsProperty('totalSets', totalSets))..add(DiagnosticsProperty('rivalSets', rivalSets))..add(DiagnosticsProperty('activity', activity))..add(DiagnosticsProperty('rivalMoves', rivalMoves))..add(DiagnosticsProperty('rivalRestarts', rivalRestarts))..add(DiagnosticsProperty('rivalBoard', rivalBoard))..add(DiagnosticsProperty('result', result))..add(DiagnosticsProperty('outcome', outcome));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RaceState&&const DeepCollectionEquality().equals(other.request, request)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.held, held) || other.held == held)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.rivalSets, rivalSets) || other.rivalSets == rivalSets)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.rivalMoves, rivalMoves) || other.rivalMoves == rivalMoves)&&(identical(other.rivalRestarts, rivalRestarts) || other.rivalRestarts == rivalRestarts)&&(identical(other.rivalBoard, rivalBoard) || other.rivalBoard == rivalBoard)&&(identical(other.result, result) || other.result == result)&&(identical(other.outcome, outcome) || other.outcome == outcome));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(request),phase,held,totalSets,rivalSets,activity,rivalMoves,rivalRestarts,rivalBoard,result,outcome);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RaceState(request: $request, phase: $phase, held: $held, totalSets: $totalSets, rivalSets: $rivalSets, activity: $activity, rivalMoves: $rivalMoves, rivalRestarts: $rivalRestarts, rivalBoard: $rivalBoard, result: $result, outcome: $outcome)';
}


}

/// @nodoc
abstract mixin class $RaceStateCopyWith<$Res>  {
  factory $RaceStateCopyWith(RaceState value, $Res Function(RaceState) _then) = _$RaceStateCopyWithImpl;
@useResult
$Res call({
 RacePlay request, RacePhase phase, bool held, int totalSets, int rivalSets, RivalActivity activity, int rivalMoves, int rivalRestarts, GameState? rivalBoard, RaceResult? result, RaceWinOutcome? outcome
});


$RaceWinOutcomeCopyWith<$Res>? get outcome;

}
/// @nodoc
class _$RaceStateCopyWithImpl<$Res>
    implements $RaceStateCopyWith<$Res> {
  _$RaceStateCopyWithImpl(this._self, this._then);

  final RaceState _self;
  final $Res Function(RaceState) _then;

/// Create a copy of RaceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? request = freezed,Object? phase = null,Object? held = null,Object? totalSets = null,Object? rivalSets = null,Object? activity = null,Object? rivalMoves = null,Object? rivalRestarts = null,Object? rivalBoard = freezed,Object? result = freezed,Object? outcome = freezed,}) {
  return _then(_self.copyWith(
request: freezed == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as RacePlay,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as RacePhase,held: null == held ? _self.held : held // ignore: cast_nullable_to_non_nullable
as bool,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,rivalSets: null == rivalSets ? _self.rivalSets : rivalSets // ignore: cast_nullable_to_non_nullable
as int,activity: null == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as RivalActivity,rivalMoves: null == rivalMoves ? _self.rivalMoves : rivalMoves // ignore: cast_nullable_to_non_nullable
as int,rivalRestarts: null == rivalRestarts ? _self.rivalRestarts : rivalRestarts // ignore: cast_nullable_to_non_nullable
as int,rivalBoard: freezed == rivalBoard ? _self.rivalBoard : rivalBoard // ignore: cast_nullable_to_non_nullable
as GameState?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as RaceResult?,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as RaceWinOutcome?,
  ));
}
/// Create a copy of RaceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RaceWinOutcomeCopyWith<$Res>? get outcome {
    if (_self.outcome == null) {
    return null;
  }

  return $RaceWinOutcomeCopyWith<$Res>(_self.outcome!, (value) {
    return _then(_self.copyWith(outcome: value));
  });
}
}


/// Adds pattern-matching-related methods to [RaceState].
extension RaceStatePatterns on RaceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RaceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RaceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RaceState value)  $default,){
final _that = this;
switch (_that) {
case _RaceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RaceState value)?  $default,){
final _that = this;
switch (_that) {
case _RaceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RacePlay request,  RacePhase phase,  bool held,  int totalSets,  int rivalSets,  RivalActivity activity,  int rivalMoves,  int rivalRestarts,  GameState? rivalBoard,  RaceResult? result,  RaceWinOutcome? outcome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RaceState() when $default != null:
return $default(_that.request,_that.phase,_that.held,_that.totalSets,_that.rivalSets,_that.activity,_that.rivalMoves,_that.rivalRestarts,_that.rivalBoard,_that.result,_that.outcome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RacePlay request,  RacePhase phase,  bool held,  int totalSets,  int rivalSets,  RivalActivity activity,  int rivalMoves,  int rivalRestarts,  GameState? rivalBoard,  RaceResult? result,  RaceWinOutcome? outcome)  $default,) {final _that = this;
switch (_that) {
case _RaceState():
return $default(_that.request,_that.phase,_that.held,_that.totalSets,_that.rivalSets,_that.activity,_that.rivalMoves,_that.rivalRestarts,_that.rivalBoard,_that.result,_that.outcome);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RacePlay request,  RacePhase phase,  bool held,  int totalSets,  int rivalSets,  RivalActivity activity,  int rivalMoves,  int rivalRestarts,  GameState? rivalBoard,  RaceResult? result,  RaceWinOutcome? outcome)?  $default,) {final _that = this;
switch (_that) {
case _RaceState() when $default != null:
return $default(_that.request,_that.phase,_that.held,_that.totalSets,_that.rivalSets,_that.activity,_that.rivalMoves,_that.rivalRestarts,_that.rivalBoard,_that.result,_that.outcome);case _:
  return null;

}
}

}

/// @nodoc


class _RaceState extends RaceState with DiagnosticableTreeMixin {
  const _RaceState({required this.request, this.phase = RacePhase.waiting, this.held = false, this.totalSets = 0, this.rivalSets = 0, this.activity = RivalActivity.idle, this.rivalMoves = 0, this.rivalRestarts = 0, this.rivalBoard, this.result, this.outcome}): super._();
  

/// The race being played (the rival and its raceNo).
@override final  RacePlay request;
@override@JsonKey() final  RacePhase phase;
/// A [RaceHold] is on: the rival's clock is stopped.
@override@JsonKey() final  bool held;
/// Families on the board (both sides have the same board).
@override@JsonKey() final  int totalSets;
/// Families the rival has completed in its current run (0 again after
/// a restart).
@override@JsonKey() final  int rivalSets;
@override@JsonKey() final  RivalActivity activity;
/// The rival's moves in this race, all runs together: bumped once per
/// rival move, so the strip can play its short "moved" beat (never per
/// frame).
@override@JsonKey() final  int rivalMoves;
/// How many times the rival started over in this race.
@override@JsonKey() final  int rivalRestarts;
/// The rival's board, from its mirrored `GameSession` (a mini board, if
/// Claude Design's frame 9.3 asks for one; tests). Null before the
/// board loads.
@override final  GameState? rivalBoard;
/// Once [phase] is [RacePhase.finished]: who won.
@override final  RaceResult? result;
/// Once the player won: what `SaveService.recordRaceWin` did (the
/// coins, the rival unlocked, the new badges), written exactly once.
@override final  RaceWinOutcome? outcome;

/// Create a copy of RaceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RaceStateCopyWith<_RaceState> get copyWith => __$RaceStateCopyWithImpl<_RaceState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RaceState'))
    ..add(DiagnosticsProperty('request', request))..add(DiagnosticsProperty('phase', phase))..add(DiagnosticsProperty('held', held))..add(DiagnosticsProperty('totalSets', totalSets))..add(DiagnosticsProperty('rivalSets', rivalSets))..add(DiagnosticsProperty('activity', activity))..add(DiagnosticsProperty('rivalMoves', rivalMoves))..add(DiagnosticsProperty('rivalRestarts', rivalRestarts))..add(DiagnosticsProperty('rivalBoard', rivalBoard))..add(DiagnosticsProperty('result', result))..add(DiagnosticsProperty('outcome', outcome));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RaceState&&const DeepCollectionEquality().equals(other.request, request)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.held, held) || other.held == held)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.rivalSets, rivalSets) || other.rivalSets == rivalSets)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.rivalMoves, rivalMoves) || other.rivalMoves == rivalMoves)&&(identical(other.rivalRestarts, rivalRestarts) || other.rivalRestarts == rivalRestarts)&&(identical(other.rivalBoard, rivalBoard) || other.rivalBoard == rivalBoard)&&(identical(other.result, result) || other.result == result)&&(identical(other.outcome, outcome) || other.outcome == outcome));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(request),phase,held,totalSets,rivalSets,activity,rivalMoves,rivalRestarts,rivalBoard,result,outcome);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RaceState(request: $request, phase: $phase, held: $held, totalSets: $totalSets, rivalSets: $rivalSets, activity: $activity, rivalMoves: $rivalMoves, rivalRestarts: $rivalRestarts, rivalBoard: $rivalBoard, result: $result, outcome: $outcome)';
}


}

/// @nodoc
abstract mixin class _$RaceStateCopyWith<$Res> implements $RaceStateCopyWith<$Res> {
  factory _$RaceStateCopyWith(_RaceState value, $Res Function(_RaceState) _then) = __$RaceStateCopyWithImpl;
@override @useResult
$Res call({
 RacePlay request, RacePhase phase, bool held, int totalSets, int rivalSets, RivalActivity activity, int rivalMoves, int rivalRestarts, GameState? rivalBoard, RaceResult? result, RaceWinOutcome? outcome
});


@override $RaceWinOutcomeCopyWith<$Res>? get outcome;

}
/// @nodoc
class __$RaceStateCopyWithImpl<$Res>
    implements _$RaceStateCopyWith<$Res> {
  __$RaceStateCopyWithImpl(this._self, this._then);

  final _RaceState _self;
  final $Res Function(_RaceState) _then;

/// Create a copy of RaceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? request = freezed,Object? phase = null,Object? held = null,Object? totalSets = null,Object? rivalSets = null,Object? activity = null,Object? rivalMoves = null,Object? rivalRestarts = null,Object? rivalBoard = freezed,Object? result = freezed,Object? outcome = freezed,}) {
  return _then(_RaceState(
request: freezed == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as RacePlay,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as RacePhase,held: null == held ? _self.held : held // ignore: cast_nullable_to_non_nullable
as bool,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,rivalSets: null == rivalSets ? _self.rivalSets : rivalSets // ignore: cast_nullable_to_non_nullable
as int,activity: null == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as RivalActivity,rivalMoves: null == rivalMoves ? _self.rivalMoves : rivalMoves // ignore: cast_nullable_to_non_nullable
as int,rivalRestarts: null == rivalRestarts ? _self.rivalRestarts : rivalRestarts // ignore: cast_nullable_to_non_nullable
as int,rivalBoard: freezed == rivalBoard ? _self.rivalBoard : rivalBoard // ignore: cast_nullable_to_non_nullable
as GameState?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as RaceResult?,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as RaceWinOutcome?,
  ));
}

/// Create a copy of RaceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RaceWinOutcomeCopyWith<$Res>? get outcome {
    if (_self.outcome == null) {
    return null;
  }

  return $RaceWinOutcomeCopyWith<$Res>(_self.outcome!, (value) {
    return _then(_self.copyWith(outcome: value));
  });
}
}

// dart format on
