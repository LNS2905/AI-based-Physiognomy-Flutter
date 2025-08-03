// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUserDTO _$CreateUserDTOFromJson(Map<String, dynamic> json) =>
    CreateUserDTO(
      username: json['username'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String?,
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
