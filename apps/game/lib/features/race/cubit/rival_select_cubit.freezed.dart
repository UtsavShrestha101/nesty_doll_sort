// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rival_select_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RivalCard {

/// 1–3.
 int get number;/// Selectable: rival 1 always, the next after the first win against the
/// one before.
 bool get unlocked;/// Races won against this rival (the card's "N wins"; never a loss
/// count, vs-computer rule 10).
 int get wins;/// Coins a win pays (`RaceRules.rewardCoins`), shown before the race
/// (spec-prop §1.1 rule 2).
 int get rewardCoins;/// The player has beaten this rival at least once (`wins > 0`): the
/// portrait's check (frame 9.2b). Rematch still pays, and RaceRules is
/// the source of truth.
 bool get beaten;/// Unlocked, never raced (`raceNo == 0`) and not rival 1: the "New"
/// chip (frame 9.2b, C.9). It clears when the rival is first raced.
 bool get isNew;
/// Create a copy of RivalCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RivalCardCopyWith<RivalCard> get copyWith => _$RivalCardCopyWithImpl<RivalCard>(this as RivalCard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RivalCard&&(identical(other.number, number) || other.number == number)&&(identical(other.unlocked, unlocked) || other.unlocked == unlocked)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.beaten, beaten) || other.beaten == beaten)&&(identical(other.isNew, isNew) || other.isNew == isNew));
}


@override
int get hashCode => Object.hash(runtimeType,number,unlocked,wins,rewardCoins,beaten,isNew);

@override
String toString() {
  return 'RivalCard(number: $number, unlocked: $unlocked, wins: $wins, rewardCoins: $rewardCoins, beaten: $beaten, isNew: $isNew)';
}


}

/// @nodoc
abstract mixin class $RivalCardCopyWith<$Res>  {
  factory $RivalCardCopyWith(RivalCard value, $Res Function(RivalCard) _then) = _$RivalCardCopyWithImpl;
@useResult
$Res call({
 int number, bool unlocked, int wins, int rewardCoins, bool beaten, bool isNew
});




}
/// @nodoc
class _$RivalCardCopyWithImpl<$Res>
    implements $RivalCardCopyWith<$Res> {
  _$RivalCardCopyWithImpl(this._self, this._then);

  final RivalCard _self;
  final $Res Function(RivalCard) _then;

/// Create a copy of RivalCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? unlocked = null,Object? wins = null,Object? rewardCoins = null,Object? beaten = null,Object? isNew = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,unlocked: null == unlocked ? _self.unlocked : unlocked // ignore: cast_nullable_to_non_nullable
as bool,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,rewardCoins: null == rewardCoins ? _self.rewardCoins : rewardCoins // ignore: cast_nullable_to_non_nullable
as int,beaten: null == beaten ? _self.beaten : beaten // ignore: cast_nullable_to_non_nullable
as bool,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RivalCard].
extension RivalCardPatterns on RivalCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RivalCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RivalCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RivalCard value)  $default,){
final _that = this;
switch (_that) {
case _RivalCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RivalCard value)?  $default,){
final _that = this;
switch (_that) {
case _RivalCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  bool unlocked,  int wins,  int rewardCoins,  bool beaten,  bool isNew)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RivalCard() when $default != null:
return $default(_that.number,_that.unlocked,_that.wins,_that.rewardCoins,_that.beaten,_that.isNew);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  bool unlocked,  int wins,  int rewardCoins,  bool beaten,  bool isNew)  $default,) {final _that = this;
switch (_that) {
case _RivalCard():
return $default(_that.number,_that.unlocked,_that.wins,_that.rewardCoins,_that.beaten,_that.isNew);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  bool unlocked,  int wins,  int rewardCoins,  bool beaten,  bool isNew)?  $default,) {final _that = this;
switch (_that) {
case _RivalCard() when $default != null:
return $default(_that.number,_that.unlocked,_that.wins,_that.rewardCoins,_that.beaten,_that.isNew);case _:
  return null;

}
}

}

/// @nodoc


