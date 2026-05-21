class TrackInfo {
  TrackInfo({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    this.albumArtUrl,
    required this.playing,
  });

  final String trackId;
  final String trackName;
  final String artistName;
  final String? albumArtUrl;
  final bool playing;

  factory TrackInfo.fromJson(Map<String, dynamic> json) {
    return TrackInfo(
      trackId: json['trackId'] as String,
      trackName: json['trackName'] as String,
      artistName: json['artistName'] as String,
      albumArtUrl: json['albumArtUrl'] as String?,
      playing: json['playing'] as bool? ?? false,
    );
  }
}

class NearbyUser {
  NearbyUser({
    required this.userId,
    required this.username,
    this.displayName,
    this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    this.currentTrack,
  });

  final String userId;
  final String username;
  final String? displayName;
  final String? photoUrl;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final TrackInfo? currentTrack;

  factory NearbyUser.fromJson(Map<String, dynamic> json) {
    return NearbyUser(
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      currentTrack: json['currentTrack'] is Map<String, dynamic>
          ? TrackInfo.fromJson(json['currentTrack'] as Map<String, dynamic>)
          : null,
    );
  }
}