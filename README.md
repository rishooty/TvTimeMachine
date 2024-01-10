# TV Time Machine

The plan is a very simple frontend meant for co-op, co-op modded, splitscreen scripted (nucleus co-op or AhmedKJ's co-op on linux) or otherwise generally multiplayer games.

This is nothing more than the mere start of a controller mapping utlity at the moment. Planned functionality of this portion is to:
1. Ask the user to plug in or connect one or more controllers while it polls.
2. Set up any existing profiles if it finds one.
3. If it does not find a profile, prompt the user to map the controller.
  * Auto-Scroll through a list of controller + right-hand face button images every 3 seconds.
  * User holds ANY input fully for one second to confirm.
  * (current WIP) Show images for each button of the controller type and prompt the user to hold for one second, much like the above but     without auto scrolling.
  * After each input has been saved, spit two .cfg files containing an Xoutput (windows) and xboxdrv (*nix), saved under a directory matching the controller's name and/or hardware id.


### Credits So far:
* [Weiholmir Pixel Font](https://justfredrik.itch.io/weiholmir) by JustFredrik
* [Controllers and Butons Master Pack](https://justfredrik.itch.io/controllers-n-buttons) by JustFredrik
