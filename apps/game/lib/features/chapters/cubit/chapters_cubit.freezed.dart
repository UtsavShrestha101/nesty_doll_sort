// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chapters_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChaptersState {

/// The header's coin pill (`SaveService.coins`).
 int get coins;/// Every catalog chapter, in order: all ten render up front, future
/// ones locked.
 List<ChapterSection> get chapters;/// Home's PLAY level (`SaveService.document.currentLevel`): the header's
/// overall "Level {level} of {total}" line (owner's simulator review,
/// 2026-09-28, design request I.4, "cool, clean, elegant, addictive").
 int get currentLevel;/// Every catalog chapter's level count added up (200 at launch); the
/// overall line's denominator.
 int get totalLevels;
/// Create a copy of ChaptersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChaptersStateCopyWith<ChaptersState> get copyWith => _$ChaptersStateCopyWithImpl<ChaptersState>(this as ChaptersState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChaptersState&&(identical(other.coins, coins) || other.coins == coins)&&const DeepCollectionEquality().equals(other.chapters, chapters)&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel)&&(identical(other.totalLevels, totalLevels) || other.totalLevels == totalLevels));
}


@override
int get hashCode => Object.hash(runtimeType,coins,const DeepCollectionEquality().hash(chapters),currentLevel,totalLevels);

@override
String toString() {
  return 'ChaptersState(coins: $coins, chapters: $chapters, currentLevel: $currentLevel, totalLevels: $totalLevels)';
}


}

/// @nodoc
abstract mixin class $ChaptersStateCopyWith<$Res>  {
  factory $ChaptersStateCopyWith(ChaptersState value, $Res Function(ChaptersState) _then) = _$ChaptersStateCopyWithImpl;
@useResult
$Res call({
 int coins, List<ChapterSection> chapters, int currentLevel, int totalLevels
});




}
/// @nodoc
class _$ChaptersStateCopyWithImpl<$Res>
    implements $ChaptersStateCopyWith<$Res> {
  _$ChaptersStateCopyWithImpl(this._self, this._then);

  final ChaptersState _self;
  final $Res Function(ChaptersState) _then;

/// Create a copy of ChaptersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coins = null,Object? chapters = null,Object? currentLevel = null,Object? totalLevels = null,}) {
  return _then(_self.copyWith(
coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,chapters: null == chapters ? _self.chapters : chapters // ignore: cast_nullable_to_non_nullable
as List<ChapterSection>,currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as int,totalLevels: null == totalLevels ? _self.totalLevels : totalLevels // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChaptersState].
extension ChaptersStatePatterns on ChaptersState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChaptersState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChaptersState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChaptersState value)  $default,){
final _that = this;
switch (_that) {
case _ChaptersState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChaptersState value)?  $default,){
final _that = this;
switch (_that) {
case _ChaptersState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int coins,  List<ChapterSection> chapters,  int currentLevel,  int totalLevels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChaptersState() when $default != null:
return $default(_that.coins,_that.chapters,_that.currentLevel,_that.totalLevels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int coins,  List<ChapterSection> chapters,  int currentLevel,  int totalLevels)  $default,) {final _that = this;
switch (_that) {
case _ChaptersState():
return $default(_that.coins,_that.chapters,_that.currentLevel,_that.totalLevels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int coins,  List<ChapterSection> chapters,  int currentLevel,  int totalLevels)?  $default,) {final _that = this;
switch (_that) {
case _ChaptersState() when $default != null:
return $default(_that.coins,_that.chapters,_that.currentLevel,_that.totalLevels);case _:
  return null;

}
}

}

/// @nodoc


class _ChaptersState extends ChaptersState {
  const _ChaptersState({this.coins = 0, final  List<ChapterSection> chapters = const <ChapterSection>[], this.currentLevel = 1, this.totalLevels = 0}): _chapters = chapters,super._();
  

/// The header's coin pill (`SaveService.coins`).
@override@JsonKey() final  int coins;
/// Every catalog chapter, in order: all ten render up front, future
/// ones locked.
 final  List<ChapterSection> _chapters;
/// Every catalog chapter, in order: all ten render up front, future
/// ones locked.
@override@JsonKey() List<ChapterSection> get chapters {
  if (_chapters is EqualUnmodifiableListView) return _chapters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chapters);
}

/// Home's PLAY level (`SaveService.document.currentLevel`): the header's
/// overall "Level {level} of {total}" line (owner's simulator review,
/// 2026-09-28, design request I.4, "cool, clean, elegant, addictive").
@override@JsonKey() final  int currentLevel;
/// Every catalog chapter's level count added up (200 at launch); the
/// overall line's denominator.
@override@JsonKey() final  int totalLevels;

/// Create a copy of ChaptersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChaptersStateCopyWith<_ChaptersState> get copyWith => __$ChaptersStateCopyWithImpl<_ChaptersState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChaptersState&&(identical(other.coins, coins) || other.coins == coins)&&const DeepCollectionEquality().equals(other._chapters, _chapters)&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel)&&(identical(other.totalLevels, totalLevels) || other.totalLevels == totalLevels));
}


@override
int get hashCode => Object.hash(runtimeType,coins,const DeepCollectionEquality().hash(_chapters),currentLevel,totalLevels);

@override
String toString() {
  return 'ChaptersState(coins: $coins, chapters: $chapters, currentLevel: $currentLevel, totalLevels: $totalLevels)';
}


}

