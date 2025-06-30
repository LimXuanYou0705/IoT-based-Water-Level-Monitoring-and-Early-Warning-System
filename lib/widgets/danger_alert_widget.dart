import 'package:flutter/material.dart';

class DangerAlertWidget extends StatelessWidget {
  final VoidCallback onAcknowledge;

  const DangerAlertWidget({super.key, required this.onAcknowledge});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Center(child: AnimatedPulse()),
            Positioned(
              bottom: 30,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: onAcknowledge,
                icon: Icon(Icons.check),
                label: Text("Acknowledge"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedPulse extends StatefulWidget {
  const AnimatedPulse({super.key});

  @override
  State<AnimatedPulse> createState() => _AnimatedPulseState();
}

class _AnimatedPulseState extends State<AnimatedPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(4, (i) {
            double scale = 1.0 + (_controller.value * (i + 1) * 0.2);
            double opacity = 1 - (_controller.value * 0.8);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withAlpha(((opacity / (i + 1)) * 255).round()),
                ),
              ),
            );
          })..add(
            // Red circle with text
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: Center(
                child: Text(
                  "Alert!!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
