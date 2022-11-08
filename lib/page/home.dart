import 'dart:async';

import 'package:board_front/component/board_page/board.dart';
import 'package:board_front/component/board_page/data.dart';
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
  final m1 = BoardPageSetViewModel.createNew();

  HomePage({Key? key}) : super(key: key);

  Widget buildListView(BuildContext context) {
    ValueNotifier<BoardPageSetViewModel?> notifier = ValueNotifier(null);
    //
    // final nodeSender = BoardNode(roomId: '123', nodeId: '1');
    // final nodeReceiver = BoardNode(roomId: '123', nodeId: '2');

    // nodeReceiver.registerForOnReceive(
    //     topic: 'board',
    //     callback: (msg) {
    //       notifier.value = BoardPageSetViewModel(jsonDecode(msg.data));
    //       notifier.notifyListeners();
    //     });

    // Future.wait([nodeSender.connect(), nodeReceiver.connect()]).then((value) {
    //   Timer.periodic(Duration(seconds: 1), (timer) {
    //     nodeSender.sendTo('2', 'board', m1.toJsonString());
    //     print(m1.toJsonString());
    //   });
    // });
    Future.delayed(Duration.zero, () {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return Row(
          children: [
            Expanded(child: BoardPage(pageSetViewModel: m1)),
            // Expanded(
            //   child: ValueListenableBuilder<BoardPageSetViewModel?>(
            //     valueListenable: notifier,
            //     builder: (c, m, w) {
            //       if (m == null) return Center(child: const CircularProgressIndicator());
            //       return BoardPage(pageSetViewModel: m);
            //     },
            //   ),
            // ),
          ],
        );
      }));
    });
    return ListView(
      children: [
        // ListTile(
        //   leading: const Icon(Icons.electric_bolt),
        //   title: const Text('创建画板'),
        //   subtitle: const Text('快速创建一个新的协作画板'),
        //   onTap: () async {
        //     List<String>? text = await showInputDialog(context);
        //     if (text == null) return;
        //
        //     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        //       return BoardPage();
        //     }));
        //   },
        // ),
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
