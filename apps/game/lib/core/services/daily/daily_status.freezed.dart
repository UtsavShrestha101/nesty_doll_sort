// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyStatus {

/// The player's local date (`AppClock.today`).
 LocalDate get today;/// Today's puzzle tier: `DifficultyCurve.dailyTier` (frame 5.1 "Hard").
 Tier get tier;/// Today's puzzle colors: `DifficultyCurve.dailyParams(today).colors`
/// (frame 5.1 "5 colors").
 int get colors;/// Level 2 won (m3-design §8.3); a locked tile otherwise.
 bool get unlocked;/// The gentle streak (spec-prop §7.5, m7-design §8): the days solved,
/// never lowered (frame 5.1 "4 days").
 int get streak;/// The flame is lit (`DailyProgress.lit`): false before the first solve
/// and while [paused].
 bool get lit;/// The current unbroken run (`DailyProgress.run`); 0 while not [lit].
 int get run;/// Freezes held, 0 or 1 (frame 5.1 "1 freeze", 5.2 "0 left").
 int get freezes;/// Today's puzzle is solved (frames 5.4, 5.5).
 bool get solvedToday;/// Streak days of the current 7-day cycle already done, 0–7: the strip
/// checks days 1..cycleDone, raises day cycleDone + 1 as "Today" (not
/// solved yet) or labels it "Tmrw" (solved), and day 7 is the chest
/// (m3-design §8.4).
 int get cycleDone;/// A 7th streak day was solved and its chest is still to collect
/// (frame 5.6).
 bool get chestPending;/// A day a freeze covered that the player hasn't been told about: the
/// "Streak saved!" banner (frame 5.2) names its weekday until
/// `DailyService.acknowledgeFreezeNotice`.
 LocalDate? get freezeNotice;/// Today's board is saved mid-way: Play continues it.
 bool get inProgress;/// Today's solve (`DailyProgress.lastSolve` when its date is today):
/// the Share text's facts (E3) and the reminder offer's default hour
/// (E4, Q81; m7-design P3.8). Null before today's solve, and for a day
/// an older build solved (no Share then).
 DailySolve? get solve;
/// Create a copy of DailyStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyStatusCopyWith<DailyStatus> get copyWith => _$DailyStatusCopyWithImpl<DailyStatus>(this as DailyStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyStatus&&(identical(other.today, today) || other.today == today)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.colors, colors) || other.colors == colors)&&(identical(other.unlocked, unlocked) || other.unlocked == unlocked)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.lit, lit) || other.lit == lit)&&(identical(other.run, run) || other.run == run)&&(identical(other.freezes, freezes) || other.freezes == freezes)&&(identical(other.solvedToday, solvedToday) || other.solvedToday == solvedToday)&&(identical(other.cycleDone, cycleDone) || other.cycleDone == cycleDone)&&(identical(other.chestPending, chestPending) || other.chestPending == chestPending)&&(identical(other.freezeNotice, freezeNotice) || other.freezeNotice == freezeNotice)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.solve, solve) || other.solve == solve));
}


@override
int get hashCode => Object.hash(runtimeType,today,tier,colors,unlocked,streak,lit,run,freezes,solvedToday,cycleDone,chestPending,freezeNotice,inProgress,solve);

@override
String toString() {
  return 'DailyStatus(today: $today, tier: $tier, colors: $colors, unlocked: $unlocked, streak: $streak, lit: $lit, run: $run, freezes: $freezes, solvedToday: $solvedToday, cycleDone: $cycleDone, chestPending: $chestPending, freezeNotice: $freezeNotice, inProgress: $inProgress, solve: $solve)';
}


}

/// @nodoc
abstract mixin class $DailyStatusCopyWith<$Res>  {
  factory $DailyStatusCopyWith(DailyStatus value, $Res Function(DailyStatus) _then) = _$DailyStatusCopyWithImpl;
@useResult
$Res call({
 LocalDate today, Tier tier, int colors, bool unlocked, int streak, bool lit, int run, int freezes, bool solvedToday, int cycleDone, bool chestPending, LocalDate? freezeNotice, bool inProgress, DailySolve? solve
});


$DailySolveCopyWith<$Res>? get solve;

}
/// @nodoc
class _$DailyStatusCopyWithImpl<$Res>
    implements $DailyStatusCopyWith<$Res> {
  _$DailyStatusCopyWithImpl(this._self, this._then);

  final DailyStatus _self;
  final $Res Function(DailyStatus) _then;

/// Create a copy of DailyStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? today = null,Object? tier = null,Object? colors = null,Object? unlocked = null,Object? streak = null,Object? lit = null,Object? run = null,Object? freezes = null,Object? solvedToday = null,Object? cycleDone = null,Object? chestPending = null,Object? freezeNotice = freezed,Object? inProgress = null,Object? solve = freezed,}) {
  return _then(_self.copyWith(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,colors: null == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as int,unlocked: null == unlocked ? _self.unlocked : unlocked // ignore: cast_nullable_to_non_nullable
as bool,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,lit: null == lit ? _self.lit : lit // ignore: cast_nullable_to_non_nullable
as bool,run: null == run ? _self.run : run // ignore: cast_nullable_to_non_nullable
as int,freezes: null == freezes ? _self.freezes : freezes // ignore: cast_nullable_to_non_nullable
as int,solvedToday: null == solvedToday ? _self.solvedToday : solvedToday // ignore: cast_nullable_to_non_nullable
as bool,cycleDone: null == cycleDone ? _self.cycleDone : cycleDone // ignore: cast_nullable_to_non_nullable
as int,chestPending: null == chestPending ? _self.chestPending : chestPending // ignore: cast_nullable_to_non_nullable
as bool,freezeNotice: freezed == freezeNotice ? _self.freezeNotice : freezeNotice // ignore: cast_nullable_to_non_nullable
as LocalDate?,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as bool,solve: freezed == solve ? _self.solve : solve // ignore: cast_nullable_to_non_nullable
as DailySolve?,
  ));
}
/// Create a copy of DailyStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailySolveCopyWith<$Res>? get solve {
    if (_self.solve == null) {
    return null;
  }

  return $DailySolveCopyWith<$Res>(_self.solve!, (value) {
    return _then(_self.copyWith(solve: value));
  });
}
}


