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
 String? get playerId;/// Top-level keys this schema doesn't know (a newer app's), kept as they
/// were and written back (m3-design §3.3).
 Map<String, Object?> get unknown;
/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveDocumentCopyWith<SaveDocument> get copyWith => _$SaveDocumentCopyWithImpl<SaveDocument>(this as SaveDocument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveDocument&&(identical(other.schema, schema) || other.schema == schema)&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel)&&(identical(other.highestLevel, highestLevel) || other.highestLevel == highestLevel)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.inventory, inventory) || other.inventory == inventory)&&(identical(other.adsRemoved, adsRemoved) || other.adsRemoved == adsRemoved)&&const DeepCollectionEquality().equals(other.ownedSkins, ownedSkins)&&(identical(other.selectedSkin, selectedSkin) || other.selectedSkin == selectedSkin)&&const DeepCollectionEquality().equals(other.ownedThemes, ownedThemes)&&(identical(other.selectedTheme, selectedTheme) || other.selectedTheme == selectedTheme)&&const DeepCollectionEquality().equals(other.museum, museum)&&const DeepCollectionEquality().equals(other.museumCollected, museumCollected)&&(identical(other.daily, daily) || other.daily == daily)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.adCounters, adCounters) || other.adCounters == adCounters)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.seenIntros, seenIntros)&&(identical(other.tutorialDone, tutorialDone) || other.tutorialDone == tutorialDone)&&(identical(other.bonus, bonus) || other.bonus == bonus)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&const DeepCollectionEquality().equals(other.unknown, unknown));
}


@override
int get hashCode => Object.hashAll([runtimeType,schema,currentLevel,highestLevel,coins,inventory,adsRemoved,const DeepCollectionEquality().hash(ownedSkins),selectedSkin,const DeepCollectionEquality().hash(ownedThemes),selectedTheme,const DeepCollectionEquality().hash(museum),const DeepCollectionEquality().hash(museumCollected),daily,inProgress,adCounters,stats,const DeepCollectionEquality().hash(seenIntros),tutorialDone,bonus,playerId,const DeepCollectionEquality().hash(unknown)]);

@override
String toString() {
  return 'SaveDocument(schema: $schema, currentLevel: $currentLevel, highestLevel: $highestLevel, coins: $coins, inventory: $inventory, adsRemoved: $adsRemoved, ownedSkins: $ownedSkins, selectedSkin: $selectedSkin, ownedThemes: $ownedThemes, selectedTheme: $selectedTheme, museum: $museum, museumCollected: $museumCollected, daily: $daily, inProgress: $inProgress, adCounters: $adCounters, stats: $stats, seenIntros: $seenIntros, tutorialDone: $tutorialDone, bonus: $bonus, playerId: $playerId, unknown: $unknown)';
}


}

