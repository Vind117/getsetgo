import 'package:flutter/material.dart';
import 'package:getsetgo/screens/habit_setting_screen.dart';
import 'package:getsetgo/screens/home_screen.dart';
import 'package:getsetgo/screens/logout_screen.dart'; // Assuming this is correct
import 'package:http/http.dart' as http; // For making HTTP requests to your AI backend
import 'dart:convert'; // For encoding/decoding JSON

// Define a simple message model
class ChatMessage {
  final String text;
  final bool isUserMessage; // true for user, false for assistant

  ChatMessage({required this.text, required this.isUserMessage});
}

// Convert StatelessWidget to StatefulWidget
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  // Controller for the message input field
  final TextEditingController _textController = TextEditingController();
  // List to hold all chat messages
  final List<ChatMessage> _messages = [];

  // Placeholder for your AI backend URL (replace with your actual API endpoint)
  final String _aiApiUrl = 'YOUR_AI_BACKEND_API_URL/chat'; // e.g., 'https://your-chatbot-api.com/chat'

  // Function to send a message
  void _handleSubmitted(String text) {
    if (text.isEmpty) return; // Don't send empty messages

    _textController.clear(); // Clear the input field

    // Add user message to the list and update UI
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUserMessage: true));
    });

    // --- INTEGRATE WITH YOUR AI BACKEND HERE ---
    _getAIResponse(text);
  }

  // Function to simulate AI response (replace with actual API call)
  Future<void> _getAIResponse(String userMessage) async {
    // Simulate network delay or actual API call
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading time

    try {
      // --- ACTUAL AI API CALL ---
      // This is where you'd call your Dialogflow, Gemini API, or custom backend
      final response = await http.post(
        Uri.parse(_aiApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String aiResponseText = responseData['response']; // Adjust based on your API's JSON structure

        // Add AI response to the list and update UI
        setState(() {
          _messages.insert(0, ChatMessage(text: aiResponseText, isUserMessage: false));
        });
      } else {
        // Handle API error
        setState(() {
          _messages.insert(0, ChatMessage(text: 'Error: Could not get a response from AI. Status: ${response.statusCode}', isUserMessage: false));
        });
        print('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle network or parsing errors
      setState(() {
        _messages.insert(0, ChatMessage(text: 'Error: Failed to connect to AI. Please check your internet connection.', isUserMessage: false));
      });
      print('Network/Parsing Error: $e');
    }
  }

  // Widget to build individual message bubbles
  Widget _buildMessage(ChatMessage message) {
    // Align messages based on who sent them
    final alignment = message.isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = message.isUserMessage ? Colors.blue[600] : Colors.grey[200];
    final textColor = message.isUserMessage ? Colors.white : Colors.black;
    const double cornerRadius = 12.0; // Define the radius value

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: message.isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isUserMessage) // Show AI image only for assistant messages
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset('assets/images/Blue assistant.png', height: 40, width: 40), // Smaller AI icon
                ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: message.isUserMessage
                        ? BorderRadius.only(
                            // CORRECTED: Pass Radius.circular(cornerRadius) for each corner
                            topLeft: Radius.circular(cornerRadius),
                            bottomLeft: Radius.circular(cornerRadius),
                            bottomRight: Radius.circular(cornerRadius),
                          )
                        : BorderRadius.only(
                            // CORRECTED: Pass Radius.circular(cornerRadius) for each corner
                            topRight: Radius.circular(cornerRadius),
                            bottomLeft: Radius.circular(cornerRadius),
                            bottomRight: Radius.circular(cornerRadius),
                          ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(color: textColor, fontSize: 16.0),
                  ),
                ),
              ),
              if (message.isUserMessage) // Show user icon (optional)
                 Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                   child: const CircleAvatar( // Added const here
                      radius: 20,
                      child: Icon(Icons.person), // Or use an asset for user avatar
                   ),
                 ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('ASSISTANT'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              reverse: true, // To show latest messages at the bottom
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          
          // Message input field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _handleSubmitted, // Submit on Enter key
                    decoration: InputDecoration(
                      hintText: 'Message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25), // Make it more rounded
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  mini: true,
                  onPressed: () => _handleSubmitted(_textController.text), // Submit on button tap
                  backgroundColor: Theme.of(context).primaryColor, // Use theme color
                  child: const Icon(Icons.send, color: Colors.white),
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Assistant is at index 2
        onTap: (index) {
          switch (index) {
            case 0:
              // Only navigate if not already on the screen
              if (ModalRoute.of(context)?.settings.name != '/') { // Assuming HomeScreen is '/'
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false, // Clears all routes below
                );
              }
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HabitSettingScreen()));
              break;
            case 2:
              // Already on AssistantScreen, do nothing
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LogoutScreen()));
              break;
          }
        },
        selectedItemColor: Theme.of(context).primaryColor, // Highlight selected icon
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline), // Or Icons.format_list_bulleted for 'Habits'
            label: 'Habit Setting', // Changed from 'New Habit' to match typical usage for a habits app
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: 'Assistant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Or Icons.leaderboard for 'Progress', Icons.person for 'Profile'
            label: 'Settings', // Changed from 'Settings' for consistency
          ),
        ],
      ),
    );
  }
}