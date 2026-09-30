// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'museum_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MuseumEntry {

/// The bundle's chapter id, `ch03` (`figurineName`/`figurineFlavor`
/// select keys use [figurineId] instead, `chapterName` uses
/// [themeId]).
 String get chapterId;/// 1-based (frame 6.3 "Finish Chapter 3…").
 int get chapterNumber;/// The chapter's board theme: the `chapterName` select key (spec §7.1,
/// §12.4).
 String get themeId;/// `classic` … `explorer`: `FigurineImage`, `figurineName`,
/// `figurineShortName`, `figurineFlavor`.
 String get figurineId;/// The chapter is in the save's `museum`, or (D111 fix) its 20 levels
/// are all won even though `museum` hasn't caught up yet — never
/// "soon" once [done] reaches [total] (frame 6.1's colour art).
 bool get earned;/// The first not-[earned] chapter, in chapter order (frame 6.1's
/// "15/20" chip; only one entry is ever true).
 bool get isNext;/// This chapter's own levels already won, 0 when
/// [MuseumState.homeLevelNumber] hasn't reached it yet.
 int get done;/// Levels in the chapter (`ChapterInfo.levelsPerChapter`).
 int get total;/// The save's `museumCollected` date, or null when [earned] predates
/// that field (frame 6.2 "Collected" with no date, m3-design §9.5).
 LocalDate? get collectedOn;
/// Create a copy of MuseumEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuseumEntryCopyWith<MuseumEntry> get copyWith => _$MuseumEntryCopyWithImpl<MuseumEntry>(this as MuseumEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuseumEntry&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.chapterNumber, chapterNumber) || other.chapterNumber == chapterNumber)&&(identical(other.themeId, themeId) || other.themeId == themeId)&&(identical(other.figurineId, figurineId) || other.figurineId == figurineId)&&(identical(other.earned, earned) || other.earned == earned)&&(identical(other.isNext, isNext) || other.isNext == isNext)&&(identical(other.done, done) || other.done == done)&&(identical(other.total, total) || other.total == total)&&(identical(other.collectedOn, collectedOn) || other.collectedOn == collectedOn));
}


@override
int get hashCode => Object.hash(runtimeType,chapterId,chapterNumber,themeId,figurineId,earned,isNext,done,total,collectedOn);

@override
String toString() {
  return 'MuseumEntry(chapterId: $chapterId, chapterNumber: $chapterNumber, themeId: $themeId, figurineId: $figurineId, earned: $earned, isNext: $isNext, done: $done, total: $total, collectedOn: $collectedOn)';
}


}

/// @nodoc
abstract mixin class $MuseumEntryCopyWith<$Res>  {
  factory $MuseumEntryCopyWith(MuseumEntry value, $Res Function(MuseumEntry) _then) = _$MuseumEntryCopyWithImpl;
@useResult
$Res call({
 String chapterId, int chapterNumber, String themeId, String figurineId, bool earned, bool isNext, int done, int total, LocalDate? collectedOn
});




}
/// @nodoc
class _$MuseumEntryCopyWithImpl<$Res>
    implements $MuseumEntryCopyWith<$Res> {
  _$MuseumEntryCopyWithImpl(this._self, this._then);

  final MuseumEntry _self;
  final $Res Function(MuseumEntry) _then;

/// Create a copy of MuseumEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chapterId = null,Object? chapterNumber = null,Object? themeId = null,Object? figurineId = null,Object? earned = null,Object? isNext = null,Object? done = null,Object? total = null,Object? collectedOn = freezed,}) {
  return _then(_self.copyWith(
chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String,chapterNumber: null == chapterNumber ? _self.chapterNumber : chapterNumber // ignore: cast_nullable_to_non_nullable
as int,themeId: null == themeId ? _self.themeId : themeId // ignore: cast_nullable_to_non_nullable
as String,figurineId: null == figurineId ? _self.figurineId : figurineId // ignore: cast_nullable_to_non_nullable
as String,earned: null == earned ? _self.earned : earned // ignore: cast_nullable_to_non_nullable
as bool,isNext: null == isNext ? _self.isNext : isNext // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,collectedOn: freezed == collectedOn ? _self.collectedOn : collectedOn // ignore: cast_nullable_to_non_nullable
as LocalDate?,
  ));
}

}


