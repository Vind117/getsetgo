// lib/screens/privacy_statement_screen.dart
import 'package:flutter/material.dart';
import 'package:getsetgo/widgets/animated_background.dart'; // <--- NEW: Import your AnimatedBackground widget

class PrivacyStatementScreen extends StatelessWidget {
  const PrivacyStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground( // <--- Wrap the Scaffold with AnimatedBackground
      child: Scaffold(
        backgroundColor: Colors.transparent, // <--- Make Scaffold background transparent
        appBar: AppBar(
          title: const Text(
            'GET SET GO PRIVACY STATEMENT',
            style: TextStyle(
              fontSize: 16, // Adjusted font size as it's a longer title
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
              Navigator.pop(context); // Go back to Privacy & Security screen
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [ // Removed const from here to allow TextStyles to be non-const if needed
              Text(
                'At Get Set Go, we are committed to protecting your privacy. This Privacy Statement outlines the information we collect, how we use it, and the steps we take to safeguard your personal data. By using our app, you consent to the collection and use of information in accordance with this policy.',
                style: TextStyle(fontSize: 14, color: Colors.white), // <--- Adjust text color
              ),
              SizedBox(height: 15),

              Text(
                '1. Information We Collect',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), // <--- Adjust text color
              ),
              SizedBox(height: 5),
              Text(
                'When you use the Get Set Go app, we may collect the following types of information:',
                style: TextStyle(fontSize: 14, color: Colors.white), // <--- Adjust text color
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Personal Information: This may include your name, email address, and other details you provide when creating an account or using the app\'s features.', style: TextStyle(fontSize: 14, color: Colors.white)), // <--- Adjust text color
                    Text('• Financial Data: For users tracking their expenses and managing their budget, we may collect transaction details, categorized expenses, and financial goals.', style: TextStyle(fontSize: 14, color: Colors.white)), // <--- Adjust text color
                    Text('• Usage Data: This includes information about how you use the app, such as interaction patterns, features accessed, and preferences.', style: TextStyle(fontSize: 14, color: Colors.white)), // <--- Adjust text color
                  ],
                ),
              ),
              SizedBox(height: 15),

              Text(
                '2. How We Use Your Information',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), // <--- Adjust text color
              ),
              SizedBox(height: 5),
              Text(
                'The information we collect is used for the following purposes:',
                style: TextStyle(fontSize: 14, color: Colors.white), // <--- Adjust text color
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• To Provide Services: To help you track and manage your finances, categorize your expenses, set budgeting goals, and visualize your financial data.', style: TextStyle(fontSize: 14, color: Colors.white)), // <--- Adjust text color
                    Text('• Improvement of Services: To enhance the functionality of the app and improve user experience through continuous feedback and updates.', style: TextStyle(fontSize: 14, color: Colors.white)), // <--- Adjust text color
                    Text('• Personalization: To provide a personalized experience and recommend features based on your use and data.', style: TextStyle(fontSize: 14, color: Colors.white)), // <--- Adjust text color
                    Text('• Communication: To inform you about updates, new features, or changes to the app\'s services.', style: TextStyle(fontSize: 14, color: Colors.white)), // <--- Adjust text color
                  ],
                ),
              ),
              SizedBox(height: 15),

              Text(
                '3. Data Security',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), // <--- Adjust text color
              ),
              SizedBox(height: 5),
              Text(
                'We implement security measures to protect your personal and financial data, including encryption, secure storage, and access control. However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
                style: TextStyle(fontSize: 14, color: Colors.white), // <--- Adjust text color
              ),
              SizedBox(height: 15),

              Text(
                '4. Sharing Your Information',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), // <--- Adjust text color
              ),
              SizedBox(height: 5),
              Text(
                'We do not sell or rent your personal data to third parties. However, we may share your data with trusted partners who assist in the operation of the app, such as payment processors and analytics providers. These third parties are obligated to maintain the confidentiality and security of your information.',
                style: TextStyle(fontSize: 14, color: Colors.white), // <--- Adjust text color
              ),
              SizedBox(height: 15),

              Text(
                '5. Your Rights',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), // <--- Adjust text color
              ),
              SizedBox(height: 5),
              Text(
                'You have the right to access, update, or delete the personal information we hold about you. You can also opt out of data collection features, such as usage tracking, by adjusting your app settings.',
                style: TextStyle(fontSize: 14, color: Colors.white), // <--- Adjust text color
              ),
              SizedBox(height: 15),

              Text(
                '6. Updates to This Privacy Statement',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), // <--- Adjust text color
              ),
              SizedBox(height: 5),
              Text(
                'This privacy statement may be updated from time to time. Any changes will be reflected in this document, and we will notify users of significant changes through the app or via emails.',
                style: TextStyle(fontSize: 14, color: Colors.white), // <--- Adjust text color
              ),
              SizedBox(height: 15),

              Text(
                '7. Contact Us',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), // <--- Adjust text color
              ),
              SizedBox(height: 5),
              Text(
                'If you have any questions or concerns about your privacy or data usage, please contact us at [016-2242770].',
                style: TextStyle(fontSize: 14, color: Colors.white), // <--- Adjust text color
              ),
            ],
          ),
        ),
      ),
    );
  }
}