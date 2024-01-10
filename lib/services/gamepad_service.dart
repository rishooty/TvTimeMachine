import 'package:gamepads/gamepads.dart';
import 'dart:async';
import 'dart:io';

class GamepadService {
  String gamepadName = '';
  StreamSubscription<GamepadEvent>? gamepadSubscription;
  Timer? inputHoldTimer;
  bool isInputActive = false;

  Future<void> startPollingForGamepads(
      Function(String) onProfileNotFound) async {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
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
          onProfileNotFound(gamepadName);
        }

        timer.cancel(); // Stop polling once a controller is found
      }
    });
  }

  void startListeningForGamepadInput(Function onInputHeld) {
    const gamepadId =
        '0'; // This should be set to the actual gamepad ID you want to listen to
    print('Listening to gamepad: $gamepadId');
    gamepadSubscription =
        Gamepads.eventsByGamepad(gamepadId).listen((GamepadEvent event) {
      // ... (existing code)
      if (event.value == 1.0) {
        if (inputHoldTimer == null || !inputHoldTimer!.isActive) {
          inputHoldTimer = Timer(Duration(seconds: 1), () {
            // Input has been held for one second
            onInputHeld();
          });
        }
      } else if (event.value == 0.0) {
        // Button released
        inputHoldTimer?.cancel();
        inputHoldTimer = null;
      }
    });
  }

  void dispose() {
    gamepadSubscription?.cancel();
    inputHoldTimer?.cancel();
  }
}