/// Adds pattern-matching-related methods to [MuseumEntry].
extension MuseumEntryPatterns on MuseumEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuseumEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuseumEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuseumEntry value)  $default,){
final _that = this;
switch (_that) {
case _MuseumEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuseumEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MuseumEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String chapterId,  int chapterNumber,  String themeId,  String figurineId,  bool earned,  bool isNext,  int done,  int total,  LocalDate? collectedOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuseumEntry() when $default != null:
return $default(_that.chapterId,_that.chapterNumber,_that.themeId,_that.figurineId,_that.earned,_that.isNext,_that.done,_that.total,_that.collectedOn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String chapterId,  int chapterNumber,  String themeId,  String figurineId,  bool earned,  bool isNext,  int done,  int total,  LocalDate? collectedOn)  $default,) {final _that = this;
switch (_that) {
case _MuseumEntry():
return $default(_that.chapterId,_that.chapterNumber,_that.themeId,_that.figurineId,_that.earned,_that.isNext,_that.done,_that.total,_that.collectedOn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String chapterId,  int chapterNumber,  String themeId,  String figurineId,  bool earned,  bool isNext,  int done,  int total,  LocalDate? collectedOn)?  $default,) {final _that = this;
switch (_that) {
case _MuseumEntry() when $default != null:
return $default(_that.chapterId,_that.chapterNumber,_that.themeId,_that.figurineId,_that.earned,_that.isNext,_that.done,_that.total,_that.collectedOn);case _:
  return null;

}
}

}

/// @nodoc


class _MuseumEntry implements MuseumEntry {
  const _MuseumEntry({required this.chapterId, required this.chapterNumber, required this.themeId, required this.figurineId, required this.earned, required this.isNext, required this.done, required this.total, this.collectedOn});
  

/// The bundle's chapter id, `ch03` (`figurineName`/`figurineFlavor`
/// select keys use [figurineId] instead, `chapterName` uses
/// [themeId]).
@override final  String chapterId;
/// 1-based (frame 6.3 "Finish Chapter 3…").
@override final  int chapterNumber;
/// The chapter's board theme: the `chapterName` select key (spec §7.1,
/// §12.4).
@override final  String themeId;
/// `classic` … `explorer`: `FigurineImage`, `figurineName`,
/// `figurineShortName`, `figurineFlavor`.
@override final  String figurineId;
/// The chapter is in the save's `museum`, or (D111 fix) its 20 levels
/// are all won even though `museum` hasn't caught up yet — never
/// "soon" once [done] reaches [total] (frame 6.1's colour art).
@override final  bool earned;
/// The first not-[earned] chapter, in chapter order (frame 6.1's
/// "15/20" chip; only one entry is ever true).
@override final  bool isNext;
/// This chapter's own levels already won, 0 when
/// [MuseumState.homeLevelNumber] hasn't reached it yet.
@override final  int done;
/// Levels in the chapter (`ChapterInfo.levelsPerChapter`).
@override final  int total;
/// The save's `museumCollected` date, or null when [earned] predates
/// that field (frame 6.2 "Collected" with no date, m3-design §9.5).
@override final  LocalDate? collectedOn;

/// Create a copy of MuseumEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuseumEntryCopyWith<_MuseumEntry> get copyWith => __$MuseumEntryCopyWithImpl<_MuseumEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuseumEntry&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.chapterNumber, chapterNumber) || other.chapterNumber == chapterNumber)&&(identical(other.themeId, themeId) || other.themeId == themeId)&&(identical(other.figurineId, figurineId) || other.figurineId == figurineId)&&(identical(other.earned, earned) || other.earned == earned)&&(identical(other.isNext, isNext) || other.isNext == isNext)&&(identical(other.done, done) || other.done == done)&&(identical(other.total, total) || other.total == total)&&(identical(other.collectedOn, collectedOn) || other.collectedOn == collectedOn));
}


@override
int get hashCode => Object.hash(runtimeType,chapterId,chapterNumber,themeId,figurineId,earned,isNext,done,total,collectedOn);

@override
String toString() {
  return 'MuseumEntry(chapterId: $chapterId, chapterNumber: $chapterNumber, themeId: $themeId, figurineId: $figurineId, earned: $earned, isNext: $isNext, done: $done, total: $total, collectedOn: $collectedOn)';
}


}

