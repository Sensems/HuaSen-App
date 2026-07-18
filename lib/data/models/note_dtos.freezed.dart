// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateNoteDto {

 String? get title; String? get content; NoteSource? get source; String? get categoryId; List<String>? get tagIds; List<String>? get mediaIds;
/// Create a copy of CreateNoteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateNoteDtoCopyWith<CreateNoteDto> get copyWith => _$CreateNoteDtoCopyWithImpl<CreateNoteDto>(this as CreateNoteDto, _$identity);

  /// Serializes this CreateNoteDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateNoteDto&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.source, source) || other.source == source)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other.tagIds, tagIds)&&const DeepCollectionEquality().equals(other.mediaIds, mediaIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,content,source,categoryId,const DeepCollectionEquality().hash(tagIds),const DeepCollectionEquality().hash(mediaIds));

@override
String toString() {
  return 'CreateNoteDto(title: $title, content: $content, source: $source, categoryId: $categoryId, tagIds: $tagIds, mediaIds: $mediaIds)';
}


}

/// @nodoc
abstract mixin class $CreateNoteDtoCopyWith<$Res>  {
  factory $CreateNoteDtoCopyWith(CreateNoteDto value, $Res Function(CreateNoteDto) _then) = _$CreateNoteDtoCopyWithImpl;
@useResult
$Res call({
 String? title, String? content, NoteSource? source, String? categoryId, List<String>? tagIds, List<String>? mediaIds
});




}
/// @nodoc
class _$CreateNoteDtoCopyWithImpl<$Res>
    implements $CreateNoteDtoCopyWith<$Res> {
  _$CreateNoteDtoCopyWithImpl(this._self, this._then);

  final CreateNoteDto _self;
  final $Res Function(CreateNoteDto) _then;

/// Create a copy of CreateNoteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? content = freezed,Object? source = freezed,Object? categoryId = freezed,Object? tagIds = freezed,Object? mediaIds = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as NoteSource?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,tagIds: freezed == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>?,mediaIds: freezed == mediaIds ? _self.mediaIds : mediaIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateNoteDto].
extension CreateNoteDtoPatterns on CreateNoteDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateNoteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateNoteDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateNoteDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateNoteDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateNoteDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateNoteDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? content,  NoteSource? source,  String? categoryId,  List<String>? tagIds,  List<String>? mediaIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateNoteDto() when $default != null:
return $default(_that.title,_that.content,_that.source,_that.categoryId,_that.tagIds,_that.mediaIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? content,  NoteSource? source,  String? categoryId,  List<String>? tagIds,  List<String>? mediaIds)  $default,) {final _that = this;
switch (_that) {
case _CreateNoteDto():
return $default(_that.title,_that.content,_that.source,_that.categoryId,_that.tagIds,_that.mediaIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? content,  NoteSource? source,  String? categoryId,  List<String>? tagIds,  List<String>? mediaIds)?  $default,) {final _that = this;
switch (_that) {
case _CreateNoteDto() when $default != null:
return $default(_that.title,_that.content,_that.source,_that.categoryId,_that.tagIds,_that.mediaIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateNoteDto implements CreateNoteDto {
  const _CreateNoteDto({this.title, this.content, this.source, this.categoryId, final  List<String>? tagIds, final  List<String>? mediaIds}): _tagIds = tagIds,_mediaIds = mediaIds;
  factory _CreateNoteDto.fromJson(Map<String, dynamic> json) => _$CreateNoteDtoFromJson(json);

@override final  String? title;
@override final  String? content;
@override final  NoteSource? source;
@override final  String? categoryId;
 final  List<String>? _tagIds;
@override List<String>? get tagIds {
  final value = _tagIds;
  if (value == null) return null;
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _mediaIds;
@override List<String>? get mediaIds {
  final value = _mediaIds;
  if (value == null) return null;
  if (_mediaIds is EqualUnmodifiableListView) return _mediaIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CreateNoteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateNoteDtoCopyWith<_CreateNoteDto> get copyWith => __$CreateNoteDtoCopyWithImpl<_CreateNoteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateNoteDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateNoteDto&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.source, source) || other.source == source)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds)&&const DeepCollectionEquality().equals(other._mediaIds, _mediaIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,content,source,categoryId,const DeepCollectionEquality().hash(_tagIds),const DeepCollectionEquality().hash(_mediaIds));

@override
String toString() {
  return 'CreateNoteDto(title: $title, content: $content, source: $source, categoryId: $categoryId, tagIds: $tagIds, mediaIds: $mediaIds)';
}


}

/// @nodoc
abstract mixin class _$CreateNoteDtoCopyWith<$Res> implements $CreateNoteDtoCopyWith<$Res> {
  factory _$CreateNoteDtoCopyWith(_CreateNoteDto value, $Res Function(_CreateNoteDto) _then) = __$CreateNoteDtoCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? content, NoteSource? source, String? categoryId, List<String>? tagIds, List<String>? mediaIds
});




}
/// @nodoc
class __$CreateNoteDtoCopyWithImpl<$Res>
    implements _$CreateNoteDtoCopyWith<$Res> {
  __$CreateNoteDtoCopyWithImpl(this._self, this._then);

  final _CreateNoteDto _self;
  final $Res Function(_CreateNoteDto) _then;

/// Create a copy of CreateNoteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? content = freezed,Object? source = freezed,Object? categoryId = freezed,Object? tagIds = freezed,Object? mediaIds = freezed,}) {
  return _then(_CreateNoteDto(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as NoteSource?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,tagIds: freezed == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>?,mediaIds: freezed == mediaIds ? _self._mediaIds : mediaIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}


/// @nodoc
mixin _$UpdateNoteDto {

 String get id; String? get title; String? get content; String? get categoryId; List<String>? get tagIds; List<String>? get mediaIds;
/// Create a copy of UpdateNoteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateNoteDtoCopyWith<UpdateNoteDto> get copyWith => _$UpdateNoteDtoCopyWithImpl<UpdateNoteDto>(this as UpdateNoteDto, _$identity);

  /// Serializes this UpdateNoteDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateNoteDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other.tagIds, tagIds)&&const DeepCollectionEquality().equals(other.mediaIds, mediaIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,content,categoryId,const DeepCollectionEquality().hash(tagIds),const DeepCollectionEquality().hash(mediaIds));

@override
String toString() {
  return 'UpdateNoteDto(id: $id, title: $title, content: $content, categoryId: $categoryId, tagIds: $tagIds, mediaIds: $mediaIds)';
}


}

/// @nodoc
abstract mixin class $UpdateNoteDtoCopyWith<$Res>  {
  factory $UpdateNoteDtoCopyWith(UpdateNoteDto value, $Res Function(UpdateNoteDto) _then) = _$UpdateNoteDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? content, String? categoryId, List<String>? tagIds, List<String>? mediaIds
});




}
/// @nodoc
class _$UpdateNoteDtoCopyWithImpl<$Res>
    implements $UpdateNoteDtoCopyWith<$Res> {
  _$UpdateNoteDtoCopyWithImpl(this._self, this._then);

  final UpdateNoteDto _self;
  final $Res Function(UpdateNoteDto) _then;

/// Create a copy of UpdateNoteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? content = freezed,Object? categoryId = freezed,Object? tagIds = freezed,Object? mediaIds = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,tagIds: freezed == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>?,mediaIds: freezed == mediaIds ? _self.mediaIds : mediaIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateNoteDto].
extension UpdateNoteDtoPatterns on UpdateNoteDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateNoteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateNoteDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateNoteDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateNoteDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateNoteDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateNoteDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? content,  String? categoryId,  List<String>? tagIds,  List<String>? mediaIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateNoteDto() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.categoryId,_that.tagIds,_that.mediaIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? content,  String? categoryId,  List<String>? tagIds,  List<String>? mediaIds)  $default,) {final _that = this;
switch (_that) {
case _UpdateNoteDto():
return $default(_that.id,_that.title,_that.content,_that.categoryId,_that.tagIds,_that.mediaIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? content,  String? categoryId,  List<String>? tagIds,  List<String>? mediaIds)?  $default,) {final _that = this;
switch (_that) {
case _UpdateNoteDto() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.categoryId,_that.tagIds,_that.mediaIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateNoteDto implements UpdateNoteDto {
  const _UpdateNoteDto({required this.id, this.title, this.content, this.categoryId, final  List<String>? tagIds, final  List<String>? mediaIds}): _tagIds = tagIds,_mediaIds = mediaIds;
  factory _UpdateNoteDto.fromJson(Map<String, dynamic> json) => _$UpdateNoteDtoFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String? content;
@override final  String? categoryId;
 final  List<String>? _tagIds;
@override List<String>? get tagIds {
  final value = _tagIds;
  if (value == null) return null;
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _mediaIds;
@override List<String>? get mediaIds {
  final value = _mediaIds;
  if (value == null) return null;
  if (_mediaIds is EqualUnmodifiableListView) return _mediaIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of UpdateNoteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateNoteDtoCopyWith<_UpdateNoteDto> get copyWith => __$UpdateNoteDtoCopyWithImpl<_UpdateNoteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateNoteDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateNoteDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds)&&const DeepCollectionEquality().equals(other._mediaIds, _mediaIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,content,categoryId,const DeepCollectionEquality().hash(_tagIds),const DeepCollectionEquality().hash(_mediaIds));

@override
String toString() {
  return 'UpdateNoteDto(id: $id, title: $title, content: $content, categoryId: $categoryId, tagIds: $tagIds, mediaIds: $mediaIds)';
}


}

/// @nodoc
abstract mixin class _$UpdateNoteDtoCopyWith<$Res> implements $UpdateNoteDtoCopyWith<$Res> {
  factory _$UpdateNoteDtoCopyWith(_UpdateNoteDto value, $Res Function(_UpdateNoteDto) _then) = __$UpdateNoteDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? content, String? categoryId, List<String>? tagIds, List<String>? mediaIds
});




}
/// @nodoc
class __$UpdateNoteDtoCopyWithImpl<$Res>
    implements _$UpdateNoteDtoCopyWith<$Res> {
  __$UpdateNoteDtoCopyWithImpl(this._self, this._then);

  final _UpdateNoteDto _self;
  final $Res Function(_UpdateNoteDto) _then;

/// Create a copy of UpdateNoteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? content = freezed,Object? categoryId = freezed,Object? tagIds = freezed,Object? mediaIds = freezed,}) {
  return _then(_UpdateNoteDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,tagIds: freezed == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>?,mediaIds: freezed == mediaIds ? _self._mediaIds : mediaIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}


/// @nodoc
mixin _$NoteMetaDto {

@JsonKey(name: 'media_url') String? get mediaUrl;@JsonKey(name: 'media_type') String? get mediaType;
/// Create a copy of NoteMetaDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteMetaDtoCopyWith<NoteMetaDto> get copyWith => _$NoteMetaDtoCopyWithImpl<NoteMetaDto>(this as NoteMetaDto, _$identity);

  /// Serializes this NoteMetaDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteMetaDto&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaUrl,mediaType);

@override
String toString() {
  return 'NoteMetaDto(mediaUrl: $mediaUrl, mediaType: $mediaType)';
}


}

/// @nodoc
abstract mixin class $NoteMetaDtoCopyWith<$Res>  {
  factory $NoteMetaDtoCopyWith(NoteMetaDto value, $Res Function(NoteMetaDto) _then) = _$NoteMetaDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'media_url') String? mediaUrl,@JsonKey(name: 'media_type') String? mediaType
});




}
/// @nodoc
class _$NoteMetaDtoCopyWithImpl<$Res>
    implements $NoteMetaDtoCopyWith<$Res> {
  _$NoteMetaDtoCopyWithImpl(this._self, this._then);

  final NoteMetaDto _self;
  final $Res Function(NoteMetaDto) _then;

/// Create a copy of NoteMetaDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaUrl = freezed,Object? mediaType = freezed,}) {
  return _then(_self.copyWith(
mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteMetaDto].
extension NoteMetaDtoPatterns on NoteMetaDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteMetaDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteMetaDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteMetaDto value)  $default,){
final _that = this;
switch (_that) {
case _NoteMetaDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteMetaDto value)?  $default,){
final _that = this;
switch (_that) {
case _NoteMetaDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'media_url')  String? mediaUrl, @JsonKey(name: 'media_type')  String? mediaType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteMetaDto() when $default != null:
return $default(_that.mediaUrl,_that.mediaType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'media_url')  String? mediaUrl, @JsonKey(name: 'media_type')  String? mediaType)  $default,) {final _that = this;
switch (_that) {
case _NoteMetaDto():
return $default(_that.mediaUrl,_that.mediaType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'media_url')  String? mediaUrl, @JsonKey(name: 'media_type')  String? mediaType)?  $default,) {final _that = this;
switch (_that) {
case _NoteMetaDto() when $default != null:
return $default(_that.mediaUrl,_that.mediaType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NoteMetaDto implements NoteMetaDto {
  const _NoteMetaDto({@JsonKey(name: 'media_url') this.mediaUrl, @JsonKey(name: 'media_type') this.mediaType});
  factory _NoteMetaDto.fromJson(Map<String, dynamic> json) => _$NoteMetaDtoFromJson(json);

@override@JsonKey(name: 'media_url') final  String? mediaUrl;
@override@JsonKey(name: 'media_type') final  String? mediaType;

/// Create a copy of NoteMetaDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteMetaDtoCopyWith<_NoteMetaDto> get copyWith => __$NoteMetaDtoCopyWithImpl<_NoteMetaDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoteMetaDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteMetaDto&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaUrl,mediaType);

@override
String toString() {
  return 'NoteMetaDto(mediaUrl: $mediaUrl, mediaType: $mediaType)';
}


}

/// @nodoc
abstract mixin class _$NoteMetaDtoCopyWith<$Res> implements $NoteMetaDtoCopyWith<$Res> {
  factory _$NoteMetaDtoCopyWith(_NoteMetaDto value, $Res Function(_NoteMetaDto) _then) = __$NoteMetaDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'media_url') String? mediaUrl,@JsonKey(name: 'media_type') String? mediaType
});




}
/// @nodoc
class __$NoteMetaDtoCopyWithImpl<$Res>
    implements _$NoteMetaDtoCopyWith<$Res> {
  __$NoteMetaDtoCopyWithImpl(this._self, this._then);

  final _NoteMetaDto _self;
  final $Res Function(_NoteMetaDto) _then;

/// Create a copy of NoteMetaDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaUrl = freezed,Object? mediaType = freezed,}) {
  return _then(_NoteMetaDto(
mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$NoteDetailDto {

 String get id; String? get title; String? get content; NoteSource? get source; String? get type; String? get categoryId; List<String>? get tagIds; List<String>? get mediaIds; NoteMetaDto? get meta;@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) DateTime? get pinnedAt;@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) DateTime? get createdAt;@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) DateTime? get updatedAt;
/// Create a copy of NoteDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteDetailDtoCopyWith<NoteDetailDto> get copyWith => _$NoteDetailDtoCopyWithImpl<NoteDetailDto>(this as NoteDetailDto, _$identity);

  /// Serializes this NoteDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.source, source) || other.source == source)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other.tagIds, tagIds)&&const DeepCollectionEquality().equals(other.mediaIds, mediaIds)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.pinnedAt, pinnedAt) || other.pinnedAt == pinnedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,content,source,type,categoryId,const DeepCollectionEquality().hash(tagIds),const DeepCollectionEquality().hash(mediaIds),meta,pinnedAt,createdAt,updatedAt);

@override
String toString() {
  return 'NoteDetailDto(id: $id, title: $title, content: $content, source: $source, type: $type, categoryId: $categoryId, tagIds: $tagIds, mediaIds: $mediaIds, meta: $meta, pinnedAt: $pinnedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NoteDetailDtoCopyWith<$Res>  {
  factory $NoteDetailDtoCopyWith(NoteDetailDto value, $Res Function(NoteDetailDto) _then) = _$NoteDetailDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? content, NoteSource? source, String? type, String? categoryId, List<String>? tagIds, List<String>? mediaIds, NoteMetaDto? meta,@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) DateTime? pinnedAt,@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) DateTime? createdAt,@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) DateTime? updatedAt
});


