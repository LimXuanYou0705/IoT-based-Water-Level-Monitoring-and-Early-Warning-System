import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_water_monitor/screens/users/user/wave_screen.dart';

import '../../../models/thresholds.dart';

class HomeScreenBody extends StatefulWidget {
  final double distance;
  final Thresholds thresholds;

  const HomeScreenBody({
    super.key,
    required this.distance,
    required this.thresholds,
  });

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  double normalize(double distance, double min, double max) {
    if (max - min == 0) return 0.0;
    return ((max - distance) / (max - min)).clamp(0.0, 1.0);
  }

  Widget _buildIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildThresholdLabels(Thresholds thresholds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIndicator(
          "DANGER ≤ ${thresholds.danger.toStringAsFixed(1)} cm",
          Colors.red,
        ),
        const SizedBox(height: 6),
        _buildIndicator(
          "ALERT ≤ ${thresholds.alert.toStringAsFixed(1)} cm",
          Colors.orange,
        ),
        const SizedBox(height: 6),
        _buildIndicator(
          "SAFE ≥ ${thresholds.safe.toStringAsFixed(1)} cm",
          Colors.green,
        ),
      ],
    );
  }

  String getStatus(double distance, Thresholds thresholds) {
    if (distance <= thresholds.danger) {
      return "DANGER";
    } else if (distance <= thresholds.alert) {
      return "ALERT";
    } else {
      return "SAFE";
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "DANGER":
        return Colors.red;
      case "ALERT":
        return Colors.orange;
      case "SAFE":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedLevel = normalize(
      widget.distance,
      20,
      widget.thresholds.safe,
    );

    final status = getStatus(widget.distance, widget.thresholds);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Text(
            'Real-Time Water Level',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sensor Status: Online',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Water Level: ${widget.distance.toStringAsFixed(2)} cm',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Status: $status',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              WaveWidget(height: 450, level: normalizedLevel),
              Positioned(
                top: 12,
                left: 12,
                child: _buildThresholdLabels(widget.thresholds),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
