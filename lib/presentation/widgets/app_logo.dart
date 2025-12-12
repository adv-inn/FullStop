import 'package:flutter/material.dart';

/// App logo widget that displays the logo.png from assets
class AppLogo extends StatelessWidget {
  final double size;
  final bool showBackground;
  final double? backgroundRadius;

  const AppLogo({
    super.key,
    this.size = 64,
    this.showBackground = false,
    this.backgroundRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/icon/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (!showBackground) {
      return image;
    }

    return Container(
      width: size * 1.5,
      height: size * 1.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(backgroundRadius ?? size * 0.25),
      ),
      child: Center(child: image),
    );
  }
}
