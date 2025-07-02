import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iot_water_monitor/widgets/danger_alert_widget.dart';
import '../../main.dart';
import 'package:iot_water_monitor/main.dart' as main;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  _showLocalNotification(message);
}

Future<void> initFirebaseMessaging() async {
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showLocalNotification(message);

    final level = message.data['level'];
    final sensorDataId = message.data['sensorDataId'];

    if (level == 'DANGER') {
      main.pendingDangerAlertId = sensorDataId;

      final context = navigatorKey.currentState?.overlay?.context;

      if (context != null) {
        showDangerAlert(sensorDataId);
      }
    }
  });

  // Handle background/terminated message tap
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print('[onMessageOpenedApp] Triggered');
    await handleInitialMessage(message);
  });

  // Background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

void _showLocalNotification(RemoteMessage message) {
  final level = message.data['level'];
  final notification = message.notification;
  final android = message.notification?.android;

  if (notification != null && android != null) {
    String channelId = 'default_channel';
    Importance importance = Importance.defaultImportance;
    Priority priority = Priority.defaultPriority;
    RawResourceAndroidNotificationSound? sound;

    if (level == 'DANGER') {
      channelId = 'critical_channel_id';
      importance = Importance.max;
      priority = Priority.high;
      sound = RawResourceAndroidNotificationSound('alarm');
    } else if (level == 'ALERT') {
      channelId = 'default_channel';
      importance = Importance.high;
      priority = Priority.high;
      sound = RawResourceAndroidNotificationSound('pop');
    }

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Water Alerts',
          importance: importance,
          priority: priority,
          playSound: sound != null,
          sound: sound,
          fullScreenIntent: level == 'DANGER',
          enableVibration: true,
          visibility: NotificationVisibility.public,
        ),
      ),
    );
  }
}

Future<void> handleInitialMessage(RemoteMessage message) async {
  final data = message.data;
  final sensorDataId = data['sensorDataId'];

  if (sensorDataId == null) return;

  pendingDangerAlertId = sensorDataId;

  final snapshot =
      await FirebaseFirestore.instance
          .collection('alerts')
          .where('sensorDataId', isEqualTo: sensorDataId)
          .limit(1)
          .get();

  if (snapshot.docs.isNotEmpty) {
    final doc = snapshot.docs.first;
    final acknowledged = doc['acknowledged'] == true;

    if (acknowledged) {
      print('Alert $sensorDataId already acknowledged. Skipping popup.');
      return;
    }
  }

  final context = navigatorKey.currentState?.overlay?.context;
  if (context != null) {
    showDangerAlert(sensorDataId);
  }
}

Future<void> checkUnacknowledgedAlerts() async {
  final now = DateTime.now();
  final cutoff = now.subtract(const Duration(minutes: 15));

  final snapshot =
      await FirebaseFirestore.instance
          .collection('alerts')
          .where('acknowledged', isEqualTo: false)
          .where('alertLevel', isEqualTo: 'DANGER')
          .where('methods.push.sent', isEqualTo: true)
          .where('methods.push.acknowledged', isEqualTo: null)
          .where('methods.push.sentAt', isGreaterThan: cutoff)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

  if (snapshot.docs.isNotEmpty) {
    final doc = snapshot.docs.first;
    final sensorDataId = doc['sensorDataId'];

    final context = navigatorKey.currentState?.overlay?.context;
    if (context != null) {
      showDangerAlert(sensorDataId);
    }
  }
}
