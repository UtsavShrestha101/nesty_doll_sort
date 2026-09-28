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
mixin _$BoosterOffer implements DiagnosticableTreeMixin {

 BoosterType get type;/// `price_undo`, `price_hint` or `price_slot` (spec §7.3, §9.4).
 int get price;
/// Create a copy of BoosterOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoosterOfferCopyWith<BoosterOffer> get copyWith => _$BoosterOfferCopyWithImpl<BoosterOffer>(this as BoosterOffer, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'BoosterOffer'))
    ..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('price', price));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoosterOffer&&(identical(other.type, type) || other.type == type)&&(identical(other.price, price) || other.price == price));
}


@override
int get hashCode => Object.hash(runtimeType,type,price);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'BoosterOffer(type: $type, price: $price)';
}


}

/// @nodoc
abstract mixin class $BoosterOfferCopyWith<$Res>  {
  factory $BoosterOfferCopyWith(BoosterOffer value, $Res Function(BoosterOffer) _then) = _$BoosterOfferCopyWithImpl;
@useResult
$Res call({
 BoosterType type, int price
});




}
/// @nodoc
class _$BoosterOfferCopyWithImpl<$Res>
    implements $BoosterOfferCopyWith<$Res> {
  _$BoosterOfferCopyWithImpl(this._self, this._then);

  final BoosterOffer _self;
  final $Res Function(BoosterOffer) _then;

/// Create a copy of BoosterOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? price = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BoosterType,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BoosterOffer].
extension BoosterOfferPatterns on BoosterOffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoosterOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoosterOffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoosterOffer value)  $default,){
final _that = this;
switch (_that) {
case _BoosterOffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoosterOffer value)?  $default,){
final _that = this;
switch (_that) {
case _BoosterOffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BoosterType type,  int price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoosterOffer() when $default != null:
return $default(_that.type,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BoosterType type,  int price)  $default,) {final _that = this;
switch (_that) {
case _BoosterOffer():
return $default(_that.type,_that.price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BoosterType type,  int price)?  $default,) {final _that = this;
switch (_that) {
case _BoosterOffer() when $default != null:
return $default(_that.type,_that.price);case _:
  return null;

}
}

}

/// @nodoc


class _BoosterOffer with DiagnosticableTreeMixin implements BoosterOffer {
  const _BoosterOffer({required this.type, required this.price});
  

@override final  BoosterType type;
/// `price_undo`, `price_hint` or `price_slot` (spec §7.3, §9.4).
@override final  int price;

/// Create a copy of BoosterOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoosterOfferCopyWith<_BoosterOffer> get copyWith => __$BoosterOfferCopyWithImpl<_BoosterOffer>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'BoosterOffer'))
    ..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('price', price));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoosterOffer&&(identical(other.type, type) || other.type == type)&&(identical(other.price, price) || other.price == price));
}


@override
int get hashCode => Object.hash(runtimeType,type,price);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'BoosterOffer(type: $type, price: $price)';
}


}

