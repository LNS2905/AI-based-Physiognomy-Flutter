// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tu_vi_star.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TuViStar _$TuViStarFromJson(Map<String, dynamic> json) => TuViStar(
  starId: (json['star_id'] as num).toInt(),
  name: json['name'] as String,
  element: json['element'] as String,
  category: (json['category'] as num).toInt(),
  strength: json['strength'] as String?,
  direction: json['direction'] as String?,
  amDuong: json['am_duong'],
  trangSinh: (json['trang_sinh'] as num).toInt(),
  cssClass: json['css_class'] as String?,
);

Map<String, dynamic> _$TuViStarToJson(TuViStar instance) => <String, dynamic>{
  'star_id': instance.starId,
  'name': instance.name,
  'element': instance.element,
  'category': instance.category,
  'strength': instance.strength,
  'direction': instance.direction,
  'am_duong': instance.amDuong,
  'trang_sinh': instance.trangSinh,
  'css_class': instance.cssClass,
};
