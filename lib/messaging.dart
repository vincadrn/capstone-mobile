import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'backend.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io' show Platform;

class ClientFCM {
  static Future<void> setupToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _saveTokenToDatabase(token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToDatabase);
  }

  static Future<void> _saveTokenToDatabase(String token) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    final prefs = await SharedPreferences.getInstance();
    final willBeNotified = (prefs.getBool('notified') ?? false);

    String url = '${Backend.getHost()}/api/token';
    Map<String, String> data = {
      'token': token,
      'device_name': androidInfo.id,
      'will_be_notified': willBeNotified.toString(),
    };
    final res = await http.post(Uri.parse(url), body: jsonEncode(data));

    if (res.statusCode != 200) {
      throw Exception("Failed to post data!");
    }
  }

  static Future<void> initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // This is to show foreground notifications
    // applicable only for iOS
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.max,
      );

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        RemoteNotification? notification = message.notification;
        AndroidNotification? android = notification?.android;

        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                  android: AndroidNotificationDetails(channel.id, channel.name,
                      channelDescription: channel.description,
                      icon: android.smallIcon)));
          print(
              'Message also contained a notification: ${message.notification}');
        }
      });
    }
  }
}
