import 'package:flutter/material.dart';

class ImageViewerPage extends StatelessWidget {
  final ImageProvider provider;
  const ImageViewerPage({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: InteractiveViewer(
        child: Image(image: provider),
      ),
    );
  }
}
