import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/credentials_local_datasource.dart';
import '../di/injection_container.dart';

/// State for app settings
class SettingsState {
  final bool isLoading;
  final bool audioFeaturesEnabled;
  final String? getSongBpmApiKey;
  final bool hasGetSongBpmApiKey;
  final bool gpuAccelerationEnabled;

  const SettingsState({
    this.isLoading = true,
    this.audioFeaturesEnabled = false,
    this.getSongBpmApiKey,
    this.hasGetSongBpmApiKey = false,
    this.gpuAccelerationEnabled = false,
  });

  SettingsState copyWith({
    bool? isLoading,
    bool? audioFeaturesEnabled,
    String? getSongBpmApiKey,
    bool? hasGetSongBpmApiKey,
    bool? gpuAccelerationEnabled,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      audioFeaturesEnabled: audioFeaturesEnabled ?? this.audioFeaturesEnabled,
      getSongBpmApiKey: getSongBpmApiKey ?? this.getSongBpmApiKey,
      hasGetSongBpmApiKey: hasGetSongBpmApiKey ?? this.hasGetSongBpmApiKey,
      gpuAccelerationEnabled:
          gpuAccelerationEnabled ?? this.gpuAccelerationEnabled,
    );
  }
}

/// Notifier for managing app settings
class SettingsNotifier extends StateNotifier<SettingsState> {
  final CredentialsLocalDataSource _dataSource;
  final Ref _ref;

  SettingsNotifier(this._dataSource, this._ref) : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final audioFeaturesEnabled = await _dataSource.getAudioFeaturesEnabled();
      final getSongBpmApiKey = await _dataSource.getGetSongBpmApiKey();
      final gpuAccelerationEnabled = await _dataSource
          .getGpuAccelerationEnabled();
      state = state.copyWith(
        isLoading: false,
        audioFeaturesEnabled: audioFeaturesEnabled,
        getSongBpmApiKey: getSongBpmApiKey,
        hasGetSongBpmApiKey:
            getSongBpmApiKey != null && getSongBpmApiKey.isNotEmpty,
        gpuAccelerationEnabled: gpuAccelerationEnabled,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setAudioFeaturesEnabled(bool enabled) async {
    try {
      await _dataSource.setAudioFeaturesEnabled(enabled);
      state = state.copyWith(audioFeaturesEnabled: enabled);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<bool> setGetSongBpmApiKey(String apiKey) async {
    try {
      await _dataSource.setGetSongBpmApiKey(apiKey);
      state = state.copyWith(
        getSongBpmApiKey: apiKey,
        hasGetSongBpmApiKey: apiKey.isNotEmpty,
      );
      // Invalidate BPM providers to use new API key
      _ref.invalidate(getSongBpmApiKeyProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearGetSongBpmApiKey() async {
    try {
      await _dataSource.clearGetSongBpmApiKey();
      state = state.copyWith(
        getSongBpmApiKey: null,
        hasGetSongBpmApiKey: false,
        audioFeaturesEnabled: false,
      );
      // Also disable audio features when API key is cleared
      await _dataSource.setAudioFeaturesEnabled(false);
      // Invalidate BPM providers
      _ref.invalidate(getSongBpmApiKeyProvider);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> setGpuAccelerationEnabled(bool enabled) async {
    try {
      await _dataSource.setGpuAccelerationEnabled(enabled);
      state = state.copyWith(gpuAccelerationEnabled: enabled);
    } catch (e) {
      // Ignore errors
    }
  }
}

/// Provider for app settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final dataSource = ref.watch(credentialsLocalDataSourceProvider);
    return SettingsNotifier(dataSource, ref);
  },
);

/// Convenience provider for audio features enabled state
/// BPM features are enabled when API key is configured
final audioFeaturesEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.hasGetSongBpmApiKey;
});

/// Convenience provider for GPU acceleration enabled state
final gpuAccelerationEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.gpuAccelerationEnabled;
});