/// @nodoc
abstract mixin class _$BoosterOfferCopyWith<$Res> implements $BoosterOfferCopyWith<$Res> {
  factory _$BoosterOfferCopyWith(_BoosterOffer value, $Res Function(_BoosterOffer) _then) = __$BoosterOfferCopyWithImpl;
@override @useResult
$Res call({
 BoosterType type, int price
});




}
/// @nodoc
class __$BoosterOfferCopyWithImpl<$Res>
    implements _$BoosterOfferCopyWith<$Res> {
  __$BoosterOfferCopyWithImpl(this._self, this._then);

  final _BoosterOffer _self;
  final $Res Function(_BoosterOffer) _then;

/// Create a copy of BoosterOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? price = null,}) {
  return _then(_BoosterOffer(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BoosterType,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$TutorialCue implements DiagnosticableTreeMixin {

/// 1–4: L1 tap the small doll, L1 tap the big one, L1 finish the family
/// (no frame: `TODO(design)`), L2 the swallow. The tooltip copy and
/// `tutorial_step{step}` follow it.
 int get step; TutorialCueKind get kind;/// The scripted move.
 String get from; String get to;
/// Create a copy of TutorialCue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorialCueCopyWith<TutorialCue> get copyWith => _$TutorialCueCopyWithImpl<TutorialCue>(this as TutorialCue, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TutorialCue'))
    ..add(DiagnosticsProperty('step', step))..add(DiagnosticsProperty('kind', kind))..add(DiagnosticsProperty('from', from))..add(DiagnosticsProperty('to', to));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorialCue&&(identical(other.step, step) || other.step == step)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,step,kind,from,to);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TutorialCue(step: $step, kind: $kind, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $TutorialCueCopyWith<$Res>  {
  factory $TutorialCueCopyWith(TutorialCue value, $Res Function(TutorialCue) _then) = _$TutorialCueCopyWithImpl;
@useResult
$Res call({
 int step, TutorialCueKind kind, String from, String to
});




}
/// @nodoc
class _$TutorialCueCopyWithImpl<$Res>
    implements $TutorialCueCopyWith<$Res> {
  _$TutorialCueCopyWithImpl(this._self, this._then);

  final TutorialCue _self;
  final $Res Function(TutorialCue) _then;

/// Create a copy of TutorialCue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? kind = null,Object? from = null,Object? to = null,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TutorialCueKind,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TutorialCue].
extension TutorialCuePatterns on TutorialCue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TutorialCue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TutorialCue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TutorialCue value)  $default,){
final _that = this;
switch (_that) {
case _TutorialCue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TutorialCue value)?  $default,){
final _that = this;
switch (_that) {
case _TutorialCue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int step,  TutorialCueKind kind,  String from,  String to)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TutorialCue() when $default != null:
return $default(_that.step,_that.kind,_that.from,_that.to);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int step,  TutorialCueKind kind,  String from,  String to)  $default,) {final _that = this;
switch (_that) {
case _TutorialCue():
return $default(_that.step,_that.kind,_that.from,_that.to);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int step,  TutorialCueKind kind,  String from,  String to)?  $default,) {final _that = this;
switch (_that) {
case _TutorialCue() when $default != null:
return $default(_that.step,_that.kind,_that.from,_that.to);case _:
  return null;

}
}

}

/// @nodoc


class _TutorialCue with DiagnosticableTreeMixin implements TutorialCue {
  const _TutorialCue({required this.step, required this.kind, required this.from, required this.to});
  

/// 1–4: L1 tap the small doll, L1 tap the big one, L1 finish the family
/// (no frame: `TODO(design)`), L2 the swallow. The tooltip copy and
/// `tutorial_step{step}` follow it.
@override final  int step;
@override final  TutorialCueKind kind;
/// The scripted move.
@override final  String from;
@override final  String to;

/// Create a copy of TutorialCue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TutorialCueCopyWith<_TutorialCue> get copyWith => __$TutorialCueCopyWithImpl<_TutorialCue>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TutorialCue'))
    ..add(DiagnosticsProperty('step', step))..add(DiagnosticsProperty('kind', kind))..add(DiagnosticsProperty('from', from))..add(DiagnosticsProperty('to', to));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TutorialCue&&(identical(other.step, step) || other.step == step)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,step,kind,from,to);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TutorialCue(step: $step, kind: $kind, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class _$TutorialCueCopyWith<$Res> implements $TutorialCueCopyWith<$Res> {
  factory _$TutorialCueCopyWith(_TutorialCue value, $Res Function(_TutorialCue) _then) = __$TutorialCueCopyWithImpl;
@override @useResult
$Res call({
 int step, TutorialCueKind kind, String from, String to
});




}
/// @nodoc
class __$TutorialCueCopyWithImpl<$Res>
    implements _$TutorialCueCopyWith<$Res> {
  __$TutorialCueCopyWithImpl(this._self, this._then);

  final _TutorialCue _self;
  final $Res Function(_TutorialCue) _then;

/// Create a copy of TutorialCue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? kind = null,Object? from = null,Object? to = null,}) {
  return _then(_TutorialCue(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TutorialCueKind,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GameplayState implements DiagnosticableTreeMixin {

/// What is being played and how it pays (m3-design §6.2).
 PlayEntry get play;/// The level and its play metadata (order, chapter, tier, reward): the
/// bundle entry of a campaign level, or a stand-in for a generated one
/// (order `levelCount + n` for Bonus Level n, the date for the daily;
/// its theme as the chapter). The M2 widgets read it; new code reads
/// [play].
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
 int get extraSlotsLeft;/// Undo does something: a move to undo, free (or [unlimitedBoosters]),
/// from the inventory, or via the coin offer (frame 3.2, m3-design
/// §7.3). False only when there is nothing to undo.
 bool get canUndo;/// +1 Slot does something: fewer than 2 added to this level, free (or
/// [unlimitedBoosters]), from the inventory, or via the coin offer.
/// False only when the level's own limit is reached.
 bool get canAddSlot;/// Hint does something: free (or [unlimitedBoosters]), from the
/// inventory, or via the coin offer (frame 3.3, m3-design §7.3).
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
 BoardEffect? get effect;/// The purchase popup (frames 3.2, 3.3; m3-design §7.3).
 BoosterOffer? get offer;/// The coin prices a booster shows and costs once its free uses or the
/// inventory are gone (Remote Config `price_undo`, `price_hint`,
/// `price_slot`; frames 3.2, 3.3, 3.5 badges and rows; m3-design §7.3).
 int get undoPrice; int get hintPrice; int get slotPrice;/// The tutorial step on screen (frames 1.3, 1.4, 1.6; m3-design §10.4).
 TutorialCue? get tutorial;/// The intro card on screen (frames 4.1–4.3; m3-design §10.4). Input
/// is locked under it until `IntroDismissed`.
 IntroMechanic? get intro;/// Once won: the chapter this win completed and collected (frame 4.6).
 String? get completedChapterId;/// Once won: the `reward_chapter` coins it paid (4.6 "+150 coins").
 int get chapterReward;/// Once a daily is won: the streak after the solve (frame 5.4).
 int? get dailyStreak;/// Once won: what Continue plays (`LevelResolver.next`). The page
/// prefetches its art; a bonus request after a campaign level shows All
/// Levels Done first (frame 4.9); null after a daily ("Back to Daily").
 PlayRequest? get nextRequest;/// The board came back from the in-progress save (m3-design §3.4).
 bool get restored;
/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameplayStateCopyWith<GameplayState> get copyWith => _$GameplayStateCopyWithImpl<GameplayState>(this as GameplayState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'GameplayState'))
    ..add(DiagnosticsProperty('play', play))..add(DiagnosticsProperty('entry', entry))..add(DiagnosticsProperty('board', board))..add(DiagnosticsProperty('selectedSlotId', selectedSlotId))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('paused', paused))..add(DiagnosticsProperty('softStuck', softStuck))..add(DiagnosticsProperty('hint', hint))..add(DiagnosticsProperty('freeUndosLeft', freeUndosLeft))..add(DiagnosticsProperty('hintsLeft', hintsLeft))..add(DiagnosticsProperty('extraSlotsLeft', extraSlotsLeft))..add(DiagnosticsProperty('canUndo', canUndo))..add(DiagnosticsProperty('canAddSlot', canAddSlot))..add(DiagnosticsProperty('canHint', canHint))..add(DiagnosticsProperty('unlimitedBoosters', unlimitedBoosters))..add(DiagnosticsProperty('coins', coins))..add(DiagnosticsProperty('winReward', winReward))..add(DiagnosticsProperty('moveSeq', moveSeq))..add(DiagnosticsProperty('effectSeq', effectSeq))..add(DiagnosticsProperty('effect', effect))..add(DiagnosticsProperty('offer', offer))..add(DiagnosticsProperty('undoPrice', undoPrice))..add(DiagnosticsProperty('hintPrice', hintPrice))..add(DiagnosticsProperty('slotPrice', slotPrice))..add(DiagnosticsProperty('tutorial', tutorial))..add(DiagnosticsProperty('intro', intro))..add(DiagnosticsProperty('completedChapterId', completedChapterId))..add(DiagnosticsProperty('chapterReward', chapterReward))..add(DiagnosticsProperty('dailyStreak', dailyStreak))..add(DiagnosticsProperty('nextRequest', nextRequest))..add(DiagnosticsProperty('restored', restored));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameplayState&&(identical(other.play, play) || other.play == play)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.board, board) || other.board == board)&&(identical(other.selectedSlotId, selectedSlotId) || other.selectedSlotId == selectedSlotId)&&(identical(other.status, status) || other.status == status)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.softStuck, softStuck) || other.softStuck == softStuck)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.freeUndosLeft, freeUndosLeft) || other.freeUndosLeft == freeUndosLeft)&&(identical(other.hintsLeft, hintsLeft) || other.hintsLeft == hintsLeft)&&(identical(other.extraSlotsLeft, extraSlotsLeft) || other.extraSlotsLeft == extraSlotsLeft)&&(identical(other.canUndo, canUndo) || other.canUndo == canUndo)&&(identical(other.canAddSlot, canAddSlot) || other.canAddSlot == canAddSlot)&&(identical(other.canHint, canHint) || other.canHint == canHint)&&(identical(other.unlimitedBoosters, unlimitedBoosters) || other.unlimitedBoosters == unlimitedBoosters)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.winReward, winReward) || other.winReward == winReward)&&(identical(other.moveSeq, moveSeq) || other.moveSeq == moveSeq)&&(identical(other.effectSeq, effectSeq) || other.effectSeq == effectSeq)&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.undoPrice, undoPrice) || other.undoPrice == undoPrice)&&(identical(other.hintPrice, hintPrice) || other.hintPrice == hintPrice)&&(identical(other.slotPrice, slotPrice) || other.slotPrice == slotPrice)&&(identical(other.tutorial, tutorial) || other.tutorial == tutorial)&&(identical(other.intro, intro) || other.intro == intro)&&(identical(other.completedChapterId, completedChapterId) || other.completedChapterId == completedChapterId)&&(identical(other.chapterReward, chapterReward) || other.chapterReward == chapterReward)&&(identical(other.dailyStreak, dailyStreak) || other.dailyStreak == dailyStreak)&&(identical(other.nextRequest, nextRequest) || other.nextRequest == nextRequest)&&(identical(other.restored, restored) || other.restored == restored));
}


