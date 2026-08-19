// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:getsetgo/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:getsetgo/screens/login_screen.dart';
import 'package:getsetgo/screens/main_app_screen.dart';
import 'package:getsetgo/services/notification_service.dart'; // Import your notification service
import 'package:getsetgo/services/habit_service.dart'; // Import HabitService
import 'package:getsetgo/models/habit_entry.dart'; // Import HabitEntry and HabitStatus
import 'package:getsetgo/models/habit.dart'; // NEW: Import Habit model
import 'package:getsetgo/screens/habit_setting_screen.dart'; // NEW: Import HabitSettingScreen
import 'dart:async'; // Import for StreamSubscription
import 'dart:convert'; // Import for json decoding

// Define a global navigator key here so it can be accessed by the NotificationService
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Define global instances of services that might be needed by background handlers
// These need to be initialized in main() before use in top-level functions
late NotificationService globalNotificationService;
late HabitService globalHabitService;


// Top-level function to handle notification responses (foreground, background, and terminated)
// This function must be a top-level function or static method.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  debugPrint('notificationTapBackground: payload=${notificationResponse.payload}, actionId=${notificationResponse.actionId}');

  // Ensure services are initialized if this is called from a terminated state
  // This is a simplified check; a more robust solution might involve a dedicated
  // background entry point for Flutter plugins.
  if (!Firebase.apps.isNotEmpty) { // FIXED: Corrected Firebase.apps.isNotEmpty syntax
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  globalHabitService = HabitService(); // Re-initialize if needed
  globalNotificationService = NotificationService(); // Re-initialize if needed


  if (notificationResponse.actionId != null) {
    // This is an action button tap (e.g., 'YES_ACTION', 'NO_ACTION')
    // The data for actions is now in notificationResponse.data
    try {
      // Use notificationResponse.data for action-specific data
      final Map<String, dynamic>? actionData = notificationResponse.data;
      if (actionData != null) {
        final String habitId = actionData['habitId'];
        final String statusString = actionData['status']; // 'completed' or 'skipped'

        HabitStatus status;
        if (statusString == 'completed') {
          status = HabitStatus.completed;
        } else if (statusString == 'skipped') {
          status = HabitStatus.skipped;
        } else {
          status = HabitStatus.pending; // Default or handle unknown status
        }

        debugPrint('Action received: Habit ID: $habitId, Status: $status');

        // Get the current user. This is crucial for Firestore operations.
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Update habit entry in Firestore
          final newEntry = HabitEntry(
            habitId: habitId,
            userId: user.uid,
            date: DateTime.now(), // Log for today
            status: status,
            interactionTime: DateTime.now(),
            notes: 'Logged via notification action: $statusString',
          );
          await globalHabitService.addOrUpdateHabitEntry(newEntry);
          debugPrint('Habit entry updated in Firestore via notification action.');
        } else {
          debugPrint('No user logged in for background habit update. Cannot update Firestore.');
        }

        // If the app is in the foreground, you can show a SnackBar
        // This part will only execute if the app is already running and the context is available
        if (navigatorKey.currentState?.context != null) {
          ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
            SnackBar(content: Text('Habit "$habitId" marked as $statusString!')),
          );
        }
      } else {
        debugPrint('Action data is null for actionId: ${notificationResponse.actionId}');
      }
    } catch (e) {
      debugPrint('Error processing action payload in background handler: $e');
    }
  } else if (notificationResponse.payload != null && notificationResponse.payload!.startsWith('habit_')) {
    // This is a direct tap on the notification itself (not an action button)
    final String? habitId = notificationResponse.payload?.split('_').last;
    if (habitId != null) {
      // Use WidgetsBinding.instance.addPostFrameCallback to ensure UI is ready for navigation
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


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async operations before runApp

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize global service instances
  globalNotificationService = NotificationService();
  globalHabitService = HabitService();

  await globalNotificationService.initializeNotifications();

  // Request notification permissions after initialization
  await globalNotificationService.requestNotificationPermissions();

  // Handle any notification launched when the app was terminated
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    if (notificationAppLaunchDetails!.notificationResponse != null) {
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
  // Use the global service instances
  final HabitService _habitService = globalHabitService;
  final NotificationService _notificationService = globalNotificationService;

  StreamSubscription<List<Habit>>? _habitsSubscription; // Fixed: Habit type is now imported

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
