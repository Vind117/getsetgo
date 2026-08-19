// lib/screens/logout_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // REQUIRED: For Firebase Authentication
import 'package:getsetgo/screens/login_screen.dart';
import 'package:getsetgo/widgets/animated_background.dart';

class LogoutScreen extends StatefulWidget { // Changed to StatefulWidget
  const LogoutScreen({Key? key}) : super(key: key);

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  String _userName = 'User'; // Default name
  String _userEmail = ''; // To display if name is not available

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to load the current user's data
  void _loadUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'User'; // Use display name, or part of email, or 'User'
        _userEmail = user.email ?? '';
      });
    }
  }

  // Function to handle the actual logout
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        // Navigate to LoginScreen and clear all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout: ${e.toString()}')),
        );
      }
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
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'LOGOUT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: const AssetImage('assets/images/unisex_logos.png'),
              ),
              const SizedBox(height: 16),
              Text(
                _userName, // Display dynamic user name
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (_userEmail.isNotEmpty) // Optionally display email if name is just part of email
                Text(
                  _userEmail,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              const SizedBox(height: 8),
              const Text(
                'Logout',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              const Text(
                'Are you sure you want to logout from GetSetGo? You will need to login again next time.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _logout, // Call the _logout function
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
