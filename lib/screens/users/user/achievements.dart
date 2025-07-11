import 'package:flutter/material.dart';

class AchievementsScreen extends StatefulWidget {

  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();

}

class _AchievementsScreenState extends State<AchievementsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: const Center(
        child: Text('Achievements Screen'),
      ),
    );
  }
}