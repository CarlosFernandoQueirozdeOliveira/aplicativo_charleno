
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/http/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/config/api_config.dart'; // To check API enabled mode for mock logic

part 'auth_service.g.dart';

// Providers for dependencies (Manual injection for now or generate later)
@riverpod
SecureStorage secureStorage(Ref ref) => SecureStorage();

@riverpod
ApiClient apiClient(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage, onUnauthorized: () {
     // Handle global logout if needed, e.g. invalidate provider
  });
}

@riverpod
AuthService authService(Ref ref) {
  return AuthService(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
}

class AuthService {
  final ApiClient _client;
  final SecureStorage _storage;

  AuthService(this._client, this._storage);

  Future<void> login(String email, String password) async {
    if (!ApiConfig.isApiEnabled) {
      // Offline/Mock Mode
      // Simulating a network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulating login logic
      if (email.contains('erro')) {
        throw Exception('Erro simulado de login');
      }
      
      // Save fake token
      await _storage.saveToken('fake_jwt_token_offline_mode');
      return;
    }

    // Real API implementation
    final response = await _client.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    // Assuming backend returns { "access_token": "...", "user_id": "...", "user_name": "..." }
    final data = response.data;
    final token = data['access_token'];
    final userId = data['user_id'];
    final userName = data['user_name'];

    await _storage.saveToken(token);
    
    if (userId != null && userName != null) {
      await _storage.saveUser(userId.toString(), userName.toString());
    }
  }

  Future<String?> getUserId() => _storage.getUserId();

  Future<void> logout() async {
    await _storage.deleteToken();
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    return token != null;
  }
}
