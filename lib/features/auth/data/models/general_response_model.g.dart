// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneralResponse<T> _$GeneralResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => GeneralResponse<T>(
  data: fromJsonT(json['data']),
  code: json['code'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$GeneralResponseToJson<T>(
  GeneralResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'data': toJsonT(instance.data),
  'code': instance.code,
  'message': instance.message,
};
