import 'dart:io';

import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/model/data.dart';
import 'package:board_front/util/color_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../base_editor.dart';
import 'data.dart';

class ImageModelEditor extends StatefulWidget {
  final Model model;
  final EventBus<BoardEventName> eventBus;
  const ImageModelEditor({
    Key? key,
    required this.model,
    required this.eventBus,
  }) : super(key: key);

  @override
  State<ImageModelEditor> createState() => _ImageModelEditorState();
}

class _ImageModelEditorState extends State<ImageModelEditor> {
  SvgModelData get modelData => SvgModelData(widget.model.data);

  void refreshModel() => widget.eventBus.publish(BoardEventName.refreshModel, widget.model.id);
  void saveState() => widget.eventBus.publish(BoardEventName.saveState);

  bool _showCodeState = false;

  Widget buildEditor() {
    final controller = TextEditingController();
    controller.text = modelData.data;
    controller.addListener(() {
      modelData.data = controller.text;
      refreshModel();
    });
    return TextField(
      minLines: 100,
      maxLines: null,
      controller: controller,
    );
  }

  Widget buildColor() {
    void pickColor() async {
      final pickedColor = await showBoardColorPicker(context);
      if (pickedColor == null) return;
      modelData.color = pickedColor;
      setState(() {});
      refreshModel();
      saveState();
    }

    if (modelData.color == null) return TextButton(onPressed: pickColor, child: const Text('未选择颜色'));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: pickColor,
          child: Container(color: modelData.color, width: 50, height: 50),
        ),
        TextButton(
          onPressed: () {
            modelData.color = null;
            setState(() {});
            refreshModel();
            saveState();
          },
          child: const Text('取消覆盖'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModelAttribute(
      children: [
        ModelAttributeSection(
          title: 'SVG矢量图',
          items: [
            ModelAttributeItem(
              title: '导入SVG文件',
              child: TextButton(
                onPressed: () async {
                  final pfs = await FilePicker.platform.pickFiles(
                    dialogTitle: '上传附件',
                    type: FileType.custom,
                    allowedExtensions: ['svg'],
                  );
                  if (pfs == null || pfs.files.isEmpty) return;
                  final file = pfs.files.first;
                  if (file.path == null) return;
                  String filePath = file.path!;
                  modelData.data = await File(filePath).readAsString();
                  saveState();
                  setState(() {});
                  refreshModel();
                },
                child: const Text('导入SVG文件'),
              ),
            ),
            ModelAttributeItem(
              title: '填充方式',
              child: DropdownButton<BoxFit>(
                value: modelData.fit,
                items: BoxFit.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => modelData.fit = value);
                  refreshModel();
                  saveState();
                },
              ),
            ),
            ModelAttributeItem(
              title: '颜色覆盖',
              child: buildColor(),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            setState(() => _showCodeState = !_showCodeState);
          },
          child: Text('点击${_showCodeState ? '关闭' : '展开'}更多代码'),
        ),
        if (_showCodeState)
          ModelAttributeSection(
            title: 'SVG矢量图代码',
            items: [ModelAttributeItem(title: '', child: buildEditor())],
          ),
      ],
    );
  }
}
