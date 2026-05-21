import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/location_models.dart';

class LocationRepository {
  LocationRepository(this._ref);

  final Ref _ref;

  Future<void> updateLocation(double lat, double lng) async {
    final dio = _ref.read(dioClientProvider).dio;
    final response = await dio.put<Map<String, dynamic>>(
      '/location',
      data: <String, dynamic>{
        'latitude': lat,
        'longitude': lng,
      },
    );
    _ensureSuccess(response.data, fallback: 'No se pudo actualizar la ubicación');
  }

  Future<List<NearbyUser>> getNearbyUsers(double lat, double lng) async {
    final dio = _ref.read(dioClientProvider).dio;
    final response = await dio.get<Map<String, dynamic>>(
      '/location/nearby',
      queryParameters: <String, dynamic>{
        'lat': lat,
        'lng': lng,
        'radius': 1000,
        'limit': 50,
      },
    );

    final data = response.data;
    _ensureSuccess(data, fallback: 'No se pudieron cargar usuarios cercanos');

    final payload = data?['data'];
    final List<dynamic> usersJson = switch (payload) {
      List<dynamic> value => value,
      Map<String, dynamic> value => value['items'] as List<dynamic>? ?? <dynamic>[],
      _ => <dynamic>[],
    };

    return usersJson
        .whereType<Map<String, dynamic>>()
        .map(NearbyUser.fromJson)
        .where((user) => user.currentTrack != null)
        .toList(growable: false);
  }

  void _ensureSuccess(Map<String, dynamic>? response, {required String fallback}) {
    if (response == null) {
      throw Exception(fallback);
    }

    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] as String? ?? fallback);
    }
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(ref);
});