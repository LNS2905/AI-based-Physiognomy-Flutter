// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tu_vi_chart_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TuViChartRequest _$TuViChartRequestFromJson(Map<String, dynamic> json) =>
    TuViChartRequest(
      day: (json['day'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      hourBranch: (json['hour_branch'] as num).toInt(),
      gender: (json['gender'] as num).toInt(),
      name: json['name'] as String?,
      solarCalendar: json['solar_calendar'] as bool? ?? true,
      timezone: (json['timezone'] as num?)?.toInt() ?? 7,
    );

Map<String, dynamic> _$TuViChartRequestToJson(TuViChartRequest instance) =>
    <String, dynamic>{
      'day': instance.day,
      'month': instance.month,
      'year': instance.year,
      'hour_branch': instance.hourBranch,
      'gender': instance.gender,
      'name': instance.name,
      'solar_calendar': instance.solarCalendar,
      'timezone': instance.timezone,
    };
