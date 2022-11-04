import 'package:flutter/material.dart';

import 'data.dart';

class RectModelWidget extends StatelessWidget {
  final RectModelData data;
  const RectModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.fillColor,
        border: Border.all(color: data.borderColor, width: data.borderWidth),
      ),
    );
  }
}
