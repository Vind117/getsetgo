import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer' as developer; // Import for developer.log

class AnimatedBackground extends StatefulWidget {
  final Widget child; // The content of the screen to be placed on top

  const AnimatedBackground({super.key, required this.child});

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/bg_animation.mp4')
      ..initialize().then((_) {
        if (mounted) {
          _controller.play();
          _controller.setLooping(true);
          setState(() {}); // Ensure the first frame is shown
        }
        developer.log('Video controller initialized: ${_controller.value.isInitialized}', name: 'AnimatedBackground');
        if (!_controller.value.isInitialized) {
          developer.log('Failed to initialize video controller.', name: 'AnimatedBackground', error: 'Check video path and file integrity.');
        }
      }).catchError((error) {
        developer.log('Error initializing video controller: $error', name: 'AnimatedBackground', error: error);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If the controller is not initialized, show a simple dark container
    if (!_controller.value.isInitialized) {
      return Container(
        color: Colors.black, // Fallback solid color
        child: widget.child,
      );
    }

    return Stack(
      children: <Widget>[
        // The Video Background
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover, // Ensures the video covers the whole area without distortion
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        // A subtle overlay to make text/elements on top more readable
        Container(
          color: Colors.black.withOpacity(0.3), // Adjust opacity as needed
        ),
        // Your actual screen content (passed as 'child')
        widget.child,
      ],
    );
  }
}