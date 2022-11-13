import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/util/color_picker.dart';
import 'package:flutter/material.dart';

import '../../model/model.dart';
import '../base_editor.dart';
import 'data.dart';
import 'line_watcher.dart';

class FreeStyleModelEditor extends StatefulWidget {
  final Model model;
  final EventBus<BoardEventName> eventBus;
  const FreeStyleModelEditor({
    Key? key,
    required this.model,
    required this.eventBus,
  }) : super(key: key);

  @override
  State<FreeStyleModelEditor> createState() => _FreeStyleModelEditorState();
}

class _FreeStyleModelEditorState extends State<FreeStyleModelEditor> {
  FreeStyleModelData get modelData => FreeStyleModelData(widget.model.data);

  FreeStylePaintStyleModelData get paint => modelData.paint;

  void refreshModel() => widget.eventBus.publish(BoardEventName.refreshModel, widget.model.id);
  void saveState() => widget.eventBus.publish(BoardEventName.saveState);

  void _refreshEditor(arg) {
    if (!mounted) return;
    if (arg == widget.model.id) setState(() {});
  }

  @override
  void initState() {
    widget.eventBus.subscribe(BoardEventName.refreshEditor, _refreshEditor);
    super.initState();
  }

  @override
  void dispose() {
    widget.eventBus.unsubscribe(BoardEventName.refreshEditor, _refreshEditor);
    super.dispose();
  }

  ModelAttributeItem buildBackgroundColor() => ModelAttributeItem(
        title: '背景颜色',
        child: InkWell(
          onTap: () async {
            final pickedColor = await showBoardColorPicker(context);
            if (pickedColor == null) return;
            setState(() => modelData.backgroundColor = pickedColor);
            refreshModel();
            saveState();
          },
          child: Container(color: modelData.backgroundColor, width: 50, height: 50),
        ),
      );

  ModelAttributeItem buildCurrentPathShow() => ModelAttributeItem(
        title: '当前绘制线条数: ${modelData.pathListSize}',
        child: TextButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: LineWatcherColumn(
                        pathList: modelData.pathIdList.map((e) => modelData.getPathById(e)).toList(),
                        onDeletePath: (i) {
                          final ids = modelData.pathIdList.toList();
                          ids.removeWhere((e) => e == i);
                          modelData.pathIdList = ids;
                          refreshModel();
                          setState(() {});
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                });
          },
          child: Text('查看线条'),
        ),
      );

  ModelAttributeItem buildPaintColor() => ModelAttributeItem(
      title: '画笔颜色',
      child: InkWell(
        onTap: () async {
          final pickedColor = await showBoardColorPicker(context);
          if (pickedColor == null) return;
          modelData.paint.color = pickedColor;
          setState(() {});
          saveState();
        },
        child: Container(color: modelData.paint.color, width: 50, height: 50),
      ));

  ModelAttributeItem buildPaintStrokeWidth() => ModelAttributeItem(
      title: '画笔线宽',
      child: Slider(
        value: paint.strokeWidth,
        min: 1,
        max: 100,
        onChanged: (value) {
          setState(() => paint.strokeWidth = value);
        },
        onChangeEnd: (value) => saveState(),
      ));

  ModelAttributeItem buildAntiAlias() => ModelAttributeItem(
        title: '抗锯齿',
        child: Checkbox(
          value: paint.isAntiAlias,
          onChanged: (value) {
            setState(() => paint.isAntiAlias = value!);
            saveState();
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ModelAttribute(
      children: [
        ModelAttributeSection(
          title: '画板属性',
          items: [buildCurrentPathShow(), buildBackgroundColor()],
        ),
        ModelAttributeSection(
          title: '画笔属性',
          items: [
            buildPaintColor(),
            buildPaintStrokeWidth(),
            buildAntiAlias(),
          ],
        ),
      ],
    );
  }
}
