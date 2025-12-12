import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/proxy_provider.dart';
import '../../../domain/entities/proxy_settings.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/app_theme.dart';

class ProxySettingsSection extends ConsumerStatefulWidget {
  const ProxySettingsSection({super.key});

  @override
  ConsumerState<ProxySettingsSection> createState() =>
      _ProxySettingsSectionState();
}

class _ProxySettingsSectionState extends ConsumerState<ProxySettingsSection> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _enabled = false;
  AppProxyType _type = AppProxyType.http;
  bool _initialized = false;

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _initFromState(ProxyState proxyState) {
    if (_initialized) return;
    _initialized = true;
    _enabled = proxyState.config.enabled;
    _type = proxyState.config.type;
    _hostController.text = proxyState.config.host;
    _portController.text = proxyState.config.port > 0
        ? proxyState.config.port.toString()
        : '';
    _usernameController.text = proxyState.config.username ?? '';
    _passwordController.text = proxyState.config.password ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final proxyState = ref.watch(proxyProvider);

    // Initialize when loaded
    if (!proxyState.isLoading && !_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initFromState(proxyState);
        if (mounted) setState(() {});
      });
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.speed, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.proxyHint,
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: Text(l10n.proxyEnabled),
          value: _enabled,
          activeColor: AppTheme.spotifyGreen,
          onChanged: (value) {
            setState(() => _enabled = value);
            if (!value) {
              _saveConfig();
            }
          },
        ),
        if (_enabled) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(l10n.proxyType, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 16),
                Expanded(
                  child: SegmentedButton<AppProxyType>(
                    segments: const [
                      ButtonSegment(
                        value: AppProxyType.http,
                        label: Text('HTTP'),
                      ),
                      ButtonSegment(
                        value: AppProxyType.socks5,
                        label: Text('SOCKS5'),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selected) {
                      setState(() => _type = selected.first);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return AppTheme.spotifyGreen;
                        }
                        return Colors.transparent;
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _hostController,
                    decoration: InputDecoration(
                      labelText: l10n.proxyHost,
                      hintText: '127.0.0.1',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _portController,
                    decoration: InputDecoration(
                      labelText: l10n.proxyPort,
                      hintText: '1080',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: l10n.proxyUsername,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.proxyPassword,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _testConnection,
                    icon: const Icon(Icons.network_check),
                    label: Text(l10n.testProxy),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveConfig,
                    icon: const Icon(Icons.save),
                    label: Text(l10n.save),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.spotifyGreen,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  AppProxySettings _buildConfig() {
    final port = int.tryParse(_portController.text) ?? 0;
    return AppProxySettings(
      enabled: _enabled,
      type: _type,
      host: _hostController.text.trim(),
      port: port,
      username: _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim(),
      password: _passwordController.text.isEmpty
          ? null
          : _passwordController.text,
    );
  }

  Future<void> _saveConfig() async {
    final l10n = AppLocalizations.of(context)!;
    final config = _buildConfig();

    if (_enabled && !config.isValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.proxyInvalid)));
      return;
    }

    final success = await ref.read(proxyProvider.notifier).saveConfig(config);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? l10n.proxySaved : l10n.proxyInvalid)),
      );
    }
  }

  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context)!;
    final config = _buildConfig().copyWith(enabled: true);

    if (!config.isValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.proxyInvalid)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Testing connection...')));

    try {
      await ref.read(proxyProvider.notifier).saveConfig(config);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.proxyTestSuccess),
            backgroundColor: AppTheme.spotifyGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.proxyTestFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
