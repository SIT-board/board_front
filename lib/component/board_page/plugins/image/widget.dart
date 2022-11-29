import 'package:flutter/material.dart';

import 'data.dart';

class ImageModelWidget extends StatelessWidget {
  final ImageModelData data;
  const ImageModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.url.isEmpty) return const Center(child: Text('未设置图片'));
    return Image.network(
      data.url,
      fit: data.fit,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        int currentLength = loadingProgress.cumulativeBytesLoaded;
        int? totalLength = loadingProgress.expectedTotalBytes;
        return Center(
          child: CircularProgressIndicator(value: totalLength != null ? currentLength / totalLength : null),
        );
      },
    );
  }
}