/// Adds pattern-matching-related methods to [DailyStatus].
extension DailyStatusPatterns on DailyStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyStatus value)  $default,){
final _that = this;
switch (_that) {
case _DailyStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyStatus value)?  $default,){
final _that = this;
switch (_that) {
case _DailyStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate today,  Tier tier,  int colors,  bool unlocked,  int streak,  bool lit,  int run,  int freezes,  bool solvedToday,  int cycleDone,  bool chestPending,  LocalDate? freezeNotice,  bool inProgress,  DailySolve? solve)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyStatus() when $default != null:
return $default(_that.today,_that.tier,_that.colors,_that.unlocked,_that.streak,_that.lit,_that.run,_that.freezes,_that.solvedToday,_that.cycleDone,_that.chestPending,_that.freezeNotice,_that.inProgress,_that.solve);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate today,  Tier tier,  int colors,  bool unlocked,  int streak,  bool lit,  int run,  int freezes,  bool solvedToday,  int cycleDone,  bool chestPending,  LocalDate? freezeNotice,  bool inProgress,  DailySolve? solve)  $default,) {final _that = this;
switch (_that) {
case _DailyStatus():
return $default(_that.today,_that.tier,_that.colors,_that.unlocked,_that.streak,_that.lit,_that.run,_that.freezes,_that.solvedToday,_that.cycleDone,_that.chestPending,_that.freezeNotice,_that.inProgress,_that.solve);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate today,  Tier tier,  int colors,  bool unlocked,  int streak,  bool lit,  int run,  int freezes,  bool solvedToday,  int cycleDone,  bool chestPending,  LocalDate? freezeNotice,  bool inProgress,  DailySolve? solve)?  $default,) {final _that = this;
switch (_that) {
case _DailyStatus() when $default != null:
return $default(_that.today,_that.tier,_that.colors,_that.unlocked,_that.streak,_that.lit,_that.run,_that.freezes,_that.solvedToday,_that.cycleDone,_that.chestPending,_that.freezeNotice,_that.inProgress,_that.solve);case _:
  return null;

}
}

}

/// @nodoc


class _DailyStatus extends DailyStatus {
  const _DailyStatus({required this.today, required this.tier, required this.colors, this.unlocked = false, this.streak = 0, this.lit = false, this.run = 0, this.freezes = 0, this.solvedToday = false, this.cycleDone = 0, this.chestPending = false, this.freezeNotice, this.inProgress = false, this.solve}): super._();
  

/// The player's local date (`AppClock.today`).
@override final  LocalDate today;
/// Today's puzzle tier: `DifficultyCurve.dailyTier` (frame 5.1 "Hard").
@override final  Tier tier;
/// Today's puzzle colors: `DifficultyCurve.dailyParams(today).colors`
/// (frame 5.1 "5 colors").
@override final  int colors;
/// Level 2 won (m3-design §8.3); a locked tile otherwise.
@override@JsonKey() final  bool unlocked;
/// The gentle streak (spec-prop §7.5, m7-design §8): the days solved,
/// never lowered (frame 5.1 "4 days").
@override@JsonKey() final  int streak;
/// The flame is lit (`DailyProgress.lit`): false before the first solve
/// and while [paused].
@override@JsonKey() final  bool lit;
/// The current unbroken run (`DailyProgress.run`); 0 while not [lit].
@override@JsonKey() final  int run;
/// Freezes held, 0 or 1 (frame 5.1 "1 freeze", 5.2 "0 left").
@override@JsonKey() final  int freezes;
/// Today's puzzle is solved (frames 5.4, 5.5).
@override@JsonKey() final  bool solvedToday;
/// Streak days of the current 7-day cycle already done, 0–7: the strip
/// checks days 1..cycleDone, raises day cycleDone + 1 as "Today" (not
/// solved yet) or labels it "Tmrw" (solved), and day 7 is the chest
/// (m3-design §8.4).
@override@JsonKey() final  int cycleDone;
/// A 7th streak day was solved and its chest is still to collect
/// (frame 5.6).
@override@JsonKey() final  bool chestPending;
/// A day a freeze covered that the player hasn't been told about: the
/// "Streak saved!" banner (frame 5.2) names its weekday until
/// `DailyService.acknowledgeFreezeNotice`.
@override final  LocalDate? freezeNotice;
/// Today's board is saved mid-way: Play continues it.
@override@JsonKey() final  bool inProgress;
/// Today's solve (`DailyProgress.lastSolve` when its date is today):
/// the Share text's facts (E3) and the reminder offer's default hour
/// (E4, Q81; m7-design P3.8). Null before today's solve, and for a day
/// an older build solved (no Share then).
@override final  DailySolve? solve;

/// Create a copy of DailyStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyStatusCopyWith<_DailyStatus> get copyWith => __$DailyStatusCopyWithImpl<_DailyStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyStatus&&(identical(other.today, today) || other.today == today)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.colors, colors) || other.colors == colors)&&(identical(other.unlocked, unlocked) || other.unlocked == unlocked)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.lit, lit) || other.lit == lit)&&(identical(other.run, run) || other.run == run)&&(identical(other.freezes, freezes) || other.freezes == freezes)&&(identical(other.solvedToday, solvedToday) || other.solvedToday == solvedToday)&&(identical(other.cycleDone, cycleDone) || other.cycleDone == cycleDone)&&(identical(other.chestPending, chestPending) || other.chestPending == chestPending)&&(identical(other.freezeNotice, freezeNotice) || other.freezeNotice == freezeNotice)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.solve, solve) || other.solve == solve));
}


