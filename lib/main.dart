library;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iot_water_monitor/screens/users/admin/add_incident_type.dart';
import 'package:iot_water_monitor/screens/users/user/achievements.dart';
import 'package:iot_water_monitor/screens/users/user/alert_preference.dart';
import 'package:iot_water_monitor/screens/users/user/leaderboard.dart';
import 'package:iot_water_monitor/screens/users/user/settings.dart';
import 'package:iot_water_monitor/screens/wrapper.dart';
import 'package:iot_water_monitor/services/firebase_service/firebase_messaging_service.dart';
import 'package:iot_water_monitor/test.dart';
import 'package:iot_water_monitor/widgets/danger_alert_widget.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

String? pendingDangerAlertId;
// String? pendingInitialSensorDataId;
// RemoteMessage? initialMessage;

bool isAlertShowing = false;

void showDangerAlert(String sensorDataId) {
  if (isAlertShowing) return;

  final context = navigatorKey.currentState?.overlay?.context;
  if (context != null) {
    isAlertShowing = true;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DangerAlertWidget(
          sensorDataId: sensorDataId,
          onAcknowledge: () {
            Navigator.of(context).pop();
            isAlertShowing = false;
          },
        ),
      ),
    );
  }
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force Portrait Mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Initialize Local Notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create the critical notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'critical_channel_id',
    'Danger Alerts',
    description: 'Critical danger alerts that require immediate attention',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('alarm'),
  );

  final androidImplementation =
  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await androidImplementation?.createNotificationChannel(channel);

  // Initialize Firebase Messaging Listener
  await initFirebaseMessaging();

  // initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  // print('[DEBUG] initialMessage: ${initialMessage?.data}');
  //
  // if (initialMessage != null) {
  //   pendingInitialSensorDataId = initialMessage!.data['sensorDataId'];
  // }

  runApp(const MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Water Monitor',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Color(0xFFF7F8FC), // Light background
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
          surface: Color(0xFFF7F8FC),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black, // Dark background
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          surface: Colors.black,
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const Wrapper(),
        '/settings': (context) => const SettingsScreen(),
        '/setupAlerts': (context) => const SetupAlertScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/addIncidentType': (context) => const AddIncidentTypeScreen(),
        // '/reviewPosts': (context) => const ReviewPostsScreen(),
      },
    );
  }
}