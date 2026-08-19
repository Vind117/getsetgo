// lib/screens/ai_assistant_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:getsetgo/screens/logout_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:video_player/video_player.dart';

class ChatMessage {
  final String text;
  final bool isUserMessage;
  final Key key;

  ChatMessage({required this.text, required this.isUserMessage}) : key = UniqueKey();
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  late FlutterTts flutterTts;
  late SpeechToText _speechToText;
  late VideoPlayerController _videoController;

  bool _isListening = false;
  String _lastWords = '';
  bool _isLoadingResponse = false;
  bool _enableVoiceResponse = false;
  bool _isShowingListeningIndicator = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeechToText();
    _initVideoBackground();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    flutterTts.stop();
    _speechToText.stop();
    _scrollController.dispose();
    _animationController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void _initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);
    flutterTts.setCompletionHandler(() {
      print("TTS finished speaking");
    });
    flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
    });
  }

  void _initSpeechToText() async {
    _speechToText = SpeechToText();
    bool available = await _speechToText.initialize(
      onStatus: (status) => print('STT Status: $status'),
      onError: (errorNotification) => print('STT Error: $errorNotification'),
    );
    if (!available) {
      print('Speech recognition not available on this device.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available. Check device settings or permissions.')),
        );
      }
    }
  }

  void _initVideoBackground() async {
    _videoController = VideoPlayerController.asset('assets/videos/bg_animation.mp4');
    await _videoController.initialize();
    _videoController.setLooping(true);
    _videoController.setVolume(0.0);
    _videoController.play();
    setState(() {});
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;
    _textController.clear();
    setState(() {
      if (_isShowingListeningIndicator) {
        _isShowingListeningIndicator = false;
      }
      _messages.add(ChatMessage(text: text, isUserMessage: true));
      _isLoadingResponse = true;
      _enableVoiceResponse = false;
    });
    _scrollToBottom();
    _getAIResponse(text);
  }

  void _toggleListening() async {
    if (_isListening) {
      _speechToText.stop();
      setState(() {
        _isListening = false;
        _animationController.reverse();
        _isShowingListeningIndicator = false;
      });
      if (_lastWords.isNotEmpty) {
        _handleSubmitted(_lastWords);
      }
      _lastWords = '';
    } else {
      _lastWords = '';
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'listening') {
            setState(() {
              _isListening = true;
              _enableVoiceResponse = true;
              _animationController.forward();
              _isShowingListeningIndicator = true;
            });
          } else if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
              _animationController.reverse();
              _isShowingListeningIndicator = false;
              _enableVoiceResponse = false;
            });
            if (_lastWords.isNotEmpty) {
              _handleSubmitted(_lastWords);
            }
            _lastWords = '';
          }
        },
        onError: (errorNotification) {
          print('STT Error: ${errorNotification.errorMsg}');
          setState(() {
            _isListening = false;
            _enableVoiceResponse = false;
            _animationController.reverse();
            _isShowingListeningIndicator = false;
            _messages.add(ChatMessage(text: 'Voice input error: ${errorNotification.errorMsg.split(':')[0]}. Please try again.', isUserMessage: false));
            _scrollToBottom();
          });
          _lastWords = '';
        },
      );
      if (available) {
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
              _textController.text = _lastWords;
            });
          },
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
          onDevice: true,
        );
      } else {
        setState(() {
          _isListening = false;
          _enableVoiceResponse = false;
          _isShowingListeningIndicator = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available on this device.')),
        );
      }
    }
  }

  Future<void> _getAIResponse(String userMessage) async {
    List<Map<String, dynamic>> apiChatContents = [];

    apiChatContents.add({
      "role": "user",
      "parts": [
        {
          "text": "You are a helpful AI assistant for a habit tracker application called 'GetSetGo'. Your goal is to assist users with questions related to habit tracking, health and fitness habits, creating habit plans, and general well-being advice. Be encouraging and provide actionable advice. If a user asks something unrelated, gently steer them back to habits or health topics."
        }
      ]
    });
    apiChatContents.add({"role": "model", "parts": [{"text": "Hello! How can I assist you today regarding your habits or health?"}]});

    for (var msg in _messages.where((msg) => !msg.text.startsWith('Listening'))) {
      apiChatContents.add({
        "role": msg.isUserMessage ? "user" : "model",
        "parts": [{"text": msg.text}]
      });
    }

    final String apiKey = "AIzaSyDsWC-KmRBNuAmYwbajjMGlNz7IaM2zr14";
    final String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Flutter Habit Tracker App',
        },
        body: json.encode({'contents': apiChatContents}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String aiResponseText = "I'm sorry, I couldn't understand that.";

        if (responseData['candidates'] != null &&
            responseData['candidates'].isNotEmpty &&
            responseData['candidates'][0]['content'] != null &&
            responseData['candidates'][0]['content']['parts'] != null &&
            responseData['candidates'][0]['content']['parts'].isNotEmpty) {
          aiResponseText = responseData['candidates'][0]['content']['parts'][0]['text'];
        }

        setState(() {
          _messages.add(ChatMessage(text: aiResponseText, isUserMessage: false));
          _isLoadingResponse = false;
          _enableVoiceResponse = false;
        });
        _scrollToBottom();
        if (_enableVoiceResponse) {
          _speak(aiResponseText);
        }
      } else {
        String errorMsg = 'Error getting response: HTTP ${response.statusCode}';
        if (response.statusCode == 400) {
          errorMsg += '. (Bad Request: Check request format, especially chat history roles. Response body: ${response.body})';
        } else if (response.statusCode == 403) {
          errorMsg += '. (Forbidden: API key might be invalid or lacking permissions, or Gemini API is not enabled for your project.)';
        } else if (response.statusCode == 429) {
          errorMsg += '. (Rate Limit Exceeded: Too many requests. Try again later.)';
        }
        print('API Error: ${response.statusCode} - ${response.body}');
        setState(() {
          _messages.add(ChatMessage(text: errorMsg, isUserMessage: false));
          _isLoadingResponse = false;
        });
        _scrollToBottom();
        if (_enableVoiceResponse) {
          _speak('I encountered an error getting a response. Please check the console for details.');
        }
      }
    } catch (e) {
      print('Network/Parsing Error: $e');
      setState(() {
        _messages.add(ChatMessage(text: 'Error connecting to AI. Please check your internet connection.', isUserMessage: false));
        _isLoadingResponse = false;
      });
      _scrollToBottom();
      if (_enableVoiceResponse) {
        _speak('I\'m having trouble connecting. Please check your internet connection and try again.');
      }
    }
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.isInitialized ? _videoController.value.size.width : 0,
                height: _videoController.value.isInitialized ? _videoController.value.size.height : 0,
                child: _videoController.value.isInitialized
                    ? VideoPlayer(_videoController)
                    : Container(color: Colors.black),
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'ASSISTANT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black45,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessage(_messages[index]);
                  },
                ),
              ),
              if (_isLoadingResponse)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  ),
                ),
              if (_isShowingListeningIndicator)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Listening: $_lastWords',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: _handleSubmitted,
                        decoration: InputDecoration(
                          hintText: 'Message the AI assistant...',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
                        ),
                        style: const TextStyle(color: Colors.black, fontSize: 16.0),
                        cursorColor: Theme.of(context).primaryColor,
                        enabled: !_isListening,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      onPressed: _isLoadingResponse || _isListening ? null : () => _handleSubmitted(_textController.text),
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      onPressed: _toggleListening,
                      backgroundColor: _isListening ? Colors.redAccent.shade700 : Theme.of(context).primaryColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      child: Icon(
                        _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final alignment = message.isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = message.isUserMessage ? Theme.of(context).primaryColor : Colors.grey[200];
    final textColor = message.isUserMessage ? Colors.white : Colors.black87;
    const double cornerRadius = 18.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: message.isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUserMessage)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                  child: Image.asset('assets/images/Blue assistant.png', height: 36, width: 36),
                ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: message.isUserMessage
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(cornerRadius),
                            bottomLeft: Radius.circular(cornerRadius),
                            bottomRight: Radius.circular(cornerRadius),
                          )
                        : const BorderRadius.only(
                            topRight: Radius.circular(cornerRadius),
                            bottomLeft: Radius.circular(cornerRadius),
                            bottomRight: Radius.circular(cornerRadius),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.0,
                      shadows: message.isUserMessage
                          ? [
                              Shadow(
                                blurRadius: 2.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(1.0, 1.0),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
              if (message.isUserMessage)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: CircleAvatar(
                    radius: 18,
                    child: Image.asset(
                      'assets/images/avatar.png',
                      fit: BoxFit.cover,
                      width: 36,
                      height: 36,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}