/// @nodoc
abstract mixin class _$ChaptersStateCopyWith<$Res> implements $ChaptersStateCopyWith<$Res> {
  factory _$ChaptersStateCopyWith(_ChaptersState value, $Res Function(_ChaptersState) _then) = __$ChaptersStateCopyWithImpl;
@override @useResult
$Res call({
 int coins, List<ChapterSection> chapters, int currentLevel, int totalLevels
});




}
/// @nodoc
class __$ChaptersStateCopyWithImpl<$Res>
    implements _$ChaptersStateCopyWith<$Res> {
  __$ChaptersStateCopyWithImpl(this._self, this._then);

  final _ChaptersState _self;
  final $Res Function(_ChaptersState) _then;

/// Create a copy of ChaptersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coins = null,Object? chapters = null,Object? currentLevel = null,Object? totalLevels = null,}) {
  return _then(_ChaptersState(
coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,chapters: null == chapters ? _self._chapters : chapters // ignore: cast_nullable_to_non_nullable
as List<ChapterSection>,currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as int,totalLevels: null == totalLevels ? _self.totalLevels : totalLevels // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ChapterSection {

/// `ch01` … `ch10`: the `chapterName` select key and the theme.
 String get chapterId;/// 1-based.
 int get number;/// The chapter's levels, first to last (20 per chapter, spec §7.1).
 List<ChapterLevel> get levels;/// The chapter's board theme (`ChapterTheme.byId`), so its card can
/// carry the theme's colour (owner's simulator review, 2026-09-28,
/// D111: "give each chapter its character"). '' when the catalog entry
/// somehow has none (falls back to a neutral tint).
 String get themeId;/// The figurine this chapter awards (`FigurineImage`, `museumFamilyLabel`
/// / `museumSoonLabel`; same ids as the Museum). '' when the catalog
/// entry somehow has none.
 String get figurineId;/// Mirrors `MuseumEntry.earned` (D111's "show it as ready" fix): the
/// save's `museum` list, or every level in [levels] already won even
/// before `museum` catches up. Never a stale "not earned" once [won]
/// reaches [total].
 bool get figurineEarned;/// Best stars over the chapter's won levels (`levelStars`; spec-prop
/// §7.10, §10.2 #18; m7-design P3.7): the card's and the folded row's
/// "38/60".
 int get stars;/// `StarRating.maxStars` × the chapter's levels the bundle has with a
/// par (60 for a full chapter at launch): the total beside [stars].
 int get starsPossible;
/// Create a copy of ChapterSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChapterSectionCopyWith<ChapterSection> get copyWith => _$ChapterSectionCopyWithImpl<ChapterSection>(this as ChapterSection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChapterSection&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.number, number) || other.number == number)&&const DeepCollectionEquality().equals(other.levels, levels)&&(identical(other.themeId, themeId) || other.themeId == themeId)&&(identical(other.figurineId, figurineId) || other.figurineId == figurineId)&&(identical(other.figurineEarned, figurineEarned) || other.figurineEarned == figurineEarned)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.starsPossible, starsPossible) || other.starsPossible == starsPossible));
}


@override
int get hashCode => Object.hash(runtimeType,chapterId,number,const DeepCollectionEquality().hash(levels),themeId,figurineId,figurineEarned,stars,starsPossible);

@override
String toString() {
  return 'ChapterSection(chapterId: $chapterId, number: $number, levels: $levels, themeId: $themeId, figurineId: $figurineId, figurineEarned: $figurineEarned, stars: $stars, starsPossible: $starsPossible)';
}


}

/// @nodoc
abstract mixin class $ChapterSectionCopyWith<$Res>  {
  factory $ChapterSectionCopyWith(ChapterSection value, $Res Function(ChapterSection) _then) = _$ChapterSectionCopyWithImpl;
@useResult
$Res call({
 String chapterId, int number, List<ChapterLevel> levels, String themeId, String figurineId, bool figurineEarned, int stars, int starsPossible
});




}
/// @nodoc
class _$ChapterSectionCopyWithImpl<$Res>
    implements $ChapterSectionCopyWith<$Res> {
  _$ChapterSectionCopyWithImpl(this._self, this._then);

  final ChapterSection _self;
  final $Res Function(ChapterSection) _then;

/// Create a copy of ChapterSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chapterId = null,Object? number = null,Object? levels = null,Object? themeId = null,Object? figurineId = null,Object? figurineEarned = null,Object? stars = null,Object? starsPossible = null,}) {
  return _then(_self.copyWith(
chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as List<ChapterLevel>,themeId: null == themeId ? _self.themeId : themeId // ignore: cast_nullable_to_non_nullable
as String,figurineId: null == figurineId ? _self.figurineId : figurineId // ignore: cast_nullable_to_non_nullable
as String,figurineEarned: null == figurineEarned ? _self.figurineEarned : figurineEarned // ignore: cast_nullable_to_non_nullable
as bool,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,starsPossible: null == starsPossible ? _self.starsPossible : starsPossible // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChapterSection].
extension ChapterSectionPatterns on ChapterSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChapterSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChapterSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChapterSection value)  $default,){
final _that = this;
switch (_that) {
case _ChapterSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChapterSection value)?  $default,){
final _that = this;
switch (_that) {
case _ChapterSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String chapterId,  int number,  List<ChapterLevel> levels,  String themeId,  String figurineId,  bool figurineEarned,  int stars,  int starsPossible)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChapterSection() when $default != null:
return $default(_that.chapterId,_that.number,_that.levels,_that.themeId,_that.figurineId,_that.figurineEarned,_that.stars,_that.starsPossible);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String chapterId,  int number,  List<ChapterLevel> levels,  String themeId,  String figurineId,  bool figurineEarned,  int stars,  int starsPossible)  $default,) {final _that = this;
switch (_that) {
case _ChapterSection():
return $default(_that.chapterId,_that.number,_that.levels,_that.themeId,_that.figurineId,_that.figurineEarned,_that.stars,_that.starsPossible);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String chapterId,  int number,  List<ChapterLevel> levels,  String themeId,  String figurineId,  bool figurineEarned,  int stars,  int starsPossible)?  $default,) {final _that = this;
switch (_that) {
case _ChapterSection() when $default != null:
return $default(_that.chapterId,_that.number,_that.levels,_that.themeId,_that.figurineId,_that.figurineEarned,_that.stars,_that.starsPossible);case _:
  return null;

}
}

}

