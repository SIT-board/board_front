import 'dart:io';

import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../model/model.dart';
import '../base_editor.dart';
import 'data.dart';

class PlantUMLModelEditor extends StatefulWidget {
  final Model model;
  final EventBus<BoardEventName> eventBus;
  const PlantUMLModelEditor({
    Key? key,
    required this.model,
    required this.eventBus,
  }) : super(key: key);

  @override
  State<PlantUMLModelEditor> createState() => _PlantUMLModelEditorState();
}

class _PlantUMLModelEditorState extends State<PlantUMLModelEditor> {
  PlantUMLModelData get modelData => PlantUMLModelData(widget.model.data);

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

  @override
  Widget build(BuildContext context) {
    return ModelAttribute(
      children: [
        ModelAttributeSection(
          title: 'PlantUML',
          items: [
            ModelAttributeItem(
              title: '导入PlantUML文件',
              child: TextButton(
                onPressed: () async {
                  final pfs = await FilePicker.platform.pickFiles(
                    dialogTitle: '导入PlantUML文件',
                    type: FileType.any,
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
                child: const Text('导入PlantUML文件'),
              ),
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
            title: 'PlantUML代码',
            items: [ModelAttributeItem(title: '', child: buildEditor())],
          ),
      ],
    );
  }
}
