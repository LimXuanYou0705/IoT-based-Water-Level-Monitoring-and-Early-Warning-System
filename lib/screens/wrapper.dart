import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iot_water_monitor/screens/home/customer_navigator.dart';
import 'package:iot_water_monitor/screens/phoneVerify/phone_verification_screen.dart';
import 'package:iot_water_monitor/screens/splash/splash_screen.dart';
import 'auth/login_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // listen to live changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasData) {
          // logged-in
          User? user = snapshot.data;

          if (user!.phoneNumber == null) {
            return const PhoneVerificationScreen();
          } else {
            return const CustomerNavigator();
          }
        } else {
          // Not logged-in
          return const LoginScreen();
        }
      },
    );
  }
}
