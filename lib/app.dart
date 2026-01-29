import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/app_localizations.dart';
import 'application/providers/auth_provider.dart';
import 'application/providers/credentials_provider.dart';
import 'application/providers/locale_provider.dart';
import 'application/providers/navigation_provider.dart';
import 'application/providers/playback_provider.dart';
import 'core/services/system_tray_service.dart';
import 'domain/entities/playback_state.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/setup_guide_screen.dart';
import 'presentation/themes/app_theme.dart';
import 'presentation/widgets/cached_network_image.dart';
import 'presentation/widgets/custom_title_bar.dart';

class SpotifyFocusSomeoneApp extends ConsumerWidget {
  const SpotifyFocusSomeoneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'FullStop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Localization
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('zh'), Locale('ja')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _AppShell(),
    );
  }
}

/// App shell that wraps content with custom title bar on Windows
/// Also handles system tray and window close behavior
class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> with WindowListener {
  final _systemTray = SystemTrayService();
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _initSystemTray();
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      windowManager.addListener(this);
      // Prevent default close behavior
      windowManager.setPreventClose(true);
    }
    // Set navigator key for unified title bar navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationProvider.notifier).setNavigatorKey(_navigatorKey);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update tray localization when locale changes
    _updateTrayLocalization();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _systemTray.dispose();
    super.dispose();
  }

  void _updateTrayLocalization() {
    if (!_systemTray.isSupported) return;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    _systemTray.updateLocalizedStrings(
      TrayLocalizedStrings(
        showWindow: l10n.trayShowWindow,
        exit: l10n.trayExit,
        play: l10n.play,
        pause: l10n.pause,
        previousTrack: l10n.trayPreviousTrack,
        nextTrack: l10n.trayNextTrack,
        tooltip: l10n.trayTooltip,
      ),
    );
  }

  Future<void> _initSystemTray() async {
    if (!_systemTray.isSupported) return;

    await _systemTray.initialize(
      onShowWindow: () {
        // Window will be shown by the service
      },
      onExitApp: _exitApp,
      onPlayPause: () {
        ref.read(playbackProvider.notifier).togglePlayPause();
      },
      onNextTrack: () {
        ref.read(playbackProvider.notifier).skipNext();
      },
      onPreviousTrack: () {
        ref.read(playbackProvider.notifier).skipPrevious();
      },
    );

    // Listen to playback state changes to update tray
    ref.listenManual(playbackProvider, (previous, next) {
      _systemTray.updatePlaybackState(
        isPlaying: next.isPlaying,
        trackName: next.currentTrack?.name,
        artistName: next.currentTrack?.artistNames,
      );
    });
  }

  void _exitApp() async {
    _isExiting = true;
    await _systemTray.dispose();
    await windowManager.setPreventClose(false);
    await windowManager.close();
  }

  @override
  void onWindowClose() async {
    if (_isExiting) return;

    // Minimize to tray instead of closing
    if (_systemTray.isSupported) {
      await _systemTray.hideToTray();
    } else {
      // If tray not supported, actually close
      _exitApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      final navState = ref.watch(navigationProvider);
      final isTransparent = navState.transparentMode;
      final isMiniMode = navState.miniPlayerMode;

      // Always use Stack layout to preserve CustomTitleBar and Navigator state
      // This prevents Navigator rebuild when toggling mini mode
      return Stack(
        children: [
          // Main content area - hidden but kept alive in mini mode
          Offstage(
            offstage: isMiniMode,
            child: Padding(
              padding: EdgeInsets.only(top: isTransparent ? 0 : 32),
              child: Navigator(
                key: _navigatorKey,
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (context) => const _AppRouter(),
                    settings: settings,
                  );
                },
              ),
            ),
          ),
          // Mini player content - shown only in mini mode
          // Wrapped in Material to provide default text styles (prevents yellow underline)
          if (isMiniMode)
            Positioned(
              top: 32, // Below title bar
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                color: AppTheme.spotifyBlack,
                child: const _MiniPlayerContent(),
              ),
            ),
          // Title bar always on top
          const Positioned(top: 0, left: 0, right: 0, child: CustomTitleBar()),
        ],
      );
    }
    return const _AppRouter();
  }
}

/// Mini player content with compact layout optimized for small window
class _MiniPlayerContent extends ConsumerStatefulWidget {
  const _MiniPlayerContent();

  @override
  ConsumerState<_MiniPlayerContent> createState() => _MiniPlayerContentState();
}

