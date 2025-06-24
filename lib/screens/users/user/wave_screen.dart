import 'dart:math';
import 'package:flutter/material.dart';

class WaveWidget extends StatefulWidget {
  const WaveWidget({super.key, required this.level, this.height = 120});

  final double level;
  final double height;

  @override
  State<WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _levelController;
  late Animation<double> _levelAnimation;
  late DateTime _startTime;

  double _currentLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Controller for continuous wave animation
    _waveController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Controller for level transitions
    _levelController = AnimationController(
      duration: Duration(milliseconds: 800), // Adjust transition duration
      vsync: this,
    );

    // Initialize current level
    _currentLevel = widget.level;
    _levelAnimation = Tween<double>(
      begin: _currentLevel,
      end: widget.level,
    ).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.easeInOut, // Smooth transition curve
    ));
  }

  @override
  void didUpdateWidget(WaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate to new level when widget.level changes
    if (oldWidget.level != widget.level) {
      _levelAnimation = Tween<double>(
        begin: _currentLevel,
        end: widget.level,
      ).animate(CurvedAnimation(
        parent: _levelController,
        curve: Curves.easeInOut,
      ));

      _levelController.forward(from: 0.0).then((_) {
        _currentLevel = widget.level;
      });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: Listenable.merge([_waveController, _levelAnimation]),
        builder: (context, _) {
          // Calculate continuous time since start
          final elapsed = DateTime.now().difference(_startTime).inMilliseconds / 1000.0;

          // Use animated level value for smooth transitions
          final animatedLevel = _levelAnimation.value;

          return CustomPaint(
            painter: MultiWavePainter(elapsed, animatedLevel),
          );
        },
      ),
    );
  }
}

class MultiWavePainter extends CustomPainter {
  final double elapsedTime;
  final double level;

  MultiWavePainter(this.elapsedTime, this.level);

  @override
  void paint(Canvas canvas, Size size) {
    double baseOffset = size.height * (1 - level);

    _drawWave(
      canvas,
      size,
      color: Color(0xFF2496FF).withAlpha(90),
      waveHeight: 8,
      speed: 1.4,
      yOffset: baseOffset,
    );

    _drawWave(
      canvas,
      size,
      color: Color(0xFF2496FF).withAlpha(128),
      waveHeight: 6,
      speed: -1.2,
      yOffset: baseOffset + 2,
    );
  }

  void _drawWave(Canvas canvas, Size size,
      {required Color color,
        required double waveHeight,
        required double speed,
        required double yOffset}) {
    final paint = Paint()..color = color;
    final path = Path();

    double waveLength = size.width;
    double fullCycle = 2 * pi;

    // Use elapsed time directly for continuous phase calculation
    double continuousPhase = elapsedTime * 2 * pi * speed / 3.0;

    path.moveTo(0, yOffset);

    for (double x = 0; x <= size.width; x++) {
      double y = sin((x / waveLength * fullCycle) + continuousPhase) * waveHeight;
      path.lineTo(x, y + yOffset);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MultiWavePainter oldDelegate) =>
      oldDelegate.elapsedTime != elapsedTime || oldDelegate.level != level;
}