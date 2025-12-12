import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/create_session_provider.dart';
import '../../../domain/entities/music_style.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/app_theme.dart';
import '../horizontal_scroll_view.dart';

class StyleSelector extends ConsumerWidget {
  const StyleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final createState = ref.watch(createSessionProvider);

    return HorizontalScrollView(
      child: Row(
        children: MusicStyle.values.map((style) {
          final isSelected = createState.selectedStyle == style;
          final styleName = _getStyleName(style, l10n);
          final styleDesc = _getStyleDesc(style, l10n);
          final range = style.bpmRange;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                ref
                    .read(createSessionProvider.notifier)
                    .setSelectedStyle(isSelected ? null : style);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.spotifyGreen.withValues(alpha: 0.2)
                      : AppTheme.spotifyBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.spotifyGreen
                        : AppTheme.spotifyLightGray.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(style.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          styleName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.spotifyGreen
                                : AppTheme.spotifyWhite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      styleDesc,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.spotifyLightGray,
                      ),
                    ),
                    Text(
                      l10n.bpmRange(range.$1, range.$2),
                      style: TextStyle(
                        fontSize: 9,
                        color: AppTheme.spotifyLightGray.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getStyleName(MusicStyle style, AppLocalizations l10n) {
    switch (style) {
      case MusicStyle.slow:
        return l10n.styleSlow;
      case MusicStyle.midTempo:
        return l10n.styleMidTempo;
      case MusicStyle.upTempo:
        return l10n.styleUpTempo;
      case MusicStyle.fast:
        return l10n.styleFast;
    }
  }

  String _getStyleDesc(MusicStyle style, AppLocalizations l10n) {
    switch (style) {
      case MusicStyle.slow:
        return l10n.styleSlowDesc;
      case MusicStyle.midTempo:
        return l10n.styleMidTempoDesc;
      case MusicStyle.upTempo:
        return l10n.styleUpTempoDesc;
      case MusicStyle.fast:
        return l10n.styleFastDesc;
    }
  }
}
