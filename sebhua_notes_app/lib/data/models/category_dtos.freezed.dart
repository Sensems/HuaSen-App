// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategoryDto {

 String get id; String get name; String? get parentId; int get sortOrder; int get notesCount; List<CategoryDto>? get children;
/// Create a copy of CategoryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryDtoCopyWith<CategoryDto> get copyWith => _$CategoryDtoCopyWithImpl<CategoryDto>(this as CategoryDto, _$identity);

  /// Serializes this CategoryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.notesCount, notesCount) || other.notesCount == notesCount)&&const DeepCollectionEquality().equals(other.children, children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,parentId,sortOrder,notesCount,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'CategoryDto(id: $id, name: $name, parentId: $parentId, sortOrder: $sortOrder, notesCount: $notesCount, children: $children)';
}


}

/// @nodoc
abstract mixin class $CategoryDtoCopyWith<$Res>  {
  factory $CategoryDtoCopyWith(CategoryDto value, $Res Function(CategoryDto) _then) = _$CategoryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? parentId, int sortOrder, int notesCount, List<CategoryDto>? children
});




}
/// @nodoc
class _$CategoryDtoCopyWithImpl<$Res>
    implements $CategoryDtoCopyWith<$Res> {
  _$CategoryDtoCopyWithImpl(this._self, this._then);

  final CategoryDto _self;
  final $Res Function(CategoryDto) _then;

/// Create a copy of CategoryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? parentId = freezed,Object? sortOrder = null,Object? notesCount = null,Object? children = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,notesCount: null == notesCount ? _self.notesCount : notesCount // ignore: cast_nullable_to_non_nullable
as int,children: freezed == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<CategoryDto>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryDto].
extension CategoryDtoPatterns on CategoryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryDto value)  $default,){
final _that = this;
switch (_that) {
case _CategoryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryDto value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? parentId,  int sortOrder,  int notesCount,  List<CategoryDto>? children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryDto() when $default != null:
return $default(_that.id,_that.name,_that.parentId,_that.sortOrder,_that.notesCount,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? parentId,  int sortOrder,  int notesCount,  List<CategoryDto>? children)  $default,) {final _that = this;
switch (_that) {
case _CategoryDto():
return $default(_that.id,_that.name,_that.parentId,_that.sortOrder,_that.notesCount,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? parentId,  int sortOrder,  int notesCount,  List<CategoryDto>? children)?  $default,) {final _that = this;
switch (_that) {
case _CategoryDto() when $default != null:
return $default(_that.id,_that.name,_that.parentId,_that.sortOrder,_that.notesCount,_that.children);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryDto implements CategoryDto {
  const _CategoryDto({required this.id, required this.name, this.parentId, required this.sortOrder, required this.notesCount, final  List<CategoryDto>? children}): _children = children;
  factory _CategoryDto.fromJson(Map<String, dynamic> json) => _$CategoryDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? parentId;
@override final  int sortOrder;
@override final  int notesCount;
 final  List<CategoryDto>? _children;
@override List<CategoryDto>? get children {
  final value = _children;
  if (value == null) return null;
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryDtoCopyWith<_CategoryDto> get copyWith => __$CategoryDtoCopyWithImpl<_CategoryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.notesCount, notesCount) || other.notesCount == notesCount)&&const DeepCollectionEquality().equals(other._children, _children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,parentId,sortOrder,notesCount,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'CategoryDto(id: $id, name: $name, parentId: $parentId, sortOrder: $sortOrder, notesCount: $notesCount, children: $children)';
}


}

/// @nodoc
abstract mixin class _$CategoryDtoCopyWith<$Res> implements $CategoryDtoCopyWith<$Res> {
  factory _$CategoryDtoCopyWith(_CategoryDto value, $Res Function(_CategoryDto) _then) = __$CategoryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? parentId, int sortOrder, int notesCount, List<CategoryDto>? children
});




}
/// @nodoc
class __$CategoryDtoCopyWithImpl<$Res>
    implements _$CategoryDtoCopyWith<$Res> {
  __$CategoryDtoCopyWithImpl(this._self, this._then);

  final _CategoryDto _self;
  final $Res Function(_CategoryDto) _then;

/// Create a copy of CategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? parentId = freezed,Object? sortOrder = null,Object? notesCount = null,Object? children = freezed,}) {
  return _then(_CategoryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,notesCount: null == notesCount ? _self.notesCount : notesCount // ignore: cast_nullable_to_non_nullable
as int,children: freezed == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<CategoryDto>?,
  ));
}


}


