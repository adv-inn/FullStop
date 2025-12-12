import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A horizontal scroll view that supports mouse wheel scrolling on desktop.
/// This widget wraps content in a SingleChildScrollView with horizontal scrolling
/// and enables mouse wheel to scroll horizontally.
class HorizontalScrollView extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;

  const HorizontalScrollView({
    super.key,
    required this.child,
    this.controller,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _HorizontalScrollBehavior(),
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Custom scroll behavior that enables mouse wheel horizontal scrolling
class _HorizontalScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

/// A horizontal ListView that supports mouse wheel scrolling on desktop.
class HorizontalListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const HorizontalListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ScrollConfiguration(
        behavior: _HorizontalScrollBehavior(),
        child: ListView.builder(
          controller: controller,
          scrollDirection: Axis.horizontal,
          padding: padding,
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        ),
      ),
    );
  }
}
