import 'dart:math';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Animated wave background that shows gentle flowing waves
/// Used to indicate currently playing session
class AnimatedWaveBackground extends StatefulWidget {
  final Widget child;
  final double heightRatio;
  final Color? color;

  const AnimatedWaveBackground({
    super.key,
    required this.child,
    this.heightRatio = 0.3,
    this.color,
  });

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waveColor = widget.color ?? AppTheme.spotifyGreen;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;

                  if (width <= 0 ||
                      height <= 0 ||
                      !width.isFinite ||
                      !height.isFinite) {
                    return const SizedBox.shrink();
                  }

                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(width, height),
                        painter: _WavePainter(
                          animationValue: _controller.value,
                          color: waveColor,
                          heightRatio: widget.heightRatio,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double heightRatio;

  _WavePainter({
    required this.animationValue,
    required this.color,
    required this.heightRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final waveHeight = size.height * heightRatio;
    final baseY = size.height - waveHeight;

    // Create gradient paint for wave fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.05)],
      ).createShader(Rect.fromLTWH(0, baseY, size.width, waveHeight));

    // Build wave path
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, baseY);

    // Draw two overlapping waves for organic feel
    for (double x = 0; x <= size.width; x += 2) {
      final progress = x / size.width;
      final wave1 = sin((progress * 2 * pi) + (animationValue * 2 * pi)) * 8;
      final wave2 =
          sin((progress * 3 * pi) + (animationValue * 2 * pi * 1.3)) * 5;
      path.lineTo(x, baseY + wave1 + wave2);
    }

    path
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, fillPaint);

    // Draw subtle top wave line
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final linePath = Path();
    for (double x = 0; x <= size.width; x += 2) {
      final progress = x / size.width;
      final wave1 = sin((progress * 2 * pi) + (animationValue * 2 * pi)) * 8;
      final wave2 =
          sin((progress * 3 * pi) + (animationValue * 2 * pi * 1.3)) * 5;
      final y = baseY + wave1 + wave2;

      if (x == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
