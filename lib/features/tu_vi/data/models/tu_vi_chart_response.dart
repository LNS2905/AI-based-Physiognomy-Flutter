import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'tu_vi_chart_request.dart';
import 'tu_vi_house.dart';
import 'tu_vi_extra.dart';

part 'tu_vi_chart_response.g.dart';

/// Response model for Tu Vi chart
@JsonSerializable()
class TuViChartResponse extends Equatable {
  final int? id;
  final TuViChartRequest request;
  final List<TuViHouse> houses;
  final TuViExtra extra;

  const TuViChartResponse({
    this.id,
    required this.request,
    required this.houses,
    required this.extra,
  });

  /// Get the main house (Cung Mệnh)
  TuViHouse? get mainHouse => houses.firstWhere(
        (house) => house.isMainHouse,
        orElse: () => houses.first,
      );

  /// Get the body house (Cung Thân)
  TuViHouse? get bodyHouse => houses.firstWhere(
        (house) => house.isBodyHouse,
        orElse: () => houses.first,
      );

  /// Get houses sorted by house number
  List<TuViHouse> get sortedHouses {
    final sorted = List<TuViHouse>.from(houses);
    sorted.sort((a, b) => a.houseNumber.compareTo(b.houseNumber));
    return sorted;
  }

  /// JSON serialization
  factory TuViChartResponse.fromJson(Map<String, dynamic> json) =>
      _$TuViChartResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TuViChartResponseToJson(this);

  @override
  List<Object?> get props => [id, request, houses, extra];

  @override
  String toString() {
    return 'TuViChartResponse(id: $id, houses: ${houses.length}, name: ${extra.name})';
  }
}
