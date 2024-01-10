import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tvtimemachine/widgets/controller_image_album.dart';
import 'package:tvtimemachine/services/gamepad_service.dart';
import 'package:tvtimemachine/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String controllerStatus = 'Please connect one or more controllers.';
  int currentPage = 0;
  final GamepadService gamepadService = GamepadService();
  bool shouldStartAutoRotation = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    gamepadService.startPollingForGamepads((String gamepadName) {
      setState(() {
        controllerStatus =
            'No profile found for $gamepadName. Please create a mapping.';
        shouldStartAutoRotation = true;
      });
    });
    gamepadService.startListeningForGamepadInput(() {
      _handleInputHeld();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    gamepadService.dispose();
    super.dispose();
  }

  void _updateCurrentPage(int index) {
    setState(() {
      currentPage = index;
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
        'No profile found for ${gamepadService.gamepadName}. Please create a mapping.';
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
                      gamepadImages: AppConstants.gamepadImages,
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