@override
int get hashCode => Object.hashAll([runtimeType,play,entry,board,selectedSlotId,status,paused,softStuck,hint,freeUndosLeft,hintsLeft,extraSlotsLeft,canUndo,canAddSlot,canHint,unlimitedBoosters,coins,winReward,moveSeq,effectSeq,effect,offer,undoPrice,hintPrice,slotPrice,tutorial,intro,completedChapterId,chapterReward,dailyStreak,nextRequest,restored]);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'GameplayState(play: $play, entry: $entry, board: $board, selectedSlotId: $selectedSlotId, status: $status, paused: $paused, softStuck: $softStuck, hint: $hint, freeUndosLeft: $freeUndosLeft, hintsLeft: $hintsLeft, extraSlotsLeft: $extraSlotsLeft, canUndo: $canUndo, canAddSlot: $canAddSlot, canHint: $canHint, unlimitedBoosters: $unlimitedBoosters, coins: $coins, winReward: $winReward, moveSeq: $moveSeq, effectSeq: $effectSeq, effect: $effect, offer: $offer, undoPrice: $undoPrice, hintPrice: $hintPrice, slotPrice: $slotPrice, tutorial: $tutorial, intro: $intro, completedChapterId: $completedChapterId, chapterReward: $chapterReward, dailyStreak: $dailyStreak, nextRequest: $nextRequest, restored: $restored)';
}


}

