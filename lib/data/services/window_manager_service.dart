import 'dart:io';
import 'dart:ui';
import 'package:window_manager/window_manager.dart';
import '../../core/services/window_service.dart';

/// Implementation of WindowService using window_manager package
class WindowManagerService implements WindowService, WindowListener {
  final List<WindowStateListener> _listeners = [];

  WindowManagerService() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
    }
  }

  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    _listeners.clear();
  }

  @override
  Future<bool> isMaximized() async {
    if (!_isDesktop) return false;
    return await windowManager.isMaximized();
  }

  @override
  Future<void> minimize() async {
    if (!_isDesktop) return;
    await windowManager.minimize();
  }

  @override
  Future<void> maximize() async {
    if (!_isDesktop) return;
    await windowManager.maximize();
  }

  @override
  Future<void> unmaximize() async {
    if (!_isDesktop) return;
    await windowManager.unmaximize();
  }

  @override
  Future<void> close() async {
    if (!_isDesktop) return;
    await windowManager.close();
  }

  @override
  Future<bool> isAlwaysOnTop() async {
    if (!_isDesktop) return false;
    return await windowManager.isAlwaysOnTop();
  }

  @override
  Future<void> setAlwaysOnTop(bool isAlwaysOnTop) async {
    if (!_isDesktop) return;
    await windowManager.setAlwaysOnTop(isAlwaysOnTop);
  }

  @override
  Future<Size> getSize() async {
    if (!_isDesktop) return Size.zero;
    return await windowManager.getSize();
  }

  @override
  Future<void> setSize(Size size) async {
    if (!_isDesktop) return;
    await windowManager.setSize(size);
  }

  @override
  Future<void> setMinimumSize(Size size) async {
    if (!_isDesktop) return;
    await windowManager.setMinimumSize(size);
  }

  @override
  Future<void> setMaximumSize(Size size) async {
    if (!_isDesktop) return;
    await windowManager.setMaximumSize(size);
  }

  @override
  void addListener(WindowStateListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  @override
  void removeListener(WindowStateListener listener) {
    _listeners.remove(listener);
  }

  bool get _isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  // WindowListener implementation - forward to our listeners
  @override
  void onWindowMaximize() {
    for (final listener in _listeners) {
      listener.onWindowMaximize();
    }
  }

  @override
  void onWindowUnmaximize() {
    for (final listener in _listeners) {
      listener.onWindowUnmaximize();
    }
  }

  @override
  void onWindowMinimize() {
    for (final listener in _listeners) {
      listener.onWindowMinimize();
    }
  }

  @override
  void onWindowRestore() {
    for (final listener in _listeners) {
      listener.onWindowRestore();
    }
  }

  @override
  void onWindowClose() {
    for (final listener in _listeners) {
      listener.onWindowClose();
    }
  }

  @override
  void onWindowFocus() {
    for (final listener in _listeners) {
      listener.onWindowFocus();
    }
  }

  @override
  void onWindowBlur() {
    for (final listener in _listeners) {
      listener.onWindowBlur();
    }
  }

  // Other WindowListener methods - not forwarding as they're less common
  @override
  void onWindowEvent(String eventName) {}

  @override
  void onWindowMove() {}

  @override
  void onWindowResize() {}

  @override
  void onWindowResized() {}

  @override
  void onWindowMoved() {}

  @override
  void onWindowEnterFullScreen() {}

  @override
  void onWindowLeaveFullScreen() {}

  @override
  void onWindowDocked() {}

  @override
  void onWindowUndocked() {}
}
