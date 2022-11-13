import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/global.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../model/model.dart';
import '../base_editor.dart';
import 'data.dart';

class AttachmentModelEditor extends StatefulWidget {
  final Model model;
  final EventBus<BoardEventName> eventBus;
  const AttachmentModelEditor({
    Key? key,
    required this.model,
    required this.eventBus,
  }) : super(key: key);

  @override
  State<AttachmentModelEditor> createState() => _AttachmentModelEditorState();
}

class _AttachmentModelEditorState extends State<AttachmentModelEditor> {
  AttachmentModelData get modelData => AttachmentModelData(widget.model.data);

  void refreshModel() => widget.eventBus.publish(BoardEventName.refreshModel, widget.model.id);
  void saveState() => widget.eventBus.publish(BoardEventName.saveState);

  ModelAttributeItem buildAttachmentUrl() {
    return ModelAttributeItem(
      title: '',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () async {
              final pfs = await FilePicker.platform.pickFiles(
                dialogTitle: '上传附件',
                type: FileType.image,
              );
              if (pfs == null || pfs.files.isEmpty) return;
              final file = pfs.files.first;
              if (file.path == null) return;
              String filePath = file.path!;
              String fileName = file.name;
              print('上传附件：$filePath');
              EasyLoading.showProgress(0, status: '正在上传');
              final uploadResponse = await GlobalObjects.api.attachment.upload(await MultipartFile.fromFile(filePath));
              String url = uploadResponse.url;
              EasyLoading.dismiss();
              modelData.url = url;
              modelData.name = fileName;
              saveState();
              setState(() {});
              refreshModel();
            },
            child: const Text('修改附件'),
          ),
          TextButton(
            onPressed: () async {
              final filePath = await FilePicker.platform.saveFile(
                dialogTitle: '保存附件',
                fileName: modelData.name,
              );
              if (filePath == null) return;
              await Dio().download(
                modelData.url,
                filePath,
                onReceiveProgress: (count, total) {
                  EasyLoading.showProgress(count / total, status: '正在下载文件: ${modelData.name}');
                },
              );
              EasyLoading.dismiss();
              EasyLoading.showSuccess('下载成功');
            },
            child: const Text('下载附件'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController()..text = modelData.name;
    return ModelAttribute(
      children: [
        ModelAttributeSection(
          title: '附件属性',
          items: [
            buildAttachmentUrl(),
            ModelAttributeItem(
              title: '附件名称',
              child: TextField(
                controller: nameController,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
