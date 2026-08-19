// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // REQUIRED: For Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // REQUIRED: To save user's name
import 'package:getsetgo/screens/main_app_screen.dart'; // Ensure MainAppScreen is imported
import 'package:getsetgo/widgets/animated_background.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Basic validation
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required.';
        _isLoading = false;
      });
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
        _isLoading = false;
      });
      return;
    }

    if (!_agreedToTerms) {
      setState(() {
        _errorMessage =
            'You must agree to the Terms and Conditions and Privacy Policy.';
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Create user
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Update profile
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // 3. Save user in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Navigate to main screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainAppScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = 'Sign up failed: ${e.message}';
      }

      setState(() {
        _errorMessage = message;
      });
      print('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
      print('General Sign Up Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),

              // Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Create a password',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),

              // Terms and conditions
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (val) {
                      setState(() {
                        _agreedToTerms = val ?? false;
                      });
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        text: 'I have read and agree with the ',
                        style: TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: TextStyle(color: Colors.blue),
                          ),
                          TextSpan(
                            text: ' and the ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Submit Button
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    )
                  : ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Sign Up'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
