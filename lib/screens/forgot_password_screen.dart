// lib/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // REQUIRED: For Firebase Auth
import 'package:getsetgo/widgets/animated_background.dart'; // Import your AnimatedBackground widget

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message; // For success or error messages to the user

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _message = null; // Clear previous messages
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() {
        _message = 'Password reset email sent! Check your inbox.';
      });

      // Optionally, navigate back to login after a short delay
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.pop(context); // Go back to login screen
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else {
        errorMessage = 'Error sending reset email: ${e.message}';
      }
      setState(() {
        _message = errorMessage;
      });
      print('Firebase Auth Error (Password Reset): ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        _message = 'An unexpected error occurred: ${e.toString()}';
      });
      print('General Error (Password Reset): ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground( // Using your AnimatedBackground for consistent UI
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Forgot Password',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Go back to LoginScreen
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter your email address to receive a password reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 30),

                if (_message != null) // Display message (success or error)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _message!.contains('sent') ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),

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

                const SizedBox(height: 20),

                _isLoading
                    ? const CircularProgressIndicator(color: Colors.blue)
                    : ElevatedButton(
                        onPressed: _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Send Reset Link'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
