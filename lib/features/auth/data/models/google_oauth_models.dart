import 'dart:convert';

/// Google OAuth Token Response Model
class GoogleOAuthTokenResponse {
  final String accessToken;
  final String idToken;
  final int expiresIn;
  final String tokenType;
  final String scope;
  final String? refreshToken;

  const GoogleOAuthTokenResponse({
    required this.accessToken,
    required this.idToken,
    required this.expiresIn,
    required this.tokenType,
    required this.scope,
    this.refreshToken,
  });

  factory GoogleOAuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return GoogleOAuthTokenResponse(
      accessToken: json['access_token'] as String,
      idToken: json['id_token'] as String,
      expiresIn: json['expires_in'] as int,
      tokenType: json['token_type'] as String,
      scope: json['scope'] as String,
      refreshToken: json['refresh_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'id_token': idToken,
      'expires_in': expiresIn,
      'token_type': tokenType,
      'scope': scope,
      if (refreshToken != null) 'refresh_token': refreshToken,
    };
  }
}

/// Google User Info from ID Token
class GoogleUserInfo {
  final String sub; // Google user ID
  final String email;
  final bool emailVerified;
  final String name;
  final String? picture;
  final String? givenName;
  final String? familyName;
  final String iss; // Issuer
  final String aud; // Audience
  final int iat; // Issued at
  final int exp; // Expires at

  const GoogleUserInfo({
    required this.sub,
    required this.email,
    required this.emailVerified,
    required this.name,
    this.picture,
    this.givenName,
    this.familyName,
    required this.iss,
    required this.aud,
    required this.iat,
    required this.exp,
  });

  factory GoogleUserInfo.fromJson(Map<String, dynamic> json) {
    return GoogleUserInfo(
      sub: json['sub'] as String,
      email: json['email'] as String,
      emailVerified: json['email_verified'] as bool,
      name: json['name'] as String,
      picture: json['picture'] as String?,
      givenName: json['given_name'] as String?,
      familyName: json['family_name'] as String?,
      iss: json['iss'] as String,
      aud: json['aud'] as String,
      iat: json['iat'] as int,
      exp: json['exp'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'email': email,
      'email_verified': emailVerified,
      'name': name,
      if (picture != null) 'picture': picture,
      if (givenName != null) 'given_name': givenName,
      if (familyName != null) 'family_name': familyName,
      'iss': iss,
      'aud': aud,
      'iat': iat,
      'exp': exp,
    };
  }

  /// Decode JWT token to get user info
  static GoogleUserInfo fromIdToken(String idToken) {
    try {
      // Split the JWT token
      final parts = idToken.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token format');
      }

      // Decode the payload (second part)
      String payload = parts[1];
      
      // Add padding if needed
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      // Decode base64
      final decoded = base64Url.decode(payload);
      final jsonString = utf8.decode(decoded);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      return GoogleUserInfo.fromJson(json);
    } catch (e) {
      throw Exception('Failed to decode ID token: $e');
    }
  }
}

/// Google Sign-In Request Model for backend
class GoogleSignInRequest {
  final String idToken;
  final String? accessToken;
  final GoogleUserInfo userInfo;

  const GoogleSignInRequest({
    required this.idToken,
    this.accessToken,
    required this.userInfo,
  });

  factory GoogleSignInRequest.fromTokenResponse(GoogleOAuthTokenResponse tokenResponse) {
    final userInfo = GoogleUserInfo.fromIdToken(tokenResponse.idToken);
    
    return GoogleSignInRequest(
      idToken: tokenResponse.idToken,
      accessToken: tokenResponse.accessToken,
      userInfo: userInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_token': idToken,
      if (accessToken != null) 'access_token': accessToken,
      'user_info': userInfo.toJson(),
    };
  }
}
