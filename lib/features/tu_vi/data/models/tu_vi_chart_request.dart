import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tu_vi_chart_request.g.dart';

/// Request model for creating a Tu Vi chart
@JsonSerializable()
class TuViChartRequest extends Equatable {
  final int day;
  final int month;
  final int year;
  @JsonKey(name: 'hour_branch')
  final int hourBranch;
  final int gender; // 1 = male, -1 = female
  final String? name;
  @JsonKey(name: 'solar_calendar')
  final bool solarCalendar;
  final int timezone;

  const TuViChartRequest({
    required this.day,
    required this.month,
    required this.year,
    required this.hourBranch,
    required this.gender,
    this.name,
    this.solarCalendar = true,
    this.timezone = 7,
  });

  /// Create a copy with modifications
  TuViChartRequest copyWith({
    int? day,
    int? month,
    int? year,
    int? hourBranch,
    int? gender,
    String? name,
    bool? solarCalendar,
    int? timezone,
  }) {
    return TuViChartRequest(
      day: day ?? this.day,
      month: month ?? this.month,
      year: year ?? this.year,
      hourBranch: hourBranch ?? this.hourBranch,
      gender: gender ?? this.gender,
      name: name ?? this.name,
      solarCalendar: solarCalendar ?? this.solarCalendar,
      timezone: timezone ?? this.timezone,
    );
  }

  /// JSON serialization
  factory TuViChartRequest.fromJson(Map<String, dynamic> json) =>
      _$TuViChartRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TuViChartRequestToJson(this);

  @override
  List<Object?> get props => [
        day,
        month,
        year,
        hourBranch,
        gender,
        name,
        solarCalendar,
        timezone,
      ];

  @override
  String toString() {
    return 'TuViChartRequest(day: $day, month: $month, year: $year, hourBranch: $hourBranch, gender: $gender, name: $name, solarCalendar: $solarCalendar)';
  }
}
