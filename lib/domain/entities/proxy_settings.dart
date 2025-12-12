import 'package:equatable/equatable.dart';

/// Proxy type enum for domain layer
/// Named with App prefix to avoid conflict with socks5_proxy package
enum AppProxyType { http, socks5 }

/// Domain entity for proxy settings
/// This is the domain representation used by presentation and application layers
/// Named AppProxySettings to avoid conflict with socks5_proxy package
class AppProxySettings extends Equatable {
  final bool enabled;
  final AppProxyType type;
  final String host;
  final int port;
  final String? username;
  final String? password;

  const AppProxySettings({
    this.enabled = false,
    this.type = AppProxyType.http,
    this.host = '',
    this.port = 0,
    this.username,
    this.password,
  });

  bool get isValid => host.isNotEmpty && port > 0 && port <= 65535;

  bool get hasAuth => username != null && username!.isNotEmpty;

  String get proxyUrl {
    final auth = hasAuth ? '$username:${password ?? ''}@' : '';
    final protocol = type == AppProxyType.socks5 ? 'socks5' : 'http';
    return '$protocol://$auth$host:$port';
  }

  AppProxySettings copyWith({
    bool? enabled,
    AppProxyType? type,
    String? host,
    int? port,
    String? username,
    String? password,
    bool clearAuth = false,
  }) {
    return AppProxySettings(
      enabled: enabled ?? this.enabled,
      type: type ?? this.type,
      host: host ?? this.host,
      port: port ?? this.port,
      username: clearAuth ? null : (username ?? this.username),
      password: clearAuth ? null : (password ?? this.password),
    );
  }

  @override
  List<Object?> get props => [enabled, type, host, port, username, password];
}

/// Type alias for backward compatibility
typedef ProxyConfig = AppProxySettings;
typedef ProxyType = AppProxyType;
