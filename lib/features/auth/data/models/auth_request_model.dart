import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_request_model.g.dart';

/// Authentication request model
@JsonSerializable()
class AuthRequest extends Equatable {
  final String username;
  final String password;

  const AuthRequest({
    required this.username,
    required this.password,
  });

  /// Create AuthRequest from JSON
  factory AuthRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthRequestFromJson(json);

  /// Convert AuthRequest to JSON
  Map<String, dynamic> toJson() => _$AuthRequestToJson(this);

  @override
  List<Object?> get props => [username, password];

  @override
  String toString() => 'AuthRequest(username: $username)';

  /// Create a copy with updated fields
  AuthRequest copyWith({
    String? username,
    String? password,
  }) {
    return AuthRequest(
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
