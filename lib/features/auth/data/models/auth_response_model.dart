import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

/// Authentication response model
@JsonSerializable()
class AuthResponseModel extends Equatable {
  final String? accessToken;
  final String? refreshToken;
  final UserModel user;
  final String tokenType;
  final int? expiresIn;

  const AuthResponseModel({
    this.accessToken,
    this.refreshToken,
    required this.user,
    this.tokenType = 'Bearer',
    this.expiresIn,
  });

  /// Create AuthResponseModel from JSON
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  /// Convert AuthResponseModel to JSON
  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  /// Get authorization header value
  String? get authorizationHeader => accessToken != null ? '$tokenType $accessToken' : null;

  /// Check if token is expired (with 5 minute buffer)
  bool get isExpired {
    if (expiresIn == null) return false;
    final now = DateTime.now();
    final expiryTime = now.add(Duration(seconds: expiresIn! - 300)); // 5 min buffer
    return now.isAfter(expiryTime);
  }

  /// Copy with method
  AuthResponseModel copyWith({
    String? accessToken,
    String? refreshToken,
    UserModel? user,
    String? tokenType,
    int? expiresIn,
  }) {
    return AuthResponseModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        user,
        tokenType,
        expiresIn,
      ];
}