/// @nodoc
abstract mixin class _$MuseumEntryCopyWith<$Res> implements $MuseumEntryCopyWith<$Res> {
  factory _$MuseumEntryCopyWith(_MuseumEntry value, $Res Function(_MuseumEntry) _then) = __$MuseumEntryCopyWithImpl;
@override @useResult
$Res call({
 String chapterId, int chapterNumber, String themeId, String figurineId, bool earned, bool isNext, int done, int total, LocalDate? collectedOn
});




}
/// @nodoc
class __$MuseumEntryCopyWithImpl<$Res>
    implements _$MuseumEntryCopyWith<$Res> {
  __$MuseumEntryCopyWithImpl(this._self, this._then);

  final _MuseumEntry _self;
  final $Res Function(_MuseumEntry) _then;

/// Create a copy of MuseumEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chapterId = null,Object? chapterNumber = null,Object? themeId = null,Object? figurineId = null,Object? earned = null,Object? isNext = null,Object? done = null,Object? total = null,Object? collectedOn = freezed,}) {
  return _then(_MuseumEntry(
chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String,chapterNumber: null == chapterNumber ? _self.chapterNumber : chapterNumber // ignore: cast_nullable_to_non_nullable
as int,themeId: null == themeId ? _self.themeId : themeId // ignore: cast_nullable_to_non_nullable
as String,figurineId: null == figurineId ? _self.figurineId : figurineId // ignore: cast_nullable_to_non_nullable
as String,earned: null == earned ? _self.earned : earned // ignore: cast_nullable_to_non_nullable
as bool,isNext: null == isNext ? _self.isNext : isNext // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,collectedOn: freezed == collectedOn ? _self.collectedOn : collectedOn // ignore: cast_nullable_to_non_nullable
as LocalDate?,
  ));
}


}

/// @nodoc
mixin _$MuseumState {

/// The header's coin pill (`SaveService.coins`).
 int get coins;/// The collection card's "N / 10" (`museumCount`): how many [entries]
/// are [MuseumEntry.earned], not the save's raw `museum` list length
/// (D111 fix — they can differ until a fully-won chapter's figurine is
/// durably granted).
 int get collectedCount;/// The catalog's chapter count (`CatalogRepository.chapters.length`).
 int get totalChapters;/// The cabinet, one per chapter, chapter order.
 List<MuseumEntry> get entries;/// The locked/next modal's "▶ Play Level N" (`LevelResolver.homeRequest`,
/// the same request Home's PLAY starts).
 PlayRequest get homeRequest;/// The number that button shows (`SaveService.currentLevel`).
 int get homeLevelNumber;
/// Create a copy of MuseumState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuseumStateCopyWith<MuseumState> get copyWith => _$MuseumStateCopyWithImpl<MuseumState>(this as MuseumState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuseumState&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.collectedCount, collectedCount) || other.collectedCount == collectedCount)&&(identical(other.totalChapters, totalChapters) || other.totalChapters == totalChapters)&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.homeRequest, homeRequest) || other.homeRequest == homeRequest)&&(identical(other.homeLevelNumber, homeLevelNumber) || other.homeLevelNumber == homeLevelNumber));
}


@override
int get hashCode => Object.hash(runtimeType,coins,collectedCount,totalChapters,const DeepCollectionEquality().hash(entries),homeRequest,homeLevelNumber);

@override
String toString() {
  return 'MuseumState(coins: $coins, collectedCount: $collectedCount, totalChapters: $totalChapters, entries: $entries, homeRequest: $homeRequest, homeLevelNumber: $homeLevelNumber)';
}


}

