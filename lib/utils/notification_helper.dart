import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class NotificationHelper {
  ///Shows Notification immediately when called.
  showNotification() async {
    var androidChannelSpecifics = const AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      "CHANNEL_DESCRIPTION",
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'title',
      'body',
      platformChannelSpecifics,
      payload: 'New Payload',
    );
  }

  scheduledNotification(
    String selectedDate,
    String selectedTime,
    int id,
    String title,
    String body,
  ) async {
    var scheduledNotificationDateTime = DateTime(
        int.parse(selectedDate.substring(0, 4)),
        int.parse(selectedDate.substring(5, 7)),
        int.parse(selectedDate.substring(8, 10)),
        int.parse(selectedTime.substring(0, 2)),
        int.parse(selectedTime.substring(3, 5)));
    var androidChannelSpecifics = const AndroidNotificationDetails(
      '1',
      'Reminder',
      "Notes Reminder",
      enableLights: true,
      color: Color.fromARGB(255, 255, 0, 0),
      ledColor: Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      // timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.schedule(
      id,
      title,
      body,
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      payload: id.toString(),
      androidAllowWhileIdle: true,
    );
  }

  deleteNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
