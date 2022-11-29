import 'package:board_front/component/board_page/data.dart';
import 'package:board_front/component/board_page/plugins/plugins.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:json_model_sync/json_model_sync.dart';

Future<String?> showTextInputDialog({
  required BuildContext context,
  required String title,
  required String initialText,
}) async {
  return await showDialog<String>(
    context: context,
    builder: (ctx) {
      final controller = TextEditingController();
      controller.text = initialText;
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            TextField(controller: controller),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(controller.text);
                  },
                  child: const Text('确认'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showJoinDialog(BuildContext context, BoardUserNode node, String ownerId) async {
  final screenHeight = MediaQuery.of(context).size.height;
  final n = node;
  return showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: screenHeight * 0.6,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('参与人数：${n.onlineList.length}', style: Theme.of(context).textTheme.headline5),
                    ElevatedButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: n.roomId));
                          EasyLoading.showSuccess('白板ID已复制到剪切板');
                        },
                        child: const Text('复制白板ID')),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: n.onlineList.map((e) {
                      if (e == n.userNodeId) {
                        return ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          onTap: () async {
                            final username = await showTextInputDialog(
                              context: context,
                              title: '修改参会用户名',
                              initialText: n.username,
                            );
                            if (username == null) return;
                            n.username = username;
                            EasyLoading.showSuccess('用户名修改成功');
                            Navigator.of(context).pop();
                          },
                          title: Text(n.getUsernameByUserId(e)),
                          trailing: const Text('自己'),
                        );
                      }
                      if (e == ownerId) {
                        return ListTile(
                          leading: const Icon(Icons.person, color: Colors.orange),
                          title: Text(n.getUsernameByUserId(e)),
                          trailing: const Text('主持人'),
                        );
                      }
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(n.getUsernameByUserId(e)),
                        trailing: const Text('成员'),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}

Future<void> showProjectInfoDialog(BuildContext context, BoardPageSetViewModel pageSetViewModel) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('项目信息', style: Theme.of(context).textTheme.headline5),
              Text('页数：${pageSetViewModel.pageIdList.length}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('关闭')),
                ],
              ),
            ],
          ),
        );
      });
}

final defaultModelPluginManager = BoardModelPluginManager(
  initialPlugins: [
    RectModelPlugin(),
    LineModelPlugin(),
    OvalModelPlugin(),
    SvgModelPlugin(),
    PlantUMLModelPlugin(),
    ImageModelPlugin(),
    AttachmentModelPlugin(),
    FreeStyleModelPlugin(),
    HtmlModelPlugin(),
    MarkdownModelPlugin(),
  ],
);
