// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FigurineInfo {

/// `classic` … `explorer`: the ARB select key.
 String get id;/// 1-based, the chapter it belongs to.
 int get number;/// The earned art, `assets/museum/NN-<id>.png` (synced from
/// `design/museum/png/` by `sync_design_assets`, m3-design §9.5).
 String get artAsset;/// The locked silhouette, `assets/museum/NN-<id>-locked.png`.
 String get lockedArtAsset;
/// Create a copy of FigurineInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FigurineInfoCopyWith<FigurineInfo> get copyWith => _$FigurineInfoCopyWithImpl<FigurineInfo>(this as FigurineInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FigurineInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.artAsset, artAsset) || other.artAsset == artAsset)&&(identical(other.lockedArtAsset, lockedArtAsset) || other.lockedArtAsset == lockedArtAsset));
}


@override
int get hashCode => Object.hash(runtimeType,id,number,artAsset,lockedArtAsset);

@override
String toString() {
  return 'FigurineInfo(id: $id, number: $number, artAsset: $artAsset, lockedArtAsset: $lockedArtAsset)';
}


}

/// @nodoc
abstract mixin class $FigurineInfoCopyWith<$Res>  {
  factory $FigurineInfoCopyWith(FigurineInfo value, $Res Function(FigurineInfo) _then) = _$FigurineInfoCopyWithImpl;
@useResult
$Res call({
 String id, int number, String artAsset, String lockedArtAsset
});




}
/// @nodoc
class _$FigurineInfoCopyWithImpl<$Res>
    implements $FigurineInfoCopyWith<$Res> {
  _$FigurineInfoCopyWithImpl(this._self, this._then);

  final FigurineInfo _self;
  final $Res Function(FigurineInfo) _then;

/// Create a copy of FigurineInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? artAsset = null,Object? lockedArtAsset = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,artAsset: null == artAsset ? _self.artAsset : artAsset // ignore: cast_nullable_to_non_nullable
as String,lockedArtAsset: null == lockedArtAsset ? _self.lockedArtAsset : lockedArtAsset // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FigurineInfo].
extension FigurineInfoPatterns on FigurineInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FigurineInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FigurineInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FigurineInfo value)  $default,){
final _that = this;
switch (_that) {
case _FigurineInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FigurineInfo value)?  $default,){
final _that = this;
switch (_that) {
case _FigurineInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  String artAsset,  String lockedArtAsset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FigurineInfo() when $default != null:
return $default(_that.id,_that.number,_that.artAsset,_that.lockedArtAsset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  String artAsset,  String lockedArtAsset)  $default,) {final _that = this;
switch (_that) {
case _FigurineInfo():
return $default(_that.id,_that.number,_that.artAsset,_that.lockedArtAsset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  String artAsset,  String lockedArtAsset)?  $default,) {final _that = this;
switch (_that) {
case _FigurineInfo() when $default != null:
return $default(_that.id,_that.number,_that.artAsset,_that.lockedArtAsset);case _:
  return null;

}
}

}

/// @nodoc


class _FigurineInfo implements FigurineInfo {
  const _FigurineInfo({required this.id, required this.number, required this.artAsset, required this.lockedArtAsset});
  

/// `classic` … `explorer`: the ARB select key.
@override final  String id;
/// 1-based, the chapter it belongs to.
@override final  int number;
/// The earned art, `assets/museum/NN-<id>.png` (synced from
/// `design/museum/png/` by `sync_design_assets`, m3-design §9.5).
@override final  String artAsset;
/// The locked silhouette, `assets/museum/NN-<id>-locked.png`.
@override final  String lockedArtAsset;

/// Create a copy of FigurineInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FigurineInfoCopyWith<_FigurineInfo> get copyWith => __$FigurineInfoCopyWithImpl<_FigurineInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FigurineInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.artAsset, artAsset) || other.artAsset == artAsset)&&(identical(other.lockedArtAsset, lockedArtAsset) || other.lockedArtAsset == lockedArtAsset));
}


@override
int get hashCode => Object.hash(runtimeType,id,number,artAsset,lockedArtAsset);

@override
String toString() {
  return 'FigurineInfo(id: $id, number: $number, artAsset: $artAsset, lockedArtAsset: $lockedArtAsset)';
}


}

