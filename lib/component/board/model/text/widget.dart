import 'package:flutter/material.dart';

import 'data.dart';

class TextModelWidget extends StatelessWidget {
  final TextModelData data;
  const TextModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    controller.text = data.content;
    controller.addListener(() {});
    return EditableText(
      controller: controller,
      focusNode: FocusNode(),
      selectionColor: Colors.blue,
      style: TextStyle(
        color: data.color ?? Colors.black,
      ),
      cursorColor: Colors.black,
      backgroundCursorColor: Colors.transparent,
    );
  }
}
