// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gameplay_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameplayState implements DiagnosticableTreeMixin {

/// The level and its play metadata (order, chapter, tier, reward).
 LevelBundleEntry get entry;/// The board after the last transition: nesty_core's truth.
 GameState get board;/// The lifted nest's slot, if any.
 String? get selectedSlotId; GameplayStatus get status; bool get paused;/// Frame 3.4's banner and the glowing Undo: the solver proved the board
/// unsolvable. Cleared by the next board change.
 bool get softStuck;/// The hint on screen (frame 3.1), cleared by any tap and any board
/// reset.
 Move? get hint;/// Undos left before undo costs coins (`SaveService.freeUndosPerLevel`,
/// Remote Config `free_undos_per_level`, spec §7.3). Per level: a
/// restart keeps the count (D22, `GameSession.undosUsed`).
 int get freeUndosLeft;/// Hint boosters in the inventory (spec §8), for the booster badge.
 int get hintsLeft;/// Extra-slot boosters in the inventory (spec §8), for the booster
/// badge. The level's own limit of 2 is in [canAddSlot].
 int get extraSlotsLeft;/// Undo is usable: a move to undo and a free undo left (or
/// [unlimitedBoosters]). The coin path is M3 (frame 3.2).
 bool get canUndo;/// +1 Slot is usable: fewer than 2 added to this level and a booster in
/// the inventory (or free in this build).
 bool get canAddSlot;/// Hint is usable: a booster in the inventory (or
/// [unlimitedBoosters]). The coin path is M3 (frame 3.3).
 bool get canHint;/// The dev flavor (`SaveService.unlimitedBoosters`): boosters never run
/// out, so the badges may show no count.
 bool get unlimitedBoosters;/// The player's coins (the HUD coin pill, spec §7.3).
 int get coins;/// Coins the win paid (the win overlay's "+N"); 0 until [status] is
/// [GameplayStatus.won].
 int get winReward;/// Bumped by every board change: an applied move, undo, restart, +1
/// Slot and a new level. Solver results asked for an older value are
/// stale.
 int get moveSeq;/// Bumped with every new [effect].
 int get effectSeq;/// What the board must play for the latest transition.
 BoardEffect? get effect;
/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameplayStateCopyWith<GameplayState> get copyWith => _$GameplayStateCopyWithImpl<GameplayState>(this as GameplayState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'GameplayState'))
    ..add(DiagnosticsProperty('entry', entry))..add(DiagnosticsProperty('board', board))..add(DiagnosticsProperty('selectedSlotId', selectedSlotId))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('paused', paused))..add(DiagnosticsProperty('softStuck', softStuck))..add(DiagnosticsProperty('hint', hint))..add(DiagnosticsProperty('freeUndosLeft', freeUndosLeft))..add(DiagnosticsProperty('hintsLeft', hintsLeft))..add(DiagnosticsProperty('extraSlotsLeft', extraSlotsLeft))..add(DiagnosticsProperty('canUndo', canUndo))..add(DiagnosticsProperty('canAddSlot', canAddSlot))..add(DiagnosticsProperty('canHint', canHint))..add(DiagnosticsProperty('unlimitedBoosters', unlimitedBoosters))..add(DiagnosticsProperty('coins', coins))..add(DiagnosticsProperty('winReward', winReward))..add(DiagnosticsProperty('moveSeq', moveSeq))..add(DiagnosticsProperty('effectSeq', effectSeq))..add(DiagnosticsProperty('effect', effect));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameplayState&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.board, board) || other.board == board)&&(identical(other.selectedSlotId, selectedSlotId) || other.selectedSlotId == selectedSlotId)&&(identical(other.status, status) || other.status == status)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.softStuck, softStuck) || other.softStuck == softStuck)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.freeUndosLeft, freeUndosLeft) || other.freeUndosLeft == freeUndosLeft)&&(identical(other.hintsLeft, hintsLeft) || other.hintsLeft == hintsLeft)&&(identical(other.extraSlotsLeft, extraSlotsLeft) || other.extraSlotsLeft == extraSlotsLeft)&&(identical(other.canUndo, canUndo) || other.canUndo == canUndo)&&(identical(other.canAddSlot, canAddSlot) || other.canAddSlot == canAddSlot)&&(identical(other.canHint, canHint) || other.canHint == canHint)&&(identical(other.unlimitedBoosters, unlimitedBoosters) || other.unlimitedBoosters == unlimitedBoosters)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.winReward, winReward) || other.winReward == winReward)&&(identical(other.moveSeq, moveSeq) || other.moveSeq == moveSeq)&&(identical(other.effectSeq, effectSeq) || other.effectSeq == effectSeq)&&(identical(other.effect, effect) || other.effect == effect));
}


