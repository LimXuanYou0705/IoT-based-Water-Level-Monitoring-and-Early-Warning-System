import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iot_water_monitor/screens/home/customer_navigator.dart';
import 'package:iot_water_monitor/screens/phoneVerify/phone_verification_screen.dart';
import 'package:iot_water_monitor/screens/splash/splash_screen.dart';
import '../main.dart';
import 'auth/login_screen.dart';
import 'home/admin_navigator.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _delayFinished = false;

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  void _startDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _delayFinished = true;
      });
    }
  }

  Future<void> checkDangerAlertAtStartup() async {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(minutes: 15));

    final snapshot = await FirebaseFirestore.instance
        .collection('alerts')
        .where('acknowledged', isEqualTo: false)
        .where('alertLevel', isEqualTo: 'DANGER')
        .where('methods.push.sent', isEqualTo: true)
        .where('methods.push.acknowledged', isEqualTo: null)
        .where('methods.push.sentAt', isGreaterThan: cutoff)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      pendingDangerAlertId = snapshot.docs.first.id;
      print("Startup: Unacknowledged danger alert found: $pendingDangerAlertId");
    } else {
      print("No recent danger alert found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (!_delayFinished ||
            authSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = authSnapshot.data;

        if (user == null) return const LoginScreen();

        return StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
          builder: (context, userSnapshot) {
            if (!_delayFinished ||
                userSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const PhoneVerificationScreen();
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>;
            final role = data['role'];

            if (role == 'admin') {
              return const AdminNavigator();
            } else {
              // Run alert check before showing CustomerNavigator
              return FutureBuilder(
                  future: checkDangerAlertAtStartup(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SplashScreen();
                    }

                    return const CustomerNavigator();
                  }
              );
            }
          },
        );
      },
    );
  }
}
