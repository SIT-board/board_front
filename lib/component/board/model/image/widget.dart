import 'package:flutter/material.dart';

import 'data.dart';

class ImageModelWidget extends StatelessWidget {
  final ImageModelData data;
  const ImageModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      data.url,
      fit: BoxFit.fill,
    );
  }
}
