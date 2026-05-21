import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/location_models.dart';

class UserBlobMarker extends StatelessWidget {
  const UserBlobMarker({
    super.key,
    required this.user,
    required this.onTap,
  });

  final NearbyUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayText = _displayText(user);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            color: Theme.of(context).colorScheme.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: user.photoUrl != null && user.photoUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: user.photoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _FallbackAvatar(text: displayText),
                  errorWidget: (context, url, error) => _FallbackAvatar(text: displayText),
                )
              : _FallbackAvatar(text: displayText),
        ),
      ),
    );
  }

  String _displayText(NearbyUser user) {
    final source = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : user.username.trim();
    if (source.isEmpty) {
      return '?';
    }
    return source.characters.first.toUpperCase();
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
