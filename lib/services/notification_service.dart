// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz; // Keep this for tz.getLocation and tz.setLocalLocation
import 'package:timezone/data/latest.dart' as tz_data; // <--- NEW: Import for initializeTimeZones()
import 'package:flutter_timezone/flutter_timezone.dart'; // Keep this for FlutterTimezone.getLocalTimezone()
import 'package:flutter/material.dart';
import 'package:getsetgo/models/habit.dart';
import 'package:getsetgo/screens/habit_setting_screen.dart';
import 'package:getsetgo/main.dart';

// Global instance of the plugin (used by main.dart and background handler)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('notificationTapBackground: payload=${notificationResponse.payload}');
  if (notificationResponse.payload != null) {
    if (notificationResponse.payload!.startsWith('habit_')) {
      final String? habitId = notificationResponse.payload?.split('_').last;
      if (habitId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (context) => HabitSettingScreen(habitId: habitId), // Pass habitId
              ),
            );
          } else {
            debugPrint('ERROR: navigatorKey.currentState is null in background handler.');
          }
        });
      }
    }
  }
}

class NotificationService {
  Future<void> initializeNotifications() async {
    // CORRECTED: Initialize base timezones using tz_data.initializeTimeZones()
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName)); // Set local timezone using tz.getLocation

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon'); // Ensure 'app_icon' exists in drawable

    final DarwinInitializationSettings initializationSettingsDarwin =
        const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        debugPrint('onDidReceiveNotificationResponse: payload=${notificationResponse.payload}');
        if (notificationResponse.payload != null) {
          if (notificationResponse.payload!.startsWith('habit_')) {
            final String? habitId = notificationResponse.payload?.split('_').last;
            if (habitId != null && navigatorKey.currentState != null) {
              navigatorKey.currentState!.push(
                MaterialPageRoute(
                  builder: (context) => HabitSettingScreen(habitId: habitId), // Pass habitId
                ),
              );
            }
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> requestNotificationPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    debugPrint('Notification permissions requested.');
  }

  Future<void> scheduleHabitNotification({
    required String notificationId,
    required String habitName,
    required DateTime scheduledTime,
    required String habitFirestoreId,
  }) async {
    int id = notificationId.hashCode;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'habit_notifications_channel_id',
      'Habit Reminders',
      channelDescription: 'Reminders for your daily habits',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    final DarwinNotificationDetails darwinPlatformChannelSpecifics =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
      macOS: darwinPlatformChannelSpecifics,
    );

    final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Time to ${habitName.toUpperCase()}!',
      'Don\'t forget to complete your habit today.',
      scheduledTZTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'habit_$habitFirestoreId',
    );
    debugPrint('Notification scheduled for $habitName at $scheduledTZTime with ID: $id (payload: habit_$habitFirestoreId)');
  }

  Future<void> cancelNotificationsForHabit(String habitFirestoreId) async {
    debugPrint('DEBUG NOTIFICATION: Attempting to cancel all notifications for habit ID: $habitFirestoreId');
    await cancelNotification('daily_$habitFirestoreId');
    debugPrint('DEBUG NOTIFICATION: Finished attempting to cancel notifications for habit ID: $habitFirestoreId.');
  }

  Future<void> scheduleDailyHabitReminders(List<Habit> habits) async {
    debugPrint('Scheduling daily reminders for ${habits.length} habits...');
    await cancelAllNotifications();

    for (var habit in habits) {
      if (habit.reminderTime != null) {
        final DateTime now = DateTime.now();
        final DateTime todayScheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          habit.reminderTime!.hour,
          habit.reminderTime!.minute,
        );

        DateTime effectiveScheduledTime = todayScheduledTime;
        if (effectiveScheduledTime.isBefore(now)) {
          effectiveScheduledTime = effectiveScheduledTime.add(const Duration(days: 1));
          debugPrint('DEBUG: Reminder time for ${habit.name} is in the past today. Scheduling for tomorrow.');
        }

        if (habit.id != null && habit.id!.isNotEmpty) {
            await scheduleHabitNotification(
              notificationId: 'daily_${habit.id}',
              habitName: habit.name,
              scheduledTime: effectiveScheduledTime,
              habitFirestoreId: habit.id!,
            );
        } else {
            debugPrint('WARNING: Habit ${habit.name} has a null or empty ID, skipping notification scheduling.');
        }
      }
    }
    debugPrint('Finished scheduling daily habit reminders.');
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('All notifications cancelled.');
  }

  Future<void> cancelNotification(String notificationId) async {
    int id = notificationId.hashCode;
    await flutterLocalNotificationsPlugin.cancel(id);
    debugPrint('Notification with ID (string): $notificationId (int: $id) cancelled.');
  }
}