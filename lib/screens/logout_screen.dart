import 'package:flutter/material.dart';
import 'package:getsetgo/screens/login_screen.dart'; // <--- NEW: Import LoginScreen
import 'package:getsetgo/widgets/animated_background.dart'; // <--- NEW: Import AnimatedBackground

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground( // <--- Wrap the Scaffold with AnimatedBackground
      child: Scaffold(
        backgroundColor: Colors.transparent, // <--- Make Scaffold background transparent
        appBar: AppBar( // <--- Added AppBar for consistency and back navigation
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white), // <--- Adjust color
            onPressed: () {
              Navigator.pop(context); // Go back to the previous screen (e.g., Settings)
            },
          ),
          title: const Text(
            'LOGOUT',
            style: TextStyle(
              color: Colors.white, // <--- Adjust color
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
                backgroundImage: const AssetImage('assets/images/avatar.png'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aravind',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // <--- Adjust text color
              ),
              const SizedBox(height: 8),
              const Text(
                'Logout',
                style: TextStyle(fontSize: 18, color: Colors.white70), // <--- Adjust text color
              ),
              const SizedBox(height: 24),
              const Text(
                'Are you sure you want to logout from GetSetGo? You will need to login again next time.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white), // <--- Adjust text color
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
                      backgroundColor: Colors.white.withOpacity(0.8), // <--- Adjust color
                      foregroundColor: Colors.black, // <--- Adjust text color
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // <--- CORRECTED NAVIGATION: Navigate to LoginScreen
                      Navigator.pushAndRemoveUntil( // Use pushAndRemoveUntil to clear the stack
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false, // This predicate ensures all previous routes are removed
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Keep red for logout
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