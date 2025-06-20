import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iot_water_monitor/screens/home/customer_navigator.dart';
import 'package:iot_water_monitor/screens/phoneVerify/phone_verification_screen.dart';
import 'package:iot_water_monitor/screens/splash/splash_screen.dart';
import 'auth/login_screen.dart';
import 'home/admin_navigator.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Auth state stream
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (Navigator.canPop(context)) Navigator.of(context).pop();

        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        final user = authSnapshot.data!;

        // Convert Firestore user document into a Stream
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (Navigator.canPop(context)) Navigator.of(context).pop();

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const PhoneVerificationScreen();
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>;
            final String role = data['role'];

            if (role == 'admin') {
              return const AdminNavigator();
            } else {
              return const CustomerNavigator();
            }
          },
        );
      },
    );
  }
}
