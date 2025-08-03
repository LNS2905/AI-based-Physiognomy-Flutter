import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'create_user_dto.dart'; // Import for Gender enum

part 'update_user_dto.g.dart';

/// Update user DTO model
@JsonSerializable()
class UpdateUserDTO extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final double age;
  final Gender gender;
  final String? avatar;

  const UpdateUserDTO({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    this.avatar,
  });

  /// Create UpdateUserDTO from JSON
  factory UpdateUserDTO.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserDTOFromJson(json);

  /// Convert UpdateUserDTO to JSON
  Map<String, dynamic> toJson() => _$UpdateUserDTOToJson(this);

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        phone,
        age,
        gender,
        avatar,
      ];

  @override
  String toString() => 'UpdateUserDTO(email: $email, firstName: $firstName, lastName: $lastName)';

  /// Create a copy with updated fields
  UpdateUserDTO copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    double? age,
    Gender? gender,
    String? avatar,
  }) {
    return UpdateUserDTO(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
    );
  }
}
