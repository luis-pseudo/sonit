import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

class AuthNotifier extends AutoDisposeAsyncNotifier<UserSummary?> {
  @override
  Future<UserSummary?> build() async {
    return checkAuthStatus();
  }

  Future<UserSummary?> checkAuthStatus() async {
    final dio = ref.read(dioClientProvider).dio;
    try {
      final response = await dio.get<Map<String, dynamic>>('/users/me');
      final data = response.data;
      if (data == null) {
        return null;
      }

      final success = data['success'] as bool? ?? false;
      if (!success) {
        return null;
      }

      final responseData = data['data'] as Map<String, dynamic>?;
      if (responseData == null) {
        return null;
      }

      return UserSummary.fromJson(responseData);
    } catch (_) {
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    final repository = ref.read(authRepositoryProvider);
    final user = await repository.login(email, password);
    state = AsyncValue.data(user);
  }

  Future<void> register(
    String displayName,
    String email,
    String password,
  ) async {
    final repository = ref.read(authRepositoryProvider);
    final user = await repository.register(displayName, email, password);
    state = AsyncValue.data(user);
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncValue.data(null);
  }
}

final authProvider = AutoDisposeAsyncNotifierProvider<AuthNotifier, UserSummary?>(
  AuthNotifier.new,
);
