import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/util/color_picker.dart';
import 'package:flutter/material.dart';

import '../../model/model.dart';
import '../base_editor.dart';
import 'data.dart';

class OvalModelEditor extends StatefulWidget {
  final Model model;
  final EventBus<BoardEventName> eventBus;
  const OvalModelEditor({
    Key? key,
    required this.model,
    required this.eventBus,
  }) : super(key: key);

  @override
  State<OvalModelEditor> createState() => _OvalModelEditorState();
}

class _OvalModelEditorState extends State<OvalModelEditor> {
  OvalModelData get modelData => OvalModelData(widget.model.data);

  void refreshModel() => widget.eventBus.publish(BoardEventName.refreshModel, widget.model.id);
  void saveState() => widget.eventBus.publish(BoardEventName.saveState);

  @override
  Widget build(BuildContext context) {
    return ModelAttribute(children: [
      ModelAttributeSection(
        title: '椭圆属性',
        items: [
          ModelAttributeItem(
            title: '填充颜色',
            child: InkWell(
              onTap: () async {
                final pickedColor = await showBoardColorPicker(context);
                if (pickedColor == null) return;
                modelData.color = pickedColor;
                setState(() {});
                refreshModel();
                saveState();
              },
              child: Container(color: modelData.color, width: 50, height: 50),
            ),
          ),
        ],
      )
    ]);
  }
}
