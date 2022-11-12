import 'package:board_front/component/board_page/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:json_model_sync/json_model_sync.dart';

Future<void> showJoinDialog(BuildContext context, BoardUserNode node) async {
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
                      return ListTile(
                        title: Text(n.getUsernameByUserId(e)),
                        trailing: e == n.userNodeId ? const Text('自己') : null,
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
