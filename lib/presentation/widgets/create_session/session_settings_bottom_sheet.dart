import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/create_session_provider.dart';
import '../../../domain/entities/focus_session.dart';
import '../../../domain/services/track_dispatcher.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/app_theme.dart';
import 'smart_schedule_section.dart';
import 'track_limit_dialog.dart';

/// Bottom sheet for session settings with schedule mode toggle
class SessionSettingsBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback onStartPressed;
  final bool isCreating;

  const SessionSettingsBottomSheet({
    super.key,
    required this.onStartPressed,
    this.isCreating = false,
  });

  @override
  SessionSettingsBottomSheetState createState() =>
      SessionSettingsBottomSheetState();
}

class SessionSettingsBottomSheetState
    extends ConsumerState<SessionSettingsBottomSheet> {
  bool _trueShuffle = true;
  RepeatMode _repeatMode = RepeatMode.context;
  bool _isExpanded = false;
  bool _userHasCollapsed = false; // Track if user manually collapsed

  bool get trueShuffle => _trueShuffle;
  RepeatMode get repeatMode => _repeatMode;
  bool get isExpanded => _isExpanded;
  bool get userHasCollapsed => _userHasCollapsed;

  /// Expand the bottom sheet (only if user hasn't manually collapsed)
  void expand() {
    if (!_isExpanded && !_userHasCollapsed) {
      setState(() => _isExpanded = true);
    }
  }

  /// Collapse the bottom sheet
  void collapse() {
    if (_isExpanded) {
      setState(() => _isExpanded = false);
    }
  }

  /// User manually toggles the panel
  void _onUserToggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      // Mark as user-collapsed when user manually collapses
      if (!_isExpanded) {
        _userHasCollapsed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final createState = ref.watch(createSessionProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.spotifyDarkGray,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar - tap to expand/collapse
            GestureDetector(
              onTap: _onUserToggle,
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.spotifyLightGray.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Expand/collapse indicator
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: AppTheme.spotifyLightGray.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Collapsible content with animation
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              sizeCurve: Curves.easeInOut,
              firstChild: _buildCollapsedContent(l10n, createState),
              secondChild: _buildExpandedContent(l10n, createState),
            ),

            // Start button (always visible)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: createState.canCreate && !widget.isCreating
                      ? widget.onStartPressed
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.spotifyGreen,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: AppTheme.spotifyLightGray
                        .withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: widget.isCreating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          l10n.play.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Collapsed view - shows minimal info in a single row
  Widget _buildCollapsedContent(
    AppLocalizations l10n,
    CreateSessionState createState,
  ) {
    // Determine current mode info
    String modeText;
    IconData modeIcon;

    if (createState.traditionalScheduleEnabled) {
      // Use localized dispatch mode name
      modeText = _getLocalizedDispatchMode(l10n, createState.dispatchMode);
      modeIcon = Icons.tune;
    } else if (createState.smartScheduleEnabled) {
      modeText = l10n.smartSchedule;
      modeIcon = Icons.auto_awesome;
    } else {
      modeText = l10n.traditionalSchedule;
      modeIcon = Icons.tune;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Mode indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.spotifyGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.spotifyGreen.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(modeIcon, size: 14, color: AppTheme.spotifyGreen),
                const SizedBox(width: 6),
                Text(
                  modeText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.spotifyGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Track limit indicator
          if (createState.trackLimitEnabled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.spotifyBlack,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${createState.trackLimitValue} ${l10n.tracks(createState.trackLimitValue).split(' ').last}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.spotifyLightGray,
                ),
              ),
            ),
          const Spacer(),
          // Tap hint
          Text(
            l10n.tapToExpand,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.spotifyLightGray.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Expanded view - shows full settings
  Widget _buildExpandedContent(
    AppLocalizations l10n,
    CreateSessionState createState,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Schedule mode toggle (slider)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _ScheduleModeSlider(),
        ),
        const SizedBox(height: 16),

        // Mode section
        if (createState.traditionalScheduleEnabled) ...[
          _buildSectionHeader(l10n.traditionalSchedule),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _DispatchModeSegments(),
          ),
        ] else if (createState.smartScheduleEnabled) ...[
          _buildSectionHeader(l10n.smartSchedule),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const SmartScheduleContent(),
          ),
        ],
        const SizedBox(height: 16),

        // Settings section
        _buildSectionHeader(l10n.settings),
        const SizedBox(height: 8),
        _buildSettingRow(
          l10n.trackLimit,
          _buildTrackLimitValue(createState, l10n),
          onTap: () => _showTrackLimitEditor(createState, l10n),
        ),
        _buildSettingToggleWithDescription(
          l10n.trueShuffle,
          _trueShuffle,
          (v) => setState(() => _trueShuffle = v),
          description: l10n.trueShuffleDesc,
        ),
        _buildSettingToggle(
          l10n.repeatAll,
          _repeatMode == RepeatMode.context,
          (v) => setState(
            () => _repeatMode = v ? RepeatMode.context : RepeatMode.off,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppTheme.spotifyLightGray.withValues(alpha: 0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.spotifyLightGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppTheme.spotifyLightGray.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    String label,
    Widget trailing, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.spotifyWhite,
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildTrackLimitValue(
    CreateSessionState createState,
    AppLocalizations l10n,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          createState.trackLimitEnabled
              ? '${createState.trackLimitValue}'
              : l10n.trackLimitDisabled,
          style: TextStyle(fontSize: 14, color: AppTheme.spotifyLightGray),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, size: 20, color: AppTheme.spotifyLightGray),
      ],
    );
  }

  Widget _buildSettingToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.spotifyWhite),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.spotifyGreen,
            activeTrackColor: AppTheme.spotifyGreen.withValues(alpha: 0.5),
            inactiveThumbColor: AppTheme.spotifyLightGray,
            inactiveTrackColor: AppTheme.spotifyLightGray.withValues(
              alpha: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingToggleWithDescription(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.spotifyWhite,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.spotifyLightGray.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.spotifyGreen,
            activeTrackColor: AppTheme.spotifyGreen.withValues(alpha: 0.5),
            inactiveThumbColor: AppTheme.spotifyLightGray,
            inactiveTrackColor: AppTheme.spotifyLightGray.withValues(
              alpha: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Get localized dispatch mode name
  String _getLocalizedDispatchMode(AppLocalizations l10n, DispatchMode mode) {
    switch (mode) {
      case DispatchMode.hitsOnly:
        return l10n.dispatchHitsOnly;
      case DispatchMode.balanced:
        return l10n.dispatchBalanced;
      case DispatchMode.deepDive:
        return l10n.dispatchDeepDive;
      case DispatchMode.unfiltered:
        return l10n.dispatchUnfiltered;
    }
  }

  Future<void> _showTrackLimitEditor(
    CreateSessionState createState,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController(
      text: createState.trackLimitValue.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => TrackLimitDialog(
        controller: controller,
        initialValue: createState.trackLimitValue,
        l10n: l10n,
      ),
    );

    if (result != null) {
      ref.read(createSessionProvider.notifier).setTrackLimitValue(result);
      ref.read(createSessionProvider.notifier).setTrackLimitEnabled(true);
    }
  }
}

/// Schedule mode slider toggle (Traditional / Smart)
class _ScheduleModeSlider extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final createState = ref.watch(createSessionProvider);

    // 0 = Traditional, 1 = Smart
    final isSmartMode = createState.smartScheduleEnabled;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.spotifyBlack,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SliderTab(
              icon: Icons.tune,
              label: l10n.traditionalSchedule,
              isSelected: createState.traditionalScheduleEnabled,
              onTap: () {
                ref
                    .read(createSessionProvider.notifier)
                    .setTraditionalScheduleEnabled(true);
              },
            ),
          ),
          Expanded(
            child: _SliderTab(
              icon: Icons.auto_awesome,
              label: l10n.smartSchedule,
              isSelected: isSmartMode,
              onTap: () {
                ref
                    .read(createSessionProvider.notifier)
                    .setSmartScheduleEnabled(true);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SliderTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.spotifyGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : AppTheme.spotifyLightGray,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : AppTheme.spotifyLightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dispatch mode segments for Traditional scheduling - 2x2 grid layout
class _DispatchModeSegments extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final createState = ref.watch(createSessionProvider);

    return Column(
      children: [
        // First row: Hits Only, Balanced
        Row(
          children: [
            Expanded(
              child: _DispatchSegment(
                mode: DispatchMode.hitsOnly,
                icon: Icons.star,
                label: l10n.dispatchHitsOnly,
                description: l10n.dispatchHitsOnlyDesc,
                isSelected: createState.dispatchMode == DispatchMode.hitsOnly,
                onTap: () => ref
                    .read(createSessionProvider.notifier)
                    .setDispatchMode(DispatchMode.hitsOnly),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DispatchSegment(
                mode: DispatchMode.balanced,
                icon: Icons.tune,
                label: l10n.dispatchBalanced,
                description: l10n.dispatchBalancedDesc,
                isSelected: createState.dispatchMode == DispatchMode.balanced,
                onTap: () => ref
                    .read(createSessionProvider.notifier)
                    .setDispatchMode(DispatchMode.balanced),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Second row: Deep Dive, Unfiltered
        Row(
          children: [
            Expanded(
              child: _DispatchSegment(
                mode: DispatchMode.deepDive,
                icon: Icons.explore,
                label: l10n.dispatchDeepDive,
                description: l10n.dispatchDeepDiveDesc,
                isSelected: createState.dispatchMode == DispatchMode.deepDive,
                onTap: () => ref
                    .read(createSessionProvider.notifier)
                    .setDispatchMode(DispatchMode.deepDive),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DispatchSegment(
                mode: DispatchMode.unfiltered,
                icon: Icons.all_inclusive,
                label: l10n.dispatchUnfiltered,
                description: l10n.dispatchUnfilteredDesc,
                isSelected: createState.dispatchMode == DispatchMode.unfiltered,
                onTap: () => ref
                    .read(createSessionProvider.notifier)
                    .setDispatchMode(DispatchMode.unfiltered),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DispatchSegment extends StatelessWidget {
  final DispatchMode mode;
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _DispatchSegment({
    required this.mode,
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.spotifyGreen.withValues(alpha: 0.2)
              : AppTheme.spotifyBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.spotifyGreen
                : AppTheme.spotifyLightGray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppTheme.spotifyGreen
                  : AppTheme.spotifyLightGray,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.spotifyGreen
                          : AppTheme.spotifyWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? AppTheme.spotifyGreen.withValues(alpha: 0.8)
                          : AppTheme.spotifyLightGray.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
