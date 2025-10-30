// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tu_vi_extra.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TuViExtra _$TuViExtraFromJson(Map<String, dynamic> json) => TuViExtra(
  name: json['name'] as String?,
  gender: json['gender'] as String,
  genderValue: (json['gender_value'] as num).toInt(),
  hour: json['hour'] as String,
  hourCanChi: json['hour_can_chi'] as String,
  solarDate: json['solar_date'] as String,
  lunarDate: json['lunar_date'] as String,
  thangNhuan: (json['thang_nhuan'] as num?)?.toInt(),
  stemBranch: Map<String, String>.from(json['stem_branch'] as Map),
  stemBranchNumbers: Map<String, int>.from(json['stem_branch_numbers'] as Map),
  cuc: json['cuc'] as String,
  hanhCuc: (json['hanh_cuc'] as num).toInt(),
  menh: json['menh'] as String,
  menhId: json['menh_id'] as String,
  menhChu: json['menh_chu'] as String,
  thanChu: json['than_chu'] as String,
  menhVsCuc: json['menh_vs_cuc'] as String,
  amDuongNamSinh: json['am_duong_nam_sinh'] as String,
  amDuongMenh: json['am_duong_menh'] as String,
  timezone: (json['timezone'] as num).toInt(),
  today: json['today'] as String,
);

Map<String, dynamic> _$TuViExtraToJson(TuViExtra instance) => <String, dynamic>{
  'name': instance.name,
  'gender': instance.gender,
  'gender_value': instance.genderValue,
  'hour': instance.hour,
  'hour_can_chi': instance.hourCanChi,
  'solar_date': instance.solarDate,
  'lunar_date': instance.lunarDate,
  'thang_nhuan': instance.thangNhuan,
  'stem_branch': instance.stemBranch,
  'stem_branch_numbers': instance.stemBranchNumbers,
  'cuc': instance.cuc,
  'hanh_cuc': instance.hanhCuc,
  'menh': instance.menh,
  'menh_id': instance.menhId,
  'menh_chu': instance.menhChu,
  'than_chu': instance.thanChu,
  'menh_vs_cuc': instance.menhVsCuc,
  'am_duong_nam_sinh': instance.amDuongNamSinh,
  'am_duong_menh': instance.amDuongMenh,
  'timezone': instance.timezone,
  'today': instance.today,
};