/// @nodoc
abstract mixin class $SaveDocumentCopyWith<$Res>  {
  factory $SaveDocumentCopyWith(SaveDocument value, $Res Function(SaveDocument) _then) = _$SaveDocumentCopyWithImpl;
@useResult
$Res call({
 int schema, int currentLevel, int highestLevel, int coins, BoosterInventory inventory, bool adsRemoved, List<String> ownedSkins, String selectedSkin, List<String> ownedThemes, String? selectedTheme, List<String> museum, Map<String, LocalDate> museumCollected, DailyProgress daily, InProgressLevel? inProgress, AdCounters adCounters, SaveStats stats, List<String> seenIntros, bool tutorialDone, BonusProgress bonus, String? playerId, Map<String, Object?> unknown
});


$BoosterInventoryCopyWith<$Res> get inventory;$DailyProgressCopyWith<$Res> get daily;$InProgressLevelCopyWith<$Res>? get inProgress;$AdCountersCopyWith<$Res> get adCounters;$SaveStatsCopyWith<$Res> get stats;$BonusProgressCopyWith<$Res> get bonus;

}
/// @nodoc
class _$SaveDocumentCopyWithImpl<$Res>
    implements $SaveDocumentCopyWith<$Res> {
  _$SaveDocumentCopyWithImpl(this._self, this._then);

  final SaveDocument _self;
  final $Res Function(SaveDocument) _then;

/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schema = null,Object? currentLevel = null,Object? highestLevel = null,Object? coins = null,Object? inventory = null,Object? adsRemoved = null,Object? ownedSkins = null,Object? selectedSkin = null,Object? ownedThemes = null,Object? selectedTheme = freezed,Object? museum = null,Object? museumCollected = null,Object? daily = null,Object? inProgress = freezed,Object? adCounters = null,Object? stats = null,Object? seenIntros = null,Object? tutorialDone = null,Object? bonus = null,Object? playerId = freezed,Object? unknown = null,}) {
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
as String?,unknown: null == unknown ? _self.unknown : unknown // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schema,  int currentLevel,  int highestLevel,  int coins,  BoosterInventory inventory,  bool adsRemoved,  List<String> ownedSkins,  String selectedSkin,  List<String> ownedThemes,  String? selectedTheme,  List<String> museum,  Map<String, LocalDate> museumCollected,  DailyProgress daily,  InProgressLevel? inProgress,  AdCounters adCounters,  SaveStats stats,  List<String> seenIntros,  bool tutorialDone,  BonusProgress bonus,  String? playerId,  Map<String, Object?> unknown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaveDocument() when $default != null:
return $default(_that.schema,_that.currentLevel,_that.highestLevel,_that.coins,_that.inventory,_that.adsRemoved,_that.ownedSkins,_that.selectedSkin,_that.ownedThemes,_that.selectedTheme,_that.museum,_that.museumCollected,_that.daily,_that.inProgress,_that.adCounters,_that.stats,_that.seenIntros,_that.tutorialDone,_that.bonus,_that.playerId,_that.unknown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schema,  int currentLevel,  int highestLevel,  int coins,  BoosterInventory inventory,  bool adsRemoved,  List<String> ownedSkins,  String selectedSkin,  List<String> ownedThemes,  String? selectedTheme,  List<String> museum,  Map<String, LocalDate> museumCollected,  DailyProgress daily,  InProgressLevel? inProgress,  AdCounters adCounters,  SaveStats stats,  List<String> seenIntros,  bool tutorialDone,  BonusProgress bonus,  String? playerId,  Map<String, Object?> unknown)  $default,) {final _that = this;
switch (_that) {
case _SaveDocument():
return $default(_that.schema,_that.currentLevel,_that.highestLevel,_that.coins,_that.inventory,_that.adsRemoved,_that.ownedSkins,_that.selectedSkin,_that.ownedThemes,_that.selectedTheme,_that.museum,_that.museumCollected,_that.daily,_that.inProgress,_that.adCounters,_that.stats,_that.seenIntros,_that.tutorialDone,_that.bonus,_that.playerId,_that.unknown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schema,  int currentLevel,  int highestLevel,  int coins,  BoosterInventory inventory,  bool adsRemoved,  List<String> ownedSkins,  String selectedSkin,  List<String> ownedThemes,  String? selectedTheme,  List<String> museum,  Map<String, LocalDate> museumCollected,  DailyProgress daily,  InProgressLevel? inProgress,  AdCounters adCounters,  SaveStats stats,  List<String> seenIntros,  bool tutorialDone,  BonusProgress bonus,  String? playerId,  Map<String, Object?> unknown)?  $default,) {final _that = this;
switch (_that) {
case _SaveDocument() when $default != null:
return $default(_that.schema,_that.currentLevel,_that.highestLevel,_that.coins,_that.inventory,_that.adsRemoved,_that.ownedSkins,_that.selectedSkin,_that.ownedThemes,_that.selectedTheme,_that.museum,_that.museumCollected,_that.daily,_that.inProgress,_that.adCounters,_that.stats,_that.seenIntros,_that.tutorialDone,_that.bonus,_that.playerId,_that.unknown);case _:
  return null;

}
}

}

/// @nodoc


