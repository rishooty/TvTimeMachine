import 'package:flutter/material.dart';
import 'dart:async';

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