$NoteMetaDtoCopyWith<$Res>? get meta;

}
/// @nodoc
class _$NoteDetailDtoCopyWithImpl<$Res>
    implements $NoteDetailDtoCopyWith<$Res> {
  _$NoteDetailDtoCopyWithImpl(this._self, this._then);

  final NoteDetailDto _self;
  final $Res Function(NoteDetailDto) _then;

/// Create a copy of NoteDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? content = freezed,Object? source = freezed,Object? type = freezed,Object? categoryId = freezed,Object? tagIds = freezed,Object? mediaIds = freezed,Object? meta = freezed,Object? pinnedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as NoteSource?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,tagIds: freezed == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>?,mediaIds: freezed == mediaIds ? _self.mediaIds : mediaIds // ignore: cast_nullable_to_non_nullable
as List<String>?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as NoteMetaDto?,pinnedAt: freezed == pinnedAt ? _self.pinnedAt : pinnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of NoteDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteMetaDtoCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $NoteMetaDtoCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [NoteDetailDto].
extension NoteDetailDtoPatterns on NoteDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _NoteDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _NoteDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? content,  NoteSource? source,  String? type,  String? categoryId,  List<String>? tagIds,  List<String>? mediaIds,  NoteMetaDto? meta, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)  DateTime? pinnedAt, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)  DateTime? createdAt, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteDetailDto() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.source,_that.type,_that.categoryId,_that.tagIds,_that.mediaIds,_that.meta,_that.pinnedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? content,  NoteSource? source,  String? type,  String? categoryId,  List<String>? tagIds,  List<String>? mediaIds,  NoteMetaDto? meta, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)  DateTime? pinnedAt, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)  DateTime? createdAt, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NoteDetailDto():
return $default(_that.id,_that.title,_that.content,_that.source,_that.type,_that.categoryId,_that.tagIds,_that.mediaIds,_that.meta,_that.pinnedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? content,  NoteSource? source,  String? type,  String? categoryId,  List<String>? tagIds,  List<String>? mediaIds,  NoteMetaDto? meta, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)  DateTime? pinnedAt, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)  DateTime? createdAt, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NoteDetailDto() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.source,_that.type,_that.categoryId,_that.tagIds,_that.mediaIds,_that.meta,_that.pinnedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NoteDetailDto implements NoteDetailDto {
  const _NoteDetailDto({required this.id, this.title, this.content, this.source, this.type, this.categoryId, final  List<String>? tagIds, final  List<String>? mediaIds, this.meta, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) this.pinnedAt, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) this.createdAt, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) this.updatedAt}): _tagIds = tagIds,_mediaIds = mediaIds;
  factory _NoteDetailDto.fromJson(Map<String, dynamic> json) => _$NoteDetailDtoFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String? content;
