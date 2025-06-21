import 'package:flutter/material.dart';
import 'package:iot_water_monitor/screens/users/user/wave_screen.dart';

import '../../../services/firebase_service/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Text(
                'Real-Time Water Level',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              StreamBuilder<double>(
                stream: _firebaseService.getLatestWaterLevel(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final distance = snapshot.data!;
                  final normalizedLevel = normalize(distance, 20, 70);

                  return WaveWidget(height: 450, level: normalizedLevel);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  double normalize(double distance, double min, double max) {
    return ((max - distance) / (max - min)).clamp(0.0, 1.0);
  }
}
