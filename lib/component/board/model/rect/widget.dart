import 'package:flutter/material.dart';

import 'data.dart';

class RectModelWidget extends StatelessWidget {
  final RectModelData data;
  const RectModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.fillColor.value,
        border: Border.all(
          color: data.borderColor.value ?? const Color(0xFF000000),
          width: data.borderWidth.value ?? 1.0,
        ),
      ),
    );
  }
}