@override final  NoteSource? source;
@override final  String? type;
@override final  String? categoryId;
 final  List<String>? _tagIds;
@override List<String>? get tagIds {
  final value = _tagIds;
  if (value == null) return null;
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _mediaIds;
@override List<String>? get mediaIds {
  final value = _mediaIds;
  if (value == null) return null;
  if (_mediaIds is EqualUnmodifiableListView) return _mediaIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  NoteMetaDto? meta;
@override@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) final  DateTime? pinnedAt;
@override@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) final  DateTime? createdAt;
@override@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) final  DateTime? updatedAt;

/// Create a copy of NoteDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteDetailDtoCopyWith<_NoteDetailDto> get copyWith => __$NoteDetailDtoCopyWithImpl<_NoteDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoteDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.source, source) || other.source == source)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds)&&const DeepCollectionEquality().equals(other._mediaIds, _mediaIds)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.pinnedAt, pinnedAt) || other.pinnedAt == pinnedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,content,source,type,categoryId,const DeepCollectionEquality().hash(_tagIds),const DeepCollectionEquality().hash(_mediaIds),meta,pinnedAt,createdAt,updatedAt);

@override
String toString() {
  return 'NoteDetailDto(id: $id, title: $title, content: $content, source: $source, type: $type, categoryId: $categoryId, tagIds: $tagIds, mediaIds: $mediaIds, meta: $meta, pinnedAt: $pinnedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NoteDetailDtoCopyWith<$Res> implements $NoteDetailDtoCopyWith<$Res> {
  factory _$NoteDetailDtoCopyWith(_NoteDetailDto value, $Res Function(_NoteDetailDto) _then) = __$NoteDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? content, NoteSource? source, String? type, String? categoryId, List<String>? tagIds, List<String>? mediaIds, NoteMetaDto? meta,@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) DateTime? pinnedAt,@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) DateTime? createdAt,@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) DateTime? updatedAt
});


