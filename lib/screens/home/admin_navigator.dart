import 'package:flutter/material.dart';

class AdminNavigator extends StatelessWidget {
  const AdminNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Admin Screen",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
