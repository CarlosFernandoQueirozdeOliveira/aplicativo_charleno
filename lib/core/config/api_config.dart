enum ApiMode { disabled, enabled }

class ApiConfig {
  /// URL base da API FastAPI
  /// Configure via: flutter run --dart-define=API_BASE_URL=http://SEU_IP:8000/api/v1
  /// Padrão: 10.0.2.2 para Android Emulator, localhost para iOS/Web
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
  
  /// Modo da API:
  /// - disabled: usa dados mock (desenvolvimento sem backend)
  /// - enabled: usa a API real
  static const ApiMode mode = ApiMode.enabled;
  
  static bool get isApiEnabled => mode == ApiMode.enabled;
}
