import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/model/base_editor.dart';
import 'package:board_front/util/color_picker.dart';
import 'package:flutter/material.dart';

class LineModelEditor extends StatefulWidget {
  final Model model;
  final EventBus<BoardEventName>? eventBus;
  const LineModelEditor({
    Key? key,
    required this.model,
    this.eventBus,
  }) : super(key: key);

  @override
  State<LineModelEditor> createState() => _LineModelEditorState();
}

class _LineModelEditorState extends State<LineModelEditor> {
  LineModelData get modelData => widget.model.data as LineModelData;

  void refreshModel() {
    widget.eventBus?.publish(BoardEventName.refreshModel, widget.model.id);
  }

  @override
  Widget build(BuildContext context) {
    return ModelAttribute(children: [
      ModelAttributeSection(
        title: '直线属性',
        items: [
          ModelAttributeItem(
            title: '线宽',
            child: Slider(
              value: modelData.thickness,
              min: 1,
              max: 100,
              onChanged: (value) {
                setState(() {
                  modelData.thickness = value;
                });
                refreshModel();
              },
            ),
          ),
          ModelAttributeItem(
            title: '直线颜色',
            child: InkWell(
              onTap: () async {
                final pickedColor = await showBoardColorPicker(context);
                if (pickedColor == null) return;
                modelData.color = pickedColor;
                setState(() {});
                refreshModel();
              },
              child: Container(color: modelData.color, width: 50, height: 50),
            ),
          ),
          ModelAttributeItem(
            title: '实线长度',
            child: Slider(
              value: modelData.dashLength,
              min: 0,
              max: 10,
              onChanged: (value) {
                setState(() => modelData.dashLength = value);
                refreshModel();
              },
            ),
          ),
          ModelAttributeItem(
            title: '虚线长度',
            child: Slider(
              value: modelData.dashGapLength,
              min: 0,
              max: 10,
              onChanged: (value) {
                setState(() => modelData.dashGapLength = value);
                refreshModel();
              },
            ),
          ),
        ],
      )
    ]);
  }
}
