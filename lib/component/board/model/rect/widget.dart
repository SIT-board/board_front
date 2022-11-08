import 'package:flutter/material.dart';

import 'common.dart';
import 'data.dart';

class RectModelWidget extends StatefulWidget {
  final RectModelData data;

  const RectModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  State<RectModelWidget> createState() => _RectModelWidgetState();
}

class _RectModelWidgetState extends State<RectModelWidget> {
  RectModelData get rect => widget.data;
  TextModelData get text => rect.text;
  BorderModelData get border => rect.border;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () async {
        final content = await showModifyTextDialog(
          context,
          text: text.content,
        );
        if (content == null || content == text.content) return;
        setState(() {
          text.content = content;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: rect.color,
          border: Border.all(
            color: border.color,
            width: border.width,
          ),
        ),
        alignment: text.alignment,
        child: Text(
          text.content,
          style: TextStyle(
            fontWeight: text.bold ? FontWeight.bold : FontWeight.normal,
            fontStyle: text.italic ? FontStyle.italic : FontStyle.normal,
            decoration: text.underline ? TextDecoration.underline : TextDecoration.none,
            color: text.color,
            fontSize: text.fontSize,
          ),
        ),
      ),
    );
  }
}
