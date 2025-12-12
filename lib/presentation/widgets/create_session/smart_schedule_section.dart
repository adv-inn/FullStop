import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/create_session_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/app_theme.dart';
import '../horizontal_scroll_view.dart';
import 'artist_track_match_section.dart';
import 'playlist_match_section.dart';
import 'style_selector.dart';

/// Toggle button for smart schedule (to be used in a Row with TraditionalScheduleToggle)
class SmartScheduleToggle extends ConsumerWidget {
  const SmartScheduleToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final createState = ref.watch(createSessionProvider);

    return GestureDetector(
      onTap: () {
        ref
            .read(createSessionProvider.notifier)
            .setSmartScheduleEnabled(!createState.smartScheduleEnabled);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: createState.smartScheduleEnabled
              ? AppTheme.spotifyGreen.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: createState.smartScheduleEnabled
                ? AppTheme.spotifyGreen
                : AppTheme.spotifyLightGray,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: createState.smartScheduleEnabled
                  ? AppTheme.spotifyGreen
                  : AppTheme.spotifyLightGray,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.smartSchedule,
              style: TextStyle(
                fontSize: 12,
                color: createState.smartScheduleEnabled
                    ? AppTheme.spotifyGreen
                    : AppTheme.spotifyWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Expanded content for smart schedule (mode selector and content)
class SmartScheduleContent extends ConsumerWidget {
  const SmartScheduleContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final createState = ref.watch(createSessionProvider);

    if (!createState.smartScheduleEnabled) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScheduleModeSelector(),
        const SizedBox(height: 12),

        // Content based on mode
        if (createState.scheduleMode == SmartScheduleMode.byStyle) ...[
          Text(
            l10n.selectStyle,
            style: TextStyle(fontSize: 12, color: AppTheme.spotifyLightGray),
          ),
          const SizedBox(height: 8),
          const StyleSelector(),
        ] else if (createState.scheduleMode ==
            SmartScheduleMode.byArtistTrack) ...[
          const ArtistTrackMatchSection(),
        ] else ...[
          const PlaylistMatchSection(),
        ],
      ],
    );
  }
}

/// Combined section (for backwards compatibility, now only shows toggle)
class SmartScheduleSection extends ConsumerWidget {
  const SmartScheduleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SmartScheduleToggle();
  }
}

class _ScheduleModeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final createState = ref.watch(createSessionProvider);

    return HorizontalScrollView(
      child: Row(
        children: [
          _ModeChip(
            label: l10n.matchByStyle,
            icon: Icons.music_note,
            isSelected: createState.scheduleMode == SmartScheduleMode.byStyle,
            onTap: () => ref
                .read(createSessionProvider.notifier)
                .setScheduleMode(SmartScheduleMode.byStyle),
          ),
          const SizedBox(width: 8),
          _ModeChip(
            label: l10n.matchByArtistTrack,
            icon: Icons.person_search,
            isSelected:
                createState.scheduleMode == SmartScheduleMode.byArtistTrack,
            onTap: () => ref
                .read(createSessionProvider.notifier)
                .setScheduleMode(SmartScheduleMode.byArtistTrack),
          ),
          const SizedBox(width: 8),
          _ModeChip(
            label: l10n.matchByPlaylist,
            icon: Icons.queue_music,
            isSelected:
                createState.scheduleMode == SmartScheduleMode.byPlaylist,
            onTap: () => ref
                .read(createSessionProvider.notifier)
                .setScheduleMode(SmartScheduleMode.byPlaylist),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.spotifyGreen.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.spotifyGreen
                : AppTheme.spotifyLightGray.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? AppTheme.spotifyGreen
                  : AppTheme.spotifyLightGray,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? AppTheme.spotifyGreen
                    : AppTheme.spotifyWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
