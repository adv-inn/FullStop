import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/providers/credentials_provider.dart';
import '../../core/config/app_config.dart';
import '../themes/app_theme.dart';
import '../widgets/app_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _clientIdController = TextEditingController();
  bool _clientIdSaved = false;

  @override
  void initState() {
    super.initState();
    // Load existing client ID if any
    final creds = ref.read(credentialsProvider);
    if (creds.customSpotifyClientId != null &&
        creds.customSpotifyClientId!.isNotEmpty) {
      _clientIdController.text = creds.customSpotifyClientId!;
      _clientIdSaved = true;
    }
    _clientIdController.addListener(_onClientIdChanged);
  }

  void _onClientIdChanged() {
    // Mark unsaved when text changes after a save
    if (_clientIdSaved &&
        _clientIdController.text.trim() !=
            ref.read(credentialsProvider).customSpotifyClientId) {
      setState(() => _clientIdSaved = false);
    }
  }

  @override
  void dispose() {
    _clientIdController.removeListener(_onClientIdChanged);
    _clientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final l10n = AppLocalizations.of(context)!;
    final effectiveClientId = ref.watch(effectiveSpotifyClientIdProvider);
    final hasClientId = effectiveClientId.isNotEmpty && _clientIdSaved;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  64 -
                  MediaQuery.of(context).padding.vertical,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const AppLogo(size: 120),
                const SizedBox(height: 32),
                Text(
                  l10n.appTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.focusOnFavoriteArtists,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.spotifyLightGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Loading state with cancel option
                if (isLoading) _buildLoadingState(context, ref),

                // Error message
                if (authState.status == AuthStatus.error)
                  _buildErrorMessage(context, ref, authState.errorMessage),

                // Client ID input (always visible, required)
                if (!isLoading) _buildClientIdSection(context, l10n),

                const SizedBox(height: 20),

                // Login button (disabled without client ID)
                if (!isLoading)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: hasClientId
                          ? () => ref.read(authProvider.notifier).login()
                          : null,
                      icon: const Icon(Icons.login),
                      label: Text(l10n.connectWithSpotify),
                    ),
                  ),
                const SizedBox(height: 24),

                // Info section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.spotifyDarkGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.lock_outline,
                        l10n.credentialsStayOnDevice,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.speaker_group,
                        l10n.controlsExistingSession,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.workspace_premium,
                        l10n.requiresPremium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientIdSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.spotifyDarkGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customClientIdDescription,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.spotifyLightGray.withValues(alpha: 0.8),
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
              suffixIcon: _clientIdSaved
                  ? Icon(Icons.check_circle, color: AppTheme.spotifyGreen, size: 20)
                  : null,
            ),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton(
                onPressed: () => _saveClientId(l10n),
                child: Text(l10n.save),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Redirect URI info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.redirectUriForSpotifyApp,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
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
          ),
        ],
      ),
    );
  }

  Future<void> _saveClientId(AppLocalizations l10n) async {
    final value = _clientIdController.text.trim();
    if (value.isEmpty) return;

    final notifier = ref.read(credentialsProvider.notifier);
    final success = await notifier.saveCustomSpotifyClientId(value);

    if (!mounted) return;

    if (success) {
      setState(() => _clientIdSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customClientIdSaved)),
      );
    }
  }

  Widget _buildLoadingState(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.spotifyDarkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.spotifyGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.spotifyGreen),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.connectingToSpotify,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.completeLoginInBrowser,
            style: TextStyle(fontSize: 13, color: AppTheme.spotifyLightGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.spotifyGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 16, color: AppTheme.spotifyGreen),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.afterAgreeCloseBrowser,
                    style: TextStyle(fontSize: 12, color: AppTheme.spotifyGreen),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => ref.read(authProvider.notifier).cancelLogin(),
              icon: const Icon(Icons.cancel, size: 20),
              label: Text(AppLocalizations.of(context)!.cancelLogin),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.cancelHint,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.spotifyLightGray.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.spotifyLightGray),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: AppTheme.spotifyLightGray),
          ),
        ),
      ],
    );
  }

  String _getErrorMessage(BuildContext context, String? error) {
    final l10n = AppLocalizations.of(context)!;
    if (error == null) return 'An unknown error occurred';
    final lowerError = error.toLowerCase();
    if (lowerError.contains('invalid_client') ||
        lowerError.contains('invalid client')) {
      if (lowerError.contains('redirect')) return l10n.errorRedirectUri;
      return l10n.errorInvalidClient;
    }
    if (lowerError.contains('redirect_uri') ||
        lowerError.contains('callback')) {
      return l10n.errorRedirectUri;
    }
    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return l10n.errorNetwork;
    }
    if (lowerError.contains('cancelled') || lowerError.contains('canceled')) {
      return l10n.errorCancelled;
    }
    if (lowerError.contains('timed out') || lowerError.contains('timeout')) {
      return l10n.errorTimeout;
    }
    if (lowerError.contains('port') || lowerError.contains('bind')) {
      return 'Could not start local server. All ports are in use. Please close other applications and try again.';
    }
    if (lowerError.contains('access_denied')) {
      return l10n.errorAccessDenied;
    }
    if (lowerError.contains('certificate') || lowerError.contains('ssl')) {
      return 'SSL certificate error. Please ensure your browser accepts the local certificate.';
    }
    return error;
  }

  Widget _buildErrorMessage(
    BuildContext context,
    WidgetRef ref,
    String? errorMessage,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final displayMessage = _getErrorMessage(context, errorMessage);
    final rawError = errorMessage ?? 'Unknown error';

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.connectionFailed,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: rawError));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.errorCopied),
                      backgroundColor: AppTheme.spotifyDarkGray,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                color: Colors.red.shade300,
                tooltip: 'Copy error message',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            displayMessage,
            style: TextStyle(color: Colors.red.shade300, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
