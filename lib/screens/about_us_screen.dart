// lib/screens/about_us_screen.dart
import 'package:flutter/material.dart';
import 'package:getsetgo/widgets/animated_background.dart'; // <--- NEW: Import your AnimatedBackground widget

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground( // <--- Wrap the Scaffold with AnimatedBackground
      child: Scaffold(
        backgroundColor: Colors.transparent, // <--- Make Scaffold background transparent
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min, // Make row only take required space
            children: [
              const Text(
                'ABOUT US',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // <--- Adjust title color for readability on animated background
                ),
              ),
              const SizedBox(width: 8),
              // Using your info.png asset
              Image.asset(
                'assets/images/info.png', // Path to your info.png asset
                height: 24, // Adjust size as needed
                width: 24, // Adjust size as needed
                color: Colors.blue, // Keep blue color for info icon, adjust if needed
                colorBlendMode: BlendMode.modulate, // Example blend mode
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.info_outline, color: Colors.blue); // Fallback icon
                },
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent, // <--- Make AppBar background transparent
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white), // <--- Adjust icon color
            onPressed: () {
              Navigator.pop(context); // Go back to Settings screen
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  // Made semi-transparent to allow animated background to show through
                  color: Colors.yellow[200]!.withOpacity(0.7), // <--- Made semi-transparent
                  borderRadius: BorderRadius.circular(10), // Slightly rounded corners
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to Get Set Go, your personalized habit tracker and goal management app. Our mission is to empower individuals to build positive habits, achieve their goals, and improve their daily productivity.',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black), // <--- Adjust text color
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png', // Assuming you have a logo.png asset
                        height: 100, // Adjust size as needed
                        // Consider adding color/blendMode if logo is dark and needs contrast
                        // color: Colors.black, // Example if logo is white and needs to show on yellow
                        // colorBlendMode: BlendMode.srcIn,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('Get Set Go Logo', style: TextStyle(color: Colors.grey, fontSize: 16)); // Fallback text
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'What We Offer:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black), // <--- Adjust text color
                    ),
                    const SizedBox(height: 5),
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• AI-powered suggestions to help you pick the best habits and goals.', style: TextStyle(fontSize: 14, color: Colors.black)), // <--- Adjust text color
                          Text('• User-friendly analytics to track your progress and celebrate milestones', style: TextStyle(fontSize: 14, color: Colors.black)), // <--- Adjust text color
                          Text('• Smart reminders and notifications tailored to your daily routine.', style: TextStyle(fontSize: 14, color: Colors.black)), // <--- Adjust text color
                          Text('• A seamless, intuitive interface for stress-free goal management.', style: TextStyle(fontSize: 14, color: Colors.black)), // <--- Adjust text color
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'We are committed to leveraging technology to make self-improvement simple, effective, and enjoyable. Start your journey to a better you with Get Set Go today!',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black), // <--- Adjust text color
                    ),
                  ],
                ),
              ),
              // Add more content below the yellow box if needed, as per design.
            ],
          ),
        ),
      ),
    );
  }
}