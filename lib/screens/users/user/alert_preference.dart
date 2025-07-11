import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../services/firebase_service/firebase_service.dart';

class SetupAlertScreen extends StatefulWidget {
  const SetupAlertScreen({super.key});

  @override
  State<SetupAlertScreen> createState() => _SetupAlertScreenState();
}

class _SetupAlertScreenState extends State<SetupAlertScreen> {
  final _auth = FirebaseAuth.instance;
  final _firebaseService = FirebaseService();

  bool _loading = true;
  Set<String> _selectedChannels = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        debugPrint('[AlertScreen] No user logged in.');
        return;
      }

      final channels = await _firebaseService.getAlertChannels(uid);

      setState(() {
        _selectedChannels = Set<String>.from(channels);
        _loading = false;
      });

      debugPrint('[AlertScreen] Loaded: $_selectedChannels');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load alert preferences')),
        );
      }
    }
  }

  Future<void> _updatePreference(String key, bool enabled) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final updated = Set<String>.from(_selectedChannels);
      enabled ? updated.add(key) : updated.remove(key);

      setState(() {
        _selectedChannels = updated;
      });

      await _firebaseService.updateAlertChannels(
        uid,
        _selectedChannels.toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? '${_formatKey(key)} enabled.'
                  : '${_formatKey(key)} disabled.',
            ),
            // duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update $key')));
      }
    }
  }

  String _formatKey(String key) {
    switch (key) {
      case 'push':
        return 'Push Notifications';
      case 'sms':
        return 'SMS Alerts';
      case 'email':
        return 'Email Notifications';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Alert Preferences')),
      body: ListView(
        children: [
          _buildSwitchTile('sms', 'SMS / Text Message'),
          _buildSwitchTile('push', 'Mobile Push Notifications / Siren'),
          _buildSwitchTile('email', 'Email Notifications'),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String key, String label) {
    final enabled = _selectedChannels.contains(key);
    return SwitchListTile(
      title: Text(label),
      value: enabled,
      onChanged: (value) => _updatePreference(key, value),
    );
  }
}
