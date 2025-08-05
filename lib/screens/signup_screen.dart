// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // REQUIRED: For Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // REQUIRED: To save user's name (optional, but good practice)
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
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false; // To show/hide loading indicator during signup
  String? _errorMessage; // To display error messages
  bool _agreedToTerms = false; // State for the checkbox

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
      _errorMessage = null; // Clear previous errors
    });

    // Basic client-side validation
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

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
        _isLoading = false;
      });
      return;
    }

    if (!_agreedToTerms) {
      setState(() {
        _errorMessage = 'You must agree to the Terms and Conditions and Privacy Policy.';
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Create user with Email and Password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Optionally, update user profile (display name)
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // 3. Store additional user data in Firestore (e.g., the user's name)
      // This is highly recommended if you have a 'Name' field.
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(), // Timestamp of creation
      });

      // If signup is successful, navigate to MainAppScreen and remove all previous routes
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainAppScreen()),
          (Route<dynamic> route) => false, // This clears the navigation stack
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
      }
      else {
        message = 'Sign up failed: ${e.message}';
      }
      setState(() {
        _errorMessage = message;
      });
      print('Firebase Auth Error: ${e.code} - ${e.message}'); // For debugging
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
      print('General Sign Up Error: ${e.toString()}'); // For debugging
    } finally {
      setState(() {
        _isLoading = false; // Always stop loading, whether success or fail
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) // Display error message if present
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              TextField(
                controller: _nameController, // Link controller
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController, // Link controller
                keyboardType: TextInputType.emailAddress, // Suggest email keyboard
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController, // Link controller
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Create a password',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController, // Link controller
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms, // Link to state variable
                    onChanged: (val) {
                      setState(() {
                        _agreedToTerms = val ?? false; // Update checkbox state
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
                            // TODO: Add onTap for legal links
                          ),
                          TextSpan(text: ' and the ', style: TextStyle(color: Colors.white)),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(color: Colors.blue),
                            // TODO: Add onTap for legal links
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blue)) // Show loading indicator
                  : ElevatedButton(
                      onPressed: _signUp, // Call the _signUp method
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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