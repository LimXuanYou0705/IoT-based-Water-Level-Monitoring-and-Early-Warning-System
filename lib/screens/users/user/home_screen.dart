import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_water_monitor/screens/users/user/wave_screen.dart';
import '../../../models/thresholds.dart';
import '../../../services/firebase_service/firebase_service.dart';
import 'home_screen_body.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  HomeScreen({super.key});

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

              return HomeScreenBody(distance: distance, thresholds: thresholds);
            },
          );
        },
      ),
    );
  }
}
