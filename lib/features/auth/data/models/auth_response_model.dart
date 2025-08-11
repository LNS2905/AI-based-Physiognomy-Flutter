import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_response_model.g.dart';

/// Authentication response model (only tokens from login)
@JsonSerializable()
class AuthResponseModel extends Equatable {
  final String accessToken;
  final String refreshToken;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  /// Create AuthResponseModel from JSON
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  /// Convert AuthResponseModel to JSON
  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  /// Get authorization header value
  String get authorizationHeader => 'Bearer $accessToken';

  /// Copy with method
  AuthResponseModel copyWith({
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthResponseModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
      ];
}
