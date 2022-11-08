import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/model/base_editor.dart';
import 'package:board_front/util/color_picker.dart';
import 'package:flutter/material.dart';

typedef SwitchCallback = void Function(int index);

class MultiButtonSwitch extends StatefulWidget {
  final List<Widget> children;
  final SwitchCallback onSwitch;
  final int defaultOptionIndex;

  const MultiButtonSwitch({
    Key? key,
    required this.children,
    required this.onSwitch,
    this.defaultOptionIndex = 0,
  }) : super(key: key);

  @override
  State<MultiButtonSwitch> createState() => _MultiButtonSwitchState();
}

class _MultiButtonSwitchState extends State<MultiButtonSwitch> {
  late int currentOptionIndex;

  @override
  void initState() {
    currentOptionIndex = widget.defaultOptionIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.children.asMap().entries.map((MapEntry<int, Widget> entry) {
        final e = Expanded(
          child: TextButton(
            onPressed: () {
              widget.onSwitch(entry.key);
              setState(() {
                currentOptionIndex = entry.key;
              });
            },
            child: entry.value,
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.resolveWith((states) => Colors.black),
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                //设置按下时的背景颜色
                if (currentOptionIndex == entry.key) {
                  return Colors.blue[100];
                }
                //默认不使用背景颜色
                return null;
              }),
            ),
          ),
        );
        return Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [e],
          ),
        );
      }).toList(),
    );
  }
}

class RectModelEditor extends StatefulWidget {
  final Model model;
  final EventBus<BoardEventName>? eventBus;
  const RectModelEditor({
    Key? key,
    required this.model,
    this.eventBus,
  }) : super(key: key);

  @override
  State<RectModelEditor> createState() => _RectModelEditorState();
}

class _RectModelEditorState extends State<RectModelEditor> {
  RectModelData get modelData => widget.model.data as RectModelData;

  void refreshModel() {
    widget.eventBus?.publish(BoardEventName.refreshModel, widget.model.id);
  }

  @override
  Widget build(BuildContext context) {
    return ModelAttribute(children: [
      ModelAttributeSection(
        title: '矩形属性',
        items: [
          ModelAttributeItem(
            title: '背景颜色',
            child: InkWell(
              onTap: () async {
                final pickedColor = await showBoardColorPicker(context);
                if (pickedColor == null) return;
                setState(() {
                  modelData.color = pickedColor;
                });
                refreshModel();
              },
              child: Container(height: 50, width: 50, color: modelData.color),
            ),
          ),
          ModelAttributeItem(
            title: '边框颜色',
            child: InkWell(
              onTap: () async {
                final pickedColor = await showBoardColorPicker(context);
                if (pickedColor == null) return;
                setState(() {
                  modelData.border.color = pickedColor;
                });
                refreshModel();
              },
              child: Container(height: 50, width: 50, color: modelData.border.color),
            ),
          ),
          ModelAttributeItem(
            title: '边框宽度',
            child: Slider(
              value: modelData.border.width,
              min: 0,
              max: 10,
              onChanged: (value) {
                setState(() {
                  modelData.border.width = value;
                });
                refreshModel();
              },
            ),
          ),
        ],
      ),
      ModelAttributeSection(
        title: '文字属性',
        items: [
          ModelAttributeItem(
            title: '水平对齐',
            child: MultiButtonSwitch(
              onSwitch: (i) {
                modelData.text.alignment = Alignment(
                  i - 1,
                  modelData.text.alignment.y,
                );
                print(modelData.text.alignment);
                refreshModel();
              },
              defaultOptionIndex: modelData.text.alignment.x.toInt() + 1,
              children: const [
                Icon(Icons.align_horizontal_left),
                Icon(Icons.align_horizontal_center),
                Icon(Icons.align_horizontal_right),
              ],
            ),
          ),
          ModelAttributeItem(
            title: '垂直对齐',
            child: MultiButtonSwitch(
              onSwitch: (i) {
                modelData.text.alignment = Alignment(
                  modelData.text.alignment.x,
                  i - 1,
                );
                print(modelData.text.alignment);
                refreshModel();
              },
              defaultOptionIndex: modelData.text.alignment.y.toInt() + 1,
              children: const [
                Icon(Icons.align_vertical_top),
                Icon(Icons.align_vertical_center),
                Icon(Icons.align_vertical_bottom),
              ],
            ),
          ),
        ],
      )
    ]);
  }
}
