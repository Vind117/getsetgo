// lib/models/habit.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Habit {
  final String? id; // Made nullable for new habits
  final String userId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String duration; // e.g., "1 hour", "30 mins"
  final TimeOfDay? reminderTime; // Optional daily reminder time
  final String? notes; // New feature: Add notes to a habit
  final String? category; // New feature: Categorize habits (e.g., Health, Learning)

  Habit({
    this.id, // Made optional for new habits
    required this.userId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.duration,
    this.reminderTime,
    this.notes,
    this.category,
  });

  // Convert a Habit object into a Map for Firestore
  // Renamed to toFirestore for consistency
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'duration': duration,
      'reminderTimeHour': reminderTime?.hour, // Store hour separately
      'reminderTimeMinute': reminderTime?.minute, // Store minute separately
      'notes': notes,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(), // Optional: for tracking creation time
    };
  }

  // Create a Habit object from a Firestore document snapshot
  factory Habit.fromFirestore(DocumentSnapshot doc) {
    print('DEBUG HABIT MODEL: Starting fromFirestore for doc ID: ${doc.id}');
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Explicitly cast to Map<String, dynamic>
    print('DEBUG HABIT MODEL: Raw data from Firestore: $data');

    // Parse startDate
    DateTime parsedStartDate;
    try {
      parsedStartDate = (data['startDate'] as Timestamp).toDate();
      print('DEBUG HABIT MODEL: Parsed startDate: $parsedStartDate');
    } catch (e) {
      print('ERROR HABIT MODEL: Failed to parse startDate for doc ${doc.id}: $e');
      parsedStartDate = DateTime.now(); // Fallback to current date
    }

    // Parse endDate
    DateTime parsedEndDate;
    try {
      parsedEndDate = (data['endDate'] as Timestamp).toDate();
      print('DEBUG HABIT MODEL: Parsed endDate: $parsedEndDate');
    } catch (e) {
      print('ERROR HABIT MODEL: Failed to parse endDate for doc ${doc.id}: $e');
      parsedEndDate = DateTime.now(); // Fallback to current date
    }

    // Parse reminderTime
    TimeOfDay? parsedReminderTime;
    if (data['reminderTimeHour'] != null && data['reminderTimeMinute'] != null) {
      try {
        parsedReminderTime = TimeOfDay(
          hour: data['reminderTimeHour'] as int, // Explicit cast to int
          minute: data['reminderTimeMinute'] as int, // Explicit cast to int
        );
        print('DEBUG HABIT MODEL: Parsed reminderTime: $parsedReminderTime');
      } catch (e) {
        print('ERROR HABIT MODEL: Failed to parse reminderTime for doc ${doc.id}: $e');
        parsedReminderTime = null;
      }
    } else {
      print('DEBUG HABIT MODEL: reminderTime is null or incomplete.');
    }

    final habit = Habit(
      id: doc.id, // Use doc.id directly for the ID
      userId: data['userId'] ?? '',
      name: data['name'] ?? 'Unnamed Habit',
      startDate: parsedStartDate,
      endDate: parsedEndDate,
      duration: data['duration'] ?? '',
      reminderTime: parsedReminderTime,
      notes: data['notes'],
      category: data['category'],
    );
    print('DEBUG HABIT MODEL: Successfully created Habit object: ${habit.name} for User ID: ${habit.userId}');
    return habit;
  }

  // Helper method to create a new Habit instance with some updated fields
  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? duration,
    TimeOfDay? reminderTime,
    String? notes,
    String? category,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      duration: duration ?? this.duration,
      reminderTime: reminderTime ?? this.reminderTime,
      notes: notes ?? this.notes,
      category: category ?? this.category,
    );
  }
}