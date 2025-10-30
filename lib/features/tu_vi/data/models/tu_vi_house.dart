import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'tu_vi_star.dart';

part 'tu_vi_house.g.dart';

/// Model for a house (Cung) in Tu Vi chart
@JsonSerializable()
class TuViHouse extends Equatable {
  @JsonKey(name: 'house_number')
  final int houseNumber;
  final String branch;
  final String name;
  final String element;
  @JsonKey(name: 'am_duong')
  final int amDuong; // 1 = Dương, -1 = Âm
  @JsonKey(name: 'is_body_house')
  final bool isBodyHouse;
  @JsonKey(name: 'tuan_trung')
  final bool tuanTrung;
  @JsonKey(name: 'triet_lo')
  final bool trietLo;
  @JsonKey(name: 'major_period')
  final int? majorPeriod;
  @JsonKey(name: 'minor_period')
  final String? minorPeriod;
  final List<TuViStar> stars;

  const TuViHouse({
    required this.houseNumber,
    required this.branch,
    required this.name,
    required this.element,
    required this.amDuong,
    required this.isBodyHouse,
    required this.tuanTrung,
    required this.trietLo,
    this.majorPeriod,
    this.minorPeriod,
    required this.stars,
  });

  /// Check if this is the main house (Cung Mệnh)
  bool get isMainHouse => name == 'Mệnh';

  /// Get Âm Dương display name
  String get amDuongName => amDuong == 1 ? 'Dương' : 'Âm';

  /// Get element display name
  String get elementDisplayName {
    return element;
  }

  /// Get main stars in this house (category = 1)
  List<TuViStar> get mainStars => stars.where((s) => s.category == 1).toList();

  /// Get supporting stars in this house
  List<TuViStar> get supportingStars =>
      stars.where((s) => s.category != 1).toList();

  /// Get house description
  String get description {
    switch (name) {
      case 'Mệnh':
        return 'Bản chất, tính cách, số phận';
      case 'Phụ mẫu':
        return 'Quan hệ với cha mẹ, người lớn tuổi';
      case 'Phúc đức':
        return 'Tinh thần, suy nghĩ, giá trị sống';
      case 'Điền trạch':
        return 'Nhà cửa, bất động sản';
      case 'Quan lộc':
        return 'Sự nghiệp, công danh';
      case 'Nô bộc':
        return 'Bạn bè, đồng nghiệp, nhân viên';
      case 'Thiên di':
        return 'Di chuyển, du lịch, môi trường bên ngoài';
      case 'Tật Ách':
        return 'Sức khỏe, bệnh tật';
      case 'Tài Bạch':
        return 'Tài chính, tiền bạc';
      case 'Tử tức':
        return 'Con cái, người trẻ tuổi';
      case 'Phu thê':
        return 'Vợ chồng, tình cảm';
      case 'Huynh đệ':
        return 'Anh chị em, bạn bè thân';
      default:
        return '';
    }
  }

  /// JSON serialization
  factory TuViHouse.fromJson(Map<String, dynamic> json) =>
      _$TuViHouseFromJson(json);

  Map<String, dynamic> toJson() => _$TuViHouseToJson(this);

  @override
  List<Object?> get props => [
        houseNumber,
        branch,
        name,
        element,
        amDuong,
        isBodyHouse,
        tuanTrung,
        trietLo,
        majorPeriod,
        minorPeriod,
        stars,
      ];

  @override
  String toString() {
    return 'TuViHouse(number: $houseNumber, name: $name, branch: $branch, stars: ${stars.length})';
  }
}