class _SaveDocument extends SaveDocument {
  const _SaveDocument({this.schema = SaveDocument.currentSchema, this.currentLevel = 1, this.highestLevel = 1, this.coins = 0, this.inventory = const BoosterInventory(), this.adsRemoved = false, final  List<String> ownedSkins = const <String>[SaveDocument.defaultSkin], this.selectedSkin = SaveDocument.defaultSkin, final  List<String> ownedThemes = const <String>[SaveDocument.defaultTheme], this.selectedTheme, final  List<String> museum = const <String>[], final  Map<String, LocalDate> museumCollected = const <String, LocalDate>{}, this.daily = const DailyProgress(), this.inProgress, this.adCounters = const AdCounters(), this.stats = const SaveStats(), final  List<String> seenIntros = const <String>[], this.tutorialDone = false, this.bonus = const BonusProgress(), this.playerId, final  Map<String, Object?> unknown = const <String, Object?>{}}): _ownedSkins = ownedSkins,_ownedThemes = ownedThemes,_museum = museum,_museumCollected = museumCollected,_seenIntros = seenIntros,_unknown = unknown,super._();
  

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveDocument&&(identical(other.schema, schema) || other.schema == schema)&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel)&&(identical(other.highestLevel, highestLevel) || other.highestLevel == highestLevel)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.inventory, inventory) || other.inventory == inventory)&&(identical(other.adsRemoved, adsRemoved) || other.adsRemoved == adsRemoved)&&const DeepCollectionEquality().equals(other._ownedSkins, _ownedSkins)&&(identical(other.selectedSkin, selectedSkin) || other.selectedSkin == selectedSkin)&&const DeepCollectionEquality().equals(other._ownedThemes, _ownedThemes)&&(identical(other.selectedTheme, selectedTheme) || other.selectedTheme == selectedTheme)&&const DeepCollectionEquality().equals(other._museum, _museum)&&const DeepCollectionEquality().equals(other._museumCollected, _museumCollected)&&(identical(other.daily, daily) || other.daily == daily)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.adCounters, adCounters) || other.adCounters == adCounters)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other._seenIntros, _seenIntros)&&(identical(other.tutorialDone, tutorialDone) || other.tutorialDone == tutorialDone)&&(identical(other.bonus, bonus) || other.bonus == bonus)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&const DeepCollectionEquality().equals(other._unknown, _unknown));
}


@override
int get hashCode => Object.hashAll([runtimeType,schema,currentLevel,highestLevel,coins,inventory,adsRemoved,const DeepCollectionEquality().hash(_ownedSkins),selectedSkin,const DeepCollectionEquality().hash(_ownedThemes),selectedTheme,const DeepCollectionEquality().hash(_museum),const DeepCollectionEquality().hash(_museumCollected),daily,inProgress,adCounters,stats,const DeepCollectionEquality().hash(_seenIntros),tutorialDone,bonus,playerId,const DeepCollectionEquality().hash(_unknown)]);

@override
String toString() {
  return 'SaveDocument(schema: $schema, currentLevel: $currentLevel, highestLevel: $highestLevel, coins: $coins, inventory: $inventory, adsRemoved: $adsRemoved, ownedSkins: $ownedSkins, selectedSkin: $selectedSkin, ownedThemes: $ownedThemes, selectedTheme: $selectedTheme, museum: $museum, museumCollected: $museumCollected, daily: $daily, inProgress: $inProgress, adCounters: $adCounters, stats: $stats, seenIntros: $seenIntros, tutorialDone: $tutorialDone, bonus: $bonus, playerId: $playerId, unknown: $unknown)';
}


}

