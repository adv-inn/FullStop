import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import '../utils/logger.dart';

/// Callback types for tray events
typedef TrayCallback = void Function();

/// Localized strings for system tray menu
class TrayLocalizedStrings {
  final String showWindow;
  final String exit;
  final String play;
  final String pause;
  final String previousTrack;
  final String nextTrack;
  final String tooltip;

  const TrayLocalizedStrings({
    required this.showWindow,
    required this.exit,
    required this.play,
    required this.pause,
    required this.previousTrack,
    required this.nextTrack,
    required this.tooltip,
  });

  /// Default English strings
  static const TrayLocalizedStrings defaultStrings = TrayLocalizedStrings(
    showWindow: 'Show FullStop',
    exit: 'Exit',
    play: 'Play',
    pause: 'Pause',
    previousTrack: 'Previous Track',
    nextTrack: 'Next Track',
    tooltip: 'FullStop - Spotify Controller',
  );
}

/// Service for managing system tray functionality
/// Uses native Windows context menu via TrackPopupMenu API
class SystemTrayService {
  static final SystemTrayService _instance = SystemTrayService._internal();
  factory SystemTrayService() => _instance;
  SystemTrayService._internal();

  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();

  bool _isInitialized = false;
  TrayCallback? _onShowWindow;
  TrayCallback? _onExitApp;
  TrayCallback? _onPlayPause;
  TrayCallback? _onNextTrack;
  TrayCallback? _onPreviousTrack;
  TrayLocalizedStrings _localizedStrings = TrayLocalizedStrings.defaultStrings;

  // Current state for menu rebuilding (only rebuild when changed)
  bool _currentIsPlaying = false;
  String? _currentTrackName;
  String? _cachedIconPath;

  /// Check if system tray is supported on this platform
  bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// Get the tray icon path (cached after first extraction)
  Future<String?> _getTrayIconPath() async {
    if (_cachedIconPath != null) return _cachedIconPath;

    try {
      final (assetPath, fileName) = Platform.isWindows
          ? ('assets/icon/app_icon.ico', 'tray_icon.ico')
          : ('assets/icon/logo.png', 'tray_icon.png');

      _cachedIconPath = await _extractAssetIcon(assetPath, fileName);
      return _cachedIconPath;
    } catch (e) {
      AppLogger.error('Failed to get tray icon path', e);
      return null;
    }
  }

