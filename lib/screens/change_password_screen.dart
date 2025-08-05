// lib/screens/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:getsetgo/widgets/animated_background.dart';
// import 'package:http/http.dart' as http; // For backend API calls
// import 'dart:convert'; // For json.encode

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Key for form validation

  bool _isLoading = false; // To show loading state
  bool _obscureCurrentPassword = true; // For password visibility toggle
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String currentPassword = _currentPasswordController.text;
      String newPassword = _newPasswordController.text;
      String confirmPassword = _confirmPasswordController.text;

      // Basic validation (more robust validation should be done server-side too)
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New password and confirm password do not match!')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (newPassword.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New password must be at least 8 characters long.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // TODO: Implement actual backend integration here
      // This is where you would send an HTTP POST request to your API
      // to change the user's password. You typically send the current password
      // for re-authentication and the new password.

      try {
        // Simulate an API call
        await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

        // Example using http package:
        /*
        final response = await http.post(
          Uri.parse('YOUR_BACKEND_API_ENDPOINT/change-password'), // Replace with your API endpoint
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer YOUR_AUTH_TOKEN'},
          body: json.encode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully!')),
          );
          Navigator.pop(context); // Go back after successful update
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update password: ${response.body}')),
          );
        }
        */

        // For now, just print the passwords and show a success message
        print('Current Password: $currentPassword');
        print('New Password: $newPassword');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully (simulated)!')),
        );

        // Clear the fields after successful update
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        Navigator.pop(context); // Go back after successful update

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating password: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Change Password',
            style: TextStyle(
              fontSize: 20,
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
          padding: const EdgeInsets.all(24.0),
          child: Form( // Wrap with Form for validation
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '@aravind1107',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 20),

                _buildPasswordField(
                  'Current Password',
                  _currentPasswordController,
                  _obscureCurrentPassword,
                  () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
                const SizedBox(height: 20),

                _buildPasswordField(
                  'New Password',
                  _newPasswordController,
                  _obscureNewPassword,
                  () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  hintText: 'At least 8 characters',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildPasswordField(
                  'Confirm Password',
                  _confirmPasswordController,
                  _obscureConfirmPassword,
                  () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  hintText: 'At least 8 characters',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Update Password',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password flow (e.g., navigate to a forgot password screen)
                      print('Forgot your Password? tapped!');
                    },
                    child: const Text(
                      'Forget your Password?',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscureText, VoidCallback toggleObscure, {String? hintText, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        TextFormField( // Use TextFormField for validation capabilities
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: toggleObscure,
            ),
          ),
          style: const TextStyle(color: Colors.black),
          validator: validator,
        ),
      ],
    );
  }
}