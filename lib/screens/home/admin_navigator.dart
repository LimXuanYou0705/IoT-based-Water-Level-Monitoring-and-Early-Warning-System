import 'package:flutter/material.dart';
import 'package:iot_water_monitor/screens/users/admin/community.dart';
import 'package:iot_water_monitor/screens/users/user/community_screen.dart';
import 'package:iot_water_monitor/screens/users/user/home_screen.dart';
import 'package:iot_water_monitor/screens/users/user/profile_screen.dart';
import '../../main.dart';
import '../../services/firebase_service/firebase_messaging_service.dart';
import '../../services/firebase_service/firebase_service.dart';
import '../alert/alert_history_screen.dart';
import '../alert/sensor_data_screen.dart';

class AdminNavigator extends StatefulWidget {
  final String? initialAlertSensorDataId;
  const AdminNavigator({super.key, this.initialAlertSensorDataId});

  @override
  State<AdminNavigator> createState() => _AdminNavigatorState();
}

class _AdminNavigatorState extends State<AdminNavigator>
    with WidgetsBindingObserver {
  final _firebaseService = FirebaseService();
  int _selectedIndex = 0;
  late List<Widget> _pages;
  final List<String> _titles = ["Home", "Community Management", "Profile"];
  final List<NavigationDestination> _navItems = [
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

    // Setup bottom nav pages
    _pages = [HomeScreen(), const Community(), const ProfileScreen()];
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
      appBar: _buildAppBar(),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0.0,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Text(_titles[_selectedIndex]),
      centerTitle: true,
      actions: [_buildNotificationIcon()],
    );
  }

  Widget _buildNotificationIcon() {
    return StreamBuilder<int>(
      stream: _firebaseService.getUnseenAlertCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return Stack(
          children: [
            IconButton(
              onPressed:
                  () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlertHistoryScreen(),
                ),
              ),
              icon: Icon(Icons.notifications, color: const Color(0xFFFAB005)),
            ),
            if (count > 0)
              Positioned(right: 8, top: 8, child: _buildBadge(count)),
          ],
        );
      },
    );
  }

  Widget _buildBadge(int count) {
    final displayCount = count > 99 ? '99+' : '$count';

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Color(0xFFD32F2F),
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Center(
        child: Text(
          displayCount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow:[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            )
          ]
      ),
      child: NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: Theme.of(context).colorScheme.secondary.withAlpha((255 * 0.3).round()),
          elevation: 0,
          height: MediaQuery.of(context).size.height * 0.09,
          animationDuration: const Duration(milliseconds: 300),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: _navItems
      ),
    );
  }
}
