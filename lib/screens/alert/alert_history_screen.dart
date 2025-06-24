import 'package:flutter/material.dart';

import '../../helper/date_helper.dart';
import '../../models/sensor_data.dart';
import '../../services/firebase_service/firebase_service.dart';

class AlertHistoryScreen extends StatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  final _firebaseService = FirebaseService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseService().markAllAlertsAsSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alert History'), centerTitle: true),
      body: StreamBuilder<List<SensorData>>(
        stream: _firebaseService.getAlertHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final alerts = snapshot.data ?? [];

          if (alerts.isEmpty) {
            return const Center(child: Text('No alerts found.'));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];

              Color iconColor;
              IconData iconData;

              switch (alert.level) {
                case 'DANGER':
                  iconColor = Colors.red;
                  iconData = Icons.warning;
                  break;
                case 'ALERT':
                  iconColor = Colors.orange;
                  iconData = Icons.error_outline;
                  break;
                default:
                  iconColor = Colors.grey;
                  iconData = Icons.info_outline;
              }

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(iconData, color: iconColor),
                  title: Text(
                    '${alert.level} - ${alert.distance.toStringAsFixed(2)} cm',
                  ),
                  subtitle: Text(
                    alert.timestamp != null
                        ? formatTimestamp(alert.timestamp)
                        : 'No timestamp',
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
