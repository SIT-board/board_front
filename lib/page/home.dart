import 'dart:async';

import 'package:board_front/global.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'board/local_board.dart';

Future<List<String>?> showInputDialog(BuildContext context) async {
  final controller = TextEditingController();
  final self = TextEditingController();
  final other = TextEditingController();
  controller.text = '123';
  return await showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '请输入房间号',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextField(controller: controller),
            TextField(controller: self),
            TextField(controller: other),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop([controller.text, self.text, other.text]);
                  },
                  child: const Text('加入画板'),
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget buildListView(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.draw),
          title: const Text('启动本地画板'),
          subtitle: const Text('创建一个仅自己可见的本地画板'),
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LocalBoardPage()));
            setState(() {});
          },
        ),
        ListTile(
          leading: const Icon(Icons.electric_bolt),
          title: const Text('创建协作画板'),
          subtitle: const Text('快速创建一个新的协作画板'),
          onTap: () async {
            List<String>? text = await showInputDialog(context);
            if (text == null) return;
          },
        ),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('加入协作画板'),
          subtitle: const Text('加入一个协作画板'),
          onTap: () {},
        ),
        const Divider(),
        const ListTile(title: Text('最近使用')),
        Expanded(
          child: ListView(
            children: GlobalObjects.storage.recentlyUsed.items.map((e) {
              return ListTile(
                title: Text(e.name),
                subtitle: Text('最近使用时间：${DateFormat('yyyy年MM月dd日 HH:mm:ss').format(e.ts)}'),
                onTap: () async {
                  await Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => LocalBoardPage(initialFilePath: e.name)));
                  setState(() {});
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('共享协作画板'),
      ),
      body: buildListView(context),
    );
  }
}
