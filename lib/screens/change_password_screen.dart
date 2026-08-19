// lib/screens/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:getsetgo/widgets/animated_background.dart';
import 'package:firebase_auth/firebase_auth.dart'; // REQUIRED: For Firebase Authentication
import 'package:getsetgo/screens/forgot_password_screen.dart'; // REQUIRED: Import ForgotPasswordScreen

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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

      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user is currently signed in.')),
          );
          return;
        }

        // Re-authenticate the user with their current password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, // Assuming email is not null for signed-in users
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);

        // Update the password
        await user.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );

        // Clear the fields after successful update
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        if (mounted) {
          Navigator.pop(context); // Go back after successful update
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'wrong-password') {
          message = 'Incorrect current password.';
        } else if (e.code == 'requires-recent-login') {
          message =
              'This operation is sensitive and requires recent authentication. Please log in again.';
        } else if (e.code == 'weak-password') {
          message = 'The new password is too weak.';
        } else {
          message = 'Failed to update password: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Firebase Auth Error (Change Password): ${e.code} - ${e.message}');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating password: ${e.toString()}')),
        );
        print('General Error (Change Password): ${e.toString()}');
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to ForgotPasswordScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
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

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    VoidCallback toggleObscure, {
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        TextFormField(
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
