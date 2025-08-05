import 'package:flutter/material.dart';
import 'package:getsetgo/screens/change_password_screen.dart'; // Import the change password screen
import 'package:getsetgo/screens/privacy_statement_screen.dart'; // Import the privacy statement screen
import 'package:getsetgo/widgets/animated_background.dart'; // <--- NEW: Import your AnimatedBackground widget

class PrivacyAndSecurityScreen extends StatelessWidget {
  const PrivacyAndSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground( // <--- Wrap the Scaffold with AnimatedBackground
      child: Scaffold(
        backgroundColor: Colors.transparent, // <--- Make Scaffold background transparent
        appBar: AppBar(
          title: const Text(
            'PRIVACY & SECURITY',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // <--- Adjust title color for readability on animated background
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent, // <--- Make AppBar background transparent
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white), // <--- Adjust icon color
            onPressed: () {
              Navigator.pop(context); // Go back to the previous screen (Settings)
            },
          ),
        ),
        body: Column(
          children: [
            // Option: Change Password
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              title: const Text(
                'Change Password',
                style: TextStyle(
                  color: Colors.red, // Red color as per screenshot (might need to adjust for contrast)
                  fontSize: 18,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white), // <--- Adjust icon color
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            // Horizontal line separator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: Colors.white54, thickness: 1), // <--- Adjust divider color
            ),
            // Option: Get Set Go Privacy Statement
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              title: const Text(
                'Get Set Go Privacy Statement',
                style: TextStyle(
                  color: Colors.red, // Red color as per screenshot (might need to adjust for contrast)
                  fontSize: 18,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white), // <--- Adjust icon color
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyStatementScreen()),
                );
              },
            ),
            // Horizontal line separator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: Colors.white54, thickness: 1), // <--- Adjust divider color
            ),
          ],
        ),
      ),
    );
  }
}