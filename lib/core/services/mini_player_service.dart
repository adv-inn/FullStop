import 'dart:ui';

import '../services/window_service.dart';

/// Service to coordinate mini player mode transitions
class MiniPlayerService {
  final WindowService _windowService;

  /// Stored window size before entering mini mode
  Size? _savedSize;

  /// Whether currently in mini player mode
  bool _isMiniMode = false;

  /// Normal mode minimum size (from main.dart)
  static const Size normalMinSize = Size(380, 600);

  /// Mini mode window size (32px title bar + 56px content, no progress bar)
  /// Width 380px shows all controls (like, prev, play, next)
  static const Size miniSize = Size(380, 88);

  /// Mini mode minimum size
  /// Width 280px shows minimal controls (play, next only)
  static const Size miniMinSize = Size(280, 84);

  /// Mini mode maximum size (allows expanding to show more controls)
  /// Height 150px shows progress bar, shuffle, progress time, repeat controls
  static const Size miniMaxSize = Size(500, 150);

  MiniPlayerService(this._windowService);

  bool get isMiniMode => _isMiniMode;

  /// Enter mini player mode
  /// Saves current window size, adjusts minimum/maximum size, shrinks window, and enables always on top
  Future<void> enterMiniMode() async {
    if (_isMiniMode) return;

    // Save current window size
    _savedSize = await _windowService.getSize();

    // Set mini mode size constraints
    await _windowService.setMinimumSize(miniMinSize);
    await _windowService.setMaximumSize(miniMaxSize);

    // Shrink window to mini size
    await _windowService.setSize(miniSize);

    // Enable always on top
    await _windowService.setAlwaysOnTop(true);

    _isMiniMode = true;
  }

  /// Exit mini player mode
  /// Restores minimum size, removes maximum size limit, and restores window size
  Future<void> exitMiniMode() async {
    if (!_isMiniMode) return;

    // Remove maximum size limit first (use very large size)
    await _windowService.setMaximumSize(const Size(9999, 9999));

    // Restore normal minimum size
    await _windowService.setMinimumSize(normalMinSize);

    // Restore saved window size or use default
    final restoreSize = _savedSize ?? const Size(900, 700);
    await _windowService.setSize(restoreSize);

    _isMiniMode = false;
    _savedSize = null;
  }

  /// Toggle mini player mode
  Future<void> toggleMiniMode() async {
    if (_isMiniMode) {
      await exitMiniMode();
    } else {
      await enterMiniMode();
    }
  }
}
