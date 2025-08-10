// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

const _$GenderEnumMap = {Gender.male: 'male', Gender.female: 'female'};
