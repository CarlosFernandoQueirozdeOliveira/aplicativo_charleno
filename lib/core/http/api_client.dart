
import 'package:dio/dio.dart';
// Ideally ApiClient shouldn't depend on AuthService directly to avoid circular dep.
// We will just expose a way to set token or use interceptor.

import '../config/api_config.dart';
import '../errors/api_exception.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorage _storage;
  // Callback to trigger logout on 401
  final Function()? onUnauthorized; 

  ApiClient(this._storage, {this.onUnauthorized}) 
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!ApiConfig.isApiEnabled) {
          // If API is disabled, we reject immediately but we need to handle it gracefully in the repository.
          // Or we can return a specific error here.
           return handler.reject(
            DioException(
              requestOptions: options,
              error: const ApiNotConfiguredException(),
              type: DioExceptionType.cancel,
            ),
          );
        }

        final token = await _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Log detalhado para debug
        print('🔴 API Error: ${e.response?.statusCode ?? '-'} | ${e.requestOptions.method} ${e.requestOptions.uri}');
        print('🔴 Response: ${e.response?.data ?? e.message}');
        
        if (e.response?.statusCode == 401) {
          await _storage.deleteToken();
           onUnauthorized?.call();
           // We transform 401 to UnauthorizedException
           return handler.next(e.copyWith(error: const UnauthorizedException()));
        }
        
        // Transform other errors
        if (e.error is ApiNotConfiguredException) {
           return handler.next(e);
        }

        return handler.next(e); // Pass through other errors
      },
    ));
  }

  Dio get dio => _dio;
}
