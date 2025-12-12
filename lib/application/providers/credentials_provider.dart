import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/credentials_local_datasource.dart';
import '../di/injection_container.dart';

/// State for credentials configuration
class CredentialsState {
  final bool isLoading;
  final bool hasSpotifyCredentials;
  final bool hasLlmConfig;
  final String? spotifyClientId;
  final String? spotifyClientSecret;
  final String? llmApiKey;
  final String? llmModel;
  final String? llmBaseUrl;
  final String? error;

  const CredentialsState({
    this.isLoading = true,
    this.hasSpotifyCredentials = false,
    this.hasLlmConfig = false,
    this.spotifyClientId,
    this.spotifyClientSecret,
    this.llmApiKey,
    this.llmModel,
    this.llmBaseUrl,
    this.error,
  });

  CredentialsState copyWith({
    bool? isLoading,
    bool? hasSpotifyCredentials,
    bool? hasLlmConfig,
    String? spotifyClientId,
    String? spotifyClientSecret,
    String? llmApiKey,
    String? llmModel,
    String? llmBaseUrl,
    String? error,
    bool clearSpotifyCredentials = false,
    bool clearLlmConfig = false,
  }) {
    return CredentialsState(
      isLoading: isLoading ?? this.isLoading,
      hasSpotifyCredentials:
          hasSpotifyCredentials ?? this.hasSpotifyCredentials,
      hasLlmConfig: hasLlmConfig ?? this.hasLlmConfig,
      spotifyClientId: clearSpotifyCredentials
          ? null
          : (spotifyClientId ?? this.spotifyClientId),
      spotifyClientSecret: clearSpotifyCredentials
          ? null
          : (spotifyClientSecret ?? this.spotifyClientSecret),
      llmApiKey: clearLlmConfig ? null : (llmApiKey ?? this.llmApiKey),
      llmModel: clearLlmConfig ? null : (llmModel ?? this.llmModel),
      llmBaseUrl: clearLlmConfig ? null : (llmBaseUrl ?? this.llmBaseUrl),
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
      final hasSpotify = await _dataSource.hasSpotifyCredentials();
      final hasLlm = await _dataSource.hasLlmConfig();
      final clientId = await _dataSource.getSpotifyClientId();
      final clientSecret = await _dataSource.getSpotifyClientSecret();
      final llmApiKey = await _dataSource.getLlmApiKey();
      final llmModel = await _dataSource.getLlmModel();
      final llmBaseUrl = await _dataSource.getLlmBaseUrl();

      state = state.copyWith(
        isLoading: false,
        hasSpotifyCredentials: hasSpotify,
        hasLlmConfig: hasLlm,
        spotifyClientId: clientId,
        spotifyClientSecret: clientSecret,
        llmApiKey: llmApiKey,
        llmModel: llmModel,
        llmBaseUrl: llmBaseUrl,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> saveSpotifyCredentials({
    required String clientId,
    required String clientSecret,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Validate inputs
      if (clientId.trim().isEmpty || clientSecret.trim().isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Client ID and Client Secret are required',
        );
        return false;
      }

      await _dataSource.saveSpotifyCredentials(
        clientId: clientId.trim(),
        clientSecret: clientSecret.trim(),
      );

      state = state.copyWith(
        isLoading: false,
        hasSpotifyCredentials: true,
        spotifyClientId: clientId.trim(),
        spotifyClientSecret: clientSecret.trim(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save credentials: $e',
      );
      return false;
    }
  }

  Future<void> clearSpotifyCredentials() async {
    try {
      state = state.copyWith(isLoading: true);
      await _dataSource.clearSpotifyCredentials();
      state = state.copyWith(
        isLoading: false,
        hasSpotifyCredentials: false,
        clearSpotifyCredentials: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear credentials: $e',
      );
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

  Future<void> refresh() async {
    await _checkCredentials();
  }
}

/// Provider for credentials management
final credentialsProvider =
    StateNotifierProvider<CredentialsNotifier, CredentialsState>((ref) {
      return CredentialsNotifier(ref.watch(credentialsLocalDataSourceProvider));
    });

/// Helper provider to get Spotify credentials for API calls
final spotifyCredentialsProvider = FutureProvider<SpotifyCredentials?>((
  ref,
) async {
  final dataSource = ref.watch(credentialsLocalDataSourceProvider);
  final clientId = await dataSource.getSpotifyClientId();
  final clientSecret = await dataSource.getSpotifyClientSecret();

  if (clientId == null ||
      clientId.isEmpty ||
      clientSecret == null ||
      clientSecret.isEmpty) {
    return null;
  }

  return SpotifyCredentials(clientId: clientId, clientSecret: clientSecret);
});

class SpotifyCredentials {
  final String clientId;
  final String clientSecret;

  const SpotifyCredentials({
    required this.clientId,
    required this.clientSecret,
  });
}
