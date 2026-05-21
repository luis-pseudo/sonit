import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/location_models.dart';

Future<void> showUserDetailSheet(BuildContext context, NearbyUser user) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => UserDetailSheet(user: user),
  );
}

class UserDetailSheet extends StatelessWidget {
  const UserDetailSheet({super.key, required this.user});

  final NearbyUser user;

  @override
  Widget build(BuildContext context) {
    final track = user.currentTrack;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: 20 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _UserAvatar(user: user),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.displayName?.trim().isNotEmpty == true
                            ? user.displayName!.trim()
                            : user.username,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'a ${user.distanceMeters.toStringAsFixed(0)} metros',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Canción',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (track == null)
              const Text('Sin música en este momento')
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _TrackArtwork(track: track),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          track.trackName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          track.artistName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Icon(
                              track.playing ? Icons.graphic_eq : Icons.music_note,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              track.playing
                                  ? 'reproduciendo ahora'
                                  : 'pausado',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user});

  final NearbyUser user;

  @override
  Widget build(BuildContext context) {
    final displayText = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim().characters.first.toUpperCase()
        : user.username.trim().characters.first.toUpperCase();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: user.photoUrl != null && user.photoUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: user.photoUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => _AvatarFallback(text: displayText),
              errorWidget: (context, url, error) => _AvatarFallback(text: displayText),
            )
          : _AvatarFallback(text: displayText),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _TrackArtwork extends StatelessWidget {
  const _TrackArtwork({required this.track});

  final TrackInfo track;

  @override
  Widget build(BuildContext context) {
    final artworkUrl = track.albumArtUrl;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: artworkUrl != null && artworkUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: artworkUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Icon(Icons.music_note),
              errorWidget: (context, url, error) => const Icon(Icons.music_note),
            )
          : const Icon(Icons.music_note),
    );
  }
}
