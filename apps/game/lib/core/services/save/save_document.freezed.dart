// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'save_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SaveDocument {

/// The schema this app writes ([currentSchema]).
 int get schema;/// The published level Home's PLAY starts, 1-based (§13.3). Past the
/// last level it stays at `levelCount + 1`, and PLAY starts
/// `bonus.next` (m3-design §7.4).
 int get currentLevel;/// The highest [currentLevel] reached (§13.3). The daily unlocks at 3
/// (Level 2 won, m3-design §8.3).
 int get highestLevel;/// Spec §7.3. A fresh install has 0 (Q46).
 int get coins;/// Hints and extra slots held (§8, §13.3), the starter gift first.
 BoosterInventory get inventory;/// Spec §9.2; always false until M6.
 bool get adsRemoved;/// Skin ids owned, `classic` always among them (§7.4).
 List<String> get ownedSkins;/// The skin boards use (§7.4); always one of [ownedSkins].
 String get selectedSkin;/// Themes bought, and `ch01`. A chapter's own theme is owned once the
/// chapter is reached, whether or not it is listed (frame 7.7,
/// m3-design §9.4).
 List<String> get ownedThemes;/// Null: "Match each chapter" (§7.4, frame 7.7).
 String? get selectedTheme;/// Chapter ids whose figurine the player has (§7.2, §13.3), in the
/// order collected.
 List<String> get museum;/// The local date each figurine was collected (frame 6.2 "Collected ·
/// Sep 12"; an M3 addition, D22). A [museum] id without a date shows
/// "Collected".
 Map<String, LocalDate> get museumCollected;/// The daily puzzle and its streak (§7.5, m3-design §8).
 DailyProgress get daily;/// The campaign or bonus level in progress (§13.3; m3-design §3.4).
/// The daily's board is [DailyProgress.inProgress].
 InProgressLevel? get inProgress;/// Interstitial pacing (§9.1, §13.3); read and written from M6.
 AdCounters get adCounters;/// Spec §13.3 `stats`.
 SaveStats get stats;/// `IntroMechanic.id`s whose card was dismissed (frames 4.1–4.3; an M3
/// addition).
 List<String> get seenIntros;/// The Level 2 swallow demo was done (frames 1.3–1.6; an M3 addition).
 bool get tutorialDone;/// Bonus Endless (§7.1; an M3 addition).
 BonusProgress get bonus;/// A local random id for the Settings footer ("Player ID 7F3A-21C9",
/// frame 8.1; an M3 addition, Q74). `SaveService.load` makes one when
/// it is missing, so it is null only in a document not yet loaded.
 String? get playerId;/// Fewest moves per bundled level, keyed `LevelBests.key` (`L0024@2`):
/// every win of a campaign level or a replay (spec-prop §7.1, §13.3;
/// m7-design §11). Generated boards keep none.
 Map<String, int> get levelBests;/// Best stars per bundled level id (`L0024` → 1–3): the most any win
/// of a campaign level or a replay has earned (spec-prop §7.10, §13.3;
/// D125; m7-design P3.4). Kept per level id, so a new level version
/// keeps them (Q117); never lowered. `SaveService.backfillLevelStars`
/// fills it at load for levels won before stars existed (Q120).
/// Generated boards (daily, bonus, race) keep none.
 Map<String, int> get levelStars;/// The one-time star tip ("Fewer moves earn more stars…") was shown on
/// the first win below 3 stars (Q119; m7-design P3.6), so no later
/// win card shows it.
 bool get starTipShown;/// Lifetime records and badges (spec-prop §7.8, §13.3; m7-design §12).
 SaveRecords get records;/// Milestone chests already opened (spec-prop §7.3; m7-design §9).
 ChestProgress get chests;/// vs Computer, per rival (spec-prop §7.7, §13.3; m7-design §3). The
/// race itself lands in M7 phase 2; the fields are schema 2's.
 RaceProgress get race;/// Top-level keys this schema doesn't know (a newer app's), kept as they
/// were and written back (m3-design §3.3).
 Map<String, Object?> get unknown;
/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveDocumentCopyWith<SaveDocument> get copyWith => _$SaveDocumentCopyWithImpl<SaveDocument>(this as SaveDocument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveDocument&&(identical(other.schema, schema) || other.schema == schema)&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel)&&(identical(other.highestLevel, highestLevel) || other.highestLevel == highestLevel)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.inventory, inventory) || other.inventory == inventory)&&(identical(other.adsRemoved, adsRemoved) || other.adsRemoved == adsRemoved)&&const DeepCollectionEquality().equals(other.ownedSkins, ownedSkins)&&(identical(other.selectedSkin, selectedSkin) || other.selectedSkin == selectedSkin)&&const DeepCollectionEquality().equals(other.ownedThemes, ownedThemes)&&(identical(other.selectedTheme, selectedTheme) || other.selectedTheme == selectedTheme)&&const DeepCollectionEquality().equals(other.museum, museum)&&const DeepCollectionEquality().equals(other.museumCollected, museumCollected)&&(identical(other.daily, daily) || other.daily == daily)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.adCounters, adCounters) || other.adCounters == adCounters)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.seenIntros, seenIntros)&&(identical(other.tutorialDone, tutorialDone) || other.tutorialDone == tutorialDone)&&(identical(other.bonus, bonus) || other.bonus == bonus)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&const DeepCollectionEquality().equals(other.levelBests, levelBests)&&const DeepCollectionEquality().equals(other.levelStars, levelStars)&&(identical(other.starTipShown, starTipShown) || other.starTipShown == starTipShown)&&(identical(other.records, records) || other.records == records)&&(identical(other.chests, chests) || other.chests == chests)&&(identical(other.race, race) || other.race == race)&&const DeepCollectionEquality().equals(other.unknown, unknown));
}


@override
int get hashCode => Object.hashAll([runtimeType,schema,currentLevel,highestLevel,coins,inventory,adsRemoved,const DeepCollectionEquality().hash(ownedSkins),selectedSkin,const DeepCollectionEquality().hash(ownedThemes),selectedTheme,const DeepCollectionEquality().hash(museum),const DeepCollectionEquality().hash(museumCollected),daily,inProgress,adCounters,stats,const DeepCollectionEquality().hash(seenIntros),tutorialDone,bonus,playerId,const DeepCollectionEquality().hash(levelBests),const DeepCollectionEquality().hash(levelStars),starTipShown,records,chests,race,const DeepCollectionEquality().hash(unknown)]);

@override
String toString() {
  return 'SaveDocument(schema: $schema, currentLevel: $currentLevel, highestLevel: $highestLevel, coins: $coins, inventory: $inventory, adsRemoved: $adsRemoved, ownedSkins: $ownedSkins, selectedSkin: $selectedSkin, ownedThemes: $ownedThemes, selectedTheme: $selectedTheme, museum: $museum, museumCollected: $museumCollected, daily: $daily, inProgress: $inProgress, adCounters: $adCounters, stats: $stats, seenIntros: $seenIntros, tutorialDone: $tutorialDone, bonus: $bonus, playerId: $playerId, levelBests: $levelBests, levelStars: $levelStars, starTipShown: $starTipShown, records: $records, chests: $chests, race: $race, unknown: $unknown)';
}


}