@override $NoteMetaDtoCopyWith<$Res>? get meta;

}
/// @nodoc
class __$NoteDetailDtoCopyWithImpl<$Res>
    implements _$NoteDetailDtoCopyWith<$Res> {
  __$NoteDetailDtoCopyWithImpl(this._self, this._then);

  final _NoteDetailDto _self;
  final $Res Function(_NoteDetailDto) _then;

/// Create a copy of NoteDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? content = freezed,Object? source = freezed,Object? type = freezed,Object? categoryId = freezed,Object? tagIds = freezed,Object? mediaIds = freezed,Object? meta = freezed,Object? pinnedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_NoteDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as NoteSource?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,tagIds: freezed == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>?,mediaIds: freezed == mediaIds ? _self._mediaIds : mediaIds // ignore: cast_nullable_to_non_nullable
as List<String>?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as NoteMetaDto?,pinnedAt: freezed == pinnedAt ? _self.pinnedAt : pinnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of NoteDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteMetaDtoCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $NoteMetaDtoCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// @nodoc
mixin _$PaginatedNotes {

 List<NoteDetailDto> get items; int get total; int get page; int get size;
/// Create a copy of PaginatedNotes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedNotesCopyWith<PaginatedNotes> get copyWith => _$PaginatedNotesCopyWithImpl<PaginatedNotes>(this as PaginatedNotes, _$identity);

  /// Serializes this PaginatedNotes to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedNotes&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,page,size);

@override
String toString() {
  return 'PaginatedNotes(items: $items, total: $total, page: $page, size: $size)';
}


}

/// @nodoc
abstract mixin class $PaginatedNotesCopyWith<$Res>  {
  factory $PaginatedNotesCopyWith(PaginatedNotes value, $Res Function(PaginatedNotes) _then) = _$PaginatedNotesCopyWithImpl;
@useResult
$Res call({
 List<NoteDetailDto> items, int total, int page, int size
});




}
/// @nodoc
class _$PaginatedNotesCopyWithImpl<$Res>
    implements $PaginatedNotesCopyWith<$Res> {
  _$PaginatedNotesCopyWithImpl(this._self, this._then);

  final PaginatedNotes _self;
  final $Res Function(PaginatedNotes) _then;

/// Create a copy of PaginatedNotes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? size = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<NoteDetailDto>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedNotes].
extension PaginatedNotesPatterns on PaginatedNotes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedNotes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedNotes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedNotes value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedNotes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedNotes value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedNotes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NoteDetailDto> items,  int total,  int page,  int size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedNotes() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NoteDetailDto> items,  int total,  int page,  int size)  $default,) {final _that = this;
switch (_that) {
case _PaginatedNotes():
return $default(_that.items,_that.total,_that.page,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NoteDetailDto> items,  int total,  int page,  int size)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedNotes() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.size);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedNotes implements PaginatedNotes {
  const _PaginatedNotes({required final  List<NoteDetailDto> items, required this.total, required this.page, required this.size}): _items = items;
  factory _PaginatedNotes.fromJson(Map<String, dynamic> json) => _$PaginatedNotesFromJson(json);

 final  List<NoteDetailDto> _items;
@override List<NoteDetailDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override final  int page;
@override final  int size;

/// Create a copy of PaginatedNotes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedNotesCopyWith<_PaginatedNotes> get copyWith => __$PaginatedNotesCopyWithImpl<_PaginatedNotes>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedNotesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedNotes&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page,size);

@override
String toString() {
  return 'PaginatedNotes(items: $items, total: $total, page: $page, size: $size)';
}


}

/// @nodoc
abstract mixin class _$PaginatedNotesCopyWith<$Res> implements $PaginatedNotesCopyWith<$Res> {
  factory _$PaginatedNotesCopyWith(_PaginatedNotes value, $Res Function(_PaginatedNotes) _then) = __$PaginatedNotesCopyWithImpl;
@override @useResult
$Res call({
 List<NoteDetailDto> items, int total, int page, int size
});




}
/// @nodoc
class __$PaginatedNotesCopyWithImpl<$Res>
    implements _$PaginatedNotesCopyWith<$Res> {
  __$PaginatedNotesCopyWithImpl(this._self, this._then);

  final _PaginatedNotes _self;
  final $Res Function(_PaginatedNotes) _then;

/// Create a copy of PaginatedNotes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? size = null,}) {
  return _then(_PaginatedNotes(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<NoteDetailDto>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ShareInfoDto {

 String get id; String get title; String? get type; String get shareUrl;
/// Create a copy of ShareInfoDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareInfoDtoCopyWith<ShareInfoDto> get copyWith => _$ShareInfoDtoCopyWithImpl<ShareInfoDto>(this as ShareInfoDto, _$identity);

  /// Serializes this ShareInfoDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareInfoDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.shareUrl, shareUrl) || other.shareUrl == shareUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,type,shareUrl);

@override
String toString() {
  return 'ShareInfoDto(id: $id, title: $title, type: $type, shareUrl: $shareUrl)';
}


}

/// @nodoc
abstract mixin class $ShareInfoDtoCopyWith<$Res>  {
  factory $ShareInfoDtoCopyWith(ShareInfoDto value, $Res Function(ShareInfoDto) _then) = _$ShareInfoDtoCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? type, String shareUrl
});




}
/// @nodoc
class _$ShareInfoDtoCopyWithImpl<$Res>
    implements $ShareInfoDtoCopyWith<$Res> {
  _$ShareInfoDtoCopyWithImpl(this._self, this._then);

  final ShareInfoDto _self;
  final $Res Function(ShareInfoDto) _then;

/// Create a copy of ShareInfoDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? type = freezed,Object? shareUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,shareUrl: null == shareUrl ? _self.shareUrl : shareUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ShareInfoDto].
extension ShareInfoDtoPatterns on ShareInfoDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShareInfoDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShareInfoDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShareInfoDto value)  $default,){
final _that = this;
switch (_that) {
case _ShareInfoDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShareInfoDto value)?  $default,){
final _that = this;
switch (_that) {
case _ShareInfoDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? type,  String shareUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShareInfoDto() when $default != null:
return $default(_that.id,_that.title,_that.type,_that.shareUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? type,  String shareUrl)  $default,) {final _that = this;
switch (_that) {
case _ShareInfoDto():
return $default(_that.id,_that.title,_that.type,_that.shareUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? type,  String shareUrl)?  $default,) {final _that = this;
switch (_that) {
case _ShareInfoDto() when $default != null:
return $default(_that.id,_that.title,_that.type,_that.shareUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShareInfoDto implements ShareInfoDto {
  const _ShareInfoDto({required this.id, required this.title, this.type, required this.shareUrl});
  factory _ShareInfoDto.fromJson(Map<String, dynamic> json) => _$ShareInfoDtoFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? type;
@override final  String shareUrl;

/// Create a copy of ShareInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShareInfoDtoCopyWith<_ShareInfoDto> get copyWith => __$ShareInfoDtoCopyWithImpl<_ShareInfoDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShareInfoDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShareInfoDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.shareUrl, shareUrl) || other.shareUrl == shareUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,type,shareUrl);

@override
String toString() {
  return 'ShareInfoDto(id: $id, title: $title, type: $type, shareUrl: $shareUrl)';
}


}

/// @nodoc
abstract mixin class _$ShareInfoDtoCopyWith<$Res> implements $ShareInfoDtoCopyWith<$Res> {
  factory _$ShareInfoDtoCopyWith(_ShareInfoDto value, $Res Function(_ShareInfoDto) _then) = __$ShareInfoDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? type, String shareUrl
});




}
/// @nodoc
class __$ShareInfoDtoCopyWithImpl<$Res>
    implements _$ShareInfoDtoCopyWith<$Res> {
  __$ShareInfoDtoCopyWithImpl(this._self, this._then);

  final _ShareInfoDto _self;
  final $Res Function(_ShareInfoDto) _then;

/// Create a copy of ShareInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? type = freezed,Object? shareUrl = null,}) {
  return _then(_ShareInfoDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,shareUrl: null == shareUrl ? _self.shareUrl : shareUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
