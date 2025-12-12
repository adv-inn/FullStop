import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/settings_provider.dart';
import '../themes/app_theme.dart';

/// Shared mixin for audio wave animations
/// Provides synchronized rhythm animations for both indicator bars and wave backgrounds
mixin AudioWaveAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late List<AnimationController> waveControllers;
  late List<Animation<double>> waveAnimations;
  final _random = Random();

  void initWaveAnimations({
    int count = 5,
    double minValue = 0.3,
    double maxValue = 0.8,
  }) {
    waveControllers = List.generate(count, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + _random.nextInt(200)),
      );
    });

    waveAnimations = waveControllers.map((controller) {
      return Tween<double>(
        begin: minValue,
        end: maxValue,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    // Start animations with staggered delays for natural rhythm
    for (int i = 0; i < waveControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) {
          waveControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void disposeWaveAnimations() {
    for (final controller in waveControllers) {
      controller.dispose();
    }
  }
}

/// Animated audio wave indicator - shows bars dancing like an equalizer
class AudioWaveIndicator extends ConsumerStatefulWidget {
  final double size;
  final Color? color;
  final int barCount;

  const AudioWaveIndicator({
    super.key,
    this.size = 20,
    this.color,
    this.barCount = 3,
  });

  @override
  ConsumerState<AudioWaveIndicator> createState() => _AudioWaveIndicatorState();
}

class _AudioWaveIndicatorState extends ConsumerState<AudioWaveIndicator>
    with TickerProviderStateMixin, AudioWaveAnimationMixin {
  @override
  void initState() {
    super.initState();
    initWaveAnimations(count: widget.barCount);
  }

  @override
  void dispose() {
    disposeWaveAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gpuEnabled = ref.watch(gpuAccelerationEnabledProvider);
    final color = widget.color ?? AppTheme.spotifyGreen;
    final barWidth = widget.size / (widget.barCount * 2);
    final spacing = barWidth * 0.5;

    Widget content = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          return AnimatedBuilder(
            animation: waveAnimations[index],
            builder: (context, child) {
              return Container(
                width: barWidth,
                height: widget.size * waveAnimations[index].value,
                margin: EdgeInsets.only(
                  right: index < widget.barCount - 1 ? spacing : 0,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              );
            },
          );
        }),
      ),
    );

    // Wrap with RepaintBoundary for GPU acceleration if enabled
    if (gpuEnabled) {
      content = RepaintBoundary(child: content);
    }

    // Exclude from accessibility tree to prevent frequent AXTree updates
    return ExcludeSemantics(child: content);
  }
}

/// Animated wave background - unified "music fountain" style animation
///
/// States:
/// - hidden: no wave visible (completely idle)
/// - loading: ray extends from right (50%) to left, building the "water surface"
/// - playing: wave animates with rhythm (fountain is active)
/// - paused: wave calms down to a flat line (fountain stopped but water surface remains)
class AnimatedWaveBackground extends ConsumerStatefulWidget {
  final Widget child;
  final double heightRatio;
  final Color? color;
  final int waveCount;

  /// Whether this session is currently playing (waves animate)
  final bool isPlaying;

  /// Whether this session is active (playing or paused, shows the surface)
  final bool isActive;

  /// Whether currently loading (shows ray-to-line animation)
  final bool isLoading;

  const AnimatedWaveBackground({
    super.key,
    required this.child,
    this.heightRatio = 0.3,
    this.color,
    this.waveCount = 5,
    this.isPlaying = false,
    this.isActive = true,
    this.isLoading = false,
  });

  @override
  ConsumerState<AnimatedWaveBackground> createState() =>
      _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends ConsumerState<AnimatedWaveBackground>
    with TickerProviderStateMixin {
  /// Controller for the ray extension animation (right to left)
  late AnimationController _rayController;

  /// Animation for ray extension progress (0.0 = 50% from right, 1.0 = full width)
  late Animation<double> _rayAnimation;

  /// Controllers for wave amplitude (one per wave point)
  late List<AnimationController> _waveControllers;

  /// Animations for wave heights
  late List<Animation<double>> _waveAnimations;

  /// Controller for ECG-style wave activation (right to left sweep)
  /// 0 = all flat, 1 = all waves active
  late AnimationController _waveActivationController;

  /// Animation for wave activation sweep
  late Animation<double> _waveActivationAnimation;

  final _random = Random();

  /// Whether the surface has been constructed (ray animation completed at least once)
  /// Once true, stays true until session changes (isActive becomes false)
  bool _surfaceConstructed = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _applyInitialState();
  }