/// @nodoc
abstract mixin class $SaveDocumentCopyWith<$Res>  {
  factory $SaveDocumentCopyWith(SaveDocument value, $Res Function(SaveDocument) _then) = _$SaveDocumentCopyWithImpl;
@useResult
$Res call({
 int schema, int currentLevel, int highestLevel, int coins, BoosterInventory inventory, bool adsRemoved, List<String> ownedSkins, String selectedSkin, List<String> ownedThemes, String? selectedTheme, List<String> museum, Map<String, LocalDate> museumCollected, DailyProgress daily, InProgressLevel? inProgress, AdCounters adCounters, SaveStats stats, List<String> seenIntros, bool tutorialDone, BonusProgress bonus, String? playerId, Map<String, int> levelBests, Map<String, int> levelStars, bool starTipShown, SaveRecords records, ChestProgress chests, RaceProgress race, Map<String, Object?> unknown
});


$BoosterInventoryCopyWith<$Res> get inventory;$DailyProgressCopyWith<$Res> get daily;$InProgressLevelCopyWith<$Res>? get inProgress;$AdCountersCopyWith<$Res> get adCounters;$SaveStatsCopyWith<$Res> get stats;$BonusProgressCopyWith<$Res> get bonus;$SaveRecordsCopyWith<$Res> get records;$ChestProgressCopyWith<$Res> get chests;$RaceProgressCopyWith<$Res> get race;

}
/// @nodoc
class _$SaveDocumentCopyWithImpl<$Res>
    implements $SaveDocumentCopyWith<$Res> {
  _$SaveDocumentCopyWithImpl(this._self, this._then);

  final SaveDocument _self;
  final $Res Function(SaveDocument) _then;

/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schema = null,Object? currentLevel = null,Object? highestLevel = null,Object? coins = null,Object? inventory = null,Object? adsRemoved = null,Object? ownedSkins = null,Object? selectedSkin = null,Object? ownedThemes = null,Object? selectedTheme = freezed,Object? museum = null,Object? museumCollected = null,Object? daily = null,Object? inProgress = freezed,Object? adCounters = null,Object? stats = null,Object? seenIntros = null,Object? tutorialDone = null,Object? bonus = null,Object? playerId = freezed,Object? levelBests = null,Object? levelStars = null,Object? starTipShown = null,Object? records = null,Object? chests = null,Object? race = null,Object? unknown = null,}) {
  return _then(_self.copyWith(
schema: null == schema ? _self.schema : schema // ignore: cast_nullable_to_non_nullable
as int,currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as int,highestLevel: null == highestLevel ? _self.highestLevel : highestLevel // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,inventory: null == inventory ? _self.inventory : inventory // ignore: cast_nullable_to_non_nullable
as BoosterInventory,adsRemoved: null == adsRemoved ? _self.adsRemoved : adsRemoved // ignore: cast_nullable_to_non_nullable
as bool,ownedSkins: null == ownedSkins ? _self.ownedSkins : ownedSkins // ignore: cast_nullable_to_non_nullable
as List<String>,selectedSkin: null == selectedSkin ? _self.selectedSkin : selectedSkin // ignore: cast_nullable_to_non_nullable
as String,ownedThemes: null == ownedThemes ? _self.ownedThemes : ownedThemes // ignore: cast_nullable_to_non_nullable
as List<String>,selectedTheme: freezed == selectedTheme ? _self.selectedTheme : selectedTheme // ignore: cast_nullable_to_non_nullable
as String?,museum: null == museum ? _self.museum : museum // ignore: cast_nullable_to_non_nullable
as List<String>,museumCollected: null == museumCollected ? _self.museumCollected : museumCollected // ignore: cast_nullable_to_non_nullable
as Map<String, LocalDate>,daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as DailyProgress,inProgress: freezed == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as InProgressLevel?,adCounters: null == adCounters ? _self.adCounters : adCounters // ignore: cast_nullable_to_non_nullable
as AdCounters,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as SaveStats,seenIntros: null == seenIntros ? _self.seenIntros : seenIntros // ignore: cast_nullable_to_non_nullable
as List<String>,tutorialDone: null == tutorialDone ? _self.tutorialDone : tutorialDone // ignore: cast_nullable_to_non_nullable
as bool,bonus: null == bonus ? _self.bonus : bonus // ignore: cast_nullable_to_non_nullable
as BonusProgress,playerId: freezed == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String?,levelBests: null == levelBests ? _self.levelBests : levelBests // ignore: cast_nullable_to_non_nullable
as Map<String, int>,levelStars: null == levelStars ? _self.levelStars : levelStars // ignore: cast_nullable_to_non_nullable
as Map<String, int>,starTipShown: null == starTipShown ? _self.starTipShown : starTipShown // ignore: cast_nullable_to_non_nullable
as bool,records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as SaveRecords,chests: null == chests ? _self.chests : chests // ignore: cast_nullable_to_non_nullable
as ChestProgress,race: null == race ? _self.race : race // ignore: cast_nullable_to_non_nullable
as RaceProgress,unknown: null == unknown ? _self.unknown : unknown // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoosterInventoryCopyWith<$Res> get inventory {
  
  return $BoosterInventoryCopyWith<$Res>(_self.inventory, (value) {
    return _then(_self.copyWith(inventory: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailyProgressCopyWith<$Res> get daily {
  
  return $DailyProgressCopyWith<$Res>(_self.daily, (value) {
    return _then(_self.copyWith(daily: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InProgressLevelCopyWith<$Res>? get inProgress {
    if (_self.inProgress == null) {
    return null;
  }

  return $InProgressLevelCopyWith<$Res>(_self.inProgress!, (value) {
    return _then(_self.copyWith(inProgress: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdCountersCopyWith<$Res> get adCounters {
  
  return $AdCountersCopyWith<$Res>(_self.adCounters, (value) {
    return _then(_self.copyWith(adCounters: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SaveStatsCopyWith<$Res> get stats {
  
  return $SaveStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BonusProgressCopyWith<$Res> get bonus {
  
  return $BonusProgressCopyWith<$Res>(_self.bonus, (value) {
    return _then(_self.copyWith(bonus: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SaveRecordsCopyWith<$Res> get records {
  
  return $SaveRecordsCopyWith<$Res>(_self.records, (value) {
    return _then(_self.copyWith(records: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChestProgressCopyWith<$Res> get chests {
  
  return $ChestProgressCopyWith<$Res>(_self.chests, (value) {
    return _then(_self.copyWith(chests: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RaceProgressCopyWith<$Res> get race {
  
  return $RaceProgressCopyWith<$Res>(_self.race, (value) {
    return _then(_self.copyWith(race: value));
  });
}
}


/// Adds pattern-matching-related methods to [SaveDocument].
extension SaveDocumentPatterns on SaveDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaveDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaveDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaveDocument value)  $default,){
final _that = this;
switch (_that) {
case _SaveDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaveDocument value)?  $default,){
final _that = this;
switch (_that) {
case _SaveDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schema,  int currentLevel,  int highestLevel,  int coins,  BoosterInventory inventory,  bool adsRemoved,  List<String> ownedSkins,  String selectedSkin,  List<String> ownedThemes,  String? selectedTheme,  List<String> museum,  Map<String, LocalDate> museumCollected,  DailyProgress daily,  InProgressLevel? inProgress,  AdCounters adCounters,  SaveStats stats,  List<String> seenIntros,  bool tutorialDone,  BonusProgress bonus,  String? playerId,  Map<String, int> levelBests,  Map<String, int> levelStars,  bool starTipShown,  SaveRecords records,  ChestProgress chests,  RaceProgress race,  Map<String, Object?> unknown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaveDocument() when $default != null:
return $default(_that.schema,_that.currentLevel,_that.highestLevel,_that.coins,_that.inventory,_that.adsRemoved,_that.ownedSkins,_that.selectedSkin,_that.ownedThemes,_that.selectedTheme,_that.museum,_that.museumCollected,_that.daily,_that.inProgress,_that.adCounters,_that.stats,_that.seenIntros,_that.tutorialDone,_that.bonus,_that.playerId,_that.levelBests,_that.levelStars,_that.starTipShown,_that.records,_that.chests,_that.race,_that.unknown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schema,  int currentLevel,  int highestLevel,  int coins,  BoosterInventory inventory,  bool adsRemoved,  List<String> ownedSkins,  String selectedSkin,  List<String> ownedThemes,  String? selectedTheme,  List<String> museum,  Map<String, LocalDate> museumCollected,  DailyProgress daily,  InProgressLevel? inProgress,  AdCounters adCounters,  SaveStats stats,  List<String> seenIntros,  bool tutorialDone,  BonusProgress bonus,  String? playerId,  Map<String, int> levelBests,  Map<String, int> levelStars,  bool starTipShown,  SaveRecords records,  ChestProgress chests,  RaceProgress race,  Map<String, Object?> unknown)  $default,) {final _that = this;
switch (_that) {
case _SaveDocument():
return $default(_that.schema,_that.currentLevel,_that.highestLevel,_that.coins,_that.inventory,_that.adsRemoved,_that.ownedSkins,_that.selectedSkin,_that.ownedThemes,_that.selectedTheme,_that.museum,_that.museumCollected,_that.daily,_that.inProgress,_that.adCounters,_that.stats,_that.seenIntros,_that.tutorialDone,_that.bonus,_that.playerId,_that.levelBests,_that.levelStars,_that.starTipShown,_that.records,_that.chests,_that.race,_that.unknown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schema,  int currentLevel,  int highestLevel,  int coins,  BoosterInventory inventory,  bool adsRemoved,  List<String> ownedSkins,  String selectedSkin,  List<String> ownedThemes,  String? selectedTheme,  List<String> museum,  Map<String, LocalDate> museumCollected,  DailyProgress daily,  InProgressLevel? inProgress,  AdCounters adCounters,  SaveStats stats,  List<String> seenIntros,  bool tutorialDone,  BonusProgress bonus,  String? playerId,  Map<String, int> levelBests,  Map<String, int> levelStars,  bool starTipShown,  SaveRecords records,  ChestProgress chests,  RaceProgress race,  Map<String, Object?> unknown)?  $default,) {final _that = this;
switch (_that) {
case _SaveDocument() when $default != null:
return $default(_that.schema,_that.currentLevel,_that.highestLevel,_that.coins,_that.inventory,_that.adsRemoved,_that.ownedSkins,_that.selectedSkin,_that.ownedThemes,_that.selectedTheme,_that.museum,_that.museumCollected,_that.daily,_that.inProgress,_that.adCounters,_that.stats,_that.seenIntros,_that.tutorialDone,_that.bonus,_that.playerId,_that.levelBests,_that.levelStars,_that.starTipShown,_that.records,_that.chests,_that.race,_that.unknown);case _:
  return null;

}
}

}

/// @nodoc


class _SaveDocument extends SaveDocument {
  const _SaveDocument({this.schema = SaveDocument.currentSchema, this.currentLevel = 1, this.highestLevel = 1, this.coins = 0, this.inventory = const BoosterInventory(), this.adsRemoved = false, final  List<String> ownedSkins = const <String>[SaveDocument.defaultSkin], this.selectedSkin = SaveDocument.defaultSkin, final  List<String> ownedThemes = const <String>[SaveDocument.defaultTheme], this.selectedTheme, final  List<String> museum = const <String>[], final  Map<String, LocalDate> museumCollected = const <String, LocalDate>{}, this.daily = const DailyProgress(), this.inProgress, this.adCounters = const AdCounters(), this.stats = const SaveStats(), final  List<String> seenIntros = const <String>[], this.tutorialDone = false, this.bonus = const BonusProgress(), this.playerId, final  Map<String, int> levelBests = const <String, int>{}, final  Map<String, int> levelStars = const <String, int>{}, this.starTipShown = false, this.records = const SaveRecords(), this.chests = const ChestProgress(), this.race = const RaceProgress(), final  Map<String, Object?> unknown = const <String, Object?>{}}): _ownedSkins = ownedSkins,_ownedThemes = ownedThemes,_museum = museum,_museumCollected = museumCollected,_seenIntros = seenIntros,_levelBests = levelBests,_levelStars = levelStars,_unknown = unknown,super._();
  

/// The schema this app writes ([currentSchema]).
@override@JsonKey() final  int schema;
/// The published level Home's PLAY starts, 1-based (§13.3). Past the
/// last level it stays at `levelCount + 1`, and PLAY starts
/// `bonus.next` (m3-design §7.4).
@override@JsonKey() final  int currentLevel;
/// The highest [currentLevel] reached (§13.3). The daily unlocks at 3
/// (Level 2 won, m3-design §8.3).
@override@JsonKey() final  int highestLevel;
/// Spec §7.3. A fresh install has 0 (Q46).
@override@JsonKey() final  int coins;
/// Hints and extra slots held (§8, §13.3), the starter gift first.
@override@JsonKey() final  BoosterInventory inventory;
/// Spec §9.2; always false until M6.
@override@JsonKey() final  bool adsRemoved;
/// Skin ids owned, `classic` always among them (§7.4).
 final  List<String> _ownedSkins;
/// Skin ids owned, `classic` always among them (§7.4).
@override@JsonKey() List<String> get ownedSkins {
  if (_ownedSkins is EqualUnmodifiableListView) return _ownedSkins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownedSkins);
}

/// The skin boards use (§7.4); always one of [ownedSkins].
@override@JsonKey() final  String selectedSkin;
/// Themes bought, and `ch01`. A chapter's own theme is owned once the
/// chapter is reached, whether or not it is listed (frame 7.7,
/// m3-design §9.4).
 final  List<String> _ownedThemes;
/// Themes bought, and `ch01`. A chapter's own theme is owned once the
/// chapter is reached, whether or not it is listed (frame 7.7,
/// m3-design §9.4).
@override@JsonKey() List<String> get ownedThemes {
  if (_ownedThemes is EqualUnmodifiableListView) return _ownedThemes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownedThemes);
}

/// Null: "Match each chapter" (§7.4, frame 7.7).
@override final  String? selectedTheme;
/// Chapter ids whose figurine the player has (§7.2, §13.3), in the
/// order collected.
 final  List<String> _museum;
/// Chapter ids whose figurine the player has (§7.2, §13.3), in the
/// order collected.
@override@JsonKey() List<String> get museum {
  if (_museum is EqualUnmodifiableListView) return _museum;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_museum);
}

/// The local date each figurine was collected (frame 6.2 "Collected ·
/// Sep 12"; an M3 addition, D22). A [museum] id without a date shows
/// "Collected".
 final  Map<String, LocalDate> _museumCollected;
/// The local date each figurine was collected (frame 6.2 "Collected ·
/// Sep 12"; an M3 addition, D22). A [museum] id without a date shows
/// "Collected".
@override@JsonKey() Map<String, LocalDate> get museumCollected {
  if (_museumCollected is EqualUnmodifiableMapView) return _museumCollected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_museumCollected);
}

/// The daily puzzle and its streak (§7.5, m3-design §8).
@override@JsonKey() final  DailyProgress daily;
/// The campaign or bonus level in progress (§13.3; m3-design §3.4).
/// The daily's board is [DailyProgress.inProgress].
@override final  InProgressLevel? inProgress;
/// Interstitial pacing (§9.1, §13.3); read and written from M6.
@override@JsonKey() final  AdCounters adCounters;
/// Spec §13.3 `stats`.
@override@JsonKey() final  SaveStats stats;
/// `IntroMechanic.id`s whose card was dismissed (frames 4.1–4.3; an M3
/// addition).
 final  List<String> _seenIntros;
/// `IntroMechanic.id`s whose card was dismissed (frames 4.1–4.3; an M3
/// addition).
@override@JsonKey() List<String> get seenIntros {
  if (_seenIntros is EqualUnmodifiableListView) return _seenIntros;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seenIntros);
}

/// The Level 2 swallow demo was done (frames 1.3–1.6; an M3 addition).
@override@JsonKey() final  bool tutorialDone;
/// Bonus Endless (§7.1; an M3 addition).
@override@JsonKey() final  BonusProgress bonus;
/// A local random id for the Settings footer ("Player ID 7F3A-21C9",
/// frame 8.1; an M3 addition, Q74). `SaveService.load` makes one when
/// it is missing, so it is null only in a document not yet loaded.
@override final  String? playerId;
/// Fewest moves per bundled level, keyed `LevelBests.key` (`L0024@2`):
/// every win of a campaign level or a replay (spec-prop §7.1, §13.3;
/// m7-design §11). Generated boards keep none.
 final  Map<String, int> _levelBests;
/// Fewest moves per bundled level, keyed `LevelBests.key` (`L0024@2`):
/// every win of a campaign level or a replay (spec-prop §7.1, §13.3;
/// m7-design §11). Generated boards keep none.
@override@JsonKey() Map<String, int> get levelBests {
  if (_levelBests is EqualUnmodifiableMapView) return _levelBests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_levelBests);
}

/// Best stars per bundled level id (`L0024` → 1–3): the most any win
/// of a campaign level or a replay has earned (spec-prop §7.10, §13.3;
/// D125; m7-design P3.4). Kept per level id, so a new level version
/// keeps them (Q117); never lowered. `SaveService.backfillLevelStars`
/// fills it at load for levels won before stars existed (Q120).
/// Generated boards (daily, bonus, race) keep none.
 final  Map<String, int> _levelStars;
/// Best stars per bundled level id (`L0024` → 1–3): the most any win
/// of a campaign level or a replay has earned (spec-prop §7.10, §13.3;
/// D125; m7-design P3.4). Kept per level id, so a new level version
/// keeps them (Q117); never lowered. `SaveService.backfillLevelStars`
/// fills it at load for levels won before stars existed (Q120).
/// Generated boards (daily, bonus, race) keep none.
@override@JsonKey() Map<String, int> get levelStars {
  if (_levelStars is EqualUnmodifiableMapView) return _levelStars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_levelStars);
}

/// The one-time star tip ("Fewer moves earn more stars…") was shown on
/// the first win below 3 stars (Q119; m7-design P3.6), so no later
/// win card shows it.
@override@JsonKey() final  bool starTipShown;
/// Lifetime records and badges (spec-prop §7.8, §13.3; m7-design §12).
@override@JsonKey() final  SaveRecords records;
/// Milestone chests already opened (spec-prop §7.3; m7-design §9).
@override@JsonKey() final  ChestProgress chests;
/// vs Computer, per rival (spec-prop §7.7, §13.3; m7-design §3). The
/// race itself lands in M7 phase 2; the fields are schema 2's.
@override@JsonKey() final  RaceProgress race;
/// Top-level keys this schema doesn't know (a newer app's), kept as they
/// were and written back (m3-design §3.3).
 final  Map<String, Object?> _unknown;
/// Top-level keys this schema doesn't know (a newer app's), kept as they
/// were and written back (m3-design §3.3).
@override@JsonKey() Map<String, Object?> get unknown {
  if (_unknown is EqualUnmodifiableMapView) return _unknown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_unknown);
}


/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaveDocumentCopyWith<_SaveDocument> get copyWith => __$SaveDocumentCopyWithImpl<_SaveDocument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveDocument&&(identical(other.schema, schema) || other.schema == schema)&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel)&&(identical(other.highestLevel, highestLevel) || other.highestLevel == highestLevel)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.inventory, inventory) || other.inventory == inventory)&&(identical(other.adsRemoved, adsRemoved) || other.adsRemoved == adsRemoved)&&const DeepCollectionEquality().equals(other._ownedSkins, _ownedSkins)&&(identical(other.selectedSkin, selectedSkin) || other.selectedSkin == selectedSkin)&&const DeepCollectionEquality().equals(other._ownedThemes, _ownedThemes)&&(identical(other.selectedTheme, selectedTheme) || other.selectedTheme == selectedTheme)&&const DeepCollectionEquality().equals(other._museum, _museum)&&const DeepCollectionEquality().equals(other._museumCollected, _museumCollected)&&(identical(other.daily, daily) || other.daily == daily)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.adCounters, adCounters) || other.adCounters == adCounters)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other._seenIntros, _seenIntros)&&(identical(other.tutorialDone, tutorialDone) || other.tutorialDone == tutorialDone)&&(identical(other.bonus, bonus) || other.bonus == bonus)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&const DeepCollectionEquality().equals(other._levelBests, _levelBests)&&const DeepCollectionEquality().equals(other._levelStars, _levelStars)&&(identical(other.starTipShown, starTipShown) || other.starTipShown == starTipShown)&&(identical(other.records, records) || other.records == records)&&(identical(other.chests, chests) || other.chests == chests)&&(identical(other.race, race) || other.race == race)&&const DeepCollectionEquality().equals(other._unknown, _unknown));
}


@override
int get hashCode => Object.hashAll([runtimeType,schema,currentLevel,highestLevel,coins,inventory,adsRemoved,const DeepCollectionEquality().hash(_ownedSkins),selectedSkin,const DeepCollectionEquality().hash(_ownedThemes),selectedTheme,const DeepCollectionEquality().hash(_museum),const DeepCollectionEquality().hash(_museumCollected),daily,inProgress,adCounters,stats,const DeepCollectionEquality().hash(_seenIntros),tutorialDone,bonus,playerId,const DeepCollectionEquality().hash(_levelBests),const DeepCollectionEquality().hash(_levelStars),starTipShown,records,chests,race,const DeepCollectionEquality().hash(_unknown)]);

@override
String toString() {
  return 'SaveDocument(schema: $schema, currentLevel: $currentLevel, highestLevel: $highestLevel, coins: $coins, inventory: $inventory, adsRemoved: $adsRemoved, ownedSkins: $ownedSkins, selectedSkin: $selectedSkin, ownedThemes: $ownedThemes, selectedTheme: $selectedTheme, museum: $museum, museumCollected: $museumCollected, daily: $daily, inProgress: $inProgress, adCounters: $adCounters, stats: $stats, seenIntros: $seenIntros, tutorialDone: $tutorialDone, bonus: $bonus, playerId: $playerId, levelBests: $levelBests, levelStars: $levelStars, starTipShown: $starTipShown, records: $records, chests: $chests, race: $race, unknown: $unknown)';
}


}

/// @nodoc
abstract mixin class _$SaveDocumentCopyWith<$Res> implements $SaveDocumentCopyWith<$Res> {
  factory _$SaveDocumentCopyWith(_SaveDocument value, $Res Function(_SaveDocument) _then) = __$SaveDocumentCopyWithImpl;
@override @useResult
$Res call({
 int schema, int currentLevel, int highestLevel, int coins, BoosterInventory inventory, bool adsRemoved, List<String> ownedSkins, String selectedSkin, List<String> ownedThemes, String? selectedTheme, List<String> museum, Map<String, LocalDate> museumCollected, DailyProgress daily, InProgressLevel? inProgress, AdCounters adCounters, SaveStats stats, List<String> seenIntros, bool tutorialDone, BonusProgress bonus, String? playerId, Map<String, int> levelBests, Map<String, int> levelStars, bool starTipShown, SaveRecords records, ChestProgress chests, RaceProgress race, Map<String, Object?> unknown
});


@override $BoosterInventoryCopyWith<$Res> get inventory;@override $DailyProgressCopyWith<$Res> get daily;@override $InProgressLevelCopyWith<$Res>? get inProgress;@override $AdCountersCopyWith<$Res> get adCounters;@override $SaveStatsCopyWith<$Res> get stats;@override $BonusProgressCopyWith<$Res> get bonus;@override $SaveRecordsCopyWith<$Res> get records;@override $ChestProgressCopyWith<$Res> get chests;@override $RaceProgressCopyWith<$Res> get race;

}
/// @nodoc
class __$SaveDocumentCopyWithImpl<$Res>
    implements _$SaveDocumentCopyWith<$Res> {
  __$SaveDocumentCopyWithImpl(this._self, this._then);

  final _SaveDocument _self;
  final $Res Function(_SaveDocument) _then;

/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schema = null,Object? currentLevel = null,Object? highestLevel = null,Object? coins = null,Object? inventory = null,Object? adsRemoved = null,Object? ownedSkins = null,Object? selectedSkin = null,Object? ownedThemes = null,Object? selectedTheme = freezed,Object? museum = null,Object? museumCollected = null,Object? daily = null,Object? inProgress = freezed,Object? adCounters = null,Object? stats = null,Object? seenIntros = null,Object? tutorialDone = null,Object? bonus = null,Object? playerId = freezed,Object? levelBests = null,Object? levelStars = null,Object? starTipShown = null,Object? records = null,Object? chests = null,Object? race = null,Object? unknown = null,}) {
  return _then(_SaveDocument(
schema: null == schema ? _self.schema : schema // ignore: cast_nullable_to_non_nullable
as int,currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as int,highestLevel: null == highestLevel ? _self.highestLevel : highestLevel // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,inventory: null == inventory ? _self.inventory : inventory // ignore: cast_nullable_to_non_nullable
as BoosterInventory,adsRemoved: null == adsRemoved ? _self.adsRemoved : adsRemoved // ignore: cast_nullable_to_non_nullable
as bool,ownedSkins: null == ownedSkins ? _self._ownedSkins : ownedSkins // ignore: cast_nullable_to_non_nullable
as List<String>,selectedSkin: null == selectedSkin ? _self.selectedSkin : selectedSkin // ignore: cast_nullable_to_non_nullable
as String,ownedThemes: null == ownedThemes ? _self._ownedThemes : ownedThemes // ignore: cast_nullable_to_non_nullable
as List<String>,selectedTheme: freezed == selectedTheme ? _self.selectedTheme : selectedTheme // ignore: cast_nullable_to_non_nullable
as String?,museum: null == museum ? _self._museum : museum // ignore: cast_nullable_to_non_nullable
as List<String>,museumCollected: null == museumCollected ? _self._museumCollected : museumCollected // ignore: cast_nullable_to_non_nullable
as Map<String, LocalDate>,daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as DailyProgress,inProgress: freezed == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as InProgressLevel?,adCounters: null == adCounters ? _self.adCounters : adCounters // ignore: cast_nullable_to_non_nullable
as AdCounters,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as SaveStats,seenIntros: null == seenIntros ? _self._seenIntros : seenIntros // ignore: cast_nullable_to_non_nullable
as List<String>,tutorialDone: null == tutorialDone ? _self.tutorialDone : tutorialDone // ignore: cast_nullable_to_non_nullable
as bool,bonus: null == bonus ? _self.bonus : bonus // ignore: cast_nullable_to_non_nullable
as BonusProgress,playerId: freezed == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String?,levelBests: null == levelBests ? _self._levelBests : levelBests // ignore: cast_nullable_to_non_nullable
as Map<String, int>,levelStars: null == levelStars ? _self._levelStars : levelStars // ignore: cast_nullable_to_non_nullable
as Map<String, int>,starTipShown: null == starTipShown ? _self.starTipShown : starTipShown // ignore: cast_nullable_to_non_nullable
as bool,records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as SaveRecords,chests: null == chests ? _self.chests : chests // ignore: cast_nullable_to_non_nullable
as ChestProgress,race: null == race ? _self.race : race // ignore: cast_nullable_to_non_nullable
as RaceProgress,unknown: null == unknown ? _self._unknown : unknown // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoosterInventoryCopyWith<$Res> get inventory {
  
  return $BoosterInventoryCopyWith<$Res>(_self.inventory, (value) {
    return _then(_self.copyWith(inventory: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailyProgressCopyWith<$Res> get daily {
  
  return $DailyProgressCopyWith<$Res>(_self.daily, (value) {
    return _then(_self.copyWith(daily: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InProgressLevelCopyWith<$Res>? get inProgress {
    if (_self.inProgress == null) {
    return null;
  }

  return $InProgressLevelCopyWith<$Res>(_self.inProgress!, (value) {
    return _then(_self.copyWith(inProgress: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdCountersCopyWith<$Res> get adCounters {
  
  return $AdCountersCopyWith<$Res>(_self.adCounters, (value) {
    return _then(_self.copyWith(adCounters: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SaveStatsCopyWith<$Res> get stats {
  
  return $SaveStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BonusProgressCopyWith<$Res> get bonus {
  
  return $BonusProgressCopyWith<$Res>(_self.bonus, (value) {
    return _then(_self.copyWith(bonus: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SaveRecordsCopyWith<$Res> get records {
  
  return $SaveRecordsCopyWith<$Res>(_self.records, (value) {
    return _then(_self.copyWith(records: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChestProgressCopyWith<$Res> get chests {
  
  return $ChestProgressCopyWith<$Res>(_self.chests, (value) {
    return _then(_self.copyWith(chests: value));
  });
}/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RaceProgressCopyWith<$Res> get race {
  
  return $RaceProgressCopyWith<$Res>(_self.race, (value) {
    return _then(_self.copyWith(race: value));
  });
}
}

/// @nodoc
mixin _$BoosterInventory {

/// Starts at `BoosterKind.hint.starterGift`.
 int get hint;/// Starts at `BoosterKind.extraSlot.starterGift`.
 int get slot;
/// Create a copy of BoosterInventory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoosterInventoryCopyWith<BoosterInventory> get copyWith => _$BoosterInventoryCopyWithImpl<BoosterInventory>(this as BoosterInventory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoosterInventory&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.slot, slot) || other.slot == slot));
}


@override
int get hashCode => Object.hash(runtimeType,hint,slot);

@override
String toString() {
  return 'BoosterInventory(hint: $hint, slot: $slot)';
}


}

/// @nodoc
abstract mixin class $BoosterInventoryCopyWith<$Res>  {
  factory $BoosterInventoryCopyWith(BoosterInventory value, $Res Function(BoosterInventory) _then) = _$BoosterInventoryCopyWithImpl;
@useResult
$Res call({
 int hint, int slot
});




}
/// @nodoc
class _$BoosterInventoryCopyWithImpl<$Res>
    implements $BoosterInventoryCopyWith<$Res> {
  _$BoosterInventoryCopyWithImpl(this._self, this._then);

  final BoosterInventory _self;
  final $Res Function(BoosterInventory) _then;

/// Create a copy of BoosterInventory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hint = null,Object? slot = null,}) {
  return _then(_self.copyWith(
hint: null == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as int,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BoosterInventory].
extension BoosterInventoryPatterns on BoosterInventory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoosterInventory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoosterInventory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoosterInventory value)  $default,){
final _that = this;
switch (_that) {
case _BoosterInventory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoosterInventory value)?  $default,){
final _that = this;
switch (_that) {
case _BoosterInventory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int hint,  int slot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoosterInventory() when $default != null:
return $default(_that.hint,_that.slot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int hint,  int slot)  $default,) {final _that = this;
switch (_that) {
case _BoosterInventory():
return $default(_that.hint,_that.slot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int hint,  int slot)?  $default,) {final _that = this;
switch (_that) {
case _BoosterInventory() when $default != null:
return $default(_that.hint,_that.slot);case _:
  return null;

}
}

}

/// @nodoc


class _BoosterInventory extends BoosterInventory {
  const _BoosterInventory({this.hint = 3, this.slot = 2}): super._();
  

/// Starts at `BoosterKind.hint.starterGift`.
@override@JsonKey() final  int hint;
/// Starts at `BoosterKind.extraSlot.starterGift`.
@override@JsonKey() final  int slot;

/// Create a copy of BoosterInventory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoosterInventoryCopyWith<_BoosterInventory> get copyWith => __$BoosterInventoryCopyWithImpl<_BoosterInventory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoosterInventory&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.slot, slot) || other.slot == slot));
}


@override
int get hashCode => Object.hash(runtimeType,hint,slot);

@override
String toString() {
  return 'BoosterInventory(hint: $hint, slot: $slot)';
}


}

/// @nodoc
abstract mixin class _$BoosterInventoryCopyWith<$Res> implements $BoosterInventoryCopyWith<$Res> {
  factory _$BoosterInventoryCopyWith(_BoosterInventory value, $Res Function(_BoosterInventory) _then) = __$BoosterInventoryCopyWithImpl;
@override @useResult
$Res call({
 int hint, int slot
});




}
/// @nodoc
class __$BoosterInventoryCopyWithImpl<$Res>
    implements _$BoosterInventoryCopyWith<$Res> {
  __$BoosterInventoryCopyWithImpl(this._self, this._then);

  final _BoosterInventory _self;
  final $Res Function(_BoosterInventory) _then;

/// Create a copy of BoosterInventory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hint = null,Object? slot = null,}) {
  return _then(_BoosterInventory(
hint: null == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as int,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$DailyProgress {

/// The days the daily was solved on its own date: a solve adds one and
/// nothing ever lowers it (spec-prop §7.5, m7-design §8). Schema 1's
/// "days in a row" carries over as it was (m7-design §3.3).
 int get streak;/// The flame is lit (spec-prop §7.5): false before the first solve and
/// after a missed day no freeze covered ("paused"); the next solve
/// relights it. Always `run > 0` (m7-design §8).
 bool get lit;/// The current unbroken run: days in a row, a frozen day keeping it
/// without adding (the old streak's meaning). 0 while not [lit]. The
/// longest one is `SaveRecords.longestRun`.
 int get run;/// The last day the run reached, by a solve or a freeze; null when
/// there is no run (fresh, or paused).
 LocalDate? get lastDate;/// Freezes held, 0 or 1 ([maxFreezes]).
 int get freezes;/// `LocalDate.isoWeekKey` of the last weekly freeze grant.
 int? get freezeWeek;/// Days solved, oldest first, at most [maxDates].
 List<LocalDate> get done;/// Days a freeze covered, oldest first, at most [maxDates].
 List<LocalDate> get frozen;/// The frozen day whose "Streak saved!" banner (frame 5.2) was shown.
 LocalDate? get noticeDate;/// A 7th streak day was solved and its chest (frame 5.6) not collected.
 bool get chestPending;/// The latest daily solved for the first time on its date: what the
/// Daily screen's Share text says (E3, spec-prop §10.2 #11) and the
/// hour the reminder offer proposes (E4, Q81; m7-design P3.4). Null
/// before the first solve, and for a day an older build solved.
 DailySolve? get lastSolve;/// Today's daily board in progress (m3-design §3.4).
 InProgressLevel? get inProgress;
/// Create a copy of DailyProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyProgressCopyWith<DailyProgress> get copyWith => _$DailyProgressCopyWithImpl<DailyProgress>(this as DailyProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyProgress&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.lit, lit) || other.lit == lit)&&(identical(other.run, run) || other.run == run)&&(identical(other.lastDate, lastDate) || other.lastDate == lastDate)&&(identical(other.freezes, freezes) || other.freezes == freezes)&&(identical(other.freezeWeek, freezeWeek) || other.freezeWeek == freezeWeek)&&const DeepCollectionEquality().equals(other.done, done)&&const DeepCollectionEquality().equals(other.frozen, frozen)&&(identical(other.noticeDate, noticeDate) || other.noticeDate == noticeDate)&&(identical(other.chestPending, chestPending) || other.chestPending == chestPending)&&(identical(other.lastSolve, lastSolve) || other.lastSolve == lastSolve)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress));
}


@override
int get hashCode => Object.hash(runtimeType,streak,lit,run,lastDate,freezes,freezeWeek,const DeepCollectionEquality().hash(done),const DeepCollectionEquality().hash(frozen),noticeDate,chestPending,lastSolve,inProgress);

@override
String toString() {
  return 'DailyProgress(streak: $streak, lit: $lit, run: $run, lastDate: $lastDate, freezes: $freezes, freezeWeek: $freezeWeek, done: $done, frozen: $frozen, noticeDate: $noticeDate, chestPending: $chestPending, lastSolve: $lastSolve, inProgress: $inProgress)';
}


}

/// @nodoc
abstract mixin class $DailyProgressCopyWith<$Res>  {
  factory $DailyProgressCopyWith(DailyProgress value, $Res Function(DailyProgress) _then) = _$DailyProgressCopyWithImpl;
@useResult
$Res call({
 int streak, bool lit, int run, LocalDate? lastDate, int freezes, int? freezeWeek, List<LocalDate> done, List<LocalDate> frozen, LocalDate? noticeDate, bool chestPending, DailySolve? lastSolve, InProgressLevel? inProgress
});


$DailySolveCopyWith<$Res>? get lastSolve;$InProgressLevelCopyWith<$Res>? get inProgress;

}
/// @nodoc
class _$DailyProgressCopyWithImpl<$Res>
    implements $DailyProgressCopyWith<$Res> {
  _$DailyProgressCopyWithImpl(this._self, this._then);

  final DailyProgress _self;
  final $Res Function(DailyProgress) _then;

/// Create a copy of DailyProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? streak = null,Object? lit = null,Object? run = null,Object? lastDate = freezed,Object? freezes = null,Object? freezeWeek = freezed,Object? done = null,Object? frozen = null,Object? noticeDate = freezed,Object? chestPending = null,Object? lastSolve = freezed,Object? inProgress = freezed,}) {
  return _then(_self.copyWith(
streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,lit: null == lit ? _self.lit : lit // ignore: cast_nullable_to_non_nullable
as bool,run: null == run ? _self.run : run // ignore: cast_nullable_to_non_nullable
as int,lastDate: freezed == lastDate ? _self.lastDate : lastDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,freezes: null == freezes ? _self.freezes : freezes // ignore: cast_nullable_to_non_nullable
as int,freezeWeek: freezed == freezeWeek ? _self.freezeWeek : freezeWeek // ignore: cast_nullable_to_non_nullable
as int?,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as List<LocalDate>,frozen: null == frozen ? _self.frozen : frozen // ignore: cast_nullable_to_non_nullable
as List<LocalDate>,noticeDate: freezed == noticeDate ? _self.noticeDate : noticeDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,chestPending: null == chestPending ? _self.chestPending : chestPending // ignore: cast_nullable_to_non_nullable
as bool,lastSolve: freezed == lastSolve ? _self.lastSolve : lastSolve // ignore: cast_nullable_to_non_nullable
as DailySolve?,inProgress: freezed == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as InProgressLevel?,
  ));
}
/// Create a copy of DailyProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailySolveCopyWith<$Res>? get lastSolve {
    if (_self.lastSolve == null) {
    return null;
  }

  return $DailySolveCopyWith<$Res>(_self.lastSolve!, (value) {
    return _then(_self.copyWith(lastSolve: value));
  });
}/// Create a copy of DailyProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InProgressLevelCopyWith<$Res>? get inProgress {
    if (_self.inProgress == null) {
    return null;
  }

  return $InProgressLevelCopyWith<$Res>(_self.inProgress!, (value) {
    return _then(_self.copyWith(inProgress: value));
  });
}
}


/// Adds pattern-matching-related methods to [DailyProgress].
extension DailyProgressPatterns on DailyProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyProgress value)  $default,){
final _that = this;
switch (_that) {
case _DailyProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyProgress value)?  $default,){
final _that = this;
switch (_that) {
case _DailyProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int streak,  bool lit,  int run,  LocalDate? lastDate,  int freezes,  int? freezeWeek,  List<LocalDate> done,  List<LocalDate> frozen,  LocalDate? noticeDate,  bool chestPending,  DailySolve? lastSolve,  InProgressLevel? inProgress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyProgress() when $default != null:
return $default(_that.streak,_that.lit,_that.run,_that.lastDate,_that.freezes,_that.freezeWeek,_that.done,_that.frozen,_that.noticeDate,_that.chestPending,_that.lastSolve,_that.inProgress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int streak,  bool lit,  int run,  LocalDate? lastDate,  int freezes,  int? freezeWeek,  List<LocalDate> done,  List<LocalDate> frozen,  LocalDate? noticeDate,  bool chestPending,  DailySolve? lastSolve,  InProgressLevel? inProgress)  $default,) {final _that = this;
switch (_that) {
case _DailyProgress():
return $default(_that.streak,_that.lit,_that.run,_that.lastDate,_that.freezes,_that.freezeWeek,_that.done,_that.frozen,_that.noticeDate,_that.chestPending,_that.lastSolve,_that.inProgress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int streak,  bool lit,  int run,  LocalDate? lastDate,  int freezes,  int? freezeWeek,  List<LocalDate> done,  List<LocalDate> frozen,  LocalDate? noticeDate,  bool chestPending,  DailySolve? lastSolve,  InProgressLevel? inProgress)?  $default,) {final _that = this;
switch (_that) {
case _DailyProgress() when $default != null:
return $default(_that.streak,_that.lit,_that.run,_that.lastDate,_that.freezes,_that.freezeWeek,_that.done,_that.frozen,_that.noticeDate,_that.chestPending,_that.lastSolve,_that.inProgress);case _:
  return null;

}
}

}

/// @nodoc


class _DailyProgress extends DailyProgress {
  const _DailyProgress({this.streak = 0, this.lit = false, this.run = 0, this.lastDate, this.freezes = 0, this.freezeWeek, final  List<LocalDate> done = const <LocalDate>[], final  List<LocalDate> frozen = const <LocalDate>[], this.noticeDate, this.chestPending = false, this.lastSolve, this.inProgress}): _done = done,_frozen = frozen,super._();
  

/// The days the daily was solved on its own date: a solve adds one and
/// nothing ever lowers it (spec-prop §7.5, m7-design §8). Schema 1's
/// "days in a row" carries over as it was (m7-design §3.3).
@override@JsonKey() final  int streak;
/// The flame is lit (spec-prop §7.5): false before the first solve and
/// after a missed day no freeze covered ("paused"); the next solve
/// relights it. Always `run > 0` (m7-design §8).
@override@JsonKey() final  bool lit;
/// The current unbroken run: days in a row, a frozen day keeping it
/// without adding (the old streak's meaning). 0 while not [lit]. The
/// longest one is `SaveRecords.longestRun`.
@override@JsonKey() final  int run;
/// The last day the run reached, by a solve or a freeze; null when
/// there is no run (fresh, or paused).
@override final  LocalDate? lastDate;
/// Freezes held, 0 or 1 ([maxFreezes]).
@override@JsonKey() final  int freezes;
/// `LocalDate.isoWeekKey` of the last weekly freeze grant.
@override final  int? freezeWeek;
/// Days solved, oldest first, at most [maxDates].
 final  List<LocalDate> _done;
/// Days solved, oldest first, at most [maxDates].
@override@JsonKey() List<LocalDate> get done {
  if (_done is EqualUnmodifiableListView) return _done;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_done);
}

/// Days a freeze covered, oldest first, at most [maxDates].
 final  List<LocalDate> _frozen;
/// Days a freeze covered, oldest first, at most [maxDates].
@override@JsonKey() List<LocalDate> get frozen {
  if (_frozen is EqualUnmodifiableListView) return _frozen;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_frozen);
}

/// The frozen day whose "Streak saved!" banner (frame 5.2) was shown.
@override final  LocalDate? noticeDate;
/// A 7th streak day was solved and its chest (frame 5.6) not collected.
@override@JsonKey() final  bool chestPending;
/// The latest daily solved for the first time on its date: what the
/// Daily screen's Share text says (E3, spec-prop §10.2 #11) and the
/// hour the reminder offer proposes (E4, Q81; m7-design P3.4). Null
/// before the first solve, and for a day an older build solved.
@override final  DailySolve? lastSolve;
/// Today's daily board in progress (m3-design §3.4).
@override final  InProgressLevel? inProgress;

/// Create a copy of DailyProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyProgressCopyWith<_DailyProgress> get copyWith => __$DailyProgressCopyWithImpl<_DailyProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyProgress&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.lit, lit) || other.lit == lit)&&(identical(other.run, run) || other.run == run)&&(identical(other.lastDate, lastDate) || other.lastDate == lastDate)&&(identical(other.freezes, freezes) || other.freezes == freezes)&&(identical(other.freezeWeek, freezeWeek) || other.freezeWeek == freezeWeek)&&const DeepCollectionEquality().equals(other._done, _done)&&const DeepCollectionEquality().equals(other._frozen, _frozen)&&(identical(other.noticeDate, noticeDate) || other.noticeDate == noticeDate)&&(identical(other.chestPending, chestPending) || other.chestPending == chestPending)&&(identical(other.lastSolve, lastSolve) || other.lastSolve == lastSolve)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress));
}


@override
int get hashCode => Object.hash(runtimeType,streak,lit,run,lastDate,freezes,freezeWeek,const DeepCollectionEquality().hash(_done),const DeepCollectionEquality().hash(_frozen),noticeDate,chestPending,lastSolve,inProgress);

@override
String toString() {
  return 'DailyProgress(streak: $streak, lit: $lit, run: $run, lastDate: $lastDate, freezes: $freezes, freezeWeek: $freezeWeek, done: $done, frozen: $frozen, noticeDate: $noticeDate, chestPending: $chestPending, lastSolve: $lastSolve, inProgress: $inProgress)';
}


}

/// @nodoc
abstract mixin class _$DailyProgressCopyWith<$Res> implements $DailyProgressCopyWith<$Res> {
  factory _$DailyProgressCopyWith(_DailyProgress value, $Res Function(_DailyProgress) _then) = __$DailyProgressCopyWithImpl;
@override @useResult
$Res call({
 int streak, bool lit, int run, LocalDate? lastDate, int freezes, int? freezeWeek, List<LocalDate> done, List<LocalDate> frozen, LocalDate? noticeDate, bool chestPending, DailySolve? lastSolve, InProgressLevel? inProgress
});


@override $DailySolveCopyWith<$Res>? get lastSolve;@override $InProgressLevelCopyWith<$Res>? get inProgress;

}
/// @nodoc
class __$DailyProgressCopyWithImpl<$Res>
    implements _$DailyProgressCopyWith<$Res> {
  __$DailyProgressCopyWithImpl(this._self, this._then);

  final _DailyProgress _self;
  final $Res Function(_DailyProgress) _then;

/// Create a copy of DailyProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? streak = null,Object? lit = null,Object? run = null,Object? lastDate = freezed,Object? freezes = null,Object? freezeWeek = freezed,Object? done = null,Object? frozen = null,Object? noticeDate = freezed,Object? chestPending = null,Object? lastSolve = freezed,Object? inProgress = freezed,}) {
  return _then(_DailyProgress(
streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,lit: null == lit ? _self.lit : lit // ignore: cast_nullable_to_non_nullable
as bool,run: null == run ? _self.run : run // ignore: cast_nullable_to_non_nullable
as int,lastDate: freezed == lastDate ? _self.lastDate : lastDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,freezes: null == freezes ? _self.freezes : freezes // ignore: cast_nullable_to_non_nullable
as int,freezeWeek: freezed == freezeWeek ? _self.freezeWeek : freezeWeek // ignore: cast_nullable_to_non_nullable
as int?,done: null == done ? _self._done : done // ignore: cast_nullable_to_non_nullable
as List<LocalDate>,frozen: null == frozen ? _self._frozen : frozen // ignore: cast_nullable_to_non_nullable
as List<LocalDate>,noticeDate: freezed == noticeDate ? _self.noticeDate : noticeDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,chestPending: null == chestPending ? _self.chestPending : chestPending // ignore: cast_nullable_to_non_nullable
as bool,lastSolve: freezed == lastSolve ? _self.lastSolve : lastSolve // ignore: cast_nullable_to_non_nullable
as DailySolve?,inProgress: freezed == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as InProgressLevel?,
  ));
}

/// Create a copy of DailyProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailySolveCopyWith<$Res>? get lastSolve {
    if (_self.lastSolve == null) {
    return null;
  }

  return $DailySolveCopyWith<$Res>(_self.lastSolve!, (value) {
    return _then(_self.copyWith(lastSolve: value));
  });
}/// Create a copy of DailyProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InProgressLevelCopyWith<$Res>? get inProgress {
    if (_self.inProgress == null) {
    return null;
  }

  return $InProgressLevelCopyWith<$Res>(_self.inProgress!, (value) {
    return _then(_self.copyWith(inProgress: value));
  });
}
}

/// @nodoc
mixin _$DailySolve {

/// The daily's own date (its `PlayRequest.daily` number).
 LocalDate get date;/// `GameState.moveCount` at the win.
 int get moves;/// The families the board completed (`RecordRules.familiesIn`).
 int get families;/// The local minute of the day the win landed on (0–1439,
/// `hour × 60 + minute` from `AppClock`); null when unknown.
 int? get minuteOfDay;
/// Create a copy of DailySolve
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailySolveCopyWith<DailySolve> get copyWith => _$DailySolveCopyWithImpl<DailySolve>(this as DailySolve, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailySolve&&(identical(other.date, date) || other.date == date)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.families, families) || other.families == families)&&(identical(other.minuteOfDay, minuteOfDay) || other.minuteOfDay == minuteOfDay));
}


@override
int get hashCode => Object.hash(runtimeType,date,moves,families,minuteOfDay);

@override
String toString() {
  return 'DailySolve(date: $date, moves: $moves, families: $families, minuteOfDay: $minuteOfDay)';
}


}

/// @nodoc
abstract mixin class $DailySolveCopyWith<$Res>  {
  factory $DailySolveCopyWith(DailySolve value, $Res Function(DailySolve) _then) = _$DailySolveCopyWithImpl;
@useResult
$Res call({
 LocalDate date, int moves, int families, int? minuteOfDay
});




}
/// @nodoc
class _$DailySolveCopyWithImpl<$Res>
    implements $DailySolveCopyWith<$Res> {
  _$DailySolveCopyWithImpl(this._self, this._then);

  final DailySolve _self;
  final $Res Function(DailySolve) _then;

/// Create a copy of DailySolve
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? moves = null,Object? families = null,Object? minuteOfDay = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,families: null == families ? _self.families : families // ignore: cast_nullable_to_non_nullable
as int,minuteOfDay: freezed == minuteOfDay ? _self.minuteOfDay : minuteOfDay // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DailySolve].
extension DailySolvePatterns on DailySolve {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailySolve value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailySolve() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailySolve value)  $default,){
final _that = this;
switch (_that) {
case _DailySolve():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailySolve value)?  $default,){
final _that = this;
switch (_that) {
case _DailySolve() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate date,  int moves,  int families,  int? minuteOfDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailySolve() when $default != null:
return $default(_that.date,_that.moves,_that.families,_that.minuteOfDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate date,  int moves,  int families,  int? minuteOfDay)  $default,) {final _that = this;
switch (_that) {
case _DailySolve():
return $default(_that.date,_that.moves,_that.families,_that.minuteOfDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate date,  int moves,  int families,  int? minuteOfDay)?  $default,) {final _that = this;
switch (_that) {
case _DailySolve() when $default != null:
return $default(_that.date,_that.moves,_that.families,_that.minuteOfDay);case _:
  return null;

}
}

}

/// @nodoc


class _DailySolve implements DailySolve {
  const _DailySolve({required this.date, this.moves = 0, this.families = 0, this.minuteOfDay});
  

/// The daily's own date (its `PlayRequest.daily` number).
@override final  LocalDate date;
/// `GameState.moveCount` at the win.
@override@JsonKey() final  int moves;
/// The families the board completed (`RecordRules.familiesIn`).
@override@JsonKey() final  int families;
/// The local minute of the day the win landed on (0–1439,
/// `hour × 60 + minute` from `AppClock`); null when unknown.
@override final  int? minuteOfDay;

/// Create a copy of DailySolve
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailySolveCopyWith<_DailySolve> get copyWith => __$DailySolveCopyWithImpl<_DailySolve>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailySolve&&(identical(other.date, date) || other.date == date)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.families, families) || other.families == families)&&(identical(other.minuteOfDay, minuteOfDay) || other.minuteOfDay == minuteOfDay));
}


@override
int get hashCode => Object.hash(runtimeType,date,moves,families,minuteOfDay);

@override
String toString() {
  return 'DailySolve(date: $date, moves: $moves, families: $families, minuteOfDay: $minuteOfDay)';
}


}

/// @nodoc
abstract mixin class _$DailySolveCopyWith<$Res> implements $DailySolveCopyWith<$Res> {
  factory _$DailySolveCopyWith(_DailySolve value, $Res Function(_DailySolve) _then) = __$DailySolveCopyWithImpl;
@override @useResult
$Res call({
 LocalDate date, int moves, int families, int? minuteOfDay
});




}
/// @nodoc
class __$DailySolveCopyWithImpl<$Res>
    implements _$DailySolveCopyWith<$Res> {
  __$DailySolveCopyWithImpl(this._self, this._then);

  final _DailySolve _self;
  final $Res Function(_DailySolve) _then;

/// Create a copy of DailySolve
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? moves = null,Object? families = null,Object? minuteOfDay = freezed,}) {
  return _then(_DailySolve(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,families: null == families ? _self.families : families // ignore: cast_nullable_to_non_nullable
as int,minuteOfDay: freezed == minuteOfDay ? _self.minuteOfDay : minuteOfDay // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$InProgressLevel {

/// What is being played; its kind and number are stored.
 PlayRequest get request;/// `Level.id` of the board.
 String get levelId;/// Must equal the entry's `PlayEntry.levelVersion` to restore (§13.3).
 int get levelVersion;/// `GameSessionCodec.encode` of the session: the board, the undo
/// history and `undosUsed`. The selection and the hint are not saved.
 Map<String, Object?> get session;/// `LevelCodec.encode` of a generated board (bonus, daily), so a resume
/// never regenerates it. Null for campaign levels.
 Map<String, Object?>? get level;/// A generated board's tier, so a resume needn't simulate it again.
 Tier? get tier;/// A hint was shown during this attempt, since the last Restart (Q116;
/// m7-design P3.6): the win's stars are capped at 2 even after a kill
/// and a restore. Restart clears it.
 bool get hinted;
/// Create a copy of InProgressLevel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InProgressLevelCopyWith<InProgressLevel> get copyWith => _$InProgressLevelCopyWithImpl<InProgressLevel>(this as InProgressLevel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InProgressLevel&&(identical(other.request, request) || other.request == request)&&(identical(other.levelId, levelId) || other.levelId == levelId)&&(identical(other.levelVersion, levelVersion) || other.levelVersion == levelVersion)&&const DeepCollectionEquality().equals(other.session, session)&&const DeepCollectionEquality().equals(other.level, level)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.hinted, hinted) || other.hinted == hinted));
}


@override
int get hashCode => Object.hash(runtimeType,request,levelId,levelVersion,const DeepCollectionEquality().hash(session),const DeepCollectionEquality().hash(level),tier,hinted);

@override
String toString() {
  return 'InProgressLevel(request: $request, levelId: $levelId, levelVersion: $levelVersion, session: $session, level: $level, tier: $tier, hinted: $hinted)';
}


}

/// @nodoc
abstract mixin class $InProgressLevelCopyWith<$Res>  {
  factory $InProgressLevelCopyWith(InProgressLevel value, $Res Function(InProgressLevel) _then) = _$InProgressLevelCopyWithImpl;
@useResult
$Res call({
 PlayRequest request, String levelId, int levelVersion, Map<String, Object?> session, Map<String, Object?>? level, Tier? tier, bool hinted
});


$PlayRequestCopyWith<$Res> get request;

}
/// @nodoc
class _$InProgressLevelCopyWithImpl<$Res>
    implements $InProgressLevelCopyWith<$Res> {
  _$InProgressLevelCopyWithImpl(this._self, this._then);

  final InProgressLevel _self;
  final $Res Function(InProgressLevel) _then;

/// Create a copy of InProgressLevel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? request = null,Object? levelId = null,Object? levelVersion = null,Object? session = null,Object? level = freezed,Object? tier = freezed,Object? hinted = null,}) {
  return _then(_self.copyWith(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PlayRequest,levelId: null == levelId ? _self.levelId : levelId // ignore: cast_nullable_to_non_nullable
as String,levelVersion: null == levelVersion ? _self.levelVersion : levelVersion // ignore: cast_nullable_to_non_nullable
as int,session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,tier: freezed == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier?,hinted: null == hinted ? _self.hinted : hinted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of InProgressLevel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res> get request {
  
  return $PlayRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}


/// Adds pattern-matching-related methods to [InProgressLevel].
extension InProgressLevelPatterns on InProgressLevel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InProgressLevel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InProgressLevel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InProgressLevel value)  $default,){
final _that = this;
switch (_that) {
case _InProgressLevel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InProgressLevel value)?  $default,){
final _that = this;
switch (_that) {
case _InProgressLevel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayRequest request,  String levelId,  int levelVersion,  Map<String, Object?> session,  Map<String, Object?>? level,  Tier? tier,  bool hinted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InProgressLevel() when $default != null:
return $default(_that.request,_that.levelId,_that.levelVersion,_that.session,_that.level,_that.tier,_that.hinted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayRequest request,  String levelId,  int levelVersion,  Map<String, Object?> session,  Map<String, Object?>? level,  Tier? tier,  bool hinted)  $default,) {final _that = this;
switch (_that) {
case _InProgressLevel():
return $default(_that.request,_that.levelId,_that.levelVersion,_that.session,_that.level,_that.tier,_that.hinted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayRequest request,  String levelId,  int levelVersion,  Map<String, Object?> session,  Map<String, Object?>? level,  Tier? tier,  bool hinted)?  $default,) {final _that = this;
switch (_that) {
case _InProgressLevel() when $default != null:
return $default(_that.request,_that.levelId,_that.levelVersion,_that.session,_that.level,_that.tier,_that.hinted);case _:
  return null;

}
}

}

/// @nodoc


class _InProgressLevel implements InProgressLevel {
  const _InProgressLevel({required this.request, required this.levelId, required this.levelVersion, required final  Map<String, Object?> session, final  Map<String, Object?>? level, this.tier, this.hinted = false}): _session = session,_level = level;
  

/// What is being played; its kind and number are stored.
@override final  PlayRequest request;
/// `Level.id` of the board.
@override final  String levelId;
/// Must equal the entry's `PlayEntry.levelVersion` to restore (§13.3).
@override final  int levelVersion;
/// `GameSessionCodec.encode` of the session: the board, the undo
/// history and `undosUsed`. The selection and the hint are not saved.
 final  Map<String, Object?> _session;
/// `GameSessionCodec.encode` of the session: the board, the undo
/// history and `undosUsed`. The selection and the hint are not saved.
@override Map<String, Object?> get session {
  if (_session is EqualUnmodifiableMapView) return _session;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_session);
}

/// `LevelCodec.encode` of a generated board (bonus, daily), so a resume
/// never regenerates it. Null for campaign levels.
 final  Map<String, Object?>? _level;
/// `LevelCodec.encode` of a generated board (bonus, daily), so a resume
/// never regenerates it. Null for campaign levels.
@override Map<String, Object?>? get level {
  final value = _level;
  if (value == null) return null;
  if (_level is EqualUnmodifiableMapView) return _level;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// A generated board's tier, so a resume needn't simulate it again.
@override final  Tier? tier;
/// A hint was shown during this attempt, since the last Restart (Q116;
/// m7-design P3.6): the win's stars are capped at 2 even after a kill
/// and a restore. Restart clears it.
@override@JsonKey() final  bool hinted;

/// Create a copy of InProgressLevel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InProgressLevelCopyWith<_InProgressLevel> get copyWith => __$InProgressLevelCopyWithImpl<_InProgressLevel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InProgressLevel&&(identical(other.request, request) || other.request == request)&&(identical(other.levelId, levelId) || other.levelId == levelId)&&(identical(other.levelVersion, levelVersion) || other.levelVersion == levelVersion)&&const DeepCollectionEquality().equals(other._session, _session)&&const DeepCollectionEquality().equals(other._level, _level)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.hinted, hinted) || other.hinted == hinted));
}


@override
int get hashCode => Object.hash(runtimeType,request,levelId,levelVersion,const DeepCollectionEquality().hash(_session),const DeepCollectionEquality().hash(_level),tier,hinted);

@override
String toString() {
  return 'InProgressLevel(request: $request, levelId: $levelId, levelVersion: $levelVersion, session: $session, level: $level, tier: $tier, hinted: $hinted)';
}


}

/// @nodoc
abstract mixin class _$InProgressLevelCopyWith<$Res> implements $InProgressLevelCopyWith<$Res> {
  factory _$InProgressLevelCopyWith(_InProgressLevel value, $Res Function(_InProgressLevel) _then) = __$InProgressLevelCopyWithImpl;
@override @useResult
$Res call({
 PlayRequest request, String levelId, int levelVersion, Map<String, Object?> session, Map<String, Object?>? level, Tier? tier, bool hinted
});


@override $PlayRequestCopyWith<$Res> get request;

}
/// @nodoc
class __$InProgressLevelCopyWithImpl<$Res>
    implements _$InProgressLevelCopyWith<$Res> {
  __$InProgressLevelCopyWithImpl(this._self, this._then);

  final _InProgressLevel _self;
  final $Res Function(_InProgressLevel) _then;

/// Create a copy of InProgressLevel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? request = null,Object? levelId = null,Object? levelVersion = null,Object? session = null,Object? level = freezed,Object? tier = freezed,Object? hinted = null,}) {
  return _then(_InProgressLevel(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PlayRequest,levelId: null == levelId ? _self.levelId : levelId // ignore: cast_nullable_to_non_nullable
as String,levelVersion: null == levelVersion ? _self.levelVersion : levelVersion // ignore: cast_nullable_to_non_nullable
as int,session: null == session ? _self._session : session // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,level: freezed == level ? _self._level : level // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,tier: freezed == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier?,hinted: null == hinted ? _self.hinted : hinted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of InProgressLevel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res> get request {
  
  return $PlayRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}

/// @nodoc
mixin _$AdCounters {

 int get winsSinceInterstitial;/// Milliseconds since the epoch; 0 for never.
 int get lastAdAt; int get interstitialsShown;
/// Create a copy of AdCounters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdCountersCopyWith<AdCounters> get copyWith => _$AdCountersCopyWithImpl<AdCounters>(this as AdCounters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdCounters&&(identical(other.winsSinceInterstitial, winsSinceInterstitial) || other.winsSinceInterstitial == winsSinceInterstitial)&&(identical(other.lastAdAt, lastAdAt) || other.lastAdAt == lastAdAt)&&(identical(other.interstitialsShown, interstitialsShown) || other.interstitialsShown == interstitialsShown));
}


@override
int get hashCode => Object.hash(runtimeType,winsSinceInterstitial,lastAdAt,interstitialsShown);

@override
String toString() {
  return 'AdCounters(winsSinceInterstitial: $winsSinceInterstitial, lastAdAt: $lastAdAt, interstitialsShown: $interstitialsShown)';
}


}

/// @nodoc
abstract mixin class $AdCountersCopyWith<$Res>  {
  factory $AdCountersCopyWith(AdCounters value, $Res Function(AdCounters) _then) = _$AdCountersCopyWithImpl;
@useResult
$Res call({
 int winsSinceInterstitial, int lastAdAt, int interstitialsShown
});




}
/// @nodoc
class _$AdCountersCopyWithImpl<$Res>
    implements $AdCountersCopyWith<$Res> {
  _$AdCountersCopyWithImpl(this._self, this._then);

  final AdCounters _self;
  final $Res Function(AdCounters) _then;

/// Create a copy of AdCounters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? winsSinceInterstitial = null,Object? lastAdAt = null,Object? interstitialsShown = null,}) {
  return _then(_self.copyWith(
winsSinceInterstitial: null == winsSinceInterstitial ? _self.winsSinceInterstitial : winsSinceInterstitial // ignore: cast_nullable_to_non_nullable
as int,lastAdAt: null == lastAdAt ? _self.lastAdAt : lastAdAt // ignore: cast_nullable_to_non_nullable
as int,interstitialsShown: null == interstitialsShown ? _self.interstitialsShown : interstitialsShown // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AdCounters].
extension AdCountersPatterns on AdCounters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdCounters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdCounters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdCounters value)  $default,){
final _that = this;
switch (_that) {
case _AdCounters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdCounters value)?  $default,){
final _that = this;
switch (_that) {
case _AdCounters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int winsSinceInterstitial,  int lastAdAt,  int interstitialsShown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdCounters() when $default != null:
return $default(_that.winsSinceInterstitial,_that.lastAdAt,_that.interstitialsShown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int winsSinceInterstitial,  int lastAdAt,  int interstitialsShown)  $default,) {final _that = this;
switch (_that) {
case _AdCounters():
return $default(_that.winsSinceInterstitial,_that.lastAdAt,_that.interstitialsShown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int winsSinceInterstitial,  int lastAdAt,  int interstitialsShown)?  $default,) {final _that = this;
switch (_that) {
case _AdCounters() when $default != null:
return $default(_that.winsSinceInterstitial,_that.lastAdAt,_that.interstitialsShown);case _:
  return null;

}
}

}

/// @nodoc


class _AdCounters implements AdCounters {
  const _AdCounters({this.winsSinceInterstitial = 0, this.lastAdAt = 0, this.interstitialsShown = 0});
  

@override@JsonKey() final  int winsSinceInterstitial;
/// Milliseconds since the epoch; 0 for never.
@override@JsonKey() final  int lastAdAt;
@override@JsonKey() final  int interstitialsShown;

/// Create a copy of AdCounters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdCountersCopyWith<_AdCounters> get copyWith => __$AdCountersCopyWithImpl<_AdCounters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdCounters&&(identical(other.winsSinceInterstitial, winsSinceInterstitial) || other.winsSinceInterstitial == winsSinceInterstitial)&&(identical(other.lastAdAt, lastAdAt) || other.lastAdAt == lastAdAt)&&(identical(other.interstitialsShown, interstitialsShown) || other.interstitialsShown == interstitialsShown));
}


@override
int get hashCode => Object.hash(runtimeType,winsSinceInterstitial,lastAdAt,interstitialsShown);

@override
String toString() {
  return 'AdCounters(winsSinceInterstitial: $winsSinceInterstitial, lastAdAt: $lastAdAt, interstitialsShown: $interstitialsShown)';
}


}

/// @nodoc
abstract mixin class _$AdCountersCopyWith<$Res> implements $AdCountersCopyWith<$Res> {
  factory _$AdCountersCopyWith(_AdCounters value, $Res Function(_AdCounters) _then) = __$AdCountersCopyWithImpl;
@override @useResult
$Res call({
 int winsSinceInterstitial, int lastAdAt, int interstitialsShown
});




}
/// @nodoc
class __$AdCountersCopyWithImpl<$Res>
    implements _$AdCountersCopyWith<$Res> {
  __$AdCountersCopyWithImpl(this._self, this._then);

  final _AdCounters _self;
  final $Res Function(_AdCounters) _then;

/// Create a copy of AdCounters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? winsSinceInterstitial = null,Object? lastAdAt = null,Object? interstitialsShown = null,}) {
  return _then(_AdCounters(
winsSinceInterstitial: null == winsSinceInterstitial ? _self.winsSinceInterstitial : winsSinceInterstitial // ignore: cast_nullable_to_non_nullable
as int,lastAdAt: null == lastAdAt ? _self.lastAdAt : lastAdAt // ignore: cast_nullable_to_non_nullable
as int,interstitialsShown: null == interstitialsShown ? _self.interstitialsShown : interstitialsShown // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SaveStats {

/// Levels won: campaign, bonus and daily.
 int get wins;/// Moves of the won levels (`GameState.moveCount` at the win).
 int get moves;/// `BoosterType.id` → uses.
 Map<String, int> get boostersUsed;
/// Create a copy of SaveStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveStatsCopyWith<SaveStats> get copyWith => _$SaveStatsCopyWithImpl<SaveStats>(this as SaveStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveStats&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.moves, moves) || other.moves == moves)&&const DeepCollectionEquality().equals(other.boostersUsed, boostersUsed));
}


@override
int get hashCode => Object.hash(runtimeType,wins,moves,const DeepCollectionEquality().hash(boostersUsed));

@override
String toString() {
  return 'SaveStats(wins: $wins, moves: $moves, boostersUsed: $boostersUsed)';
}


}

/// @nodoc
abstract mixin class $SaveStatsCopyWith<$Res>  {
  factory $SaveStatsCopyWith(SaveStats value, $Res Function(SaveStats) _then) = _$SaveStatsCopyWithImpl;
@useResult
$Res call({
 int wins, int moves, Map<String, int> boostersUsed
});




}
/// @nodoc
class _$SaveStatsCopyWithImpl<$Res>
    implements $SaveStatsCopyWith<$Res> {
  _$SaveStatsCopyWithImpl(this._self, this._then);

  final SaveStats _self;
  final $Res Function(SaveStats) _then;

/// Create a copy of SaveStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wins = null,Object? moves = null,Object? boostersUsed = null,}) {
  return _then(_self.copyWith(
wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,boostersUsed: null == boostersUsed ? _self.boostersUsed : boostersUsed // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [SaveStats].
extension SaveStatsPatterns on SaveStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaveStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaveStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaveStats value)  $default,){
final _that = this;
switch (_that) {
case _SaveStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaveStats value)?  $default,){
final _that = this;
switch (_that) {
case _SaveStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int wins,  int moves,  Map<String, int> boostersUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaveStats() when $default != null:
return $default(_that.wins,_that.moves,_that.boostersUsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int wins,  int moves,  Map<String, int> boostersUsed)  $default,) {final _that = this;
switch (_that) {
case _SaveStats():
return $default(_that.wins,_that.moves,_that.boostersUsed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int wins,  int moves,  Map<String, int> boostersUsed)?  $default,) {final _that = this;
switch (_that) {
case _SaveStats() when $default != null:
return $default(_that.wins,_that.moves,_that.boostersUsed);case _:
  return null;

}
}

}

/// @nodoc


class _SaveStats implements SaveStats {
  const _SaveStats({this.wins = 0, this.moves = 0, final  Map<String, int> boostersUsed = const <String, int>{}}): _boostersUsed = boostersUsed;
  

/// Levels won: campaign, bonus and daily.
@override@JsonKey() final  int wins;
/// Moves of the won levels (`GameState.moveCount` at the win).
@override@JsonKey() final  int moves;
/// `BoosterType.id` → uses.
 final  Map<String, int> _boostersUsed;
/// `BoosterType.id` → uses.
@override@JsonKey() Map<String, int> get boostersUsed {
  if (_boostersUsed is EqualUnmodifiableMapView) return _boostersUsed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_boostersUsed);
}


/// Create a copy of SaveStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaveStatsCopyWith<_SaveStats> get copyWith => __$SaveStatsCopyWithImpl<_SaveStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveStats&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.moves, moves) || other.moves == moves)&&const DeepCollectionEquality().equals(other._boostersUsed, _boostersUsed));
}


@override
int get hashCode => Object.hash(runtimeType,wins,moves,const DeepCollectionEquality().hash(_boostersUsed));

@override
String toString() {
  return 'SaveStats(wins: $wins, moves: $moves, boostersUsed: $boostersUsed)';
}


}

/// @nodoc
abstract mixin class _$SaveStatsCopyWith<$Res> implements $SaveStatsCopyWith<$Res> {
  factory _$SaveStatsCopyWith(_SaveStats value, $Res Function(_SaveStats) _then) = __$SaveStatsCopyWithImpl;
@override @useResult
$Res call({
 int wins, int moves, Map<String, int> boostersUsed
});




}
/// @nodoc
class __$SaveStatsCopyWithImpl<$Res>
    implements _$SaveStatsCopyWith<$Res> {
  __$SaveStatsCopyWithImpl(this._self, this._then);

  final _SaveStats _self;
  final $Res Function(_SaveStats) _then;

/// Create a copy of SaveStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wins = null,Object? moves = null,Object? boostersUsed = null,}) {
  return _then(_SaveStats(
wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,boostersUsed: null == boostersUsed ? _self._boostersUsed : boostersUsed // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

/// @nodoc
mixin _$BonusProgress {

/// The "Bonus Level N" PLAY starts next, from 1.
 int get next;
/// Create a copy of BonusProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BonusProgressCopyWith<BonusProgress> get copyWith => _$BonusProgressCopyWithImpl<BonusProgress>(this as BonusProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BonusProgress&&(identical(other.next, next) || other.next == next));
}


@override
int get hashCode => Object.hash(runtimeType,next);

@override
String toString() {
  return 'BonusProgress(next: $next)';
}


}

/// @nodoc
abstract mixin class $BonusProgressCopyWith<$Res>  {
  factory $BonusProgressCopyWith(BonusProgress value, $Res Function(BonusProgress) _then) = _$BonusProgressCopyWithImpl;
@useResult
$Res call({
 int next
});




}
/// @nodoc
class _$BonusProgressCopyWithImpl<$Res>
    implements $BonusProgressCopyWith<$Res> {
  _$BonusProgressCopyWithImpl(this._self, this._then);

  final BonusProgress _self;
  final $Res Function(BonusProgress) _then;

/// Create a copy of BonusProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? next = null,}) {
  return _then(_self.copyWith(
next: null == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BonusProgress].
extension BonusProgressPatterns on BonusProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BonusProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BonusProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BonusProgress value)  $default,){
final _that = this;
switch (_that) {
case _BonusProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BonusProgress value)?  $default,){
final _that = this;
switch (_that) {
case _BonusProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int next)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BonusProgress() when $default != null:
return $default(_that.next);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int next)  $default,) {final _that = this;
switch (_that) {
case _BonusProgress():
return $default(_that.next);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int next)?  $default,) {final _that = this;
switch (_that) {
case _BonusProgress() when $default != null:
return $default(_that.next);case _:
  return null;

}
}

}

/// @nodoc


class _BonusProgress implements BonusProgress {
  const _BonusProgress({this.next = 1});
  

/// The "Bonus Level N" PLAY starts next, from 1.
@override@JsonKey() final  int next;

/// Create a copy of BonusProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BonusProgressCopyWith<_BonusProgress> get copyWith => __$BonusProgressCopyWithImpl<_BonusProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BonusProgress&&(identical(other.next, next) || other.next == next));
}


@override
int get hashCode => Object.hash(runtimeType,next);

@override
String toString() {
  return 'BonusProgress(next: $next)';
}


}

/// @nodoc
abstract mixin class _$BonusProgressCopyWith<$Res> implements $BonusProgressCopyWith<$Res> {
  factory _$BonusProgressCopyWith(_BonusProgress value, $Res Function(_BonusProgress) _then) = __$BonusProgressCopyWithImpl;
@override @useResult
$Res call({
 int next
});




}
/// @nodoc
class __$BonusProgressCopyWithImpl<$Res>
    implements _$BonusProgressCopyWith<$Res> {
  __$BonusProgressCopyWithImpl(this._self, this._then);

  final _BonusProgress _self;
  final $Res Function(_BonusProgress) _then;

/// Create a copy of BonusProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? next = null,}) {
  return _then(_BonusProgress(
next: null == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$LevelWinRecord {

/// What was won. A campaign win moves [SaveDocument.currentLevel] past
/// its order (never back), a bonus win moves `bonus.next` past its
/// number, a daily win takes [daily]. Its in-progress board is cleared.
 PlayRequest get request;/// The level's coins ([PlayEntry.rewardCoins]).
 int get rewardCoins;/// `GameState.moveCount` at the win (`stats.moves`).
 int get moves;/// A campaign win that completed its chapter: this chapter id joins the
/// museum with [date], and [chapterReward] is paid, only if it isn't
/// there yet.
 String? get completedChapterId;/// `reward_chapter` (m3-design §7.1).
 int get chapterReward;/// Today (the museum's collected date).
 LocalDate? get date;/// A daily win: the streak after the solve
/// (`DailyService.progressAfterSolve`).
 DailyProgress? get daily;/// A bundled board's `LevelBests.key` (a campaign level or a replay):
/// [moves] becomes the level's best when fewer (m7-design §11). Null
/// for generated boards, which keep no best.
 String? get bestKey;/// The milestone chest this win reaches (`MilestoneChest.forWin`),
/// paid in the same update unless `chests` already has it (m7-design
/// §9). Never set for a replay; the save ignores one anyway.
 ChestGrant? get chest;/// The families the won board completed (`RecordRules.familiesIn`),
/// added to `records.families` (m7-design §12).
 int get families;/// The dolls the won board nested (`RecordRules.dollsNestedIn`), added
/// to `records.dolls` (m7-design §12).
 int get dolls;/// Badges the won board itself earns (`BadgeRules.forWonBoard`): glass,
/// ice and tall boards (m7-design §12). The save adds the ones
/// derivable from the document after the win.
 List<BadgeId> get boardBadges;/// The bundled level's id (`StarRules.keyOf`) whose best stars this win
/// may raise (spec-prop §7.10; m7-design P3.4). Null for generated
/// boards and for an entry without a par: no stars.
 String? get starsKey;/// This win's stars, 1–3 (`StarRating.starsForWin`); null with no
/// [starsKey]. Stars pay and unlock nothing: only `levelStars` reads
/// them.
 int? get stars;/// The local minute of the day of the win (0–1439, from `AppClock`).
/// The save keeps it only for a daily (`DailySolve.minuteOfDay`).
 int? get minuteOfDay;/// The win's [stars] were capped by a hint or an extra slot: the
/// uncapped rule would have given 3 (`GameplayState.starsCapped`; Q145).
/// The card shows the helper note, so [LevelWinOutcome.showStarTip]
/// stays false (phase 4 architecture §3.6). Not stored.
 bool get starsCapped;
/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LevelWinRecordCopyWith<LevelWinRecord> get copyWith => _$LevelWinRecordCopyWithImpl<LevelWinRecord>(this as LevelWinRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LevelWinRecord&&(identical(other.request, request) || other.request == request)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.completedChapterId, completedChapterId) || other.completedChapterId == completedChapterId)&&(identical(other.chapterReward, chapterReward) || other.chapterReward == chapterReward)&&(identical(other.date, date) || other.date == date)&&(identical(other.daily, daily) || other.daily == daily)&&(identical(other.bestKey, bestKey) || other.bestKey == bestKey)&&(identical(other.chest, chest) || other.chest == chest)&&(identical(other.families, families) || other.families == families)&&(identical(other.dolls, dolls) || other.dolls == dolls)&&const DeepCollectionEquality().equals(other.boardBadges, boardBadges)&&(identical(other.starsKey, starsKey) || other.starsKey == starsKey)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.minuteOfDay, minuteOfDay) || other.minuteOfDay == minuteOfDay)&&(identical(other.starsCapped, starsCapped) || other.starsCapped == starsCapped));
}


@override
int get hashCode => Object.hash(runtimeType,request,rewardCoins,moves,completedChapterId,chapterReward,date,daily,bestKey,chest,families,dolls,const DeepCollectionEquality().hash(boardBadges),starsKey,stars,minuteOfDay,starsCapped);

@override
String toString() {
  return 'LevelWinRecord(request: $request, rewardCoins: $rewardCoins, moves: $moves, completedChapterId: $completedChapterId, chapterReward: $chapterReward, date: $date, daily: $daily, bestKey: $bestKey, chest: $chest, families: $families, dolls: $dolls, boardBadges: $boardBadges, starsKey: $starsKey, stars: $stars, minuteOfDay: $minuteOfDay, starsCapped: $starsCapped)';
}


}

/// @nodoc
abstract mixin class $LevelWinRecordCopyWith<$Res>  {
  factory $LevelWinRecordCopyWith(LevelWinRecord value, $Res Function(LevelWinRecord) _then) = _$LevelWinRecordCopyWithImpl;
@useResult
$Res call({
 PlayRequest request, int rewardCoins, int moves, String? completedChapterId, int chapterReward, LocalDate? date, DailyProgress? daily, String? bestKey, ChestGrant? chest, int families, int dolls, List<BadgeId> boardBadges, String? starsKey, int? stars, int? minuteOfDay, bool starsCapped
});


$PlayRequestCopyWith<$Res> get request;$DailyProgressCopyWith<$Res>? get daily;$ChestGrantCopyWith<$Res>? get chest;

}
/// @nodoc
class _$LevelWinRecordCopyWithImpl<$Res>
    implements $LevelWinRecordCopyWith<$Res> {
  _$LevelWinRecordCopyWithImpl(this._self, this._then);

  final LevelWinRecord _self;
  final $Res Function(LevelWinRecord) _then;

/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? request = null,Object? rewardCoins = null,Object? moves = null,Object? completedChapterId = freezed,Object? chapterReward = null,Object? date = freezed,Object? daily = freezed,Object? bestKey = freezed,Object? chest = freezed,Object? families = null,Object? dolls = null,Object? boardBadges = null,Object? starsKey = freezed,Object? stars = freezed,Object? minuteOfDay = freezed,Object? starsCapped = null,}) {
  return _then(_self.copyWith(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PlayRequest,rewardCoins: null == rewardCoins ? _self.rewardCoins : rewardCoins // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,completedChapterId: freezed == completedChapterId ? _self.completedChapterId : completedChapterId // ignore: cast_nullable_to_non_nullable
as String?,chapterReward: null == chapterReward ? _self.chapterReward : chapterReward // ignore: cast_nullable_to_non_nullable
as int,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate?,daily: freezed == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as DailyProgress?,bestKey: freezed == bestKey ? _self.bestKey : bestKey // ignore: cast_nullable_to_non_nullable
as String?,chest: freezed == chest ? _self.chest : chest // ignore: cast_nullable_to_non_nullable
as ChestGrant?,families: null == families ? _self.families : families // ignore: cast_nullable_to_non_nullable
as int,dolls: null == dolls ? _self.dolls : dolls // ignore: cast_nullable_to_non_nullable
as int,boardBadges: null == boardBadges ? _self.boardBadges : boardBadges // ignore: cast_nullable_to_non_nullable
as List<BadgeId>,starsKey: freezed == starsKey ? _self.starsKey : starsKey // ignore: cast_nullable_to_non_nullable
as String?,stars: freezed == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int?,minuteOfDay: freezed == minuteOfDay ? _self.minuteOfDay : minuteOfDay // ignore: cast_nullable_to_non_nullable
as int?,starsCapped: null == starsCapped ? _self.starsCapped : starsCapped // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res> get request {
  
  return $PlayRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailyProgressCopyWith<$Res>? get daily {
    if (_self.daily == null) {
    return null;
  }

  return $DailyProgressCopyWith<$Res>(_self.daily!, (value) {
    return _then(_self.copyWith(daily: value));
  });
}/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChestGrantCopyWith<$Res>? get chest {
    if (_self.chest == null) {
    return null;
  }

  return $ChestGrantCopyWith<$Res>(_self.chest!, (value) {
    return _then(_self.copyWith(chest: value));
  });
}
}


/// Adds pattern-matching-related methods to [LevelWinRecord].
extension LevelWinRecordPatterns on LevelWinRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LevelWinRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LevelWinRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LevelWinRecord value)  $default,){
final _that = this;
switch (_that) {
case _LevelWinRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LevelWinRecord value)?  $default,){
final _that = this;
switch (_that) {
case _LevelWinRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayRequest request,  int rewardCoins,  int moves,  String? completedChapterId,  int chapterReward,  LocalDate? date,  DailyProgress? daily,  String? bestKey,  ChestGrant? chest,  int families,  int dolls,  List<BadgeId> boardBadges,  String? starsKey,  int? stars,  int? minuteOfDay,  bool starsCapped)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LevelWinRecord() when $default != null:
return $default(_that.request,_that.rewardCoins,_that.moves,_that.completedChapterId,_that.chapterReward,_that.date,_that.daily,_that.bestKey,_that.chest,_that.families,_that.dolls,_that.boardBadges,_that.starsKey,_that.stars,_that.minuteOfDay,_that.starsCapped);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayRequest request,  int rewardCoins,  int moves,  String? completedChapterId,  int chapterReward,  LocalDate? date,  DailyProgress? daily,  String? bestKey,  ChestGrant? chest,  int families,  int dolls,  List<BadgeId> boardBadges,  String? starsKey,  int? stars,  int? minuteOfDay,  bool starsCapped)  $default,) {final _that = this;
switch (_that) {
case _LevelWinRecord():
return $default(_that.request,_that.rewardCoins,_that.moves,_that.completedChapterId,_that.chapterReward,_that.date,_that.daily,_that.bestKey,_that.chest,_that.families,_that.dolls,_that.boardBadges,_that.starsKey,_that.stars,_that.minuteOfDay,_that.starsCapped);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayRequest request,  int rewardCoins,  int moves,  String? completedChapterId,  int chapterReward,  LocalDate? date,  DailyProgress? daily,  String? bestKey,  ChestGrant? chest,  int families,  int dolls,  List<BadgeId> boardBadges,  String? starsKey,  int? stars,  int? minuteOfDay,  bool starsCapped)?  $default,) {final _that = this;
switch (_that) {
case _LevelWinRecord() when $default != null:
return $default(_that.request,_that.rewardCoins,_that.moves,_that.completedChapterId,_that.chapterReward,_that.date,_that.daily,_that.bestKey,_that.chest,_that.families,_that.dolls,_that.boardBadges,_that.starsKey,_that.stars,_that.minuteOfDay,_that.starsCapped);case _:
  return null;

}
}

}

/// @nodoc


class _LevelWinRecord implements LevelWinRecord {
  const _LevelWinRecord({required this.request, required this.rewardCoins, this.moves = 0, this.completedChapterId, this.chapterReward = 0, this.date, this.daily, this.bestKey, this.chest, this.families = 0, this.dolls = 0, final  List<BadgeId> boardBadges = const <BadgeId>[], this.starsKey, this.stars, this.minuteOfDay, this.starsCapped = false}): _boardBadges = boardBadges;
  

/// What was won. A campaign win moves [SaveDocument.currentLevel] past
/// its order (never back), a bonus win moves `bonus.next` past its
/// number, a daily win takes [daily]. Its in-progress board is cleared.
@override final  PlayRequest request;
/// The level's coins ([PlayEntry.rewardCoins]).
@override final  int rewardCoins;
/// `GameState.moveCount` at the win (`stats.moves`).
@override@JsonKey() final  int moves;
/// A campaign win that completed its chapter: this chapter id joins the
/// museum with [date], and [chapterReward] is paid, only if it isn't
/// there yet.
@override final  String? completedChapterId;
/// `reward_chapter` (m3-design §7.1).
@override@JsonKey() final  int chapterReward;
/// Today (the museum's collected date).
@override final  LocalDate? date;
/// A daily win: the streak after the solve
/// (`DailyService.progressAfterSolve`).
@override final  DailyProgress? daily;
/// A bundled board's `LevelBests.key` (a campaign level or a replay):
/// [moves] becomes the level's best when fewer (m7-design §11). Null
/// for generated boards, which keep no best.
@override final  String? bestKey;
/// The milestone chest this win reaches (`MilestoneChest.forWin`),
/// paid in the same update unless `chests` already has it (m7-design
/// §9). Never set for a replay; the save ignores one anyway.
@override final  ChestGrant? chest;
/// The families the won board completed (`RecordRules.familiesIn`),
/// added to `records.families` (m7-design §12).
@override@JsonKey() final  int families;
/// The dolls the won board nested (`RecordRules.dollsNestedIn`), added
/// to `records.dolls` (m7-design §12).
@override@JsonKey() final  int dolls;
/// Badges the won board itself earns (`BadgeRules.forWonBoard`): glass,
/// ice and tall boards (m7-design §12). The save adds the ones
/// derivable from the document after the win.
 final  List<BadgeId> _boardBadges;
/// Badges the won board itself earns (`BadgeRules.forWonBoard`): glass,
/// ice and tall boards (m7-design §12). The save adds the ones
/// derivable from the document after the win.
@override@JsonKey() List<BadgeId> get boardBadges {
  if (_boardBadges is EqualUnmodifiableListView) return _boardBadges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_boardBadges);
}

/// The bundled level's id (`StarRules.keyOf`) whose best stars this win
/// may raise (spec-prop §7.10; m7-design P3.4). Null for generated
/// boards and for an entry without a par: no stars.
@override final  String? starsKey;
/// This win's stars, 1–3 (`StarRating.starsForWin`); null with no
/// [starsKey]. Stars pay and unlock nothing: only `levelStars` reads
/// them.
@override final  int? stars;
/// The local minute of the day of the win (0–1439, from `AppClock`).
/// The save keeps it only for a daily (`DailySolve.minuteOfDay`).
@override final  int? minuteOfDay;
/// The win's [stars] were capped by a hint or an extra slot: the
/// uncapped rule would have given 3 (`GameplayState.starsCapped`; Q145).
/// The card shows the helper note, so [LevelWinOutcome.showStarTip]
/// stays false (phase 4 architecture §3.6). Not stored.
@override@JsonKey() final  bool starsCapped;

/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LevelWinRecordCopyWith<_LevelWinRecord> get copyWith => __$LevelWinRecordCopyWithImpl<_LevelWinRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LevelWinRecord&&(identical(other.request, request) || other.request == request)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.completedChapterId, completedChapterId) || other.completedChapterId == completedChapterId)&&(identical(other.chapterReward, chapterReward) || other.chapterReward == chapterReward)&&(identical(other.date, date) || other.date == date)&&(identical(other.daily, daily) || other.daily == daily)&&(identical(other.bestKey, bestKey) || other.bestKey == bestKey)&&(identical(other.chest, chest) || other.chest == chest)&&(identical(other.families, families) || other.families == families)&&(identical(other.dolls, dolls) || other.dolls == dolls)&&const DeepCollectionEquality().equals(other._boardBadges, _boardBadges)&&(identical(other.starsKey, starsKey) || other.starsKey == starsKey)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.minuteOfDay, minuteOfDay) || other.minuteOfDay == minuteOfDay)&&(identical(other.starsCapped, starsCapped) || other.starsCapped == starsCapped));
}


@override
int get hashCode => Object.hash(runtimeType,request,rewardCoins,moves,completedChapterId,chapterReward,date,daily,bestKey,chest,families,dolls,const DeepCollectionEquality().hash(_boardBadges),starsKey,stars,minuteOfDay,starsCapped);

@override
String toString() {
  return 'LevelWinRecord(request: $request, rewardCoins: $rewardCoins, moves: $moves, completedChapterId: $completedChapterId, chapterReward: $chapterReward, date: $date, daily: $daily, bestKey: $bestKey, chest: $chest, families: $families, dolls: $dolls, boardBadges: $boardBadges, starsKey: $starsKey, stars: $stars, minuteOfDay: $minuteOfDay, starsCapped: $starsCapped)';
}


}

/// @nodoc
abstract mixin class _$LevelWinRecordCopyWith<$Res> implements $LevelWinRecordCopyWith<$Res> {
  factory _$LevelWinRecordCopyWith(_LevelWinRecord value, $Res Function(_LevelWinRecord) _then) = __$LevelWinRecordCopyWithImpl;
@override @useResult
$Res call({
 PlayRequest request, int rewardCoins, int moves, String? completedChapterId, int chapterReward, LocalDate? date, DailyProgress? daily, String? bestKey, ChestGrant? chest, int families, int dolls, List<BadgeId> boardBadges, String? starsKey, int? stars, int? minuteOfDay, bool starsCapped
});


@override $PlayRequestCopyWith<$Res> get request;@override $DailyProgressCopyWith<$Res>? get daily;@override $ChestGrantCopyWith<$Res>? get chest;

}
/// @nodoc
class __$LevelWinRecordCopyWithImpl<$Res>
    implements _$LevelWinRecordCopyWith<$Res> {
  __$LevelWinRecordCopyWithImpl(this._self, this._then);

  final _LevelWinRecord _self;
  final $Res Function(_LevelWinRecord) _then;

/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? request = null,Object? rewardCoins = null,Object? moves = null,Object? completedChapterId = freezed,Object? chapterReward = null,Object? date = freezed,Object? daily = freezed,Object? bestKey = freezed,Object? chest = freezed,Object? families = null,Object? dolls = null,Object? boardBadges = null,Object? starsKey = freezed,Object? stars = freezed,Object? minuteOfDay = freezed,Object? starsCapped = null,}) {
  return _then(_LevelWinRecord(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PlayRequest,rewardCoins: null == rewardCoins ? _self.rewardCoins : rewardCoins // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,completedChapterId: freezed == completedChapterId ? _self.completedChapterId : completedChapterId // ignore: cast_nullable_to_non_nullable
as String?,chapterReward: null == chapterReward ? _self.chapterReward : chapterReward // ignore: cast_nullable_to_non_nullable
as int,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate?,daily: freezed == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as DailyProgress?,bestKey: freezed == bestKey ? _self.bestKey : bestKey // ignore: cast_nullable_to_non_nullable
as String?,chest: freezed == chest ? _self.chest : chest // ignore: cast_nullable_to_non_nullable
as ChestGrant?,families: null == families ? _self.families : families // ignore: cast_nullable_to_non_nullable
as int,dolls: null == dolls ? _self.dolls : dolls // ignore: cast_nullable_to_non_nullable
as int,boardBadges: null == boardBadges ? _self._boardBadges : boardBadges // ignore: cast_nullable_to_non_nullable
as List<BadgeId>,starsKey: freezed == starsKey ? _self.starsKey : starsKey // ignore: cast_nullable_to_non_nullable
as String?,stars: freezed == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int?,minuteOfDay: freezed == minuteOfDay ? _self.minuteOfDay : minuteOfDay // ignore: cast_nullable_to_non_nullable
as int?,starsCapped: null == starsCapped ? _self.starsCapped : starsCapped // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayRequestCopyWith<$Res> get request {
  
  return $PlayRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailyProgressCopyWith<$Res>? get daily {
    if (_self.daily == null) {
    return null;
  }

  return $DailyProgressCopyWith<$Res>(_self.daily!, (value) {
    return _then(_self.copyWith(daily: value));
  });
}/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChestGrantCopyWith<$Res>? get chest {
    if (_self.chest == null) {
    return null;
  }

  return $ChestGrantCopyWith<$Res>(_self.chest!, (value) {
    return _then(_self.copyWith(chest: value));
  });
}
}

/// @nodoc
mixin _$LevelWinOutcome {

/// The level's best moves after this win (so never above its moves);
/// null when the win had no `LevelWinRecord.bestKey`.
 int? get bestMoves;/// The best before this win, or null when it had none (a first win, or
/// no best kept).
 int? get previousBest;/// The milestone chest this win opened and paid, or null (none reached,
/// already opened, or a replay).
 ChestGrant? get chestPaid;/// The badges this win earned, in [BadgeId] order (one toast each).
 List<BadgeId> get newBadges;/// The level's best stars after this win (so never below this win's),
/// or null when the win had no stars (m7-design P3.4).
 int? get stars;/// The level's best stars before this win; null when it had none (a
/// first win, or a level won before stars that the backfill hasn't
/// reached).
 int? get previousStars;/// The one-time star tip may show on this win's card (Q119): it was
/// never shown, the win is below 3 stars and its stars weren't capped.
/// The card calls `SaveService.markStarTipShown` once it shows it
/// (phase 4 architecture §3.6); a card with no room leaves it for the
/// next one.
 bool get showStarTip;
/// Create a copy of LevelWinOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LevelWinOutcomeCopyWith<LevelWinOutcome> get copyWith => _$LevelWinOutcomeCopyWithImpl<LevelWinOutcome>(this as LevelWinOutcome, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LevelWinOutcome&&(identical(other.bestMoves, bestMoves) || other.bestMoves == bestMoves)&&(identical(other.previousBest, previousBest) || other.previousBest == previousBest)&&(identical(other.chestPaid, chestPaid) || other.chestPaid == chestPaid)&&const DeepCollectionEquality().equals(other.newBadges, newBadges)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.previousStars, previousStars) || other.previousStars == previousStars)&&(identical(other.showStarTip, showStarTip) || other.showStarTip == showStarTip));
}


@override
int get hashCode => Object.hash(runtimeType,bestMoves,previousBest,chestPaid,const DeepCollectionEquality().hash(newBadges),stars,previousStars,showStarTip);

@override
String toString() {
  return 'LevelWinOutcome(bestMoves: $bestMoves, previousBest: $previousBest, chestPaid: $chestPaid, newBadges: $newBadges, stars: $stars, previousStars: $previousStars, showStarTip: $showStarTip)';
}


}

/// @nodoc
abstract mixin class $LevelWinOutcomeCopyWith<$Res>  {
  factory $LevelWinOutcomeCopyWith(LevelWinOutcome value, $Res Function(LevelWinOutcome) _then) = _$LevelWinOutcomeCopyWithImpl;
@useResult
$Res call({
 int? bestMoves, int? previousBest, ChestGrant? chestPaid, List<BadgeId> newBadges, int? stars, int? previousStars, bool showStarTip
});


$ChestGrantCopyWith<$Res>? get chestPaid;

}
/// @nodoc
class _$LevelWinOutcomeCopyWithImpl<$Res>
    implements $LevelWinOutcomeCopyWith<$Res> {
  _$LevelWinOutcomeCopyWithImpl(this._self, this._then);

  final LevelWinOutcome _self;
  final $Res Function(LevelWinOutcome) _then;

/// Create a copy of LevelWinOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bestMoves = freezed,Object? previousBest = freezed,Object? chestPaid = freezed,Object? newBadges = null,Object? stars = freezed,Object? previousStars = freezed,Object? showStarTip = null,}) {
  return _then(_self.copyWith(
bestMoves: freezed == bestMoves ? _self.bestMoves : bestMoves // ignore: cast_nullable_to_non_nullable
as int?,previousBest: freezed == previousBest ? _self.previousBest : previousBest // ignore: cast_nullable_to_non_nullable
as int?,chestPaid: freezed == chestPaid ? _self.chestPaid : chestPaid // ignore: cast_nullable_to_non_nullable
as ChestGrant?,newBadges: null == newBadges ? _self.newBadges : newBadges // ignore: cast_nullable_to_non_nullable
as List<BadgeId>,stars: freezed == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int?,previousStars: freezed == previousStars ? _self.previousStars : previousStars // ignore: cast_nullable_to_non_nullable
as int?,showStarTip: null == showStarTip ? _self.showStarTip : showStarTip // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of LevelWinOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChestGrantCopyWith<$Res>? get chestPaid {
    if (_self.chestPaid == null) {
    return null;
  }

  return $ChestGrantCopyWith<$Res>(_self.chestPaid!, (value) {
    return _then(_self.copyWith(chestPaid: value));
  });
}
}


/// Adds pattern-matching-related methods to [LevelWinOutcome].
extension LevelWinOutcomePatterns on LevelWinOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LevelWinOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LevelWinOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LevelWinOutcome value)  $default,){
final _that = this;
switch (_that) {
case _LevelWinOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LevelWinOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _LevelWinOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? bestMoves,  int? previousBest,  ChestGrant? chestPaid,  List<BadgeId> newBadges,  int? stars,  int? previousStars,  bool showStarTip)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LevelWinOutcome() when $default != null:
return $default(_that.bestMoves,_that.previousBest,_that.chestPaid,_that.newBadges,_that.stars,_that.previousStars,_that.showStarTip);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? bestMoves,  int? previousBest,  ChestGrant? chestPaid,  List<BadgeId> newBadges,  int? stars,  int? previousStars,  bool showStarTip)  $default,) {final _that = this;
switch (_that) {
case _LevelWinOutcome():
return $default(_that.bestMoves,_that.previousBest,_that.chestPaid,_that.newBadges,_that.stars,_that.previousStars,_that.showStarTip);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? bestMoves,  int? previousBest,  ChestGrant? chestPaid,  List<BadgeId> newBadges,  int? stars,  int? previousStars,  bool showStarTip)?  $default,) {final _that = this;
switch (_that) {
case _LevelWinOutcome() when $default != null:
return $default(_that.bestMoves,_that.previousBest,_that.chestPaid,_that.newBadges,_that.stars,_that.previousStars,_that.showStarTip);case _:
  return null;

}
}

}

/// @nodoc


class _LevelWinOutcome implements LevelWinOutcome {
  const _LevelWinOutcome({this.bestMoves, this.previousBest, this.chestPaid, final  List<BadgeId> newBadges = const <BadgeId>[], this.stars, this.previousStars, this.showStarTip = false}): _newBadges = newBadges;
  

/// The level's best moves after this win (so never above its moves);
/// null when the win had no `LevelWinRecord.bestKey`.
@override final  int? bestMoves;
/// The best before this win, or null when it had none (a first win, or
/// no best kept).
@override final  int? previousBest;
/// The milestone chest this win opened and paid, or null (none reached,
/// already opened, or a replay).
@override final  ChestGrant? chestPaid;
/// The badges this win earned, in [BadgeId] order (one toast each).
 final  List<BadgeId> _newBadges;
/// The badges this win earned, in [BadgeId] order (one toast each).
@override@JsonKey() List<BadgeId> get newBadges {
  if (_newBadges is EqualUnmodifiableListView) return _newBadges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_newBadges);
}

/// The level's best stars after this win (so never below this win's),
/// or null when the win had no stars (m7-design P3.4).
@override final  int? stars;
/// The level's best stars before this win; null when it had none (a
/// first win, or a level won before stars that the backfill hasn't
/// reached).
@override final  int? previousStars;
/// The one-time star tip may show on this win's card (Q119): it was
/// never shown, the win is below 3 stars and its stars weren't capped.
/// The card calls `SaveService.markStarTipShown` once it shows it
/// (phase 4 architecture §3.6); a card with no room leaves it for the
/// next one.
@override@JsonKey() final  bool showStarTip;

/// Create a copy of LevelWinOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LevelWinOutcomeCopyWith<_LevelWinOutcome> get copyWith => __$LevelWinOutcomeCopyWithImpl<_LevelWinOutcome>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LevelWinOutcome&&(identical(other.bestMoves, bestMoves) || other.bestMoves == bestMoves)&&(identical(other.previousBest, previousBest) || other.previousBest == previousBest)&&(identical(other.chestPaid, chestPaid) || other.chestPaid == chestPaid)&&const DeepCollectionEquality().equals(other._newBadges, _newBadges)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.previousStars, previousStars) || other.previousStars == previousStars)&&(identical(other.showStarTip, showStarTip) || other.showStarTip == showStarTip));
}


@override
int get hashCode => Object.hash(runtimeType,bestMoves,previousBest,chestPaid,const DeepCollectionEquality().hash(_newBadges),stars,previousStars,showStarTip);

@override
String toString() {
  return 'LevelWinOutcome(bestMoves: $bestMoves, previousBest: $previousBest, chestPaid: $chestPaid, newBadges: $newBadges, stars: $stars, previousStars: $previousStars, showStarTip: $showStarTip)';
}


}

/// @nodoc
abstract mixin class _$LevelWinOutcomeCopyWith<$Res> implements $LevelWinOutcomeCopyWith<$Res> {
  factory _$LevelWinOutcomeCopyWith(_LevelWinOutcome value, $Res Function(_LevelWinOutcome) _then) = __$LevelWinOutcomeCopyWithImpl;
@override @useResult
$Res call({
 int? bestMoves, int? previousBest, ChestGrant? chestPaid, List<BadgeId> newBadges, int? stars, int? previousStars, bool showStarTip
});


@override $ChestGrantCopyWith<$Res>? get chestPaid;

}
/// @nodoc
class __$LevelWinOutcomeCopyWithImpl<$Res>
    implements _$LevelWinOutcomeCopyWith<$Res> {
  __$LevelWinOutcomeCopyWithImpl(this._self, this._then);

  final _LevelWinOutcome _self;
  final $Res Function(_LevelWinOutcome) _then;

/// Create a copy of LevelWinOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bestMoves = freezed,Object? previousBest = freezed,Object? chestPaid = freezed,Object? newBadges = null,Object? stars = freezed,Object? previousStars = freezed,Object? showStarTip = null,}) {
  return _then(_LevelWinOutcome(
bestMoves: freezed == bestMoves ? _self.bestMoves : bestMoves // ignore: cast_nullable_to_non_nullable
as int?,previousBest: freezed == previousBest ? _self.previousBest : previousBest // ignore: cast_nullable_to_non_nullable
as int?,chestPaid: freezed == chestPaid ? _self.chestPaid : chestPaid // ignore: cast_nullable_to_non_nullable
as ChestGrant?,newBadges: null == newBadges ? _self._newBadges : newBadges // ignore: cast_nullable_to_non_nullable
as List<BadgeId>,stars: freezed == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int?,previousStars: freezed == previousStars ? _self.previousStars : previousStars // ignore: cast_nullable_to_non_nullable
as int?,showStarTip: null == showStarTip ? _self.showStarTip : showStarTip // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of LevelWinOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChestGrantCopyWith<$Res>? get chestPaid {
    if (_self.chestPaid == null) {
    return null;
  }

  return $ChestGrantCopyWith<$Res>(_self.chestPaid!, (value) {
    return _then(_self.copyWith(chestPaid: value));
  });
}
}

/// @nodoc
mixin _$ChestGrant {

 ChestSource get source;/// The campaign order ([ChestSource.campaign]) or the bonus number
/// ([ChestSource.bonus]) whose win opens it.
 int get number;/// `chest_coins` (Remote Config, default 100).
 int get coins;/// `chest_hints` (Remote Config, default 1): hint boosters.
 int get hints;
/// Create a copy of ChestGrant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChestGrantCopyWith<ChestGrant> get copyWith => _$ChestGrantCopyWithImpl<ChestGrant>(this as ChestGrant, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChestGrant&&(identical(other.source, source) || other.source == source)&&(identical(other.number, number) || other.number == number)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.hints, hints) || other.hints == hints));
}


@override
int get hashCode => Object.hash(runtimeType,source,number,coins,hints);

@override
String toString() {
  return 'ChestGrant(source: $source, number: $number, coins: $coins, hints: $hints)';
}


}

/// @nodoc
abstract mixin class $ChestGrantCopyWith<$Res>  {
  factory $ChestGrantCopyWith(ChestGrant value, $Res Function(ChestGrant) _then) = _$ChestGrantCopyWithImpl;
@useResult
$Res call({
 ChestSource source, int number, int coins, int hints
});




}
/// @nodoc
class _$ChestGrantCopyWithImpl<$Res>
    implements $ChestGrantCopyWith<$Res> {
  _$ChestGrantCopyWithImpl(this._self, this._then);

  final ChestGrant _self;
  final $Res Function(ChestGrant) _then;

/// Create a copy of ChestGrant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? number = null,Object? coins = null,Object? hints = null,}) {
  return _then(_self.copyWith(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ChestSource,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,hints: null == hints ? _self.hints : hints // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChestGrant].
extension ChestGrantPatterns on ChestGrant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChestGrant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChestGrant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChestGrant value)  $default,){
final _that = this;
switch (_that) {
case _ChestGrant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChestGrant value)?  $default,){
final _that = this;
switch (_that) {
case _ChestGrant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChestSource source,  int number,  int coins,  int hints)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChestGrant() when $default != null:
return $default(_that.source,_that.number,_that.coins,_that.hints);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChestSource source,  int number,  int coins,  int hints)  $default,) {final _that = this;
switch (_that) {
case _ChestGrant():
return $default(_that.source,_that.number,_that.coins,_that.hints);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChestSource source,  int number,  int coins,  int hints)?  $default,) {final _that = this;
switch (_that) {
case _ChestGrant() when $default != null:
return $default(_that.source,_that.number,_that.coins,_that.hints);case _:
  return null;

}
}

}

/// @nodoc


class _ChestGrant implements ChestGrant {
  const _ChestGrant({required this.source, required this.number, required this.coins, required this.hints});
  

@override final  ChestSource source;
/// The campaign order ([ChestSource.campaign]) or the bonus number
/// ([ChestSource.bonus]) whose win opens it.
@override final  int number;
/// `chest_coins` (Remote Config, default 100).
@override final  int coins;
/// `chest_hints` (Remote Config, default 1): hint boosters.
@override final  int hints;

/// Create a copy of ChestGrant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChestGrantCopyWith<_ChestGrant> get copyWith => __$ChestGrantCopyWithImpl<_ChestGrant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChestGrant&&(identical(other.source, source) || other.source == source)&&(identical(other.number, number) || other.number == number)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.hints, hints) || other.hints == hints));
}


@override
int get hashCode => Object.hash(runtimeType,source,number,coins,hints);

@override
String toString() {
  return 'ChestGrant(source: $source, number: $number, coins: $coins, hints: $hints)';
}


}

/// @nodoc
abstract mixin class _$ChestGrantCopyWith<$Res> implements $ChestGrantCopyWith<$Res> {
  factory _$ChestGrantCopyWith(_ChestGrant value, $Res Function(_ChestGrant) _then) = __$ChestGrantCopyWithImpl;
@override @useResult
$Res call({
 ChestSource source, int number, int coins, int hints
});




}
/// @nodoc
class __$ChestGrantCopyWithImpl<$Res>
    implements _$ChestGrantCopyWith<$Res> {
  __$ChestGrantCopyWithImpl(this._self, this._then);

  final _ChestGrant _self;
  final $Res Function(_ChestGrant) _then;

/// Create a copy of ChestGrant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? number = null,Object? coins = null,Object? hints = null,}) {
  return _then(_ChestGrant(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ChestSource,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,hints: null == hints ? _self.hints : hints // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SaveRecords {

/// Families completed in won boards.
 int get families;/// Dolls nested in won boards: the dolls that end inside another.
 int get dolls;/// Daily puzzles solved, one per date.
 int get dailies;/// The longest unbroken daily run (`DailyProgress.run`).
 int get longestRun;/// `BadgeId.id`s earned, in the order earned. Unknown ids (a newer
/// app's) are kept and written back, never shown.
 List<String> get badges;
/// Create a copy of SaveRecords
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveRecordsCopyWith<SaveRecords> get copyWith => _$SaveRecordsCopyWithImpl<SaveRecords>(this as SaveRecords, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveRecords&&(identical(other.families, families) || other.families == families)&&(identical(other.dolls, dolls) || other.dolls == dolls)&&(identical(other.dailies, dailies) || other.dailies == dailies)&&(identical(other.longestRun, longestRun) || other.longestRun == longestRun)&&const DeepCollectionEquality().equals(other.badges, badges));
}


@override
int get hashCode => Object.hash(runtimeType,families,dolls,dailies,longestRun,const DeepCollectionEquality().hash(badges));

@override
String toString() {
  return 'SaveRecords(families: $families, dolls: $dolls, dailies: $dailies, longestRun: $longestRun, badges: $badges)';
}


}

/// @nodoc
abstract mixin class $SaveRecordsCopyWith<$Res>  {
  factory $SaveRecordsCopyWith(SaveRecords value, $Res Function(SaveRecords) _then) = _$SaveRecordsCopyWithImpl;
@useResult
$Res call({
 int families, int dolls, int dailies, int longestRun, List<String> badges
});




}
/// @nodoc
class _$SaveRecordsCopyWithImpl<$Res>
    implements $SaveRecordsCopyWith<$Res> {
  _$SaveRecordsCopyWithImpl(this._self, this._then);

  final SaveRecords _self;
  final $Res Function(SaveRecords) _then;

/// Create a copy of SaveRecords
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? families = null,Object? dolls = null,Object? dailies = null,Object? longestRun = null,Object? badges = null,}) {
  return _then(_self.copyWith(
families: null == families ? _self.families : families // ignore: cast_nullable_to_non_nullable
as int,dolls: null == dolls ? _self.dolls : dolls // ignore: cast_nullable_to_non_nullable
as int,dailies: null == dailies ? _self.dailies : dailies // ignore: cast_nullable_to_non_nullable
as int,longestRun: null == longestRun ? _self.longestRun : longestRun // ignore: cast_nullable_to_non_nullable
as int,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SaveRecords].
extension SaveRecordsPatterns on SaveRecords {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaveRecords value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaveRecords() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaveRecords value)  $default,){
final _that = this;
switch (_that) {
case _SaveRecords():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaveRecords value)?  $default,){
final _that = this;
switch (_that) {
case _SaveRecords() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int families,  int dolls,  int dailies,  int longestRun,  List<String> badges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaveRecords() when $default != null:
return $default(_that.families,_that.dolls,_that.dailies,_that.longestRun,_that.badges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int families,  int dolls,  int dailies,  int longestRun,  List<String> badges)  $default,) {final _that = this;
switch (_that) {
case _SaveRecords():
return $default(_that.families,_that.dolls,_that.dailies,_that.longestRun,_that.badges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int families,  int dolls,  int dailies,  int longestRun,  List<String> badges)?  $default,) {final _that = this;
switch (_that) {
case _SaveRecords() when $default != null:
return $default(_that.families,_that.dolls,_that.dailies,_that.longestRun,_that.badges);case _:
  return null;

}
}

}

/// @nodoc


class _SaveRecords extends SaveRecords {
  const _SaveRecords({this.families = 0, this.dolls = 0, this.dailies = 0, this.longestRun = 0, final  List<String> badges = const <String>[]}): _badges = badges,super._();
  

/// Families completed in won boards.
@override@JsonKey() final  int families;
/// Dolls nested in won boards: the dolls that end inside another.
@override@JsonKey() final  int dolls;
/// Daily puzzles solved, one per date.
@override@JsonKey() final  int dailies;
/// The longest unbroken daily run (`DailyProgress.run`).
@override@JsonKey() final  int longestRun;
/// `BadgeId.id`s earned, in the order earned. Unknown ids (a newer
/// app's) are kept and written back, never shown.
 final  List<String> _badges;
/// `BadgeId.id`s earned, in the order earned. Unknown ids (a newer
/// app's) are kept and written back, never shown.
@override@JsonKey() List<String> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}


/// Create a copy of SaveRecords
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaveRecordsCopyWith<_SaveRecords> get copyWith => __$SaveRecordsCopyWithImpl<_SaveRecords>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveRecords&&(identical(other.families, families) || other.families == families)&&(identical(other.dolls, dolls) || other.dolls == dolls)&&(identical(other.dailies, dailies) || other.dailies == dailies)&&(identical(other.longestRun, longestRun) || other.longestRun == longestRun)&&const DeepCollectionEquality().equals(other._badges, _badges));
}


@override
int get hashCode => Object.hash(runtimeType,families,dolls,dailies,longestRun,const DeepCollectionEquality().hash(_badges));

@override
String toString() {
  return 'SaveRecords(families: $families, dolls: $dolls, dailies: $dailies, longestRun: $longestRun, badges: $badges)';
}


}

/// @nodoc
abstract mixin class _$SaveRecordsCopyWith<$Res> implements $SaveRecordsCopyWith<$Res> {
  factory _$SaveRecordsCopyWith(_SaveRecords value, $Res Function(_SaveRecords) _then) = __$SaveRecordsCopyWithImpl;
@override @useResult
$Res call({
 int families, int dolls, int dailies, int longestRun, List<String> badges
});




}
/// @nodoc
class __$SaveRecordsCopyWithImpl<$Res>
    implements _$SaveRecordsCopyWith<$Res> {
  __$SaveRecordsCopyWithImpl(this._self, this._then);

  final _SaveRecords _self;
  final $Res Function(_SaveRecords) _then;

/// Create a copy of SaveRecords
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? families = null,Object? dolls = null,Object? dailies = null,Object? longestRun = null,Object? badges = null,}) {
  return _then(_SaveRecords(
families: null == families ? _self.families : families // ignore: cast_nullable_to_non_nullable
as int,dolls: null == dolls ? _self.dolls : dolls // ignore: cast_nullable_to_non_nullable
as int,dailies: null == dailies ? _self.dailies : dailies // ignore: cast_nullable_to_non_nullable
as int,longestRun: null == longestRun ? _self.longestRun : longestRun // ignore: cast_nullable_to_non_nullable
as int,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$ChestProgress {

/// Campaign orders whose chest was opened (10, 30 …), ascending.
 List<int> get opened;/// Bonus numbers whose chest was opened (10, 20 …), ascending. Kept
/// apart from [opened] so a chapter published later (M4) never meets
/// a bonus number (an M7 addition to spec-prop §13.3, m7-design §3).
 List<int> get bonusOpened;
/// Create a copy of ChestProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChestProgressCopyWith<ChestProgress> get copyWith => _$ChestProgressCopyWithImpl<ChestProgress>(this as ChestProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChestProgress&&const DeepCollectionEquality().equals(other.opened, opened)&&const DeepCollectionEquality().equals(other.bonusOpened, bonusOpened));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(opened),const DeepCollectionEquality().hash(bonusOpened));

@override
String toString() {
  return 'ChestProgress(opened: $opened, bonusOpened: $bonusOpened)';
}


}

/// @nodoc
abstract mixin class $ChestProgressCopyWith<$Res>  {
  factory $ChestProgressCopyWith(ChestProgress value, $Res Function(ChestProgress) _then) = _$ChestProgressCopyWithImpl;
@useResult
$Res call({
 List<int> opened, List<int> bonusOpened
});




}
/// @nodoc
class _$ChestProgressCopyWithImpl<$Res>
    implements $ChestProgressCopyWith<$Res> {
  _$ChestProgressCopyWithImpl(this._self, this._then);

  final ChestProgress _self;
  final $Res Function(ChestProgress) _then;

/// Create a copy of ChestProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? opened = null,Object? bonusOpened = null,}) {
  return _then(_self.copyWith(
opened: null == opened ? _self.opened : opened // ignore: cast_nullable_to_non_nullable
as List<int>,bonusOpened: null == bonusOpened ? _self.bonusOpened : bonusOpened // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChestProgress].
extension ChestProgressPatterns on ChestProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChestProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChestProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChestProgress value)  $default,){
final _that = this;
switch (_that) {
case _ChestProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChestProgress value)?  $default,){
final _that = this;
switch (_that) {
case _ChestProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int> opened,  List<int> bonusOpened)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChestProgress() when $default != null:
return $default(_that.opened,_that.bonusOpened);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int> opened,  List<int> bonusOpened)  $default,) {final _that = this;
switch (_that) {
case _ChestProgress():
return $default(_that.opened,_that.bonusOpened);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int> opened,  List<int> bonusOpened)?  $default,) {final _that = this;
switch (_that) {
case _ChestProgress() when $default != null:
return $default(_that.opened,_that.bonusOpened);case _:
  return null;

}
}

}

/// @nodoc


class _ChestProgress extends ChestProgress {
  const _ChestProgress({final  List<int> opened = const <int>[], final  List<int> bonusOpened = const <int>[]}): _opened = opened,_bonusOpened = bonusOpened,super._();
  

/// Campaign orders whose chest was opened (10, 30 …), ascending.
 final  List<int> _opened;
/// Campaign orders whose chest was opened (10, 30 …), ascending.
@override@JsonKey() List<int> get opened {
  if (_opened is EqualUnmodifiableListView) return _opened;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_opened);
}

/// Bonus numbers whose chest was opened (10, 20 …), ascending. Kept
/// apart from [opened] so a chapter published later (M4) never meets
/// a bonus number (an M7 addition to spec-prop §13.3, m7-design §3).
 final  List<int> _bonusOpened;
/// Bonus numbers whose chest was opened (10, 20 …), ascending. Kept
/// apart from [opened] so a chapter published later (M4) never meets
/// a bonus number (an M7 addition to spec-prop §13.3, m7-design §3).
@override@JsonKey() List<int> get bonusOpened {
  if (_bonusOpened is EqualUnmodifiableListView) return _bonusOpened;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bonusOpened);
}


/// Create a copy of ChestProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChestProgressCopyWith<_ChestProgress> get copyWith => __$ChestProgressCopyWithImpl<_ChestProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChestProgress&&const DeepCollectionEquality().equals(other._opened, _opened)&&const DeepCollectionEquality().equals(other._bonusOpened, _bonusOpened));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_opened),const DeepCollectionEquality().hash(_bonusOpened));

@override
String toString() {
  return 'ChestProgress(opened: $opened, bonusOpened: $bonusOpened)';
}


}

/// @nodoc
abstract mixin class _$ChestProgressCopyWith<$Res> implements $ChestProgressCopyWith<$Res> {
  factory _$ChestProgressCopyWith(_ChestProgress value, $Res Function(_ChestProgress) _then) = __$ChestProgressCopyWithImpl;
@override @useResult
$Res call({
 List<int> opened, List<int> bonusOpened
});




}
/// @nodoc
class __$ChestProgressCopyWithImpl<$Res>
    implements _$ChestProgressCopyWith<$Res> {
  __$ChestProgressCopyWithImpl(this._self, this._then);

  final _ChestProgress _self;
  final $Res Function(_ChestProgress) _then;

/// Create a copy of ChestProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? opened = null,Object? bonusOpened = null,}) {
  return _then(_ChestProgress(
opened: null == opened ? _self._opened : opened // ignore: cast_nullable_to_non_nullable
as List<int>,bonusOpened: null == bonusOpened ? _self._bonusOpened : bonusOpened // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

/// @nodoc
mixin _$RaceProgress {

 List<RivalProgress> get rivals;
/// Create a copy of RaceProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RaceProgressCopyWith<RaceProgress> get copyWith => _$RaceProgressCopyWithImpl<RaceProgress>(this as RaceProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RaceProgress&&const DeepCollectionEquality().equals(other.rivals, rivals));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rivals));

@override
String toString() {
  return 'RaceProgress(rivals: $rivals)';
}


}

/// @nodoc
abstract mixin class $RaceProgressCopyWith<$Res>  {
  factory $RaceProgressCopyWith(RaceProgress value, $Res Function(RaceProgress) _then) = _$RaceProgressCopyWithImpl;
@useResult
$Res call({
 List<RivalProgress> rivals
});




}
/// @nodoc
class _$RaceProgressCopyWithImpl<$Res>
    implements $RaceProgressCopyWith<$Res> {
  _$RaceProgressCopyWithImpl(this._self, this._then);

  final RaceProgress _self;
  final $Res Function(RaceProgress) _then;

/// Create a copy of RaceProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rivals = null,}) {
  return _then(_self.copyWith(
rivals: null == rivals ? _self.rivals : rivals // ignore: cast_nullable_to_non_nullable
as List<RivalProgress>,
  ));
}

}


/// Adds pattern-matching-related methods to [RaceProgress].
extension RaceProgressPatterns on RaceProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RaceProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RaceProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RaceProgress value)  $default,){
final _that = this;
switch (_that) {
case _RaceProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RaceProgress value)?  $default,){
final _that = this;
switch (_that) {
case _RaceProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RivalProgress> rivals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RaceProgress() when $default != null:
return $default(_that.rivals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RivalProgress> rivals)  $default,) {final _that = this;
switch (_that) {
case _RaceProgress():
return $default(_that.rivals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RivalProgress> rivals)?  $default,) {final _that = this;
switch (_that) {
case _RaceProgress() when $default != null:
return $default(_that.rivals);case _:
  return null;

}
}

}

/// @nodoc


class _RaceProgress extends RaceProgress {
  const _RaceProgress({final  List<RivalProgress> rivals = RaceProgress.defaultRivals}): _rivals = rivals,super._();
  

 final  List<RivalProgress> _rivals;
@override@JsonKey() List<RivalProgress> get rivals {
  if (_rivals is EqualUnmodifiableListView) return _rivals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rivals);
}


/// Create a copy of RaceProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RaceProgressCopyWith<_RaceProgress> get copyWith => __$RaceProgressCopyWithImpl<_RaceProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RaceProgress&&const DeepCollectionEquality().equals(other._rivals, _rivals));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rivals));

@override
String toString() {
  return 'RaceProgress(rivals: $rivals)';
}


}

/// @nodoc
abstract mixin class _$RaceProgressCopyWith<$Res> implements $RaceProgressCopyWith<$Res> {
  factory _$RaceProgressCopyWith(_RaceProgress value, $Res Function(_RaceProgress) _then) = __$RaceProgressCopyWithImpl;
@override @useResult
$Res call({
 List<RivalProgress> rivals
});




}
/// @nodoc
class __$RaceProgressCopyWithImpl<$Res>
    implements _$RaceProgressCopyWith<$Res> {
  __$RaceProgressCopyWithImpl(this._self, this._then);

  final _RaceProgress _self;
  final $Res Function(_RaceProgress) _then;

/// Create a copy of RaceProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rivals = null,}) {
  return _then(_RaceProgress(
rivals: null == rivals ? _self._rivals : rivals // ignore: cast_nullable_to_non_nullable
as List<RivalProgress>,
  ));
}


}

/// @nodoc
mixin _$RivalProgress {

/// Selectable: rival 1 always, the next after the first win against
/// the one before (vs-computer rule 2).
 bool get unlocked;/// Races won against this rival.
 int get wins;/// The number of this rival's latest race (from 1; 0 = none yet).
/// Selecting the rival or New race starts `raceNo + 1`; Rematch keeps
/// it (plan-m7 decision 14; `SaveService.beginRace`, m7-design P2.7).
 int get raceNo;
/// Create a copy of RivalProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RivalProgressCopyWith<RivalProgress> get copyWith => _$RivalProgressCopyWithImpl<RivalProgress>(this as RivalProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RivalProgress&&(identical(other.unlocked, unlocked) || other.unlocked == unlocked)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.raceNo, raceNo) || other.raceNo == raceNo));
}


@override
int get hashCode => Object.hash(runtimeType,unlocked,wins,raceNo);

@override
String toString() {
  return 'RivalProgress(unlocked: $unlocked, wins: $wins, raceNo: $raceNo)';
}


}

/// @nodoc
abstract mixin class $RivalProgressCopyWith<$Res>  {
  factory $RivalProgressCopyWith(RivalProgress value, $Res Function(RivalProgress) _then) = _$RivalProgressCopyWithImpl;
@useResult
$Res call({
 bool unlocked, int wins, int raceNo
});




}
/// @nodoc
class _$RivalProgressCopyWithImpl<$Res>
    implements $RivalProgressCopyWith<$Res> {
  _$RivalProgressCopyWithImpl(this._self, this._then);

  final RivalProgress _self;
  final $Res Function(RivalProgress) _then;

/// Create a copy of RivalProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unlocked = null,Object? wins = null,Object? raceNo = null,}) {
  return _then(_self.copyWith(
unlocked: null == unlocked ? _self.unlocked : unlocked // ignore: cast_nullable_to_non_nullable
as bool,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,raceNo: null == raceNo ? _self.raceNo : raceNo // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RivalProgress].
extension RivalProgressPatterns on RivalProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RivalProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RivalProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RivalProgress value)  $default,){
final _that = this;
switch (_that) {
case _RivalProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RivalProgress value)?  $default,){
final _that = this;
switch (_that) {
case _RivalProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool unlocked,  int wins,  int raceNo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RivalProgress() when $default != null:
return $default(_that.unlocked,_that.wins,_that.raceNo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool unlocked,  int wins,  int raceNo)  $default,) {final _that = this;
switch (_that) {
case _RivalProgress():
return $default(_that.unlocked,_that.wins,_that.raceNo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool unlocked,  int wins,  int raceNo)?  $default,) {final _that = this;
switch (_that) {
case _RivalProgress() when $default != null:
return $default(_that.unlocked,_that.wins,_that.raceNo);case _:
  return null;

}
}

}

/// @nodoc


class _RivalProgress implements RivalProgress {
  const _RivalProgress({this.unlocked = false, this.wins = 0, this.raceNo = 0});
  

/// Selectable: rival 1 always, the next after the first win against
/// the one before (vs-computer rule 2).
@override@JsonKey() final  bool unlocked;
/// Races won against this rival.
@override@JsonKey() final  int wins;
/// The number of this rival's latest race (from 1; 0 = none yet).
/// Selecting the rival or New race starts `raceNo + 1`; Rematch keeps
/// it (plan-m7 decision 14; `SaveService.beginRace`, m7-design P2.7).
@override@JsonKey() final  int raceNo;

/// Create a copy of RivalProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RivalProgressCopyWith<_RivalProgress> get copyWith => __$RivalProgressCopyWithImpl<_RivalProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RivalProgress&&(identical(other.unlocked, unlocked) || other.unlocked == unlocked)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.raceNo, raceNo) || other.raceNo == raceNo));
}


@override
int get hashCode => Object.hash(runtimeType,unlocked,wins,raceNo);

@override
String toString() {
  return 'RivalProgress(unlocked: $unlocked, wins: $wins, raceNo: $raceNo)';
}


}

/// @nodoc
abstract mixin class _$RivalProgressCopyWith<$Res> implements $RivalProgressCopyWith<$Res> {
  factory _$RivalProgressCopyWith(_RivalProgress value, $Res Function(_RivalProgress) _then) = __$RivalProgressCopyWithImpl;
@override @useResult
$Res call({
 bool unlocked, int wins, int raceNo
});




}
/// @nodoc
class __$RivalProgressCopyWithImpl<$Res>
    implements _$RivalProgressCopyWith<$Res> {
  __$RivalProgressCopyWithImpl(this._self, this._then);

  final _RivalProgress _self;
  final $Res Function(_RivalProgress) _then;

/// Create a copy of RivalProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unlocked = null,Object? wins = null,Object? raceNo = null,}) {
  return _then(_RivalProgress(
unlocked: null == unlocked ? _self.unlocked : unlocked // ignore: cast_nullable_to_non_nullable
as bool,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,raceNo: null == raceNo ? _self.raceNo : raceNo // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$RaceWinRecord {

/// The rival beaten, 1–3.
 int get rival;/// The race's number (`PlayRequest.race`'s raceNo, ≥ 1), already
/// stored by `SaveService.beginRace` when the race was chosen.
 int get raceNo;/// `race_reward_n` (`RaceRules.rewardCoins`, the resolver's
/// `PlayEntry.rewardCoins`). A Rematch win pays again (default, an
/// owner question, m7-design P2.14).
 int get rewardCoins;/// The player's `GameState.moveCount` at the win (`stats.moves`).
 int get moves;/// The families the won board completed (`RecordRules.familiesIn`),
/// added to `records.families`: races count in the records (m7-design
/// §12, Q91).
 int get families;/// The dolls the won board nested (`RecordRules.dollsNestedIn`), added
/// to `records.dolls`.
 int get dolls;/// Badges the won board itself earns (`BadgeRules.forWonLevel`).
 List<BadgeId> get boardBadges;
/// Create a copy of RaceWinRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RaceWinRecordCopyWith<RaceWinRecord> get copyWith => _$RaceWinRecordCopyWithImpl<RaceWinRecord>(this as RaceWinRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RaceWinRecord&&(identical(other.rival, rival) || other.rival == rival)&&(identical(other.raceNo, raceNo) || other.raceNo == raceNo)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.families, families) || other.families == families)&&(identical(other.dolls, dolls) || other.dolls == dolls)&&const DeepCollectionEquality().equals(other.boardBadges, boardBadges));
}


@override
int get hashCode => Object.hash(runtimeType,rival,raceNo,rewardCoins,moves,families,dolls,const DeepCollectionEquality().hash(boardBadges));

@override
String toString() {
  return 'RaceWinRecord(rival: $rival, raceNo: $raceNo, rewardCoins: $rewardCoins, moves: $moves, families: $families, dolls: $dolls, boardBadges: $boardBadges)';
}


}

/// @nodoc
abstract mixin class $RaceWinRecordCopyWith<$Res>  {
  factory $RaceWinRecordCopyWith(RaceWinRecord value, $Res Function(RaceWinRecord) _then) = _$RaceWinRecordCopyWithImpl;
@useResult
$Res call({
 int rival, int raceNo, int rewardCoins, int moves, int families, int dolls, List<BadgeId> boardBadges
});




}
/// @nodoc
class _$RaceWinRecordCopyWithImpl<$Res>
    implements $RaceWinRecordCopyWith<$Res> {
  _$RaceWinRecordCopyWithImpl(this._self, this._then);

  final RaceWinRecord _self;
  final $Res Function(RaceWinRecord) _then;

/// Create a copy of RaceWinRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rival = null,Object? raceNo = null,Object? rewardCoins = null,Object? moves = null,Object? families = null,Object? dolls = null,Object? boardBadges = null,}) {
  return _then(_self.copyWith(
rival: null == rival ? _self.rival : rival // ignore: cast_nullable_to_non_nullable
as int,raceNo: null == raceNo ? _self.raceNo : raceNo // ignore: cast_nullable_to_non_nullable
as int,rewardCoins: null == rewardCoins ? _self.rewardCoins : rewardCoins // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,families: null == families ? _self.families : families // ignore: cast_nullable_to_non_nullable
as int,dolls: null == dolls ? _self.dolls : dolls // ignore: cast_nullable_to_non_nullable
as int,boardBadges: null == boardBadges ? _self.boardBadges : boardBadges // ignore: cast_nullable_to_non_nullable
as List<BadgeId>,
  ));
}

}


/// Adds pattern-matching-related methods to [RaceWinRecord].
extension RaceWinRecordPatterns on RaceWinRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RaceWinRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RaceWinRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RaceWinRecord value)  $default,){
final _that = this;
switch (_that) {
case _RaceWinRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RaceWinRecord value)?  $default,){
final _that = this;
switch (_that) {
case _RaceWinRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rival,  int raceNo,  int rewardCoins,  int moves,  int families,  int dolls,  List<BadgeId> boardBadges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RaceWinRecord() when $default != null:
return $default(_that.rival,_that.raceNo,_that.rewardCoins,_that.moves,_that.families,_that.dolls,_that.boardBadges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rival,  int raceNo,  int rewardCoins,  int moves,  int families,  int dolls,  List<BadgeId> boardBadges)  $default,) {final _that = this;
switch (_that) {
case _RaceWinRecord():
return $default(_that.rival,_that.raceNo,_that.rewardCoins,_that.moves,_that.families,_that.dolls,_that.boardBadges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rival,  int raceNo,  int rewardCoins,  int moves,  int families,  int dolls,  List<BadgeId> boardBadges)?  $default,) {final _that = this;
switch (_that) {
case _RaceWinRecord() when $default != null:
return $default(_that.rival,_that.raceNo,_that.rewardCoins,_that.moves,_that.families,_that.dolls,_that.boardBadges);case _:
  return null;

}
}

}

/// @nodoc


class _RaceWinRecord implements RaceWinRecord {
  const _RaceWinRecord({required this.rival, required this.raceNo, required this.rewardCoins, this.moves = 0, this.families = 0, this.dolls = 0, final  List<BadgeId> boardBadges = const <BadgeId>[]}): _boardBadges = boardBadges;
  

/// The rival beaten, 1–3.
@override final  int rival;
/// The race's number (`PlayRequest.race`'s raceNo, ≥ 1), already
/// stored by `SaveService.beginRace` when the race was chosen.
@override final  int raceNo;
/// `race_reward_n` (`RaceRules.rewardCoins`, the resolver's
/// `PlayEntry.rewardCoins`). A Rematch win pays again (default, an
/// owner question, m7-design P2.14).
@override final  int rewardCoins;
/// The player's `GameState.moveCount` at the win (`stats.moves`).
@override@JsonKey() final  int moves;
/// The families the won board completed (`RecordRules.familiesIn`),
/// added to `records.families`: races count in the records (m7-design
/// §12, Q91).
@override@JsonKey() final  int families;
/// The dolls the won board nested (`RecordRules.dollsNestedIn`), added
/// to `records.dolls`.
@override@JsonKey() final  int dolls;
/// Badges the won board itself earns (`BadgeRules.forWonLevel`).
 final  List<BadgeId> _boardBadges;
/// Badges the won board itself earns (`BadgeRules.forWonLevel`).
@override@JsonKey() List<BadgeId> get boardBadges {
  if (_boardBadges is EqualUnmodifiableListView) return _boardBadges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_boardBadges);
}


/// Create a copy of RaceWinRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RaceWinRecordCopyWith<_RaceWinRecord> get copyWith => __$RaceWinRecordCopyWithImpl<_RaceWinRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RaceWinRecord&&(identical(other.rival, rival) || other.rival == rival)&&(identical(other.raceNo, raceNo) || other.raceNo == raceNo)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.families, families) || other.families == families)&&(identical(other.dolls, dolls) || other.dolls == dolls)&&const DeepCollectionEquality().equals(other._boardBadges, _boardBadges));
}


@override
int get hashCode => Object.hash(runtimeType,rival,raceNo,rewardCoins,moves,families,dolls,const DeepCollectionEquality().hash(_boardBadges));

@override
String toString() {
  return 'RaceWinRecord(rival: $rival, raceNo: $raceNo, rewardCoins: $rewardCoins, moves: $moves, families: $families, dolls: $dolls, boardBadges: $boardBadges)';
}


}

/// @nodoc
abstract mixin class _$RaceWinRecordCopyWith<$Res> implements $RaceWinRecordCopyWith<$Res> {
  factory _$RaceWinRecordCopyWith(_RaceWinRecord value, $Res Function(_RaceWinRecord) _then) = __$RaceWinRecordCopyWithImpl;
@override @useResult
$Res call({
 int rival, int raceNo, int rewardCoins, int moves, int families, int dolls, List<BadgeId> boardBadges
});




}
/// @nodoc
class __$RaceWinRecordCopyWithImpl<$Res>
    implements _$RaceWinRecordCopyWith<$Res> {
  __$RaceWinRecordCopyWithImpl(this._self, this._then);

  final _RaceWinRecord _self;
  final $Res Function(_RaceWinRecord) _then;

/// Create a copy of RaceWinRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rival = null,Object? raceNo = null,Object? rewardCoins = null,Object? moves = null,Object? families = null,Object? dolls = null,Object? boardBadges = null,}) {
  return _then(_RaceWinRecord(
rival: null == rival ? _self.rival : rival // ignore: cast_nullable_to_non_nullable
as int,raceNo: null == raceNo ? _self.raceNo : raceNo // ignore: cast_nullable_to_non_nullable
as int,rewardCoins: null == rewardCoins ? _self.rewardCoins : rewardCoins // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,families: null == families ? _self.families : families // ignore: cast_nullable_to_non_nullable
as int,dolls: null == dolls ? _self.dolls : dolls // ignore: cast_nullable_to_non_nullable
as int,boardBadges: null == boardBadges ? _self._boardBadges : boardBadges // ignore: cast_nullable_to_non_nullable
as List<BadgeId>,
  ));
}


}

/// @nodoc
mixin _$RaceWinOutcome {

/// The coins the win paid (`max(0, rewardCoins)`).
 int get coins;/// The rival this win unlocked (2 or 3), or null: rival 3 unlocks
/// nothing, and a rival already open isn't unlocked again.
 int? get unlockedRival;/// The races won against this rival after this win.
 int get wins;/// The badges this win earned, in [BadgeId] order (`first_race`,
/// `all_rivals` and the board's own; one toast each).
 List<BadgeId> get newBadges;
/// Create a copy of RaceWinOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RaceWinOutcomeCopyWith<RaceWinOutcome> get copyWith => _$RaceWinOutcomeCopyWithImpl<RaceWinOutcome>(this as RaceWinOutcome, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RaceWinOutcome&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.unlockedRival, unlockedRival) || other.unlockedRival == unlockedRival)&&(identical(other.wins, wins) || other.wins == wins)&&const DeepCollectionEquality().equals(other.newBadges, newBadges));
}


@override
int get hashCode => Object.hash(runtimeType,coins,unlockedRival,wins,const DeepCollectionEquality().hash(newBadges));

@override
String toString() {
  return 'RaceWinOutcome(coins: $coins, unlockedRival: $unlockedRival, wins: $wins, newBadges: $newBadges)';
}


}

/// @nodoc
abstract mixin class $RaceWinOutcomeCopyWith<$Res>  {
  factory $RaceWinOutcomeCopyWith(RaceWinOutcome value, $Res Function(RaceWinOutcome) _then) = _$RaceWinOutcomeCopyWithImpl;
@useResult
$Res call({
 int coins, int? unlockedRival, int wins, List<BadgeId> newBadges
});




}
/// @nodoc
class _$RaceWinOutcomeCopyWithImpl<$Res>
    implements $RaceWinOutcomeCopyWith<$Res> {
  _$RaceWinOutcomeCopyWithImpl(this._self, this._then);

  final RaceWinOutcome _self;
  final $Res Function(RaceWinOutcome) _then;

/// Create a copy of RaceWinOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coins = null,Object? unlockedRival = freezed,Object? wins = null,Object? newBadges = null,}) {
  return _then(_self.copyWith(
coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,unlockedRival: freezed == unlockedRival ? _self.unlockedRival : unlockedRival // ignore: cast_nullable_to_non_nullable
as int?,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,newBadges: null == newBadges ? _self.newBadges : newBadges // ignore: cast_nullable_to_non_nullable
as List<BadgeId>,
  ));
}

}


/// Adds pattern-matching-related methods to [RaceWinOutcome].
extension RaceWinOutcomePatterns on RaceWinOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RaceWinOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RaceWinOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RaceWinOutcome value)  $default,){
final _that = this;
switch (_that) {
case _RaceWinOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RaceWinOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _RaceWinOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int coins,  int? unlockedRival,  int wins,  List<BadgeId> newBadges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RaceWinOutcome() when $default != null:
return $default(_that.coins,_that.unlockedRival,_that.wins,_that.newBadges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int coins,  int? unlockedRival,  int wins,  List<BadgeId> newBadges)  $default,) {final _that = this;
switch (_that) {
case _RaceWinOutcome():
return $default(_that.coins,_that.unlockedRival,_that.wins,_that.newBadges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int coins,  int? unlockedRival,  int wins,  List<BadgeId> newBadges)?  $default,) {final _that = this;
switch (_that) {
case _RaceWinOutcome() when $default != null:
return $default(_that.coins,_that.unlockedRival,_that.wins,_that.newBadges);case _:
  return null;

}
}

}

/// @nodoc


class _RaceWinOutcome implements RaceWinOutcome {
  const _RaceWinOutcome({this.coins = 0, this.unlockedRival, this.wins = 0, final  List<BadgeId> newBadges = const <BadgeId>[]}): _newBadges = newBadges;
  

/// The coins the win paid (`max(0, rewardCoins)`).
@override@JsonKey() final  int coins;
/// The rival this win unlocked (2 or 3), or null: rival 3 unlocks
/// nothing, and a rival already open isn't unlocked again.
@override final  int? unlockedRival;
/// The races won against this rival after this win.
@override@JsonKey() final  int wins;
/// The badges this win earned, in [BadgeId] order (`first_race`,
/// `all_rivals` and the board's own; one toast each).
 final  List<BadgeId> _newBadges;
/// The badges this win earned, in [BadgeId] order (`first_race`,
/// `all_rivals` and the board's own; one toast each).
@override@JsonKey() List<BadgeId> get newBadges {
  if (_newBadges is EqualUnmodifiableListView) return _newBadges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_newBadges);
}


/// Create a copy of RaceWinOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RaceWinOutcomeCopyWith<_RaceWinOutcome> get copyWith => __$RaceWinOutcomeCopyWithImpl<_RaceWinOutcome>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RaceWinOutcome&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.unlockedRival, unlockedRival) || other.unlockedRival == unlockedRival)&&(identical(other.wins, wins) || other.wins == wins)&&const DeepCollectionEquality().equals(other._newBadges, _newBadges));
}


@override
int get hashCode => Object.hash(runtimeType,coins,unlockedRival,wins,const DeepCollectionEquality().hash(_newBadges));

@override
String toString() {
  return 'RaceWinOutcome(coins: $coins, unlockedRival: $unlockedRival, wins: $wins, newBadges: $newBadges)';
}


}

/// @nodoc
abstract mixin class _$RaceWinOutcomeCopyWith<$Res> implements $RaceWinOutcomeCopyWith<$Res> {
  factory _$RaceWinOutcomeCopyWith(_RaceWinOutcome value, $Res Function(_RaceWinOutcome) _then) = __$RaceWinOutcomeCopyWithImpl;
@override @useResult
$Res call({
 int coins, int? unlockedRival, int wins, List<BadgeId> newBadges
});




}
/// @nodoc
class __$RaceWinOutcomeCopyWithImpl<$Res>
    implements _$RaceWinOutcomeCopyWith<$Res> {
  __$RaceWinOutcomeCopyWithImpl(this._self, this._then);

  final _RaceWinOutcome _self;
  final $Res Function(_RaceWinOutcome) _then;

/// Create a copy of RaceWinOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coins = null,Object? unlockedRival = freezed,Object? wins = null,Object? newBadges = null,}) {
  return _then(_RaceWinOutcome(
coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,unlockedRival: freezed == unlockedRival ? _self.unlockedRival : unlockedRival // ignore: cast_nullable_to_non_nullable
as int?,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,newBadges: null == newBadges ? _self._newBadges : newBadges // ignore: cast_nullable_to_non_nullable
as List<BadgeId>,
  ));
}


}

// dart format on