class _RivalCard implements RivalCard {
  const _RivalCard({required this.number, this.unlocked = false, this.wins = 0, this.rewardCoins = 0, this.beaten = false, this.isNew = false});
  

/// 1–3.
@override final  int number;
/// Selectable: rival 1 always, the next after the first win against the
/// one before.
@override@JsonKey() final  bool unlocked;
/// Races won against this rival (the card's "N wins"; never a loss
/// count, vs-computer rule 10).
@override@JsonKey() final  int wins;
/// Coins a win pays (`RaceRules.rewardCoins`), shown before the race
/// (spec-prop §1.1 rule 2).
@override@JsonKey() final  int rewardCoins;
/// The player has beaten this rival at least once (`wins > 0`): the
/// portrait's check (frame 9.2b). Rematch still pays, and RaceRules is
/// the source of truth.
@override@JsonKey() final  bool beaten;
/// Unlocked, never raced (`raceNo == 0`) and not rival 1: the "New"
/// chip (frame 9.2b, C.9). It clears when the rival is first raced.
@override@JsonKey() final  bool isNew;

/// Create a copy of RivalCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RivalCardCopyWith<_RivalCard> get copyWith => __$RivalCardCopyWithImpl<_RivalCard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RivalCard&&(identical(other.number, number) || other.number == number)&&(identical(other.unlocked, unlocked) || other.unlocked == unlocked)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.beaten, beaten) || other.beaten == beaten)&&(identical(other.isNew, isNew) || other.isNew == isNew));
}


@override
int get hashCode => Object.hash(runtimeType,number,unlocked,wins,rewardCoins,beaten,isNew);

@override
String toString() {
  return 'RivalCard(number: $number, unlocked: $unlocked, wins: $wins, rewardCoins: $rewardCoins, beaten: $beaten, isNew: $isNew)';
}


}