/// @nodoc
abstract mixin class $GameplayStateCopyWith<$Res>  {
  factory $GameplayStateCopyWith(GameplayState value, $Res Function(GameplayState) _then) = _$GameplayStateCopyWithImpl;
@useResult
$Res call({
 PlayEntry play, LevelBundleEntry entry, GameState board, String? selectedSlotId, GameplayStatus status, bool paused, bool softStuck, Move? hint, int freeUndosLeft, int hintsLeft, int extraSlotsLeft, bool canUndo, bool canAddSlot, bool canHint, bool unlimitedBoosters, int coins, int winReward, int moveSeq, int effectSeq, BoardEffect? effect, BoosterOffer? offer, int undoPrice, int hintPrice, int slotPrice, TutorialCue? tutorial, IntroMechanic? intro, String? completedChapterId, int chapterReward, int? dailyStreak, PlayRequest? nextRequest, bool restored
});


$PlayEntryCopyWith<$Res> get play;$BoosterOfferCopyWith<$Res>? get offer;$TutorialCueCopyWith<$Res>? get tutorial;$PlayRequestCopyWith<$Res>? get nextRequest;

}
/// @nodoc
class _$GameplayStateCopyWithImpl<$Res>
    implements $GameplayStateCopyWith<$Res> {
  _$GameplayStateCopyWithImpl(this._self, this._then);

  final GameplayState _self;
  final $Res Function(GameplayState) _then;

/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? play = null,Object? entry = null,Object? board = null,Object? selectedSlotId = freezed,Object? status = null,Object? paused = null,Object? softStuck = null,Object? hint = freezed,Object? freeUndosLeft = null,Object? hintsLeft = null,Object? extraSlotsLeft = null,Object? canUndo = null,Object? canAddSlot = null,Object? canHint = null,Object? unlimitedBoosters = null,Object? coins = null,Object? winReward = null,Object? moveSeq = null,Object? effectSeq = null,Object? effect = freezed,Object? offer = freezed,Object? undoPrice = null,Object? hintPrice = null,Object? slotPrice = null,Object? tutorial = freezed,Object? intro = freezed,Object? completedChapterId = freezed,Object? chapterReward = null,Object? dailyStreak = freezed,Object? nextRequest = freezed,Object? restored = null,}) {
  return _then(_self.copyWith(
play: null == play ? _self.play : play // ignore: cast_nullable_to_non_nullable
as PlayEntry,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
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
as BoardEffect?,offer: freezed == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as BoosterOffer?,undoPrice: null == undoPrice ? _self.undoPrice : undoPrice // ignore: cast_nullable_to_non_nullable
as int,hintPrice: null == hintPrice ? _self.hintPrice : hintPrice // ignore: cast_nullable_to_non_nullable
as int,slotPrice: null == slotPrice ? _self.slotPrice : slotPrice // ignore: cast_nullable_to_non_nullable
as int,tutorial: freezed == tutorial ? _self.tutorial : tutorial // ignore: cast_nullable_to_non_nullable
as TutorialCue?,intro: freezed == intro ? _self.intro : intro // ignore: cast_nullable_to_non_nullable
as IntroMechanic?,completedChapterId: freezed == completedChapterId ? _self.completedChapterId : completedChapterId // ignore: cast_nullable_to_non_nullable
as String?,chapterReward: null == chapterReward ? _self.chapterReward : chapterReward // ignore: cast_nullable_to_non_nullable
as int,dailyStreak: freezed == dailyStreak ? _self.dailyStreak : dailyStreak // ignore: cast_nullable_to_non_nullable
as int?,nextRequest: freezed == nextRequest ? _self.nextRequest : nextRequest // ignore: cast_nullable_to_non_nullable
as PlayRequest?,restored: null == restored ? _self.restored : restored // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayEntryCopyWith<$Res> get play {
  
  return $PlayEntryCopyWith<$Res>(_self.play, (value) {
    return _then(_self.copyWith(play: value));
  });
}/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoosterOfferCopyWith<$Res>? get offer {
    if (_self.offer == null) {
    return null;
  }

  return $BoosterOfferCopyWith<$Res>(_self.offer!, (value) {
    return _then(_self.copyWith(offer: value));
  });
}/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TutorialCueCopyWith<$Res>? get tutorial {
    if (_self.tutorial == null) {
    return null;
  }

  return $TutorialCueCopyWith<$Res>(_self.tutorial!, (value) {
    return _then(_self.copyWith(tutorial: value));
  });
}/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res>? get nextRequest {
    if (_self.nextRequest == null) {
    return null;
  }

  return $PlayRequestCopyWith<$Res>(_self.nextRequest!, (value) {
    return _then(_self.copyWith(nextRequest: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayEntry play,  LevelBundleEntry entry,  GameState board,  String? selectedSlotId,  GameplayStatus status,  bool paused,  bool softStuck,  Move? hint,  int freeUndosLeft,  int hintsLeft,  int extraSlotsLeft,  bool canUndo,  bool canAddSlot,  bool canHint,  bool unlimitedBoosters,  int coins,  int winReward,  int moveSeq,  int effectSeq,  BoardEffect? effect,  BoosterOffer? offer,  int undoPrice,  int hintPrice,  int slotPrice,  TutorialCue? tutorial,  IntroMechanic? intro,  String? completedChapterId,  int chapterReward,  int? dailyStreak,  PlayRequest? nextRequest,  bool restored)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameplayState() when $default != null:
return $default(_that.play,_that.entry,_that.board,_that.selectedSlotId,_that.status,_that.paused,_that.softStuck,_that.hint,_that.freeUndosLeft,_that.hintsLeft,_that.extraSlotsLeft,_that.canUndo,_that.canAddSlot,_that.canHint,_that.unlimitedBoosters,_that.coins,_that.winReward,_that.moveSeq,_that.effectSeq,_that.effect,_that.offer,_that.undoPrice,_that.hintPrice,_that.slotPrice,_that.tutorial,_that.intro,_that.completedChapterId,_that.chapterReward,_that.dailyStreak,_that.nextRequest,_that.restored);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayEntry play,  LevelBundleEntry entry,  GameState board,  String? selectedSlotId,  GameplayStatus status,  bool paused,  bool softStuck,  Move? hint,  int freeUndosLeft,  int hintsLeft,  int extraSlotsLeft,  bool canUndo,  bool canAddSlot,  bool canHint,  bool unlimitedBoosters,  int coins,  int winReward,  int moveSeq,  int effectSeq,  BoardEffect? effect,  BoosterOffer? offer,  int undoPrice,  int hintPrice,  int slotPrice,  TutorialCue? tutorial,  IntroMechanic? intro,  String? completedChapterId,  int chapterReward,  int? dailyStreak,  PlayRequest? nextRequest,  bool restored)  $default,) {final _that = this;
switch (_that) {
case _GameplayState():
return $default(_that.play,_that.entry,_that.board,_that.selectedSlotId,_that.status,_that.paused,_that.softStuck,_that.hint,_that.freeUndosLeft,_that.hintsLeft,_that.extraSlotsLeft,_that.canUndo,_that.canAddSlot,_that.canHint,_that.unlimitedBoosters,_that.coins,_that.winReward,_that.moveSeq,_that.effectSeq,_that.effect,_that.offer,_that.undoPrice,_that.hintPrice,_that.slotPrice,_that.tutorial,_that.intro,_that.completedChapterId,_that.chapterReward,_that.dailyStreak,_that.nextRequest,_that.restored);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayEntry play,  LevelBundleEntry entry,  GameState board,  String? selectedSlotId,  GameplayStatus status,  bool paused,  bool softStuck,  Move? hint,  int freeUndosLeft,  int hintsLeft,  int extraSlotsLeft,  bool canUndo,  bool canAddSlot,  bool canHint,  bool unlimitedBoosters,  int coins,  int winReward,  int moveSeq,  int effectSeq,  BoardEffect? effect,  BoosterOffer? offer,  int undoPrice,  int hintPrice,  int slotPrice,  TutorialCue? tutorial,  IntroMechanic? intro,  String? completedChapterId,  int chapterReward,  int? dailyStreak,  PlayRequest? nextRequest,  bool restored)?  $default,) {final _that = this;
switch (_that) {
case _GameplayState() when $default != null:
return $default(_that.play,_that.entry,_that.board,_that.selectedSlotId,_that.status,_that.paused,_that.softStuck,_that.hint,_that.freeUndosLeft,_that.hintsLeft,_that.extraSlotsLeft,_that.canUndo,_that.canAddSlot,_that.canHint,_that.unlimitedBoosters,_that.coins,_that.winReward,_that.moveSeq,_that.effectSeq,_that.effect,_that.offer,_that.undoPrice,_that.hintPrice,_that.slotPrice,_that.tutorial,_that.intro,_that.completedChapterId,_that.chapterReward,_that.dailyStreak,_that.nextRequest,_that.restored);case _:
  return null;

}
}

}

/// @nodoc


class _GameplayState extends GameplayState with DiagnosticableTreeMixin {
  const _GameplayState({required this.play, required this.entry, required this.board, this.selectedSlotId, this.status = GameplayStatus.playing, this.paused = false, this.softStuck = false, this.hint, this.freeUndosLeft = 0, this.hintsLeft = 0, this.extraSlotsLeft = 0, this.canUndo = false, this.canAddSlot = false, this.canHint = false, this.unlimitedBoosters = false, this.coins = 0, this.winReward = 0, this.moveSeq = 0, this.effectSeq = 0, this.effect, this.offer, this.undoPrice = 0, this.hintPrice = 0, this.slotPrice = 0, this.tutorial, this.intro, this.completedChapterId, this.chapterReward = 0, this.dailyStreak, this.nextRequest, this.restored = false}): super._();
  

/// What is being played and how it pays (m3-design §6.2).
@override final  PlayEntry play;
/// The level and its play metadata (order, chapter, tier, reward): the
/// bundle entry of a campaign level, or a stand-in for a generated one
/// (order `levelCount + n` for Bonus Level n, the date for the daily;
/// its theme as the chapter). The M2 widgets read it; new code reads
/// [play].
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
/// Undo does something: a move to undo, free (or [unlimitedBoosters]),
/// from the inventory, or via the coin offer (frame 3.2, m3-design
/// §7.3). False only when there is nothing to undo.
@override@JsonKey() final  bool canUndo;
/// +1 Slot does something: fewer than 2 added to this level, free (or
/// [unlimitedBoosters]), from the inventory, or via the coin offer.
/// False only when the level's own limit is reached.
@override@JsonKey() final  bool canAddSlot;
/// Hint does something: free (or [unlimitedBoosters]), from the
/// inventory, or via the coin offer (frame 3.3, m3-design §7.3).
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
/// The purchase popup (frames 3.2, 3.3; m3-design §7.3).
@override final  BoosterOffer? offer;
/// The coin prices a booster shows and costs once its free uses or the
/// inventory are gone (Remote Config `price_undo`, `price_hint`,
/// `price_slot`; frames 3.2, 3.3, 3.5 badges and rows; m3-design §7.3).
@override@JsonKey() final  int undoPrice;
@override@JsonKey() final  int hintPrice;
@override@JsonKey() final  int slotPrice;
/// The tutorial step on screen (frames 1.3, 1.4, 1.6; m3-design §10.4).
@override final  TutorialCue? tutorial;
/// The intro card on screen (frames 4.1–4.3; m3-design §10.4). Input
/// is locked under it until `IntroDismissed`.
@override final  IntroMechanic? intro;
/// Once won: the chapter this win completed and collected (frame 4.6).
@override final  String? completedChapterId;
/// Once won: the `reward_chapter` coins it paid (4.6 "+150 coins").
@override@JsonKey() final  int chapterReward;
/// Once a daily is won: the streak after the solve (frame 5.4).
@override final  int? dailyStreak;
/// Once won: what Continue plays (`LevelResolver.next`). The page
/// prefetches its art; a bonus request after a campaign level shows All
/// Levels Done first (frame 4.9); null after a daily ("Back to Daily").
@override final  PlayRequest? nextRequest;
/// The board came back from the in-progress save (m3-design §3.4).
@override@JsonKey() final  bool restored;

/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameplayStateCopyWith<_GameplayState> get copyWith => __$GameplayStateCopyWithImpl<_GameplayState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'GameplayState'))
    ..add(DiagnosticsProperty('play', play))..add(DiagnosticsProperty('entry', entry))..add(DiagnosticsProperty('board', board))..add(DiagnosticsProperty('selectedSlotId', selectedSlotId))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('paused', paused))..add(DiagnosticsProperty('softStuck', softStuck))..add(DiagnosticsProperty('hint', hint))..add(DiagnosticsProperty('freeUndosLeft', freeUndosLeft))..add(DiagnosticsProperty('hintsLeft', hintsLeft))..add(DiagnosticsProperty('extraSlotsLeft', extraSlotsLeft))..add(DiagnosticsProperty('canUndo', canUndo))..add(DiagnosticsProperty('canAddSlot', canAddSlot))..add(DiagnosticsProperty('canHint', canHint))..add(DiagnosticsProperty('unlimitedBoosters', unlimitedBoosters))..add(DiagnosticsProperty('coins', coins))..add(DiagnosticsProperty('winReward', winReward))..add(DiagnosticsProperty('moveSeq', moveSeq))..add(DiagnosticsProperty('effectSeq', effectSeq))..add(DiagnosticsProperty('effect', effect))..add(DiagnosticsProperty('offer', offer))..add(DiagnosticsProperty('undoPrice', undoPrice))..add(DiagnosticsProperty('hintPrice', hintPrice))..add(DiagnosticsProperty('slotPrice', slotPrice))..add(DiagnosticsProperty('tutorial', tutorial))..add(DiagnosticsProperty('intro', intro))..add(DiagnosticsProperty('completedChapterId', completedChapterId))..add(DiagnosticsProperty('chapterReward', chapterReward))..add(DiagnosticsProperty('dailyStreak', dailyStreak))..add(DiagnosticsProperty('nextRequest', nextRequest))..add(DiagnosticsProperty('restored', restored));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameplayState&&(identical(other.play, play) || other.play == play)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.board, board) || other.board == board)&&(identical(other.selectedSlotId, selectedSlotId) || other.selectedSlotId == selectedSlotId)&&(identical(other.status, status) || other.status == status)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.softStuck, softStuck) || other.softStuck == softStuck)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.freeUndosLeft, freeUndosLeft) || other.freeUndosLeft == freeUndosLeft)&&(identical(other.hintsLeft, hintsLeft) || other.hintsLeft == hintsLeft)&&(identical(other.extraSlotsLeft, extraSlotsLeft) || other.extraSlotsLeft == extraSlotsLeft)&&(identical(other.canUndo, canUndo) || other.canUndo == canUndo)&&(identical(other.canAddSlot, canAddSlot) || other.canAddSlot == canAddSlot)&&(identical(other.canHint, canHint) || other.canHint == canHint)&&(identical(other.unlimitedBoosters, unlimitedBoosters) || other.unlimitedBoosters == unlimitedBoosters)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.winReward, winReward) || other.winReward == winReward)&&(identical(other.moveSeq, moveSeq) || other.moveSeq == moveSeq)&&(identical(other.effectSeq, effectSeq) || other.effectSeq == effectSeq)&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.undoPrice, undoPrice) || other.undoPrice == undoPrice)&&(identical(other.hintPrice, hintPrice) || other.hintPrice == hintPrice)&&(identical(other.slotPrice, slotPrice) || other.slotPrice == slotPrice)&&(identical(other.tutorial, tutorial) || other.tutorial == tutorial)&&(identical(other.intro, intro) || other.intro == intro)&&(identical(other.completedChapterId, completedChapterId) || other.completedChapterId == completedChapterId)&&(identical(other.chapterReward, chapterReward) || other.chapterReward == chapterReward)&&(identical(other.dailyStreak, dailyStreak) || other.dailyStreak == dailyStreak)&&(identical(other.nextRequest, nextRequest) || other.nextRequest == nextRequest)&&(identical(other.restored, restored) || other.restored == restored));
}


