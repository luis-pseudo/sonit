import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/config/app_config.dart';
import '../../../core/storage/secure_storage.dart';

@pragma('vm:entry-point')
Future<bool> onBackgroundStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final secureStorage = SecureStorage();
  Timer? pollingTimer;

  service.on('stopService').listen((event) {
    pollingTimer?.cancel();
    service.stopSelf();
  });

  Future<void> updateLocationInBackground() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        pollingTimer?.cancel();
        service.stopSelf();
        return;
      }

      await dio.put<Map<String, dynamic>>(
        '/location',
        data: <String, dynamic>{
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
    } catch (_) {
      // Silently fail and keep polling
    }
  }

  pollingTimer = Timer.periodic(
    const Duration(seconds: AppConfig.locationUpdateIntervalSeconds),
    (_) => updateLocationInBackground(),
  );

  // Initial update
  updateLocationInBackground();

  return true;
}

class BackgroundLocationService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onBackgroundStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'sonit_location',
        initialNotificationTitle: 'Sonit activo',
        initialNotificationContent: 'Compartiendo tu música',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onBackgroundStart,
        onBackground: onBackgroundStart,
      ),
    );
  }

  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }
}
