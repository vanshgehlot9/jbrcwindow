import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _handleRelay(message.data);
}

final FlutterLocalNotificationsPlugin local = FlutterLocalNotificationsPlugin();

const String kChannelId = 'high_importance';
const String kChannelName = 'High Importance Notifications';

Future<void> initNotifications() async {
  await Firebase.initializeApp();

  // iOS + general Firebase notification permission dialog
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // ANDROID 13+: request runtime POST_NOTIFICATIONS using permission_handler
  if (Platform.isAndroid) {
    await Permission.notification.request();
  }

  // Create Android notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    kChannelId,
    kChannelName,
    description: 'Used for important alerts.',
    importance: Importance.high,
  );
  await local
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // Initialize local notifications
  const InitializationSettings initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await local.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
      // Handle notification taps or action buttons if you add them later
      // final payload = response.payload;
    },
  );

  // Background handler for data-only messages
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Foreground messages
  FirebaseMessaging.onMessage.listen((message) async {
    await _showWhenForeground(message);
    await _handleRelay(message.data);
  });

  // App opened from notification
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    // Handle deep links / navigation if needed
  });

  // Optional: get and send token to your backend
  // final token = await FirebaseMessaging.instance.getToken();
  // debugPrint('FCM token: $token');
}

Future<void> _showWhenForeground(RemoteMessage m) async {
  final n = m.notification;
  final data = m.data;
  final title = n?.title ?? data['title'] ?? 'VOR';
  final body = n?.body ?? data['body'] ?? 'You have an update';

  const android = AndroidNotificationDetails(
    kChannelId,
    kChannelName,
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker',
  );

  await local.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    const NotificationDetails(
      android: android,
      iOS: DarwinNotificationDetails(),
    ),
    payload: data['payload'],
  );
}

Future<void> _handleRelay(Map<String, dynamic> data) async {
  if (data['type'] == 'relay' && data['command'] != null) {
    final cmd = data['command'] as String;

    // TODO: verify signature/HMAC before executing any sensitive action
    switch (cmd) {
      case 'RELAY_ON':
        // TODO: call your API / update device state
        break;
      case 'RELAY_OFF':
        // TODO: call your API / update device state
        break;
      default:
        break;
    }

    await local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Relay',
      'Executed: $cmd',
      const NotificationDetails(
        android: AndroidNotificationDetails(kChannelId, kChannelName),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
