// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShopState {

/// The segmented control's current tab.
 ShopTab get tab;/// The coin pill (header) and the "You have N coins" lines.
 int get coins;/// Sold skins only, in catalog order (`forest-bear` never appears,
/// D75).
 List<SkinInfo> get skins;/// `SaveDocument.ownedSkins` (`classic` is always in it).
 List<String> get ownedSkins;/// The skin every board actually draws
/// ([SkinService.selectedSkinId]): the green-ring "Equipped" skin.
 String get selectedSkinId;/// Every theme, in catalog (chapter) order.
 List<ThemeInfo> get themes;/// `SaveDocument.ownedThemes` (bought early, or `ch01`).
 List<String> get ownedThemes;/// `SaveDocument.selectedTheme`: null means "Match each chapter".
 String? get selectedThemeId;/// The theme of the chapter the player has reached (or the last
/// published one in Bonus Endless): what turning the toggle back on
/// picks, and what "Match each chapter" would show right now.
 String get currentChapterThemeId;/// The reached chapter's number, for [ThemeInfo.isOwned].
 int get reachedChapterNumber;
/// Create a copy of ShopState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopStateCopyWith<ShopState> get copyWith => _$ShopStateCopyWithImpl<ShopState>(this as ShopState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShopState&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.coins, coins) || other.coins == coins)&&const DeepCollectionEquality().equals(other.skins, skins)&&const DeepCollectionEquality().equals(other.ownedSkins, ownedSkins)&&(identical(other.selectedSkinId, selectedSkinId) || other.selectedSkinId == selectedSkinId)&&const DeepCollectionEquality().equals(other.themes, themes)&&const DeepCollectionEquality().equals(other.ownedThemes, ownedThemes)&&(identical(other.selectedThemeId, selectedThemeId) || other.selectedThemeId == selectedThemeId)&&(identical(other.currentChapterThemeId, currentChapterThemeId) || other.currentChapterThemeId == currentChapterThemeId)&&(identical(other.reachedChapterNumber, reachedChapterNumber) || other.reachedChapterNumber == reachedChapterNumber));
}


@override
int get hashCode => Object.hash(runtimeType,tab,coins,const DeepCollectionEquality().hash(skins),const DeepCollectionEquality().hash(ownedSkins),selectedSkinId,const DeepCollectionEquality().hash(themes),const DeepCollectionEquality().hash(ownedThemes),selectedThemeId,currentChapterThemeId,reachedChapterNumber);

@override
String toString() {
  return 'ShopState(tab: $tab, coins: $coins, skins: $skins, ownedSkins: $ownedSkins, selectedSkinId: $selectedSkinId, themes: $themes, ownedThemes: $ownedThemes, selectedThemeId: $selectedThemeId, currentChapterThemeId: $currentChapterThemeId, reachedChapterNumber: $reachedChapterNumber)';
}


}

