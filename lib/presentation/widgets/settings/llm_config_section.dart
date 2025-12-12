import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullstop/l10n/app_localizations.dart';
import '../../../agent/config/llm_config.dart';
import '../../../agent/providers/llm_provider.dart';
import '../../../application/di/core_providers.dart';
import '../../../application/providers/credentials_provider.dart';
import '../../themes/app_theme.dart';

class LlmConfigSection extends ConsumerStatefulWidget {
  const LlmConfigSection({super.key});

  @override
  ConsumerState<LlmConfigSection> createState() => _LlmConfigSectionState();
}

class _LlmConfigSectionState extends ConsumerState<LlmConfigSection> {
  bool _enabled = false;
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initFromState();
  }

  void _initFromState() {
    final credentialsState = ref.read(credentialsProvider);
    _enabled = credentialsState.hasLlmConfig;
    _apiKeyController.text = credentialsState.llmApiKey ?? '';
    _baseUrlController.text =
        credentialsState.llmBaseUrl ?? 'https://api.openai.com/v1';
    _modelController.text = credentialsState.llmModel ?? 'gpt-4o-mini';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final credentialsState = ref.watch(credentialsProvider);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.cyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.smart_toy, color: Colors.cyan, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.llmOpenAiCompatible,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.llmOpenAiCompatibleDesc,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.cyan.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: Text(l10n.enableAiFeatures),
          subtitle: Text(l10n.smartPlaylistCuration),
          value: _enabled,
          onChanged: (value) {
            setState(() => _enabled = value);
            if (!value) {
              ref.read(credentialsProvider.notifier).clearLlmCredentials();
            }
          },
        ),
        if (_enabled) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _baseUrlController,
              decoration: InputDecoration(
                labelText: l10n.llmBaseUrl,
                hintText: l10n.llmBaseUrlHint,
                border: const OutlineInputBorder(),
                isDense: true,
                helperText: l10n.llmBaseUrlHelper,
              ),
            ),
          ),
          _buildExamplesBox(l10n),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: l10n.llmModel,
                hintText: l10n.llmModelHint,
                border: const OutlineInputBorder(),
                isDense: true,
                helperText: l10n.llmModelHelper,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: l10n.llmApiKey,
                hintText: l10n.llmApiKeyHint,
                border: const OutlineInputBorder(),
                isDense: true,
                helperText: l10n.llmApiKeyHelper,
              ),
              obscureText: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _testConnection,
                    icon: const Icon(Icons.network_check),
                    label: Text(l10n.test),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveCredentials,
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
          if (credentialsState.hasLlmConfig)
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
                    l10n.llmConfigured(credentialsState.llmModel ?? ''),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.spotifyGreen,
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

  Widget _buildExamplesBox(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.blue.shade300),
                const SizedBox(width: 8),
                Text(
                  l10n.llmExamples,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade200,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '• OpenAI: https://api.openai.com/v1\n'
              '• Gemini: https://generativelanguage.googleapis.com/v1beta/openai\n'
              '• Ollama: http://localhost:11434/v1',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue.shade200,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCredentials() async {
    final l10n = AppLocalizations.of(context)!;
    final baseUrl = _baseUrlController.text.trim();
    final model = _modelController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (baseUrl.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.llmBaseUrlModelRequired)));
      return;
    }

    final success = await ref
        .read(credentialsProvider.notifier)
        .saveLlmCredentials(baseUrl: baseUrl, model: model, apiKey: apiKey);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? l10n.llmConfigSaved : l10n.llmConfigSaveFailed,
          ),
          backgroundColor: success ? AppTheme.spotifyGreen : Colors.red,
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context)!;
    final baseUrl = _baseUrlController.text.trim();
    final model = _modelController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (baseUrl.isEmpty || model.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.llmBaseUrlModelRequired)));
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.llmTesting(baseUrl))));

    try {
      final config = LlmConfig(baseUrl: baseUrl, model: model, apiKey: apiKey);

      final dio = ref.read(llmDioProvider);
      final provider = OpenAiCompatibleProvider(config: config, dio: dio);
      final response = await provider.complete('Say "hello" in one word.');

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.llmTestSuccess(
                response.substring(0, response.length.clamp(0, 50)),
              ),
            ),
            backgroundColor: AppTheme.spotifyGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showErrorDialog(baseUrl, model, e.toString());
      }
    }
  }

  void _showErrorDialog(String endpoint, String model, String error) {
    final l10n = AppLocalizations.of(context)!;
    final friendlyError = _formatError(error, l10n);
    final shortError = _extractShortError(error);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.spotifyDarkGray,
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(l10n.connectionFailed),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                friendlyError,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.request,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  'POST $endpoint/chat/completions\n'
                  'Model: $model\n\n'
                  '$shortError',
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
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

  String _formatError(String error, AppLocalizations l10n) {
    if (error.contains('404')) {
      return l10n.llmError404;
    }
    if (error.contains('401') || error.contains('Unauthorized')) {
      return l10n.llmError401;
    }
    if (error.contains('403')) {
      return l10n.llmError403;
    }
    if (error.contains('429')) {
      return l10n.llmError429;
    }
    if (error.contains('500') ||
        error.contains('502') ||
        error.contains('503')) {
      return l10n.llmErrorServer;
    }
    if (error.contains('timeout') || error.contains('Timeout')) {
      return l10n.llmErrorTimeout;
    }
    if (error.contains('Connection') || error.contains('SocketException')) {
      return l10n.llmErrorConnection;
    }
    final shortened = error
        .replaceAll('AppException:', '')
        .replaceAll('LlmException:', '')
        .trim();
    if (shortened.length > 80) {
      return '${shortened.substring(0, 80)}...';
    }
    return shortened;
  }

  String _extractShortError(String fullError) {
    final statusMatch = RegExp(r'status code of (\d+)').firstMatch(fullError);
    if (statusMatch != null) {
      return 'HTTP ${statusMatch.group(1)}';
    }
    String short = fullError
        .replaceAll('AppException: ', '')
        .replaceAll('LlmException: ', '')
        .replaceAll(RegExp(r'This exception was thrown because.*?\.'), '')
        .replaceAll(
          RegExp(r'The status code of \d+ has the following meaning:.*?\.'),
          '',
        )
        .replaceAll(RegExp(r'Read more about.*?Status'), '')
        .replaceAll(RegExp(r'In order to resolve.*?code\.'), '')
        .replaceAll(RegExp(r'\(code: null\)'), '')
        .replaceAll('\n\n', '\n')
        .trim();
    if (short.length > 150) {
      short = '${short.substring(0, 150)}...';
    }
    return short.isEmpty ? 'Unknown error' : short;
  }
}
