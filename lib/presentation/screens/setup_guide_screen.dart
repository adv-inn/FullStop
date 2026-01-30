import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullstop/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../application/providers/credentials_provider.dart';
import '../../core/config/app_config.dart';
import '../themes/app_theme.dart';
import '../widgets/app_logo.dart';

class SetupGuideScreen extends ConsumerStatefulWidget {
  final VoidCallback onSetupComplete;
  final bool isReconfiguring;

  const SetupGuideScreen({
    super.key,
    required this.onSetupComplete,
    this.isReconfiguring = false,
  });

  @override
  ConsumerState<SetupGuideScreen> createState() => _SetupGuideScreenState();
}

class _SetupGuideScreenState extends ConsumerState<SetupGuideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();
  bool _obscureSecret = true;
  int _currentStep = 0;
  bool _hasLoadedExistingCredentials = false;

  @override
  void initState() {
    super.initState();
    // If reconfiguring, start at step 2 (credentials entry)
    if (widget.isReconfiguring) {
      _currentStep = 1;
    }
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  void _loadExistingCredentials(CredentialsState credentialsState) {
    if (!_hasLoadedExistingCredentials && widget.isReconfiguring) {
      // Pre-fill existing credentials
      if (credentialsState.spotifyClientId != null) {
        _clientIdController.text = credentialsState.spotifyClientId!;
      }
      if (credentialsState.spotifyClientSecret != null) {
        _clientSecretController.text = credentialsState.spotifyClientSecret!;
      }
      _hasLoadedExistingCredentials = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final credentialsState = ref.watch(credentialsProvider);
    final l10n = AppLocalizations.of(context)!;

    // Load existing credentials when reconfiguring
    _loadExistingCredentials(credentialsState);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const AppLogo(size: 80),
                  const SizedBox(height: 16),
                  Text(
                    widget.isReconfiguring
                        ? l10n.updateCredentials
                        : l10n.welcomeToFullStop,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isReconfiguring
                        ? l10n.updateSpotifyCredentials
                        : l10n.connectSpotifyToStart,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.spotifyLightGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Security Notice
            _buildSecurityNotice(),

            const SizedBox(height: 16),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 24),
                    _buildCurrentStepContent(credentialsState),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(credentialsState),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.spotifyGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.spotifyGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.security, color: AppTheme.spotifyGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.credentialsSecurelyStored,
              style: TextStyle(fontSize: 12, color: AppTheme.spotifyLightGray),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 18),
            color: AppTheme.spotifyGreen,
            onPressed: () => _showPrivacyPolicy(context),
            tooltip: l10n.privacyPolicy,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        for (int i = 0; i < 3; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= _currentStep
                    ? AppTheme.spotifyGreen
                    : AppTheme.spotifyDarkGray,
              ),
            ),
          GestureDetector(
            onTap: () => setState(() => _currentStep = i),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: i <= _currentStep
                    ? AppTheme.spotifyGreen
                    : AppTheme.spotifyDarkGray,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: i < _currentStep
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: AppTheme.spotifyBlack,
                      )
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i <= _currentStep
                              ? AppTheme.spotifyBlack
                              : AppTheme.spotifyLightGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrentStepContent(CredentialsState credentialsState) {
    switch (_currentStep) {
      case 0:
        return _buildStep1CreateApp();
      case 1:
        return _buildStep2EnterCredentials(credentialsState);
      case 2:
        return _buildStep3Confirm(credentialsState);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1CreateApp() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.step1CreateApp,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildInstructionCard(
          icon: Icons.open_in_new,
          title: '1. ${l10n.openDeveloperDashboard}',
          description: l10n.openDeveloperDashboardHint,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _launchUrl('https://developer.spotify.com/dashboard'),
              icon: const Icon(Icons.open_in_browser),
              label: Text(l10n.openDeveloperDashboard),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          icon: Icons.add_circle_outline,
          title: '2. ${l10n.createNewApp}',
          description: l10n.createNewAppDescShort,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildCopyableField(
                label: l10n.appNameLabel,
                value: 'FullStop',
                onCopied: () => _showCopiedSnackbar(l10n.appNameCopied),
              ),
              const SizedBox(height: 8),
              _buildCopyableField(
                label: l10n.appDescriptionLabel,
                value: 'FullStop Custom API Client',
                onCopied: () => _showCopiedSnackbar(l10n.appDescriptionCopied),
              ),
              const SizedBox(height: 8),
              _buildCopyableField(
                label: l10n.redirectUriLabel,
                value: AppConfig.spotifyRedirectUri,
                onCopied: () => _showCopiedSnackbar(l10n.redirectUriCopied),
                isHighlighted: true,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.redirectUriWarning,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCopyableField({
    required String label,
    required String value,
    required VoidCallback onCopied,
    bool isHighlighted = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.spotifyBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.spotifyLightGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.spotifyLightGray,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: isHighlighted
                        ? AppTheme.spotifyGreen
                        : AppTheme.spotifyWhite,
                    fontSize: 13,
                    fontWeight: isHighlighted
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              onCopied();
            },
            icon: const Icon(Icons.copy, size: 18),
            color: AppTheme.spotifyGreen,
            tooltip: l10n.copy,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  void _showCopiedSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.spotifyGreen,
      ),
    );
  }

  Widget _buildStep2EnterCredentials(CredentialsState credentialsState) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isReconfiguring
                ? l10n.updateYourCredentials
                : l10n.step2EnterCredentials,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isReconfiguring
                ? l10n.modifyCredentialsHint
                : l10n.findCredentialsHint,
            style: TextStyle(fontSize: 14, color: AppTheme.spotifyLightGray),
          ),
          const SizedBox(height: 24),

          // Client ID field
          Text(
            l10n.clientId,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _clientIdController,
            style: const TextStyle(color: AppTheme.spotifyWhite),
            decoration: InputDecoration(
              hintText: l10n.enterClientId,
              prefixIcon: const Icon(Icons.key),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppTheme.spotifyDarkGray,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.clientIdRequired;
              }
              if (value.trim().length < 10) {
                return l10n.clientIdTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Client Secret field
          Text(
            l10n.clientSecret,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _clientSecretController,
            obscureText: _obscureSecret,
            style: const TextStyle(color: AppTheme.spotifyWhite),
            decoration: InputDecoration(
              hintText: l10n.enterClientSecret,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSecret ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _obscureSecret = !_obscureSecret);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppTheme.spotifyDarkGray,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.clientSecretRequired;
              }
              if (value.trim().length < 10) {
                return l10n.clientSecretTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Help text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.whereToFindCredentials,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.whereToFindCredentialsDesc,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.spotifyLightGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (credentialsState.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      credentialsState.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3Confirm(CredentialsState credentialsState) {
    final l10n = AppLocalizations.of(context)!;
    final isConfigured = credentialsState.hasSpotifyCredentials;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.step3ReadyToConnect,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Status card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isConfigured
                ? AppTheme.spotifyGreen.withValues(alpha: 0.1)
                : AppTheme.spotifyDarkGray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isConfigured
                  ? AppTheme.spotifyGreen
                  : AppTheme.spotifyLightGray.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                isConfigured ? Icons.check_circle : Icons.pending,
                size: 64,
                color: isConfigured
                    ? AppTheme.spotifyGreen
                    : AppTheme.spotifyLightGray,
              ),
              const SizedBox(height: 16),
              Text(
                isConfigured
                    ? l10n.credentialsSaved
                    : l10n.waitingForCredentials,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isConfigured
                      ? AppTheme.spotifyGreen
                      : AppTheme.spotifyWhite,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isConfigured
                    ? l10n.credentialsSavedDesc
                    : l10n.waitingForCredentialsDesc,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.spotifyLightGray,
                ),
                textAlign: TextAlign.center,
              ),
              if (isConfigured && credentialsState.spotifyClientId != null) ...[
                const SizedBox(height: 12),
                Text(
                  '${l10n.clientId}: ${_maskString(credentialsState.spotifyClientId!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.spotifyLightGray,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Requirements reminder
        _buildInstructionCard(
          icon: Icons.workspace_premium,
          title: l10n.spotifyPremiumRequired,
          description: l10n.spotifyPremiumRequiredDesc,
        ),
      ],
    );
  }

  Widget _buildInstructionCard({
    required IconData icon,
    required String title,
    required String description,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.spotifyDarkGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.spotifyGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.spotifyLightGray,
                height: 1.5,
              ),
            ),
          ),
          if (child != null) ...[
            const SizedBox(height: 8),
            Padding(padding: const EdgeInsets.only(left: 32), child: child),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(CredentialsState credentialsState) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.spotifyDarkGray,
        border: Border(
          top: BorderSide(
            color: AppTheme.spotifyLightGray.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Back/Cancel button
          if (_currentStep > 0 || widget.isReconfiguring)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                  } else if (widget.isReconfiguring) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  _currentStep == 0 && widget.isReconfiguring
                      ? l10n.cancel
                      : l10n.back,
                ),
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 16),

          // Next/Save/Finish button
          Expanded(flex: 2, child: _buildPrimaryButton(credentialsState)),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(CredentialsState credentialsState) {
    final l10n = AppLocalizations.of(context)!;
    if (_currentStep == 0) {
      return ElevatedButton(
        onPressed: () => setState(() => _currentStep++),
        child: Text(l10n.nextEnterCredentials),
      );
    } else if (_currentStep == 1) {
      return ElevatedButton(
        onPressed: credentialsState.isLoading ? null : _saveCredentials,
        child: credentialsState.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                widget.isReconfiguring
                    ? l10n.updateCredentialsButton
                    : l10n.saveCredentials,
              ),
      );
    } else {
      return ElevatedButton(
        onPressed: credentialsState.hasSpotifyCredentials
            ? () {
                // Call the callback first
                widget.onSetupComplete();
                // Then navigate using our own context
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }
            : null,
        child: Text(l10n.connectToSpotify),
      );
    }
  }

  Future<void> _saveCredentials() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(credentialsProvider.notifier)
        .saveSpotifyCredentials(
          clientId: _clientIdController.text.trim(),
          clientSecret: _clientSecretController.text.trim(),
        );

    if (success && mounted) {
      setState(() => _currentStep = 2);
    }
  }

  String _maskString(String value) {
    if (value.length <= 8) return '****';
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.spotifyDarkGray,
        title: Text(l10n.aboutPrivacySecurity),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPrivacySection(
                l10n.privacySecureStorage,
                l10n.privacySecureStorageDesc,
              ),
              _buildPrivacySection(
                l10n.privacyDirectConnection,
                l10n.privacyDirectConnectionDesc,
              ),
              _buildPrivacySection(
                l10n.privacyNoDataCollection,
                l10n.privacyNoDataCollectionDesc,
              ),
              _buildPrivacySection(
                l10n.privacyYouControl,
                l10n.privacyYouControlDesc,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.spotifyGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.spotifyLightGray,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