/// @nodoc
abstract mixin class $MuseumStateCopyWith<$Res>  {
  factory $MuseumStateCopyWith(MuseumState value, $Res Function(MuseumState) _then) = _$MuseumStateCopyWithImpl;
@useResult
$Res call({
 int coins, int collectedCount, int totalChapters, List<MuseumEntry> entries, PlayRequest homeRequest, int homeLevelNumber
});


$PlayRequestCopyWith<$Res> get homeRequest;

}
/// @nodoc
class _$MuseumStateCopyWithImpl<$Res>
    implements $MuseumStateCopyWith<$Res> {
  _$MuseumStateCopyWithImpl(this._self, this._then);

  final MuseumState _self;
  final $Res Function(MuseumState) _then;

/// Create a copy of MuseumState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coins = null,Object? collectedCount = null,Object? totalChapters = null,Object? entries = null,Object? homeRequest = null,Object? homeLevelNumber = null,}) {
  return _then(_self.copyWith(
coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,collectedCount: null == collectedCount ? _self.collectedCount : collectedCount // ignore: cast_nullable_to_non_nullable
as int,totalChapters: null == totalChapters ? _self.totalChapters : totalChapters // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<MuseumEntry>,homeRequest: null == homeRequest ? _self.homeRequest : homeRequest // ignore: cast_nullable_to_non_nullable
as PlayRequest,homeLevelNumber: null == homeLevelNumber ? _self.homeLevelNumber : homeLevelNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of MuseumState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res> get homeRequest {
  
  return $PlayRequestCopyWith<$Res>(_self.homeRequest, (value) {
    return _then(_self.copyWith(homeRequest: value));
  });
}
}


/// Adds pattern-matching-related methods to [MuseumState].
extension MuseumStatePatterns on MuseumState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuseumState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuseumState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuseumState value)  $default,){
final _that = this;
switch (_that) {
case _MuseumState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuseumState value)?  $default,){
final _that = this;
switch (_that) {
case _MuseumState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int coins,  int collectedCount,  int totalChapters,  List<MuseumEntry> entries,  PlayRequest homeRequest,  int homeLevelNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuseumState() when $default != null:
return $default(_that.coins,_that.collectedCount,_that.totalChapters,_that.entries,_that.homeRequest,_that.homeLevelNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int coins,  int collectedCount,  int totalChapters,  List<MuseumEntry> entries,  PlayRequest homeRequest,  int homeLevelNumber)  $default,) {final _that = this;
switch (_that) {
case _MuseumState():
return $default(_that.coins,_that.collectedCount,_that.totalChapters,_that.entries,_that.homeRequest,_that.homeLevelNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int coins,  int collectedCount,  int totalChapters,  List<MuseumEntry> entries,  PlayRequest homeRequest,  int homeLevelNumber)?  $default,) {final _that = this;
switch (_that) {
case _MuseumState() when $default != null:
return $default(_that.coins,_that.collectedCount,_that.totalChapters,_that.entries,_that.homeRequest,_that.homeLevelNumber);case _:
  return null;

}
}

}

/// @nodoc


class _MuseumState extends MuseumState {
  const _MuseumState({required this.coins, required this.collectedCount, required this.totalChapters, required final  List<MuseumEntry> entries, required this.homeRequest, required this.homeLevelNumber}): _entries = entries,super._();
  

/// The header's coin pill (`SaveService.coins`).
@override final  int coins;
/// The collection card's "N / 10" (`museumCount`): how many [entries]
/// are [MuseumEntry.earned], not the save's raw `museum` list length
/// (D111 fix — they can differ until a fully-won chapter's figurine is
/// durably granted).
@override final  int collectedCount;
/// The catalog's chapter count (`CatalogRepository.chapters.length`).
@override final  int totalChapters;
/// The cabinet, one per chapter, chapter order.
 final  List<MuseumEntry> _entries;
/// The cabinet, one per chapter, chapter order.
@override List<MuseumEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

/// The locked/next modal's "▶ Play Level N" (`LevelResolver.homeRequest`,
/// the same request Home's PLAY starts).
@override final  PlayRequest homeRequest;
/// The number that button shows (`SaveService.currentLevel`).
@override final  int homeLevelNumber;

/// Create a copy of MuseumState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuseumStateCopyWith<_MuseumState> get copyWith => __$MuseumStateCopyWithImpl<_MuseumState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuseumState&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.collectedCount, collectedCount) || other.collectedCount == collectedCount)&&(identical(other.totalChapters, totalChapters) || other.totalChapters == totalChapters)&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.homeRequest, homeRequest) || other.homeRequest == homeRequest)&&(identical(other.homeLevelNumber, homeLevelNumber) || other.homeLevelNumber == homeLevelNumber));
}


@override
int get hashCode => Object.hash(runtimeType,coins,collectedCount,totalChapters,const DeepCollectionEquality().hash(_entries),homeRequest,homeLevelNumber);

@override
String toString() {
  return 'MuseumState(coins: $coins, collectedCount: $collectedCount, totalChapters: $totalChapters, entries: $entries, homeRequest: $homeRequest, homeLevelNumber: $homeLevelNumber)';
}


}

/// @nodoc
abstract mixin class _$MuseumStateCopyWith<$Res> implements $MuseumStateCopyWith<$Res> {
  factory _$MuseumStateCopyWith(_MuseumState value, $Res Function(_MuseumState) _then) = __$MuseumStateCopyWithImpl;
@override @useResult
$Res call({
 int coins, int collectedCount, int totalChapters, List<MuseumEntry> entries, PlayRequest homeRequest, int homeLevelNumber
});


@override $PlayRequestCopyWith<$Res> get homeRequest;

}
/// @nodoc
class __$MuseumStateCopyWithImpl<$Res>
    implements _$MuseumStateCopyWith<$Res> {
  __$MuseumStateCopyWithImpl(this._self, this._then);

  final _MuseumState _self;
  final $Res Function(_MuseumState) _then;

/// Create a copy of MuseumState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coins = null,Object? collectedCount = null,Object? totalChapters = null,Object? entries = null,Object? homeRequest = null,Object? homeLevelNumber = null,}) {
  return _then(_MuseumState(
coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,collectedCount: null == collectedCount ? _self.collectedCount : collectedCount // ignore: cast_nullable_to_non_nullable
as int,totalChapters: null == totalChapters ? _self.totalChapters : totalChapters // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<MuseumEntry>,homeRequest: null == homeRequest ? _self.homeRequest : homeRequest // ignore: cast_nullable_to_non_nullable
as PlayRequest,homeLevelNumber: null == homeLevelNumber ? _self.homeLevelNumber : homeLevelNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of MuseumState
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
