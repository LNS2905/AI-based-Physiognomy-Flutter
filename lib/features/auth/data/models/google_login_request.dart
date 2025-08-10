import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'google_login_request.g.dart';

/// Google login request model
@JsonSerializable()
class GoogleLoginRequest extends Equatable {
  final String token;

  const GoogleLoginRequest({
    required this.token,
  });

  /// Create GoogleLoginRequest from JSON
  factory GoogleLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$GoogleLoginRequestFromJson(json);

  /// Convert GoogleLoginRequest to JSON
  Map<String, dynamic> toJson() => _$GoogleLoginRequestToJson(this);

  @override
  List<Object?> get props => [token];

  @override
  String toString() => 'GoogleLoginRequest(token: ${token.substring(0, 10)}...)';

  /// Create a copy with updated fields
  GoogleLoginRequest copyWith({
    String? token,
  }) {
    return GoogleLoginRequest(
      token: token ?? this.token,
    );
  }
}
