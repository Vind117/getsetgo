import 'package:flutter/material.dart';
import 'package:getsetgo/widgets/animated_background.dart'; // Import AnimatedBackground
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // State variables for notification settings
  bool _showNotification = true;
  bool _soundNotification = true;
  bool _dailyReminderEnabled = true;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _doNotDisturb = false;

  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  // Load the notification settings from shared preferences
  _loadNotificationSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _showNotification = _prefs.getBool('showNotification') ?? _showNotification;
      _soundNotification = _prefs.getBool('soundNotification') ?? _soundNotification;
      _dailyReminderEnabled = _prefs.getBool('dailyReminderEnabled') ?? _dailyReminderEnabled;
      _doNotDisturb = _prefs.getBool('doNotDisturb') ?? _doNotDisturb;

      // Load daily reminder time, defaulting to 8:00 AM if not found
      final int reminderHour = _prefs.getInt('dailyReminderHour') ?? _dailyReminderTime.hour;
      final int reminderMinute = _prefs.getInt('dailyReminderMinute') ?? _dailyReminderTime.minute;
      _dailyReminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
    });
  }

  // Save the notification settings to shared preferences
  _saveNotificationSettings() async {
    await _prefs.setBool('showNotification', _showNotification);
    await _prefs.setBool('soundNotification', _soundNotification);
    await _prefs.setBool('dailyReminderEnabled', _dailyReminderEnabled);
    await _prefs.setBool('doNotDisturb', _doNotDisturb);
    await _prefs.setInt('dailyReminderHour', _dailyReminderTime.hour);
    await _prefs.setInt('dailyReminderMinute', _dailyReminderTime.minute);
  }

  // Function to show the time picker and update the daily reminder time
  Future<void> _selectDailyReminderTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue, // Header background color
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newTime != null) {
      setState(() {
        _dailyReminderTime = newTime;
        _saveNotificationSettings(); // Save the new time
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Notification',
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // Show Notification Toggle
                _buildNotificationToggle(
                  'Show Notification',
                  _showNotification,
                  (bool value) {
                    setState(() {
                      _showNotification = value;
                      _saveNotificationSettings();
                    });
                  },
                ),

                // Sound Notification Toggle
                _buildNotificationToggle(
                  'Sound Notification',
                  _soundNotification,
                  (bool value) {
                    setState(() {
                      _soundNotification = value;
                      _saveNotificationSettings();
                    });
                  },
                ),

                // Daily Reminder Time (with time picker)
                _buildDailyReminderTimeTile(),

                // Do Not Disturb (DND) Toggle
                _buildNotificationToggle(
                  'Do Not Disturb(DND)',
                  _doNotDisturb,
                  (bool value) {
                    setState(() {
                      _doNotDisturb = value;
                      _saveNotificationSettings();
                    });
                  },
                ),

                // Now shows the message if any toggle is on
                if (_showNotification || _soundNotification || _dailyReminderEnabled || _doNotDisturb)
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Features coming soon!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // A reusable widget to build a notification toggle list tile
  Widget _buildNotificationToggle(String title, bool value, ValueChanged<bool> onChanged) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
            inactiveTrackColor: Colors.grey.shade700,
            inactiveThumbColor: Colors.white,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
        ),
      ],
    );
  }

  // A dedicated widget for the daily reminder time setting
  Widget _buildDailyReminderTimeTile() {
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Daily Reminder Time',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          subtitle: _dailyReminderEnabled
              ? Text(
                  'Set at ${_dailyReminderTime.format(context)}',
                  style: const TextStyle(color: Colors.white70),
                )
              : null,
          trailing: Switch(
            value: _dailyReminderEnabled,
            onChanged: (bool value) {
              setState(() {
                _dailyReminderEnabled = value;
                _saveNotificationSettings();
              });
            },
            activeColor: Colors.green,
            inactiveTrackColor: Colors.grey.shade700,
            inactiveThumbColor: Colors.white,
          ),
          onTap: () {
            if (_dailyReminderEnabled) {
              _selectDailyReminderTime(context);
            }
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
        ),
      ],
    );
  }
}
