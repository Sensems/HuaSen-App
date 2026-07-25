// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaDto {

 String get mediaId; String get key; String get url; String get mimeType; int get size; MediaType? get type;@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) DateTime? get createdAt;
/// Create a copy of MediaDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaDtoCopyWith<MediaDto> get copyWith => _$MediaDtoCopyWithImpl<MediaDto>(this as MediaDto, _$identity);

  /// Serializes this MediaDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaDto&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.key, key) || other.key == key)&&(identical(other.url, url) || other.url == url)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.size, size) || other.size == size)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaId,key,url,mimeType,size,type,createdAt);

@override
String toString() {
  return 'MediaDto(mediaId: $mediaId, key: $key, url: $url, mimeType: $mimeType, size: $size, type: $type, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MediaDtoCopyWith<$Res>  {
  factory $MediaDtoCopyWith(MediaDto value, $Res Function(MediaDto) _then) = _$MediaDtoCopyWithImpl;
@useResult
$Res call({
 String mediaId, String key, String url, String mimeType, int size, MediaType? type,@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) DateTime? createdAt
});




}
/// @nodoc
class _$MediaDtoCopyWithImpl<$Res>
    implements $MediaDtoCopyWith<$Res> {
  _$MediaDtoCopyWithImpl(this._self, this._then);

  final MediaDto _self;
  final $Res Function(MediaDto) _then;

/// Create a copy of MediaDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaId = null,Object? key = null,Object? url = null,Object? mimeType = null,Object? size = null,Object? type = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MediaType?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaDto].
extension MediaDtoPatterns on MediaDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaDto value)  $default,){
final _that = this;
switch (_that) {
case _MediaDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaDto value)?  $default,){
final _that = this;
switch (_that) {
case _MediaDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mediaId,  String key,  String url,  String mimeType,  int size,  MediaType? type, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaDto() when $default != null:
return $default(_that.mediaId,_that.key,_that.url,_that.mimeType,_that.size,_that.type,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mediaId,  String key,  String url,  String mimeType,  int size,  MediaType? type, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _MediaDto():
return $default(_that.mediaId,_that.key,_that.url,_that.mimeType,_that.size,_that.type,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mediaId,  String key,  String url,  String mimeType,  int size,  MediaType? type, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MediaDto() when $default != null:
return $default(_that.mediaId,_that.key,_that.url,_that.mimeType,_that.size,_that.type,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaDto implements MediaDto {
  const _MediaDto({required this.mediaId, required this.key, required this.url, required this.mimeType, required this.size, this.type, @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) this.createdAt});
  factory _MediaDto.fromJson(Map<String, dynamic> json) => _$MediaDtoFromJson(json);

@override final  String mediaId;
@override final  String key;
@override final  String url;
@override final  String mimeType;
@override final  int size;
@override final  MediaType? type;
@override@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) final  DateTime? createdAt;

/// Create a copy of MediaDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaDtoCopyWith<_MediaDto> get copyWith => __$MediaDtoCopyWithImpl<_MediaDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaDto&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.key, key) || other.key == key)&&(identical(other.url, url) || other.url == url)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.size, size) || other.size == size)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaId,key,url,mimeType,size,type,createdAt);

@override
String toString() {
  return 'MediaDto(mediaId: $mediaId, key: $key, url: $url, mimeType: $mimeType, size: $size, type: $type, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MediaDtoCopyWith<$Res> implements $MediaDtoCopyWith<$Res> {
  factory _$MediaDtoCopyWith(_MediaDto value, $Res Function(_MediaDto) _then) = __$MediaDtoCopyWithImpl;
@override @useResult
$Res call({
 String mediaId, String key, String url, String mimeType, int size, MediaType? type,@JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable) DateTime? createdAt
});




}
/// @nodoc
class __$MediaDtoCopyWithImpl<$Res>
    implements _$MediaDtoCopyWith<$Res> {
  __$MediaDtoCopyWithImpl(this._self, this._then);

  final _MediaDto _self;
  final $Res Function(_MediaDto) _then;

/// Create a copy of MediaDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaId = null,Object? key = null,Object? url = null,Object? mimeType = null,Object? size = null,Object? type = freezed,Object? createdAt = freezed,}) {
  return _then(_MediaDto(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MediaType?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CheckMediaDto {

 List<String> get mediaIds;
/// Create a copy of CheckMediaDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckMediaDtoCopyWith<CheckMediaDto> get copyWith => _$CheckMediaDtoCopyWithImpl<CheckMediaDto>(this as CheckMediaDto, _$identity);

  /// Serializes this CheckMediaDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckMediaDto&&const DeepCollectionEquality().equals(other.mediaIds, mediaIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mediaIds));

@override
String toString() {
  return 'CheckMediaDto(mediaIds: $mediaIds)';
}


}

/// @nodoc
abstract mixin class $CheckMediaDtoCopyWith<$Res>  {
  factory $CheckMediaDtoCopyWith(CheckMediaDto value, $Res Function(CheckMediaDto) _then) = _$CheckMediaDtoCopyWithImpl;
@useResult
$Res call({
 List<String> mediaIds
});




}
/// @nodoc
class _$CheckMediaDtoCopyWithImpl<$Res>
    implements $CheckMediaDtoCopyWith<$Res> {
  _$CheckMediaDtoCopyWithImpl(this._self, this._then);

  final CheckMediaDto _self;
  final $Res Function(CheckMediaDto) _then;

/// Create a copy of CheckMediaDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaIds = null,}) {
  return _then(_self.copyWith(
mediaIds: null == mediaIds ? _self.mediaIds : mediaIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckMediaDto].
extension CheckMediaDtoPatterns on CheckMediaDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckMediaDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckMediaDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckMediaDto value)  $default,){
final _that = this;
switch (_that) {
case _CheckMediaDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckMediaDto value)?  $default,){
final _that = this;
switch (_that) {
case _CheckMediaDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> mediaIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckMediaDto() when $default != null:
return $default(_that.mediaIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> mediaIds)  $default,) {final _that = this;
switch (_that) {
case _CheckMediaDto():
return $default(_that.mediaIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> mediaIds)?  $default,) {final _that = this;
switch (_that) {
case _CheckMediaDto() when $default != null:
return $default(_that.mediaIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckMediaDto implements CheckMediaDto {
  const _CheckMediaDto({required final  List<String> mediaIds}): _mediaIds = mediaIds;
  factory _CheckMediaDto.fromJson(Map<String, dynamic> json) => _$CheckMediaDtoFromJson(json);

 final  List<String> _mediaIds;
@override List<String> get mediaIds {
  if (_mediaIds is EqualUnmodifiableListView) return _mediaIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaIds);
}


/// Create a copy of CheckMediaDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckMediaDtoCopyWith<_CheckMediaDto> get copyWith => __$CheckMediaDtoCopyWithImpl<_CheckMediaDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckMediaDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckMediaDto&&const DeepCollectionEquality().equals(other._mediaIds, _mediaIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mediaIds));

@override
String toString() {
  return 'CheckMediaDto(mediaIds: $mediaIds)';
}


}

/// @nodoc
abstract mixin class _$CheckMediaDtoCopyWith<$Res> implements $CheckMediaDtoCopyWith<$Res> {
  factory _$CheckMediaDtoCopyWith(_CheckMediaDto value, $Res Function(_CheckMediaDto) _then) = __$CheckMediaDtoCopyWithImpl;
@override @useResult
$Res call({
 List<String> mediaIds
});




}
/// @nodoc
class __$CheckMediaDtoCopyWithImpl<$Res>
    implements _$CheckMediaDtoCopyWith<$Res> {
  __$CheckMediaDtoCopyWithImpl(this._self, this._then);

  final _CheckMediaDto _self;
  final $Res Function(_CheckMediaDto) _then;

/// Create a copy of CheckMediaDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaIds = null,}) {
  return _then(_CheckMediaDto(
mediaIds: null == mediaIds ? _self._mediaIds : mediaIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$CheckMediaResultDto {

 List<String> get valid; List<String> get invalid;
/// Create a copy of CheckMediaResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckMediaResultDtoCopyWith<CheckMediaResultDto> get copyWith => _$CheckMediaResultDtoCopyWithImpl<CheckMediaResultDto>(this as CheckMediaResultDto, _$identity);

  /// Serializes this CheckMediaResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckMediaResultDto&&const DeepCollectionEquality().equals(other.valid, valid)&&const DeepCollectionEquality().equals(other.invalid, invalid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(valid),const DeepCollectionEquality().hash(invalid));

@override
String toString() {
  return 'CheckMediaResultDto(valid: $valid, invalid: $invalid)';
}


}

/// @nodoc
abstract mixin class $CheckMediaResultDtoCopyWith<$Res>  {
  factory $CheckMediaResultDtoCopyWith(CheckMediaResultDto value, $Res Function(CheckMediaResultDto) _then) = _$CheckMediaResultDtoCopyWithImpl;
@useResult
$Res call({
 List<String> valid, List<String> invalid
});




}
/// @nodoc
class _$CheckMediaResultDtoCopyWithImpl<$Res>
    implements $CheckMediaResultDtoCopyWith<$Res> {
  _$CheckMediaResultDtoCopyWithImpl(this._self, this._then);

  final CheckMediaResultDto _self;
  final $Res Function(CheckMediaResultDto) _then;

/// Create a copy of CheckMediaResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? valid = null,Object? invalid = null,}) {
  return _then(_self.copyWith(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as List<String>,invalid: null == invalid ? _self.invalid : invalid // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckMediaResultDto].
extension CheckMediaResultDtoPatterns on CheckMediaResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckMediaResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckMediaResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckMediaResultDto value)  $default,){
final _that = this;
switch (_that) {
case _CheckMediaResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckMediaResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _CheckMediaResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> valid,  List<String> invalid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckMediaResultDto() when $default != null:
return $default(_that.valid,_that.invalid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> valid,  List<String> invalid)  $default,) {final _that = this;
switch (_that) {
case _CheckMediaResultDto():
return $default(_that.valid,_that.invalid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> valid,  List<String> invalid)?  $default,) {final _that = this;
switch (_that) {
case _CheckMediaResultDto() when $default != null:
return $default(_that.valid,_that.invalid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckMediaResultDto implements CheckMediaResultDto {
  const _CheckMediaResultDto({required final  List<String> valid, required final  List<String> invalid}): _valid = valid,_invalid = invalid;
  factory _CheckMediaResultDto.fromJson(Map<String, dynamic> json) => _$CheckMediaResultDtoFromJson(json);

 final  List<String> _valid;
@override List<String> get valid {
  if (_valid is EqualUnmodifiableListView) return _valid;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_valid);
}

 final  List<String> _invalid;
@override List<String> get invalid {
  if (_invalid is EqualUnmodifiableListView) return _invalid;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invalid);
}


/// Create a copy of CheckMediaResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckMediaResultDtoCopyWith<_CheckMediaResultDto> get copyWith => __$CheckMediaResultDtoCopyWithImpl<_CheckMediaResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckMediaResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckMediaResultDto&&const DeepCollectionEquality().equals(other._valid, _valid)&&const DeepCollectionEquality().equals(other._invalid, _invalid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_valid),const DeepCollectionEquality().hash(_invalid));

@override
String toString() {
  return 'CheckMediaResultDto(valid: $valid, invalid: $invalid)';
}


}

/// @nodoc
abstract mixin class _$CheckMediaResultDtoCopyWith<$Res> implements $CheckMediaResultDtoCopyWith<$Res> {
  factory _$CheckMediaResultDtoCopyWith(_CheckMediaResultDto value, $Res Function(_CheckMediaResultDto) _then) = __$CheckMediaResultDtoCopyWithImpl;
@override @useResult
$Res call({
 List<String> valid, List<String> invalid
});




}
/// @nodoc
class __$CheckMediaResultDtoCopyWithImpl<$Res>
    implements _$CheckMediaResultDtoCopyWith<$Res> {
  __$CheckMediaResultDtoCopyWithImpl(this._self, this._then);

  final _CheckMediaResultDto _self;
  final $Res Function(_CheckMediaResultDto) _then;

/// Create a copy of CheckMediaResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? valid = null,Object? invalid = null,}) {
  return _then(_CheckMediaResultDto(
valid: null == valid ? _self._valid : valid // ignore: cast_nullable_to_non_nullable
as List<String>,invalid: null == invalid ? _self._invalid : invalid // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
