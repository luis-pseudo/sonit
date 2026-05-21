class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.spotifyConnected,
  });

  final String id;
  final String username;
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool spotifyConnected;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      spotifyConnected: _isSpotifyConnected(json),
    );
  }

  static bool _isSpotifyConnected(Map<String, dynamic> json) {
    final connectedServices = json['connectedServices'] as Map<String, dynamic>?;
    if (connectedServices == null) {
      return false;
    }
    final spotify = connectedServices['spotify'] as Map<String, dynamic>?;
    if (spotify == null) {
      return false;
    }
    return spotify['connected'] as bool? ?? false;
  }
}
