import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/util/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:json_model_undo_redo/json_model_undo_redo.dart';

import 'board_page_event.dart';
import 'menu/menu.dart';

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
  final eventBus2 = EventBus<BoardEventName>();
  final controller = TransformationController();
  late final vm = BoardViewModel({});
  late final undoRedoManager = UndoRedoManager(
    vm.map,
    excludePath: {'viewerTransform'},
  );
  @override
  void initState() {
    eventBus.subscribe(BoardPageEventName.refreshBoard, onRefreshBoardEvent);
    BoardEventName.values.toSet()
      ..removeAll([
        BoardEventName.onModelMoving,
        BoardEventName.onModelResizing,
        BoardEventName.onModelRotating,
        BoardEventName.onViewportChanged,
      ])
      ..forEach(
        (e) => eventBus2.subscribe(e, (arg) {
          undoRedoManager.store();
        }),
      );
    super.initState();
  }

  @override
  void dispose() {
    eventBus.unsubscribe(BoardPageEventName.refreshBoard, onRefreshBoardEvent);
    super.dispose();
  }

  void onRefreshBoardEvent(arg) {
    final patch = undoRedoManager.store();
    if (patch.isEmpty()) return;
    setState(() {});
    print('画布刷新: $patch');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
        actions: [
          IconButton(
            onPressed: () {
              print("vmMap: ${vm.map}");
            },
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: !undoRedoManager.canUndo
                ? null
                : () {
                    print(undoRedoManager.undo());
                    setState(() {});
                  },
            icon: Icon(Icons.undo),
          ),
          IconButton(
            onPressed: !undoRedoManager.canRedo
                ? null
                : () {
                    print(undoRedoManager.redo());
                    setState(() {});
                  },
            icon: Icon(Icons.redo),
          ),
          IconButton(
            onPressed: () {
              print(undoRedoManager.history);
            },
            icon: Icon(Icons.ac_unit),
          ),
        ],
        leading: IconButton(
            onPressed: () {
              print(vm.map);
              showBoardColorPicker(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: BoardMenu(
        eventBus: eventBus,
        boardViewModel: vm,
        child: BoardViewModelWidget(
          // 视口变换控制器
          controller: controller,
          viewModel: vm,
          eventBus: eventBus2,
        ),
      ),
    );
  }
}
