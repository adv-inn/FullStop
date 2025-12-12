import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/settings_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/app_theme.dart';

class PerformanceSection extends ConsumerWidget {
  const PerformanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return Column(
      children: [
        // GPU Acceleration toggle
        SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.spotifyGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.speed, color: AppTheme.spotifyGreen, size: 24),
          ),
          title: Text(l10n.gpuAcceleration),
          subtitle: Text(
            l10n.gpuAccelerationDesc,
            style: TextStyle(color: AppTheme.spotifyLightGray, fontSize: 12),
          ),
          value: settings.gpuAccelerationEnabled,
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .setGpuAccelerationEnabled(value);
          },
          activeColor: AppTheme.spotifyGreen,
        ),

        // Hint text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.gpuAccelerationHint,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.spotifyLightGray.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
