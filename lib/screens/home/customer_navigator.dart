import 'package:flutter/material.dart';
import 'package:iot_water_monitor/screens/users/user/home_screen.dart';
import 'package:iot_water_monitor/screens/users/user/profile_screen.dart';

class CustomerNavigator extends StatefulWidget {
  const CustomerNavigator({super.key});

  @override
  State<CustomerNavigator> createState() => _CustomerNavigatorState();
}

class _CustomerNavigatorState extends State<CustomerNavigator> {
  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        elevation:0,
        title: Text(_title[_selectedIndex]),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 1,
            color: Theme.of(context).colorScheme.outline,
          ),
          Theme(
            data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  labelTextStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 10),
                  ),
                  height: MediaQuery.of(context).size.height * 0.07,
                )
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

  final _title =[
    "Home",
    "Profile"
  ];

  final _pages = [
    const HomeScreen(),
    const ProfileScreen(),
  ];

  final _navBarItems = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined, size: 20,),
      selectedIcon: Icon(Icons.home, size: 20),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Icons.person_outline_rounded, size: 20,),
      selectedIcon: Icon(Icons.person_rounded, size: 20,),
      label: 'Profile',
    ),
  ];
}
