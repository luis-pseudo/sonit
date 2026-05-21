import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/app_config.dart';
import '../data/location_repository.dart';
import '../domain/location_models.dart';

class MapState {
  const MapState({
    this.currentPosition,
    this.nearbyUsers = const <NearbyUser>[],
    this.isLoadingLocation = false,
    this.error,
  });

  final LatLng? currentPosition;
  final List<NearbyUser> nearbyUsers;
  final bool isLoadingLocation;
  final String? error;

  MapState copyWith({
    LatLng? currentPosition,
    List<NearbyUser>? nearbyUsers,
    bool? isLoadingLocation,
    String? error,
    bool clearError = false,
  }) {
    return MapState(
      currentPosition: currentPosition ?? this.currentPosition,
      nearbyUsers: nearbyUsers ?? this.nearbyUsers,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class MapNotifier extends AutoDisposeNotifier<MapState> {
  Timer? _pollingTimer;
  bool _initialized = false;

  static const String permissionDeniedError = 'permission_denied';
  static const String permissionDeniedForeverError = 'permission_denied_forever';
  static const String serviceDisabledError = 'service_disabled';

  @override
  MapState build() {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });
    return const MapState();
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    state = state.copyWith(isLoadingLocation: true, clearError: true);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        isLoadingLocation: false,
        error: serviceDisabledError,
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      state = state.copyWith(
        isLoadingLocation: false,
        error: permissionDeniedError,
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        isLoadingLocation: false,
        error: permissionDeniedForeverError,
      );
      return;
    }

    _initialized = true;
    await _syncLocationAndUsers();
    _startPolling();
    state = state.copyWith(isLoadingLocation: false);
  }

  Future<void> refreshNearbyUsers() async {
    final currentPosition = state.currentPosition;
    if (currentPosition == null) {
      return;
    }

    try {
      final users = await ref
          .read(locationRepositoryProvider)
          .getNearbyUsers(currentPosition.latitude, currentPosition.longitude);
      state = state.copyWith(nearbyUsers: users, clearError: true);
    } catch (error) {
      state = state.copyWith(error: _extractMessage(error));
    }
  }

  Future<void> retryInitialize() async {
    _initialized = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    await initialize();
  }

  Future<void> _syncLocationAndUsers() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      state = state.copyWith(currentPosition: latLng, clearError: true);

      await ref
          .read(locationRepositoryProvider)
          .updateLocation(position.latitude, position.longitude);
      await refreshNearbyUsers();
    } catch (error) {
      state = state.copyWith(error: _extractMessage(error));
    }
  }

  Future<void> _refreshCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      state = state.copyWith(currentPosition: latLng, clearError: true);

      await ref
          .read(locationRepositoryProvider)
          .updateLocation(position.latitude, position.longitude);
      await refreshNearbyUsers();
    } catch (error) {
      state = state.copyWith(error: _extractMessage(error));
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: AppConfig.locationUpdateIntervalSeconds),
      (_) => _refreshCurrentPosition(),
    );
  }

  String _extractMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

final mapProvider = AutoDisposeNotifierProvider<MapNotifier, MapState>(
  MapNotifier.new,
);