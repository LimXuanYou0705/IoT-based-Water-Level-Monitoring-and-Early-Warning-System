import 'package:flutter/material.dart';
import 'package:iot_water_monitor/services/firebase_service/firebase_service.dart';

import '../../helper/date_helper.dart';
import '../../models/sensor_data.dart';

class SensorDataScreen extends StatelessWidget {
  final FirebaseService firestoreService = FirebaseService();

  SensorDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data'),
      ),
      body: StreamBuilder<List<SensorData>>(
        stream: firestoreService.getSensorData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final sensorDataList = snapshot.data ?? [];

          if (sensorDataList.isEmpty) {
            return Center(child: Text('No sensor data found.'));
          }

          return ListView.builder(
            itemCount: sensorDataList.length,
            itemBuilder: (context, index) {
              final sensorData = sensorDataList[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Distance: ${sensorData.distance}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Danger: ${sensorData.level}'),
                      Text(
                        'Timestamp: ${formatTimestamp(sensorData.timestamp)}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}