/// @nodoc
abstract mixin class _$SaveDocumentCopyWith<$Res> implements $SaveDocumentCopyWith<$Res> {
  factory _$SaveDocumentCopyWith(_SaveDocument value, $Res Function(_SaveDocument) _then) = __$SaveDocumentCopyWithImpl;
@override @useResult
$Res call({
 int schema, int currentLevel, int highestLevel, int coins, BoosterInventory inventory, bool adsRemoved, List<String> ownedSkins, String selectedSkin, List<String> ownedThemes, String? selectedTheme, List<String> museum, Map<String, LocalDate> museumCollected, DailyProgress daily, InProgressLevel? inProgress, AdCounters adCounters, SaveStats stats, List<String> seenIntros, bool tutorialDone, BonusProgress bonus, String? playerId, Map<String, Object?> unknown
});


@override $BoosterInventoryCopyWith<$Res> get inventory;@override $DailyProgressCopyWith<$Res> get daily;@override $InProgressLevelCopyWith<$Res>? get inProgress;@override $AdCountersCopyWith<$Res> get adCounters;@override $SaveStatsCopyWith<$Res> get stats;@override $BonusProgressCopyWith<$Res> get bonus;

}
/// @nodoc
class __$SaveDocumentCopyWithImpl<$Res>
    implements _$SaveDocumentCopyWith<$Res> {
  __$SaveDocumentCopyWithImpl(this._self, this._then);

  final _SaveDocument _self;
  final $Res Function(_SaveDocument) _then;

/// Create a copy of SaveDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schema = null,Object? currentLevel = null,Object? highestLevel = null,Object? coins = null,Object? inventory = null,Object? adsRemoved = null,Object? ownedSkins = null,Object? selectedSkin = null,Object? ownedThemes = null,Object? selectedTheme = freezed,Object? museum = null,Object? museumCollected = null,Object? daily = null,Object? inProgress = freezed,Object? adCounters = null,Object? stats = null,Object? seenIntros = null,Object? tutorialDone = null,Object? bonus = null,Object? playerId = freezed,Object? unknown = null,}) {
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
as String?,unknown: null == unknown ? _self._unknown : unknown // ignore: cast_nullable_to_non_nullable
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

/// Days in a row: a solve adds one, a frozen day keeps it (§7.5).
 int get streak;/// The last day the streak reached, by a solve or a freeze; null when
/// there is no streak.
 LocalDate? get lastDate;/// Freezes held, 0 or 1 ([maxFreezes]).
 int get freezes;/// `LocalDate.isoWeekKey` of the last weekly freeze grant.
 int? get freezeWeek;/// Days solved, oldest first, at most [maxDates].
 List<LocalDate> get done;/// Days a freeze covered, oldest first, at most [maxDates].
 List<LocalDate> get frozen;/// The frozen day whose "Streak saved!" banner (frame 5.2) was shown.
 LocalDate? get noticeDate;/// A 7th streak day was solved and its chest (frame 5.6) not collected.
 bool get chestPending;/// Today's daily board in progress (m3-design §3.4).
 InProgressLevel? get inProgress;
/// Create a copy of DailyProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyProgressCopyWith<DailyProgress> get copyWith => _$DailyProgressCopyWithImpl<DailyProgress>(this as DailyProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyProgress&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.lastDate, lastDate) || other.lastDate == lastDate)&&(identical(other.freezes, freezes) || other.freezes == freezes)&&(identical(other.freezeWeek, freezeWeek) || other.freezeWeek == freezeWeek)&&const DeepCollectionEquality().equals(other.done, done)&&const DeepCollectionEquality().equals(other.frozen, frozen)&&(identical(other.noticeDate, noticeDate) || other.noticeDate == noticeDate)&&(identical(other.chestPending, chestPending) || other.chestPending == chestPending)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress));
}


@override
int get hashCode => Object.hash(runtimeType,streak,lastDate,freezes,freezeWeek,const DeepCollectionEquality().hash(done),const DeepCollectionEquality().hash(frozen),noticeDate,chestPending,inProgress);

@override
String toString() {
  return 'DailyProgress(streak: $streak, lastDate: $lastDate, freezes: $freezes, freezeWeek: $freezeWeek, done: $done, frozen: $frozen, noticeDate: $noticeDate, chestPending: $chestPending, inProgress: $inProgress)';
}


}

/// @nodoc
abstract mixin class $DailyProgressCopyWith<$Res>  {
  factory $DailyProgressCopyWith(DailyProgress value, $Res Function(DailyProgress) _then) = _$DailyProgressCopyWithImpl;
@useResult
$Res call({
 int streak, LocalDate? lastDate, int freezes, int? freezeWeek, List<LocalDate> done, List<LocalDate> frozen, LocalDate? noticeDate, bool chestPending, InProgressLevel? inProgress
});


$InProgressLevelCopyWith<$Res>? get inProgress;

}
/// @nodoc
class _$DailyProgressCopyWithImpl<$Res>
    implements $DailyProgressCopyWith<$Res> {
  _$DailyProgressCopyWithImpl(this._self, this._then);

  final DailyProgress _self;
  final $Res Function(DailyProgress) _then;

/// Create a copy of DailyProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? streak = null,Object? lastDate = freezed,Object? freezes = null,Object? freezeWeek = freezed,Object? done = null,Object? frozen = null,Object? noticeDate = freezed,Object? chestPending = null,Object? inProgress = freezed,}) {
  return _then(_self.copyWith(
streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,lastDate: freezed == lastDate ? _self.lastDate : lastDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,freezes: null == freezes ? _self.freezes : freezes // ignore: cast_nullable_to_non_nullable
as int,freezeWeek: freezed == freezeWeek ? _self.freezeWeek : freezeWeek // ignore: cast_nullable_to_non_nullable
as int?,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as List<LocalDate>,frozen: null == frozen ? _self.frozen : frozen // ignore: cast_nullable_to_non_nullable
as List<LocalDate>,noticeDate: freezed == noticeDate ? _self.noticeDate : noticeDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,chestPending: null == chestPending ? _self.chestPending : chestPending // ignore: cast_nullable_to_non_nullable
as bool,inProgress: freezed == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as InProgressLevel?,
  ));
}
/// Create a copy of DailyProgress
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int streak,  LocalDate? lastDate,  int freezes,  int? freezeWeek,  List<LocalDate> done,  List<LocalDate> frozen,  LocalDate? noticeDate,  bool chestPending,  InProgressLevel? inProgress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyProgress() when $default != null:
return $default(_that.streak,_that.lastDate,_that.freezes,_that.freezeWeek,_that.done,_that.frozen,_that.noticeDate,_that.chestPending,_that.inProgress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int streak,  LocalDate? lastDate,  int freezes,  int? freezeWeek,  List<LocalDate> done,  List<LocalDate> frozen,  LocalDate? noticeDate,  bool chestPending,  InProgressLevel? inProgress)  $default,) {final _that = this;
switch (_that) {
case _DailyProgress():
return $default(_that.streak,_that.lastDate,_that.freezes,_that.freezeWeek,_that.done,_that.frozen,_that.noticeDate,_that.chestPending,_that.inProgress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int streak,  LocalDate? lastDate,  int freezes,  int? freezeWeek,  List<LocalDate> done,  List<LocalDate> frozen,  LocalDate? noticeDate,  bool chestPending,  InProgressLevel? inProgress)?  $default,) {final _that = this;
switch (_that) {
case _DailyProgress() when $default != null:
return $default(_that.streak,_that.lastDate,_that.freezes,_that.freezeWeek,_that.done,_that.frozen,_that.noticeDate,_that.chestPending,_that.inProgress);case _:
  return null;

}
}

}

