import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set a static color as the background for the splash screen
    return MaterialApp(
      title: 'TV Time Machine',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Define a blocky font family if available
        // fontFamily: 'BlockyFontFamily',
      ),
      home: const SplashScreen(),
    );
  }
}

class ControllerImageAlbum extends StatefulWidget {
  final List<String> gamepadImages;
  final Function(int) onPageChanged; // Callback to update the current page
  final bool shouldStartAutoRotation;

  const ControllerImageAlbum(
      {Key? key,
      required this.gamepadImages,
      required this.onPageChanged,
      required this.shouldStartAutoRotation})
      : super(key: key);

  @override
  _ControllerImageAlbumState createState() => _ControllerImageAlbumState();
}

class _ControllerImageAlbumState extends State<ControllerImageAlbum> {
  final PageController gamepadPageController =
      PageController(viewportFraction: 0.8);
  int currentPage = 0;
  Timer? _pageTimer;

  int getCurrentPageIndex() {
    return currentPage; // Return the current page index
  }

  @override
  void initState() {
    super.initState();
    if (widget.shouldStartAutoRotation) {
      _startAutoRotateImages();
    }
  }

  @override
  void dispose() {
    _pageTimer?.cancel(); // Cancel the image rotation timer
    gamepadPageController.dispose();
    super.dispose();
  }

  void _startAutoRotateImages() {
    _pageTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      int nextPage = currentPage + 1;
      if (nextPage >= widget.gamepadImages.length) {
        nextPage = 0; // Go back to the first page if we've reached the end
      }
      if (mounted) {
        gamepadPageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we should start auto-rotation
    final splashScreenState =
        context.findAncestorStateOfType<_SplashScreenState>();
    if (splashScreenState != null &&
        splashScreenState.shouldStartAutoRotation) {
      _startAutoRotateImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Set a fixed height for the PageView
      child: PageView.builder(
        itemCount: widget.gamepadImages.length,
        controller: gamepadPageController,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
          widget.onPageChanged(currentPage);
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Image.asset(
              widget.gamepadImages[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String controllerStatus = 'Please connect one or more controllers.';
  String gamepadName = '';
  int currentPage = 0;
  Timer? _timer;
  Timer? _controllerPageTimer;
  bool shouldStartAutoRotation = false;
  final List<String> gamepadImages = [
    'assets/controllerImages/xbox.png',
    'assets/controllerImages/switch.png',
    'assets/controllerImages/playstation.png',
    'assets/controllerImages/snes.png',
  ];
  final List<String> buttonInputImages = [];
  StreamSubscription<GamepadEvent>? _gamepadSubscription;
  Timer? _inputHoldTimer;
  bool isInputActive = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _startPollingForGamepads();
    _startListeningForGamepadInput();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _controllerPageTimer?.cancel(); // Cancel the image rotation timer
    _gamepadSubscription?.cancel();
    _inputHoldTimer?.cancel();
    super.dispose();
  }

  void _updateCurrentPage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void _startPollingForGamepads() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final gamepads = await Gamepads.list();
      if (gamepads.isNotEmpty) {
        gamepadName = gamepads[0].name;
        print(gamepads[0].id);
        print('Gamepad found: $gamepadName');

        final profilePath =
            'gamepad_profiles/${gamepadName.replaceAll(' ', '_')}.cfg';
        final profileFile = File(profilePath);
        if (await profileFile.exists()) {
          // Load the profile
          final profileContents = await profileFile.readAsString();
          // TODO: Apply the profile settings
        } else {
          setState(() {
            controllerStatus =
                'No profile found for $gamepadName. Please create a mapping.';
          });
          shouldStartAutoRotation = true;
        }

        _timer?.cancel(); // Stop polling once a controller is found
      }
    });
  }

  void _startListeningForGamepadInput() {
    const gamepadId =
        '0'; // This should be set to the actual gamepad ID you want to listen to
    print('Listening to gamepad: $gamepadId');
    _gamepadSubscription =
        Gamepads.eventsByGamepad(gamepadId).listen((GamepadEvent event) {
      // ... (existing code)
      if (event.value == 1.0) {
        if (_inputHoldTimer == null || !_inputHoldTimer!.isActive) {
          _inputHoldTimer = Timer(Duration(seconds: 1), () {
            // Input has been held for one second
            _handleInputHeld(); // Call without parameters
          });
        }
      } else if (event.value == 0.0) {
        // Button released
        _inputHoldTimer?.cancel();
        _inputHoldTimer = null;
      }
    });
  }

  void _handleInputHeld() {
    // This method now only needs to handle the input held event
    print('Button held for one second on page $currentPage');
    // Perform any actions needed when a button is held
    // No need to call setState here unless you're updating the UI based on the input held event
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowControllerAlbum = controllerStatus ==
        'No profile found for $gamepadName. Please create a mapping.';
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/static.gif', fit: BoxFit.fill),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width *
                  0.8, // 80% of screen width
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(0.8), // Darker semi-transparent black
                // Removed borderRadius to have sharp corners
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Fit to content
                children: [
                  // White title bar
                  Container(
                    color: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    width:
                        double.infinity, // Full width of the parent container
                    child: const Text(
                      'Channel Setup',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Weiholmir', // Use the font family name
                      ),
                    ),
                  ),
                  // White text content
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      controllerStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Weiholmir', // Use the font family name
                      ),
                    ),
                  ),
                  if (shouldShowControllerAlbum)
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Does your controller look like this?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Weiholmir',
                        ),
                      ),
                    ),
                  if (shouldShowControllerAlbum)
                    ControllerImageAlbum(
                      gamepadImages: gamepadImages,
                      onPageChanged: _updateCurrentPage,
                      shouldStartAutoRotation: shouldStartAutoRotation,
                    ),
                ],
              ),
            ),
          ),
          // Add your PageView or gesture detection here for flipping channels
        ],
      ),
    );
  }
}
