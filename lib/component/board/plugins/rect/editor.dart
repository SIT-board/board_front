import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/plugins/base_editor.dart';
import 'package:board_front/util/color_picker.dart';
import 'package:flutter/material.dart';

import 'common.dart';
import 'data.dart';

class RadioButtonGroup extends StatelessWidget {
  final List<Widget> children;
  final void Function(int index) onChanged;
  final int value;
  const RadioButtonGroup({
    Key? key,
    required this.children,
    required this.onChanged,
    required this.value,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiRadioButtonGroup(
      onChanged: (int index, bool selectState) => onChanged(index),
      selectStateList: List.generate(children.length, (index) => index == value),
      children: children,
    );
  }
}

class MultiRadioButtonGroup extends StatelessWidget {
  final List<Widget> children;
  final void Function(int index, bool selectState) onChanged;
  final List<bool> selectStateList;

  const MultiRadioButtonGroup({
    Key? key,
    required this.children,
    required this.onChanged,
    required this.selectStateList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children.asMap().entries.map((MapEntry<int, Widget> entry) {
        final e = Expanded(
          child: TextButton(
            onPressed: () => onChanged(entry.key, !selectStateList[entry.key]),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.resolveWith((states) => Colors.black),
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                //设置按下时的背景颜色
                if (selectStateList[entry.key]) return Colors.blue[100];
                //默认不使用背景颜色
                return null;
              }),
            ),
            child: entry.value,
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
  final EventBus<BoardEventName> eventBus;
  const RectModelEditor({
    Key? key,
    required this.model,
    required this.eventBus,
  }) : super(key: key);

  @override
  State<RectModelEditor> createState() => _RectModelEditorState();
}

class _RectModelEditorState extends State<RectModelEditor> {
  RectModelData get modelData => RectModelData(widget.model.data);

  void refreshModel() => widget.eventBus.publish(BoardEventName.refreshModel, widget.model.id);
  void saveState() => widget.eventBus.publish(BoardEventName.saveState);

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
                setState(() => modelData.color = pickedColor);
                refreshModel();
                saveState();
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
                setState(() => modelData.border.color = pickedColor);
                refreshModel();
                saveState();
              },
              child: Container(height: 50, width: 50, color: modelData.border.color),
            ),
          ),
          ModelAttributeItem(
            title: '边框宽度',
            child: Slider(
              value: modelData.border.width,
              min: 0,
              max: widget.model.common.size.shortestSide / 2,
              onChanged: (value) {
                setState(() => modelData.border.width = value);
                refreshModel();
              },
              onChangeEnd: (value) => saveState(),
            ),
          ),
          ModelAttributeItem(
            title: '圆角半径',
            child: Slider(
              value: modelData.border.radius,
              min: 0,
              max: widget.model.common.size.shortestSide / 2,
              onChanged: (value) {
                setState(() => modelData.border.radius = value);
                refreshModel();
              },
              onChangeEnd: (value) => saveState(),
            ),
          ),
          ModelAttributeItem(
            title: '背景形状',
            child: DropdownButton<BoxShape>(
              value: modelData.backgroundShape,
              items: BoxShape.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => modelData.backgroundShape = value);
                refreshModel();
                saveState();
              },
            ),
          ),
        ],
      ),
      ModelAttributeSection(
        title: '文字属性',
        items: [
          ModelAttributeItem(
            title: '文字内容',
            child: TextButton(
              onPressed: () async {
                final content = await showModifyTextDialog(
                  context,
                  text: modelData.text.content,
                );
                if (content == null || content == modelData.text.content) return;
                modelData.text.content = content;
                refreshModel();
                saveState();
              },
              child: Text('修改'),
            ),
          ),
          ModelAttributeItem(
            title: '字号',
            child: Slider(
              value: modelData.text.fontSize,
              min: 1,
              max: 72,
              onChanged: (value) {
                setState(() {
                  modelData.text.fontSize = value;
                });
                refreshModel();
              },
              onChangeEnd: (value) => saveState(),
            ),
          ),
          ModelAttributeItem(
            title: '文字颜色',
            child: InkWell(
              onTap: () async {
                final pickedColor = await showBoardColorPicker(context);
                if (pickedColor == null) return;
                setState(() => modelData.text.color = pickedColor);
                refreshModel();
                saveState();
              },
              child: Container(height: 50, width: 50, color: modelData.text.color),
            ),
          ),
          ModelAttributeItem(
            title: '水平对齐',
            child: RadioButtonGroup(
              onChanged: (i) {
                setState(() {
                  modelData.text.alignment = Alignment(
                    i - 1,
                    modelData.text.alignment.y,
                  );
                });
                refreshModel();
                saveState();
              },
              value: modelData.text.alignment.x.toInt() + 1,
              children: const [
                Icon(Icons.align_horizontal_left),
                Icon(Icons.align_horizontal_center),
                Icon(Icons.align_horizontal_right),
              ],
            ),
          ),
          ModelAttributeItem(
            title: '垂直对齐',
            child: RadioButtonGroup(
              onChanged: (i) {
                setState(() {
                  modelData.text.alignment = Alignment(
                    modelData.text.alignment.x,
                    i - 1,
                  );
                });
                refreshModel();
                saveState();
              },
              value: modelData.text.alignment.y.toInt() + 1,
              children: const [
                Icon(Icons.align_vertical_top),
                Icon(Icons.align_vertical_center),
                Icon(Icons.align_vertical_bottom),
              ],
            ),
          ),
          ModelAttributeItem(
            title: '文字样式',
            child: MultiRadioButtonGroup(
              onChanged: (index, state) {
                [
                  () => modelData.text.bold = state,
                  () => modelData.text.italic = state,
                  () => modelData.text.underline = state,
                ][index]();
                setState(() {});
                refreshModel();
                saveState();
              },
              selectStateList: [
                modelData.text.bold,
                modelData.text.italic,
                modelData.text.underline,
              ],
              children: const [
                Icon(Icons.format_bold),
                Icon(Icons.format_italic),
                Icon(Icons.format_underline),
              ],
            ),
          ),
        ],
      )
    ]);
  }
}
