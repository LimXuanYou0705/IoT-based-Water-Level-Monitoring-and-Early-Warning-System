import 'package:flutter/material.dart';
import '../../services/firebase_service/auth_service.dart';
import '../../services/firebase_service/firebase_service.dart';
import '../loading/loading_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  BuildContext? dialogContext; // store dialog context

  void _handleGoogleSignIn() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          dialogContext = ctx;
          return const LoadingScreen(message: "Signing in");
        },
      );
      print("Signing in with Google...");
      final userCredential = await _authService.signInWithGoogle();

      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
      }

      if (userCredential == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Sign in cancelled")));
      } else {
        final userId = userCredential.user?.uid;
        if (userId != null) {
          await _firebaseService.saveFcmToken(userId);
          print("FCM token saved for $userId");
        }
      }
    } catch (e) {
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _handleGoogleSignIn,
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