/// @nodoc
abstract mixin class _$RivalCardCopyWith<$Res> implements $RivalCardCopyWith<$Res> {
  factory _$RivalCardCopyWith(_RivalCard value, $Res Function(_RivalCard) _then) = __$RivalCardCopyWithImpl;
@override @useResult
$Res call({
 int number, bool unlocked, int wins, int rewardCoins, bool beaten, bool isNew
});




}
/// @nodoc
class __$RivalCardCopyWithImpl<$Res>
    implements _$RivalCardCopyWith<$Res> {
  __$RivalCardCopyWithImpl(this._self, this._then);

  final _RivalCard _self;
  final $Res Function(_RivalCard) _then;

/// Create a copy of RivalCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? unlocked = null,Object? wins = null,Object? rewardCoins = null,Object? beaten = null,Object? isNew = null,}) {
  return _then(_RivalCard(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,unlocked: null == unlocked ? _self.unlocked : unlocked // ignore: cast_nullable_to_non_nullable
as bool,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,rewardCoins: null == rewardCoins ? _self.rewardCoins : rewardCoins // ignore: cast_nullable_to_non_nullable
as int,beaten: null == beaten ? _self.beaten : beaten // ignore: cast_nullable_to_non_nullable
as bool,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RivalSelectState {

/// The header's coin pill (`SaveService.coins`).
 int get coins;/// Rivals 1–3, in order.
 List<RivalCard> get rivals;/// The rival the one Start races (1–3): the newest unlocked one not yet
/// raced, else the highest unlocked; the player's taps change it for
/// this visit only (frame 9.2).
 int get selected;
/// Create a copy of RivalSelectState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RivalSelectStateCopyWith<RivalSelectState> get copyWith => _$RivalSelectStateCopyWithImpl<RivalSelectState>(this as RivalSelectState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RivalSelectState&&(identical(other.coins, coins) || other.coins == coins)&&const DeepCollectionEquality().equals(other.rivals, rivals)&&(identical(other.selected, selected) || other.selected == selected));
}


@override
int get hashCode => Object.hash(runtimeType,coins,const DeepCollectionEquality().hash(rivals),selected);

@override
String toString() {
  return 'RivalSelectState(coins: $coins, rivals: $rivals, selected: $selected)';
}


}

/// @nodoc
abstract mixin class $RivalSelectStateCopyWith<$Res>  {
  factory $RivalSelectStateCopyWith(RivalSelectState value, $Res Function(RivalSelectState) _then) = _$RivalSelectStateCopyWithImpl;
@useResult
$Res call({
 int coins, List<RivalCard> rivals, int selected
});




}
/// @nodoc
class _$RivalSelectStateCopyWithImpl<$Res>
    implements $RivalSelectStateCopyWith<$Res> {
  _$RivalSelectStateCopyWithImpl(this._self, this._then);

  final RivalSelectState _self;
  final $Res Function(RivalSelectState) _then;

/// Create a copy of RivalSelectState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coins = null,Object? rivals = null,Object? selected = null,}) {
  return _then(_self.copyWith(
coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,rivals: null == rivals ? _self.rivals : rivals // ignore: cast_nullable_to_non_nullable
as List<RivalCard>,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RivalSelectState].
extension RivalSelectStatePatterns on RivalSelectState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RivalSelectState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RivalSelectState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RivalSelectState value)  $default,){
final _that = this;
switch (_that) {
case _RivalSelectState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RivalSelectState value)?  $default,){
final _that = this;
switch (_that) {
case _RivalSelectState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int coins,  List<RivalCard> rivals,  int selected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RivalSelectState() when $default != null:
return $default(_that.coins,_that.rivals,_that.selected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int coins,  List<RivalCard> rivals,  int selected)  $default,) {final _that = this;
switch (_that) {
case _RivalSelectState():
return $default(_that.coins,_that.rivals,_that.selected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int coins,  List<RivalCard> rivals,  int selected)?  $default,) {final _that = this;
switch (_that) {
case _RivalSelectState() when $default != null:
return $default(_that.coins,_that.rivals,_that.selected);case _:
  return null;

}
}

}

/// @nodoc


class _RivalSelectState implements RivalSelectState {
  const _RivalSelectState({this.coins = 0, final  List<RivalCard> rivals = const <RivalCard>[], this.selected = 1}): _rivals = rivals;
  

/// The header's coin pill (`SaveService.coins`).
@override@JsonKey() final  int coins;
/// Rivals 1–3, in order.
 final  List<RivalCard> _rivals;
/// Rivals 1–3, in order.
@override@JsonKey() List<RivalCard> get rivals {
  if (_rivals is EqualUnmodifiableListView) return _rivals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rivals);
}

/// The rival the one Start races (1–3): the newest unlocked one not yet
/// raced, else the highest unlocked; the player's taps change it for
/// this visit only (frame 9.2).
@override@JsonKey() final  int selected;

/// Create a copy of RivalSelectState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RivalSelectStateCopyWith<_RivalSelectState> get copyWith => __$RivalSelectStateCopyWithImpl<_RivalSelectState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RivalSelectState&&(identical(other.coins, coins) || other.coins == coins)&&const DeepCollectionEquality().equals(other._rivals, _rivals)&&(identical(other.selected, selected) || other.selected == selected));
}


@override
int get hashCode => Object.hash(runtimeType,coins,const DeepCollectionEquality().hash(_rivals),selected);

@override
String toString() {
  return 'RivalSelectState(coins: $coins, rivals: $rivals, selected: $selected)';
}


}

/// @nodoc
abstract mixin class _$RivalSelectStateCopyWith<$Res> implements $RivalSelectStateCopyWith<$Res> {
  factory _$RivalSelectStateCopyWith(_RivalSelectState value, $Res Function(_RivalSelectState) _then) = __$RivalSelectStateCopyWithImpl;
@override @useResult
$Res call({
 int coins, List<RivalCard> rivals, int selected
});




}
/// @nodoc
class __$RivalSelectStateCopyWithImpl<$Res>
    implements _$RivalSelectStateCopyWith<$Res> {
  __$RivalSelectStateCopyWithImpl(this._self, this._then);

  final _RivalSelectState _self;
  final $Res Function(_RivalSelectState) _then;

/// Create a copy of RivalSelectState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coins = null,Object? rivals = null,Object? selected = null,}) {
  return _then(_RivalSelectState(
coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,rivals: null == rivals ? _self._rivals : rivals // ignore: cast_nullable_to_non_nullable
as List<RivalCard>,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
