// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tu_vi_house.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TuViHouse _$TuViHouseFromJson(Map<String, dynamic> json) => TuViHouse(
  houseNumber: (json['house_number'] as num).toInt(),
  branch: json['branch'] as String,
  name: json['name'] as String,
  element: json['element'] as String,
  amDuong: (json['am_duong'] as num).toInt(),
  isBodyHouse: json['is_body_house'] as bool,
  tuanTrung: json['tuan_trung'] as bool,
  trietLo: json['triet_lo'] as bool,
  majorPeriod: (json['major_period'] as num?)?.toInt(),
  minorPeriod: json['minor_period'] as String?,
  stars: (json['stars'] as List<dynamic>)
      .map((e) => TuViStar.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TuViHouseToJson(TuViHouse instance) => <String, dynamic>{
  'house_number': instance.houseNumber,
  'branch': instance.branch,
  'name': instance.name,
  'element': instance.element,
  'am_duong': instance.amDuong,
  'is_body_house': instance.isBodyHouse,
  'tuan_trung': instance.tuanTrung,
  'triet_lo': instance.trietLo,
  'major_period': instance.majorPeriod,
  'minor_period': instance.minorPeriod,
  'stars': instance.stars,
};
