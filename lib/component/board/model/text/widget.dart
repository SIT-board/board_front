import 'package:flutter/material.dart';

import 'data.dart';

class TextModelWidget extends StatelessWidget {
  final TextModelData data;
  const TextModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    controller.text = data.content.value;
    return EditableText(
      controller: controller,
      focusNode: FocusNode(),
      selectionColor: Colors.blue,
      style: TextStyle(
        color: data.color.value ?? Colors.black,
      ),
      cursorColor: Colors.black,
      backgroundCursorColor: Colors.transparent,
    );
  }
}