/// @nodoc


class _DailyProgress extends DailyProgress {
  const _DailyProgress({this.streak = 0, this.lastDate, this.freezes = 0, this.freezeWeek, final  List<LocalDate> done = const <LocalDate>[], final  List<LocalDate> frozen = const <LocalDate>[], this.noticeDate, this.chestPending = false, this.inProgress}): _done = done,_frozen = frozen,super._();
  

/// Days in a row: a solve adds one, a frozen day keeps it (§7.5).
@override@JsonKey() final  int streak;
/// The last day the streak reached, by a solve or a freeze; null when
/// there is no streak.
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
/// Today's daily board in progress (m3-design §3.4).
@override final  InProgressLevel? inProgress;

/// Create a copy of DailyProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyProgressCopyWith<_DailyProgress> get copyWith => __$DailyProgressCopyWithImpl<_DailyProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyProgress&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.lastDate, lastDate) || other.lastDate == lastDate)&&(identical(other.freezes, freezes) || other.freezes == freezes)&&(identical(other.freezeWeek, freezeWeek) || other.freezeWeek == freezeWeek)&&const DeepCollectionEquality().equals(other._done, _done)&&const DeepCollectionEquality().equals(other._frozen, _frozen)&&(identical(other.noticeDate, noticeDate) || other.noticeDate == noticeDate)&&(identical(other.chestPending, chestPending) || other.chestPending == chestPending)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress));
}


@override
int get hashCode => Object.hash(runtimeType,streak,lastDate,freezes,freezeWeek,const DeepCollectionEquality().hash(_done),const DeepCollectionEquality().hash(_frozen),noticeDate,chestPending,inProgress);

@override
String toString() {
  return 'DailyProgress(streak: $streak, lastDate: $lastDate, freezes: $freezes, freezeWeek: $freezeWeek, done: $done, frozen: $frozen, noticeDate: $noticeDate, chestPending: $chestPending, inProgress: $inProgress)';
}


}

