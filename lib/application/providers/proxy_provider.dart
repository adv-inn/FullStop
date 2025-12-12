import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../data/datasources/credentials_local_datasource.dart';
import '../../domain/entities/proxy_settings.dart';
import '../di/injection_container.dart';

/// State for proxy configuration
class ProxyState {
  final bool isLoading;
  final AppProxySettings config;
  final String? error;

  const ProxyState({
    this.isLoading = true,
    this.config = const AppProxySettings(),
    this.error,
  });

  ProxyState copyWith({
    bool? isLoading,
    AppProxySettings? config,
    String? error,
  }) {
    return ProxyState(
      isLoading: isLoading ?? this.isLoading,
      config: config ?? this.config,
      error: error,
    );
  }
}

/// Notifier for managing proxy configuration
class ProxyNotifier extends StateNotifier<ProxyState> {
  final CredentialsLocalDataSource _dataSource;
  final void Function(AppProxySettings?) _onProxyChanged;

  ProxyNotifier(this._dataSource, this._onProxyChanged)
    : super(const ProxyState()) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final config = await _dataSource.getAppProxySettings();
      AppLogger.debug(
        '[Proxy] Loaded config: enabled=${config.enabled}, host=${config.host}, port=${config.port}',
      );
      state = state.copyWith(isLoading: false, config: config);
      // Apply proxy on load if enabled
      if (config.enabled && config.isValid) {
        _onProxyChanged(config);
        AppLogger.debug('[Proxy] Applied proxy on startup');
      }
    } catch (e) {
      AppLogger.error('[Proxy] Load error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> saveConfig(AppProxySettings config) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _dataSource.saveAppProxySettings(config);
      state = state.copyWith(isLoading: false, config: config);
      // Apply or remove proxy
      if (config.enabled && config.isValid) {
        _onProxyChanged(config);
        AppLogger.debug('[Proxy] Enabled: ${config.host}:${config.port}');
      } else {
        _onProxyChanged(null);
        AppLogger.debug('[Proxy] Disabled');
      }
      return true;
    } catch (e) {
      AppLogger.error('[Proxy] Save error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save proxy config: $e',
      );
      return false;
    }
  }

  Future<void> clearConfig() async {
    try {
      state = state.copyWith(isLoading: true);
      await _dataSource.clearAppProxySettings();
      state = state.copyWith(
        isLoading: false,
        config: const AppProxySettings(),
      );
      _onProxyChanged(null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear proxy config: $e',
      );
    }
  }

  void updateConfig(AppProxySettings config) {
    state = state.copyWith(config: config);
  }
}

/// Provider for proxy management
final proxyProvider = StateNotifierProvider<ProxyNotifier, ProxyState>((ref) {
  final dataSource = ref.watch(credentialsLocalDataSourceProvider);
  final proxyUpdater = ref.watch(proxyUpdaterProvider);
  return ProxyNotifier(dataSource, proxyUpdater);
});