  void _initAnimations() {
    // Ray extension animation (builds the surface)
    _rayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rayAnimation = CurvedAnimation(
      parent: _rayController,
      curve: Curves.easeOutCubic,
    );
    _rayController.addStatusListener(_onRayComplete);

    // Wave controllers (rhythm animation) - amplitude limited to 20%-40%
    _waveControllers = List.generate(widget.waveCount, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + _random.nextInt(200)),
      );
    });

    _waveAnimations = _waveControllers.map((controller) {
      // Amplitude range: 0.2 to 0.4 (20%-40% of max height)
      return Tween<double>(
        begin: 0.2,
        end: 0.4,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    // ECG-style wave activation controller (right to left sweep)
    _waveActivationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _waveActivationAnimation = CurvedAnimation(
      parent: _waveActivationController,
      curve: Curves.easeOutCubic,
    );
  }

  void _applyInitialState() {
    if (widget.isLoading) {
      // First time loading: animate ray
      _rayController.forward();
    } else if (widget.isActive) {
      // Surface already ready (e.g., app started with active playback)
      _surfaceConstructed = true;
      _rayController.value = 1.0;
      if (widget.isPlaying) {
        _waveActivationController.value = 1.0;
        _startWaveAnimations();
      }
    }
  }

  void _onRayComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _surfaceConstructed = true);
      // If already playing, start waves with ECG sweep
      if (widget.isPlaying) {
        _waveActivationController.forward();
        _startWaveAnimations();
      }
    }
  }

  void _startWaveAnimations() {
    for (int i = 0; i < _waveControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 60), () {
        if (mounted && _waveControllers[i].isAnimating == false) {
          _waveControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopWaveAnimations() {
    for (final controller in _waveControllers) {
      controller.stop();
    }
  }

  @override
  void didUpdateWidget(AnimatedWaveBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle loading state - only animate ray if surface not yet constructed
    if (widget.isLoading && !oldWidget.isLoading) {
      if (!_surfaceConstructed) {
        // First time loading this session: animate ray construction
        _rayController.forward(from: 0);
        _waveActivationController.value = 0;
        _stopWaveAnimations();
      }
      // If surface already constructed (pause/resume), skip ray animation
    }

    // Handle session change (isActive becomes false = different session or stopped)
    if (!widget.isActive && oldWidget.isActive && !widget.isLoading) {
      // Session ended or switched: reset surface
      _rayController.reverse();
      _waveActivationController.value = 0;
      _stopWaveAnimations();
      _surfaceConstructed = false; // Reset for next session
    } else if (widget.isActive && !oldWidget.isActive && !widget.isLoading) {
      // Became active without loading (e.g., detected existing playback)
      _surfaceConstructed = true;
      _rayController.value = 1.0;
    }

    // Handle playing state (ECG-style wave activation)
    if (widget.isPlaying && !oldWidget.isPlaying) {
      // Started playing or resumed: ECG sweep from right to left (waves activate)
      if (_surfaceConstructed) {
        // Always start from 0 to ensure visible animation on resume
        _waveActivationController.forward(from: 0);
        _startWaveAnimations();
      } else if (_rayController.value >= 1.0) {
        // Ray finished but state not updated yet
        _surfaceConstructed = true;
        _waveActivationController.forward(from: 0);
        _startWaveAnimations();
      }
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      // Paused: ECG flatline sweep from right to left (waves deactivate)
      // Always start from 1 to ensure visible animation on pause
      _waveActivationController.reverse(from: 1);
      // Don't stop wave controllers - let them run for smooth transition
    }
  }

  @override
  void dispose() {
    _rayController.removeStatusListener(_onRayComplete);
    _rayController.dispose();
    _waveActivationController.dispose();
    for (final controller in _waveControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nothing to show if not active and not loading
    final showSurface =
        widget.isActive || widget.isLoading || _rayController.isAnimating;

    if (!showSurface) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: widget.child,
      );
    }

    final gpuEnabled = ref.watch(gpuAccelerationEnabledProvider);
    final waveColor = widget.color ?? AppTheme.spotifyGreen;

    Widget waveLayer = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        if (width <= 0 || height <= 0 || !width.isFinite || !height.isFinite) {
          return const SizedBox.shrink();
        }

        return AnimatedBuilder(
          animation: Listenable.merge([
            _rayAnimation,
            _waveActivationAnimation,
            ...(_surfaceConstructed ? _waveAnimations : <Animation<double>>[]),
          ]),
          builder: (context, child) {
            return CustomPaint(
              size: Size(width, height),
              painter: _MusicFountainPainter(
                surfaceProgress: _rayAnimation.value,
                waveActivation: _waveActivationAnimation.value,
                waveValues: _surfaceConstructed
                    ? _waveAnimations.map((a) => a.value).toList()
                    : List.filled(widget.waveCount, 0.3),
                color: waveColor,
                heightRatio: widget.heightRatio,
              ),
            );
          },
        );
      },
    );

    // Wrap with RepaintBoundary for GPU acceleration if enabled
    if (gpuEnabled) {
      waveLayer = RepaintBoundary(child: waveLayer);
    }

    // Exclude wave layer from accessibility tree
    waveLayer = ExcludeSemantics(child: waveLayer);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(child: IgnorePointer(child: waveLayer)),
        ],
      ),
    );
  }
}

