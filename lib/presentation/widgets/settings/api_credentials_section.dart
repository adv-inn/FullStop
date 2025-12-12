import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullstop/l10n/app_localizations.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/credentials_provider.dart';
import '../../../application/providers/playback_provider.dart';
import '../../../core/config/app_config.dart';
import '../../screens/setup_guide_screen.dart';
import '../../themes/app_theme.dart';

class ApiCredentialsSection extends ConsumerWidget {
  const ApiCredentialsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final credentialsState = ref.watch(credentialsProvider);

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.key),
          title: Text(l10n.spotifyApi),
          subtitle: Text(
            credentialsState.hasSpotifyCredentials
                ? l10n.configured(
                    _maskClientId(credentialsState.spotifyClientId),
                  )
                : l10n.notConfigured,
          ),
          trailing: credentialsState.hasSpotifyCredentials
              ? Icon(Icons.check_circle, color: AppTheme.spotifyGreen)
              : const Icon(Icons.warning, color: Colors.orange),
        ),
        ListTile(
          leading: const Icon(Icons.refresh),
          title: Text(l10n.reconfigureApiCredentials),
          subtitle: Text(l10n.changeClientIdSecret),
          onTap: () => _showReconfigureDialog(context, ref),
        ),
        _buildRedirectUriInfo(context),
      ],
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

  String _maskClientId(String? clientId) {
    if (clientId == null || clientId.length < 8) return '****';
    return '${clientId.substring(0, 4)}...${clientId.substring(clientId.length - 4)}';
  }

  void _showReconfigureDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.spotifyDarkGray,
        title: Text(l10n.reconfigureDialogTitle),
        content: Text(l10n.reconfigureDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Stop playback polling first to prevent 401 errors
              ref.read(playbackProvider.notifier).stopPolling();
              await ref
                  .read(credentialsProvider.notifier)
                  .clearSpotifyCredentials();
              await ref.read(authProvider.notifier).logout();
              // Navigate to SetupGuideScreen with isReconfiguring flag
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => SetupGuideScreen(
                      isReconfiguring: true,
                      // Pass a no-op callback since navigation is handled by pushReplacement
                      // The SetupGuideScreen will navigate back when setup is complete
                      onSetupComplete: () {
                        // Navigation is handled inside SetupGuideScreen using its own context
                      },
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.reconfigure),
          ),
        ],
      ),
    );
  }
}
