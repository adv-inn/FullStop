import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../application/providers/background_session_provider.dart';
import '../../application/providers/create_session_provider.dart';
import '../../application/providers/search_provider.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/music_style.dart';
import '../../domain/services/track_dispatcher.dart';
import '../../l10n/app_localizations.dart';
import '../themes/app_theme.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/artist_card.dart';
import '../widgets/create_session/create_session_widgets.dart';
import '../widgets/draggable_app_bar.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  ConsumerState<CreateSessionScreen> createState() =>
      _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _chipsScrollController = ScrollController();
  final _bottomSheetKey = GlobalKey<SessionSettingsBottomSheetState>();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _chipsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searchState = ref.watch(searchProvider);
    final createState = ref.watch(createSessionProvider);

    return Scaffold(
      appBar: DraggableAppBar(title: Text(l10n.createSession)),
      body: Column(
        children: [
          // Search bar with selected artist chips
          _buildSearchSection(l10n, createState),

          // Search results list
          Expanded(
            child: _buildSearchResults(context, searchState, createState, l10n),
          ),

          // Bottom sheet (only show when artists are selected)
          if (createState.selectedArtists.isNotEmpty)
            Flexible(
              child: SessionSettingsBottomSheet(
                key: _bottomSheetKey,
                onStartPressed: _createSession,
                isCreating: createState.isCreating,
              ),
            ),
        ],
      ),
    );
  }

  // Track scroll position for edge shadows
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  void _updateScrollIndicators() {
    if (!_chipsScrollController.hasClients) return;
    final position = _chipsScrollController.position;
    final newCanScrollLeft = position.pixels > 0;
    final newCanScrollRight = position.pixels < position.maxScrollExtent;
    if (newCanScrollLeft != _canScrollLeft ||
        newCanScrollRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = newCanScrollLeft;
        _canScrollRight = newCanScrollRight;
      });
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && _chipsScrollController.hasClients) {
      // Convert vertical scroll to horizontal
      final delta = event.scrollDelta.dy;
      final newOffset = (_chipsScrollController.offset + delta).clamp(
        0.0,
        _chipsScrollController.position.maxScrollExtent,
      );
      _chipsScrollController.jumpTo(newOffset);
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // Backspace when input is empty: delete last chip
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _searchController.text.isEmpty &&
        ref.read(createSessionProvider).selectedArtists.isNotEmpty) {
      final artists = ref.read(createSessionProvider).selectedArtists;
      ref.read(createSessionProvider.notifier).removeArtist(artists.last.id);
      // Restore focus after chip deletion
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  /// Scroll to end to show the input area
  void _scrollToEnd() {
    if (_chipsScrollController.hasClients) {
      _chipsScrollController.animateTo(
        _chipsScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      _updateScrollIndicators();
    }
  }

  Widget _buildSearchSection(
    AppLocalizations l10n,
    CreateSessionState createState,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.spotifyBlack,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.spotifyLightGray.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Listener(
        onPointerSignal: _handlePointerSignal,
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: _handleKeyEvent,
          child: GestureDetector(
            onTap: () => _searchFocusNode.requestFocus(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.spotifyDarkGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Search icon
                  const Icon(
                    Icons.search,
                    color: AppTheme.spotifyLightGray,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  // Scrollable content area with edge shadows
                  Expanded(
                    child: SizedBox(
                      height: 24,
                      child: Stack(
                        children: [
                          // Scrollable list
                          NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              _updateScrollIndicators();
                              return false;
                            },
                            child: GestureDetector(
                              onTap: () => _searchFocusNode.requestFocus(),
                              behavior: HitTestBehavior.translucent,
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(
                                  context,
                                ).copyWith(scrollbars: false),
                                child: ListView(
                                  controller: _chipsScrollController,
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    // Selected artist chips
                                    ...createState.selectedArtists.map(
                                      (artist) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: _buildInlineChip(artist),
                                      ),
                                    ),
                                    // Text input area
                                    Center(
                                      child: IntrinsicWidth(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minWidth: 120,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.centerLeft,
                                            children: [
                                              // Hint text (visible when empty)
                                              if (_searchController
                                                  .text
                                                  .isEmpty)
                                                Text(
                                                  createState
                                                          .selectedArtists
                                                          .isEmpty
                                                      ? l10n.searchArtists
                                                      : l10n.addMoreArtists,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppTheme
                                                        .spotifyLightGray
                                                        .withValues(alpha: 0.5),
                                                  ),
                                                ),
                                              // Always present EditableText
                                              EditableText(
                                                controller: _searchController,
                                                focusNode: _searchFocusNode,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                                cursorColor:
                                                    AppTheme.spotifyGreen,
                                                backgroundCursorColor:
                                                    Colors.transparent,
                                                onChanged: (query) {
                                                  setState(() {});
                                                  // Scroll to end when user is typing to keep input visible
                                                  _scrollToEnd();
                                                  if (query.length >= 2) {
                                                    ref
                                                        .read(
                                                          searchProvider
                                                              .notifier,
                                                        )
                                                        .searchArtists(query);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Left edge shadow
                          if (_canScrollLeft)
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: IgnorePointer(
                                child: Container(
                                  width: 20,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        AppTheme.spotifyDarkGray,
                                        AppTheme.spotifyDarkGray.withValues(
                                          alpha: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Right edge shadow
                          if (_canScrollRight)
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: IgnorePointer(
                                child: Container(
                                  width: 20,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                      colors: [
                                        AppTheme.spotifyDarkGray,
                                        AppTheme.spotifyDarkGray.withValues(
                                          alpha: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Counter
                  if (createState.selectedArtists.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${createState.selectedArtists.length}/$kMaxArtistsPerSession',
                      style: TextStyle(
                        fontSize: 12,
                        color: createState.canAddMoreArtists
                            ? AppTheme.spotifyLightGray
                            : AppTheme.spotifyGreen,
                        fontWeight: createState.canAddMoreArtists
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                  ],
                  // Clear button
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        ref.read(searchProvider.notifier).clear();
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.clear,
                          size: 18,
                          color: AppTheme.spotifyLightGray.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineChip(Artist artist) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.spotifyGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            artist.name,
            style: const TextStyle(fontSize: 13, color: AppTheme.spotifyGreen),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => ref
                .read(createSessionProvider.notifier)
                .removeArtist(artist.id),
            child: Icon(
              Icons.close,
              size: 14,
              color: AppTheme.spotifyGreen.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    SearchState searchState,
    CreateSessionState createState,
    AppLocalizations l10n,
  ) {
    if (searchState.status == SearchStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.status == SearchStatus.error) {
      return Center(
        child: Text(
          searchState.errorMessage ?? 'Search failed',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (searchState.artists.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? l10n.searchForArtists
              : l10n.noArtistsFound,
          style: TextStyle(color: AppTheme.spotifyLightGray),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: searchState.artists.length,
      itemBuilder: (context, index) {
        final artist = searchState.artists[index];
        final isSelected = createState.selectedArtists.any(
          (a) => a.id == artist.id,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ArtistCard(
            artist: artist,
            isSelected: isSelected,
            onTap: () => _toggleArtist(artist, isSelected, l10n),
            onAddPressed: () => _toggleArtist(artist, isSelected, l10n),
          ),
        );
      },
    );
  }

  void _toggleArtist(Artist artist, bool isSelected, AppLocalizations l10n) {
    if (isSelected) {
      ref.read(createSessionProvider.notifier).removeArtist(artist.id);
    } else {
      final success = ref
          .read(createSessionProvider.notifier)
          .addArtist(artist);
      if (success) {
        // Clear search text but keep search results visible
        _searchController.clear();
        setState(() {});

        // After UI settles, scroll to end and expand bottom sheet
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToEnd();
          _bottomSheetKey.currentState?.expand();
        });
      } else {
        // Show toast when limit is reached
        showAppSnackBar(
          context,
          message: l10n.artistLimitReached,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _createSession() async {
    final createState = ref.read(createSessionProvider);
    if (createState.isCreating) return;

    // Get settings from bottom sheet
    final bottomSheetState = _bottomSheetKey.currentState;
    final trueShuffle = bottomSheetState?.trueShuffle ?? true;
    final repeatMode = bottomSheetState?.repeatMode ?? RepeatMode.context;

    final settings = FocusSessionSettings(
      playback: PlaybackSettings(
        shuffle: trueShuffle, // True Shuffle 后处理会在 Pipeline 中应用
        repeatMode: repeatMode,
      ),
    );

    // Generate session name from artists
    final sessionName = createState.generateDefaultName();

    // Determine scheduling parameters based on mode
    List<int>? selectedTrackBpms;
    MusicStyle? filterByStyle;
    int? filterByBpm;
    DispatchMode? dispatchMode;

    if (createState.smartScheduleEnabled) {
      // Smart Scheduling: BPM-based filtering
      switch (createState.scheduleMode) {
        case SmartScheduleMode.byStyle:
          filterByStyle = createState.selectedStyle;
          break;
        case SmartScheduleMode.byPlaylist:
          filterByBpm = createState.matchTrackBpm;
          break;
        case SmartScheduleMode.byArtistTrack:
          selectedTrackBpms = createState.selectedArtistTracks
              .where((t) => t.bpm != null)
              .map((t) => t.bpm!)
              .toList();
          break;
      }
    } else if (createState.traditionalScheduleEnabled) {
      // Traditional Scheduling: Rule-based dispatch
      dispatchMode = createState.dispatchMode;
    }

    final taskId = const Uuid().v4();
    final trackLimit = createState.trackLimitEnabled
        ? createState.trackLimitValue
        : null;

    ref
        .read(backgroundSessionProvider.notifier)
        .createSessionInBackground(
          BackgroundSessionParams(
            taskId: taskId,
            name: sessionName,
            artists: createState.selectedArtists,
            settings: settings,
            selectedTrackBpms: selectedTrackBpms,
            filterByStyle: filterByStyle,
            filterByBpm: filterByBpm,
            dispatchMode: dispatchMode,
            trackLimit: trackLimit,
            trueShuffle: trueShuffle,
          ),
        );

    ref.read(createSessionProvider.notifier).reset();

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
