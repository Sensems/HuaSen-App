// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfileDto {

 String? get id; String? get email; String? get nickname; String? get avatar;/// 6-digit code for WeChat official-account binding when unbound.
 String? get bindingCode; bool? get wxBound;
/// Create a copy of UserProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileDtoCopyWith<UserProfileDto> get copyWith => _$UserProfileDtoCopyWithImpl<UserProfileDto>(this as UserProfileDto, _$identity);

  /// Serializes this UserProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileDto&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.bindingCode, bindingCode) || other.bindingCode == bindingCode)&&(identical(other.wxBound, wxBound) || other.wxBound == wxBound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,nickname,avatar,bindingCode,wxBound);

@override
String toString() {
  return 'UserProfileDto(id: $id, email: $email, nickname: $nickname, avatar: $avatar, bindingCode: $bindingCode, wxBound: $wxBound)';
}


}

/// @nodoc
abstract mixin class $UserProfileDtoCopyWith<$Res>  {
  factory $UserProfileDtoCopyWith(UserProfileDto value, $Res Function(UserProfileDto) _then) = _$UserProfileDtoCopyWithImpl;
@useResult
$Res call({
 String? id, String? email, String? nickname, String? avatar, String? bindingCode, bool? wxBound
});




}
/// @nodoc
class _$UserProfileDtoCopyWithImpl<$Res>
    implements $UserProfileDtoCopyWith<$Res> {
  _$UserProfileDtoCopyWithImpl(this._self, this._then);

  final UserProfileDto _self;
  final $Res Function(UserProfileDto) _then;

/// Create a copy of UserProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? email = freezed,Object? nickname = freezed,Object? avatar = freezed,Object? bindingCode = freezed,Object? wxBound = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,bindingCode: freezed == bindingCode ? _self.bindingCode : bindingCode // ignore: cast_nullable_to_non_nullable
as String?,wxBound: freezed == wxBound ? _self.wxBound : wxBound // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileDto].
extension UserProfileDtoPatterns on UserProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? email,  String? nickname,  String? avatar,  String? bindingCode,  bool? wxBound)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileDto() when $default != null:
return $default(_that.id,_that.email,_that.nickname,_that.avatar,_that.bindingCode,_that.wxBound);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? email,  String? nickname,  String? avatar,  String? bindingCode,  bool? wxBound)  $default,) {final _that = this;
switch (_that) {
case _UserProfileDto():
return $default(_that.id,_that.email,_that.nickname,_that.avatar,_that.bindingCode,_that.wxBound);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? email,  String? nickname,  String? avatar,  String? bindingCode,  bool? wxBound)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileDto() when $default != null:
return $default(_that.id,_that.email,_that.nickname,_that.avatar,_that.bindingCode,_that.wxBound);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileDto implements UserProfileDto {
  const _UserProfileDto({this.id, this.email, this.nickname, this.avatar, this.bindingCode, this.wxBound});
  factory _UserProfileDto.fromJson(Map<String, dynamic> json) => _$UserProfileDtoFromJson(json);

@override final  String? id;
@override final  String? email;
@override final  String? nickname;
@override final  String? avatar;
/// 6-digit code for WeChat official-account binding when unbound.
@override final  String? bindingCode;
@override final  bool? wxBound;

/// Create a copy of UserProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileDtoCopyWith<_UserProfileDto> get copyWith => __$UserProfileDtoCopyWithImpl<_UserProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileDto&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.bindingCode, bindingCode) || other.bindingCode == bindingCode)&&(identical(other.wxBound, wxBound) || other.wxBound == wxBound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,nickname,avatar,bindingCode,wxBound);

@override
String toString() {
  return 'UserProfileDto(id: $id, email: $email, nickname: $nickname, avatar: $avatar, bindingCode: $bindingCode, wxBound: $wxBound)';
}


}

/// @nodoc
abstract mixin class _$UserProfileDtoCopyWith<$Res> implements $UserProfileDtoCopyWith<$Res> {
  factory _$UserProfileDtoCopyWith(_UserProfileDto value, $Res Function(_UserProfileDto) _then) = __$UserProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? email, String? nickname, String? avatar, String? bindingCode, bool? wxBound
});




}
/// @nodoc
class __$UserProfileDtoCopyWithImpl<$Res>
    implements _$UserProfileDtoCopyWith<$Res> {
  __$UserProfileDtoCopyWithImpl(this._self, this._then);

  final _UserProfileDto _self;
  final $Res Function(_UserProfileDto) _then;

/// Create a copy of UserProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? email = freezed,Object? nickname = freezed,Object? avatar = freezed,Object? bindingCode = freezed,Object? wxBound = freezed,}) {
  return _then(_UserProfileDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,bindingCode: freezed == bindingCode ? _self.bindingCode : bindingCode // ignore: cast_nullable_to_non_nullable
as String?,wxBound: freezed == wxBound ? _self.wxBound : wxBound // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$UpdateProfileDto {

@JsonKey(includeIfNull: false) String? get nickname;@JsonKey(includeIfNull: false) String? get avatar;
/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateProfileDtoCopyWith<UpdateProfileDto> get copyWith => _$UpdateProfileDtoCopyWithImpl<UpdateProfileDto>(this as UpdateProfileDto, _$identity);

  /// Serializes this UpdateProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateProfileDto&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nickname,avatar);

@override
String toString() {
  return 'UpdateProfileDto(nickname: $nickname, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class $UpdateProfileDtoCopyWith<$Res>  {
  factory $UpdateProfileDtoCopyWith(UpdateProfileDto value, $Res Function(UpdateProfileDto) _then) = _$UpdateProfileDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? nickname,@JsonKey(includeIfNull: false) String? avatar
});




}
/// @nodoc
class _$UpdateProfileDtoCopyWithImpl<$Res>
    implements $UpdateProfileDtoCopyWith<$Res> {
  _$UpdateProfileDtoCopyWithImpl(this._self, this._then);

  final UpdateProfileDto _self;
  final $Res Function(UpdateProfileDto) _then;

/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nickname = freezed,Object? avatar = freezed,}) {
  return _then(_self.copyWith(
nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateProfileDto].
extension UpdateProfileDtoPatterns on UpdateProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? nickname, @JsonKey(includeIfNull: false)  String? avatar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateProfileDto() when $default != null:
return $default(_that.nickname,_that.avatar);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? nickname, @JsonKey(includeIfNull: false)  String? avatar)  $default,) {final _that = this;
switch (_that) {
case _UpdateProfileDto():
return $default(_that.nickname,_that.avatar);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? nickname, @JsonKey(includeIfNull: false)  String? avatar)?  $default,) {final _that = this;
switch (_that) {
case _UpdateProfileDto() when $default != null:
return $default(_that.nickname,_that.avatar);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateProfileDto implements UpdateProfileDto {
  const _UpdateProfileDto({@JsonKey(includeIfNull: false) this.nickname, @JsonKey(includeIfNull: false) this.avatar});
  factory _UpdateProfileDto.fromJson(Map<String, dynamic> json) => _$UpdateProfileDtoFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? nickname;
@override@JsonKey(includeIfNull: false) final  String? avatar;

/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateProfileDtoCopyWith<_UpdateProfileDto> get copyWith => __$UpdateProfileDtoCopyWithImpl<_UpdateProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateProfileDto&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nickname,avatar);

@override
String toString() {
  return 'UpdateProfileDto(nickname: $nickname, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class _$UpdateProfileDtoCopyWith<$Res> implements $UpdateProfileDtoCopyWith<$Res> {
  factory _$UpdateProfileDtoCopyWith(_UpdateProfileDto value, $Res Function(_UpdateProfileDto) _then) = __$UpdateProfileDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? nickname,@JsonKey(includeIfNull: false) String? avatar
});




}
/// @nodoc
class __$UpdateProfileDtoCopyWithImpl<$Res>
    implements _$UpdateProfileDtoCopyWith<$Res> {
  __$UpdateProfileDtoCopyWithImpl(this._self, this._then);

  final _UpdateProfileDto _self;
  final $Res Function(_UpdateProfileDto) _then;

/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nickname = freezed,Object? avatar = freezed,}) {
  return _then(_UpdateProfileDto(
nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BindUserDto {

 String get bindingCode;
/// Create a copy of BindUserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BindUserDtoCopyWith<BindUserDto> get copyWith => _$BindUserDtoCopyWithImpl<BindUserDto>(this as BindUserDto, _$identity);

  /// Serializes this BindUserDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BindUserDto&&(identical(other.bindingCode, bindingCode) || other.bindingCode == bindingCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bindingCode);

@override
String toString() {
  return 'BindUserDto(bindingCode: $bindingCode)';
}


}

/// @nodoc
abstract mixin class $BindUserDtoCopyWith<$Res>  {
  factory $BindUserDtoCopyWith(BindUserDto value, $Res Function(BindUserDto) _then) = _$BindUserDtoCopyWithImpl;
@useResult
$Res call({
 String bindingCode
});




}
/// @nodoc
class _$BindUserDtoCopyWithImpl<$Res>
    implements $BindUserDtoCopyWith<$Res> {
  _$BindUserDtoCopyWithImpl(this._self, this._then);

  final BindUserDto _self;
  final $Res Function(BindUserDto) _then;

/// Create a copy of BindUserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bindingCode = null,}) {
  return _then(_self.copyWith(
bindingCode: null == bindingCode ? _self.bindingCode : bindingCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BindUserDto].
extension BindUserDtoPatterns on BindUserDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BindUserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BindUserDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BindUserDto value)  $default,){
final _that = this;
switch (_that) {
case _BindUserDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BindUserDto value)?  $default,){
final _that = this;
switch (_that) {
case _BindUserDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bindingCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BindUserDto() when $default != null:
return $default(_that.bindingCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bindingCode)  $default,) {final _that = this;
switch (_that) {
case _BindUserDto():
return $default(_that.bindingCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bindingCode)?  $default,) {final _that = this;
switch (_that) {
case _BindUserDto() when $default != null:
return $default(_that.bindingCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BindUserDto implements BindUserDto {
  const _BindUserDto({required this.bindingCode});
  factory _BindUserDto.fromJson(Map<String, dynamic> json) => _$BindUserDtoFromJson(json);

@override final  String bindingCode;

/// Create a copy of BindUserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BindUserDtoCopyWith<_BindUserDto> get copyWith => __$BindUserDtoCopyWithImpl<_BindUserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BindUserDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BindUserDto&&(identical(other.bindingCode, bindingCode) || other.bindingCode == bindingCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bindingCode);

@override
String toString() {
  return 'BindUserDto(bindingCode: $bindingCode)';
}


}

/// @nodoc
abstract mixin class _$BindUserDtoCopyWith<$Res> implements $BindUserDtoCopyWith<$Res> {
  factory _$BindUserDtoCopyWith(_BindUserDto value, $Res Function(_BindUserDto) _then) = __$BindUserDtoCopyWithImpl;
@override @useResult
$Res call({
 String bindingCode
});




}
/// @nodoc
class __$BindUserDtoCopyWithImpl<$Res>
    implements _$BindUserDtoCopyWith<$Res> {
  __$BindUserDtoCopyWithImpl(this._self, this._then);

  final _BindUserDto _self;
  final $Res Function(_BindUserDto) _then;

/// Create a copy of BindUserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bindingCode = null,}) {
  return _then(_BindUserDto(
bindingCode: null == bindingCode ? _self.bindingCode : bindingCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BindUserResponseDto {

 bool get wxBound; int get syncedDraftCount; bool get overwritten; String get message;
/// Create a copy of BindUserResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BindUserResponseDtoCopyWith<BindUserResponseDto> get copyWith => _$BindUserResponseDtoCopyWithImpl<BindUserResponseDto>(this as BindUserResponseDto, _$identity);

  /// Serializes this BindUserResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BindUserResponseDto&&(identical(other.wxBound, wxBound) || other.wxBound == wxBound)&&(identical(other.syncedDraftCount, syncedDraftCount) || other.syncedDraftCount == syncedDraftCount)&&(identical(other.overwritten, overwritten) || other.overwritten == overwritten)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wxBound,syncedDraftCount,overwritten,message);

@override
String toString() {
  return 'BindUserResponseDto(wxBound: $wxBound, syncedDraftCount: $syncedDraftCount, overwritten: $overwritten, message: $message)';
}


}

/// @nodoc
abstract mixin class $BindUserResponseDtoCopyWith<$Res>  {
  factory $BindUserResponseDtoCopyWith(BindUserResponseDto value, $Res Function(BindUserResponseDto) _then) = _$BindUserResponseDtoCopyWithImpl;
@useResult
$Res call({
 bool wxBound, int syncedDraftCount, bool overwritten, String message
});




}
/// @nodoc
class _$BindUserResponseDtoCopyWithImpl<$Res>
    implements $BindUserResponseDtoCopyWith<$Res> {
  _$BindUserResponseDtoCopyWithImpl(this._self, this._then);

  final BindUserResponseDto _self;
  final $Res Function(BindUserResponseDto) _then;

/// Create a copy of BindUserResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wxBound = null,Object? syncedDraftCount = null,Object? overwritten = null,Object? message = null,}) {
  return _then(_self.copyWith(
wxBound: null == wxBound ? _self.wxBound : wxBound // ignore: cast_nullable_to_non_nullable
as bool,syncedDraftCount: null == syncedDraftCount ? _self.syncedDraftCount : syncedDraftCount // ignore: cast_nullable_to_non_nullable
as int,overwritten: null == overwritten ? _self.overwritten : overwritten // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BindUserResponseDto].
extension BindUserResponseDtoPatterns on BindUserResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BindUserResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BindUserResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BindUserResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _BindUserResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BindUserResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _BindUserResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool wxBound,  int syncedDraftCount,  bool overwritten,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BindUserResponseDto() when $default != null:
return $default(_that.wxBound,_that.syncedDraftCount,_that.overwritten,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool wxBound,  int syncedDraftCount,  bool overwritten,  String message)  $default,) {final _that = this;
switch (_that) {
case _BindUserResponseDto():
return $default(_that.wxBound,_that.syncedDraftCount,_that.overwritten,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool wxBound,  int syncedDraftCount,  bool overwritten,  String message)?  $default,) {final _that = this;
switch (_that) {
case _BindUserResponseDto() when $default != null:
return $default(_that.wxBound,_that.syncedDraftCount,_that.overwritten,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BindUserResponseDto implements BindUserResponseDto {
  const _BindUserResponseDto({required this.wxBound, required this.syncedDraftCount, required this.overwritten, required this.message});
  factory _BindUserResponseDto.fromJson(Map<String, dynamic> json) => _$BindUserResponseDtoFromJson(json);

@override final  bool wxBound;
@override final  int syncedDraftCount;
@override final  bool overwritten;
@override final  String message;

/// Create a copy of BindUserResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BindUserResponseDtoCopyWith<_BindUserResponseDto> get copyWith => __$BindUserResponseDtoCopyWithImpl<_BindUserResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BindUserResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BindUserResponseDto&&(identical(other.wxBound, wxBound) || other.wxBound == wxBound)&&(identical(other.syncedDraftCount, syncedDraftCount) || other.syncedDraftCount == syncedDraftCount)&&(identical(other.overwritten, overwritten) || other.overwritten == overwritten)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wxBound,syncedDraftCount,overwritten,message);

@override
String toString() {
  return 'BindUserResponseDto(wxBound: $wxBound, syncedDraftCount: $syncedDraftCount, overwritten: $overwritten, message: $message)';
}


}

/// @nodoc
abstract mixin class _$BindUserResponseDtoCopyWith<$Res> implements $BindUserResponseDtoCopyWith<$Res> {
  factory _$BindUserResponseDtoCopyWith(_BindUserResponseDto value, $Res Function(_BindUserResponseDto) _then) = __$BindUserResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 bool wxBound, int syncedDraftCount, bool overwritten, String message
});




}
/// @nodoc
class __$BindUserResponseDtoCopyWithImpl<$Res>
    implements _$BindUserResponseDtoCopyWith<$Res> {
  __$BindUserResponseDtoCopyWithImpl(this._self, this._then);

  final _BindUserResponseDto _self;
  final $Res Function(_BindUserResponseDto) _then;

/// Create a copy of BindUserResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wxBound = null,Object? syncedDraftCount = null,Object? overwritten = null,Object? message = null,}) {
  return _then(_BindUserResponseDto(
wxBound: null == wxBound ? _self.wxBound : wxBound // ignore: cast_nullable_to_non_nullable
as bool,syncedDraftCount: null == syncedDraftCount ? _self.syncedDraftCount : syncedDraftCount // ignore: cast_nullable_to_non_nullable
as int,overwritten: null == overwritten ? _self.overwritten : overwritten // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UnbindWechatResponseDto {

 bool get wxBound; String get message;
/// Create a copy of UnbindWechatResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnbindWechatResponseDtoCopyWith<UnbindWechatResponseDto> get copyWith => _$UnbindWechatResponseDtoCopyWithImpl<UnbindWechatResponseDto>(this as UnbindWechatResponseDto, _$identity);

  /// Serializes this UnbindWechatResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnbindWechatResponseDto&&(identical(other.wxBound, wxBound) || other.wxBound == wxBound)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wxBound,message);

@override
String toString() {
  return 'UnbindWechatResponseDto(wxBound: $wxBound, message: $message)';
}


}

/// @nodoc
abstract mixin class $UnbindWechatResponseDtoCopyWith<$Res>  {
  factory $UnbindWechatResponseDtoCopyWith(UnbindWechatResponseDto value, $Res Function(UnbindWechatResponseDto) _then) = _$UnbindWechatResponseDtoCopyWithImpl;
@useResult
$Res call({
 bool wxBound, String message
});




}
/// @nodoc
class _$UnbindWechatResponseDtoCopyWithImpl<$Res>
    implements $UnbindWechatResponseDtoCopyWith<$Res> {
  _$UnbindWechatResponseDtoCopyWithImpl(this._self, this._then);

  final UnbindWechatResponseDto _self;
  final $Res Function(UnbindWechatResponseDto) _then;

/// Create a copy of UnbindWechatResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wxBound = null,Object? message = null,}) {
  return _then(_self.copyWith(
wxBound: null == wxBound ? _self.wxBound : wxBound // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UnbindWechatResponseDto].
extension UnbindWechatResponseDtoPatterns on UnbindWechatResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnbindWechatResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnbindWechatResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnbindWechatResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _UnbindWechatResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnbindWechatResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _UnbindWechatResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool wxBound,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnbindWechatResponseDto() when $default != null:
return $default(_that.wxBound,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool wxBound,  String message)  $default,) {final _that = this;
switch (_that) {
case _UnbindWechatResponseDto():
return $default(_that.wxBound,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool wxBound,  String message)?  $default,) {final _that = this;
switch (_that) {
case _UnbindWechatResponseDto() when $default != null:
return $default(_that.wxBound,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnbindWechatResponseDto implements UnbindWechatResponseDto {
  const _UnbindWechatResponseDto({required this.wxBound, required this.message});
  factory _UnbindWechatResponseDto.fromJson(Map<String, dynamic> json) => _$UnbindWechatResponseDtoFromJson(json);

@override final  bool wxBound;
@override final  String message;

/// Create a copy of UnbindWechatResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnbindWechatResponseDtoCopyWith<_UnbindWechatResponseDto> get copyWith => __$UnbindWechatResponseDtoCopyWithImpl<_UnbindWechatResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnbindWechatResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnbindWechatResponseDto&&(identical(other.wxBound, wxBound) || other.wxBound == wxBound)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wxBound,message);

@override
String toString() {
  return 'UnbindWechatResponseDto(wxBound: $wxBound, message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnbindWechatResponseDtoCopyWith<$Res> implements $UnbindWechatResponseDtoCopyWith<$Res> {
  factory _$UnbindWechatResponseDtoCopyWith(_UnbindWechatResponseDto value, $Res Function(_UnbindWechatResponseDto) _then) = __$UnbindWechatResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 bool wxBound, String message
});




}
/// @nodoc
class __$UnbindWechatResponseDtoCopyWithImpl<$Res>
    implements _$UnbindWechatResponseDtoCopyWith<$Res> {
  __$UnbindWechatResponseDtoCopyWithImpl(this._self, this._then);

  final _UnbindWechatResponseDto _self;
  final $Res Function(_UnbindWechatResponseDto) _then;

/// Create a copy of UnbindWechatResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wxBound = null,Object? message = null,}) {
  return _then(_UnbindWechatResponseDto(
wxBound: null == wxBound ? _self.wxBound : wxBound // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
