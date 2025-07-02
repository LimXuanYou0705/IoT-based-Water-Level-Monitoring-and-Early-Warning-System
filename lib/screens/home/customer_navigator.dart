import 'package:flutter/material.dart';
import 'package:iot_water_monitor/screens/users/user/community_screen.dart';
import 'package:iot_water_monitor/screens/users/user/home_screen.dart';
import 'package:iot_water_monitor/screens/users/user/profile_screen.dart';
import '../../main.dart';
import '../../services/firebase_service/firebase_messaging_service.dart';
import '../../services/firebase_service/firebase_service.dart';
import '../alert/alert_history_screen.dart';
import '../alert/sensor_data_screen.dart';

class CustomerNavigator extends StatefulWidget {
  final String? initialAlertSensorDataId;
  const CustomerNavigator({super.key, this.initialAlertSensorDataId});

  @override
  State<CustomerNavigator> createState() => _CustomerNavigatorState();
}

class _CustomerNavigatorState extends State<CustomerNavigator> with WidgetsBindingObserver {
  final _firebaseService = FirebaseService();
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (pendingDangerAlertId != null) {
      Future.delayed(Duration.zero, () {
        showDangerAlert(pendingDangerAlertId!);
        pendingDangerAlertId = null;
      });
    }

    _pages = [
      HomeScreen(),
      SensorDataScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This runs when app goes to/resumes from background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("LIFECYCLE STATE: $state");
    if (state == AppLifecycleState.resumed) {
      checkUnacknowledgedAlerts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(_title[_selectedIndex]),
        centerTitle: true,
        actions: [
          StreamBuilder<int>(
            stream: _firebaseService.getUnseenAlertCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;

              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: Color(0xFFFAB005),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AlertHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD32F2F),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(height: 1, color: Theme.of(context).colorScheme.outline),
          Theme(
            data: Theme.of(context).copyWith(
              navigationBarTheme: NavigationBarThemeData(
                labelTextStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 10),
                ),
                height: MediaQuery.of(context).size.height * 0.1,
              ),
            ),
            child: NavigationBar(
              indicatorColor: Theme.of(context).colorScheme.secondary,
              animationDuration: const Duration(seconds: 1),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: _navBarItems,
            ),
          ),
        ],
      ),
    );
  }

  final _title = ["Home", "Community", "Profile"];

  // final _pages = [
  //   const HomeScreen(),
  //   SensorDataScreen(),
  //   const ProfileScreen(),
  // ];

  final _navBarItems = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined, size: 20),
      selectedIcon: Icon(Icons.home, size: 20),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Icons.people_alt_outlined, size: 20),
      selectedIcon: Icon(Icons.people_alt, size: 20),
      label: 'Community',
    ),
    const NavigationDestination(
      icon: Icon(Icons.person_outline_rounded, size: 20),
      selectedIcon: Icon(Icons.person_rounded, size: 20),
      label: 'Profile',
    ),
  ];
}
