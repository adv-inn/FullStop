import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullstop/l10n/app_localizations.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/credentials_provider.dart';
import '../../../core/config/app_config.dart';
import '../../themes/app_theme.dart';

class ApiCredentialsSection extends ConsumerStatefulWidget {
  const ApiCredentialsSection({super.key});

  @override
  ConsumerState<ApiCredentialsSection> createState() =>
      _ApiCredentialsSectionState();
}

class _ApiCredentialsSectionState extends ConsumerState<ApiCredentialsSection> {
  bool _editing = false;
  final _clientIdController = TextEditingController();

  @override
  void dispose() {
    _clientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final effectiveClientId = ref.watch(effectiveSpotifyClientIdProvider);
    final hasClientId = effectiveClientId.isNotEmpty;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.key),
          title: Text(l10n.spotifyApi),
          subtitle: Text(
            hasClientId
                ? l10n.configured(_maskClientId(effectiveClientId))
                : l10n.customClientIdHint,
          ),
          trailing: hasClientId
              ? Icon(Icons.check_circle, color: AppTheme.spotifyGreen)
              : const Icon(Icons.warning_amber, color: Colors.orange),
          onTap: () {
            setState(() {
              _editing = !_editing;
              if (_editing && hasClientId) {
                _clientIdController.text = effectiveClientId;
              }
            });
          },
        ),
        _buildRedirectUriInfo(context),
        if (_editing) _buildEditSection(context, l10n),
      ],
    );
  }

  Widget _buildEditSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customClientIdDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _clientIdController,
            decoration: InputDecoration(
              labelText: l10n.customClientId,
              hintText: l10n.customClientIdHint,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton(
                onPressed: () => _saveClientId(context, l10n),
                child: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveClientId(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final value = _clientIdController.text.trim();
    if (value.isEmpty) return;

    final notifier = ref.read(credentialsProvider.notifier);
    final success = await notifier.saveCustomSpotifyClientId(value);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customClientIdSaved)),
      );
      _showReauthDialog(context, l10n);
    }
  }

  void _showReauthDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.customClientIdReauthRequired),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
            },
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  Widget _buildRedirectUriInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.redirectUriForSpotifyApp,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  AppConfig.spotifyRedirectUri,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _maskClientId(String clientId) {
    if (clientId.length < 8) return '****';
    return '${clientId.substring(0, 4)}...${clientId.substring(clientId.length - 4)}';
  }
}
