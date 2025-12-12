import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/services/window_service.dart';
import '../../application/providers/navigation_provider.dart';
import '../../l10n/app_localizations.dart';
import '../themes/app_theme.dart';
import '../../application/di/injection_container.dart';
import 'app_logo.dart';

/// Custom title bar widget for Windows platform
/// Provides a Spotify-style title bar with window controls
/// Title is always "FullStop" - no dynamic updates
/// Supports transparent mode for full-bleed content screens
class CustomTitleBar extends ConsumerStatefulWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const CustomTitleBar({
    super.key,
    this.title = 'FullStop',
    this.leading,
    this.actions,
    this.backgroundColor,
  });

  @override
  ConsumerState<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _CustomTitleBarState extends ConsumerState<CustomTitleBar>
    with WindowStateListenerMixin {
  bool _isMaximized = false;
  bool _isAlwaysOnTop = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      final windowService = ref.read(windowServiceProvider);
      windowService.addListener(this);
      _updateMaximizedState();
      _updateAlwaysOnTopState();
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      final windowService = ref.read(windowServiceProvider);
      windowService.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _updateMaximizedState() async {
    if (Platform.isWindows) {
      final windowService = ref.read(windowServiceProvider);
      final isMaximized = await windowService.isMaximized();
      if (mounted) {
        setState(() {
          _isMaximized = isMaximized;
        });
      }
    }
  }

  Future<void> _updateAlwaysOnTopState() async {
    if (Platform.isWindows) {
      final windowService = ref.read(windowServiceProvider);
      final isAlwaysOnTop = await windowService.isAlwaysOnTop();
      if (mounted) {
        setState(() {
          _isAlwaysOnTop = isAlwaysOnTop;
        });
      }
    }
  }

  Future<void> _toggleAlwaysOnTop() async {
    final windowService = ref.read(windowServiceProvider);
    await windowService.setAlwaysOnTop(!_isAlwaysOnTop);
    if (mounted) {
      setState(() {
        _isAlwaysOnTop = !_isAlwaysOnTop;
      });
    }
  }

  @override
  void onWindowMaximize() {
    setState(() {
      _isMaximized = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      _isMaximized = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) {
      return const SizedBox.shrink();
    }

    final windowService = ref.watch(windowServiceProvider);
    final navState = ref.watch(navigationProvider);
    final actions = widget.actions ?? [];
    final isTransparent = navState.transparentMode;

    return Container(
      height: 32,
      color: isTransparent
          ? Colors.transparent
          : (widget.backgroundColor ?? AppTheme.spotifyBlack),
      child: Row(
        children: [
          // Draggable area with title - use DragToMoveArea for proper Windows dragging
          Expanded(
            child: DragToMoveArea(
              child: GestureDetector(
                onDoubleTap: () => _toggleMaximize(windowService),
                child: Container(
                  padding: const EdgeInsets.only(left: 12),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      // In transparent mode, show back button instead of logo
                      if (isTransparent) ...[
                        _TransparentModeBackButton(
                          onPressed: () =>
                              ref.read(navigationProvider.notifier).goBack(),
                        ),
                      ] else ...[
                        // App icon
                        const AppLogo(size: 16),
                        const SizedBox(width: 8),
                        // Leading widget
                        if (widget.leading != null) widget.leading!,
                        // Title - static "FullStop"
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: AppTheme.spotifyWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Custom actions (only in normal mode)
                      if (!isTransparent && actions.isNotEmpty) ...actions,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Always on top button
          _AlwaysOnTopButton(
            isAlwaysOnTop: _isAlwaysOnTop,
            onPressed: _toggleAlwaysOnTop,
            tooltip: _isAlwaysOnTop
                ? AppLocalizations.of(context)?.unpinFromTop ?? 'Unpin from top'
                : AppLocalizations.of(context)?.pinToTop ?? 'Pin to top',
          ),
          // Window control buttons
          _WindowControls(
            isMaximized: _isMaximized,
            onMinimize: windowService.minimize,
            onMaximize: () => _toggleMaximize(windowService),
            onClose: windowService.close,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMaximize(WindowService windowService) async {
    if (_isMaximized) {
      await windowService.unmaximize();
    } else {
      await windowService.maximize();
    }
  }
}

/// Window control buttons (minimize, maximize, close)
class _WindowControls extends StatelessWidget {
  final bool isMaximized;
  final VoidCallback onMinimize;
  final VoidCallback onMaximize;
  final VoidCallback onClose;

  const _WindowControls({
    required this.isMaximized,
    required this.onMinimize,
    required this.onMaximize,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WindowControlButton(
          icon: Icons.remove,
          onPressed: onMinimize,
          tooltip: 'Minimize',
        ),
        _WindowControlButton(
          icon: isMaximized ? Icons.filter_none : Icons.crop_square,
          onPressed: onMaximize,
          tooltip: isMaximized ? 'Restore' : 'Maximize',
          iconSize: isMaximized ? 14 : 16,
        ),
        _WindowControlButton(
          icon: Icons.close,
          onPressed: onClose,
          tooltip: 'Close',
          isClose: true,
        ),
      ],
    );
  }
}

/// Individual window control button
class _WindowControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isClose;
  final double iconSize;

  const _WindowControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isClose = false,
    this.iconSize = 16,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 46,
            height: 32,
            color: _isHovered
                ? (widget.isClose ? Colors.red : AppTheme.spotifyDarkGray)
                : Colors.transparent,
            child: Icon(
              widget.icon,
              color: _isHovered && widget.isClose
                  ? Colors.white
                  : AppTheme.spotifyLightGray,
              size: widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

/// Back button for transparent mode title bar
class _TransparentModeBackButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _TransparentModeBackButton({required this.onPressed});

  @override
  State<_TransparentModeBackButton> createState() =>
      _TransparentModeBackButtonState();
}

class _TransparentModeBackButtonState
    extends State<_TransparentModeBackButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppTheme.spotifyWhite,
            size: 18,
          ),
        ),
      ),
    );
  }
}

/// Always on top toggle button
class _AlwaysOnTopButton extends StatefulWidget {
  final bool isAlwaysOnTop;
  final VoidCallback onPressed;
  final String tooltip;

  const _AlwaysOnTopButton({
    required this.isAlwaysOnTop,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  State<_AlwaysOnTopButton> createState() => _AlwaysOnTopButtonState();
}

class _AlwaysOnTopButtonState extends State<_AlwaysOnTopButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 36,
            height: 32,
            color: _isHovered ? AppTheme.spotifyDarkGray : Colors.transparent,
            child: Icon(
              widget.isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
              color: widget.isAlwaysOnTop
                  ? AppTheme.spotifyGreen
                  : AppTheme.spotifyLightGray,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }
}