/// @nodoc
abstract mixin class $ShopStateCopyWith<$Res>  {
  factory $ShopStateCopyWith(ShopState value, $Res Function(ShopState) _then) = _$ShopStateCopyWithImpl;
@useResult
$Res call({
 ShopTab tab, int coins, List<SkinInfo> skins, List<String> ownedSkins, String selectedSkinId, List<ThemeInfo> themes, List<String> ownedThemes, String? selectedThemeId, String currentChapterThemeId, int reachedChapterNumber
});




}
/// @nodoc
class _$ShopStateCopyWithImpl<$Res>
    implements $ShopStateCopyWith<$Res> {
  _$ShopStateCopyWithImpl(this._self, this._then);

  final ShopState _self;
  final $Res Function(ShopState) _then;

/// Create a copy of ShopState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tab = null,Object? coins = null,Object? skins = null,Object? ownedSkins = null,Object? selectedSkinId = null,Object? themes = null,Object? ownedThemes = null,Object? selectedThemeId = freezed,Object? currentChapterThemeId = null,Object? reachedChapterNumber = null,}) {
  return _then(_self.copyWith(
tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as ShopTab,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,skins: null == skins ? _self.skins : skins // ignore: cast_nullable_to_non_nullable
as List<SkinInfo>,ownedSkins: null == ownedSkins ? _self.ownedSkins : ownedSkins // ignore: cast_nullable_to_non_nullable
as List<String>,selectedSkinId: null == selectedSkinId ? _self.selectedSkinId : selectedSkinId // ignore: cast_nullable_to_non_nullable
as String,themes: null == themes ? _self.themes : themes // ignore: cast_nullable_to_non_nullable
as List<ThemeInfo>,ownedThemes: null == ownedThemes ? _self.ownedThemes : ownedThemes // ignore: cast_nullable_to_non_nullable
as List<String>,selectedThemeId: freezed == selectedThemeId ? _self.selectedThemeId : selectedThemeId // ignore: cast_nullable_to_non_nullable
as String?,currentChapterThemeId: null == currentChapterThemeId ? _self.currentChapterThemeId : currentChapterThemeId // ignore: cast_nullable_to_non_nullable
as String,reachedChapterNumber: null == reachedChapterNumber ? _self.reachedChapterNumber : reachedChapterNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ShopState].
extension ShopStatePatterns on ShopState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShopState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShopState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShopState value)  $default,){
final _that = this;
switch (_that) {
case _ShopState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShopState value)?  $default,){
final _that = this;
switch (_that) {
case _ShopState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ShopTab tab,  int coins,  List<SkinInfo> skins,  List<String> ownedSkins,  String selectedSkinId,  List<ThemeInfo> themes,  List<String> ownedThemes,  String? selectedThemeId,  String currentChapterThemeId,  int reachedChapterNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShopState() when $default != null:
return $default(_that.tab,_that.coins,_that.skins,_that.ownedSkins,_that.selectedSkinId,_that.themes,_that.ownedThemes,_that.selectedThemeId,_that.currentChapterThemeId,_that.reachedChapterNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ShopTab tab,  int coins,  List<SkinInfo> skins,  List<String> ownedSkins,  String selectedSkinId,  List<ThemeInfo> themes,  List<String> ownedThemes,  String? selectedThemeId,  String currentChapterThemeId,  int reachedChapterNumber)  $default,) {final _that = this;
switch (_that) {
case _ShopState():
return $default(_that.tab,_that.coins,_that.skins,_that.ownedSkins,_that.selectedSkinId,_that.themes,_that.ownedThemes,_that.selectedThemeId,_that.currentChapterThemeId,_that.reachedChapterNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ShopTab tab,  int coins,  List<SkinInfo> skins,  List<String> ownedSkins,  String selectedSkinId,  List<ThemeInfo> themes,  List<String> ownedThemes,  String? selectedThemeId,  String currentChapterThemeId,  int reachedChapterNumber)?  $default,) {final _that = this;
switch (_that) {
case _ShopState() when $default != null:
return $default(_that.tab,_that.coins,_that.skins,_that.ownedSkins,_that.selectedSkinId,_that.themes,_that.ownedThemes,_that.selectedThemeId,_that.currentChapterThemeId,_that.reachedChapterNumber);case _:
  return null;

}
}

}

/// @nodoc


class _ShopState extends ShopState {
  const _ShopState({required this.tab, required this.coins, required final  List<SkinInfo> skins, required final  List<String> ownedSkins, required this.selectedSkinId, required final  List<ThemeInfo> themes, required final  List<String> ownedThemes, required this.selectedThemeId, required this.currentChapterThemeId, required this.reachedChapterNumber}): _skins = skins,_ownedSkins = ownedSkins,_themes = themes,_ownedThemes = ownedThemes,super._();
  

/// The segmented control's current tab.
@override final  ShopTab tab;
/// The coin pill (header) and the "You have N coins" lines.
@override final  int coins;
/// Sold skins only, in catalog order (`forest-bear` never appears,
/// D75).
 final  List<SkinInfo> _skins;
/// Sold skins only, in catalog order (`forest-bear` never appears,
/// D75).
@override List<SkinInfo> get skins {
  if (_skins is EqualUnmodifiableListView) return _skins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skins);
}

/// `SaveDocument.ownedSkins` (`classic` is always in it).
 final  List<String> _ownedSkins;
/// `SaveDocument.ownedSkins` (`classic` is always in it).
@override List<String> get ownedSkins {
  if (_ownedSkins is EqualUnmodifiableListView) return _ownedSkins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownedSkins);
}

/// The skin every board actually draws
/// ([SkinService.selectedSkinId]): the green-ring "Equipped" skin.
@override final  String selectedSkinId;
/// Every theme, in catalog (chapter) order.
 final  List<ThemeInfo> _themes;
/// Every theme, in catalog (chapter) order.
@override List<ThemeInfo> get themes {
  if (_themes is EqualUnmodifiableListView) return _themes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_themes);
}

/// `SaveDocument.ownedThemes` (bought early, or `ch01`).
 final  List<String> _ownedThemes;
/// `SaveDocument.ownedThemes` (bought early, or `ch01`).
@override List<String> get ownedThemes {
  if (_ownedThemes is EqualUnmodifiableListView) return _ownedThemes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownedThemes);
}

