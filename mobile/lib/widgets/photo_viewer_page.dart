import 'package:flutter/material.dart';

import 'attachment_thumbnail.dart';

/// Full-screen, zoomable, swipeable view of one or more locally-stored
/// photos — used for both Documents and expense receipts.
class PhotoViewerPage extends StatefulWidget {
  const PhotoViewerPage({
    super.key,
    required this.imagePaths,
    required this.title,
    this.initialIndex = 0,
  });

  final List<String> imagePaths;
  final String title;
  final int initialIndex;

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final multiple = widget.imagePaths.length > 1;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(multiple ? '${widget.title} (${_currentIndex + 1}/${widget.imagePaths.length})' : widget.title),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imagePaths.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final path = widget.imagePaths[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: buildAttachmentThumbnail(context, path, iconSize: 64),
              ),
            ),
          );
        },
      ),
    );
  }
}
