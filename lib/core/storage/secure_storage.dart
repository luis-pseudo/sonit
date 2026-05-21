import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';

class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> saveTokens(String access, String refresh) async {
    await Future.wait(<Future<void>>[
      _storage.write(key: AppConfig.accessTokenKey, value: access),
      _storage.write(key: AppConfig.refreshTokenKey, value: refresh),
    ]);
  }

  Future<String?> getAccessToken() {
    return _storage.read(key: AppConfig.accessTokenKey);
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: AppConfig.refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await Future.wait(<Future<void>>[
      _storage.delete(key: AppConfig.accessTokenKey),
      _storage.delete(key: AppConfig.refreshTokenKey),
    ]);
  }
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});