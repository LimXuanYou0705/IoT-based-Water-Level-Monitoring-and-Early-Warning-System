import 'package:flutter/material.dart';
import 'package:iot_water_monitor/screens/users/user/wave_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Text('Real-Time Water Level', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              const SizedBox(height: 20),
              WaveWidget(height: 450),
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}