@override
int get hashCode => Object.hashAll([runtimeType,entry,board,selectedSlotId,status,paused,softStuck,hint,freeUndosLeft,hintsLeft,extraSlotsLeft,canUndo,canAddSlot,canHint,unlimitedBoosters,coins,winReward,moveSeq,effectSeq,effect]);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'GameplayState(entry: $entry, board: $board, selectedSlotId: $selectedSlotId, status: $status, paused: $paused, softStuck: $softStuck, hint: $hint, freeUndosLeft: $freeUndosLeft, hintsLeft: $hintsLeft, extraSlotsLeft: $extraSlotsLeft, canUndo: $canUndo, canAddSlot: $canAddSlot, canHint: $canHint, unlimitedBoosters: $unlimitedBoosters, coins: $coins, winReward: $winReward, moveSeq: $moveSeq, effectSeq: $effectSeq, effect: $effect)';
}


}

/// @nodoc
abstract mixin class $GameplayStateCopyWith<$Res>  {
  factory $GameplayStateCopyWith(GameplayState value, $Res Function(GameplayState) _then) = _$GameplayStateCopyWithImpl;
@useResult
$Res call({
 LevelBundleEntry entry, GameState board, String? selectedSlotId, GameplayStatus status, bool paused, bool softStuck, Move? hint, int freeUndosLeft, int hintsLeft, int extraSlotsLeft, bool canUndo, bool canAddSlot, bool canHint, bool unlimitedBoosters, int coins, int winReward, int moveSeq, int effectSeq, BoardEffect? effect
});




}
/// @nodoc
class _$GameplayStateCopyWithImpl<$Res>
    implements $GameplayStateCopyWith<$Res> {
  _$GameplayStateCopyWithImpl(this._self, this._then);

  final GameplayState _self;
  final $Res Function(GameplayState) _then;

/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entry = null,Object? board = null,Object? selectedSlotId = freezed,Object? status = null,Object? paused = null,Object? softStuck = null,Object? hint = freezed,Object? freeUndosLeft = null,Object? hintsLeft = null,Object? extraSlotsLeft = null,Object? canUndo = null,Object? canAddSlot = null,Object? canHint = null,Object? unlimitedBoosters = null,Object? coins = null,Object? winReward = null,Object? moveSeq = null,Object? effectSeq = null,Object? effect = freezed,}) {
  return _then(_self.copyWith(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as LevelBundleEntry,board: null == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as GameState,selectedSlotId: freezed == selectedSlotId ? _self.selectedSlotId : selectedSlotId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameplayStatus,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,softStuck: null == softStuck ? _self.softStuck : softStuck // ignore: cast_nullable_to_non_nullable
as bool,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as Move?,freeUndosLeft: null == freeUndosLeft ? _self.freeUndosLeft : freeUndosLeft // ignore: cast_nullable_to_non_nullable
as int,hintsLeft: null == hintsLeft ? _self.hintsLeft : hintsLeft // ignore: cast_nullable_to_non_nullable
as int,extraSlotsLeft: null == extraSlotsLeft ? _self.extraSlotsLeft : extraSlotsLeft // ignore: cast_nullable_to_non_nullable
as int,canUndo: null == canUndo ? _self.canUndo : canUndo // ignore: cast_nullable_to_non_nullable
as bool,canAddSlot: null == canAddSlot ? _self.canAddSlot : canAddSlot // ignore: cast_nullable_to_non_nullable
as bool,canHint: null == canHint ? _self.canHint : canHint // ignore: cast_nullable_to_non_nullable
as bool,unlimitedBoosters: null == unlimitedBoosters ? _self.unlimitedBoosters : unlimitedBoosters // ignore: cast_nullable_to_non_nullable
as bool,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,winReward: null == winReward ? _self.winReward : winReward // ignore: cast_nullable_to_non_nullable
as int,moveSeq: null == moveSeq ? _self.moveSeq : moveSeq // ignore: cast_nullable_to_non_nullable
as int,effectSeq: null == effectSeq ? _self.effectSeq : effectSeq // ignore: cast_nullable_to_non_nullable
as int,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as BoardEffect?,
  ));
}

}