@override
int get hashCode => Object.hash(runtimeType,today,tier,colors,unlocked,streak,lit,run,freezes,solvedToday,cycleDone,chestPending,freezeNotice,inProgress,solve);

@override
String toString() {
  return 'DailyStatus(today: $today, tier: $tier, colors: $colors, unlocked: $unlocked, streak: $streak, lit: $lit, run: $run, freezes: $freezes, solvedToday: $solvedToday, cycleDone: $cycleDone, chestPending: $chestPending, freezeNotice: $freezeNotice, inProgress: $inProgress, solve: $solve)';
}


}

/// @nodoc
abstract mixin class _$DailyStatusCopyWith<$Res> implements $DailyStatusCopyWith<$Res> {
  factory _$DailyStatusCopyWith(_DailyStatus value, $Res Function(_DailyStatus) _then) = __$DailyStatusCopyWithImpl;
@override @useResult
$Res call({
 LocalDate today, Tier tier, int colors, bool unlocked, int streak, bool lit, int run, int freezes, bool solvedToday, int cycleDone, bool chestPending, LocalDate? freezeNotice, bool inProgress, DailySolve? solve
});


@override $DailySolveCopyWith<$Res>? get solve;

}
/// @nodoc
class __$DailyStatusCopyWithImpl<$Res>
    implements _$DailyStatusCopyWith<$Res> {
  __$DailyStatusCopyWithImpl(this._self, this._then);

  final _DailyStatus _self;
  final $Res Function(_DailyStatus) _then;

/// Create a copy of DailyStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? today = null,Object? tier = null,Object? colors = null,Object? unlocked = null,Object? streak = null,Object? lit = null,Object? run = null,Object? freezes = null,Object? solvedToday = null,Object? cycleDone = null,Object? chestPending = null,Object? freezeNotice = freezed,Object? inProgress = null,Object? solve = freezed,}) {
  return _then(_DailyStatus(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,colors: null == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as int,unlocked: null == unlocked ? _self.unlocked : unlocked // ignore: cast_nullable_to_non_nullable
as bool,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,lit: null == lit ? _self.lit : lit // ignore: cast_nullable_to_non_nullable
as bool,run: null == run ? _self.run : run // ignore: cast_nullable_to_non_nullable
as int,freezes: null == freezes ? _self.freezes : freezes // ignore: cast_nullable_to_non_nullable
as int,solvedToday: null == solvedToday ? _self.solvedToday : solvedToday // ignore: cast_nullable_to_non_nullable
as bool,cycleDone: null == cycleDone ? _self.cycleDone : cycleDone // ignore: cast_nullable_to_non_nullable
as int,chestPending: null == chestPending ? _self.chestPending : chestPending // ignore: cast_nullable_to_non_nullable
as bool,freezeNotice: freezed == freezeNotice ? _self.freezeNotice : freezeNotice // ignore: cast_nullable_to_non_nullable
as LocalDate?,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as bool,solve: freezed == solve ? _self.solve : solve // ignore: cast_nullable_to_non_nullable
as DailySolve?,
  ));
}

/// Create a copy of DailyStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailySolveCopyWith<$Res>? get solve {
    if (_self.solve == null) {
    return null;
  }

  return $DailySolveCopyWith<$Res>(_self.solve!, (value) {
    return _then(_self.copyWith(solve: value));
  });
}
}

// dart format on
