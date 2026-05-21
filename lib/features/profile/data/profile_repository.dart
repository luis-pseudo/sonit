import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/profile_models.dart';

class ProfileRepository {
  final Dio dio;

  ProfileRepository(this.dio);

  Future<UserProfile> getMyProfile() async {
    final response = await dio.get<Map<String, dynamic>>('/users/me');
    final data = response.data;

    if (data == null) {
      throw Exception('Failed to fetch profile');
    }

    final success = data['success'] as bool? ?? false;
    if (!success) {
      final message = data['message'] as String? ?? 'Unknown error';
      throw Exception(message);
    }

    final profileData = data['data'] as Map<String, dynamic>?;
    if (profileData == null) {
      throw Exception('Invalid profile data');
    }

    return UserProfile.fromJson(profileData);
  }

  Future<String> getSpotifyAuthUrl() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/integrations/spotify/auth-url',
    );
    final data = response.data;

    if (data == null) {
      throw Exception('Failed to fetch Spotify auth URL');
    }

    final success = data['success'] as bool? ?? false;
    if (!success) {
      final message = data['message'] as String? ?? 'Unknown error';
      throw Exception(message);
    }

    final responseData = data['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      throw Exception('Invalid response data');
    }

    final authUrl = responseData['authUrl'] as String?;
    if (authUrl == null || authUrl.isEmpty) {
      throw Exception('No auth URL provided');
    }

    return authUrl;
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return ProfileRepository(dio);
});