/// `SaveDocument.selectedTheme`: null means "Match each chapter".
@override final  String? selectedThemeId;
/// The theme of the chapter the player has reached (or the last
/// published one in Bonus Endless): what turning the toggle back on
/// picks, and what "Match each chapter" would show right now.
@override final  String currentChapterThemeId;
/// The reached chapter's number, for [ThemeInfo.isOwned].
@override final  int reachedChapterNumber;

/// Create a copy of ShopState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShopStateCopyWith<_ShopState> get copyWith => __$ShopStateCopyWithImpl<_ShopState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShopState&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.coins, coins) || other.coins == coins)&&const DeepCollectionEquality().equals(other._skins, _skins)&&const DeepCollectionEquality().equals(other._ownedSkins, _ownedSkins)&&(identical(other.selectedSkinId, selectedSkinId) || other.selectedSkinId == selectedSkinId)&&const DeepCollectionEquality().equals(other._themes, _themes)&&const DeepCollectionEquality().equals(other._ownedThemes, _ownedThemes)&&(identical(other.selectedThemeId, selectedThemeId) || other.selectedThemeId == selectedThemeId)&&(identical(other.currentChapterThemeId, currentChapterThemeId) || other.currentChapterThemeId == currentChapterThemeId)&&(identical(other.reachedChapterNumber, reachedChapterNumber) || other.reachedChapterNumber == reachedChapterNumber));
}


@override
int get hashCode => Object.hash(runtimeType,tab,coins,const DeepCollectionEquality().hash(_skins),const DeepCollectionEquality().hash(_ownedSkins),selectedSkinId,const DeepCollectionEquality().hash(_themes),const DeepCollectionEquality().hash(_ownedThemes),selectedThemeId,currentChapterThemeId,reachedChapterNumber);

@override
String toString() {
  return 'ShopState(tab: $tab, coins: $coins, skins: $skins, ownedSkins: $ownedSkins, selectedSkinId: $selectedSkinId, themes: $themes, ownedThemes: $ownedThemes, selectedThemeId: $selectedThemeId, currentChapterThemeId: $currentChapterThemeId, reachedChapterNumber: $reachedChapterNumber)';
}


}

/// @nodoc
abstract mixin class _$ShopStateCopyWith<$Res> implements $ShopStateCopyWith<$Res> {
  factory _$ShopStateCopyWith(_ShopState value, $Res Function(_ShopState) _then) = __$ShopStateCopyWithImpl;
@override @useResult
$Res call({
 ShopTab tab, int coins, List<SkinInfo> skins, List<String> ownedSkins, String selectedSkinId, List<ThemeInfo> themes, List<String> ownedThemes, String? selectedThemeId, String currentChapterThemeId, int reachedChapterNumber
});




}
/// @nodoc
class __$ShopStateCopyWithImpl<$Res>
    implements _$ShopStateCopyWith<$Res> {
  __$ShopStateCopyWithImpl(this._self, this._then);

  final _ShopState _self;
  final $Res Function(_ShopState) _then;

/// Create a copy of ShopState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tab = null,Object? coins = null,Object? skins = null,Object? ownedSkins = null,Object? selectedSkinId = null,Object? themes = null,Object? ownedThemes = null,Object? selectedThemeId = freezed,Object? currentChapterThemeId = null,Object? reachedChapterNumber = null,}) {
  return _then(_ShopState(
tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as ShopTab,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,skins: null == skins ? _self._skins : skins // ignore: cast_nullable_to_non_nullable
as List<SkinInfo>,ownedSkins: null == ownedSkins ? _self._ownedSkins : ownedSkins // ignore: cast_nullable_to_non_nullable
as List<String>,selectedSkinId: null == selectedSkinId ? _self.selectedSkinId : selectedSkinId // ignore: cast_nullable_to_non_nullable
as String,themes: null == themes ? _self._themes : themes // ignore: cast_nullable_to_non_nullable
as List<ThemeInfo>,ownedThemes: null == ownedThemes ? _self._ownedThemes : ownedThemes // ignore: cast_nullable_to_non_nullable
as List<String>,selectedThemeId: freezed == selectedThemeId ? _self.selectedThemeId : selectedThemeId // ignore: cast_nullable_to_non_nullable
as String?,currentChapterThemeId: null == currentChapterThemeId ? _self.currentChapterThemeId : currentChapterThemeId // ignore: cast_nullable_to_non_nullable
as String,reachedChapterNumber: null == reachedChapterNumber ? _self.reachedChapterNumber : reachedChapterNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