@override
int get hashCode => Object.hashAll([runtimeType,play,entry,board,selectedSlotId,status,paused,softStuck,hint,freeUndosLeft,hintsLeft,extraSlotsLeft,canUndo,canAddSlot,canHint,unlimitedBoosters,coins,winReward,moveSeq,effectSeq,effect,offer,undoPrice,hintPrice,slotPrice,tutorial,intro,completedChapterId,chapterReward,dailyStreak,nextRequest,restored]);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'GameplayState(play: $play, entry: $entry, board: $board, selectedSlotId: $selectedSlotId, status: $status, paused: $paused, softStuck: $softStuck, hint: $hint, freeUndosLeft: $freeUndosLeft, hintsLeft: $hintsLeft, extraSlotsLeft: $extraSlotsLeft, canUndo: $canUndo, canAddSlot: $canAddSlot, canHint: $canHint, unlimitedBoosters: $unlimitedBoosters, coins: $coins, winReward: $winReward, moveSeq: $moveSeq, effectSeq: $effectSeq, effect: $effect, offer: $offer, undoPrice: $undoPrice, hintPrice: $hintPrice, slotPrice: $slotPrice, tutorial: $tutorial, intro: $intro, completedChapterId: $completedChapterId, chapterReward: $chapterReward, dailyStreak: $dailyStreak, nextRequest: $nextRequest, restored: $restored)';
}


}

