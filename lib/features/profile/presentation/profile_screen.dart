import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import 'widgets/spotify_connect_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.mapPath),
        ),
        title: const Text('Perfil'),
      ),
      body: profileState.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('Error al cargar perfil'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                // User info section
                Center(
                  child: Column(
                    children: <Widget>[
                      // Avatar
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: profile.photoUrl != null
                            ? NetworkImage(profile.photoUrl!)
                            : null,
                        child: profile.photoUrl == null
                            ? Text(
                                profile.displayName.isNotEmpty
                                    ? profile.displayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 32),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Display name
                      Text(
                        profile.displayName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      // Username
                      Text(
                        '@${profile.username}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Email
                      Text(
                        profile.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Music services section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Servicios de música',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: _buildSpotifyTile(context, ref, profile),
                ),
                const SizedBox(height: 32),

                // Logout section
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: () => _handleLogout(context, ref),
                    child: const Text('Cerrar sesión'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stack) {
          return Center(
            child: Text('Error: $error'),
          );
        },
      ),
    );
  }

  Widget _buildSpotifyTile(
    BuildContext context,
    WidgetRef ref,
    dynamic profile,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final profileState = ref.watch(profileProvider);

        return SpotifyConnectTile(
          connected: profile.spotifyConnected,
          isLoading: profileState.isLoading,
          onConnect: () {
            ref.read(profileProvider.notifier).connectSpotify();
          },
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) {
      context.go(AppRouter.loginPath);
    }
  }
}