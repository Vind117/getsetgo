// lib/screens/create_new_habit_screen.dart

import 'package:flutter/material.dart';
import 'package:getsetgo/widgets/animated_background.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:getsetgo/models/habit.dart';
import 'package:getsetgo/services/habit_service.dart';
import 'package:getsetgo/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart'; // REQUIRED: Import permission_handler

class CreateNewHabitScreen extends StatefulWidget {
  const CreateNewHabitScreen({super.key});

  @override
  State<CreateNewHabitScreen> createState() => _CreateNewHabitScreenState();
}

class _CreateNewHabitScreenState extends State<CreateNewHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _habitNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _reminderTimeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedReminderTime; // Stored as TimeOfDay

  String? _selectedCategory;
  final List<String> _categories = [
    'Health',
    'Learning',
    'Productivity',
    'Self-Care',
    'Social',
    'Other',
  ];

  bool _isLoading = false;

  final HabitService _habitService = HabitService();
  final NotificationService _notificationService =
      NotificationService(); // Instantiate NotificationService

  @override
  void dispose() {
    _habitNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _durationController.dispose();
    _reminderTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.black87,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.blueGrey[900],
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
          _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _selectedEndDate = picked;
          _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF1A3A69),
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedReminderTime) {
      if (!mounted) return;
      setState(() {
        _selectedReminderTime = picked;
        _reminderTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _submitHabit() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to create a habit.')),
        );
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        print(
            'DEBUG: User is NOT logged in. Cannot save habit (from create_new_habit_screen).');
        return;
      }

      // --- START: Exact Alarm Permission Request ---
      var status = await Permission.scheduleExactAlarm.status;
      print('DEBUG: Exact alarm permission status: $status');

      if (status.isDenied) {
        status = await Permission.scheduleExactAlarm.request();
        print('DEBUG: Exact alarm permission status after request: $status');
      }

      if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Exact alarm permission is permanently denied. Please enable it in app settings.'),
              action: SnackBarAction(
                label: 'SETTINGS',
                onPressed: () {
                  openAppSettings(); // Opens app settings for the user
                },
              ),
            ),
          );
        }
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        print(
            'DEBUG: Exact alarm permission permanently denied. Cannot schedule notifications.');
        return; // Stop here if permission is not granted
      }

      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Exact alarm permission not granted. Notifications may not work.')),
          );
        }
        print(
            'DEBUG: Exact alarm permission not granted. Notifications will not be scheduled.');
        // We will still proceed with habit creation, but notifications won't work.
      }
      // --- END: Exact Alarm Permission Request ---

      print(
          'DEBUG: Current Authenticated User UID (from create_new_habit_screen): ${user.uid}');

      if (_selectedStartDate == null || _selectedEndDate == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both start and end dates.')),
        );
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        print('DEBUG: Start or end date is null.');
        return;
      }

      if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End date cannot be before start date.')),
        );
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        print('DEBUG: End date is before start date.');
        return;
      }

      if (_selectedReminderTime == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a reminder time for the habit.')),
        );
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        final newHabit = Habit(
          id: '', // Firestore will generate this
          userId: user.uid, // Ensure userId is set to the current user's UID
          name: _habitNameController.text.trim(),
          startDate: _selectedStartDate!,
          endDate: _selectedEndDate!,
          duration: _durationController.text.trim(),
          reminderTime: _selectedReminderTime, // Use the TimeOfDay object
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          category: _selectedCategory,
        );

        print('DEBUG: Habit object created:');
        print('   Name: ${newHabit.name}');
        print('   User ID (in Habit object): ${newHabit.userId}'); // Confirm UID in object
        print('   Start Date: ${newHabit.startDate}');
        print('   End Date: ${newHabit.endDate}');
        print('   Duration: ${newHabit.duration}');
        print('   Reminder Time: ${newHabit.reminderTime?.format(context)}');
        print('   Notes: ${newHabit.notes}');
        print('   Category: ${newHabit.category}');

        final String habitFirestoreId = await _habitService.addHabit(newHabit);

        print(
            'DEBUG: Habit saved successfully to Firestore with ID: $habitFirestoreId');

        // Only attempt to schedule notifications if exact alarm permission is granted
        if (status.isGranted) {
          for (int i = 0; i < 7; i++) {
            final DateTime scheduledDate = DateTime.now().add(Duration(days: i));
            final DateTime scheduledDateTime = DateTime(
              scheduledDate.year,
              scheduledDate.month,
              scheduledDate.day,
              _selectedReminderTime!.hour,
              _selectedReminderTime!.minute,
            );

            if (scheduledDateTime.isAfter(DateTime.now())) {
              await _notificationService.scheduleHabitNotification(
                notificationId:
                    '$habitFirestoreId-${scheduledDateTime.year}-${scheduledDateTime.month}-${scheduledDateTime.day}',
                habitName: newHabit.name,
                scheduledTime: scheduledDateTime,
                habitFirestoreId: habitFirestoreId,
              );
              print(
                  'DEBUG: Scheduled notification for ${newHabit.name} on ${DateFormat('dd/MM/yyyy HH:mm').format(scheduledDateTime)}');
            } else {
              print(
                  'DEBUG: Skipping past notification for ${newHabit.name} on ${DateFormat('dd/MM/yyyy HH:mm').format(scheduledDateTime)}');
            }
          }
        } else {
          print(
              'DEBUG: Skipping notification scheduling due to missing exact alarm permission.');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Habit created and notifications scheduled successfully!')),
          );
          Navigator.pop(context);
        }
        print('DEBUG: _submitHabit process finished.');
      } on FirebaseException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating habit: ${e.message}')),
          );
        }
        print('DEBUG: Firestore Error: ${e.code} - ${e.message}');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
          );
        }
        print('DEBUG: General Error: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      print('DEBUG: Form validation failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'CREATE NEW HABIT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _habitNameController,
                  label: 'HABIT NAME',
                  hintText: 'e.g., Read for 30 minutes',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a habit name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildDatePickerField(
                  controller: _startDateController,
                  label: 'START DATE',
                  hintText: 'DD/MM/YYYY',
                  onTap: () => _selectDate(context, isStartDate: true),
                  validator: (value) {
                    if (_selectedStartDate == null) {
                      return 'Please select a start date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildDatePickerField(
                  controller: _endDateController,
                  label: 'END DATE',
                  hintText: 'DD/MM/YYYY',
                  onTap: () => _selectDate(context, isStartDate: false),
                  validator: (value) {
                    if (_selectedEndDate == null) {
                      return 'Please select an end date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _durationController,
                  label: 'TARGET DURATION / GOAL',
                  hintText: 'e.g., 1 hour, 30 pages, 5 km',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a duration or goal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTimePickerField(
                  controller: _reminderTimeController,
                  label: 'SET DAILY REMINDER (Optional)',
                  hintText: 'Select Time',
                  onTap: () => _selectTime(context),
                ),
                const SizedBox(height: 20),
                _buildDropdownField<String>(
                  label: 'CATEGORY (Optional)',
                  value: _selectedCategory,
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (!mounted) return;
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  hintText: 'Select a category',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _notesController,
                  label: 'NOTES (Optional)',
                  hintText: 'Add any specific notes about this habit',
                  maxLines: 3,
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.red))
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitHabit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDA363C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    VoidCallback? onTap,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildTimePickerField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: const Icon(Icons.access_time, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          ),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}

