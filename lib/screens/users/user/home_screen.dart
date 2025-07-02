import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_water_monitor/screens/users/user/wave_screen.dart';
import '../../../models/thresholds.dart';
import '../../../services/firebase_service/firebase_service.dart';
import 'home_screen_body.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  DateTime currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 60), (_) {
      if (mounted) {
        setState(() {
          currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<double>(
        stream: _firebaseService.getLatestWaterLevel(),
        builder: (context, distanceSnapshot) {
          if (!distanceSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final distance = distanceSnapshot.data!;

          return StreamBuilder<Thresholds>(
            stream: _firebaseService.getThresholds(),
            builder: (context, thresholdSnapshot) {
              if (!thresholdSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final thresholds = thresholdSnapshot.data!;

              return StreamBuilder<bool>(
                stream: _firebaseService.getSensorStatus(),
                builder: (context, sensorStatusSnapshot) {
                  final sensorStatus = sensorStatusSnapshot.data ?? false;

                  return HomeScreenBody(
                    distance: distance,
                    thresholds: thresholds,
                    currentTime: currentTime,
                    sensorStatus: sensorStatus ? 'Online' : 'Offline',
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
