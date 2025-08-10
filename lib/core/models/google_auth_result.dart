import 'package:equatable/equatable.dart';

/// Google authentication result model
class GoogleAuthResult extends Equatable {
  final String idToken;
  final String? accessToken;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String id;

  const GoogleAuthResult({
    required this.idToken,
    this.accessToken,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.id,
  });

  /// Convert to API format for backend
  Map<String, dynamic> toApiMap() {
    return {
      'token': idToken,
    };
  }

  /// Create from Google Sign-In account
  factory GoogleAuthResult.fromGoogleAccount({
    required String idToken,
    String? accessToken,
    required String email,
    String? displayName,
    String? photoUrl,
    required String id,
  }) {
    return GoogleAuthResult(
      idToken: idToken,
      accessToken: accessToken,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      id: id,
    );
  }

  @override
  List<Object?> get props => [
        idToken,
        accessToken,
        email,
        displayName,
        photoUrl,
        id,
      ];

  @override
  String toString() {
    return 'GoogleAuthResult(email: $email, displayName: $displayName, id: $id)';
  }
}
