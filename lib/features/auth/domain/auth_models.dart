class AuthTokens {
  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}

class UserSummary {
  UserSummary({
    required this.id,
    required this.username,
    required this.displayName,
    this.email,
    this.photoUrl,
  });

  final String id;
  final String username;
  final String displayName;
  final String? email;
  final String? photoUrl;

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'username': username,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
      };
}

class AuthResult {
  AuthResult({
    required this.tokens,
    required this.user,
  });

  final AuthTokens tokens;
  final UserSummary user;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      tokens: AuthTokens.fromJson(json),
      user: UserSummary.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        ...tokens.toJson(),
        ...user.toJson(),
      };
}
