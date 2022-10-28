import 'package:board_front/page/board.dart';
import 'package:flutter/material.dart';

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
                  child: Text('加入画板'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Widget buildListView(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.electric_bolt),
          title: const Text('创建画板'),
          subtitle: const Text('快速创建一个新的协作画板'),
          onTap: () async {
            List<String>? text = await showInputDialog(context);
            if (text == null) return;

            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return BoardPage(
                roomId: text[0],
                nodeId: text[1],
              );
            }));
          },
        ),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('加入画板'),
          subtitle: const Text('加入一个协作画板'),
          onTap: () {},
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