class _MiniPlayerContentState extends ConsumerState<_MiniPlayerContent> {
  bool _isLiked = false;
  bool _isLikeLoading = false;
  String? _lastTrackId;

  // Responsive breakpoints for width (in pixels)
  // These determine which controls are visible at different widths
  static const double _breakpointShowNext = 280;
  static const double _breakpointShowPrev = 320;
  static const double _breakpointShowLike = 360;

  // Responsive breakpoints for height (in pixels)
  // When height exceeds these, show additional controls
  static const double _breakpointShowProgressBar = 60;
  static const double _breakpointShowControlBar = 95;

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackProvider);
    final hasContent = playbackState.currentTrack != null;
    final l10n = AppLocalizations.of(context)!;

    if (!hasContent) {
      // Placeholder when nothing is playing
      // Use LayoutBuilder to adapt to available space and prevent overflow
      return Container(
        color: AppTheme.spotifyBlack,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // If height is very limited, show only icon
            final showText = constraints.maxHeight >= 50;

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.music_note,
                    size: 24,
                    color: AppTheme.spotifyLightGray.withValues(alpha: 0.5),
                  ),
                  if (showText) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.nothingPlaying,
                      style: TextStyle(
                        color: AppTheme.spotifyLightGray.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    }

    // Check if track changed and fetch like status (defer to avoid calling during build)
    if (playbackState.currentTrack!.id != _lastTrackId) {
      _lastTrackId = playbackState.currentTrack!.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchLikeStatus();
      });
    }

    // Responsive mini player layout - controls appear/disappear based on size
    // Progress bar at the very bottom spanning full width
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Determine which controls to show based on available width
        final showNext = width >= _breakpointShowNext;
        final showPrev = width >= _breakpointShowPrev;
        final showLike = width >= _breakpointShowLike;

        // Determine which elements to show based on height
        final showProgressBar = height >= _breakpointShowProgressBar;
        final showControlBar = height >= _breakpointShowControlBar;

        return Column(
          children: [
            // Main content row with bottom padding for spacing
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Row(
                  children: [
                    // Album art - always visible
                    _buildAlbumArt(playbackState),
                    const SizedBox(width: 12),
                    // Track info - takes remaining space, clipped to prevent overflow
                    Expanded(
                      child: ClipRect(
                        child: _buildTrackInfoCompact(playbackState),
                      ),
                    ),
                    // Responsive controls - each button is independent
                    if (showLike) _buildLikeButton(),
                    if (showPrev) _buildPrevButton(),
                    _buildPlayPauseButton(playbackState.isPlaying),
                    if (showNext) _buildNextButton(),
                  ],
                ),
              ),
            ),
            // Control bar - only shown when height permits
            if (showControlBar)
              _buildControlBar(playbackState, l10n),
            // Progress bar - only shown when height permits
            if (showProgressBar)
              LinearProgressIndicator(
                value: playbackState.progressPercent,
                backgroundColor: AppTheme.spotifyLightGray.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.spotifyGreen),
                minHeight: 3,
              ),
          ],
        );
      },
    );
  }

  // Album art widget - matches NowPlayingBar style
  Widget _buildAlbumArt(PlaybackState playbackState) {
    return CachedNetworkImage(
      imageUrl: playbackState.currentTrack!.imageUrl,
      width: 48,
      height: 48,
      borderRadius: BorderRadius.circular(4),
      placeholderIconSize: 20,
    );
  }

  // Compact track info widget - uses Flexible to prevent overflow
  Widget _buildTrackInfoCompact(PlaybackState playbackState) {
    // Wrap in MediaQuery to prevent text scaling issues in small windows
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // If height is very limited, show only song name
          final showArtist = constraints.maxHeight >= 32;

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  playbackState.currentTrack!.name,
                  style: const TextStyle(
                    color: AppTheme.spotifyWhite,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showArtist) ...[
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    playbackState.currentTrack!.artistNames,
                    style: const TextStyle(
                      color: AppTheme.spotifyLightGray,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // Like button - matches NowPlayingBar style
  Widget _buildLikeButton() {
    if (_isLikeLoading) {
      return const SizedBox(
        width: 36,
        height: 36,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.spotifyGreen),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleLike,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? AppTheme.spotifyGreen : AppTheme.spotifyLightGray,
            size: 22,
          ),
        ),
      ),
    );
  }

  // Previous track button - independent control
  Widget _buildPrevButton() {
    return GestureDetector(
      onTap: () {
        if (mounted) ref.read(playbackProvider.notifier).skipPrevious();
      },
      child: const SizedBox(
        width: 32,
        height: 32,
        child: Icon(Icons.skip_previous_rounded, color: AppTheme.spotifyWhite, size: 26),
      ),
    );
  }

  // Play/Pause button - always visible, main action
  Widget _buildPlayPauseButton(bool isPlaying) {
    return GestureDetector(
      onTap: () {
        if (mounted) ref.read(playbackProvider.notifier).togglePlayPause();
      },
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
          color: AppTheme.spotifyWhite,
          size: 40,
        ),
      ),
    );
  }

  // Next track button - independent control
  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () {
        if (mounted) ref.read(playbackProvider.notifier).skipNext();
      },
      child: const SizedBox(
        width: 32,
        height: 32,
        child: Icon(Icons.skip_next_rounded, color: AppTheme.spotifyWhite, size: 26),
      ),
    );
  }

  Future<void> _fetchLikeStatus() async {
    if (!mounted) return;
    setState(() => _isLikeLoading = true);
    // Store notifier reference before await to avoid ref access after dispose
    final notifier = ref.read(playbackProvider.notifier);
    final isSaved = await notifier.isCurrentTrackSaved();
    if (mounted) {
      setState(() {
        _isLiked = isSaved;
        _isLikeLoading = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (!mounted) return;
    setState(() => _isLikeLoading = true);
    // Store notifier reference before await to avoid ref access after dispose
    final notifier = ref.read(playbackProvider.notifier);
    final result = await notifier.toggleCurrentTrackLike(_isLiked);
    if (mounted) {
      setState(() {
        _isLiked = result.isLiked;
        _isLikeLoading = false;
      });
    }
  }

  // Control bar with shuffle, progress time, and repeat - matches NowPlayingBar
  Widget _buildControlBar(PlaybackState playbackState, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Shuffle button
          _buildShuffleButton(playbackState, l10n),
          // Progress time
          Text(
            '${_formatDuration(playbackState.progressMs)} / ${_formatDuration(playbackState.durationMs)}',
            style: const TextStyle(
              color: AppTheme.spotifyLightGray,
              fontSize: 11,
            ),
          ),
          // Repeat button
          _buildRepeatButton(playbackState, l10n),
        ],
      ),
    );
  }

  Widget _buildShuffleButton(PlaybackState playbackState, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        if (mounted) ref.read(playbackProvider.notifier).toggleShuffle();
      },
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          Icons.shuffle,
          color: playbackState.shuffleState
              ? AppTheme.spotifyGreen
              : AppTheme.spotifyLightGray,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRepeatButton(PlaybackState playbackState, AppLocalizations l10n) {
    final IconData icon;
    final Color color;

    switch (playbackState.repeatMode) {
      case RepeatMode.off:
        icon = Icons.repeat;
        color = AppTheme.spotifyLightGray;
        break;
      case RepeatMode.context:
        icon = Icons.repeat;
        color = AppTheme.spotifyGreen;
        break;
      case RepeatMode.track:
        icon = Icons.repeat_one;
        color = AppTheme.spotifyGreen;
        break;
    }

    return GestureDetector(
      onTap: () {
        if (mounted) ref.read(playbackProvider.notifier).cycleRepeatMode();
      },
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  String _formatDuration(int ms) {
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _AppRouter extends ConsumerStatefulWidget {
  const _AppRouter();

  @override
  ConsumerState<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends ConsumerState<_AppRouter> {
  bool _setupComplete = false;

  void _onSetupComplete() {
    setState(() {
      _setupComplete = true;
    });
    // After setup, check auth status
    ref.read(authProvider.notifier).checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    final credentialsState = ref.watch(credentialsProvider);

    // Show loading while checking credentials
    if (credentialsState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If credentials not configured and setup not complete, show setup guide
    if (!credentialsState.hasSpotifyCredentials && !_setupComplete) {
      return SetupGuideScreen(onSetupComplete: _onSetupComplete);
    }

    // Credentials are configured, show auth flow
    return const _AuthWrapper();
  }
}

class _AuthWrapper extends ConsumerStatefulWidget {
  const _AuthWrapper();

  @override
  ConsumerState<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<_AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check auth status when credentials are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return switch (authState.status) {
      // Only show loading spinner for initial state (checking stored tokens)
      AuthStatus.initial => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.authenticated => const HomeScreen(),
      // Show LoginScreen for loading, unauthenticated, and error states
      // LoginScreen handles its own loading UI with cancel button
      AuthStatus.loading ||
      AuthStatus.unauthenticated ||
      AuthStatus.error => const LoginScreen(),
    };
  }
}
