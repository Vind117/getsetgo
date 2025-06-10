import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'assistant_screen.dart';
import 'habit_setting_screen.dart';
import 'ai_suggestion_screen.dart';  // adjust path if needed
import 'logout_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AssistantScreen(),
    const HabitSettingScreen(),
    const AiSuggestionScreen(),
    const LogoutScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Assistant'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Habit Setting'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI Suggestion'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}
