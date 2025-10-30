// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tu_vi_chart_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TuViChartResponse _$TuViChartResponseFromJson(Map<String, dynamic> json) =>
    TuViChartResponse(
      id: (json['id'] as num?)?.toInt(),
      request: TuViChartRequest.fromJson(
        json['request'] as Map<String, dynamic>,
      ),
      houses: (json['houses'] as List<dynamic>)
          .map((e) => TuViHouse.fromJson(e as Map<String, dynamic>))
          .toList(),
      extra: TuViExtra.fromJson(json['extra'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TuViChartResponseToJson(TuViChartResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'request': instance.request,
      'houses': instance.houses,
      'extra': instance.extra,
    };