/// @nodoc
abstract mixin class _$DailyProgressCopyWith<$Res> implements $DailyProgressCopyWith<$Res> {
  factory _$DailyProgressCopyWith(_DailyProgress value, $Res Function(_DailyProgress) _then) = __$DailyProgressCopyWithImpl;
@override @useResult
$Res call({
 int streak, LocalDate? lastDate, int freezes, int? freezeWeek, List<LocalDate> done, List<LocalDate> frozen, LocalDate? noticeDate, bool chestPending, InProgressLevel? inProgress
});


@override $InProgressLevelCopyWith<$Res>? get inProgress;

}
/// @nodoc
class __$DailyProgressCopyWithImpl<$Res>
    implements _$DailyProgressCopyWith<$Res> {
  __$DailyProgressCopyWithImpl(this._self, this._then);

  final _DailyProgress _self;
  final $Res Function(_DailyProgress) _then;

/// Create a copy of DailyProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? streak = null,Object? lastDate = freezed,Object? freezes = null,Object? freezeWeek = freezed,Object? done = null,Object? frozen = null,Object? noticeDate = freezed,Object? chestPending = null,Object? inProgress = freezed,}) {
  return _then(_DailyProgress(
streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,lastDate: freezed == lastDate ? _self.lastDate : lastDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,freezes: null == freezes ? _self.freezes : freezes // ignore: cast_nullable_to_non_nullable
as int,freezeWeek: freezed == freezeWeek ? _self.freezeWeek : freezeWeek // ignore: cast_nullable_to_non_nullable
as int?,done: null == done ? _self._done : done // ignore: cast_nullable_to_non_nullable
as List<LocalDate>,frozen: null == frozen ? _self._frozen : frozen // ignore: cast_nullable_to_non_nullable
as List<LocalDate>,noticeDate: freezed == noticeDate ? _self.noticeDate : noticeDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,chestPending: null == chestPending ? _self.chestPending : chestPending // ignore: cast_nullable_to_non_nullable
as bool,inProgress: freezed == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as InProgressLevel?,
  ));
}

/// Create a copy of DailyProgress
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
mixin _$InProgressLevel {

/// What is being played; its kind and number are stored.
 PlayRequest get request;/// `Level.id` of the board.
 String get levelId;/// Must equal the entry's `PlayEntry.levelVersion` to restore (§13.3).
 int get levelVersion;/// `GameSessionCodec.encode` of the session: the board, the undo
/// history and `undosUsed`. The selection and the hint are not saved.
 Map<String, Object?> get session;/// `LevelCodec.encode` of a generated board (bonus, daily), so a resume
/// never regenerates it. Null for campaign levels.
 Map<String, Object?>? get level;/// A generated board's tier, so a resume needn't simulate it again.
 Tier? get tier;
/// Create a copy of InProgressLevel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InProgressLevelCopyWith<InProgressLevel> get copyWith => _$InProgressLevelCopyWithImpl<InProgressLevel>(this as InProgressLevel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InProgressLevel&&(identical(other.request, request) || other.request == request)&&(identical(other.levelId, levelId) || other.levelId == levelId)&&(identical(other.levelVersion, levelVersion) || other.levelVersion == levelVersion)&&const DeepCollectionEquality().equals(other.session, session)&&const DeepCollectionEquality().equals(other.level, level)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode => Object.hash(runtimeType,request,levelId,levelVersion,const DeepCollectionEquality().hash(session),const DeepCollectionEquality().hash(level),tier);

@override
String toString() {
  return 'InProgressLevel(request: $request, levelId: $levelId, levelVersion: $levelVersion, session: $session, level: $level, tier: $tier)';
}


}

