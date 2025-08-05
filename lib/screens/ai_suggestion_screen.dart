// lib/screens/ai_suggestion_screen.dart
import 'package:flutter/material.dart';
import 'package:getsetgo/screens/logout_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:getsetgo/models/habit_entry.dart';
import 'package:getsetgo/services/habit_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Import for StreamSubscription

class AiSuggestionScreen extends StatefulWidget {
  const AiSuggestionScreen({super.key});

  @override
  _AiSuggestionScreenState createState() => _AiSuggestionScreenState();
}

class _AiSuggestionScreenState extends State<AiSuggestionScreen> {
  final HabitService _habitService = HabitService();
  User? _currentUser;
  List<HabitEntry> _habitEntries = [];
  int weeklyStreak = 0;
  int dailyGoal = 6; // Default, can be dynamic
  int dailyProgress = 0;
  String morningJournalSuggestion = "We noticed you journal more in the morning. Switch time?";

  // StreamSubscription to manage the Firestore listener
  StreamSubscription<List<HabitEntry>>? _habitEntriesSubscription;

  // --- RESTORED FEEDBACK ELEMENTS ---
  List<String> feedbackList = [];
  final TextEditingController _feedbackController = TextEditingController();
  // --- END RESTORED FEEDBACK ELEMENTS ---

  @override
  void initState() {
    super.initState();
    _currentUser = _habitService.currentUser;
    if (_currentUser != null) {
      _fetchHabitEntries();
    }
  }

