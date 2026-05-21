import 'package:flutter/material.dart';

class SpotifyConnectTile extends StatelessWidget {
  const SpotifyConnectTile({
    super.key,
    required this.connected,
    required this.isLoading,
    this.onConnect,
  });

  final bool connected;
  final bool isLoading;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1DB954),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            '♫',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: const Text('Spotify'),
      subtitle: Text(
        connected ? 'Conectado' : 'No conectado',
      ),
      trailing: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : connected
              ? const Icon(Icons.check_circle, color: Color(0xFF1DB954))
              : FilledButton.tonal(
                  onPressed: onConnect,
                  child: const Text('Conectar'),
                ),
    );
  }
}
