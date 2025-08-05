// lib/models/habit_entry.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Define an enum for habit status to clearly distinguish completion types
enum HabitStatus {
  completed, // User marked as done (e.g., clicked 'Yes, I did it!')
  skipped,   // User chose not to do it or explicitly skipped (e.g., clicked 'No')
  pending,   // Default or not yet interacted with
  snoozed,   // User chose to snooze
}

class HabitEntry {
  final String? id; // Document ID from Firestore
  final String habitId; // The ID of the habit this entry belongs to
  final String userId;  // The ID of the user
  final DateTime date;  // The date this entry is for (normalized to start of day)
  final HabitStatus status; // Status of the habit for this day
  final String? notes; // Optional notes
  final DateTime? interactionTime; // The exact time the user interacted (e.g., clicked 'yes/no/snooze')

  HabitEntry({
    this.id,
    required this.habitId,
    required this.userId,
    required this.date,
    required this.status,
    this.notes,
    this.interactionTime,
  });

  // Factory constructor to create a HabitEntry from a Firestore DocumentSnapshot
  factory HabitEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HabitEntry(
      id: doc.id,
      habitId: data['habitId'] as String,
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      status: HabitStatus.values.firstWhere(
        (e) => e.toString() == 'HabitStatus.${data['status']}',
        orElse: () => HabitStatus.pending, // Default if status is not found
      ),
      notes: data['notes'] as String?,
      interactionTime: (data['interactionTime'] as Timestamp?)?.toDate(),
    );
  }

  // Method to convert a HabitEntry object to a Firestore-compatible Map
  Map<String, dynamic> toFirestore() {
    return {
      'habitId': habitId,
      'userId': userId,
      'date': Timestamp.fromDate(date), // Store as Timestamp in Firestore
      'status': status.toString().split('.').last, // Store enum as string
      'notes': notes,
      'interactionTime': interactionTime != null ? Timestamp.fromDate(interactionTime!) : null,
    };
  }
}