/// Adds pattern-matching-related methods to [GameplayState].
extension GameplayStatePatterns on GameplayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameplayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameplayState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameplayState value)  $default,){
final _that = this;
switch (_that) {
case _GameplayState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameplayState value)?  $default,){
final _that = this;
switch (_that) {
case _GameplayState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LevelBundleEntry entry,  GameState board,  String? selectedSlotId,  GameplayStatus status,  bool paused,  bool softStuck,  Move? hint,  int freeUndosLeft,  int hintsLeft,  int extraSlotsLeft,  bool canUndo,  bool canAddSlot,  bool canHint,  bool unlimitedBoosters,  int coins,  int winReward,  int moveSeq,  int effectSeq,  BoardEffect? effect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameplayState() when $default != null:
return $default(_that.entry,_that.board,_that.selectedSlotId,_that.status,_that.paused,_that.softStuck,_that.hint,_that.freeUndosLeft,_that.hintsLeft,_that.extraSlotsLeft,_that.canUndo,_that.canAddSlot,_that.canHint,_that.unlimitedBoosters,_that.coins,_that.winReward,_that.moveSeq,_that.effectSeq,_that.effect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LevelBundleEntry entry,  GameState board,  String? selectedSlotId,  GameplayStatus status,  bool paused,  bool softStuck,  Move? hint,  int freeUndosLeft,  int hintsLeft,  int extraSlotsLeft,  bool canUndo,  bool canAddSlot,  bool canHint,  bool unlimitedBoosters,  int coins,  int winReward,  int moveSeq,  int effectSeq,  BoardEffect? effect)  $default,) {final _that = this;
switch (_that) {
case _GameplayState():
return $default(_that.entry,_that.board,_that.selectedSlotId,_that.status,_that.paused,_that.softStuck,_that.hint,_that.freeUndosLeft,_that.hintsLeft,_that.extraSlotsLeft,_that.canUndo,_that.canAddSlot,_that.canHint,_that.unlimitedBoosters,_that.coins,_that.winReward,_that.moveSeq,_that.effectSeq,_that.effect);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LevelBundleEntry entry,  GameState board,  String? selectedSlotId,  GameplayStatus status,  bool paused,  bool softStuck,  Move? hint,  int freeUndosLeft,  int hintsLeft,  int extraSlotsLeft,  bool canUndo,  bool canAddSlot,  bool canHint,  bool unlimitedBoosters,  int coins,  int winReward,  int moveSeq,  int effectSeq,  BoardEffect? effect)?  $default,) {final _that = this;
switch (_that) {
case _GameplayState() when $default != null:
return $default(_that.entry,_that.board,_that.selectedSlotId,_that.status,_that.paused,_that.softStuck,_that.hint,_that.freeUndosLeft,_that.hintsLeft,_that.extraSlotsLeft,_that.canUndo,_that.canAddSlot,_that.canHint,_that.unlimitedBoosters,_that.coins,_that.winReward,_that.moveSeq,_that.effectSeq,_that.effect);case _:
  return null;

}
}

}

/// @nodoc


