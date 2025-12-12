import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/app_theme.dart';

class LanguageSection extends ConsumerWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Column(
      children: [
        RadioListTile<Locale?>(
          title: Text(l10n.systemDefault),
          value: null,
          groupValue: currentLocale,
          onChanged: (value) =>
              ref.read(localeProvider.notifier).setLocale(value),
          activeColor: AppTheme.spotifyGreen,
        ),
        RadioListTile<Locale?>(
          title: Text(l10n.english),
          value: const Locale('en'),
          groupValue: currentLocale,
          onChanged: (value) =>
              ref.read(localeProvider.notifier).setLocale(value),
          activeColor: AppTheme.spotifyGreen,
        ),
        RadioListTile<Locale?>(
          title: Text(l10n.chinese),
          value: const Locale('zh'),
          groupValue: currentLocale,
          onChanged: (value) =>
              ref.read(localeProvider.notifier).setLocale(value),
          activeColor: AppTheme.spotifyGreen,
        ),
        RadioListTile<Locale?>(
          title: Text(l10n.japanese),
          value: const Locale('ja'),
          groupValue: currentLocale,
          onChanged: (value) =>
              ref.read(localeProvider.notifier).setLocale(value),
          activeColor: AppTheme.spotifyGreen,
        ),
      ],
    );
  }
}
