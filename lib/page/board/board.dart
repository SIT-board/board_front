import 'dart:convert';

import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:flutter/material.dart';

import 'board_page_event.dart';
import 'menu.dart';

class BoardPage extends StatefulWidget {
  final String roomId;
  final String nodeId;

  const BoardPage({
    Key? key,
    required this.roomId,
    required this.nodeId,
  }) : super(key: key);

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final eventBus = EventBus<BoardPageEventName>();
  final controller = TransformationController();
  final vm = BoardViewModel({});

  @override
  void initState() {
    eventBus.subscribe(BoardPageEventName.refreshBoard, onRefreshBoardEvent);
    controller.addListener(() => eventBus.publish(BoardPageEventName.viewCameraChange, controller.value));
    super.initState();
  }

  @override
  void dispose() {
    eventBus.unsubscribe(BoardPageEventName.refreshBoard, onRefreshBoardEvent);
    super.dispose();
  }

  void onRefreshBoardEvent(arg) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
        actions: [
          IconButton(
              onPressed: () {
                print(jsonEncode(vm.map));
              },
              icon: Icon(Icons.ac_unit))
        ],
        leading: IconButton(
            onPressed: () {
              print(vm.map);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: LongPressedMenu(
        eventBus: eventBus,
        boardViewModel: vm,
        child: BoardViewModelWidget(
          // 视口变换控制器
          controller: controller,
          viewModel: vm,
          onChanged: (List<String> path, dynamic value) {
            // node.broadcast('cmd', jsonEncode([path, value]));
            // node.broadcastBoard(vm);
            print('$path=$value');
          },
        ),
      ),
    );
  }
}
