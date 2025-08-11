import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'auth_models.dart';

part 'create_user_dto.g.dart';

/// Create user DTO model
@JsonSerializable()
class CreateUserDTO extends Equatable {
  final String username;
  final String password;
  final String? confirmPassword;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final double age;
  final Gender gender;
  final String? avatar;

  const CreateUserDTO({
    required this.username,
    required this.password,
    this.confirmPassword,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    this.avatar,
  });

  /// Create CreateUserDTO from JSON
  factory CreateUserDTO.fromJson(Map<String, dynamic> json) =>
      _$CreateUserDTOFromJson(json);

  /// Convert CreateUserDTO to JSON
  Map<String, dynamic> toJson() => _$CreateUserDTOToJson(this);

  @override
  List<Object?> get props => [
        username,
        password,
        confirmPassword,
        firstName,
        lastName,
        email,
        phone,
        age,
        gender,
        avatar,
      ];

  @override
  String toString() => 'CreateUserDTO(username: $username, email: $email, firstName: $firstName, lastName: $lastName)';

  /// Create a copy with updated fields
  CreateUserDTO copyWith({
    String? username,
    String? password,
    String? confirmPassword,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    double? age,
    Gender? gender,
    String? avatar,
  }) {
    return CreateUserDTO(
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
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
