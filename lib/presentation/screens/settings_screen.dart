import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../themes/app_theme.dart';
import '../widgets/draggable_app_bar.dart';
import '../widgets/settings/settings_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: DraggableAppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Language section
          _buildSectionHeader(l10n.language),
          const LanguageSection(),
          const Divider(),

          // Account section
          _buildSectionHeader('Account'),
          const AccountSection(),
          const Divider(),

          // API Credentials section
          _buildSectionHeader('API Credentials'),
          const ApiCredentialsSection(),
          const Divider(),

          // Proxy Configuration section
          _buildSectionHeader(l10n.proxy),
          const ProxySettingsSection(),
          const Divider(),

          // Advanced Features section
          _buildSectionHeader(l10n.advancedFeatures),
          const AudioFeaturesSection(),
          const Divider(),

          // LLM Configuration section
          _buildSectionHeader('AI Integration (Optional)'),
          const LlmConfigSection(),
          const Divider(),

          // Performance section
          _buildSectionHeader(l10n.performance),
          const PerformanceSection(),
          const Divider(),

          // Cache Management section
          _buildSectionHeader(l10n.cacheManagement),
          const CacheSection(),
          const Divider(),

          // About section
          _buildSectionHeader('About'),
          const AboutSection(),
          const Divider(),

          // Credits
          _buildSectionHeader('Credits'),
          const CreditsSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.spotifyLightGray,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
