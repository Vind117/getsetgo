// lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'package:getsetgo/widgets/animated_background.dart';
import 'package:getsetgo/screens/change_password_screen.dart';
import 'package:getsetgo/screens/help_and_support_screen.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String _initialName = 'ARAVIND';
  String _initialMobileNumber = '016-2242770';
  String _initialEmail = 'Aravin1107@gmail.com';
  String _initialCountry = 'Malaysia'; // Added for initial country display

  String? _profileImageUrl; // To store the URL of the profile picture

  bool _isLoading = false; // To show loading state

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load existing user data when screen initializes
  }

  // Method to load user data from Firebase Auth and Firestore
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? ''; // Email from Firebase Auth

      // Fetch additional profile data from Firestore
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          _nameController.text = data?['name'] ?? '';
          _mobileNumberController.text = data?['mobileNumber'] ?? '';
          _countryController.text = data?['country'] ?? '';
          _profileImageUrl = data?['profileImageUrl']; // Get profile image URL
        } else {
          // If no Firestore doc, initialize with defaults or current Auth data
          _nameController.text = user.displayName ?? '';
        }
      } catch (e) {
        print("Error loading user profile from Firestore: $e");
        // Fallback to Firebase Auth data if Firestore fails
        _nameController.text = user.displayName ?? '';
      }

      // Set initial values for comparison
      _initialName = _nameController.text;
      _initialMobileNumber = _mobileNumberController.text;
      _initialEmail = _emailController.text;
      _initialCountry = _countryController.text;

      // Check for profile picture from Firebase Auth (if available and no Firestore URL)
      if (user.photoURL != null && _profileImageUrl == null) {
        _profileImageUrl = user.photoURL;
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: false, // Optional, can be true to show phone code
      onSelect: (Country country) {
        setState(() {
          _countryController.text = country.name;
        });
      },
    );
  }

  // Method to save profile updates
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('No user logged in.', Colors.red);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Update Firebase Auth profile (display name, photoURL if _profileImageUrl exists)
      await user.updateDisplayName(_nameController.text);
      if (_profileImageUrl != null) {
        await user.updatePhotoURL(_profileImageUrl);
      } else {
        await user.updatePhotoURL(null);
      }

      // 2. Update Firestore user document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'name': _nameController.text,
          'mobileNumber': _mobileNumberController.text,
          'email': _emailController.text, // Store email in Firestore too for easy access
          'country': _countryController.text,
          'profileImageUrl': _profileImageUrl, // Store image URL in Firestore (will be existing URL or null)
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // Use merge to update existing fields without overwriting others
      );

      _showSnackBar('Profile updated successfully!', Colors.green);

      // Reload profile to update initial values and UI
      await _loadUserProfile(); // This will also update the _profileImageUrl and _initialName etc.
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Failed to update Firebase Auth profile: ${e.message}', Colors.red);
    } on FirebaseException catch (e) {
      // Catch FirebaseException for Firestore specific errors
      _showSnackBar('Failed to update profile in Firestore: ${e.message}', Colors.red);
    } catch (e) {
      _showSnackBar('An unexpected error occurred: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground( // <<< Move AnimatedBackground here to wrap the entire Scaffold
      child: Scaffold(
        backgroundColor: Colors.transparent, // Important for AnimatedBackground
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Start of change: Custom leading icon for the back button
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white), // Change: Icon changed to arrow_back_ios and color set to white
            onPressed: () {
              Navigator.of(context).pop(); // Change: Functionality to go back to the previous screen
            },
          ),
          // End of change
          title: const Text(
            'EDIT PROFILE',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Profile picture display (no longer clickable for customization)
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey.shade800,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : const AssetImage('assets/images/avatar.png') as ImageProvider<Object>?,
                        child: _profileImageUrl == null
                            ? const Icon(Icons.person, size: 40, color: Colors.white70) // Changed to person icon
                            : null,
                      ),
                      const SizedBox(height: 40),
                      _buildTextField(
                        context,
                        label: 'Name',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        context,
                        label: 'Mobile Number',
                        controller: _mobileNumberController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          if (value.length < 7) { // Basic validation
                            return 'Mobile number too short';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        context,
                        label: 'Email Address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true, // Email is typically read-only
                        suffixIcon: const Icon(Icons.lock, size: 20, color: Colors.blue),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        context,
                        label: 'Country',
                        controller: _countryController,
                        readOnly: true, // Make country field read-only as it's picked via dialog
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_drop_down, size: 24, color: Colors.blue),
                          onPressed: _showCountryPicker,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your country';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                          shadowColor: Colors.black.withOpacity(0.5),
                        ),
                        child: const Text(
                          'Save Profile',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                          );
                        },
                        child: const Text(
                          'Change Password',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HelpAndSupportScreen()),
                          );
                        },
                        child: const Text(
                          'Help & Support',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        TextInputType keyboardType = TextInputType.text,
        bool readOnly = false,
        List<TextInputFormatter>? inputFormatters,
        Widget? suffixIcon,
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          validator: validator,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.white54, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            suffixIcon: suffixIcon ?? (readOnly ? null : const Icon(Icons.edit, size: 20, color: Colors.blue)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}