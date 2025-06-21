import 'dart:math';
import 'package:flutter/material.dart';

class WaveWidget extends StatefulWidget {
  const WaveWidget({super.key, this.height = 120});

  final double height;

  @override
  State<WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // Calculate continuous time since start
          final elapsed = DateTime.now().difference(_startTime).inMilliseconds / 1000.0;
          return CustomPaint(
            painter: MultiWavePainter(elapsed),
          );
        },
      ),
    );
  }
}

class MultiWavePainter extends CustomPainter {
  final double elapsedTime;
  MultiWavePainter(this.elapsedTime);

  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(
      canvas,
      size,
      color: Colors.blue[100]!,
      waveHeight: 19,
      speed: 1.1,
      yOffset: size.height * 0.6,
    );

    _drawWave(
      canvas,
      size,
      color: Colors.blue[200]!,
      waveHeight: 20,
      speed: -1.2,
      yOffset: size.height * 0.62,
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
    double continuousPhase = elapsedTime * 2 * pi * speed / 3.0; // Divide by 3 to match original 3-second cycle

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
      oldDelegate.elapsedTime != elapsedTime;

}