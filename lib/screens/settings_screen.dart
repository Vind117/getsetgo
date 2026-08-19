// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screens
import 'package:getsetgo/screens/logout_screen.dart';
import 'package:getsetgo/screens/edit_profile_screen.dart';
import 'package:getsetgo/screens/privacy_and_security_screen.dart';
import 'package:getsetgo/screens/notification_screen.dart';
import 'package:getsetgo/screens/about_us_screen.dart';
import 'package:getsetgo/screens/help_and_support_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current user
    final user = FirebaseAuth.instance.currentUser;

    // Determine the user's display name
    String displayName = user?.displayName ?? 'User';

    return Scaffold(
      backgroundColor: Colors.transparent, // Important for AnimatedBackground
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LogoutScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/images/unisex_logos.png')
                            as ImageProvider,
                    radius: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings options
            _buildSettingsOption(
              context,
              'Edit profile',
              Icons.arrow_forward_ios,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            _buildSettingsOption(
              context,
              'Privacy & Security',
              Icons.arrow_forward_ios,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyAndSecurityScreen(),
                  ),
                );
              },
            ),
            _buildSettingsOption(
              context,
              'Notification',
              Icons.arrow_forward_ios,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            _buildSettingsOption(
              context,
              'About Us',
              Icons.arrow_forward_ios,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsOption(
              context,
              'Help & Support',
              Icons.arrow_forward_ios,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpAndSupportScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
    BuildContext context,
    String title,
    IconData trailingIcon,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          trailing: Icon(trailingIcon, color: Colors.white),
          onTap: onPressed,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 8.0,
          ),
        ),
      ],
    );
  }
}