class _GameplayState extends GameplayState with DiagnosticableTreeMixin {
  const _GameplayState({required this.entry, required this.board, this.selectedSlotId, this.status = GameplayStatus.playing, this.paused = false, this.softStuck = false, this.hint, this.freeUndosLeft = 0, this.hintsLeft = 0, this.extraSlotsLeft = 0, this.canUndo = false, this.canAddSlot = false, this.canHint = false, this.unlimitedBoosters = false, this.coins = 0, this.winReward = 0, this.moveSeq = 0, this.effectSeq = 0, this.effect}): super._();
  

/// The level and its play metadata (order, chapter, tier, reward).
@override final  LevelBundleEntry entry;
/// The board after the last transition: nesty_core's truth.
@override final  GameState board;
/// The lifted nest's slot, if any.
@override final  String? selectedSlotId;
@override@JsonKey() final  GameplayStatus status;
@override@JsonKey() final  bool paused;
/// Frame 3.4's banner and the glowing Undo: the solver proved the board
/// unsolvable. Cleared by the next board change.
@override@JsonKey() final  bool softStuck;
/// The hint on screen (frame 3.1), cleared by any tap and any board
/// reset.
@override final  Move? hint;
/// Undos left before undo costs coins (`SaveService.freeUndosPerLevel`,
/// Remote Config `free_undos_per_level`, spec §7.3). Per level: a
/// restart keeps the count (D22, `GameSession.undosUsed`).
@override@JsonKey() final  int freeUndosLeft;
/// Hint boosters in the inventory (spec §8), for the booster badge.
@override@JsonKey() final  int hintsLeft;
/// Extra-slot boosters in the inventory (spec §8), for the booster
/// badge. The level's own limit of 2 is in [canAddSlot].
@override@JsonKey() final  int extraSlotsLeft;
/// Undo is usable: a move to undo and a free undo left (or
/// [unlimitedBoosters]). The coin path is M3 (frame 3.2).
@override@JsonKey() final  bool canUndo;
/// +1 Slot is usable: fewer than 2 added to this level and a booster in
/// the inventory (or free in this build).
@override@JsonKey() final  bool canAddSlot;
/// Hint is usable: a booster in the inventory (or
/// [unlimitedBoosters]). The coin path is M3 (frame 3.3).
@override@JsonKey() final  bool canHint;
/// The dev flavor (`SaveService.unlimitedBoosters`): boosters never run
/// out, so the badges may show no count.
@override@JsonKey() final  bool unlimitedBoosters;
/// The player's coins (the HUD coin pill, spec §7.3).
@override@JsonKey() final  int coins;
/// Coins the win paid (the win overlay's "+N"); 0 until [status] is
/// [GameplayStatus.won].
@override@JsonKey() final  int winReward;
/// Bumped by every board change: an applied move, undo, restart, +1
/// Slot and a new level. Solver results asked for an older value are
/// stale.
@override@JsonKey() final  int moveSeq;
/// Bumped with every new [effect].
@override@JsonKey() final  int effectSeq;
/// What the board must play for the latest transition.
@override final  BoardEffect? effect;

/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameplayStateCopyWith<_GameplayState> get copyWith => __$GameplayStateCopyWithImpl<_GameplayState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'GameplayState'))
    ..add(DiagnosticsProperty('entry', entry))..add(DiagnosticsProperty('board', board))..add(DiagnosticsProperty('selectedSlotId', selectedSlotId))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('paused', paused))..add(DiagnosticsProperty('softStuck', softStuck))..add(DiagnosticsProperty('hint', hint))..add(DiagnosticsProperty('freeUndosLeft', freeUndosLeft))..add(DiagnosticsProperty('hintsLeft', hintsLeft))..add(DiagnosticsProperty('extraSlotsLeft', extraSlotsLeft))..add(DiagnosticsProperty('canUndo', canUndo))..add(DiagnosticsProperty('canAddSlot', canAddSlot))..add(DiagnosticsProperty('canHint', canHint))..add(DiagnosticsProperty('unlimitedBoosters', unlimitedBoosters))..add(DiagnosticsProperty('coins', coins))..add(DiagnosticsProperty('winReward', winReward))..add(DiagnosticsProperty('moveSeq', moveSeq))..add(DiagnosticsProperty('effectSeq', effectSeq))..add(DiagnosticsProperty('effect', effect));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameplayState&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.board, board) || other.board == board)&&(identical(other.selectedSlotId, selectedSlotId) || other.selectedSlotId == selectedSlotId)&&(identical(other.status, status) || other.status == status)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.softStuck, softStuck) || other.softStuck == softStuck)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.freeUndosLeft, freeUndosLeft) || other.freeUndosLeft == freeUndosLeft)&&(identical(other.hintsLeft, hintsLeft) || other.hintsLeft == hintsLeft)&&(identical(other.extraSlotsLeft, extraSlotsLeft) || other.extraSlotsLeft == extraSlotsLeft)&&(identical(other.canUndo, canUndo) || other.canUndo == canUndo)&&(identical(other.canAddSlot, canAddSlot) || other.canAddSlot == canAddSlot)&&(identical(other.canHint, canHint) || other.canHint == canHint)&&(identical(other.unlimitedBoosters, unlimitedBoosters) || other.unlimitedBoosters == unlimitedBoosters)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.winReward, winReward) || other.winReward == winReward)&&(identical(other.moveSeq, moveSeq) || other.moveSeq == moveSeq)&&(identical(other.effectSeq, effectSeq) || other.effectSeq == effectSeq)&&(identical(other.effect, effect) || other.effect == effect));
}