  // Fetch habit entries from Firestore
  void _fetchHabitEntries() {
    // Cancel any existing subscription to prevent multiple listeners
    _habitEntriesSubscription?.cancel();

    // IMPORTANT: 'drinkWater' is a placeholder habitId.
    // In a real app, you would fetch all habits for the user,
    // and then fetch entries for each of those habits.
    // For now, if you haven't created a habit with ID 'drinkWater'
    // this stream will likely be empty.
    _habitEntriesSubscription = _habitService.getHabitEntriesForDateRange(
      'drinkWater', // Assuming 'drinkWater' is a habitId
      DateTime.now().subtract(const Duration(days: 7)),
      DateTime.now(),
    ).listen((entries) {
      // Check if the widget is still mounted before calling setState
      if (!mounted) {
        return;
      }
      setState(() {
        _habitEntries = entries;
        _calculateMetrics();
        _analyzeJournalingTimes();
      });
    }, onError: (error) {
      // Add error handling for the stream
      print('Error fetching habit entries: $error');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching habit data: $error")),
      );
    });
  }

  void _calculateMetrics() {
    final today = DateTime.now();
    int currentDailyProgress = 0;
    int currentWeeklyStreak = 0;

    for (var entry in _habitEntries) {
      if (entry.habitId == 'drinkWater' &&
          entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day &&
          entry.status == HabitStatus.completed) {
        // Assuming 'notes' can indicate the quantity for water.
        // You might need a more robust way to store quantities.
        try {
          final glassesLogged = int.tryParse(entry.notes!.split(' ')[0]); // Use tryParse for safety
          currentDailyProgress += glassesLogged ?? 1; // Add 1 if parsing fails
        } catch (e) {
          currentDailyProgress++;
        }
      }
    }

    Set<String> completedDays = {};
    for (var entry in _habitEntries) {
      if (entry.habitId == 'drinkWater' && entry.status == HabitStatus.completed) {
        completedDays.add(DateFormat('yyyy-MM-dd').format(entry.date));
      }
    }
    currentWeeklyStreak = completedDays.length;

    // Check if mounted before setState
    if (!mounted) {
      return;
    }
    setState(() {
      dailyProgress = currentDailyProgress;
      weeklyStreak = currentWeeklyStreak;
    });
  }

  void _analyzeJournalingTimes() {
    Map<int, int> hourCounts = {};

    for (var entry in _habitEntries) {
      // You'd need to filter by a specific habitId for journaling if you have one
      // For now, let's just analyze completion times in general for demonstration
      if (entry.status == HabitStatus.completed && entry.interactionTime != null) {
        final hour = entry.interactionTime!.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }

    // Check if mounted before setState
    if (!mounted) {
      return;
    }

    if (hourCounts.isNotEmpty) {
      int mostFrequentHour = -1;
      int maxCount = 0;
      hourCounts.forEach((hour, count) {
        if (count > maxCount) {
          maxCount = count;
          mostFrequentHour = hour;
        }
      });

      if (mostFrequentHour != -1) {
        String timeOfDay = '';
        if (mostFrequentHour >= 5 && mostFrequentHour < 12) {
          timeOfDay = 'morning';
        } else if (mostFrequentHour >= 12 && mostFrequentHour < 17) {
          timeOfDay = 'afternoon';
        } else {
          timeOfDay = 'evening';
        }

        setState(() {
          morningJournalSuggestion = "We noticed you're most active in the $timeOfDay. Consider adjusting your reminders!";
        });
      } else {
        setState(() {
          morningJournalSuggestion = "We're still learning your habits! Keep logging for personalized insights.";
        });
      }
    } else {
      setState(() {
        morningJournalSuggestion = "No journal entries found for analysis. Start logging your habits!";
      });
    }
  }

  void logWater() async {
    final user = FirebaseAuth.instance.currentUser; // Get current user here
    if (user == null) {
      if (!mounted) return; // Check mounted before showing SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to log water.")),
      );
      print('DEBUG: User is NOT logged in. Cannot log water (from ai_suggestion_screen).'); // Added more explicit message
      return;
    }

    // *** THIS IS THE CRUCIAL DEBUG PRINT ***
    print('DEBUG: Current Authenticated User UID (from ai_suggestion_screen): ${user.uid}');

    if (dailyProgress < dailyGoal) {
      final newEntry = HabitEntry(
        habitId: 'drinkWater',
        userId: user.uid, // Ensure you're using 'user.uid' here
        date: DateTime.now(),
        status: HabitStatus.completed,
        interactionTime: DateTime.now(),
        notes: '${dailyProgress + 1} glasses logged',
      );
      try {
        await _habitService.addOrUpdateHabitEntry(newEntry);
        // No setState here, as _fetchHabitEntries will update via stream
      } catch (e) {
        if (!mounted) return; // Check mounted before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to log water: $e")),
        );
        print('DEBUG: Failed to log water: $e'); // Add print for error
      }
    } else {
      if (!mounted) return; // Check mounted before showing SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Goal reached for today!")),
      );
    }
  }

  void acceptSuggestion() async {
    if (!mounted) return; // Check mounted before setState
    setState(() {
      dailyGoal = 8;
    });
    if (!mounted) return; // Check mounted before showing SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Goal updated to 8 glasses locally!")),
    );
  }

  void rejectSuggestion() {
    if (!mounted) return; // Check mounted before showing SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Suggestion dismissed.")),
    );
  }

  // --- RESTORED submitFeedback METHOD ---
  void submitFeedback() {
    if (!mounted) return; // Check mounted before setState
    setState(() {
      if (_feedbackController.text.isNotEmpty) {
        feedbackList.add(_feedbackController.text);
        _feedbackController.clear();
      }
    });
    // Navigator.pop(context) doesn't need mounted check as it's a direct navigation
    Navigator.pop(context); // Close the dialog
    if (!mounted) return; // Check mounted before showing SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback submitted!")),
    );
  }
  // --- END RESTORED submitFeedback METHOD ---

  @override
  void dispose() {
    _feedbackController.dispose(); // Ensure controller is disposed
    _habitEntriesSubscription?.cancel(); // Cancel the stream subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AI SUGGESTION',
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Evening,',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Aravind!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              // Drink Water Card
              Card(
                color: Colors.white.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Drink Water',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Weekly Streak: $weeklyStreak/7 days',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: weeklyStreak / 7,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Daily Goal: $dailyProgress/$dailyGoal glasses',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: dailyGoal == 0 ? 0 : dailyProgress / dailyGoal,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: logWater,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Add a unique heroTag if this button is part of a Hero animation
                        // heroTag: 'logWaterFab', // Example unique tag
                        child: const Text('+1 Glass', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // AI Suggestion Card
              Card(
                color: const Color(0xFF1A3A69).withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You\'re doing great!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Want to try 8 glasses daily?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: acceptSuggestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Yes, try 8',
                              style: TextStyle(color: Color(0xFF1A3A69)),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: rejectSuggestion,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'No, keep 6',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Tell us why'),
                              content: TextField(
                                controller: _feedbackController,
                                decoration: const InputDecoration(hintText: 'Your feedback...'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: submitFeedback,
                                  child: const Text('Submit'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          'Tell us why',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Weekly Habit Trends',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              // Weekly Habit Trends Graph
              Card(
                color: Colors.white.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 7,
                    child: _WeeklyHabitTrendGraph(mockHabitData: _habitEntries),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Journal Suggestion Card (Now dynamic based on _analyzeJournalingTimes)
              Card(
                color: Colors.white.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        morningJournalSuggestion,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              if (!mounted) return; // Check mounted before showing SnackBar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Time switch accepted (action to be implemented).")),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                            ),
                            child: const Text(
                              'Yes',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (!mounted) return; // Check mounted before showing SnackBar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Time switch dismissed.")),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3A69),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                            ),
                            child: const Text(
                              'No',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyHabitTrendGraph extends StatelessWidget {
  final List<HabitEntry> mockHabitData;

  const _WeeklyHabitTrendGraph({
    super.key,
    required this.mockHabitData,
  });

  String getWeekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  List<FlSpot> getChartData() {
    Map<int, int> completionsPerDay = {};
    DateTime now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      completionsPerDay[date.weekday] = 0;
    }

    for (var entry in mockHabitData) {
      if (entry.habitId == 'drinkWater' && entry.status == HabitStatus.completed) {
        final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
        final todayNormalized = DateTime(now.year, now.month, now.day);

        int daysAgo = todayNormalized.difference(entryDate).inDays;

        if (daysAgo >= 0 && daysAgo < 7) {
          completionsPerDay[entry.date.weekday] =
              (completionsPerDay[entry.date.weekday] ?? 0) + 1;
        }
      }
    }

    List<FlSpot> spots = [];
    List<int> sortedWeekdays = [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ];

    for (int i = 0; i < sortedWeekdays.length; i++) {
      final weekday = sortedWeekdays[i];
      final completions = completionsPerDay[weekday] ?? 0;
      spots.add(FlSpot(i.toDouble(), completions.toDouble()));
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int weekdayIndex = value.toInt();
                final List<int> sortedWeekdays = [
                  DateTime.monday,
                  DateTime.tuesday,
                  DateTime.wednesday,
                  DateTime.thursday,
                  DateTime.friday,
                  DateTime.saturday,
                  DateTime.sunday,
                ];
                final int weekday = sortedWeekdays[weekdayIndex];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    getWeekdayShort(weekday),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: getChartData(),
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
