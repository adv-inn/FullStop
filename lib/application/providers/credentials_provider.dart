import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/credentials_local_datasource.dart';
import '../di/injection_container.dart';

/// State for credentials configuration
class CredentialsState {
  final bool isLoading;
  final bool hasLlmConfig;
  final String? llmApiKey;
  final String? llmModel;
  final String? llmBaseUrl;
  final String? customSpotifyClientId;
  final String? error;

  const CredentialsState({
    this.isLoading = true,
    this.hasLlmConfig = false,
    this.llmApiKey,
    this.llmModel,
    this.llmBaseUrl,
    this.customSpotifyClientId,
    this.error,
  });

  CredentialsState copyWith({
    bool? isLoading,
    bool? hasLlmConfig,
    String? llmApiKey,
    String? llmModel,
    String? llmBaseUrl,
    String? customSpotifyClientId,
    String? error,
    bool clearLlmConfig = false,
    bool clearCustomClientId = false,
  }) {
    return CredentialsState(
      isLoading: isLoading ?? this.isLoading,
      hasLlmConfig: hasLlmConfig ?? this.hasLlmConfig,
      llmApiKey: clearLlmConfig ? null : (llmApiKey ?? this.llmApiKey),
      llmModel: clearLlmConfig ? null : (llmModel ?? this.llmModel),
      llmBaseUrl: clearLlmConfig ? null : (llmBaseUrl ?? this.llmBaseUrl),
      customSpotifyClientId: clearCustomClientId
          ? null
          : (customSpotifyClientId ?? this.customSpotifyClientId),
      error: error,
    );
  }
}

/// Notifier for managing credentials
class CredentialsNotifier extends StateNotifier<CredentialsState> {
  final CredentialsLocalDataSource _dataSource;

  CredentialsNotifier(this._dataSource) : super(const CredentialsState()) {
    _checkCredentials();
  }

  Future<void> _checkCredentials() async {
    try {
      final hasLlm = await _dataSource.hasLlmConfig();
      final llmApiKey = await _dataSource.getLlmApiKey();
      final llmModel = await _dataSource.getLlmModel();
      final llmBaseUrl = await _dataSource.getLlmBaseUrl();
      final customClientId = await _dataSource.getCustomSpotifyClientId();

      state = state.copyWith(
        isLoading: false,
        hasLlmConfig: hasLlm,
        llmApiKey: llmApiKey,
        llmModel: llmModel,
        llmBaseUrl: llmBaseUrl,
        customSpotifyClientId: customClientId,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> saveLlmCredentials({
    String apiKey = '',
    required String model,
    required String baseUrl,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Validate required fields
      if (model.trim().isEmpty || baseUrl.trim().isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Model and Base URL are required',
        );
        return false;
      }

      await _dataSource.saveLlmCredentials(
        apiKey: apiKey.trim(),
        model: model.trim(),
        baseUrl: baseUrl.trim(),
      );

      state = state.copyWith(
        isLoading: false,
        hasLlmConfig: true,
        llmApiKey: apiKey.trim(),
        llmModel: model.trim(),
        llmBaseUrl: baseUrl.trim(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save LLM config: $e',
      );
      return false;
    }
  }

  Future<void> clearLlmCredentials() async {
    try {
      state = state.copyWith(isLoading: true);
      await _dataSource.clearLlmCredentials();
      state = state.copyWith(
        isLoading: false,
        hasLlmConfig: false,
        clearLlmConfig: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear LLM config: $e',
      );
    }
  }

  Future<bool> saveCustomSpotifyClientId(String clientId) async {
    try {
      await _dataSource.saveCustomSpotifyClientId(clientId.trim());
      state = state.copyWith(customSpotifyClientId: clientId.trim());
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to save custom Client ID: $e');
      return false;
    }
  }

  Future<void> clearCustomSpotifyClientId() async {
    try {
      await _dataSource.clearCustomSpotifyClientId();
      state = state.copyWith(clearCustomClientId: true);
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear custom Client ID: $e');
    }
  }

  Future<void> refresh() async {
    await _checkCredentials();
  }
}

/// Provider for credentials management
final credentialsProvider =
    StateNotifierProvider<CredentialsNotifier, CredentialsState>((ref) {
      return CredentialsNotifier(ref.watch(credentialsLocalDataSourceProvider));
    });

/// Derived provider that returns the user-configured Spotify Client ID.
/// Returns empty string if not configured — login screen guards this.
final effectiveSpotifyClientIdProvider = Provider<String>((ref) {
  final creds = ref.watch(credentialsProvider);
  return creds.customSpotifyClientId ?? '';
});
