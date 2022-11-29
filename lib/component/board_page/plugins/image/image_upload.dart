import 'package:board_front/api/attachment.dart';
import 'package:board_front/api/image.dart';
import 'package:board_front/global.dart';
import 'package:board_front/storage/image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({Key? key}) : super(key: key);

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  ImageService get imageService => GlobalObjects.api.image;
  AttachmentService get attachment => GlobalObjects.api.attachment;
  ImageListStorage get storage => GlobalObjects.storage.image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('上传图片'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('是否清空所有图片列表', style: Theme.of(context).textTheme.headline5),
                          ElevatedButton(
                            onPressed: () {
                              storage.clear();
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                            child: const Text('清空'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('取消'),
                          ),
                        ],
                      ),
                    );
                  });
            },
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: ListView(
        children: storage.items.map((e) {
          return ListTile(
            title: Text(e.name),
            subtitle: Text('最近使用时间：${DateFormat('yyyy年MM月dd日 HH:mm:ss').format(e.ts)}'),
            leading: Image.network(e.thumbnailUrl),
            onTap: () {
              storage.addItem(name: e.name, rawUrl: e.rawUrl, thumbnailUrl: e.thumbnailUrl);
              Navigator.of(context).pop(e.rawUrl);
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.upload),
        onPressed: () async {
          final pfs = await FilePicker.platform.pickFiles(
            dialogTitle: '上传图片',
            type: FileType.image,
          );
          if (pfs == null || pfs.files.isEmpty) return;
          final file = pfs.files.first;
          if (file.path == null) return;
          String filePath = file.path!;
          print('上传图片：$filePath');
          EasyLoading.showProgress(0, status: '正在上传');
          final uploadResponse = await attachment.upload(await MultipartFile.fromFile(filePath));
          final url = uploadResponse.url;
          EasyLoading.dismiss();
          storage.addItem(
            name: filePath,
            rawUrl: url,
            thumbnailUrl: url,
          );
          setState(() {});
        },
      ),
    );
  }
}
