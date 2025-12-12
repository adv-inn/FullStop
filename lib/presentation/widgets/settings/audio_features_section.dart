import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../application/providers/settings_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/app_theme.dart';

class AudioFeaturesSection extends ConsumerStatefulWidget {
  const AudioFeaturesSection({super.key});

  @override
  ConsumerState<AudioFeaturesSection> createState() =>
      _AudioFeaturesSectionState();
}

class _AudioFeaturesSectionState extends ConsumerState<AudioFeaturesSection> {
  final _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initFromState();
  }

  void _initFromState() {
    final settingsState = ref.read(settingsProvider);
    if (settingsState.getSongBpmApiKey != null) {
      _apiKeyController.text = settingsState.getSongBpmApiKey!;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = ref.watch(settingsProvider);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.purple, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.getSongBpmAttribution,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.getSongBpmHint,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.purple.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _launchUrl('https://getsongbpm.com/api'),
                child: Text(
                  'https://getsongbpm.com/api',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.purple,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _apiKeyController,
            decoration: InputDecoration(
              labelText: l10n.getSongBpmApiKey,
              hintText: l10n.getSongBpmApiKeyHint,
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (settingsState.hasGetSongBpmApiKey)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _clearApiKey(l10n),
                      tooltip: l10n.clearAll,
                    ),
                  IconButton(
                    icon: const Icon(Icons.save, size: 18),
                    onPressed: () => _saveApiKey(l10n),
                    tooltip: l10n.save,
                  ),
                ],
              ),
            ),
            obscureText: true,
          ),
        ),
        if (settingsState.hasGetSongBpmApiKey)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.spotifyGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.getSongBpmApiKeyConfigured,
                  style: TextStyle(fontSize: 12, color: AppTheme.spotifyGreen),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _clearApiKey(AppLocalizations l10n) {
    _apiKeyController.clear();
    ref.read(settingsProvider.notifier).clearGetSongBpmApiKey();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.getSongBpmApiKeyCleared)));
  }

  Future<void> _saveApiKey(AppLocalizations l10n) async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.getSongBpmApiKeyEmpty)));
      return;
    }

    final success = await ref
        .read(settingsProvider.notifier)
        .setGetSongBpmApiKey(apiKey);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? l10n.getSongBpmApiKeySaved : l10n.getSongBpmApiKeyError,
          ),
          backgroundColor: success ? AppTheme.spotifyGreen : Colors.red,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
