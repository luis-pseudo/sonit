import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/auth_models.dart';

class AuthRepository {
  AuthRepository(this._ref);

  final Ref _ref;

  Future<UserSummary> login(String email, String password) async {
    final dio = _ref.read(dioClientProvider).dio;
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: <String, dynamic>{
          'email': email,
          'password': password,
        },
      );
      final data = response.data;
      if (data == null) {
        throw Exception('Empty response');
      }

      final success = data['success'] as bool? ?? false;
      if (!success) {
        throw Exception(data['message'] as String? ?? 'Login failed');
      }

      final responseData = data['data'] as Map<String, dynamic>?;
      if (responseData == null) {
        throw Exception('No data in response');
      }

      final result = AuthResult.fromJson(responseData);
      await _ref.read(secureStorageProvider).saveTokens(
            result.tokens.accessToken,
            result.tokens.refreshToken,
          );
      return result.user;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Login error');
    }
  }

  Future<UserSummary> register(
    String displayName,
    String email,
    String password,
  ) async {
    final dio = _ref.read(dioClientProvider).dio;
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: <String, dynamic>{
          'displayName': displayName,
          'email': email,
          'password': password,
        },
      );
      final data = response.data;
      if (data == null) {
        throw Exception('Empty response');
      }

      final success = data['success'] as bool? ?? false;
      if (!success) {
        throw Exception(data['message'] as String? ?? 'Registration failed');
      }

      final responseData = data['data'] as Map<String, dynamic>?;
      if (responseData == null) {
        throw Exception('No data in response');
      }

      final result = AuthResult.fromJson(responseData);
      await _ref.read(secureStorageProvider).saveTokens(
            result.tokens.accessToken,
            result.tokens.refreshToken,
          );
      return result.user;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Registration error');
    }
  }

  Future<void> logout() async {
    await _ref.read(secureStorageProvider).clearTokens();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});
