import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/model/base_editor.dart';
import 'package:flutter/material.dart';

class TextModelEditor extends StatefulWidget {
  final Model model;
  final EventBus<BoardEventName>? eventBus;
  const TextModelEditor({
    Key? key,
    required this.model,
    this.eventBus,
  }) : super(key: key);

  @override
  State<TextModelEditor> createState() => _TextModelEditorState();
}

class _TextModelEditorState extends State<TextModelEditor> {
  LineModelData get modelData => widget.model.data as LineModelData;

  void refreshModel() {
    widget.eventBus?.publish(BoardEventName.refreshModel, widget.model.id);
  }

  ModelAttributeItem buildAlign() => ModelAttributeItem(
        title: '对齐方式',
        child: Table(
          children: [
            TableRow(
              children: [
                Icon(Icons.format_align_left),
                Icon(Icons.format_align_center),
                Icon(Icons.format_align_right),
              ],
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ModelAttribute(children: [
      ModelAttributeSection(
        title: '直线属性',
        items: [buildAlign()],
      )
    ]);
  }
}
