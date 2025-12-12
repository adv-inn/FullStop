import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/create_session_provider.dart';
import '../../../domain/services/track_dispatcher.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/app_theme.dart';

/// Toggle button for traditional schedule (to be used in a Row with SmartScheduleToggle)
class TraditionalScheduleToggle extends ConsumerWidget {
  const TraditionalScheduleToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final createState = ref.watch(createSessionProvider);

    return GestureDetector(
      onTap: () {
        ref
            .read(createSessionProvider.notifier)
            .setTraditionalScheduleEnabled(
              !createState.traditionalScheduleEnabled,
            );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: createState.traditionalScheduleEnabled
              ? AppTheme.spotifyGreen.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: createState.traditionalScheduleEnabled
                ? AppTheme.spotifyGreen
                : AppTheme.spotifyLightGray,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 16,
              color: createState.traditionalScheduleEnabled
                  ? AppTheme.spotifyGreen
                  : AppTheme.spotifyLightGray,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.traditionalSchedule,
              style: TextStyle(
                fontSize: 12,
                color: createState.traditionalScheduleEnabled
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

/// Expanded content for traditional schedule (dispatch mode selector)
class TraditionalScheduleContent extends ConsumerWidget {
  const TraditionalScheduleContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createState = ref.watch(createSessionProvider);

    if (!createState.traditionalScheduleEnabled) {
      return const SizedBox.shrink();
    }

    return _DispatchModeSelector();
  }
}

/// Combined section (for backwards compatibility)
class TraditionalScheduleSection extends ConsumerWidget {
  const TraditionalScheduleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const TraditionalScheduleToggle();
  }
}

class _DispatchModeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createState = ref.watch(createSessionProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.spotifyLightGray.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: DispatchMode.values.map((mode) {
          final isSelected = createState.dispatchMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(createSessionProvider.notifier).setDispatchMode(mode);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.spotifyGreen.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  // Add border for selected state to provide visual feedback
                  // without changing text weight
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.spotifyGreen
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getDispatchModeIcon(mode),
                      size: 18,
                      color: isSelected
                          ? AppTheme.spotifyGreen
                          : AppTheme.spotifyLightGray,
                    ),
                    const SizedBox(height: 2),
                    // Use Stack with invisible bold text to reserve space
                    // This prevents layout shift when switching between modes
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Invisible bold text to reserve max width
                        Text(
                          mode.displayName,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.transparent,
                          ),
                        ),
                        // Visible text
                        Text(
                          mode.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppTheme.spotifyGreen
                                : AppTheme.spotifyWhite,
                          ),
                        ),
                      ],
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

  IconData _getDispatchModeIcon(DispatchMode mode) {
    switch (mode) {
      case DispatchMode.hitsOnly:
        return Icons.star;
      case DispatchMode.balanced:
        return Icons.tune;
      case DispatchMode.deepDive:
        return Icons.explore;
      case DispatchMode.unfiltered:
        return Icons.all_inclusive;
    }
  }
}