/// @nodoc
abstract mixin class _$GameplayStateCopyWith<$Res> implements $GameplayStateCopyWith<$Res> {
  factory _$GameplayStateCopyWith(_GameplayState value, $Res Function(_GameplayState) _then) = __$GameplayStateCopyWithImpl;
@override @useResult
$Res call({
 PlayEntry play, LevelBundleEntry entry, GameState board, String? selectedSlotId, GameplayStatus status, bool paused, bool softStuck, Move? hint, int freeUndosLeft, int hintsLeft, int extraSlotsLeft, bool canUndo, bool canAddSlot, bool canHint, bool unlimitedBoosters, int coins, int winReward, int moveSeq, int effectSeq, BoardEffect? effect, BoosterOffer? offer, int undoPrice, int hintPrice, int slotPrice, TutorialCue? tutorial, IntroMechanic? intro, String? completedChapterId, int chapterReward, int? dailyStreak, PlayRequest? nextRequest, bool restored
});


@override $PlayEntryCopyWith<$Res> get play;@override $BoosterOfferCopyWith<$Res>? get offer;@override $TutorialCueCopyWith<$Res>? get tutorial;@override $PlayRequestCopyWith<$Res>? get nextRequest;

}
/// @nodoc
class __$GameplayStateCopyWithImpl<$Res>
    implements _$GameplayStateCopyWith<$Res> {
  __$GameplayStateCopyWithImpl(this._self, this._then);

  final _GameplayState _self;
  final $Res Function(_GameplayState) _then;

/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? play = null,Object? entry = null,Object? board = null,Object? selectedSlotId = freezed,Object? status = null,Object? paused = null,Object? softStuck = null,Object? hint = freezed,Object? freeUndosLeft = null,Object? hintsLeft = null,Object? extraSlotsLeft = null,Object? canUndo = null,Object? canAddSlot = null,Object? canHint = null,Object? unlimitedBoosters = null,Object? coins = null,Object? winReward = null,Object? moveSeq = null,Object? effectSeq = null,Object? effect = freezed,Object? offer = freezed,Object? undoPrice = null,Object? hintPrice = null,Object? slotPrice = null,Object? tutorial = freezed,Object? intro = freezed,Object? completedChapterId = freezed,Object? chapterReward = null,Object? dailyStreak = freezed,Object? nextRequest = freezed,Object? restored = null,}) {
  return _then(_GameplayState(
play: null == play ? _self.play : play // ignore: cast_nullable_to_non_nullable
as PlayEntry,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
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
as BoardEffect?,offer: freezed == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as BoosterOffer?,undoPrice: null == undoPrice ? _self.undoPrice : undoPrice // ignore: cast_nullable_to_non_nullable
as int,hintPrice: null == hintPrice ? _self.hintPrice : hintPrice // ignore: cast_nullable_to_non_nullable
as int,slotPrice: null == slotPrice ? _self.slotPrice : slotPrice // ignore: cast_nullable_to_non_nullable
as int,tutorial: freezed == tutorial ? _self.tutorial : tutorial // ignore: cast_nullable_to_non_nullable
as TutorialCue?,intro: freezed == intro ? _self.intro : intro // ignore: cast_nullable_to_non_nullable
as IntroMechanic?,completedChapterId: freezed == completedChapterId ? _self.completedChapterId : completedChapterId // ignore: cast_nullable_to_non_nullable
as String?,chapterReward: null == chapterReward ? _self.chapterReward : chapterReward // ignore: cast_nullable_to_non_nullable
as int,dailyStreak: freezed == dailyStreak ? _self.dailyStreak : dailyStreak // ignore: cast_nullable_to_non_nullable
as int?,nextRequest: freezed == nextRequest ? _self.nextRequest : nextRequest // ignore: cast_nullable_to_non_nullable
as PlayRequest?,restored: null == restored ? _self.restored : restored // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayEntryCopyWith<$Res> get play {
  
  return $PlayEntryCopyWith<$Res>(_self.play, (value) {
    return _then(_self.copyWith(play: value));
  });
}/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoosterOfferCopyWith<$Res>? get offer {
    if (_self.offer == null) {
    return null;
  }

  return $BoosterOfferCopyWith<$Res>(_self.offer!, (value) {
    return _then(_self.copyWith(offer: value));
  });
}/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TutorialCueCopyWith<$Res>? get tutorial {
    if (_self.tutorial == null) {
    return null;
  }

  return $TutorialCueCopyWith<$Res>(_self.tutorial!, (value) {
    return _then(_self.copyWith(tutorial: value));
  });
}/// Create a copy of GameplayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res>? get nextRequest {
    if (_self.nextRequest == null) {
    return null;
  }

  return $PlayRequestCopyWith<$Res>(_self.nextRequest!, (value) {
    return _then(_self.copyWith(nextRequest: value));
  });
}
}

// dart format on