  /// Extract an asset icon to a temporary file
  Future<String?> _extractAssetIcon(String assetPath, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final iconFile = File(path.join(tempDir.path, 'fullstop', fileName));

      // Only extract if file doesn't exist (cached on disk)
      if (!await iconFile.exists()) {
        await iconFile.parent.create(recursive: true);
        final byteData = await rootBundle.load(assetPath);
        await iconFile.writeAsBytes(byteData.buffer.asUint8List());
      }

      return iconFile.path;
    } catch (e) {
      AppLogger.error('Failed to extract asset icon: $e', e);
      return null;
    }
  }

  /// Initialize the system tray
  Future<void> initialize({
    TrayCallback? onShowWindow,
    TrayCallback? onExitApp,
    TrayCallback? onPlayPause,
    TrayCallback? onNextTrack,
    TrayCallback? onPreviousTrack,
  }) async {
    if (!isSupported) {
      AppLogger.warning('System tray not supported on this platform');
      return;
    }

    if (_isInitialized) {
      AppLogger.info('System tray already initialized');
      return;
    }

    _onShowWindow = onShowWindow;
    _onExitApp = onExitApp;
    _onPlayPause = onPlayPause;
    _onNextTrack = onNextTrack;
    _onPreviousTrack = onPreviousTrack;

    try {
      final iconPath = await _getTrayIconPath();
      if (iconPath == null) {
        AppLogger.error('Failed to get tray icon path');
        return;
      }

      await _systemTray.initSystemTray(
        title: _localizedStrings.tooltip,
        iconPath: iconPath,
        toolTip: _localizedStrings.tooltip,
      );

      // Build initial context menu
      await _updateContextMenu();

      // Register event handlers
      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          // Left click - show window
          showWindow();
        } else if (eventName == kSystemTrayEventRightClick) {
          // Right click - show native context menu
          _systemTray.popUpContextMenu();
        }
      });

      _isInitialized = true;
      AppLogger.info('System tray initialized successfully (native menu)');
    } catch (e) {
      AppLogger.error('Failed to initialize system tray', e);
    }
  }

  /// Update the context menu with native Windows menu
  Future<void> _updateContextMenu() async {
    if (!isSupported) return;

    final items = <MenuItemBase>[
      // Current track info (if available)
      if (_currentTrackName case final name? when name.isNotEmpty) ...[
        MenuItemLabel(
          label: name.length > 40 ? '${name.substring(0, 37)}...' : name,
          enabled: false,
        ),
        MenuSeparator(),
      ],

      // Playback controls
      MenuItemLabel(
        label: _currentIsPlaying
            ? _localizedStrings.pause
            : _localizedStrings.play,
        onClicked: (_) => _onPlayPause?.call(),
      ),
      MenuItemLabel(
        label: _localizedStrings.previousTrack,
        onClicked: (_) => _onPreviousTrack?.call(),
      ),
      MenuItemLabel(
        label: _localizedStrings.nextTrack,
        onClicked: (_) => _onNextTrack?.call(),
      ),
      MenuSeparator(),

      // Window controls
      MenuItemLabel(
        label: _localizedStrings.showWindow,
        onClicked: (_) {
          showWindow();
          _onShowWindow?.call();
        },
      ),
      MenuSeparator(),

      // Exit
      MenuItemLabel(
        label: _localizedStrings.exit,
        onClicked: (_) => _onExitApp?.call(),
      ),
    ];

    final menu = Menu();
    await menu.buildFrom(items);
    await _systemTray.setContextMenu(menu);
  }

  /// Update localized strings and refresh the menu
  Future<void> updateLocalizedStrings(TrayLocalizedStrings strings) async {
    _localizedStrings = strings;
    if (!isSupported || !_isInitialized) return;

    try {
      await _systemTray.setToolTip(_localizedStrings.tooltip);
      await _updateContextMenu();
      AppLogger.info('System tray localization updated');
    } catch (e) {
      AppLogger.warning('Failed to update tray localization', e);
    }
  }

  /// Update tray with current playback state
  /// Only rebuilds menu when state actually changes
  Future<void> updatePlaybackState({
    required bool isPlaying,
    String? trackName,
    String? artistName,
  }) async {
    if (!isSupported || !_isInitialized) return;

    // Build new track display name
    final newTrackName = switch ((trackName, artistName)) {
      (String t, String a) when t.isNotEmpty && a.isNotEmpty => '$t - $a',
      (String t, _) when t.isNotEmpty => t,
      _ => null,
    };

    // Check if state actually changed
    final playingChanged = _currentIsPlaying != isPlaying;
    final trackChanged = _currentTrackName != newTrackName;

    if (!playingChanged && !trackChanged) return;

    try {
      // Update tooltip only when track changes
      if (trackChanged) {
        final tooltip = newTrackName ?? 'FullStop';
        await _systemTray.setToolTip(tooltip);
      }

      // Update state
      _currentIsPlaying = isPlaying;
      _currentTrackName = newTrackName;

      // Rebuild menu
      await _updateContextMenu();
    } catch (e) {
      AppLogger.warning('Failed to update tray state', e);
    }
  }

  /// Show the main window
  /// Uses opacity trick to prevent transparent window flash on restore
  Future<void> showWindow() async {
    if (Platform.isMacOS) {
      // On macOS, use system_tray's AppWindow to avoid window_manager nil crash
      await _appWindow.show();
    } else {
      // On Windows/Linux, use window_manager with opacity trick
      await windowManager.setOpacity(0);
      await windowManager.show();
      await windowManager.focus();
      // Small delay to let Flutter render, then restore opacity
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await windowManager.setOpacity(1);
    }
  }

  /// Hide the window to tray
  Future<void> hideToTray() async {
    try {
      await windowManager.hide();
    } catch (e) {
      // Fallback: use AppWindow.hide() which minimizes on macOS
      AppLogger.warning('windowManager.hide() failed, using fallback', e);
      await _appWindow.hide();
    }
  }

  /// Dispose of tray resources
  Future<void> dispose() async {
    if (!isSupported || !_isInitialized) return;

    try {
      await _systemTray.destroy();
      _isInitialized = false;
      AppLogger.info('System tray disposed');
    } catch (e) {
      AppLogger.warning('Failed to dispose system tray', e);
    }
  }
}