/// @nodoc
mixin _$CreateCategoryDto {

 String get name; String? get parentId;
/// Create a copy of CreateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateCategoryDtoCopyWith<CreateCategoryDto> get copyWith => _$CreateCategoryDtoCopyWithImpl<CreateCategoryDto>(this as CreateCategoryDto, _$identity);

  /// Serializes this CreateCategoryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateCategoryDto&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,parentId);

@override
String toString() {
  return 'CreateCategoryDto(name: $name, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class $CreateCategoryDtoCopyWith<$Res>  {
  factory $CreateCategoryDtoCopyWith(CreateCategoryDto value, $Res Function(CreateCategoryDto) _then) = _$CreateCategoryDtoCopyWithImpl;
@useResult
$Res call({
 String name, String? parentId
});




}
/// @nodoc
class _$CreateCategoryDtoCopyWithImpl<$Res>
    implements $CreateCategoryDtoCopyWith<$Res> {
  _$CreateCategoryDtoCopyWithImpl(this._self, this._then);

  final CreateCategoryDto _self;
  final $Res Function(CreateCategoryDto) _then;

/// Create a copy of CreateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? parentId = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateCategoryDto].
extension CreateCategoryDtoPatterns on CreateCategoryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateCategoryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateCategoryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateCategoryDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateCategoryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateCategoryDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateCategoryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateCategoryDto() when $default != null:
return $default(_that.name,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? parentId)  $default,) {final _that = this;
switch (_that) {
case _CreateCategoryDto():
return $default(_that.name,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? parentId)?  $default,) {final _that = this;
switch (_that) {
case _CreateCategoryDto() when $default != null:
return $default(_that.name,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateCategoryDto implements CreateCategoryDto {
  const _CreateCategoryDto({required this.name, this.parentId});
  factory _CreateCategoryDto.fromJson(Map<String, dynamic> json) => _$CreateCategoryDtoFromJson(json);

@override final  String name;
@override final  String? parentId;

/// Create a copy of CreateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateCategoryDtoCopyWith<_CreateCategoryDto> get copyWith => __$CreateCategoryDtoCopyWithImpl<_CreateCategoryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateCategoryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateCategoryDto&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,parentId);

@override
String toString() {
  return 'CreateCategoryDto(name: $name, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$CreateCategoryDtoCopyWith<$Res> implements $CreateCategoryDtoCopyWith<$Res> {
  factory _$CreateCategoryDtoCopyWith(_CreateCategoryDto value, $Res Function(_CreateCategoryDto) _then) = __$CreateCategoryDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String? parentId
});




}
/// @nodoc
class __$CreateCategoryDtoCopyWithImpl<$Res>
    implements _$CreateCategoryDtoCopyWith<$Res> {
  __$CreateCategoryDtoCopyWithImpl(this._self, this._then);

  final _CreateCategoryDto _self;
  final $Res Function(_CreateCategoryDto) _then;

/// Create a copy of CreateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? parentId = freezed,}) {
  return _then(_CreateCategoryDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateCategoryDto {

 String get id; String? get name; String? get parentId;
/// Create a copy of UpdateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateCategoryDtoCopyWith<UpdateCategoryDto> get copyWith => _$UpdateCategoryDtoCopyWithImpl<UpdateCategoryDto>(this as UpdateCategoryDto, _$identity);

  /// Serializes this UpdateCategoryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateCategoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,parentId);

@override
String toString() {
  return 'UpdateCategoryDto(id: $id, name: $name, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class $UpdateCategoryDtoCopyWith<$Res>  {
  factory $UpdateCategoryDtoCopyWith(UpdateCategoryDto value, $Res Function(UpdateCategoryDto) _then) = _$UpdateCategoryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? parentId
});




}
/// @nodoc
class _$UpdateCategoryDtoCopyWithImpl<$Res>
    implements $UpdateCategoryDtoCopyWith<$Res> {
  _$UpdateCategoryDtoCopyWithImpl(this._self, this._then);

  final UpdateCategoryDto _self;
  final $Res Function(UpdateCategoryDto) _then;

/// Create a copy of UpdateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? parentId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateCategoryDto].
extension UpdateCategoryDtoPatterns on UpdateCategoryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateCategoryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateCategoryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateCategoryDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateCategoryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateCategoryDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateCategoryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateCategoryDto() when $default != null:
return $default(_that.id,_that.name,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String? parentId)  $default,) {final _that = this;
switch (_that) {
case _UpdateCategoryDto():
return $default(_that.id,_that.name,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String? parentId)?  $default,) {final _that = this;
switch (_that) {
case _UpdateCategoryDto() when $default != null:
return $default(_that.id,_that.name,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateCategoryDto implements UpdateCategoryDto {
  const _UpdateCategoryDto({required this.id, this.name, this.parentId});
  factory _UpdateCategoryDto.fromJson(Map<String, dynamic> json) => _$UpdateCategoryDtoFromJson(json);

@override final  String id;
@override final  String? name;
@override final  String? parentId;

/// Create a copy of UpdateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateCategoryDtoCopyWith<_UpdateCategoryDto> get copyWith => __$UpdateCategoryDtoCopyWithImpl<_UpdateCategoryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateCategoryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateCategoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,parentId);

@override
String toString() {
  return 'UpdateCategoryDto(id: $id, name: $name, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$UpdateCategoryDtoCopyWith<$Res> implements $UpdateCategoryDtoCopyWith<$Res> {
  factory _$UpdateCategoryDtoCopyWith(_UpdateCategoryDto value, $Res Function(_UpdateCategoryDto) _then) = __$UpdateCategoryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String? parentId
});




}
/// @nodoc
class __$UpdateCategoryDtoCopyWithImpl<$Res>
    implements _$UpdateCategoryDtoCopyWith<$Res> {
  __$UpdateCategoryDtoCopyWithImpl(this._self, this._then);

  final _UpdateCategoryDto _self;
  final $Res Function(_UpdateCategoryDto) _then;

/// Create a copy of UpdateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? parentId = freezed,}) {
  return _then(_UpdateCategoryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReorderItem {

 String get id; String? get parentId;
/// Create a copy of ReorderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReorderItemCopyWith<ReorderItem> get copyWith => _$ReorderItemCopyWithImpl<ReorderItem>(this as ReorderItem, _$identity);

  /// Serializes this ReorderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReorderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,parentId);

@override
String toString() {
  return 'ReorderItem(id: $id, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class $ReorderItemCopyWith<$Res>  {
  factory $ReorderItemCopyWith(ReorderItem value, $Res Function(ReorderItem) _then) = _$ReorderItemCopyWithImpl;
@useResult
$Res call({
 String id, String? parentId
});




}
/// @nodoc
class _$ReorderItemCopyWithImpl<$Res>
    implements $ReorderItemCopyWith<$Res> {
  _$ReorderItemCopyWithImpl(this._self, this._then);

  final ReorderItem _self;
  final $Res Function(ReorderItem) _then;

/// Create a copy of ReorderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parentId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReorderItem].
extension ReorderItemPatterns on ReorderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReorderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReorderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReorderItem value)  $default,){
final _that = this;
switch (_that) {
case _ReorderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReorderItem value)?  $default,){
final _that = this;
switch (_that) {
case _ReorderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReorderItem() when $default != null:
return $default(_that.id,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? parentId)  $default,) {final _that = this;
switch (_that) {
case _ReorderItem():
return $default(_that.id,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? parentId)?  $default,) {final _that = this;
switch (_that) {
case _ReorderItem() when $default != null:
return $default(_that.id,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReorderItem implements ReorderItem {
  const _ReorderItem({required this.id, this.parentId});
  factory _ReorderItem.fromJson(Map<String, dynamic> json) => _$ReorderItemFromJson(json);

@override final  String id;
@override final  String? parentId;

/// Create a copy of ReorderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReorderItemCopyWith<_ReorderItem> get copyWith => __$ReorderItemCopyWithImpl<_ReorderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReorderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReorderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,parentId);

@override
String toString() {
  return 'ReorderItem(id: $id, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$ReorderItemCopyWith<$Res> implements $ReorderItemCopyWith<$Res> {
  factory _$ReorderItemCopyWith(_ReorderItem value, $Res Function(_ReorderItem) _then) = __$ReorderItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? parentId
});




}
/// @nodoc
class __$ReorderItemCopyWithImpl<$Res>
    implements _$ReorderItemCopyWith<$Res> {
  __$ReorderItemCopyWithImpl(this._self, this._then);

  final _ReorderItem _self;
  final $Res Function(_ReorderItem) _then;

/// Create a copy of ReorderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parentId = freezed,}) {
  return _then(_ReorderItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReorderCategoryDto {

 List<ReorderItem> get items;
/// Create a copy of ReorderCategoryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReorderCategoryDtoCopyWith<ReorderCategoryDto> get copyWith => _$ReorderCategoryDtoCopyWithImpl<ReorderCategoryDto>(this as ReorderCategoryDto, _$identity);

  /// Serializes this ReorderCategoryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReorderCategoryDto&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ReorderCategoryDto(items: $items)';
}


}

/// @nodoc
abstract mixin class $ReorderCategoryDtoCopyWith<$Res>  {
  factory $ReorderCategoryDtoCopyWith(ReorderCategoryDto value, $Res Function(ReorderCategoryDto) _then) = _$ReorderCategoryDtoCopyWithImpl;
@useResult
$Res call({
 List<ReorderItem> items
});




}
/// @nodoc
class _$ReorderCategoryDtoCopyWithImpl<$Res>
    implements $ReorderCategoryDtoCopyWith<$Res> {
  _$ReorderCategoryDtoCopyWithImpl(this._self, this._then);

  final ReorderCategoryDto _self;
  final $Res Function(ReorderCategoryDto) _then;

/// Create a copy of ReorderCategoryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ReorderItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReorderCategoryDto].
extension ReorderCategoryDtoPatterns on ReorderCategoryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReorderCategoryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReorderCategoryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReorderCategoryDto value)  $default,){
final _that = this;
switch (_that) {
case _ReorderCategoryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReorderCategoryDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReorderCategoryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ReorderItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReorderCategoryDto() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ReorderItem> items)  $default,) {final _that = this;
switch (_that) {
case _ReorderCategoryDto():
return $default(_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ReorderItem> items)?  $default,) {final _that = this;
switch (_that) {
case _ReorderCategoryDto() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReorderCategoryDto implements ReorderCategoryDto {
  const _ReorderCategoryDto({required final  List<ReorderItem> items}): _items = items;
  factory _ReorderCategoryDto.fromJson(Map<String, dynamic> json) => _$ReorderCategoryDtoFromJson(json);

 final  List<ReorderItem> _items;
@override List<ReorderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ReorderCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReorderCategoryDtoCopyWith<_ReorderCategoryDto> get copyWith => __$ReorderCategoryDtoCopyWithImpl<_ReorderCategoryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReorderCategoryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReorderCategoryDto&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ReorderCategoryDto(items: $items)';
}


}

/// @nodoc
abstract mixin class _$ReorderCategoryDtoCopyWith<$Res> implements $ReorderCategoryDtoCopyWith<$Res> {
  factory _$ReorderCategoryDtoCopyWith(_ReorderCategoryDto value, $Res Function(_ReorderCategoryDto) _then) = __$ReorderCategoryDtoCopyWithImpl;
@override @useResult
$Res call({
 List<ReorderItem> items
});




}
/// @nodoc
class __$ReorderCategoryDtoCopyWithImpl<$Res>
    implements _$ReorderCategoryDtoCopyWith<$Res> {
  __$ReorderCategoryDtoCopyWithImpl(this._self, this._then);

  final _ReorderCategoryDto _self;
  final $Res Function(_ReorderCategoryDto) _then;

/// Create a copy of ReorderCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_ReorderCategoryDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ReorderItem>,
  ));
}


}

// dart format on
