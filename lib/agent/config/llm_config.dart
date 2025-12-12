/// LLM Configuration for OpenAI-compatible APIs
/// Supports OpenAI, Ollama, and other OpenAI-compatible endpoints
class LlmConfig {
  final String apiKey;
  final String model;
  final String baseUrl;
  final double temperature;
  final int maxTokens;

  const LlmConfig({
    this.apiKey = '',
    required this.model,
    required this.baseUrl,
    this.temperature = 0.7,
    this.maxTokens = 1024,
  });

  /// Default configuration for OpenAI
  factory LlmConfig.openai({required String apiKey, String model = 'gpt-4'}) {
    return LlmConfig(
      apiKey: apiKey,
      model: model,
      baseUrl: 'https://api.openai.com/v1',
    );
  }

  /// Default configuration for Ollama (local)
  factory LlmConfig.ollama({
    String model = 'llama3',
    String host = 'http://localhost:11434',
  }) {
    return LlmConfig(
      apiKey: '', // Ollama doesn't require API key
      model: model,
      baseUrl: '$host/v1',
    );
  }

  /// Custom OpenAI-compatible endpoint
  factory LlmConfig.custom({
    String apiKey = '',
    required String model,
    required String baseUrl,
  }) {
    return LlmConfig(apiKey: apiKey, model: model, baseUrl: baseUrl);
  }

  /// Check if configuration is valid (has baseUrl and model)
  /// API key is optional for local models like Ollama
  bool get isValid => baseUrl.isNotEmpty && model.isNotEmpty;

  /// Check if API key is required (non-localhost endpoints typically need it)
  bool get requiresApiKey {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null) return true;
    final host = uri.host.toLowerCase();
    return !host.contains('localhost') && !host.contains('127.0.0.1');
  }

  /// Get headers for API requests
  Map<String, String> get headers {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
    return headers;
  }

  LlmConfig copyWith({
    String? apiKey,
    String? model,
    String? baseUrl,
    double? temperature,
    int? maxTokens,
  }) {
    return LlmConfig(
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      baseUrl: baseUrl ?? this.baseUrl,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }
}