/// @nodoc


class _ChapterSection extends ChapterSection {
  const _ChapterSection({required this.chapterId, required this.number, final  List<ChapterLevel> levels = const <ChapterLevel>[], this.themeId = '', this.figurineId = '', this.figurineEarned = false, this.stars = 0, this.starsPossible = 0}): _levels = levels,super._();
  

/// `ch01` … `ch10`: the `chapterName` select key and the theme.
@override final  String chapterId;
/// 1-based.
@override final  int number;
/// The chapter's levels, first to last (20 per chapter, spec §7.1).
 final  List<ChapterLevel> _levels;
/// The chapter's levels, first to last (20 per chapter, spec §7.1).
@override@JsonKey() List<ChapterLevel> get levels {
  if (_levels is EqualUnmodifiableListView) return _levels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_levels);
}

/// The chapter's board theme (`ChapterTheme.byId`), so its card can
/// carry the theme's colour (owner's simulator review, 2026-09-28,
/// D111: "give each chapter its character"). '' when the catalog entry
/// somehow has none (falls back to a neutral tint).
@override@JsonKey() final  String themeId;
/// The figurine this chapter awards (`FigurineImage`, `museumFamilyLabel`
/// / `museumSoonLabel`; same ids as the Museum). '' when the catalog
/// entry somehow has none.
@override@JsonKey() final  String figurineId;
/// Mirrors `MuseumEntry.earned` (D111's "show it as ready" fix): the
/// save's `museum` list, or every level in [levels] already won even
/// before `museum` catches up. Never a stale "not earned" once [won]
/// reaches [total].
@override@JsonKey() final  bool figurineEarned;
/// Best stars over the chapter's won levels (`levelStars`; spec-prop
/// §7.10, §10.2 #18; m7-design P3.7): the card's and the folded row's
/// "38/60".
@override@JsonKey() final  int stars;
/// `StarRating.maxStars` × the chapter's levels the bundle has with a
/// par (60 for a full chapter at launch): the total beside [stars].
@override@JsonKey() final  int starsPossible;

