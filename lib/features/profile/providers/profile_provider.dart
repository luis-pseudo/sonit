import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../data/profile_repository.dart';
import '../domain/profile_models.dart';

class ProfileNotifier extends AutoDisposeAsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    return loadProfile();
  }

  Future<UserProfile?> loadProfile() async {
    try {
      final repository = ref.read(profileRepositoryProvider);
      final profile = await repository.getMyProfile();
      return profile;
    } catch (_) {
      return null;
    }
  }

  Future<void> connectSpotify() async {
    try {
      final repository = ref.read(profileRepositoryProvider);
      final authUrl = await repository.getSpotifyAuthUrl();

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'sonit',
      );

      if (result.contains('spotify-connected')) {
        final updatedProfile = await loadProfile();
        state = AsyncValue.data(updatedProfile);
      }
    } on PlatformException catch (e) {
      if (e.code != 'CANCELED') {
        state = AsyncValue.error(
          Exception(e.message ?? 'Failed to connect Spotify'),
          StackTrace.current,
        );
      }
    } catch (e) {
      state = AsyncValue.error(
        Exception('Failed to connect Spotify: $e'),
        StackTrace.current,
      );
    }
  }
}

final profileProvider =
    AutoDisposeAsyncNotifierProvider<ProfileNotifier, UserProfile?>(
  ProfileNotifier.new,
);
