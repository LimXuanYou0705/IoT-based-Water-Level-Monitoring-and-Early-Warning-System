import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class DangerAlertWidget extends StatefulWidget {
  final String sensorDataId;
  final VoidCallback onAcknowledge;

  const DangerAlertWidget({
    super.key,
    required this.sensorDataId,
    required this.onAcknowledge,
  });

  @override
  State<DangerAlertWidget> createState() => _DangerAlertWidgetState();
}

class _DangerAlertWidgetState extends State<DangerAlertWidget> {
  bool _loading = true;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    playAlarmSound();
    startVibration();
    _checkAcknowledgement();
  }

  Future<void> playAlarmSound() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('sounds/alarm.mp3'));
  }

  Future<void> stopAlarmSound() async {
    await _player.stop();
  }

  Future<void> startVibration() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
    }
  }

  Future<void> stopVibration() async {
    if (await Vibration.hasVibrator()) {
      Vibration.cancel();
    }
  }

  Future<void> _checkAcknowledgement() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('alerts')
        .where('sensorDataId', isEqualTo: widget.sensorDataId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final alert = snapshot.docs.first;
      final data = alert.data();
      final acknowledged = data['acknowledged'] == true;

      if (acknowledged) {
        Navigator.of(context).pop();
        return;
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _acknowledgeAlert() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('alerts')
        .where('sensorDataId', isEqualTo: widget.sensorDataId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final docRef = snapshot.docs.first.reference;
      await docRef.update({
        'acknowledged': true,
        'acknowledgedAt': FieldValue.serverTimestamp(),
        'methods.push.acknowledged': true,
      });
    }

    await stopAlarmSound();
    await stopVibration();

    widget.onAcknowledge();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
                  onPressed: _acknowledgeAlert,
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
