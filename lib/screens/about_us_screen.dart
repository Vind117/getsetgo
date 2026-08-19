// lib/screens/about_us_screen.dart

import 'package:flutter/material.dart';
import 'package:getsetgo/widgets/animated_background.dart'; // Import AnimatedBackground widget

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      // Wrap the Scaffold with AnimatedBackground
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make Scaffold background transparent
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min, // Make row only take required space
            children: [
              const Text(
                'ABOUT US',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Adjust title color
                ),
              ),
              const SizedBox(width: 8),
              // Using your info.png asset
              Image.asset(
                'assets/images/info.png',
                height: 24,
                width: 24,
                color: Colors.blue,
                colorBlendMode: BlendMode.modulate,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.info_outline, color: Colors.blue);
                },
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent, // Transparent AppBar
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Go back to previous screen
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
                  color: Colors.yellow[200]!
                      .withOpacity(0.7), // Semi-transparent yellow box
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to Get Set Go, your personalized habit tracker and goal management app. Our mission is to empower individuals to build positive habits, achieve their goals, and improve their daily productivity.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Get Set Go Logo',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'What We Offer:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• AI-powered suggestions to help you pick the best habits and goals.',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            '• User-friendly analytics to track your progress and celebrate milestones',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            '• Smart reminders and notifications tailored to your daily routine.',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            '• A seamless, intuitive interface for stress-free goal management.',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'We are committed to leveraging technology to make self-improvement simple, effective, and enjoyable. Start your journey to a better you with Get Set Go today!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // Add more content below if needed
            ],
          ),
        ),
      ),
    );
  }
}
