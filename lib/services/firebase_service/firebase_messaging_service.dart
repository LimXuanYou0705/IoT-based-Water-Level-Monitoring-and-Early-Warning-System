import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iot_water_monitor/widgets/danger_alert_widget.dart';

import '../../main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showLocalNotification(message);
}

Future<void> initFirebaseMessaging() async {
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showLocalNotification(message);

    final level = message.data['level'];
    if (1 == 1) {
      final context = navigatorKey.currentState?.overlay?.context;

      if (context != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => DangerAlertWidget(
                  onAcknowledge: () => Navigator.pop(context),
                ),
          ),
        );
      }
    }
  });

  // Handle background/terminated message tap
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Navigate or open full screen dialog here
  });

  // Background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

void _showLocalNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'critical_channel_id',
          'Danger Alerts',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm'),
          fullScreenIntent: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        ),
      ),
    );
  }
}
