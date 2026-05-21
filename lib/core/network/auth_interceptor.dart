import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/secure_storage.dart';

final sessionExpiredProvider = StateProvider<int>((ref) => 0);

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.ref)
      : _refreshClient = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

  final Ref ref;
  final Dio _refreshClient;
  Future<_TokenPair?>? _refreshing;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path != '/auth/refresh') {
      final accessToken = await ref.read(secureStorageProvider).getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshRequest = err.requestOptions.path == '/auth/refresh';
    if (!isUnauthorized || isRefreshRequest) {
      handler.next(err);
      return;
    }

    final refreshedTokens = await _refreshTokens();
    if (refreshedTokens == null) {
      await ref.read(secureStorageProvider).clearTokens();
      ref.read(sessionExpiredProvider.notifier).state++;
      handler.next(err);
      return;
    }

    final requestOptions = err.requestOptions;
    requestOptions.headers['Authorization'] = 'Bearer ${refreshedTokens.accessToken}';

    try {
      final response = await _refreshClient.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (dioError) {
      handler.next(dioError);
    }
  }

  Future<_TokenPair?> _refreshTokens() {
    final currentRefresh = _refreshing;
    if (currentRefresh != null) {
      return currentRefresh;
    }

    final completer = Completer<_TokenPair?>();
    _refreshing = completer.future;

    () async {
      try {
        final refreshToken = await ref.read(secureStorageProvider).getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          completer.complete(null);
          return;
        }

        final response = await _refreshClient.post<dynamic>(
          '/auth/refresh',
          data: <String, dynamic>{'refreshToken': refreshToken},
        );
        final tokenPair = _parseTokenPair(response.data);
        if (tokenPair == null) {
          completer.complete(null);
          return;
        }

        await ref.read(secureStorageProvider).saveTokens(
              tokenPair.accessToken,
              tokenPair.refreshToken,
            );
        completer.complete(tokenPair);
      } catch (_) {
        completer.complete(null);
      } finally {
        _refreshing = null;
      }
    }();

    return completer.future;
  }

  _TokenPair? _parseTokenPair(dynamic data) {
    final responseMap = switch (data) {
      Map<String, dynamic> value => value,
      _ => null,
    };
    if (responseMap == null) {
      return null;
    }

    final payload = responseMap['data'];
    final payloadMap = switch (payload) {
      Map<String, dynamic> value => value,
      _ => responseMap,
    };

    final accessToken = payloadMap['accessToken'] as String?;
    final refreshToken = payloadMap['refreshToken'] as String?;
    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return _TokenPair(accessToken: accessToken, refreshToken: refreshToken);
  }
}

class _TokenPair {
  const _TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}