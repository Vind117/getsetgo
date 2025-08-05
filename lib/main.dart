// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:getsetgo/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Keep this import
import 'package:getsetgo/screens/login_screen.dart';
import 'package:getsetgo/screens/main_app_screen.dart';
import 'package:getsetgo/services/notification_service.dart'; // Import your notification service
import 'package:getsetgo/services/habit_service.dart';
import 'package:getsetgo/models/habit.dart';
import 'dart:async'; // Import for StreamSubscription

// Define a global navigator key here so it can be accessed by the NotificationService
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Removed the duplicate `notificationTapBackground` function from here.
// It should only exist in notification_service.dart as a top-level function.

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async operations before runApp

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final NotificationService notificationService = NotificationService();
  await notificationService.initializeNotifications();

  // Request notification permissions after initialization
  await notificationService.requestNotificationPermissions();

  // Handle any notification launched when the app was terminated
  // Use the global flutterLocalNotificationsPlugin instance
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    if (notificationAppLaunchDetails!.notificationResponse != null &&
        notificationAppLaunchDetails.notificationResponse!.payload != null) {
      // Direct call to the top-level handler
      notificationTapBackground(notificationAppLaunchDetails.notificationResponse!);
    }
  }

  runApp(const AuthWrapper());
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final HabitService _habitService = HabitService();
  final NotificationService _notificationService = NotificationService();

  StreamSubscription<List<Habit>>? _habitsSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        debugPrint('DEBUG MAIN: User is signed in: ${user.uid}. Starting habit stream listener.');
        // Cancel previous subscription if it exists
        _habitsSubscription?.cancel();
        // User is signed in, now listen to habits and schedule notifications
        _habitsSubscription = _habitService.getHabitsStream().listen((habits) {
          debugPrint('DEBUG MAIN: Received ${habits.length} habits from stream. Attempting to schedule notifications.');
          _notificationService.scheduleDailyHabitReminders(habits);
        }, onError: (error) {
          debugPrint('ERROR MAIN: Error fetching habits for notification scheduling: $error');
        });
      } else {
        debugPrint('DEBUG MAIN: User is signed out. Cancelling all pending notifications.');
        _habitsSubscription?.cancel(); // Cancel habit stream listener
        await _notificationService.cancelAllNotifications();
      }
    });
  }

  @override
  void dispose() {
    _habitsSubscription?.cancel(); // Ensure subscription is cancelled on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Assign the global key here
      title: 'Get Set Go',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const MainAppScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}