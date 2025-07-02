import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Reference to the 'alerts' collection in Firestore
final CollectionReference _alertsCollection = FirebaseFirestore.instance.collection('alerts');

/// Updates all documents in the 'alerts' collection.
/// It adds a new field 'resolvedAt' with a null value
/// for every document in the collection.
Future<void> addResolvedAtFieldToAlerts() async {
  print('Starting migration: Adding "resolvedAt: null" to ALL alerts records...');

  try {
    // Query for all documents in the 'alerts' collection
    final QuerySnapshot snapshot = await _alertsCollection.get();

    if (snapshot.docs.isEmpty) {
      print('No alerts records found to update.');
      return;
    }

    const int batchSize = 400; // Firestore recommends batch sizes of 500 maximum
    int processedCount = 0;
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (int i = 0; i < snapshot.docs.length; i++) {
      final DocumentSnapshot doc = snapshot.docs[i];
      final DocumentReference docRef = doc.reference;

      // Update the document to set 'resolvedAt' to null.
      // If this field doesn't exist, it will be created.
      // If it exists, its value will be updated to null.
      batch.update(docRef, {'resolvedAt': null});

      // Commit the batch periodically to avoid exceeding batch size limits
      if ((i + 1) % batchSize == 0 || (i + 1) == snapshot.docs.length) {
        await batch.commit();
        processedCount += ((i + 1) % batchSize == 0) ? batchSize : (snapshot.docs.length % batchSize == 0 ? batchSize : snapshot.docs.length % batchSize);
        print('Committed batch. Processed $processedCount of ${snapshot.docs.length} documents.');

        // Start a new batch for the next set of documents
        batch = FirebaseFirestore.instance.batch();
      }
    }

    print('Migration complete: Successfully added "resolvedAt: null" for all ${snapshot.docs.length} alerts records.');

  } catch (e) {
    print('Error during migration: $e');
    rethrow; // Re-throw the error so it can be caught by the UI
  }
}

/// A Flutter screen to trigger and display the status of the data migration.
class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  bool _isMigrating = false; // Controls button state during migration
  String _migrationStatus = "Ready to run migration."; // Displays current status

  /// Initiates the data migration process.
  void _runMigration() async {
    setState(() {
      _isMigrating = true;
      _migrationStatus = "Migration in progress...";
    });

    try {
      await addResolvedAtFieldToAlerts(); // Call the updated migration function
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
        title: const Text('Alerts Data Migration Tool'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'This tool will add a new field "resolvedAt" with a null value to ALL existing alert records in your Firestore "alerts" collection. This is typically a one-time operation.',
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
                'WARNING: This operation directly modifies your database. It will add/update the "resolvedAt" field for ALL documents in the "alerts" collection. Please ensure you have backed up your data and understand the implications before proceeding, especially in a production environment.',
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