/// @nodoc
abstract mixin class _$FigurineInfoCopyWith<$Res> implements $FigurineInfoCopyWith<$Res> {
  factory _$FigurineInfoCopyWith(_FigurineInfo value, $Res Function(_FigurineInfo) _then) = __$FigurineInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, String artAsset, String lockedArtAsset
});




}
/// @nodoc
class __$FigurineInfoCopyWithImpl<$Res>
    implements _$FigurineInfoCopyWith<$Res> {
  __$FigurineInfoCopyWithImpl(this._self, this._then);

  final _FigurineInfo _self;
  final $Res Function(_FigurineInfo) _then;

/// Create a copy of FigurineInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? artAsset = null,Object? lockedArtAsset = null,}) {
  return _then(_FigurineInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,artAsset: null == artAsset ? _self.artAsset : artAsset // ignore: cast_nullable_to_non_nullable
as String,lockedArtAsset: null == lockedArtAsset ? _self.lockedArtAsset : lockedArtAsset // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ChapterInfo {

/// The bundle's `chapterId`, `ch01` … `ch10`; also the `chapterName`
/// ARB select key (copy.md G.4 names ch07–ch10).
 String get id;/// 1-based.
 int get number;/// Its board theme: each launch chapter has its own (m7-3's ch07–ch10,
/// D171; `ChapterTheme.forChapter`).
 String get themeId;/// The figurine completing it awards.
 FigurineInfo get figurine;/// Levels per chapter (spec §7.1).
 int get levels;
/// Create a copy of ChapterInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChapterInfoCopyWith<ChapterInfo> get copyWith => _$ChapterInfoCopyWithImpl<ChapterInfo>(this as ChapterInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChapterInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.themeId, themeId) || other.themeId == themeId)&&(identical(other.figurine, figurine) || other.figurine == figurine)&&(identical(other.levels, levels) || other.levels == levels));
}


@override
int get hashCode => Object.hash(runtimeType,id,number,themeId,figurine,levels);

@override
String toString() {
  return 'ChapterInfo(id: $id, number: $number, themeId: $themeId, figurine: $figurine, levels: $levels)';
}


}

