import 'package:emotions/utils/appColors.dart';
import 'package:flutter/material.dart';
import 'package:squiggly_slider/slider.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  double _sliderValue = 0.0;
  final List<Color> _colors = [AppColors.blueColor, AppColors.violetColor, AppColors.amberColor];
  final List<String> _moods = ['Not Good', 'Great', 'Awesome'];
  final List<String> _videoPaths = [
    'assets/videos/notbad.mp4',
    'assets/videos/great.mp4',
    'assets/videos/awesome.mp4',
  ];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<VideoPlayerController> _videoControllers;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();

    // Initialize video controllers
    _videoControllers = _videoPaths.map((path) => VideoPlayerController.asset(path)).toList();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    for (var controller in _videoControllers) {
      await controller.initialize();
      controller.setLooping(true); // Loop the video
      if (_videoControllers.indexOf(controller) == _sliderValue.round()) {
        controller.play(); // Play only the initial video
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: _colors[_sliderValue.round()],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'How was your day?',
                style: TextStyle(letterSpacing: 5, wordSpacing: 5, fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    _moods[_sliderValue.round()],
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_videoControllers.isNotEmpty && _videoControllers[0].value.isInitialized)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: VideoPlayer(_videoControllers[_sliderValue.round()]),
                  ),
                ),
              const SizedBox(height: 40),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SquigglySlider(
                      value: _sliderValue,
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                          _controller.reset();
                          _controller.forward();
                          // Pause all videos and play only the selected one
                          for (var controller in _videoControllers) {
                            controller.pause();
                          }
                          _videoControllers[_sliderValue.round()].play();
                        });
                      },
                      squiggleAmplitude: 10.0,
                      squiggleWavelength: 4.0,
                      squiggleSpeed: 0.3,
                      min: 0,
                      max: 2,
                      divisions: 2,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: List.generate(3, (index) {
                  //     return Container(
                  //       margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  //       width: 12.0,
                  //       height: 12.0,
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: _sliderValue.round() == index
                  //             ? Colors.white
                  //             : Colors.white.withOpacity(0.5),
                  //       ),
                  //     );
                  //   }),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}