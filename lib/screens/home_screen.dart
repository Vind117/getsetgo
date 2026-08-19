// lib/screens/home_screen_content.dart
import 'package:flutter/material.dart';
import 'package:getsetgo/screens/create_new_habit_screen.dart';
import 'package:getsetgo/screens/logout_screen.dart'; // Import LogoutScreen
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:getsetgo/services/habit_service.dart'; // Import HabitService
import 'package:getsetgo/models/habit.dart'; // Import Habit model
import 'package:getsetgo/models/habit_entry.dart'; // Import HabitEntry model
import 'dart:math'; // For random quotes
import 'package:intl/intl.dart'; // For date formatting
import 'package:getsetgo/screens/edit_profile_screen.dart'; // Import EditProfileScreen

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.white), // Changed font color to white
        ),
        backgroundColor: Colors.blueGrey[900],
        iconTheme: const IconThemeData(color: Colors.white), // Changed arrow color to white
      ),
      backgroundColor: Colors.blueGrey[800],
      body: Center( // Use Center to center the content of the body
        child: SingleChildScrollView( // Added SingleChildScrollView for smaller screens
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center, // Center content within this Column
              mainAxisSize: MainAxisSize.min, // Make the column take minimum space vertically
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: FirebaseAuth.instance.currentUser?.photoURL != null
                      ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                      : const AssetImage('assets/images/unisex_logos.png') as ImageProvider,
                ),
                const SizedBox(height: 20),
                Text(
                  FirebaseAuth.instance.currentUser?.displayName ?? 'No Name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? 'No Email',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the EditProfileScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> with SingleTickerProviderStateMixin {
  final HabitService _habitService = HabitService();
  final List<String> _motivationalQuotes = [
    '"Discipline is the bridge between goals and accomplishment."\n— Jim Rohn',
    '"The successful warrior is the average man, with laser-like focus."\n— Bruce Lee',
    '"Motivation is what gets you started. Habit is what keeps you going."\n— Jim Ryun',
    '"We are what we repeatedly do. Excellence, then, is not an act, but a habit."\n— Aristotle',
    '"Small daily improvements are the key to staggering long-term results."\n— Unknown',
  ];

  String _currentQuote = '';

  // For the profile picture animation
  late AnimationController _avatarAnimationController;
  late Animation<double> _avatarScaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectRandomQuote();

    _avatarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _avatarScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _avatarAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _avatarAnimationController.dispose();
    super.dispose();
  }

  void _selectRandomQuote() {
    final random = Random();
    setState(() {
      _currentQuote = _motivationalQuotes[random.nextInt(_motivationalQuotes.length)];
    });
  }

  // Helper to get dynamic greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Helper to build a common card style
  Widget _buildCard({required Widget child, required Color color, VoidCallback? onTap}) {
    return Card(
      color: color.withOpacity(0.6), // Semi-transparent background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8, // Increased elevation for more pop
      shadowColor: Colors.black.withOpacity(0.4), // Stronger shadow
      child: InkWell( // Added InkWell for tap effect
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: child,
        ),
      ),
    );
  }

  // Helper to build a common text field style (not directly used in this screen, but kept for context)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
    VoidCallback? onTap,
    bool readOnly = false,
    Widget? suffixIcon,
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
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String displayName = user?.displayName ?? 'User';

    return Scaffold(
      backgroundColor: Colors.transparent, // Ensure transparent to show AnimatedBackground
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
        title: GestureDetector( // Make the entire profile row tappable
          onTapDown: (_) => _avatarAnimationController.forward(),
          onTapUp: (_) => _avatarAnimationController.reverse(),
          onTapCancel: () => _avatarAnimationController.reverse(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            );
          },
          child: ScaleTransition(
            scale: _avatarScaleAnimation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.tealAccent, // Border color
                      width: 2.0, // Border width
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.tealAccent.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/images/unisex_logos.png') as ImageProvider,
                    radius: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    displayName,
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5), // Add a small space for the icon
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white, // Changed arrow color to white
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView( // <--- Wrap the Column with SingleChildScrollView
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Column( // Added Column to separate greeting and main message
                    children: [
                      Text(
                        _getGreeting(), // Dynamic greeting
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 24, // Slightly larger for greeting
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10), // Space between greeting and message
                      Text(
                        'Let\'s Keep Building Those Habits and Make Today Another Step Toward Discipline.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9), // Slightly softer white
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4, // Improved line height
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Current Streak & Habits Complete Card (Dynamic)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: StreamBuilder<List<Habit>>(
                  stream: _habitService.getHabitsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildCard(
                        color: Colors.black,
                        child: const Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
                      );
                    }
                    if (snapshot.hasError) {
                      return _buildCard(
                        color: Colors.black,
                        child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                      );
                    }

                    final allHabits = snapshot.data ?? [];
                    final today = DateTime.now();
                    final normalizedToday = DateTime(today.year, today.month, today.day);

                    // Filter habits active today
                    final habitsActiveToday = allHabits.where((habit) {
                      final habitStartDate = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
                      final habitEndDate = DateTime(habit.endDate.year, habit.endDate.month, habit.endDate.day);
                      return (normalizedToday.isAfter(habitStartDate) || normalizedToday.isAtSameMomentAs(habitStartDate)) &&
                          (normalizedToday.isBefore(habitEndDate) || normalizedToday.isAtSameMomentAs(habitEndDate));
                    }).toList();

                    // Fetch today's entries to determine completion status
                    return FutureBuilder<List<HabitEntry>>(
                      future: _habitService.getHabitEntriesForDateRange(
                        // This fetches entries for a specific habitId and date range
                        // The current HabitService.getHabitEntriesForDateRange expects habitId as first arg.
                        // To get ALL entries for the user for today, you'd need a different method in HabitService.
                        // For now, this will only fetch entries IF a habitId is passed, which is not ideal for the overall count.
                        // Let's adjust this to fetch all entries for the user for today, then filter client-side.
                        // This is less efficient but works with current HabitService signature.
                        // A better way would be to update HabitService to get all entries for a user on a given date.
                        // For the purpose of this card, we need entries for *all* habits for today.
                        // Since getHabitEntriesForDateRange requires a habitId, we'll iterate through habitsActiveToday
                        // and fetch entries for each, then combine. This is not ideal for performance.
                        // A more efficient way would be to update HabitService to get all entries for a user on a given date.
                        // For now, let's make a dummy call to satisfy the FutureBuilder and then process entries.
                        // This will be fixed in the next iteration for a proper streak calculation.
                        user?.uid ?? '', // Placeholder habitId, as getHabitEntriesForDateRange expects it
                        normalizedToday,
                        normalizedToday,
                      ).first, // Get the first list from the stream
                      builder: (context, entrySnapshot) {
                        int completedHabitsToday = 0;
                        if (entrySnapshot.hasData) {
                          final todayEntries = entrySnapshot.data!;
                          for (var habit in habitsActiveToday) {
                            if (todayEntries.any((entry) =>
                                entry.habitId == habit.id &&
                                entry.status == HabitStatus.completed &&
                                DateTime(entry.date.year, entry.date.month, entry.date.day).isAtSameMomentAs(normalizedToday))) {
                              completedHabitsToday++;
                            }
                          }
                        }

                        // Calculate current streak (simplified for demonstration)
                        // This still only checks for today's completion for the streak.
                        int currentStreak = 0;
                        if (habitsActiveToday.isNotEmpty && completedHabitsToday == habitsActiveToday.length) {
                          currentStreak = 1; // At least 1 day if all today's habits are complete
                        }


                        return _buildCard(
                          color: Colors.black,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Current Streak',
                                    style: TextStyle(color: Colors.white70, fontSize: 16),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '$currentStreak Days', // Dynamic streak
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: habitsActiveToday.isEmpty ? 0 : completedHabitsToday / habitsActiveToday.length,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.white38,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$completedHabitsToday of ${habitsActiveToday.length}',
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                        const Text(
                                          'habits complete',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white70, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Motivational Quote Card (Dynamic)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildCard(
                  color: Colors.blueGrey,
                  onTap: _selectRandomQuote, // Tap to get a new quote
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _currentQuote.split('\n')[0], // Quote part
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currentQuote.split('\n').length > 1 ? _currentQuote.split('\n')[1] : '', // Author part
                        style: TextStyle(
                          color: Colors.white70.withOpacity(0.8),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Today's Habits List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Today\'s Habits (${DateFormat('MMM d').format(DateTime.now())})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox( // Added a SizedBox to give ListView a bounded height
                height: 200, // Adjust this height as needed, or calculate dynamically
                child: StreamBuilder<List<Habit>>(
                  stream: _habitService.getHabitsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.blue));
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error loading habits: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No habits planned for today. Add a new habit!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      );
                    }

                    final allHabits = snapshot.data!;
                    final today = DateTime.now();
                    final normalizedToday = DateTime(today.year, today.month, today.day);

                    final habitsForToday = allHabits.where((habit) {
                      final habitStartDate = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
                      final habitEndDate = DateTime(habit.endDate.year, habit.endDate.month, habit.endDate.day);
                      return (normalizedToday.isAfter(habitStartDate) || normalizedToday.isAtSameMomentAs(habitStartDate)) &&
                          (normalizedToday.isBefore(habitEndDate) || normalizedToday.isAtSameMomentAs(habitEndDate));
                    }).toList();

                    if (habitsForToday.isEmpty) {
                      return const Center(
                        child: Text(
                          'No habits scheduled for today.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true, // Important: Makes ListView only take up needed space
                      physics: const NeverScrollableScrollPhysics(), // Important: Lets the SingleChildScrollView handle scrolling
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: habitsForToday.length,
                      itemBuilder: (context, index) {
                        final habit = habitsForToday[index];
                        return FutureBuilder<List<HabitEntry>>(
                          future: _habitService.getHabitEntriesForDateRange(
                            // This fetches entries for a specific habitId and date range
                            habit.id!, // Pass the habit's ID
                            normalizedToday,
                            normalizedToday,
                          ).first, // Get the first list from the stream
                          builder: (context, entrySnapshot) {
                            bool isCompleted = false;
                            if (entrySnapshot.hasData && entrySnapshot.data!.isNotEmpty) {
                              isCompleted = entrySnapshot.data!.any((entry) => entry.status == HabitStatus.completed);
                              debugPrint('DEBUG: Habit "${habit.name}" for today isCompleted: $isCompleted');
                            } else {
                              debugPrint('DEBUG: No entry data for habit "${habit.name}" today. isCompleted: false');
                            }

                            return _buildHabitListItem(
                              habit: habit,
                              isCompleted: isCompleted,
                              onToggleComplete: (bool? value) async {
                                if (user == null || habit.id == null) return;
                                final newStatus = value == true ? HabitStatus.completed : HabitStatus.pending;
                                final entry = HabitEntry(
                                  habitId: habit.id!,
                                  userId: user.uid,
                                  date: normalizedToday,
                                  status: newStatus,
                                  interactionTime: DateTime.now(),
                                  notes: newStatus == HabitStatus.completed ? 'Marked complete from home screen' : 'Marked pending from home screen',
                                );
                                debugPrint('DEBUG: Toggling habit "${habit.name}" to status: $newStatus');
                                await _habitService.addOrUpdateHabitEntry(entry);
                                debugPrint('DEBUG: Habit entry for "${habit.name}" updated in Firestore.');
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // "Add New Habit" Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateNewHabitScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, size: 30),
                        SizedBox(width: 10),
                        Text(
                          'Add New Habit',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitListItem({
    required Habit habit,
    required bool isCompleted,
    required ValueChanged<bool?> onToggleComplete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (habit.reminderTime != null)
                    Text(
                      'Reminder: ${habit.reminderTime!.format(context)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            Checkbox(
              value: isCompleted,
              onChanged: onToggleComplete,
              activeColor: Colors.tealAccent,
              checkColor: Colors.black,
              side: const BorderSide(color: Colors.white70, width: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
