/// Abstract interface for window management
/// This decouples UI components from platform-specific window management
abstract class WindowService {
  /// Check if the window is currently maximized
  Future<bool> isMaximized();

  /// Minimize the window
  Future<void> minimize();

  /// Maximize the window
  Future<void> maximize();

  /// Restore the window from maximized state
  Future<void> unmaximize();

  /// Close the window
  Future<void> close();

  /// Check if the window is always on top
  Future<bool> isAlwaysOnTop();

  /// Set always on top state
  Future<void> setAlwaysOnTop(bool isAlwaysOnTop);

  /// Add a listener for window state changes
  void addListener(WindowStateListener listener);

  /// Remove a window state listener
  void removeListener(WindowStateListener listener);
}

/// Listener interface for window state changes
abstract class WindowStateListener {
  void onWindowMaximize();
  void onWindowUnmaximize();
  void onWindowMinimize();
  void onWindowRestore();
  void onWindowClose();
  void onWindowFocus();
  void onWindowBlur();
}

/// Default implementation of WindowStateListener with empty methods
/// Subclasses can override only the methods they need
mixin WindowStateListenerMixin implements WindowStateListener {
  @override
  void onWindowMaximize() {}

  @override
  void onWindowUnmaximize() {}

  @override
  void onWindowMinimize() {}

  @override
  void onWindowRestore() {}

  @override
  void onWindowClose() {}

  @override
  void onWindowFocus() {}

  @override
  void onWindowBlur() {}
}
