import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/image_viewer/image_viewer.dart';
import 'package:flutter/material.dart';

import '../base_editor.dart';
import '../data.dart';
import 'data.dart';

class ImageModelEditor extends StatefulWidget {
  final Model model;
  final EventBus<BoardEventName>? eventBus;
  const ImageModelEditor({
    Key? key,
    required this.model,
    this.eventBus,
  }) : super(key: key);

  @override
  State<ImageModelEditor> createState() => _ImageModelEditorState();
}

class _ImageModelEditorState extends State<ImageModelEditor> {
  ImageModelData get modelData => widget.model.data as ImageModelData;

  void refreshModel() {
    widget.eventBus?.publish(BoardEventName.refreshModel, widget.model.id);
  }

  ModelAttributeItem buildImageUrl() {
    return ModelAttributeItem(
      title: '图片位置',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () {},
            child: const Text('修改图片'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ImageViewerPage(provider: NetworkImage(modelData.url));
              }));
            },
            child: const Text('查看图片'),
          ),
        ],
      ),
    );
  }

  ModelAttributeItem buildImageStyle() {
    return ModelAttributeItem(
        title: '填充方式',
        child: DropdownButton(
          value: modelData.fit,
          items: BoxFit.values
              .map((e) => DropdownMenuItem(
                    value: e.index,
                    child: Text(e.name),
                  ))
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => modelData.fit = value);
            refreshModel();
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ModelAttribute(
      children: [
        ModelAttributeSection(
          title: '图像属性',
          items: [
            buildImageUrl(),
            buildImageStyle(),
          ],
        ),
      ],
    );
  }
}