import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation state for unified title bar
class NavigationState {
  final String title;
  final bool canGoBack;
  final List<Widget> actions;
  final GlobalKey<NavigatorState>? navigatorKey;

  /// When true, the title bar becomes transparent with only window controls visible
  /// Used for full-bleed content screens like session detail
  final bool transparentMode;

  const NavigationState({
    this.title = 'FullStop',
    this.canGoBack = false,
    this.actions = const [],
    this.navigatorKey,
    this.transparentMode = false,
  });

  NavigationState copyWith({
    String? title,
    bool? canGoBack,
    List<Widget>? actions,
    GlobalKey<NavigatorState>? navigatorKey,
    bool? transparentMode,
  }) {
    return NavigationState(
      title: title ?? this.title,
      canGoBack: canGoBack ?? this.canGoBack,
      actions: actions ?? this.actions,
      navigatorKey: navigatorKey ?? this.navigatorKey,
      transparentMode: transparentMode ?? this.transparentMode,
    );
  }
}

/// Navigation notifier to manage title bar state
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    state = state.copyWith(navigatorKey: key);
  }

  void updateTitleBar({String? title, bool? canGoBack, List<Widget>? actions}) {
    state = state.copyWith(
      title: title,
      canGoBack: canGoBack,
      actions: actions,
    );
  }

  void resetToHome() {
    state = state.copyWith(
      title: 'FullStop',
      canGoBack: false,
      actions: [],
      transparentMode: false,
    );
  }

  /// Enable transparent mode for full-bleed content screens
  void setTransparentMode(bool transparent) {
    state = state.copyWith(transparentMode: transparent);
  }

  void goBack() {
    state.navigatorKey?.currentState?.pop();
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>(
      (ref) => NavigationNotifier(),
    );
