import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'assistant_screen.dart';
import 'habit_setting_screen.dart';
import 'ai_suggestion_screen.dart';
import 'logout_screen.dart'; // Still needed for navigation
import 'settings_screen.dart';
import 'notification_screen.dart'; // Still needed for navigation
import 'package:getsetgo/widgets/animated_background.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  // These are the actual screen widgets, now each responsible for its own AppBar
  final List<Widget> _screens = [
    const HomeScreenContent(),
    const AssistantScreen(),
    const HabitSettingScreen(),
    const AiSuggestionScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground( // This wraps the entire app with the video background
      child: Scaffold(
        backgroundColor: Colors.transparent, // Crucial: Scaffold background is transparent
        // REMOVED: appBar property from MainAppScreen
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.black.withOpacity(0.5), // Semi-transparent for consistency
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.support_agent),
              label: 'Assistant',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: 'Habit Setting',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              label: 'AI Suggestion',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}