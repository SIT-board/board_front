import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/plugins/image/image_upload.dart';
import 'package:board_front/component/image_viewer/image_viewer.dart';
import 'package:flutter/material.dart';

import '../../model/model.dart';
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
  ImageModelData get modelData => ImageModelData(widget.model.data);

  void refreshModel() => widget.eventBus.publish(BoardEventName.refreshModel, widget.model.id);
  void saveState() => widget.eventBus.publish(BoardEventName.saveState);

  ModelAttributeItem buildImageUrl() {
    return ModelAttributeItem(
      title: '图片位置',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () async {
              final String? url = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const ImageUploadPage();
              }));
              if (url == null) return;
              modelData.url = url;
              saveState();
              refreshModel();
            },
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
        child: DropdownButton<BoxFit>(
          value: modelData.fit,
          items: BoxFit.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => modelData.fit = value);
            refreshModel();
            saveState();
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
