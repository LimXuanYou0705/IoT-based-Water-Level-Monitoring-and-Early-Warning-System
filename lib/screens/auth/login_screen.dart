import 'package:flutter/material.dart';
import '../../services/firebase_service/auth_service.dart';
import '../phoneVerify/phone_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  void _handleGoogleSignIn() async {
    try {
      final userCredential = await _authService.signInWithGoogle();

      if (!mounted) return; // If widget is no longer in the tree, stop here.

      if (userCredential != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PhoneVerificationScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Sign in cancelled")));
      }
    } catch (e) {
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