/// Unified painter for the "music fountain" effect with ECG-style activation
///
/// Combines ray extension, flat line, and wave animation into one painter
/// - surfaceProgress: 0 = ray starting from 50%, 1 = full surface
/// - waveActivation: 0 = all flat, 1 = all waves active (sweeps right to left)
/// - waveValues: individual wave point heights (for rhythm effect, range 0.2-0.4)
class _MusicFountainPainter extends CustomPainter {
  final double surfaceProgress;
  final double waveActivation;
  final List<double> waveValues;
  final Color color;
  final double heightRatio;

  _MusicFountainPainter({
    required this.surfaceProgress,
    required this.waveActivation,
    required this.waveValues,
    required this.color,
    required this.heightRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || surfaceProgress <= 0) return;

    final maxWaveHeight = size.height * heightRatio;
    // Base line position: 0.6 factor gives ~30% average height with heightRatio=0.5
    final baseY = size.height - (maxWaveHeight * 0.6);

    // Calculate surface extent (ray animation)
    // Starts from 50% (middle) and extends to 0% (left edge)
    final rightEdge = size.width;
    final leftEdge = size.width * 0.5 * (1 - surfaceProgress);
    final surfaceWidth = rightEdge - leftEdge;

    if (surfaceWidth <= 0) return;

    // Build wave path
    final path = Path();
    path.moveTo(leftEdge, size.height);

    // Calculate wave points with ECG-style activation (right to left)
    final points = <Offset>[];
    final segmentWidth = surfaceWidth / (waveValues.length - 1);

    for (int i = 0; i < waveValues.length; i++) {
      final x = leftEdge + (i * segmentWidth);

      // Calculate position ratio from right (0) to left (1)
      // Invert index: rightmost point = 0, leftmost = waveValues.length - 1
      final positionFromRight =
          (waveValues.length - 1 - i) / (waveValues.length - 1);

      // ECG-style activation: wave activates from right to left
      // waveActivation 0→1 means activation sweeps from right to left
      // Each point becomes active when waveActivation passes its position
      final pointActivation = (waveActivation * 1.5 - positionFromRight * 0.5)
          .clamp(0.0, 1.0);

      // Wave height is modulated by point activation (ECG effect)
      // waveValues are in range 0.2-0.4, center is 0.3
      final waveOffset =
          (waveValues[i] - 0.3) * maxWaveHeight * pointActivation;
      final y = baseY - waveOffset;
      points.add(Offset(x, y));
    }

    // Draw smooth curve through wave points
    path.lineTo(leftEdge, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    path.lineTo(rightEdge, size.height);
    path.close();

    // Fill gradient
    final fillPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.05),
            ],
          ).createShader(
            Rect.fromLTWH(
              leftEdge,
              baseY - maxWaveHeight,
              surfaceWidth,
              maxWaveHeight + (size.height - baseY),
            ),
          );

    canvas.drawPath(path, fillPaint);

    // Draw surface line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.6)],
      ).createShader(Rect.fromLTWH(leftEdge, baseY - 1, surfaceWidth, 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Draw glow at leading edge during ray animation
    if (surfaceProgress < 1.0) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.4 * (1 - surfaceProgress))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(Offset(leftEdge, points.first.dy), 4, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MusicFountainPainter oldDelegate) {
    if (oldDelegate.surfaceProgress != surfaceProgress ||
        oldDelegate.waveActivation != waveActivation ||
        oldDelegate.color != color) {
      return true;
    }
    if (oldDelegate.waveValues.length != waveValues.length) return true;
    for (int i = 0; i < waveValues.length; i++) {
      if (oldDelegate.waveValues[i] != waveValues[i]) return true;
    }
    return false;
  }
}
