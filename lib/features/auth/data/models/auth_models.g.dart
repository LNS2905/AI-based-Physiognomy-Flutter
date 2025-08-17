// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUserDTO _$CreateUserDTOFromJson(Map<String, dynamic> json) =>
    CreateUserDTO(
      username: json['username'] as String?,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      age: (json['age'] as num).toDouble(),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$CreateUserDTOToJson(CreateUserDTO instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'confirmPassword': instance.confirmPassword,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'age': instance.age,
      'gender': _$GenderEnumMap[instance.gender]!,
      'avatar': instance.avatar,
    };

const _$GenderEnumMap = {Gender.male: 'male', Gender.female: 'female'};

UpdateUserDTO _$UpdateUserDTOFromJson(Map<String, dynamic> json) =>
    UpdateUserDTO(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      age: (json['age'] as num).toDouble(),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$UpdateUserDTOToJson(UpdateUserDTO instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'age': instance.age,
      'gender': _$GenderEnumMap[instance.gender]!,
      'avatar': instance.avatar,
    };

AuthRequest _$AuthRequestFromJson(Map<String, dynamic> json) => AuthRequest(
  username: json['username'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$AuthRequestToJson(AuthRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

ChangePasswordDTO _$ChangePasswordDTOFromJson(Map<String, dynamic> json) =>
    ChangePasswordDTO(
      oldPassword: json['oldPassword'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$ChangePasswordDTOToJson(ChangePasswordDTO instance) =>
    <String, dynamic>{
      'oldPassword': instance.oldPassword,
      'password': instance.password,
    };

RequestResetPasswordDTO _$RequestResetPasswordDTOFromJson(
  Map<String, dynamic> json,
) => RequestResetPasswordDTO(email: json['email'] as String);

Map<String, dynamic> _$RequestResetPasswordDTOToJson(
  RequestResetPasswordDTO instance,
) => <String, dynamic>{'email': instance.email};

ResetPasswordDTO _$ResetPasswordDTOFromJson(Map<String, dynamic> json) =>
    ResetPasswordDTO(password: json['password'] as String);

Map<String, dynamic> _$ResetPasswordDTOToJson(ResetPasswordDTO instance) =>
    <String, dynamic>{'password': instance.password};

RefreshTokenRequest _$RefreshTokenRequestFromJson(Map<String, dynamic> json) =>
    RefreshTokenRequest(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshTokenRequestToJson(
  RefreshTokenRequest instance,
) => <String, dynamic>{'refreshToken': instance.refreshToken};

GoogleLoginRequest _$GoogleLoginRequestFromJson(Map<String, dynamic> json) =>
    GoogleLoginRequest(token: json['token'] as String);

Map<String, dynamic> _$GoogleLoginRequestToJson(GoogleLoginRequest instance) =>
    <String, dynamic>{'token': instance.token};

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  age: (json['age'] as num?)?.toInt(),
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  avatar: json['avatar'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phone': instance.phone,
  'age': instance.age,
  'gender': _$GenderEnumMap[instance.gender],
  'avatar': instance.avatar,
};

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    RegisterResponse(user: User.fromJson(json['user'] as Map<String, dynamic>));

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{'user': instance.user};
