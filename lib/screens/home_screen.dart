import 'package:flutter/material.dart';
import 'assistant_screen.dart';
import 'habit_setting_screen.dart';
import 'ai_suggestion_screen.dart';
import 'logout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens to display based on selected index
  final List<Widget> _screens = [
    // Home content
    HomeContent(),
    AssistantScreen(),
    HabitSettingScreen(),
    AiSuggestionScreen(), // You can replace with a real settings screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/Profile picture circle.png'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aravind A/L Nadarajan',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogoutScreen()),
              );
            },
          )
        ],
      ),
      body: _screens[_selectedIndex], // Display selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/Blue home.png')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/Blue assistant.png')),
            label: 'Assistant',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/New habit icon (1).png')),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/Setting icon (1).png')),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/home_bg_gif2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Welcome Back! Keep Building Those Habits and Make Today Another Step Toward Discipline.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