/// @nodoc
abstract mixin class $ChapterInfoCopyWith<$Res>  {
  factory $ChapterInfoCopyWith(ChapterInfo value, $Res Function(ChapterInfo) _then) = _$ChapterInfoCopyWithImpl;
@useResult
$Res call({
 String id, int number, String themeId, FigurineInfo figurine, int levels
});


$FigurineInfoCopyWith<$Res> get figurine;

}
/// @nodoc
class _$ChapterInfoCopyWithImpl<$Res>
    implements $ChapterInfoCopyWith<$Res> {
  _$ChapterInfoCopyWithImpl(this._self, this._then);

  final ChapterInfo _self;
  final $Res Function(ChapterInfo) _then;

/// Create a copy of ChapterInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? themeId = null,Object? figurine = null,Object? levels = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,themeId: null == themeId ? _self.themeId : themeId // ignore: cast_nullable_to_non_nullable
as String,figurine: null == figurine ? _self.figurine : figurine // ignore: cast_nullable_to_non_nullable
as FigurineInfo,levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ChapterInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FigurineInfoCopyWith<$Res> get figurine {
  
  return $FigurineInfoCopyWith<$Res>(_self.figurine, (value) {
    return _then(_self.copyWith(figurine: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChapterInfo].
extension ChapterInfoPatterns on ChapterInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChapterInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChapterInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChapterInfo value)  $default,){
final _that = this;
switch (_that) {
case _ChapterInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChapterInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ChapterInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  String themeId,  FigurineInfo figurine,  int levels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChapterInfo() when $default != null:
return $default(_that.id,_that.number,_that.themeId,_that.figurine,_that.levels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  String themeId,  FigurineInfo figurine,  int levels)  $default,) {final _that = this;
switch (_that) {
case _ChapterInfo():
return $default(_that.id,_that.number,_that.themeId,_that.figurine,_that.levels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  String themeId,  FigurineInfo figurine,  int levels)?  $default,) {final _that = this;
switch (_that) {
case _ChapterInfo() when $default != null:
return $default(_that.id,_that.number,_that.themeId,_that.figurine,_that.levels);case _:
  return null;

}
}

}

/// @nodoc


class _ChapterInfo implements ChapterInfo {
  const _ChapterInfo({required this.id, required this.number, required this.themeId, required this.figurine, this.levels = ChapterInfo.levelsPerChapter});
  

/// The bundle's `chapterId`, `ch01` … `ch10`; also the `chapterName`
/// ARB select key (copy.md G.4 names ch07–ch10).
@override final  String id;
/// 1-based.
@override final  int number;
/// Its board theme: each launch chapter has its own (m7-3's ch07–ch10,
/// D171; `ChapterTheme.forChapter`).
@override final  String themeId;
/// The figurine completing it awards.
@override final  FigurineInfo figurine;
/// Levels per chapter (spec §7.1).
@override@JsonKey() final  int levels;

/// Create a copy of ChapterInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChapterInfoCopyWith<_ChapterInfo> get copyWith => __$ChapterInfoCopyWithImpl<_ChapterInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChapterInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.themeId, themeId) || other.themeId == themeId)&&(identical(other.figurine, figurine) || other.figurine == figurine)&&(identical(other.levels, levels) || other.levels == levels));
}


@override
int get hashCode => Object.hash(runtimeType,id,number,themeId,figurine,levels);

@override
String toString() {
  return 'ChapterInfo(id: $id, number: $number, themeId: $themeId, figurine: $figurine, levels: $levels)';
}


}

/// @nodoc
abstract mixin class _$ChapterInfoCopyWith<$Res> implements $ChapterInfoCopyWith<$Res> {
  factory _$ChapterInfoCopyWith(_ChapterInfo value, $Res Function(_ChapterInfo) _then) = __$ChapterInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, String themeId, FigurineInfo figurine, int levels
});


@override $FigurineInfoCopyWith<$Res> get figurine;

}
/// @nodoc
class __$ChapterInfoCopyWithImpl<$Res>
    implements _$ChapterInfoCopyWith<$Res> {
  __$ChapterInfoCopyWithImpl(this._self, this._then);

  final _ChapterInfo _self;
  final $Res Function(_ChapterInfo) _then;

/// Create a copy of ChapterInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? themeId = null,Object? figurine = null,Object? levels = null,}) {
  return _then(_ChapterInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,themeId: null == themeId ? _self.themeId : themeId // ignore: cast_nullable_to_non_nullable
as String,figurine: null == figurine ? _self.figurine : figurine // ignore: cast_nullable_to_non_nullable
as FigurineInfo,levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ChapterInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FigurineInfoCopyWith<$Res> get figurine {
  
  return $FigurineInfoCopyWith<$Res>(_self.figurine, (value) {
    return _then(_self.copyWith(figurine: value));
  });
}
}

/// @nodoc
mixin _$SkinInfo {

/// The skin folder under `assets/skins/` and the save's id.
 String get id;/// Coins to buy it; 0 for the bundled Classic every player owns.
 int get priceCoins;/// The three dolls on its Shop card, left to right (frame 7.3).
 List<DollColor> get previewColors;/// False for a skin that ships but isn't offered (`forest-bear`).
 bool get sold;
/// Create a copy of SkinInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkinInfoCopyWith<SkinInfo> get copyWith => _$SkinInfoCopyWithImpl<SkinInfo>(this as SkinInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkinInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.priceCoins, priceCoins) || other.priceCoins == priceCoins)&&const DeepCollectionEquality().equals(other.previewColors, previewColors)&&(identical(other.sold, sold) || other.sold == sold));
}


@override
int get hashCode => Object.hash(runtimeType,id,priceCoins,const DeepCollectionEquality().hash(previewColors),sold);

@override
String toString() {
  return 'SkinInfo(id: $id, priceCoins: $priceCoins, previewColors: $previewColors, sold: $sold)';
}


}

/// @nodoc
abstract mixin class $SkinInfoCopyWith<$Res>  {
  factory $SkinInfoCopyWith(SkinInfo value, $Res Function(SkinInfo) _then) = _$SkinInfoCopyWithImpl;
@useResult
$Res call({
 String id, int priceCoins, List<DollColor> previewColors, bool sold
});




}
/// @nodoc
class _$SkinInfoCopyWithImpl<$Res>
    implements $SkinInfoCopyWith<$Res> {
  _$SkinInfoCopyWithImpl(this._self, this._then);

  final SkinInfo _self;
  final $Res Function(SkinInfo) _then;

/// Create a copy of SkinInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? priceCoins = null,Object? previewColors = null,Object? sold = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,priceCoins: null == priceCoins ? _self.priceCoins : priceCoins // ignore: cast_nullable_to_non_nullable
as int,previewColors: null == previewColors ? _self.previewColors : previewColors // ignore: cast_nullable_to_non_nullable
as List<DollColor>,sold: null == sold ? _self.sold : sold // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SkinInfo].
extension SkinInfoPatterns on SkinInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SkinInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SkinInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SkinInfo value)  $default,){
final _that = this;
switch (_that) {
case _SkinInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SkinInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SkinInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int priceCoins,  List<DollColor> previewColors,  bool sold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SkinInfo() when $default != null:
return $default(_that.id,_that.priceCoins,_that.previewColors,_that.sold);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int priceCoins,  List<DollColor> previewColors,  bool sold)  $default,) {final _that = this;
switch (_that) {
case _SkinInfo():
return $default(_that.id,_that.priceCoins,_that.previewColors,_that.sold);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int priceCoins,  List<DollColor> previewColors,  bool sold)?  $default,) {final _that = this;
switch (_that) {
case _SkinInfo() when $default != null:
return $default(_that.id,_that.priceCoins,_that.previewColors,_that.sold);case _:
  return null;

}
}

}

