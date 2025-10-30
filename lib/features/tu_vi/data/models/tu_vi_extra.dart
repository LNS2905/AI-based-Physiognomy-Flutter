import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tu_vi_extra.g.dart';

/// Extra information model for Tu Vi chart
@JsonSerializable()
class TuViExtra extends Equatable {
  final String? name;
  final String gender;
  @JsonKey(name: 'gender_value')
  final int genderValue;
  final String hour;
  @JsonKey(name: 'hour_can_chi')
  final String hourCanChi;
  @JsonKey(name: 'solar_date')
  final String solarDate;
  @JsonKey(name: 'lunar_date')
  final String lunarDate;
  @JsonKey(name: 'thang_nhuan')
  final int? thangNhuan;
  @JsonKey(name: 'stem_branch')
  final Map<String, String> stemBranch;
  @JsonKey(name: 'stem_branch_numbers')
  final Map<String, int> stemBranchNumbers;
  final String cuc;
  @JsonKey(name: 'hanh_cuc')
  final int hanhCuc;
  final String menh;
  @JsonKey(name: 'menh_id')
  final String menhId;
  @JsonKey(name: 'menh_chu')
  final String menhChu;
  @JsonKey(name: 'than_chu')
  final String thanChu;
  @JsonKey(name: 'menh_vs_cuc')
  final String menhVsCuc;
  @JsonKey(name: 'am_duong_nam_sinh')
  final String amDuongNamSinh;
  @JsonKey(name: 'am_duong_menh')
  final String amDuongMenh;
  final int timezone;
  final String today;

  const TuViExtra({
    this.name,
    required this.gender,
    required this.genderValue,
    required this.hour,
    required this.hourCanChi,
    required this.solarDate,
    required this.lunarDate,
    this.thangNhuan,
    required this.stemBranch,
    required this.stemBranchNumbers,
    required this.cuc,
    required this.hanhCuc,
    required this.menh,
    required this.menhId,
    required this.menhChu,
    required this.thanChu,
    required this.menhVsCuc,
    required this.amDuongNamSinh,
    required this.amDuongMenh,
    required this.timezone,
    required this.today,
  });

  /// Get element name from Cục
  String get cucElementName {
    switch (hanhCuc) {
      case 1:
        return 'Mộc';
      case 2:
        return 'Hỏa';
      case 3:
        return 'Thổ';
      case 4:
        return 'Kim';
      case 5:
        return 'Thủy';
      default:
        return '';
    }
  }

  /// Get element name from Mệnh
  String get menhElementName {
    switch (menhId) {
      case 'M':
        return 'Mộc';
      case 'H':
        return 'Hỏa';
      case 'O':
        return 'Thổ';
      case 'K':
        return 'Kim';
      case 'T':
        return 'Thủy';
      default:
        return menhId;
    }
  }

  /// JSON serialization
  factory TuViExtra.fromJson(Map<String, dynamic> json) =>
      _$TuViExtraFromJson(json);

  Map<String, dynamic> toJson() => _$TuViExtraToJson(this);

  @override
  List<Object?> get props => [
        name,
        gender,
        genderValue,
        hour,
        hourCanChi,
        solarDate,
        lunarDate,
        thangNhuan,
        stemBranch,
        stemBranchNumbers,
        cuc,
        hanhCuc,
        menh,
        menhId,
        menhChu,
        thanChu,
        menhVsCuc,
        amDuongNamSinh,
        amDuongMenh,
        timezone,
        today,
      ];

  @override
  String toString() {
    return 'TuViExtra(name: $name, gender: $gender, menhChu: $menhChu, thanChu: $thanChu)';
  }
}
