import 'package:flutter/material.dart';

import '../wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Wrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: 220,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(
                            77,
                          ), // Shadow color (semi-transparent black)
                          spreadRadius: 2, // How far the shadow spreads
                          blurRadius: 5, // How blurry the shadow is
                          offset: const Offset(3, 5),
                        ),
                      ],
                    ),
                    child: Image.asset("assets/images/poseidon_guard1.png"),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Flood Monitoring",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF36B6FD),
                    fontFamily: 'Arial',
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 2), // Spacing between main text and subtitle

                // Subtitle: "Early Warning System"
                Text(
                  "Early Warning\nSystem",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF36B6FD),
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 20),

                const SizedBox(
                  width: 210,
                  height: 12,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF36B6FD),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(23)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



