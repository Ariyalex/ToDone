import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  //initialize the flitterlocalnoticiationplugin instance
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {
    //handle the notification when the app is in the foreground
  }

  //initialize the notification plugin
  static Future<void> init() async {
    //define the android initialization settings
    const initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher_foreground");

    //initialize the android settings
    const InitializationSettings androidInitializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    //initialize the plugin with the specified settings
    await flutterLocalNotificationsPlugin.initialize(
      androidInitializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    //request notificatin permission for android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  //show instant notification
  static Future<void> showInstantNotification(String title, String body) async {
    //define notification details
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails("channel_Id", "channel_name",
          importance: Importance.high, priority: Priority.high),
    );
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  //show scheduled notification
  static Future<void> scheduleNotification(
      String title, String body, DateTime scheduledTime) async {
    //define notification details
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails("channel_Id", "channel_name",
          importance: Importance.high, priority: Priority.high),
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(0, title, body,
        tz.TZDateTime.from(scheduledTime, tz.local), platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
    DateTimeComponents.dateAndTime;
  }
}