/// @nodoc


class _SkinInfo implements SkinInfo {
  const _SkinInfo({required this.id, required this.priceCoins, required final  List<DollColor> previewColors, this.sold = true}): _previewColors = previewColors;
  

/// The skin folder under `assets/skins/` and the save's id.
@override final  String id;
/// Coins to buy it; 0 for the bundled Classic every player owns.
@override final  int priceCoins;
/// The three dolls on its Shop card, left to right (frame 7.3).
 final  List<DollColor> _previewColors;
/// The three dolls on its Shop card, left to right (frame 7.3).
@override List<DollColor> get previewColors {
  if (_previewColors is EqualUnmodifiableListView) return _previewColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_previewColors);
}

/// False for a skin that ships but isn't offered (`forest-bear`).
@override@JsonKey() final  bool sold;

/// Create a copy of SkinInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SkinInfoCopyWith<_SkinInfo> get copyWith => __$SkinInfoCopyWithImpl<_SkinInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SkinInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.priceCoins, priceCoins) || other.priceCoins == priceCoins)&&const DeepCollectionEquality().equals(other._previewColors, _previewColors)&&(identical(other.sold, sold) || other.sold == sold));
}


@override
int get hashCode => Object.hash(runtimeType,id,priceCoins,const DeepCollectionEquality().hash(_previewColors),sold);

@override
String toString() {
  return 'SkinInfo(id: $id, priceCoins: $priceCoins, previewColors: $previewColors, sold: $sold)';
}


}

/// @nodoc
abstract mixin class _$SkinInfoCopyWith<$Res> implements $SkinInfoCopyWith<$Res> {
  factory _$SkinInfoCopyWith(_SkinInfo value, $Res Function(_SkinInfo) _then) = __$SkinInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, int priceCoins, List<DollColor> previewColors, bool sold
});




}
/// @nodoc
class __$SkinInfoCopyWithImpl<$Res>
    implements _$SkinInfoCopyWith<$Res> {
  __$SkinInfoCopyWithImpl(this._self, this._then);

  final _SkinInfo _self;
  final $Res Function(_SkinInfo) _then;

/// Create a copy of SkinInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? priceCoins = null,Object? previewColors = null,Object? sold = null,}) {
  return _then(_SkinInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,priceCoins: null == priceCoins ? _self.priceCoins : priceCoins // ignore: cast_nullable_to_non_nullable
as int,previewColors: null == previewColors ? _self._previewColors : previewColors // ignore: cast_nullable_to_non_nullable
as List<DollColor>,sold: null == sold ? _self.sold : sold // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ThemeInfo {

/// `ch01` … `ch06`: `ChapterTheme.byId`, and the `chapterName` select
/// key for its name.
 String get id;/// The chapter it was drawn for. Reaching that chapter unlocks it
/// (frame 7.7: "Chapter themes unlock with their chapter and can then
/// be used anywhere. Later ones can be bought early.").
 int get chapterNumber;/// Coins to buy it before its chapter; 0 for ch01.
 int get priceCoins;
/// Create a copy of ThemeInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeInfoCopyWith<ThemeInfo> get copyWith => _$ThemeInfoCopyWithImpl<ThemeInfo>(this as ThemeInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.chapterNumber, chapterNumber) || other.chapterNumber == chapterNumber)&&(identical(other.priceCoins, priceCoins) || other.priceCoins == priceCoins));
}


@override
int get hashCode => Object.hash(runtimeType,id,chapterNumber,priceCoins);

@override
String toString() {
  return 'ThemeInfo(id: $id, chapterNumber: $chapterNumber, priceCoins: $priceCoins)';
}


}

