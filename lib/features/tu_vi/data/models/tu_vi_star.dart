import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tu_vi_star.g.dart';

/// Model for a star (Sao) in Tu Vi chart
@JsonSerializable()
class TuViStar extends Equatable {
  @JsonKey(name: 'star_id')
  final int starId;
  final String name;
  final String element; // K, M, T, H, O
  final int category; // 1=main stars, 2=supporting, etc.
  final String? strength; // V, M, H, Đ, null
  final String? direction;
  @JsonKey(name: 'am_duong')
  final dynamic amDuong; // 1, -1, 0, ""
  @JsonKey(name: 'trang_sinh')
  final int trangSinh;
  @JsonKey(name: 'css_class')
  final String? cssClass;

  const TuViStar({
    required this.starId,
    required this.name,
    required this.element,
    required this.category,
    this.strength,
    this.direction,
    this.amDuong,
    required this.trangSinh,
    this.cssClass,
  });

  /// Get element display name
  String get elementName {
    switch (element) {
      case 'K':
        return 'Kim';
      case 'M':
        return 'Mộc';
      case 'T':
        return 'Thủy';
      case 'H':
        return 'Hỏa';
      case 'O':
        return 'Thổ';
      default:
        return element;
    }
  }

  /// Get strength display name
  String get strengthName {
    switch (strength) {
      case 'V':
        return 'Vượng';
      case 'M':
        return 'Miếu';
      case 'H':
        return 'Hòa';
      case 'Đ':
        return 'Đắc địa';
      default:
        return '';
    }
  }

  /// Check if this is a main star (14 main stars)
  bool get isMainStar => category == 1;

  /// JSON serialization
  factory TuViStar.fromJson(Map<String, dynamic> json) =>
      _$TuViStarFromJson(json);

  Map<String, dynamic> toJson() => _$TuViStarToJson(this);

  @override
  List<Object?> get props => [
        starId,
        name,
        element,
        category,
        strength,
        direction,
        amDuong,
        trangSinh,
        cssClass,
      ];

  @override
  String toString() {
    return 'TuViStar(id: $starId, name: $name, element: $elementName, strength: $strengthName)';
  }
}
