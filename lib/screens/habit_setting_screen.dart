// lib/screens/habit_setting_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:getsetgo/screens/create_new_habit_screen.dart';
import 'package:getsetgo/screens/logout_screen.dart';
import 'package:getsetgo/widgets/animated_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:getsetgo/models/habit.dart';
import 'package:intl/intl.dart';
import 'package:getsetgo/services/habit_service.dart';
import 'package:getsetgo/screens/edit_habit_screen.dart';
import 'package:getsetgo/services/notification_service.dart'; // Import NotificationService

class HabitSettingScreen extends StatefulWidget {
  // ADDED: Optional habitId parameter for navigation from notifications
  final String? habitId;

  const HabitSettingScreen({super.key, this.habitId}); // Updated constructor

  @override
  _HabitSettingScreenState createState() => _HabitSettingScreenState();
}

class _HabitSettingScreenState extends State<HabitSettingScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final User? currentUser = FirebaseAuth.instance.currentUser;
  late final HabitService _habitService;
  late final NotificationService _notificationService; // Declare NotificationService

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _habitService = HabitService();
    _notificationService = NotificationService(); // Initialize NotificationService
    debugPrint('DEBUG HABIT SETTING: Initialized _selectedDay: $_selectedDay');

    // If a habitId is passed, you might want to automatically select that habit
    // or navigate to its edit screen. For now, we just print.
    if (widget.habitId != null) {
      debugPrint('DEBUG HABIT SETTING: Launched with habitId: ${widget.habitId}');
      // You could add logic here to fetch the specific habit and display its details
      // or navigate to EditHabitScreen for it.
    }
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'HABIT SETTING',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogoutScreen()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return _isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!mounted) return;
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    debugPrint('DEBUG HABIT SETTING: Calendar Day Selected: $_selectedDay');
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    if (!mounted) return;
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                headerVisible: false,
                daysOfWeekVisible: true,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
                  weekendTextStyle: const TextStyle(color: Colors.white70, fontSize: 16.0),
                  todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  rowDecoration: const BoxDecoration(color: Colors.transparent),
                  defaultDecoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.0),
                  weekendStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  formatButtonTextStyle: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateNewHabitScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('New Habit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.add, size: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: currentUser == null
                    ? const Center(
                        child: Text(
                          'Please log in to view your habits.',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : StreamBuilder<List<Habit>>(
                        stream: _habitService.getHabitsStream(),
                        builder: (context, snapshot) {
                          debugPrint('DEBUG HABIT SETTING: StreamBuilder building...');
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            debugPrint('DEBUG HABIT SETTING: Connection state: Waiting');
                            return const Center(child: CircularProgressIndicator(color: Colors.blue));
                          }
                          if (snapshot.hasError) {
                            debugPrint('DEBUG HABIT SETTING: Snapshot has error: ${snapshot.error}');
                            return Center(
                                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            debugPrint('DEBUG HABIT SETTING: No data or empty docs. hasData: ${snapshot.hasData}, data.isEmpty: ${snapshot.data?.isEmpty}');
                            return const Center(
                              child: Text(
                                'No habits found. Click "New Habit" to add one!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            );
                          }

                          debugPrint('DEBUG HABIT SETTING: Total habits fetched: ${snapshot.data!.length}');

                          // Filter habits for the selected day
                          debugPrint('DEBUG HABIT SETTING: Filtering habits for selected day: $_selectedDay');
                          final habitsForSelectedDay = snapshot.data!.where((habit) {
                            if (_selectedDay == null) {
                              debugPrint('DEBUG HABIT SETTING: _selectedDay is null, skipping habit ${habit.name}.');
                              return false;
                            }

                            final selectedDayDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                            final habitStartDate = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
                            final habitEndDate = DateTime(habit.endDate.year, habit.endDate.month, habit.endDate.day);

                            final bool matches = (selectedDayDate.isAfter(habitStartDate.subtract(const Duration(days: 1))) || _isSameDay(selectedDayDate, habitStartDate)) &&
                                                 (selectedDayDate.isBefore(habitEndDate.add(const Duration(days: 1))) || _isSameDay(selectedDayDate, habitEndDate));

                            debugPrint('DEBUG HABIT SETTING: Habit: ${habit.name}, SelectedDay: $selectedDayDate, StartDate: $habitStartDate, EndDate: $habitEndDate, Matches: $matches');
                            return matches;
                          }).toList();

                          debugPrint('DEBUG HABIT SETTING: Habits found for selected day: ${habitsForSelectedDay.length}');

                          if (habitsForSelectedDay.isEmpty) {
                            return Center(
                              child: Text(
                                'No habits scheduled for ${DateFormat('MMM d, yyyy').format(_selectedDay!)}.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: habitsForSelectedDay.length,
                            itemBuilder: (context, index) {
                              final habit = habitsForSelectedDay[index];
                              debugPrint('DEBUG HABIT SETTING: Building Habit Card for: ${habit.name}');
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: _buildHabitCard(habit),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    debugPrint('DEBUG HABIT SETTING: Inside _buildHabitCard for habit: ${habit.name}');
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  habit.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Goal: ${habit.duration}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          if (habit.category != null && habit.category!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Category: ${habit.category}',
              style: const TextStyle(fontSize: 14, color: Colors.white60),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Duration: ${DateFormat('MMM d, yyyy').format(habit.startDate)} - ${DateFormat('MMM d, yyyy').format(habit.endDate)}',
            style: const TextStyle(fontSize: 14, color: Colors.white60),
          ),
          if (habit.reminderTime != null) ...[
            const SizedBox(height: 4),
            Text(
              'Daily Reminder: ${habit.reminderTime!.format(context)}',
              style: const TextStyle(fontSize: 14, color: Colors.white60),
            ),
          ],
          if (habit.notes != null && habit.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: ${habit.notes}',
              style: const TextStyle(fontSize: 14, color: Colors.white54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditHabitScreen(habitToEdit: habit),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                  onPressed: () async {
                    final confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          backgroundColor: Colors.blueGrey[900],
                          title: const Text('Delete Habit', style: TextStyle(color: Colors.white)),
                          content: Text('Are you sure you want to delete "${habit.name}"?', style: const TextStyle(color: Colors.white70)),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(false);
                              },
                            ),
                            TextButton(
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(true);
                              },
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete == true) {
                      try {
                        if (habit.id != null && habit.id!.isNotEmpty) {
                          await _habitService.deleteHabit(habit.id!);
                          // CORRECTED: Call cancelNotification with the correct string ID
                          await _notificationService.cancelNotification('daily_${habit.id!}');

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${habit.name} deleted successfully!')),
                            );
                          }
                        } else {
                          debugPrint("ERROR HABIT SETTING: Attempted to delete habit with null or empty ID.");
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error: Habit ID is missing.')),
                            );
                          }
                        }
                      } on Exception catch (e) {
                        debugPrint("ERROR HABIT SETTING: Failed to delete habit or cancel notifications: $e");
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete habit: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}