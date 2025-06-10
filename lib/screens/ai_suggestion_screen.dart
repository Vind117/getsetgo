import 'package:flutter/material.dart';

class AiSuggestionScreen extends StatefulWidget {
  const AiSuggestionScreen({super.key});

  @override
  _AiSuggestionScreenState createState() => _AiSuggestionScreenState();
}

class _AiSuggestionScreenState extends State<AiSuggestionScreen> {
  int weeklyStreak = 5; // 5/7 days
  int dailyGoal = 6; // Current daily goal
  int dailyProgress = 0; // Current daily intake
  List<String> feedbackList = []; // To store feedback
  final TextEditingController _feedbackController = TextEditingController();

  void logWater() {
    setState(() {
      if (dailyProgress < dailyGoal) {
        dailyProgress++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Goal reached for today!")),
        );
      }
    });
  }

  void acceptSuggestion() {
    setState(() {
      dailyGoal = 8;
      dailyProgress = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Goal updated to 8 glasses!")),
    );
  }

  void rejectSuggestion() {
    setState(() {
      // Do nothing, keep current goal
    });
  }

  void submitFeedback() {
    setState(() {
      if (_feedbackController.text.isNotEmpty) {
        feedbackList.add(_feedbackController.text);
        _feedbackController.clear();
      }
    });
    Navigator.pop(context); // Close the dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback submitted!")),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'AI SUGGESTION',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView( // Added for scrolling if content overflows
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Evening,',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text(
                'Aravind!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              // Drink Water Card
              Card(
                color: Colors.grey[100],
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
                        value: dailyProgress / dailyGoal,
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
                        child: const Text('+1 Glass'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // AI Suggestion Card
              Card(
                color: const Color(0xFF1A3A69),
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
                          color: Colors.white.withOpacity(0.8), // Removed const
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
                ),
              ),
              const SizedBox(height: 15),
              // Weekly Habit Trends Graph
              Card(
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 7,
                    child: Image.asset(
                      'assets/images/habit_trend_graph.png', // Replace with your graph image
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Journal Suggestion Card
              Card(
                color: Colors.grey[100],
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
                        'We noticed you journal more in the morning. Switch time?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              // Handle 'Yes' button tap
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                            ),
                            child: const Text(
                              'Yes',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Handle 'No' button tap
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3A69),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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