/// Create a copy of ChapterSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChapterSectionCopyWith<_ChapterSection> get copyWith => __$ChapterSectionCopyWithImpl<_ChapterSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChapterSection&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.number, number) || other.number == number)&&const DeepCollectionEquality().equals(other._levels, _levels)&&(identical(other.themeId, themeId) || other.themeId == themeId)&&(identical(other.figurineId, figurineId) || other.figurineId == figurineId)&&(identical(other.figurineEarned, figurineEarned) || other.figurineEarned == figurineEarned)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.starsPossible, starsPossible) || other.starsPossible == starsPossible));
}


@override
int get hashCode => Object.hash(runtimeType,chapterId,number,const DeepCollectionEquality().hash(_levels),themeId,figurineId,figurineEarned,stars,starsPossible);

@override
String toString() {
  return 'ChapterSection(chapterId: $chapterId, number: $number, levels: $levels, themeId: $themeId, figurineId: $figurineId, figurineEarned: $figurineEarned, stars: $stars, starsPossible: $starsPossible)';
}


}

/// @nodoc
abstract mixin class _$ChapterSectionCopyWith<$Res> implements $ChapterSectionCopyWith<$Res> {
  factory _$ChapterSectionCopyWith(_ChapterSection value, $Res Function(_ChapterSection) _then) = __$ChapterSectionCopyWithImpl;
@override @useResult
$Res call({
 String chapterId, int number, List<ChapterLevel> levels, String themeId, String figurineId, bool figurineEarned, int stars, int starsPossible
});




}
/// @nodoc
class __$ChapterSectionCopyWithImpl<$Res>
    implements _$ChapterSectionCopyWith<$Res> {
  __$ChapterSectionCopyWithImpl(this._self, this._then);

  final _ChapterSection _self;
  final $Res Function(_ChapterSection) _then;

/// Create a copy of ChapterSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chapterId = null,Object? number = null,Object? levels = null,Object? themeId = null,Object? figurineId = null,Object? figurineEarned = null,Object? stars = null,Object? starsPossible = null,}) {
  return _then(_ChapterSection(
chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,levels: null == levels ? _self._levels : levels // ignore: cast_nullable_to_non_nullable
as List<ChapterLevel>,themeId: null == themeId ? _self.themeId : themeId // ignore: cast_nullable_to_non_nullable
as String,figurineId: null == figurineId ? _self.figurineId : figurineId // ignore: cast_nullable_to_non_nullable
as String,figurineEarned: null == figurineEarned ? _self.figurineEarned : figurineEarned // ignore: cast_nullable_to_non_nullable
as bool,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,starsPossible: null == starsPossible ? _self.starsPossible : starsPossible // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ChapterLevel {

/// The 1-based global play order (the number on the cell).
 int get order; ChapterLevelStatus get status;/// The fewest moves of the bundle's current version of it
/// (`SaveService.bestMovesFor`); null when won before best moves were
/// kept (a migrated save shows the check mark without "Best").
 int? get bestMoves;/// The bundle's own tier (spec §6.6); locked when the level isn't in the
/// bundle. Draws the cell's thin HARD/SUPER HARD edge (owner's simulator
/// review, 2026-09-28, design request I.4); easy/medium draw no edge,
/// the same `TierChip.shows` cut.
 Tier get tier;/// A won cell's best stars, 1–3 (`levelStars[levelId]`; m7-design
/// P3.7); null for a current or locked cell, and for a level won
/// before stars that the load-time backfill gave none (no par).
 int? get stars;/// The 3-star threshold in moves (`StarRating.threshold(par, star3)`),
/// for the level card's "3 stars at N moves or fewer" (frame 10.4b);
/// null without a par. Only meaningful for a won level.
 int? get target;/// The bundle's level is here, in the chapter's 10th place: the milestone
/// chest's cell (frame 10.4; spec-prop §1.1).
 bool get isChest;/// The chapter's last level: the finale's flag (frame 10.4).
 bool get isFinale;
/// Create a copy of ChapterLevel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChapterLevelCopyWith<ChapterLevel> get copyWith => _$ChapterLevelCopyWithImpl<ChapterLevel>(this as ChapterLevel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChapterLevel&&(identical(other.order, order) || other.order == order)&&(identical(other.status, status) || other.status == status)&&(identical(other.bestMoves, bestMoves) || other.bestMoves == bestMoves)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.target, target) || other.target == target)&&(identical(other.isChest, isChest) || other.isChest == isChest)&&(identical(other.isFinale, isFinale) || other.isFinale == isFinale));
}


@override
int get hashCode => Object.hash(runtimeType,order,status,bestMoves,tier,stars,target,isChest,isFinale);

@override
String toString() {
  return 'ChapterLevel(order: $order, status: $status, bestMoves: $bestMoves, tier: $tier, stars: $stars, target: $target, isChest: $isChest, isFinale: $isFinale)';
}


}

/// @nodoc
abstract mixin class $ChapterLevelCopyWith<$Res>  {
  factory $ChapterLevelCopyWith(ChapterLevel value, $Res Function(ChapterLevel) _then) = _$ChapterLevelCopyWithImpl;
@useResult
$Res call({
 int order, ChapterLevelStatus status, int? bestMoves, Tier tier, int? stars, int? target, bool isChest, bool isFinale
});




}
/// @nodoc
class _$ChapterLevelCopyWithImpl<$Res>
    implements $ChapterLevelCopyWith<$Res> {
  _$ChapterLevelCopyWithImpl(this._self, this._then);

  final ChapterLevel _self;
  final $Res Function(ChapterLevel) _then;

/// Create a copy of ChapterLevel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? order = null,Object? status = null,Object? bestMoves = freezed,Object? tier = null,Object? stars = freezed,Object? target = freezed,Object? isChest = null,Object? isFinale = null,}) {
  return _then(_self.copyWith(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChapterLevelStatus,bestMoves: freezed == bestMoves ? _self.bestMoves : bestMoves // ignore: cast_nullable_to_non_nullable
as int?,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,stars: freezed == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int?,isChest: null == isChest ? _self.isChest : isChest // ignore: cast_nullable_to_non_nullable
as bool,isFinale: null == isFinale ? _self.isFinale : isFinale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChapterLevel].
extension ChapterLevelPatterns on ChapterLevel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChapterLevel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChapterLevel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChapterLevel value)  $default,){
final _that = this;
switch (_that) {
case _ChapterLevel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChapterLevel value)?  $default,){
final _that = this;
switch (_that) {
case _ChapterLevel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int order,  ChapterLevelStatus status,  int? bestMoves,  Tier tier,  int? stars,  int? target,  bool isChest,  bool isFinale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChapterLevel() when $default != null:
return $default(_that.order,_that.status,_that.bestMoves,_that.tier,_that.stars,_that.target,_that.isChest,_that.isFinale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int order,  ChapterLevelStatus status,  int? bestMoves,  Tier tier,  int? stars,  int? target,  bool isChest,  bool isFinale)  $default,) {final _that = this;
switch (_that) {
case _ChapterLevel():
return $default(_that.order,_that.status,_that.bestMoves,_that.tier,_that.stars,_that.target,_that.isChest,_that.isFinale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int order,  ChapterLevelStatus status,  int? bestMoves,  Tier tier,  int? stars,  int? target,  bool isChest,  bool isFinale)?  $default,) {final _that = this;
switch (_that) {
case _ChapterLevel() when $default != null:
return $default(_that.order,_that.status,_that.bestMoves,_that.tier,_that.stars,_that.target,_that.isChest,_that.isFinale);case _:
  return null;

}
}

}

/// @nodoc


class _ChapterLevel extends ChapterLevel {
  const _ChapterLevel({required this.order, this.status = ChapterLevelStatus.locked, this.bestMoves, this.tier = Tier.easy, this.stars, this.target, this.isChest = false, this.isFinale = false}): super._();
  

/// The 1-based global play order (the number on the cell).
@override final  int order;
@override@JsonKey() final  ChapterLevelStatus status;
/// The fewest moves of the bundle's current version of it
/// (`SaveService.bestMovesFor`); null when won before best moves were
/// kept (a migrated save shows the check mark without "Best").
@override final  int? bestMoves;
/// The bundle's own tier (spec §6.6); locked when the level isn't in the
/// bundle. Draws the cell's thin HARD/SUPER HARD edge (owner's simulator
/// review, 2026-09-28, design request I.4); easy/medium draw no edge,
/// the same `TierChip.shows` cut.
@override@JsonKey() final  Tier tier;
/// A won cell's best stars, 1–3 (`levelStars[levelId]`; m7-design
/// P3.7); null for a current or locked cell, and for a level won
/// before stars that the load-time backfill gave none (no par).
@override final  int? stars;
/// The 3-star threshold in moves (`StarRating.threshold(par, star3)`),
/// for the level card's "3 stars at N moves or fewer" (frame 10.4b);
/// null without a par. Only meaningful for a won level.
@override final  int? target;
/// The bundle's level is here, in the chapter's 10th place: the milestone
/// chest's cell (frame 10.4; spec-prop §1.1).
@override@JsonKey() final  bool isChest;
/// The chapter's last level: the finale's flag (frame 10.4).
@override@JsonKey() final  bool isFinale;

/// Create a copy of ChapterLevel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChapterLevelCopyWith<_ChapterLevel> get copyWith => __$ChapterLevelCopyWithImpl<_ChapterLevel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChapterLevel&&(identical(other.order, order) || other.order == order)&&(identical(other.status, status) || other.status == status)&&(identical(other.bestMoves, bestMoves) || other.bestMoves == bestMoves)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.target, target) || other.target == target)&&(identical(other.isChest, isChest) || other.isChest == isChest)&&(identical(other.isFinale, isFinale) || other.isFinale == isFinale));
}


@override
int get hashCode => Object.hash(runtimeType,order,status,bestMoves,tier,stars,target,isChest,isFinale);

@override
String toString() {
  return 'ChapterLevel(order: $order, status: $status, bestMoves: $bestMoves, tier: $tier, stars: $stars, target: $target, isChest: $isChest, isFinale: $isFinale)';
}


}

/// @nodoc
abstract mixin class _$ChapterLevelCopyWith<$Res> implements $ChapterLevelCopyWith<$Res> {
  factory _$ChapterLevelCopyWith(_ChapterLevel value, $Res Function(_ChapterLevel) _then) = __$ChapterLevelCopyWithImpl;
@override @useResult
$Res call({
 int order, ChapterLevelStatus status, int? bestMoves, Tier tier, int? stars, int? target, bool isChest, bool isFinale
});




}
/// @nodoc
class __$ChapterLevelCopyWithImpl<$Res>
    implements _$ChapterLevelCopyWith<$Res> {
  __$ChapterLevelCopyWithImpl(this._self, this._then);

  final _ChapterLevel _self;
  final $Res Function(_ChapterLevel) _then;

/// Create a copy of ChapterLevel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? order = null,Object? status = null,Object? bestMoves = freezed,Object? tier = null,Object? stars = freezed,Object? target = freezed,Object? isChest = null,Object? isFinale = null,}) {
  return _then(_ChapterLevel(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChapterLevelStatus,bestMoves: freezed == bestMoves ? _self.bestMoves : bestMoves // ignore: cast_nullable_to_non_nullable
as int?,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,stars: freezed == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int?,isChest: null == isChest ? _self.isChest : isChest // ignore: cast_nullable_to_non_nullable
as bool,isFinale: null == isFinale ? _self.isFinale : isFinale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
