import 'package:flutter/material.dart';

import 'data.dart';

class RectModelWidget extends StatelessWidget {
  final RectModelData data;
  const RectModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.color,
        border: Border.all(
          color: data.border.color,
          width: data.border.width,
        ),
      ),
      child: Container(
        alignment: data.text.alignment,
        child: Text(
          data.text.content,
          style: TextStyle(
            color: data.text.color,
            fontSize: data.text.fontSize,
          ),
        ),
      ),
    );
  }
}