/// @nodoc
abstract mixin class $ThemeInfoCopyWith<$Res>  {
  factory $ThemeInfoCopyWith(ThemeInfo value, $Res Function(ThemeInfo) _then) = _$ThemeInfoCopyWithImpl;
@useResult
$Res call({
 String id, int chapterNumber, int priceCoins
});




}
/// @nodoc
class _$ThemeInfoCopyWithImpl<$Res>
    implements $ThemeInfoCopyWith<$Res> {
  _$ThemeInfoCopyWithImpl(this._self, this._then);

  final ThemeInfo _self;
  final $Res Function(ThemeInfo) _then;

/// Create a copy of ThemeInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chapterNumber = null,Object? priceCoins = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chapterNumber: null == chapterNumber ? _self.chapterNumber : chapterNumber // ignore: cast_nullable_to_non_nullable
as int,priceCoins: null == priceCoins ? _self.priceCoins : priceCoins // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemeInfo].
extension ThemeInfoPatterns on ThemeInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeInfo value)  $default,){
final _that = this;
switch (_that) {
case _ThemeInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int chapterNumber,  int priceCoins)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeInfo() when $default != null:
return $default(_that.id,_that.chapterNumber,_that.priceCoins);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int chapterNumber,  int priceCoins)  $default,) {final _that = this;
switch (_that) {
case _ThemeInfo():
return $default(_that.id,_that.chapterNumber,_that.priceCoins);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int chapterNumber,  int priceCoins)?  $default,) {final _that = this;
switch (_that) {
case _ThemeInfo() when $default != null:
return $default(_that.id,_that.chapterNumber,_that.priceCoins);case _:
  return null;

}
}

}

/// @nodoc


class _ThemeInfo extends ThemeInfo {
  const _ThemeInfo({required this.id, required this.chapterNumber, required this.priceCoins}): super._();
  

/// `ch01` … `ch06`: `ChapterTheme.byId`, and the `chapterName` select
/// key for its name.
@override final  String id;
/// The chapter it was drawn for. Reaching that chapter unlocks it
/// (frame 7.7: "Chapter themes unlock with their chapter and can then
/// be used anywhere. Later ones can be bought early.").
@override final  int chapterNumber;
/// Coins to buy it before its chapter; 0 for ch01.
@override final  int priceCoins;

/// Create a copy of ThemeInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemeInfoCopyWith<_ThemeInfo> get copyWith => __$ThemeInfoCopyWithImpl<_ThemeInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.chapterNumber, chapterNumber) || other.chapterNumber == chapterNumber)&&(identical(other.priceCoins, priceCoins) || other.priceCoins == priceCoins));
}


@override
int get hashCode => Object.hash(runtimeType,id,chapterNumber,priceCoins);

@override
String toString() {
  return 'ThemeInfo(id: $id, chapterNumber: $chapterNumber, priceCoins: $priceCoins)';
}


}

/// @nodoc
abstract mixin class _$ThemeInfoCopyWith<$Res> implements $ThemeInfoCopyWith<$Res> {
  factory _$ThemeInfoCopyWith(_ThemeInfo value, $Res Function(_ThemeInfo) _then) = __$ThemeInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, int chapterNumber, int priceCoins
});




}
/// @nodoc
class __$ThemeInfoCopyWithImpl<$Res>
    implements _$ThemeInfoCopyWith<$Res> {
  __$ThemeInfoCopyWithImpl(this._self, this._then);

  final _ThemeInfo _self;
  final $Res Function(_ThemeInfo) _then;

/// Create a copy of ThemeInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chapterNumber = null,Object? priceCoins = null,}) {
  return _then(_ThemeInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chapterNumber: null == chapterNumber ? _self.chapterNumber : chapterNumber // ignore: cast_nullable_to_non_nullable
as int,priceCoins: null == priceCoins ? _self.priceCoins : priceCoins // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
