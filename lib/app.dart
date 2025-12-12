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
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/setup_guide_screen.dart';
import 'presentation/themes/app_theme.dart';
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

      // Always use Stack layout to preserve CustomTitleBar state
      // In transparent mode: content fills entire window
      // In normal mode: content has top padding for title bar
      return Stack(
        children: [
          // Content area
          Padding(
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
