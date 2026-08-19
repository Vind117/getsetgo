// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';
import 'package:getsetgo/models/habit.dart';
import 'package:getsetgo/screens/habit_setting_screen.dart';
import 'package:getsetgo/main.dart';
import 'dart:convert';
import 'package:getsetgo/models/habit_entry.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  debugPrint('notificationTapBackground: payload=${notificationResponse.payload}, actionId=${notificationResponse.actionId}');

  if (notificationResponse.actionId != null) {
    try {
      final String? habitId = notificationResponse.payload?.split('_').last;
      final String actionId = notificationResponse.actionId!;

      if (habitId != null) {
        String statusString;
        if (actionId == 'YES_ACTION') {
          statusString = 'completed';
        } else if (actionId == 'NO_ACTION') {
          statusString = 'skipped';
        } else {
          statusString = 'unknown';
        }

        debugPrint('Action received: Habit ID: $habitId, Status: $statusString');

        HabitStatus status;
        if (statusString == 'completed') {
          status = HabitStatus.completed;
        } else if (statusString == 'skipped') {
          status = HabitStatus.skipped;
        } else {
          status = HabitStatus.pending;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final newEntry = HabitEntry(
            habitId: habitId,
            userId: user.uid,
            date: DateTime.now(),
            status: status,
            interactionTime: DateTime.now(),
            notes: 'Logged via notification action: $statusString',
          );
          await globalHabitService.addOrUpdateHabitEntry(newEntry);
          debugPrint('Habit entry updated in Firestore via notification action.');
        } else {
          debugPrint('No user logged in for background habit update. Cannot update Firestore.');
        }
      } else {
        debugPrint('Habit ID is null for actionId: $actionId');
      }
    } catch (e) {
      debugPrint('Error processing action in background: $e');
    }
  } else if (notificationResponse.payload != null && notificationResponse.payload!.startsWith('habit_')) {
    final String? habitId = notificationResponse.payload?.split('_').last;
    if (habitId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => HabitSettingScreen(habitId: habitId),
            ),
          );
        } else {
          debugPrint('ERROR: navigatorKey.currentState is null in background handler.');
        }
      });
    }
  }
}

class NotificationService {
  Future<void> initializeNotifications() async {
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // The notification icon name is now 'getsetgo_logo'
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('getsetgo_logo');

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
        debugPrint('onDidReceiveNotificationResponse: payload=${notificationResponse.payload}, actionId=${notificationResponse.actionId}');
        if (notificationResponse.actionId != null) {
          try {
            final String? habitId = notificationResponse.payload?.split('_').last;
            final String actionId = notificationResponse.actionId!;

            if (habitId != null) {
              String statusString;
              if (actionId == 'YES_ACTION') {
                statusString = 'completed';
              } else if (actionId == 'NO_ACTION') {
                statusString = 'skipped';
              } else {
                statusString = 'unknown';
              }

              debugPrint('Foreground/Background Action received: Habit ID: $habitId, Status: $statusString');

              HabitStatus status;
              if (statusString == 'completed') {
                status = HabitStatus.completed;
              } else if (statusString == 'skipped') {
                status = HabitStatus.skipped;
              } else {
                status = HabitStatus.pending;
              }

              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final newEntry = HabitEntry(
                  habitId: habitId,
                  userId: user.uid,
                  date: DateTime.now(),
                  status: status,
                  interactionTime: DateTime.now(),
                  notes: 'Logged via notification action: $statusString',
                );
                await globalHabitService.addOrUpdateHabitEntry(newEntry);
                debugPrint('Habit entry updated in Firestore via notification action.');

                if (navigatorKey.currentState?.context != null) {
                  ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
                    SnackBar(content: Text('Habit "$habitId" marked as $statusString!')),
                  );
                }
              } else {
                debugPrint('No user logged in for foreground/background habit update. Cannot update Firestore.');
                if (navigatorKey.currentState?.context != null) {
                  ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
                    const SnackBar(content: Text('Please log in to update habit status.')),
                  );
                }
              }
            } else {
              debugPrint('Habit ID is null for actionId: $actionId');
            }
          } catch (e) {
            debugPrint('Error processing action in foreground/background: $e');
            if (navigatorKey.currentState?.context != null) {
              ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
                SnackBar(content: Text('Error processing notification action: $e')),
              );
            }
          }
        } else if (notificationResponse.payload != null && notificationResponse.payload!.startsWith('habit_')) {
          final String? habitId = notificationResponse.payload?.split('_').last;
          if (habitId != null && navigatorKey.currentState != null) {
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (context) => HabitSettingScreen(habitId: habitId),
              ),
            );
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
    // Generate a unique integer ID from the string notificationId
    int id = notificationId.hashCode;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'habit_notifications_channel_id',
      'Habit Reminders',
      channelDescription: 'Reminders for your daily habits',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      actions: [
        AndroidNotificationAction(
          'YES_ACTION',
          'Yes, I did it!',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'NO_ACTION',
          'No, not yet.',
          showsUserInterface: false,
        ),
      ],
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
    // We are now canceling based on a unique string that is consistent
    await cancelNotification('daily_${habitFirestoreId}');
    debugPrint('DEBUG NOTIFICATION: Finished attempting to cancel notifications for habit ID: $habitFirestoreId.');
  }

  Future<void> scheduleDailyHabitReminders(List<Habit> habits) async {
    debugPrint('Scheduling daily reminders for ${habits.length} habits...');
    
    // Cancel all existing notifications before scheduling new ones.
    // This is the most reliable way to prevent duplicates when this function is called multiple times.
    await cancelAllNotifications();

    for (var habit in habits) {
      if (habit.reminderTime != null) {
        if (habit.id != null && habit.id!.isNotEmpty) {
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
        
          await scheduleHabitNotification(
            // Use a unique ID for each habit
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

