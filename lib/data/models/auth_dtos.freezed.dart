// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WechatCallbackDto {

 String get code;
/// Create a copy of WechatCallbackDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WechatCallbackDtoCopyWith<WechatCallbackDto> get copyWith => _$WechatCallbackDtoCopyWithImpl<WechatCallbackDto>(this as WechatCallbackDto, _$identity);

  /// Serializes this WechatCallbackDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WechatCallbackDto&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'WechatCallbackDto(code: $code)';
}


}

/// @nodoc
abstract mixin class $WechatCallbackDtoCopyWith<$Res>  {
  factory $WechatCallbackDtoCopyWith(WechatCallbackDto value, $Res Function(WechatCallbackDto) _then) = _$WechatCallbackDtoCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$WechatCallbackDtoCopyWithImpl<$Res>
    implements $WechatCallbackDtoCopyWith<$Res> {
  _$WechatCallbackDtoCopyWithImpl(this._self, this._then);

  final WechatCallbackDto _self;
  final $Res Function(WechatCallbackDto) _then;

/// Create a copy of WechatCallbackDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WechatCallbackDto].
extension WechatCallbackDtoPatterns on WechatCallbackDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WechatCallbackDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WechatCallbackDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WechatCallbackDto value)  $default,){
final _that = this;
switch (_that) {
case _WechatCallbackDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WechatCallbackDto value)?  $default,){
final _that = this;
switch (_that) {
case _WechatCallbackDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WechatCallbackDto() when $default != null:
return $default(_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code)  $default,) {final _that = this;
switch (_that) {
case _WechatCallbackDto():
return $default(_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code)?  $default,) {final _that = this;
switch (_that) {
case _WechatCallbackDto() when $default != null:
return $default(_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WechatCallbackDto implements WechatCallbackDto {
  const _WechatCallbackDto({required this.code});
  factory _WechatCallbackDto.fromJson(Map<String, dynamic> json) => _$WechatCallbackDtoFromJson(json);

@override final  String code;

/// Create a copy of WechatCallbackDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WechatCallbackDtoCopyWith<_WechatCallbackDto> get copyWith => __$WechatCallbackDtoCopyWithImpl<_WechatCallbackDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WechatCallbackDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WechatCallbackDto&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'WechatCallbackDto(code: $code)';
}


}

/// @nodoc
abstract mixin class _$WechatCallbackDtoCopyWith<$Res> implements $WechatCallbackDtoCopyWith<$Res> {
  factory _$WechatCallbackDtoCopyWith(_WechatCallbackDto value, $Res Function(_WechatCallbackDto) _then) = __$WechatCallbackDtoCopyWithImpl;
@override @useResult
$Res call({
 String code
});




}
/// @nodoc
class __$WechatCallbackDtoCopyWithImpl<$Res>
    implements _$WechatCallbackDtoCopyWith<$Res> {
  __$WechatCallbackDtoCopyWithImpl(this._self, this._then);

  final _WechatCallbackDto _self;
  final $Res Function(_WechatCallbackDto) _then;

/// Create a copy of WechatCallbackDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(_WechatCallbackDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$EmailLoginDto {

 String get email; String get password;
/// Create a copy of EmailLoginDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailLoginDtoCopyWith<EmailLoginDto> get copyWith => _$EmailLoginDtoCopyWithImpl<EmailLoginDto>(this as EmailLoginDto, _$identity);

  /// Serializes this EmailLoginDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailLoginDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'EmailLoginDto(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class $EmailLoginDtoCopyWith<$Res>  {
  factory $EmailLoginDtoCopyWith(EmailLoginDto value, $Res Function(EmailLoginDto) _then) = _$EmailLoginDtoCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$EmailLoginDtoCopyWithImpl<$Res>
    implements $EmailLoginDtoCopyWith<$Res> {
  _$EmailLoginDtoCopyWithImpl(this._self, this._then);

  final EmailLoginDto _self;
  final $Res Function(EmailLoginDto) _then;

/// Create a copy of EmailLoginDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EmailLoginDto].
extension EmailLoginDtoPatterns on EmailLoginDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmailLoginDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmailLoginDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmailLoginDto value)  $default,){
final _that = this;
switch (_that) {
case _EmailLoginDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmailLoginDto value)?  $default,){
final _that = this;
switch (_that) {
case _EmailLoginDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmailLoginDto() when $default != null:
return $default(_that.email,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password)  $default,) {final _that = this;
switch (_that) {
case _EmailLoginDto():
return $default(_that.email,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password)?  $default,) {final _that = this;
switch (_that) {
case _EmailLoginDto() when $default != null:
return $default(_that.email,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmailLoginDto implements EmailLoginDto {
  const _EmailLoginDto({required this.email, required this.password});
  factory _EmailLoginDto.fromJson(Map<String, dynamic> json) => _$EmailLoginDtoFromJson(json);

@override final  String email;
@override final  String password;

/// Create a copy of EmailLoginDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmailLoginDtoCopyWith<_EmailLoginDto> get copyWith => __$EmailLoginDtoCopyWithImpl<_EmailLoginDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmailLoginDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailLoginDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'EmailLoginDto(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class _$EmailLoginDtoCopyWith<$Res> implements $EmailLoginDtoCopyWith<$Res> {
  factory _$EmailLoginDtoCopyWith(_EmailLoginDto value, $Res Function(_EmailLoginDto) _then) = __$EmailLoginDtoCopyWithImpl;
@override @useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class __$EmailLoginDtoCopyWithImpl<$Res>
    implements _$EmailLoginDtoCopyWith<$Res> {
  __$EmailLoginDtoCopyWithImpl(this._self, this._then);

  final _EmailLoginDto _self;
  final $Res Function(_EmailLoginDto) _then;

/// Create a copy of EmailLoginDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(_EmailLoginDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$EmailSendCodeDto {

 String get email; EmailCodePurpose get purpose;
/// Create a copy of EmailSendCodeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailSendCodeDtoCopyWith<EmailSendCodeDto> get copyWith => _$EmailSendCodeDtoCopyWithImpl<EmailSendCodeDto>(this as EmailSendCodeDto, _$identity);

  /// Serializes this EmailSendCodeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailSendCodeDto&&(identical(other.email, email) || other.email == email)&&(identical(other.purpose, purpose) || other.purpose == purpose));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,purpose);

@override
String toString() {
  return 'EmailSendCodeDto(email: $email, purpose: $purpose)';
}


}

/// @nodoc
abstract mixin class $EmailSendCodeDtoCopyWith<$Res>  {
  factory $EmailSendCodeDtoCopyWith(EmailSendCodeDto value, $Res Function(EmailSendCodeDto) _then) = _$EmailSendCodeDtoCopyWithImpl;
@useResult
$Res call({
 String email, EmailCodePurpose purpose
});




}
/// @nodoc
class _$EmailSendCodeDtoCopyWithImpl<$Res>
    implements $EmailSendCodeDtoCopyWith<$Res> {
  _$EmailSendCodeDtoCopyWithImpl(this._self, this._then);

  final EmailSendCodeDto _self;
  final $Res Function(EmailSendCodeDto) _then;

/// Create a copy of EmailSendCodeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? purpose = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as EmailCodePurpose,
  ));
}

}


/// Adds pattern-matching-related methods to [EmailSendCodeDto].
extension EmailSendCodeDtoPatterns on EmailSendCodeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmailSendCodeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmailSendCodeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmailSendCodeDto value)  $default,){
final _that = this;
switch (_that) {
case _EmailSendCodeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmailSendCodeDto value)?  $default,){
final _that = this;
switch (_that) {
case _EmailSendCodeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  EmailCodePurpose purpose)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmailSendCodeDto() when $default != null:
return $default(_that.email,_that.purpose);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  EmailCodePurpose purpose)  $default,) {final _that = this;
switch (_that) {
case _EmailSendCodeDto():
return $default(_that.email,_that.purpose);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  EmailCodePurpose purpose)?  $default,) {final _that = this;
switch (_that) {
case _EmailSendCodeDto() when $default != null:
return $default(_that.email,_that.purpose);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmailSendCodeDto implements EmailSendCodeDto {
  const _EmailSendCodeDto({required this.email, required this.purpose});
  factory _EmailSendCodeDto.fromJson(Map<String, dynamic> json) => _$EmailSendCodeDtoFromJson(json);

@override final  String email;
@override final  EmailCodePurpose purpose;

/// Create a copy of EmailSendCodeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmailSendCodeDtoCopyWith<_EmailSendCodeDto> get copyWith => __$EmailSendCodeDtoCopyWithImpl<_EmailSendCodeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmailSendCodeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailSendCodeDto&&(identical(other.email, email) || other.email == email)&&(identical(other.purpose, purpose) || other.purpose == purpose));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,purpose);

@override
String toString() {
  return 'EmailSendCodeDto(email: $email, purpose: $purpose)';
}


}

/// @nodoc
abstract mixin class _$EmailSendCodeDtoCopyWith<$Res> implements $EmailSendCodeDtoCopyWith<$Res> {
  factory _$EmailSendCodeDtoCopyWith(_EmailSendCodeDto value, $Res Function(_EmailSendCodeDto) _then) = __$EmailSendCodeDtoCopyWithImpl;
@override @useResult
$Res call({
 String email, EmailCodePurpose purpose
});




}
/// @nodoc
class __$EmailSendCodeDtoCopyWithImpl<$Res>
    implements _$EmailSendCodeDtoCopyWith<$Res> {
  __$EmailSendCodeDtoCopyWithImpl(this._self, this._then);

  final _EmailSendCodeDto _self;
  final $Res Function(_EmailSendCodeDto) _then;

/// Create a copy of EmailSendCodeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? purpose = null,}) {
  return _then(_EmailSendCodeDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as EmailCodePurpose,
  ));
}


}


/// @nodoc
mixin _$EmailRegisterDto {

 String get email; String get password; String get code;
/// Create a copy of EmailRegisterDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailRegisterDtoCopyWith<EmailRegisterDto> get copyWith => _$EmailRegisterDtoCopyWithImpl<EmailRegisterDto>(this as EmailRegisterDto, _$identity);

  /// Serializes this EmailRegisterDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailRegisterDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password,code);

@override
String toString() {
  return 'EmailRegisterDto(email: $email, password: $password, code: $code)';
}


}

/// @nodoc
abstract mixin class $EmailRegisterDtoCopyWith<$Res>  {
  factory $EmailRegisterDtoCopyWith(EmailRegisterDto value, $Res Function(EmailRegisterDto) _then) = _$EmailRegisterDtoCopyWithImpl;
@useResult
$Res call({
 String email, String password, String code
});




}
/// @nodoc
class _$EmailRegisterDtoCopyWithImpl<$Res>
    implements $EmailRegisterDtoCopyWith<$Res> {
  _$EmailRegisterDtoCopyWithImpl(this._self, this._then);

  final EmailRegisterDto _self;
  final $Res Function(EmailRegisterDto) _then;

/// Create a copy of EmailRegisterDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? code = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EmailRegisterDto].
extension EmailRegisterDtoPatterns on EmailRegisterDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmailRegisterDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmailRegisterDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmailRegisterDto value)  $default,){
final _that = this;
switch (_that) {
case _EmailRegisterDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmailRegisterDto value)?  $default,){
final _that = this;
switch (_that) {
case _EmailRegisterDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmailRegisterDto() when $default != null:
return $default(_that.email,_that.password,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  String code)  $default,) {final _that = this;
switch (_that) {
case _EmailRegisterDto():
return $default(_that.email,_that.password,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  String code)?  $default,) {final _that = this;
switch (_that) {
case _EmailRegisterDto() when $default != null:
return $default(_that.email,_that.password,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmailRegisterDto implements EmailRegisterDto {
  const _EmailRegisterDto({required this.email, required this.password, required this.code});
  factory _EmailRegisterDto.fromJson(Map<String, dynamic> json) => _$EmailRegisterDtoFromJson(json);

@override final  String email;
@override final  String password;
@override final  String code;

/// Create a copy of EmailRegisterDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmailRegisterDtoCopyWith<_EmailRegisterDto> get copyWith => __$EmailRegisterDtoCopyWithImpl<_EmailRegisterDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmailRegisterDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailRegisterDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password,code);

@override
String toString() {
  return 'EmailRegisterDto(email: $email, password: $password, code: $code)';
}


}

/// @nodoc
abstract mixin class _$EmailRegisterDtoCopyWith<$Res> implements $EmailRegisterDtoCopyWith<$Res> {
  factory _$EmailRegisterDtoCopyWith(_EmailRegisterDto value, $Res Function(_EmailRegisterDto) _then) = __$EmailRegisterDtoCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, String code
});




}
/// @nodoc
class __$EmailRegisterDtoCopyWithImpl<$Res>
    implements _$EmailRegisterDtoCopyWith<$Res> {
  __$EmailRegisterDtoCopyWithImpl(this._self, this._then);

  final _EmailRegisterDto _self;
  final $Res Function(_EmailRegisterDto) _then;

/// Create a copy of EmailRegisterDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? code = null,}) {
  return _then(_EmailRegisterDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$EmailResetPasswordDto {

 String get email; String get password; String get code;
/// Create a copy of EmailResetPasswordDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailResetPasswordDtoCopyWith<EmailResetPasswordDto> get copyWith => _$EmailResetPasswordDtoCopyWithImpl<EmailResetPasswordDto>(this as EmailResetPasswordDto, _$identity);

  /// Serializes this EmailResetPasswordDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailResetPasswordDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password,code);

@override
String toString() {
  return 'EmailResetPasswordDto(email: $email, password: $password, code: $code)';
}


}

/// @nodoc
abstract mixin class $EmailResetPasswordDtoCopyWith<$Res>  {
  factory $EmailResetPasswordDtoCopyWith(EmailResetPasswordDto value, $Res Function(EmailResetPasswordDto) _then) = _$EmailResetPasswordDtoCopyWithImpl;
@useResult
$Res call({
 String email, String password, String code
});




}
/// @nodoc
class _$EmailResetPasswordDtoCopyWithImpl<$Res>
    implements $EmailResetPasswordDtoCopyWith<$Res> {
  _$EmailResetPasswordDtoCopyWithImpl(this._self, this._then);

  final EmailResetPasswordDto _self;
  final $Res Function(EmailResetPasswordDto) _then;

/// Create a copy of EmailResetPasswordDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? code = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EmailResetPasswordDto].
extension EmailResetPasswordDtoPatterns on EmailResetPasswordDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmailResetPasswordDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmailResetPasswordDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmailResetPasswordDto value)  $default,){
final _that = this;
switch (_that) {
case _EmailResetPasswordDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmailResetPasswordDto value)?  $default,){
final _that = this;
switch (_that) {
case _EmailResetPasswordDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmailResetPasswordDto() when $default != null:
return $default(_that.email,_that.password,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  String code)  $default,) {final _that = this;
switch (_that) {
case _EmailResetPasswordDto():
return $default(_that.email,_that.password,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  String code)?  $default,) {final _that = this;
switch (_that) {
case _EmailResetPasswordDto() when $default != null:
return $default(_that.email,_that.password,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmailResetPasswordDto implements EmailResetPasswordDto {
  const _EmailResetPasswordDto({required this.email, required this.password, required this.code});
  factory _EmailResetPasswordDto.fromJson(Map<String, dynamic> json) => _$EmailResetPasswordDtoFromJson(json);

@override final  String email;
@override final  String password;
@override final  String code;

/// Create a copy of EmailResetPasswordDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmailResetPasswordDtoCopyWith<_EmailResetPasswordDto> get copyWith => __$EmailResetPasswordDtoCopyWithImpl<_EmailResetPasswordDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmailResetPasswordDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailResetPasswordDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password,code);

@override
String toString() {
  return 'EmailResetPasswordDto(email: $email, password: $password, code: $code)';
}


}

/// @nodoc
abstract mixin class _$EmailResetPasswordDtoCopyWith<$Res> implements $EmailResetPasswordDtoCopyWith<$Res> {
  factory _$EmailResetPasswordDtoCopyWith(_EmailResetPasswordDto value, $Res Function(_EmailResetPasswordDto) _then) = __$EmailResetPasswordDtoCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, String code
});




}
/// @nodoc
class __$EmailResetPasswordDtoCopyWithImpl<$Res>
    implements _$EmailResetPasswordDtoCopyWith<$Res> {
  __$EmailResetPasswordDtoCopyWithImpl(this._self, this._then);

  final _EmailResetPasswordDto _self;
  final $Res Function(_EmailResetPasswordDto) _then;

/// Create a copy of EmailResetPasswordDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? code = null,}) {
  return _then(_EmailResetPasswordDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TokenResponseDto {

 String get accessToken; String get refreshToken; int get expiresIn;
/// Create a copy of TokenResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenResponseDtoCopyWith<TokenResponseDto> get copyWith => _$TokenResponseDtoCopyWithImpl<TokenResponseDto>(this as TokenResponseDto, _$identity);

  /// Serializes this TokenResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenResponseDto&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,expiresIn);

@override
String toString() {
  return 'TokenResponseDto(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class $TokenResponseDtoCopyWith<$Res>  {
  factory $TokenResponseDtoCopyWith(TokenResponseDto value, $Res Function(TokenResponseDto) _then) = _$TokenResponseDtoCopyWithImpl;
@useResult
$Res call({
 String accessToken, String refreshToken, int expiresIn
});




}
/// @nodoc
class _$TokenResponseDtoCopyWithImpl<$Res>
    implements $TokenResponseDtoCopyWith<$Res> {
  _$TokenResponseDtoCopyWithImpl(this._self, this._then);

  final TokenResponseDto _self;
  final $Res Function(TokenResponseDto) _then;

/// Create a copy of TokenResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = null,Object? expiresIn = null,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TokenResponseDto].
extension TokenResponseDtoPatterns on TokenResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TokenResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TokenResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TokenResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _TokenResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TokenResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _TokenResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  int expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TokenResponseDto() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  int expiresIn)  $default,) {final _that = this;
switch (_that) {
case _TokenResponseDto():
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  String refreshToken,  int expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _TokenResponseDto() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TokenResponseDto implements TokenResponseDto {
  const _TokenResponseDto({required this.accessToken, required this.refreshToken, required this.expiresIn});
  factory _TokenResponseDto.fromJson(Map<String, dynamic> json) => _$TokenResponseDtoFromJson(json);

@override final  String accessToken;
@override final  String refreshToken;
@override final  int expiresIn;

/// Create a copy of TokenResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenResponseDtoCopyWith<_TokenResponseDto> get copyWith => __$TokenResponseDtoCopyWithImpl<_TokenResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TokenResponseDto&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,expiresIn);

@override
String toString() {
  return 'TokenResponseDto(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class _$TokenResponseDtoCopyWith<$Res> implements $TokenResponseDtoCopyWith<$Res> {
  factory _$TokenResponseDtoCopyWith(_TokenResponseDto value, $Res Function(_TokenResponseDto) _then) = __$TokenResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, String refreshToken, int expiresIn
});




}
/// @nodoc
class __$TokenResponseDtoCopyWithImpl<$Res>
    implements _$TokenResponseDtoCopyWith<$Res> {
  __$TokenResponseDtoCopyWithImpl(this._self, this._then);

  final _TokenResponseDto _self;
  final $Res Function(_TokenResponseDto) _then;

/// Create a copy of TokenResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = null,Object? expiresIn = null,}) {
  return _then(_TokenResponseDto(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RefreshTokenDto {

 String get refreshToken;
/// Create a copy of RefreshTokenDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefreshTokenDtoCopyWith<RefreshTokenDto> get copyWith => _$RefreshTokenDtoCopyWithImpl<RefreshTokenDto>(this as RefreshTokenDto, _$identity);

  /// Serializes this RefreshTokenDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshTokenDto&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'RefreshTokenDto(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $RefreshTokenDtoCopyWith<$Res>  {
  factory $RefreshTokenDtoCopyWith(RefreshTokenDto value, $Res Function(RefreshTokenDto) _then) = _$RefreshTokenDtoCopyWithImpl;
@useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class _$RefreshTokenDtoCopyWithImpl<$Res>
    implements $RefreshTokenDtoCopyWith<$Res> {
  _$RefreshTokenDtoCopyWithImpl(this._self, this._then);

  final RefreshTokenDto _self;
  final $Res Function(RefreshTokenDto) _then;

/// Create a copy of RefreshTokenDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refreshToken = null,}) {
  return _then(_self.copyWith(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RefreshTokenDto].
extension RefreshTokenDtoPatterns on RefreshTokenDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefreshTokenDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefreshTokenDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefreshTokenDto value)  $default,){
final _that = this;
switch (_that) {
case _RefreshTokenDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefreshTokenDto value)?  $default,){
final _that = this;
switch (_that) {
case _RefreshTokenDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefreshTokenDto() when $default != null:
return $default(_that.refreshToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String refreshToken)  $default,) {final _that = this;
switch (_that) {
case _RefreshTokenDto():
return $default(_that.refreshToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _RefreshTokenDto() when $default != null:
return $default(_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RefreshTokenDto implements RefreshTokenDto {
  const _RefreshTokenDto({required this.refreshToken});
  factory _RefreshTokenDto.fromJson(Map<String, dynamic> json) => _$RefreshTokenDtoFromJson(json);

@override final  String refreshToken;

/// Create a copy of RefreshTokenDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshTokenDtoCopyWith<_RefreshTokenDto> get copyWith => __$RefreshTokenDtoCopyWithImpl<_RefreshTokenDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RefreshTokenDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshTokenDto&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'RefreshTokenDto(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$RefreshTokenDtoCopyWith<$Res> implements $RefreshTokenDtoCopyWith<$Res> {
  factory _$RefreshTokenDtoCopyWith(_RefreshTokenDto value, $Res Function(_RefreshTokenDto) _then) = __$RefreshTokenDtoCopyWithImpl;
@override @useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class __$RefreshTokenDtoCopyWithImpl<$Res>
    implements _$RefreshTokenDtoCopyWith<$Res> {
  __$RefreshTokenDtoCopyWithImpl(this._self, this._then);

  final _RefreshTokenDto _self;
  final $Res Function(_RefreshTokenDto) _then;

/// Create a copy of RefreshTokenDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refreshToken = null,}) {
  return _then(_RefreshTokenDto(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LogoutResponseDto {

 bool get success;
/// Create a copy of LogoutResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogoutResponseDtoCopyWith<LogoutResponseDto> get copyWith => _$LogoutResponseDtoCopyWithImpl<LogoutResponseDto>(this as LogoutResponseDto, _$identity);

  /// Serializes this LogoutResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogoutResponseDto&&(identical(other.success, success) || other.success == success));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success);

@override
String toString() {
  return 'LogoutResponseDto(success: $success)';
}


}

/// @nodoc
abstract mixin class $LogoutResponseDtoCopyWith<$Res>  {
  factory $LogoutResponseDtoCopyWith(LogoutResponseDto value, $Res Function(LogoutResponseDto) _then) = _$LogoutResponseDtoCopyWithImpl;
@useResult
$Res call({
 bool success
});




}
/// @nodoc
class _$LogoutResponseDtoCopyWithImpl<$Res>
    implements $LogoutResponseDtoCopyWith<$Res> {
  _$LogoutResponseDtoCopyWithImpl(this._self, this._then);

  final LogoutResponseDto _self;
  final $Res Function(LogoutResponseDto) _then;

/// Create a copy of LogoutResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LogoutResponseDto].
extension LogoutResponseDtoPatterns on LogoutResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogoutResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogoutResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogoutResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _LogoutResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogoutResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _LogoutResponseDto() when $default != null:
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
case _LogoutResponseDto() when $default != null:
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
case _LogoutResponseDto():
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
case _LogoutResponseDto() when $default != null:
return $default(_that.success);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LogoutResponseDto implements LogoutResponseDto {
  const _LogoutResponseDto({required this.success});
  factory _LogoutResponseDto.fromJson(Map<String, dynamic> json) => _$LogoutResponseDtoFromJson(json);

@override final  bool success;

/// Create a copy of LogoutResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogoutResponseDtoCopyWith<_LogoutResponseDto> get copyWith => __$LogoutResponseDtoCopyWithImpl<_LogoutResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LogoutResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogoutResponseDto&&(identical(other.success, success) || other.success == success));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success);

@override
String toString() {
  return 'LogoutResponseDto(success: $success)';
}


}

/// @nodoc
abstract mixin class _$LogoutResponseDtoCopyWith<$Res> implements $LogoutResponseDtoCopyWith<$Res> {
  factory _$LogoutResponseDtoCopyWith(_LogoutResponseDto value, $Res Function(_LogoutResponseDto) _then) = __$LogoutResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 bool success
});




}
/// @nodoc
class __$LogoutResponseDtoCopyWithImpl<$Res>
    implements _$LogoutResponseDtoCopyWith<$Res> {
  __$LogoutResponseDtoCopyWithImpl(this._self, this._then);

  final _LogoutResponseDto _self;
  final $Res Function(_LogoutResponseDto) _then;

/// Create a copy of LogoutResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,}) {
  return _then(_LogoutResponseDto(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
