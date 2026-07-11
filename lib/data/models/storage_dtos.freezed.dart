// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'storage_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UploadTokenResponseDto {

 String get token;
/// Create a copy of UploadTokenResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadTokenResponseDtoCopyWith<UploadTokenResponseDto> get copyWith => _$UploadTokenResponseDtoCopyWithImpl<UploadTokenResponseDto>(this as UploadTokenResponseDto, _$identity);

  /// Serializes this UploadTokenResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadTokenResponseDto&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'UploadTokenResponseDto(token: $token)';
}


}

/// @nodoc
abstract mixin class $UploadTokenResponseDtoCopyWith<$Res>  {
  factory $UploadTokenResponseDtoCopyWith(UploadTokenResponseDto value, $Res Function(UploadTokenResponseDto) _then) = _$UploadTokenResponseDtoCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class _$UploadTokenResponseDtoCopyWithImpl<$Res>
    implements $UploadTokenResponseDtoCopyWith<$Res> {
  _$UploadTokenResponseDtoCopyWithImpl(this._self, this._then);

  final UploadTokenResponseDto _self;
  final $Res Function(UploadTokenResponseDto) _then;

/// Create a copy of UploadTokenResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadTokenResponseDto].
extension UploadTokenResponseDtoPatterns on UploadTokenResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadTokenResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadTokenResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadTokenResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _UploadTokenResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadTokenResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _UploadTokenResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadTokenResponseDto() when $default != null:
return $default(_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token)  $default,) {final _that = this;
switch (_that) {
case _UploadTokenResponseDto():
return $default(_that.token);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token)?  $default,) {final _that = this;
switch (_that) {
case _UploadTokenResponseDto() when $default != null:
return $default(_that.token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadTokenResponseDto implements UploadTokenResponseDto {
  const _UploadTokenResponseDto({required this.token});
  factory _UploadTokenResponseDto.fromJson(Map<String, dynamic> json) => _$UploadTokenResponseDtoFromJson(json);

@override final  String token;

/// Create a copy of UploadTokenResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadTokenResponseDtoCopyWith<_UploadTokenResponseDto> get copyWith => __$UploadTokenResponseDtoCopyWithImpl<_UploadTokenResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadTokenResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadTokenResponseDto&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'UploadTokenResponseDto(token: $token)';
}


}

/// @nodoc
abstract mixin class _$UploadTokenResponseDtoCopyWith<$Res> implements $UploadTokenResponseDtoCopyWith<$Res> {
  factory _$UploadTokenResponseDtoCopyWith(_UploadTokenResponseDto value, $Res Function(_UploadTokenResponseDto) _then) = __$UploadTokenResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String token
});




}
/// @nodoc
class __$UploadTokenResponseDtoCopyWithImpl<$Res>
    implements _$UploadTokenResponseDtoCopyWith<$Res> {
  __$UploadTokenResponseDtoCopyWithImpl(this._self, this._then);

  final _UploadTokenResponseDto _self;
  final $Res Function(_UploadTokenResponseDto) _then;

/// Create a copy of UploadTokenResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(_UploadTokenResponseDto(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UploadFileResponseDto {

 String get mediaId; String get key; String get url; String get mimeType; int get size;
/// Create a copy of UploadFileResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadFileResponseDtoCopyWith<UploadFileResponseDto> get copyWith => _$UploadFileResponseDtoCopyWithImpl<UploadFileResponseDto>(this as UploadFileResponseDto, _$identity);

  /// Serializes this UploadFileResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadFileResponseDto&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.key, key) || other.key == key)&&(identical(other.url, url) || other.url == url)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaId,key,url,mimeType,size);

@override
String toString() {
  return 'UploadFileResponseDto(mediaId: $mediaId, key: $key, url: $url, mimeType: $mimeType, size: $size)';
}


}

/// @nodoc
abstract mixin class $UploadFileResponseDtoCopyWith<$Res>  {
  factory $UploadFileResponseDtoCopyWith(UploadFileResponseDto value, $Res Function(UploadFileResponseDto) _then) = _$UploadFileResponseDtoCopyWithImpl;
@useResult
$Res call({
 String mediaId, String key, String url, String mimeType, int size
});




}
/// @nodoc
class _$UploadFileResponseDtoCopyWithImpl<$Res>
    implements $UploadFileResponseDtoCopyWith<$Res> {
  _$UploadFileResponseDtoCopyWithImpl(this._self, this._then);

  final UploadFileResponseDto _self;
  final $Res Function(UploadFileResponseDto) _then;

/// Create a copy of UploadFileResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaId = null,Object? key = null,Object? url = null,Object? mimeType = null,Object? size = null,}) {
  return _then(_self.copyWith(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadFileResponseDto].
extension UploadFileResponseDtoPatterns on UploadFileResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadFileResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadFileResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadFileResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _UploadFileResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadFileResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _UploadFileResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mediaId,  String key,  String url,  String mimeType,  int size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadFileResponseDto() when $default != null:
return $default(_that.mediaId,_that.key,_that.url,_that.mimeType,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mediaId,  String key,  String url,  String mimeType,  int size)  $default,) {final _that = this;
switch (_that) {
case _UploadFileResponseDto():
return $default(_that.mediaId,_that.key,_that.url,_that.mimeType,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mediaId,  String key,  String url,  String mimeType,  int size)?  $default,) {final _that = this;
switch (_that) {
case _UploadFileResponseDto() when $default != null:
return $default(_that.mediaId,_that.key,_that.url,_that.mimeType,_that.size);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadFileResponseDto implements UploadFileResponseDto {
  const _UploadFileResponseDto({required this.mediaId, required this.key, required this.url, required this.mimeType, required this.size});
  factory _UploadFileResponseDto.fromJson(Map<String, dynamic> json) => _$UploadFileResponseDtoFromJson(json);

@override final  String mediaId;
@override final  String key;
@override final  String url;
@override final  String mimeType;
@override final  int size;

/// Create a copy of UploadFileResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadFileResponseDtoCopyWith<_UploadFileResponseDto> get copyWith => __$UploadFileResponseDtoCopyWithImpl<_UploadFileResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadFileResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadFileResponseDto&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.key, key) || other.key == key)&&(identical(other.url, url) || other.url == url)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaId,key,url,mimeType,size);

@override
String toString() {
  return 'UploadFileResponseDto(mediaId: $mediaId, key: $key, url: $url, mimeType: $mimeType, size: $size)';
}


}

/// @nodoc
abstract mixin class _$UploadFileResponseDtoCopyWith<$Res> implements $UploadFileResponseDtoCopyWith<$Res> {
  factory _$UploadFileResponseDtoCopyWith(_UploadFileResponseDto value, $Res Function(_UploadFileResponseDto) _then) = __$UploadFileResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String mediaId, String key, String url, String mimeType, int size
});




}
/// @nodoc
class __$UploadFileResponseDtoCopyWithImpl<$Res>
    implements _$UploadFileResponseDtoCopyWith<$Res> {
  __$UploadFileResponseDtoCopyWithImpl(this._self, this._then);

  final _UploadFileResponseDto _self;
  final $Res Function(_UploadFileResponseDto) _then;

/// Create a copy of UploadFileResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaId = null,Object? key = null,Object? url = null,Object? mimeType = null,Object? size = null,}) {
  return _then(_UploadFileResponseDto(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DeleteFileDto {

 String get key;
/// Create a copy of DeleteFileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteFileDtoCopyWith<DeleteFileDto> get copyWith => _$DeleteFileDtoCopyWithImpl<DeleteFileDto>(this as DeleteFileDto, _$identity);

  /// Serializes this DeleteFileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteFileDto&&(identical(other.key, key) || other.key == key));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key);

@override
String toString() {
  return 'DeleteFileDto(key: $key)';
}


}

/// @nodoc
abstract mixin class $DeleteFileDtoCopyWith<$Res>  {
  factory $DeleteFileDtoCopyWith(DeleteFileDto value, $Res Function(DeleteFileDto) _then) = _$DeleteFileDtoCopyWithImpl;
@useResult
$Res call({
 String key
});




}
/// @nodoc
class _$DeleteFileDtoCopyWithImpl<$Res>
    implements $DeleteFileDtoCopyWith<$Res> {
  _$DeleteFileDtoCopyWithImpl(this._self, this._then);

  final DeleteFileDto _self;
  final $Res Function(DeleteFileDto) _then;

/// Create a copy of DeleteFileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DeleteFileDto].
extension DeleteFileDtoPatterns on DeleteFileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeleteFileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeleteFileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeleteFileDto value)  $default,){
final _that = this;
switch (_that) {
case _DeleteFileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeleteFileDto value)?  $default,){
final _that = this;
switch (_that) {
case _DeleteFileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeleteFileDto() when $default != null:
return $default(_that.key);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key)  $default,) {final _that = this;
switch (_that) {
case _DeleteFileDto():
return $default(_that.key);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key)?  $default,) {final _that = this;
switch (_that) {
case _DeleteFileDto() when $default != null:
return $default(_that.key);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeleteFileDto implements DeleteFileDto {
  const _DeleteFileDto({required this.key});
  factory _DeleteFileDto.fromJson(Map<String, dynamic> json) => _$DeleteFileDtoFromJson(json);

@override final  String key;

/// Create a copy of DeleteFileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteFileDtoCopyWith<_DeleteFileDto> get copyWith => __$DeleteFileDtoCopyWithImpl<_DeleteFileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeleteFileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteFileDto&&(identical(other.key, key) || other.key == key));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key);

@override
String toString() {
  return 'DeleteFileDto(key: $key)';
}


}

/// @nodoc
abstract mixin class _$DeleteFileDtoCopyWith<$Res> implements $DeleteFileDtoCopyWith<$Res> {
  factory _$DeleteFileDtoCopyWith(_DeleteFileDto value, $Res Function(_DeleteFileDto) _then) = __$DeleteFileDtoCopyWithImpl;
@override @useResult
$Res call({
 String key
});




}
/// @nodoc
class __$DeleteFileDtoCopyWithImpl<$Res>
    implements _$DeleteFileDtoCopyWith<$Res> {
  __$DeleteFileDtoCopyWithImpl(this._self, this._then);

  final _DeleteFileDto _self;
  final $Res Function(_DeleteFileDto) _then;

/// Create a copy of DeleteFileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,}) {
  return _then(_DeleteFileDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DeleteFileResponseDto {

 bool get success;
/// Create a copy of DeleteFileResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteFileResponseDtoCopyWith<DeleteFileResponseDto> get copyWith => _$DeleteFileResponseDtoCopyWithImpl<DeleteFileResponseDto>(this as DeleteFileResponseDto, _$identity);

  /// Serializes this DeleteFileResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteFileResponseDto&&(identical(other.success, success) || other.success == success));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success);

@override
String toString() {
  return 'DeleteFileResponseDto(success: $success)';
}


}

/// @nodoc
abstract mixin class $DeleteFileResponseDtoCopyWith<$Res>  {
  factory $DeleteFileResponseDtoCopyWith(DeleteFileResponseDto value, $Res Function(DeleteFileResponseDto) _then) = _$DeleteFileResponseDtoCopyWithImpl;
@useResult
$Res call({
 bool success
});




}
/// @nodoc
class _$DeleteFileResponseDtoCopyWithImpl<$Res>
    implements $DeleteFileResponseDtoCopyWith<$Res> {
  _$DeleteFileResponseDtoCopyWithImpl(this._self, this._then);

  final DeleteFileResponseDto _self;
  final $Res Function(DeleteFileResponseDto) _then;

/// Create a copy of DeleteFileResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DeleteFileResponseDto].
extension DeleteFileResponseDtoPatterns on DeleteFileResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeleteFileResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeleteFileResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeleteFileResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _DeleteFileResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeleteFileResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _DeleteFileResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeleteFileResponseDto() when $default != null:
return $default(_that.success);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success)  $default,) {final _that = this;
switch (_that) {
case _DeleteFileResponseDto():
return $default(_that.success);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success)?  $default,) {final _that = this;
switch (_that) {
case _DeleteFileResponseDto() when $default != null:
return $default(_that.success);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeleteFileResponseDto implements DeleteFileResponseDto {
  const _DeleteFileResponseDto({required this.success});
  factory _DeleteFileResponseDto.fromJson(Map<String, dynamic> json) => _$DeleteFileResponseDtoFromJson(json);

@override final  bool success;

/// Create a copy of DeleteFileResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteFileResponseDtoCopyWith<_DeleteFileResponseDto> get copyWith => __$DeleteFileResponseDtoCopyWithImpl<_DeleteFileResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeleteFileResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteFileResponseDto&&(identical(other.success, success) || other.success == success));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success);

@override
String toString() {
  return 'DeleteFileResponseDto(success: $success)';
}


}

/// @nodoc
abstract mixin class _$DeleteFileResponseDtoCopyWith<$Res> implements $DeleteFileResponseDtoCopyWith<$Res> {
  factory _$DeleteFileResponseDtoCopyWith(_DeleteFileResponseDto value, $Res Function(_DeleteFileResponseDto) _then) = __$DeleteFileResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 bool success
});




}
/// @nodoc
class __$DeleteFileResponseDtoCopyWithImpl<$Res>
    implements _$DeleteFileResponseDtoCopyWith<$Res> {
  __$DeleteFileResponseDtoCopyWithImpl(this._self, this._then);

  final _DeleteFileResponseDto _self;
  final $Res Function(_DeleteFileResponseDto) _then;

/// Create a copy of DeleteFileResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,}) {
  return _then(_DeleteFileResponseDto(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
