// Authentication & User Management Models
import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

/// Enum for Gender
enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
}

/// Create User DTO for registration
@JsonSerializable()
class CreateUserDTO {
  final String? username;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final double age;
  final Gender gender;
  final String? avatar;

  const CreateUserDTO({
    this.username,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    this.avatar,
  });

  factory CreateUserDTO.fromJson(Map<String, dynamic> json) =>
      _$CreateUserDTOFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUserDTOToJson(this);
}

/// Update User DTO for profile updates
@JsonSerializable()
class UpdateUserDTO {
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

  factory UpdateUserDTO.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserDTOFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserDTOToJson(this);
}

/// Auth Request for login
@JsonSerializable()
class AuthRequest {
  final String username;
  final String password;

  const AuthRequest({
    required this.username,
    required this.password,
  });

  factory AuthRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AuthRequestToJson(this);
}

/// Change Password DTO
@JsonSerializable()
class ChangePasswordDTO {
  final String oldPassword;
  final String password;

  const ChangePasswordDTO({
    required this.oldPassword,
    required this.password,
  });

  factory ChangePasswordDTO.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordDTOToJson(this);
}

/// Request Reset Password DTO
@JsonSerializable()
class RequestResetPasswordDTO {
  final String email;

  const RequestResetPasswordDTO({
    required this.email,
  });

  factory RequestResetPasswordDTO.fromJson(Map<String, dynamic> json) =>
      _$RequestResetPasswordDTOFromJson(json);

  Map<String, dynamic> toJson() => _$RequestResetPasswordDTOToJson(this);
}

/// Reset Password DTO
@JsonSerializable()
class ResetPasswordDTO {
  final String password;

  const ResetPasswordDTO({
    required this.password,
  });

  factory ResetPasswordDTO.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordDTOToJson(this);
}

/// Refresh Token Request
@JsonSerializable()
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({
    required this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

/// Google Login Request
@JsonSerializable()
class GoogleLoginRequest {
  final String token;

  const GoogleLoginRequest({
    required this.token,
  });

  factory GoogleLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$GoogleLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleLoginRequestToJson(this);
}

/// User Model (response from API)
@JsonSerializable()
class User {
  final int id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final int? age;
  final Gender? gender;
  final String? avatar;
  final int? credits;

  const User({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    this.age,
    this.gender,
    this.avatar,
    this.credits,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Get display name (firstName + lastName)
  String get displayName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    
    if (first.isEmpty && last.isEmpty) {
      return email;
    }
    return '${first} ${last}'.trim();
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}

/// Auth Response (login response) - only contains tokens
@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

/// Register Response - only contains user data
@JsonSerializable()
class RegisterResponse {
  final User user;

  const RegisterResponse({
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}
