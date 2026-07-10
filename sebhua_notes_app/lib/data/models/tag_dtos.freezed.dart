// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tag_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TagResponseDto {

 String get id; String get name;@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get createdAt; int? get count;
/// Create a copy of TagResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagResponseDtoCopyWith<TagResponseDto> get copyWith => _$TagResponseDtoCopyWithImpl<TagResponseDto>(this as TagResponseDto, _$identity);

  /// Serializes this TagResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,count);

@override
String toString() {
  return 'TagResponseDto(id: $id, name: $name, createdAt: $createdAt, count: $count)';
}


}

/// @nodoc
abstract mixin class $TagResponseDtoCopyWith<$Res>  {
  factory $TagResponseDtoCopyWith(TagResponseDto value, $Res Function(TagResponseDto) _then) = _$TagResponseDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt, int? count
});




}
/// @nodoc
class _$TagResponseDtoCopyWithImpl<$Res>
    implements $TagResponseDtoCopyWith<$Res> {
  _$TagResponseDtoCopyWithImpl(this._self, this._then);

  final TagResponseDto _self;
  final $Res Function(TagResponseDto) _then;

/// Create a copy of TagResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? count = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TagResponseDto].
extension TagResponseDtoPatterns on TagResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _TagResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _TagResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt,  int? count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagResponseDto() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt,  int? count)  $default,) {final _that = this;
switch (_that) {
case _TagResponseDto():
return $default(_that.id,_that.name,_that.createdAt,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt,  int? count)?  $default,) {final _that = this;
switch (_that) {
case _TagResponseDto() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TagResponseDto implements TagResponseDto {
  const _TagResponseDto({required this.id, required this.name, @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.createdAt, this.count});
  factory _TagResponseDto.fromJson(Map<String, dynamic> json) => _$TagResponseDtoFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) final  DateTime createdAt;
@override final  int? count;

/// Create a copy of TagResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagResponseDtoCopyWith<_TagResponseDto> get copyWith => __$TagResponseDtoCopyWithImpl<_TagResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TagResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,count);

@override
String toString() {
  return 'TagResponseDto(id: $id, name: $name, createdAt: $createdAt, count: $count)';
}


}

/// @nodoc
abstract mixin class _$TagResponseDtoCopyWith<$Res> implements $TagResponseDtoCopyWith<$Res> {
  factory _$TagResponseDtoCopyWith(_TagResponseDto value, $Res Function(_TagResponseDto) _then) = __$TagResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt, int? count
});




}
/// @nodoc
class __$TagResponseDtoCopyWithImpl<$Res>
    implements _$TagResponseDtoCopyWith<$Res> {
  __$TagResponseDtoCopyWithImpl(this._self, this._then);

  final _TagResponseDto _self;
  final $Res Function(_TagResponseDto) _then;

/// Create a copy of TagResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? count = freezed,}) {
  return _then(_TagResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$CreateTagDto {

 String get name;
/// Create a copy of CreateTagDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTagDtoCopyWith<CreateTagDto> get copyWith => _$CreateTagDtoCopyWithImpl<CreateTagDto>(this as CreateTagDto, _$identity);

  /// Serializes this CreateTagDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTagDto&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'CreateTagDto(name: $name)';
}


}

/// @nodoc
abstract mixin class $CreateTagDtoCopyWith<$Res>  {
  factory $CreateTagDtoCopyWith(CreateTagDto value, $Res Function(CreateTagDto) _then) = _$CreateTagDtoCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$CreateTagDtoCopyWithImpl<$Res>
    implements $CreateTagDtoCopyWith<$Res> {
  _$CreateTagDtoCopyWithImpl(this._self, this._then);

  final CreateTagDto _self;
  final $Res Function(CreateTagDto) _then;

/// Create a copy of CreateTagDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateTagDto].
extension CreateTagDtoPatterns on CreateTagDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateTagDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateTagDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateTagDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateTagDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateTagDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateTagDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateTagDto() when $default != null:
return $default(_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name)  $default,) {final _that = this;
switch (_that) {
case _CreateTagDto():
return $default(_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name)?  $default,) {final _that = this;
switch (_that) {
case _CreateTagDto() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateTagDto implements CreateTagDto {
  const _CreateTagDto({required this.name});
  factory _CreateTagDto.fromJson(Map<String, dynamic> json) => _$CreateTagDtoFromJson(json);

@override final  String name;

/// Create a copy of CreateTagDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateTagDtoCopyWith<_CreateTagDto> get copyWith => __$CreateTagDtoCopyWithImpl<_CreateTagDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateTagDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateTagDto&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'CreateTagDto(name: $name)';
}


}

/// @nodoc
abstract mixin class _$CreateTagDtoCopyWith<$Res> implements $CreateTagDtoCopyWith<$Res> {
  factory _$CreateTagDtoCopyWith(_CreateTagDto value, $Res Function(_CreateTagDto) _then) = __$CreateTagDtoCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$CreateTagDtoCopyWithImpl<$Res>
    implements _$CreateTagDtoCopyWith<$Res> {
  __$CreateTagDtoCopyWithImpl(this._self, this._then);

  final _CreateTagDto _self;
  final $Res Function(_CreateTagDto) _then;

/// Create a copy of CreateTagDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_CreateTagDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
