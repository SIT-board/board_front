import 'package:flutter/material.dart';

import 'data.dart';

class RectModelWidget extends StatelessWidget {
  final RectModelData data;
  const RectModelWidget({Key? key, required this.data}) : super(key: key);

  Widget buildText() => Text(
        data.text.content,
        style: TextStyle(
          color: data.text.color,
          fontSize: data.text.fontSize,
        ),
      );

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
      child: buildText(),
    );
  }
}
