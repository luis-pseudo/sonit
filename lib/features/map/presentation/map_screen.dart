import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/router/app_router.dart';
import '../../location/background_location_service.dart';
import '../domain/location_models.dart';
import '../providers/map_provider.dart';
import 'widgets/user_blob_marker.dart';
import 'widgets/user_detail_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _permissionDialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(mapProvider.notifier).initialize();
      BackgroundLocationService.startService();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);
    final currentPosition = state.currentPosition;

    ref.listen<MapState>(mapProvider, (previous, next) {
      if (next.error == MapNotifier.permissionDeniedError &&
          previous?.error != next.error &&
          !_permissionDialogVisible) {
        _permissionDialogVisible = true;
        _showPermissionDialog();
      }

      if (previous?.currentPosition != next.currentPosition &&
          next.currentPosition != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          _mapController.move(next.currentPosition!, _mapController.camera.zoom);
        });
      }
    });

    if (state.isLoadingLocation ||
        (state.currentPosition == null && state.error == null)) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.error == MapNotifier.permissionDeniedForeverError ||
        state.error == MapNotifier.serviceDisabledError) {
      return _LocationErrorView(
        message: state.error == MapNotifier.permissionDeniedForeverError
            ? 'Activa la ubicación en la configuración del sistema para ver el mapa.'
            : 'Activa los servicios de ubicación para ver el mapa.',
        buttonLabel: 'Abrir configuración',
        onPressed: () async {
          if (state.error == MapNotifier.serviceDisabledError) {
            await Geolocator.openLocationSettings();
          } else {
            await Geolocator.openAppSettings();
          }
        },
      );
    }

    if (state.error == MapNotifier.permissionDeniedError) {
      return _LocationErrorView(
        message: 'Se necesita permiso de ubicación para mostrar tu posición.',
        buttonLabel: 'Reintentar',
        onPressed: () {
          ref.read(mapProvider.notifier).retryInitialize();
        },
      );
    }

    if (currentPosition == null && state.error != null) {
      return _LocationErrorView(
        message: state.error!,
        buttonLabel: 'Reintentar',
        onPressed: () {
          ref.read(mapProvider.notifier).retryInitialize();
        },
      );
    }

    if (currentPosition == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final markers = _buildMarkers(state.nearbyUsers);

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: currentPosition,
          initialZoom: 15,
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.sonit.app',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRouter.profilePath),
        child: const Icon(Icons.person),
      ),
    );
  }

  List<Marker> _buildMarkers(List<NearbyUser> nearbyUsers) {
    return nearbyUsers
        .where((user) => user.currentTrack != null)
        .map(
          (user) => Marker(
            point: LatLng(user.latitude, user.longitude),
            width: 44,
            height: 44,
            child: UserBlobMarker(
              user: user,
              onTap: () => showUserDetailSheet(context, user),
            ),
          ),
        )
        .toList(growable: false);
  }

  Future<void> _showPermissionDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Permiso de ubicación'),
          content: const Text(
            'Sonit necesita tu ubicación para mostrar usuarios cercanos en el mapa.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Entendido'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Geolocator.openAppSettings();
              },
              child: const Text('Abrir configuración'),
            ),
          ],
        );
      },
    );

    if (mounted) {
      _permissionDialogVisible = false;
    }
  }
}

class _LocationErrorView extends StatelessWidget {
  const _LocationErrorView({
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.location_off, size: 48),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onPressed,
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}