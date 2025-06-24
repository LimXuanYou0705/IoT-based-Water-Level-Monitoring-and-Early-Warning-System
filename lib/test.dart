import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final CollectionReference _sensorDataCollection = FirebaseFirestore.instance.collection('sensorData');

Future<void> addSeenFieldToAllRecords() async {
  print('Starting migration: Adding "seen: false" to all sensor data records...');

  try {
    final QuerySnapshot snapshot = await _sensorDataCollection.get();

    if (snapshot.docs.isEmpty) {
      print('No sensor data records found to update.');
      return;
    }

    const int batchSize = 400;
    int processedCount = 0;
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (int i = 0; i < snapshot.docs.length; i++) {
      final DocumentSnapshot doc = snapshot.docs[i];
      final DocumentReference docRef = doc.reference;

      batch.update(docRef, {'seen': false});

      if ((i + 1) % batchSize == 0 || (i + 1) == snapshot.docs.length) {
        await batch.commit();
        processedCount += (i + 1) % batchSize == 0 ? batchSize : (i + 1) % batchSize;
        print('Committed batch. Processed $processedCount of ${snapshot.docs.length} documents.');

        batch = FirebaseFirestore.instance.batch();
      }
    }

    print('Migration complete: Successfully added "seen: false" to all ${snapshot.docs.length} records.');

  } catch (e) {
    print('Error during migration: $e');
  }
}

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  bool _isMigrating = false; // To disable the button during migration
  String _migrationStatus = "Ready to run migration."; // To display status

  void _runMigration() async {
    setState(() {
      _isMigrating = true;
      _migrationStatus = "Migration in progress...";
    });

    try {
      await addSeenFieldToAllRecords();
      setState(() {
        _migrationStatus = "Migration completed successfully!";
      });
    } catch (e) {
      setState(() {
        _migrationStatus = "Migration failed: $e";
      });
    } finally {
      setState(() {
        _isMigrating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Migration Tool'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'This tool will add a "seen: false" field to all existing sensor data records in your Firestore collection. This is typically a one-time operation.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isMigrating ? null : _runMigration, // Disable button while migrating
                icon: _isMigrating
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.play_arrow),
                label: Text(_isMigrating ? 'Running...' : 'Run Data Migration'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _migrationStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _migrationStatus.contains('failed') ? Colors.red : (_migrationStatus.contains('completed') ? Colors.green : Colors.black87),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'WARNING: This operation directly modifies your database. Please ensure you have backed up your data and understand the implications before proceeding, especially in a production environment.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}