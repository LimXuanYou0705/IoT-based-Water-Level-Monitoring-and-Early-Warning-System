import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/thresholds.dart';

class ThresholdEditScreen extends StatefulWidget {
  const ThresholdEditScreen({super.key});

  @override
  State<ThresholdEditScreen> createState() => _ThresholdEditScreenState();
}

class _ThresholdEditScreenState extends State<ThresholdEditScreen> {
  // Controllers for all text fields
  final _highDangerController = TextEditingController();
  final _highAlertController = TextEditingController();
  final _highSafeController = TextEditingController();

  final _lowDangerController = TextEditingController();
  final _lowAlertController = TextEditingController();
  final _lowSafeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadCurrentThresholds();
  }

  Future<void> _loadCurrentThresholds() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('thresholds')
        .doc('region_settings')
        .get();

    if (snapshot.exists) {
      final thresholds = RegionThresholds.fromMap(snapshot.data()!);

      setState(() {
        _highDangerController.text = thresholds.highRegion.danger.toString();
        _highAlertController.text = thresholds.highRegion.alert.toString();
        _highSafeController.text = thresholds.highRegion.safe.toString();

        _lowDangerController.text = thresholds.lowRegion.danger.toString();
        _lowAlertController.text = thresholds.lowRegion.alert.toString();
        _lowSafeController.text = thresholds.lowRegion.safe.toString();
      });
    }
  }

  void _saveThresholds() {
    if (!_formKey.currentState!.validate()) return;

    final regionThresholds = RegionThresholds(
      highRegion: Thresholds(
        danger: double.parse(_highDangerController.text),
        alert: double.parse(_highAlertController.text),
        safe: double.parse(_highSafeController.text),
      ),
      lowRegion: Thresholds(
        danger: double.parse(_lowDangerController.text),
        alert: double.parse(_lowAlertController.text),
        safe: double.parse(_lowSafeController.text),
      ),
    );

    // Save to Firestore
    FirebaseFirestore.instance
        .collection('thresholds')
        .doc('region_settings')
        .set(regionThresholds.toMap())
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Thresholds')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'High Region',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildTextField(_highDangerController, 'High Danger Threshold'),
              _buildTextField(_highAlertController, 'High Alert Threshold'),
              _buildTextField(_highSafeController, 'High Safe Threshold'),

              const SizedBox(height: 24),

              const Text(
                'Low Region',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildTextField(_lowDangerController, 'Low Danger Threshold'),
              _buildTextField(_lowAlertController, 'Low Alert Threshold'),
              _buildTextField(_lowSafeController, 'Low Safe Threshold'),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveThresholds,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (value == null || value.isEmpty) return '$label is required';
          if (double.tryParse(value) == null) return 'Enter a valid number';
          return null;
        },
      ),
    );
  }
}