import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/app_localizations.dart';
import 'application/di/core_providers.dart' show sharedPrefsProvider;
import 'application/providers/auth_provider.dart';
import 'application/providers/credentials_provider.dart';
import 'application/providers/locale_provider.dart';
import 'application/providers/navigation_provider.dart';
import 'application/providers/playback_provider.dart';
import 'domain/entities/playback_state.dart';
import 'core/services/system_tray_service.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/setup_guide_screen.dart';
import 'presentation/themes/app_theme.dart';
import 'presentation/widgets/custom_title_bar.dart';
import 'presentation/widgets/mini_player_content.dart';

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
      // On macOS with fullSizeContentView, inform Scaffold about the
      // title bar area so AppBar adds internal top padding automatically.
      builder: Platform.isMacOS
          ? (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  padding: mq.padding.copyWith(top: mq.padding.top + 28),
                ),
                child: child!,
              );
            }
          : null,
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
  ProviderSubscription? _playbackSubscription;

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
    _playbackSubscription?.close();
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
    _playbackSubscription = ref.listenManual(playbackProvider, (previous, next) {
      final state = next as PlaybackState;
      _systemTray.updatePlaybackState(
        isPlaying: state.isPlaying,
        trackName: state.currentTrack?.name,
        artistName: state.currentTrack?.artistNames,
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
                child: const MiniPlayerContent(),
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
  bool _hasCheckedAuth = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // On macOS/iOS, wait for SharedPreferences to be ready before checking auth.
    // Without this, the placeholder data source returns null tokens and
    // checkAuthStatus() always concludes "unauthenticated".
    if (Platform.isMacOS || Platform.isIOS) {
      final prefsReady = ref.watch(sharedPrefsProvider).hasValue;
      if (!prefsReady) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
    }

    // Trigger auth check once when data sources are ready
    if (!_hasCheckedAuth) {
      _hasCheckedAuth = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authProvider.notifier).checkAuthStatus();
      });
    }

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