@override
int get hashCode => Object.hashAll([runtimeType,entry,board,selectedSlotId,status,paused,softStuck,hint,freeUndosLeft,hintsLeft,extraSlotsLeft,canUndo,canAddSlot,canHint,unlimitedBoosters,coins,winReward,moveSeq,effectSeq,effect]);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'GameplayState(entry: $entry, board: $board, selectedSlotId: $selectedSlotId, status: $status, paused: $paused, softStuck: $softStuck, hint: $hint, freeUndosLeft: $freeUndosLeft, hintsLeft: $hintsLeft, extraSlotsLeft: $extraSlotsLeft, canUndo: $canUndo, canAddSlot: $canAddSlot, canHint: $canHint, unlimitedBoosters: $unlimitedBoosters, coins: $coins, winReward: $winReward, moveSeq: $moveSeq, effectSeq: $effectSeq, effect: $effect)';
}


}

/// @nodoc
abstract mixin class _$GameplayStateCopyWith<$Res> implements $GameplayStateCopyWith<$Res> {
  factory _$GameplayStateCopyWith(_GameplayState value, $Res Function(_GameplayState) _then) = __$GameplayStateCopyWithImpl;
@override @useResult
$Res call({
 LevelBundleEntry entry, GameState board, String? selectedSlotId, GameplayStatus status, bool paused, bool softStuck, Move? hint, int freeUndosLeft, int hintsLeft, int extraSlotsLeft, bool canUndo, bool canAddSlot, bool canHint, bool unlimitedBoosters, int coins, int winReward, int moveSeq, int effectSeq, BoardEffect? effect
});




}
/// @nodoc
class __$GameplayStateCopyWithImpl<$Res>
    implements _$GameplayStateCopyWith<$Res> {
  __$GameplayStateCopyWithImpl(this._self, this._then);

  final _GameplayState _self;
  final $Res Function(_GameplayState) _then;

/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entry = null,Object? board = null,Object? selectedSlotId = freezed,Object? status = null,Object? paused = null,Object? softStuck = null,Object? hint = freezed,Object? freeUndosLeft = null,Object? hintsLeft = null,Object? extraSlotsLeft = null,Object? canUndo = null,Object? canAddSlot = null,Object? canHint = null,Object? unlimitedBoosters = null,Object? coins = null,Object? winReward = null,Object? moveSeq = null,Object? effectSeq = null,Object? effect = freezed,}) {
  return _then(_GameplayState(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as LevelBundleEntry,board: null == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as GameState,selectedSlotId: freezed == selectedSlotId ? _self.selectedSlotId : selectedSlotId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameplayStatus,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,softStuck: null == softStuck ? _self.softStuck : softStuck // ignore: cast_nullable_to_non_nullable
as bool,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as Move?,freeUndosLeft: null == freeUndosLeft ? _self.freeUndosLeft : freeUndosLeft // ignore: cast_nullable_to_non_nullable
as int,hintsLeft: null == hintsLeft ? _self.hintsLeft : hintsLeft // ignore: cast_nullable_to_non_nullable
as int,extraSlotsLeft: null == extraSlotsLeft ? _self.extraSlotsLeft : extraSlotsLeft // ignore: cast_nullable_to_non_nullable
as int,canUndo: null == canUndo ? _self.canUndo : canUndo // ignore: cast_nullable_to_non_nullable
as bool,canAddSlot: null == canAddSlot ? _self.canAddSlot : canAddSlot // ignore: cast_nullable_to_non_nullable
as bool,canHint: null == canHint ? _self.canHint : canHint // ignore: cast_nullable_to_non_nullable
as bool,unlimitedBoosters: null == unlimitedBoosters ? _self.unlimitedBoosters : unlimitedBoosters // ignore: cast_nullable_to_non_nullable
as bool,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,winReward: null == winReward ? _self.winReward : winReward // ignore: cast_nullable_to_non_nullable
as int,moveSeq: null == moveSeq ? _self.moveSeq : moveSeq // ignore: cast_nullable_to_non_nullable
as int,effectSeq: null == effectSeq ? _self.effectSeq : effectSeq // ignore: cast_nullable_to_non_nullable
as int,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as BoardEffect?,
  ));
}


}

// dart format on
