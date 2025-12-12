import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../application/di/injection_container.dart';
import '../../core/services/window_service.dart';

/// A custom AppBar that supports window dragging on Windows platform.
/// Wraps the title area with DragToMoveArea for window dragging functionality.
/// Window controls are handled by the unified CustomTitleBar.
class DraggableAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final double? titleSpacing;
  final bool? centerTitle;
  final double toolbarHeight;
  final FlexibleSpaceBar? flexibleSpace;

  const DraggableAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation,
    this.bottom,
    this.titleSpacing,
    this.centerTitle,
    this.toolbarHeight = kToolbarHeight,
    this.flexibleSpace,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  ConsumerState<DraggableAppBar> createState() => _DraggableAppBarState();
}

class _DraggableAppBarState extends ConsumerState<DraggableAppBar>
    with WindowStateListenerMixin {
  bool _isMaximized = false;
  WindowService? _windowService;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      _windowService = ref.read(windowServiceProvider);
      _windowService!.addListener(this);
      _updateMaximizedState();
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      _windowService?.removeListener(this);
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

  Future<void> _toggleMaximize() async {
    final windowService = ref.read(windowServiceProvider);
    if (_isMaximized) {
      await windowService.unmaximize();
    } else {
      await windowService.maximize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: widget.title,
      leading: widget.leading,
      actions: widget.actions,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      backgroundColor: widget.backgroundColor,
      elevation: widget.elevation,
      bottom: widget.bottom,
      titleSpacing: widget.titleSpacing,
      centerTitle: widget.centerTitle,
      toolbarHeight: widget.toolbarHeight,
      flexibleSpace: widget.flexibleSpace,
    );

    // On Windows, wrap with a Stack to add drag area
    if (Platform.isWindows) {
      return Stack(
        children: [
          appBar,
          // Drag area covering the app bar, but not blocking buttons
          Positioned.fill(
            child: Row(
              children: [
                // Leave space for leading/back button
                SizedBox(
                  width:
                      widget.leading != null || widget.automaticallyImplyLeading
                      ? 56
                      : 16,
                ),
                // Draggable area in the middle
                Expanded(
                  child: DragToMoveArea(
                    child: GestureDetector(
                      onDoubleTap: _toggleMaximize,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),
                // Leave space for action buttons
                SizedBox(width: _calculateActionsWidth()),
              ],
            ),
          ),
        ],
      );
    }

    return appBar;
  }

  double _calculateActionsWidth() {
    // Only calculate space for user action buttons (no window controls)
    double width = 16;
    if (widget.actions != null && widget.actions!.isNotEmpty) {
      width += widget.actions!.length * 48.0;
    }
    return width;
  }
}

/// A wrapper widget that adds window dragging capability to SliverAppBar.
/// Use this to wrap content that uses SliverAppBar in a CustomScrollView.
class DraggableScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;

  const DraggableScaffold({super.key, required this.body, this.appBar});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) {
      return Scaffold(appBar: appBar, body: body);
    }

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          body,
          // Add a drag area at the top of the screen
          Positioned(
            top: 0,
            left: 56, // Space for back button
            right: 150, // Space for action buttons
            height: kToolbarHeight,
            child: DragToMoveArea(child: Container(color: Colors.transparent)),
          ),
        ],
      ),
    );
  }
}
