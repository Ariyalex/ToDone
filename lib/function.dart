import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz; // Correct import for initializeTimeZones
import 'package:timezone/timezone.dart' as tz; // Add 'tz' prefix
import 'dart:io';
import 'package:logger/logger.dart';
// Remove the import for flutter_native_timezone
// import 'package:flutter_native_timezone/flutter_native_timezone.dart'; // Correct package import

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();
  static final Logger _logger = Logger();

  static bool notificationPermission = true;

  static Future _notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channelID',
        'channelName',
        channelDescription: 'channelDescription',
        //importance: Importance.unspecified,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  static Future init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    //When app is closed
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotifications.add(details.notificationResponse?.payload);
    }

    await _notifications.initialize(settings,
        onDidReceiveNotificationResponse: ((payload) async {
      onNotifications.add(payload.payload);
    }));

    if (initScheduled) {
      tz.initializeTimeZones(); // Initialize time zones with 'tz' prefix
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // Set local location with 'tz' prefix
      } catch (e) {
        _logger.e('Error initializing timezone: $e');
      }
    }
  }

  //This is how to request and check permissions on ANDROID and IOS
  static Future<bool?> checkNotificationPermissions() async {
    if (Platform.isAndroid) {
      _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      return await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
    }
    return null;
  }

  static void showScheduledNotification({
    required int id, //This must be a unique ID I recommend a UUID package
    String? title, 
    String? body,
    String? payload,
    required DateTime scheduledDate, //When you want the notification to happen
  }) async =>
      _notifications.zonedSchedule(id, title, body,
          tz.TZDateTime.from(scheduledDate, tz.local), await _notificationDetails(), // Use 'tz' prefix
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload);

  static void showNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(id, title, body, await _notificationDetails(), payload: payload);

  static void cancel(int id) => _notifications.cancel(id);
  static void cancelAll() => _notifications.cancelAll();
}

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return page;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}