/// @nodoc
abstract mixin class $InProgressLevelCopyWith<$Res>  {
  factory $InProgressLevelCopyWith(InProgressLevel value, $Res Function(InProgressLevel) _then) = _$InProgressLevelCopyWithImpl;
@useResult
$Res call({
 PlayRequest request, String levelId, int levelVersion, Map<String, Object?> session, Map<String, Object?>? level, Tier? tier
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
@pragma('vm:prefer-inline') @override $Res call({Object? request = null,Object? levelId = null,Object? levelVersion = null,Object? session = null,Object? level = freezed,Object? tier = freezed,}) {
  return _then(_self.copyWith(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PlayRequest,levelId: null == levelId ? _self.levelId : levelId // ignore: cast_nullable_to_non_nullable
as String,levelVersion: null == levelVersion ? _self.levelVersion : levelVersion // ignore: cast_nullable_to_non_nullable
as int,session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,tier: freezed == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayRequest request,  String levelId,  int levelVersion,  Map<String, Object?> session,  Map<String, Object?>? level,  Tier? tier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InProgressLevel() when $default != null:
return $default(_that.request,_that.levelId,_that.levelVersion,_that.session,_that.level,_that.tier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayRequest request,  String levelId,  int levelVersion,  Map<String, Object?> session,  Map<String, Object?>? level,  Tier? tier)  $default,) {final _that = this;
switch (_that) {
case _InProgressLevel():
return $default(_that.request,_that.levelId,_that.levelVersion,_that.session,_that.level,_that.tier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayRequest request,  String levelId,  int levelVersion,  Map<String, Object?> session,  Map<String, Object?>? level,  Tier? tier)?  $default,) {final _that = this;
switch (_that) {
case _InProgressLevel() when $default != null:
return $default(_that.request,_that.levelId,_that.levelVersion,_that.session,_that.level,_that.tier);case _:
  return null;

}
}

}

/// @nodoc


class _InProgressLevel implements InProgressLevel {
  const _InProgressLevel({required this.request, required this.levelId, required this.levelVersion, required final  Map<String, Object?> session, final  Map<String, Object?>? level, this.tier}): _session = session,_level = level;
  

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

/// Create a copy of InProgressLevel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InProgressLevelCopyWith<_InProgressLevel> get copyWith => __$InProgressLevelCopyWithImpl<_InProgressLevel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InProgressLevel&&(identical(other.request, request) || other.request == request)&&(identical(other.levelId, levelId) || other.levelId == levelId)&&(identical(other.levelVersion, levelVersion) || other.levelVersion == levelVersion)&&const DeepCollectionEquality().equals(other._session, _session)&&const DeepCollectionEquality().equals(other._level, _level)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode => Object.hash(runtimeType,request,levelId,levelVersion,const DeepCollectionEquality().hash(_session),const DeepCollectionEquality().hash(_level),tier);

@override
String toString() {
  return 'InProgressLevel(request: $request, levelId: $levelId, levelVersion: $levelVersion, session: $session, level: $level, tier: $tier)';
}


}

/// @nodoc
abstract mixin class _$InProgressLevelCopyWith<$Res> implements $InProgressLevelCopyWith<$Res> {
  factory _$InProgressLevelCopyWith(_InProgressLevel value, $Res Function(_InProgressLevel) _then) = __$InProgressLevelCopyWithImpl;
@override @useResult
$Res call({
 PlayRequest request, String levelId, int levelVersion, Map<String, Object?> session, Map<String, Object?>? level, Tier? tier
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
@override @pragma('vm:prefer-inline') $Res call({Object? request = null,Object? levelId = null,Object? levelVersion = null,Object? session = null,Object? level = freezed,Object? tier = freezed,}) {
  return _then(_InProgressLevel(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PlayRequest,levelId: null == levelId ? _self.levelId : levelId // ignore: cast_nullable_to_non_nullable
as String,levelVersion: null == levelVersion ? _self.levelVersion : levelVersion // ignore: cast_nullable_to_non_nullable
as int,session: null == session ? _self._session : session // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,level: freezed == level ? _self._level : level // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,tier: freezed == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier?,
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
 DailyProgress? get daily;
/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LevelWinRecordCopyWith<LevelWinRecord> get copyWith => _$LevelWinRecordCopyWithImpl<LevelWinRecord>(this as LevelWinRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LevelWinRecord&&(identical(other.request, request) || other.request == request)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.completedChapterId, completedChapterId) || other.completedChapterId == completedChapterId)&&(identical(other.chapterReward, chapterReward) || other.chapterReward == chapterReward)&&(identical(other.date, date) || other.date == date)&&(identical(other.daily, daily) || other.daily == daily));
}


@override
int get hashCode => Object.hash(runtimeType,request,rewardCoins,moves,completedChapterId,chapterReward,date,daily);

@override
String toString() {
  return 'LevelWinRecord(request: $request, rewardCoins: $rewardCoins, moves: $moves, completedChapterId: $completedChapterId, chapterReward: $chapterReward, date: $date, daily: $daily)';
}


}

/// @nodoc
abstract mixin class $LevelWinRecordCopyWith<$Res>  {
  factory $LevelWinRecordCopyWith(LevelWinRecord value, $Res Function(LevelWinRecord) _then) = _$LevelWinRecordCopyWithImpl;
@useResult
$Res call({
 PlayRequest request, int rewardCoins, int moves, String? completedChapterId, int chapterReward, LocalDate? date, DailyProgress? daily
});


$PlayRequestCopyWith<$Res> get request;$DailyProgressCopyWith<$Res>? get daily;

}
/// @nodoc
class _$LevelWinRecordCopyWithImpl<$Res>
    implements $LevelWinRecordCopyWith<$Res> {
  _$LevelWinRecordCopyWithImpl(this._self, this._then);

  final LevelWinRecord _self;
  final $Res Function(LevelWinRecord) _then;

/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? request = null,Object? rewardCoins = null,Object? moves = null,Object? completedChapterId = freezed,Object? chapterReward = null,Object? date = freezed,Object? daily = freezed,}) {
  return _then(_self.copyWith(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PlayRequest,rewardCoins: null == rewardCoins ? _self.rewardCoins : rewardCoins // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,completedChapterId: freezed == completedChapterId ? _self.completedChapterId : completedChapterId // ignore: cast_nullable_to_non_nullable
as String?,chapterReward: null == chapterReward ? _self.chapterReward : chapterReward // ignore: cast_nullable_to_non_nullable
as int,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate?,daily: freezed == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as DailyProgress?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayRequest request,  int rewardCoins,  int moves,  String? completedChapterId,  int chapterReward,  LocalDate? date,  DailyProgress? daily)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LevelWinRecord() when $default != null:
return $default(_that.request,_that.rewardCoins,_that.moves,_that.completedChapterId,_that.chapterReward,_that.date,_that.daily);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayRequest request,  int rewardCoins,  int moves,  String? completedChapterId,  int chapterReward,  LocalDate? date,  DailyProgress? daily)  $default,) {final _that = this;
switch (_that) {
case _LevelWinRecord():
return $default(_that.request,_that.rewardCoins,_that.moves,_that.completedChapterId,_that.chapterReward,_that.date,_that.daily);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayRequest request,  int rewardCoins,  int moves,  String? completedChapterId,  int chapterReward,  LocalDate? date,  DailyProgress? daily)?  $default,) {final _that = this;
switch (_that) {
case _LevelWinRecord() when $default != null:
return $default(_that.request,_that.rewardCoins,_that.moves,_that.completedChapterId,_that.chapterReward,_that.date,_that.daily);case _:
  return null;

}
}

}

/// @nodoc


class _LevelWinRecord implements LevelWinRecord {
  const _LevelWinRecord({required this.request, required this.rewardCoins, this.moves = 0, this.completedChapterId, this.chapterReward = 0, this.date, this.daily});
  

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

/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LevelWinRecordCopyWith<_LevelWinRecord> get copyWith => __$LevelWinRecordCopyWithImpl<_LevelWinRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LevelWinRecord&&(identical(other.request, request) || other.request == request)&&(identical(other.rewardCoins, rewardCoins) || other.rewardCoins == rewardCoins)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.completedChapterId, completedChapterId) || other.completedChapterId == completedChapterId)&&(identical(other.chapterReward, chapterReward) || other.chapterReward == chapterReward)&&(identical(other.date, date) || other.date == date)&&(identical(other.daily, daily) || other.daily == daily));
}


@override
int get hashCode => Object.hash(runtimeType,request,rewardCoins,moves,completedChapterId,chapterReward,date,daily);

@override
String toString() {
  return 'LevelWinRecord(request: $request, rewardCoins: $rewardCoins, moves: $moves, completedChapterId: $completedChapterId, chapterReward: $chapterReward, date: $date, daily: $daily)';
}


}

/// @nodoc
abstract mixin class _$LevelWinRecordCopyWith<$Res> implements $LevelWinRecordCopyWith<$Res> {
  factory _$LevelWinRecordCopyWith(_LevelWinRecord value, $Res Function(_LevelWinRecord) _then) = __$LevelWinRecordCopyWithImpl;
@override @useResult
$Res call({
 PlayRequest request, int rewardCoins, int moves, String? completedChapterId, int chapterReward, LocalDate? date, DailyProgress? daily
});


@override $PlayRequestCopyWith<$Res> get request;@override $DailyProgressCopyWith<$Res>? get daily;

}
/// @nodoc
class __$LevelWinRecordCopyWithImpl<$Res>
    implements _$LevelWinRecordCopyWith<$Res> {
  __$LevelWinRecordCopyWithImpl(this._self, this._then);

  final _LevelWinRecord _self;
  final $Res Function(_LevelWinRecord) _then;

/// Create a copy of LevelWinRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? request = null,Object? rewardCoins = null,Object? moves = null,Object? completedChapterId = freezed,Object? chapterReward = null,Object? date = freezed,Object? daily = freezed,}) {
  return _then(_LevelWinRecord(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PlayRequest,rewardCoins: null == rewardCoins ? _self.rewardCoins : rewardCoins // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,completedChapterId: freezed == completedChapterId ? _self.completedChapterId : completedChapterId // ignore: cast_nullable_to_non_nullable
as String?,chapterReward: null == chapterReward ? _self.chapterReward : chapterReward // ignore: cast_nullable_to_non_nullable
as int,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate?,daily: freezed == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as DailyProgress?,
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
}
}

// dart format on
